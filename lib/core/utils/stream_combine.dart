import 'dart:async';

/// Emits `combiner(a, b)` whenever either stream emits, once both have
/// emitted at least once. Errors are forwarded; completes when both are done.
Stream<R> combineLatest2<A, B, R>(
  Stream<A> a,
  Stream<B> b,
  R Function(A a, B b) combiner,
) => combineLatestList<Object?, R>([
  a,
  b,
], (values) => combiner(values[0] as A, values[1] as B));

Stream<R> combineLatest3<A, B, C, R>(
  Stream<A> a,
  Stream<B> b,
  Stream<C> c,
  R Function(A a, B b, C c) combiner,
) => combineLatestList<Object?, R>([
  a,
  b,
  c,
], (v) => combiner(v[0] as A, v[1] as B, v[2] as C));

Stream<R> combineLatestList<T, R>(
  List<Stream<T>> streams,
  R Function(List<T> values) combiner,
) {
  late StreamController<R> controller;
  final subscriptions = <StreamSubscription<T>>[];
  final values = List<T?>.filled(streams.length, null);
  final hasValue = List<bool>.filled(streams.length, false);
  var done = 0;

  controller = StreamController<R>(
    onListen: () {
      for (var i = 0; i < streams.length; i++) {
        subscriptions.add(
          streams[i].listen(
            (value) {
              values[i] = value;
              hasValue[i] = true;
              if (hasValue.every((h) => h)) {
                try {
                  controller.add(combiner(values.cast<T>()));
                } catch (e, s) {
                  controller.addError(e, s);
                }
              }
            },
            onError: controller.addError,
            onDone: () {
              done++;
              if (done == streams.length) controller.close();
            },
          ),
        );
      }
    },
    onPause: () {
      for (final s in subscriptions) {
        s.pause();
      }
    },
    onResume: () {
      for (final s in subscriptions) {
        s.resume();
      }
    },
    // Cancel sources without making the listener wait: `Stream.first`
    // completes only after the cancel future does, and a source that is slow
    // to tear down must not delay a one-off snapshot.
    onCancel: () {
      for (final s in subscriptions) {
        unawaited(s.cancel());
      }
    },
  );
  return controller.stream;
}
