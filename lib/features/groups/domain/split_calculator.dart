import '../../../core/domain/enums.dart';

/// One participant of a split with its method-specific [input]:
/// * equal — ignored
/// * exact — share in paise
/// * percentage — basis points (100 = 1%)
/// * ratio — integer weight
/// * adjustment — paise added to (or, if negative, removed from) the
///   participant's equal share
class SplitParticipant {
  const SplitParticipant(this.memberId, this.input);

  final String memberId;
  final int input;

  @override
  String toString() => 'SplitParticipant($memberId, $input)';
}

sealed class SplitOutcome {
  const SplitOutcome();
}

class SplitSuccess extends SplitOutcome {
  const SplitSuccess(this.shares);

  /// Shares in paise, in participant order (Dart map literals preserve
  /// insertion order). Always sums to the total.
  final Map<String, int> shares;

  @override
  String toString() => 'SplitSuccess($shares)';
}

class SplitFailure extends SplitOutcome {
  const SplitFailure(this.error);

  final SplitError error;

  @override
  String toString() => 'SplitFailure($error)';
}

sealed class SplitError {
  const SplitError();
}

class SplitInvalidTotal extends SplitError {
  const SplitInvalidTotal();
}

class SplitNoParticipants extends SplitError {
  const SplitNoParticipants();
}

class SplitDuplicateParticipant extends SplitError {
  const SplitDuplicateParticipant(this.memberId);
  final String memberId;
}

class SplitNegativeInput extends SplitError {
  const SplitNegativeInput(this.memberId);
  final String memberId;
}

/// Exact amounts do not add up. [differencePaise] = sum(inputs) − total.
class SplitExactMismatch extends SplitError {
  const SplitExactMismatch(this.differencePaise);
  final int differencePaise;
}

class SplitPercentageInvalid extends SplitError {
  const SplitPercentageInvalid(this.totalBasisPoints);
  final int totalBasisPoints;
}

class SplitInputTooLarge extends SplitError {
  const SplitInputTooLarge(this.memberId);
  final String memberId;
}

class SplitZeroWeights extends SplitError {
  const SplitZeroWeights();
}

class SplitAdjustmentsExceedTotal extends SplitError {
  const SplitAdjustmentsExceedTotal();
}

class SplitNegativeShare extends SplitError {
  const SplitNegativeShare(this.memberId);
  final String memberId;
}

/// Splits a group expense into per-member shares using integer paise only.
///
/// Remainder rule (deterministic): when an amount cannot be divided exactly,
/// leftover paise are handed out one at a time — for proportional methods to
/// the participants with the largest fractional remainder first, ties (and
/// the equal split) resolved by participant order. The result always sums to
/// the expense total.
abstract final class SplitCalculator {
  static const int fullPercentageBasisPoints = 10000;
  static const int maxRatioWeight = 1000000;

  static SplitOutcome calculate({
    required int totalPaise,
    required SplitMethod method,
    required List<SplitParticipant> participants,
  }) {
    if (totalPaise <= 0) return const SplitFailure(SplitInvalidTotal());
    if (participants.isEmpty) return const SplitFailure(SplitNoParticipants());

    final seen = <String>{};
    for (final p in participants) {
      if (!seen.add(p.memberId)) {
        return SplitFailure(SplitDuplicateParticipant(p.memberId));
      }
      if (method != SplitMethod.equal &&
          method != SplitMethod.adjustment &&
          p.input < 0) {
        return SplitFailure(SplitNegativeInput(p.memberId));
      }
    }

    return switch (method) {
      SplitMethod.equal => _success(
        participants,
        _equal(totalPaise, participants.length),
      ),
      SplitMethod.exact => _exact(totalPaise, participants),
      SplitMethod.percentage => _percentage(totalPaise, participants),
      SplitMethod.ratio => _ratio(totalPaise, participants),
      SplitMethod.adjustment => _adjustment(totalPaise, participants),
    };
  }

  static List<int> _equal(int total, int n) {
    final base = total ~/ n;
    final remainder = total % n;
    return [for (var i = 0; i < n; i++) base + (i < remainder ? 1 : 0)];
  }

  static SplitOutcome _exact(int total, List<SplitParticipant> ps) {
    final sum = ps.fold<int>(0, (a, p) => a + p.input);
    if (sum != total) return SplitFailure(SplitExactMismatch(sum - total));
    return _success(ps, [for (final p in ps) p.input]);
  }

  static SplitOutcome _percentage(int total, List<SplitParticipant> ps) {
    final sum = ps.fold<int>(0, (a, p) => a + p.input);
    if (sum != fullPercentageBasisPoints) {
      return SplitFailure(SplitPercentageInvalid(sum));
    }
    return _success(
      ps,
      _proportional(total, [for (final p in ps) p.input], sum),
    );
  }

  static SplitOutcome _ratio(int total, List<SplitParticipant> ps) {
    for (final p in ps) {
      if (p.input > maxRatioWeight) {
        return SplitFailure(SplitInputTooLarge(p.memberId));
      }
    }
    final sum = ps.fold<int>(0, (a, p) => a + p.input);
    if (sum == 0) return const SplitFailure(SplitZeroWeights());
    return _success(
      ps,
      _proportional(total, [for (final p in ps) p.input], sum),
    );
  }

  static SplitOutcome _adjustment(int total, List<SplitParticipant> ps) {
    final adjustments = ps.fold<int>(0, (a, p) => a + p.input);
    final pool = total - adjustments;
    if (pool < 0) return const SplitFailure(SplitAdjustmentsExceedTotal());
    final equal = _equal(pool, ps.length);
    final shares = <int>[];
    for (var i = 0; i < ps.length; i++) {
      final share = equal[i] + ps[i].input;
      if (share < 0) return SplitFailure(SplitNegativeShare(ps[i].memberId));
      shares.add(share);
    }
    return _success(ps, shares);
  }

  /// Largest-remainder apportionment of [total] by [weights] / [denominator].
  static List<int> _proportional(
    int total,
    List<int> weights,
    int denominator,
  ) {
    final floors = <int>[];
    final remainders = <int>[];
    var allocated = 0;
    for (final w in weights) {
      final raw = total * w;
      final share = raw ~/ denominator;
      floors.add(share);
      remainders.add(raw % denominator);
      allocated += share;
    }
    var leftover = total - allocated;
    final order = List<int>.generate(weights.length, (i) => i)
      ..sort((a, b) {
        final byRemainder = remainders[b].compareTo(remainders[a]);
        return byRemainder != 0 ? byRemainder : a.compareTo(b);
      });
    for (final index in order) {
      if (leftover == 0) break;
      // A participant with zero weight never receives remainder paise.
      if (weights[index] == 0) continue;
      floors[index]++;
      leftover--;
    }
    return floors;
  }

  static SplitSuccess _success(List<SplitParticipant> ps, List<int> shares) {
    final map = <String, int>{};
    for (var i = 0; i < ps.length; i++) {
      map[ps[i].memberId] = shares[i];
    }
    return SplitSuccess(map);
  }
}
