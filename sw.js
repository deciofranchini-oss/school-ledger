// sw.js — Service Worker para funcionamento offline (v2 com módulos)

const CACHE = 'school-ledger-v2';
const ASSETS = [
  './index.html',
  './manifest.json',
  './app/main.js',
  './app/db.js',
  './app/state.js',
  './app/utils.js',
  './app/seed.js',
  './app/settings.js',
  './app/reporting.js',
  './app/aiService.js',
  './app/charts.js'
];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(ASSETS)));
  self.skipWaiting();
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', e => {
  e.respondWith(
    caches.match(e.request).then(cached => cached || fetch(e.request))
  );
});
