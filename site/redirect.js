// HisabMitra moved to its own website. Keeps the page and the query, so
// invitation links shared from app 1.2.0 (…/join?code=…) still work.
(function () {
  var site = 'https://hisab-mitra-web.vercel.app';
  var path = document.currentScript.getAttribute('data-path') || '/';
  location.replace(site + path + location.search + location.hash);
})();
