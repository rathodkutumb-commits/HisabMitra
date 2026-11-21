// Invitation page: https://<owner>.github.io/<repo>/join?code=CODE
// Opens HisabMitra (hisabmitra://join?code=CODE) on the join screen.
// No tracking, no external requests.
(function () {
  'use strict';

  var APP_PACKAGE = 'com.hisabmitra.app';
  // Used when the page is not served from <owner>.github.io/<repo>/.
  var DEFAULT_OWNER = 'rathodkutumb-commits';
  var DEFAULT_REPO = 'HisabMitra';

  var params = new URLSearchParams(window.location.search);
  var code = (params.get('code') || '').trim().toUpperCase();
  var valid = /^[A-Z0-9]{6,12}$/.test(code);
  var noApp = params.has('noapp');
  var isAndroid = /android/i.test(navigator.userAgent);

  function repository() {
    var host = window.location.hostname;
    var first = window.location.pathname.split('/')[1] || '';
    if (/\.github\.io$/i.test(host) && first && first.indexOf('.') < 0) {
      return { owner: host.split('.')[0], repo: first };
    }
    return { owner: DEFAULT_OWNER, repo: DEFAULT_REPO };
  }

  var repo = repository();
  var downloadUrl =
    'https://github.com/' + repo.owner + '/' + repo.repo + '/releases/latest';
  var downloads = document.querySelectorAll('.download');
  for (var i = 0; i < downloads.length; i++) {
    downloads[i].href = downloadUrl;
  }

  if (!valid) {
    document.getElementById('invalid').hidden = false;
    return;
  }

  document.getElementById('valid').hidden = false;
  document.getElementById('code').textContent = code;

  var appLink = 'hisabmitra://join?code=' + code;
  if (isAndroid) {
    // When the app is missing, Chrome comes back to this page with
    // noapp=1 (shown below, and never tried again automatically).
    var page = window.location.href.split('#')[0];
    var fallback = noApp ? page : page + '&noapp=1';
    appLink =
      'intent://join?code=' + code +
      '#Intent;scheme=hisabmitra;package=' + APP_PACKAGE +
      ';S.browser_fallback_url=' + encodeURIComponent(fallback) + ';end';
  }
  document.getElementById('open').href = appLink;

  var copy = document.getElementById('copy');
  copy.addEventListener('click', function () {
    var done = function () {
      copy.textContent = 'Copied ✓ · કોપી થયો ✓';
    };
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(code).then(done, function () {});
    }
  });

  if (noApp) {
    document.getElementById('noapp').hidden = false;
    downloads[0].classList.add('primary');
  } else if (isAndroid) {
    // Try once; browsers that need a tap keep the button.
    window.location.href = appLink;
  }
})();
