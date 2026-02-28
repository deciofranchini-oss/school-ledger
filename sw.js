/* ══════════════════════════════════════════════════════
   Pag. D&B — Service Worker v2.0
   Estratégia: network-first para HTML, cache para assets estáticos
   Supabase API nunca é interceptada pelo SW
══════════════════════════════════════════════════════ */

const CACHE_NAME = 'pag-db-v3';

const STATIC_ASSETS = [
  './manifest.json',
  './icon.svg',
  './icon-192.png',
  './icon-512.png',
];

/* ─── INSTALL ─── */
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(STATIC_ASSETS).catch(() => {}))
      .then(() => self.skipWaiting())
  );
});

/* ─── ACTIVATE: apaga todos os caches antigos ─── */
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.map(key => caches.delete(key))))
      .then(() => self.clients.claim())
  );
});

/* ─── FETCH ─── */
self.addEventListener('fetch', event => {
  const { request } = event;
  const url = new URL(request.url);

  // Nunca interceptar chamadas ao Supabase
  if (url.hostname.includes('supabase.co')) return;

  // Nunca interceptar métodos não-GET
  if (request.method !== 'GET') return;

  // Chrome extensions / data URLs
  if (url.protocol === 'chrome-extension:' || url.protocol === 'data:') return;

  // index.html: sempre busca da rede (network-first), sem cache
  if (url.pathname.endsWith('/') || url.pathname.endsWith('index.html') || url.pathname.endsWith('school-ledger/')) {
    event.respondWith(
      fetch(request).catch(() => caches.match('./index.html'))
    );
    return;
  }

  // Fontes Google: cache com revalidação
  if (url.hostname.includes('fonts.googleapis.com') || url.hostname.includes('fonts.gstatic.com')) {
    event.respondWith(staleWhileRevalidate(request));
    return;
  }

  // Assets estáticos (ícones, manifesto): cache-first
  if (STATIC_ASSETS.some(a => url.pathname.endsWith(a.replace('./', '')))) {
    event.respondWith(cacheFirst(request));
    return;
  }

  // Todo o resto: network-first
  event.respondWith(networkFirst(request));
});

async function cacheFirst(request) {
  const cached = await caches.match(request);
  if (cached) return cached;
  const response = await fetch(request);
  if (response.ok) {
    const cache = await caches.open(CACHE_NAME);
    cache.put(request, response.clone());
  }
  return response;
}

async function networkFirst(request) {
  try {
    const response = await fetch(request);
    if (response.ok) {
      const cache = await caches.open(CACHE_NAME);
      cache.put(request, response.clone());
    }
    return response;
  } catch {
    return caches.match(request) || new Response('Offline', { status: 503 });
  }
}

async function staleWhileRevalidate(request) {
  const cached = await caches.match(request);
  const fetchPromise = fetch(request).then(response => {
    if (response.ok) caches.open(CACHE_NAME).then(c => c.put(request, response.clone()));
    return response;
  }).catch(() => null);
  return cached || await fetchPromise;
}

/* ─── MENSAGEM: limpar cache sob demanda ─── */
self.addEventListener('message', event => {
  if (event.data === 'CLEAR_CACHE') {
    caches.keys().then(keys => Promise.all(keys.map(k => caches.delete(k))))
      .then(() => event.source?.postMessage('CACHE_CLEARED'));
  }
});
