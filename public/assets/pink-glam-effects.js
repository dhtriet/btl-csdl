/** Decorative desktop effects shared by the PHP portal and React example. */
export function mountGlamEffects() {
  const desktop = window.matchMedia('(min-width: 1000px)');
  const reduced = window.matchMedia('(prefers-reduced-motion: reduce)');
  const finePointer = window.matchMedia('(pointer: fine)');
  const html = document.documentElement;
  const atmosphere = document.createElement('div');
  atmosphere.className = 'glam-atmosphere';
  atmosphere.setAttribute('aria-hidden', 'true');
  for (let i = 0; i < 28; i++) {
    const star = document.createElement('span');
    star.className = `glam-dust${i % 4 === 0 ? ' is-pearl' : ''}`;
    star.style.cssText = `--x:${(i * 37 + 9) % 100}%;--y:${(i * 29 + 7) % 100}%;--size:${i % 5 === 0 ? 18 : 5 + i % 4 * 3}px;--delay:${-i * .43}s;--duration:${4.5 + i % 5}s`;
    atmosphere.append(star);
  }

  const canvas = document.createElement('canvas');
  canvas.className = 'glam-pointer-sparkles';
  canvas.setAttribute('aria-hidden', 'true');
  const ctx = canvas.getContext('2d');
  const toggle = document.createElement('button');
  toggle.className = 'glam-effects-toggle';
  toggle.type = 'button';
  toggle.innerHTML = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m10 2 2.2 6.8L19 11l-6.8 2.2L10 20l-2.2-6.8L1 11l6.8-2.2Z"/><path d="m20 1 .8 2.2L23 4l-2.2.8L20 7l-.8-2.2L17 4l2.2-.8Z"/></svg>';

  const ornament = document.createElement('div');
  ornament.className = 'glam-heart-orbit';
  ornament.setAttribute('aria-hidden', 'true');
  ornament.innerHTML = '<svg viewBox="0 0 130 130"><defs><radialGradient id="glam-heart-material" cx="30%" cy="18%" r="85%"><stop stop-color="#fffafd"/><stop offset=".24" stop-color="#ffb7dc"/><stop offset=".65" stop-color="#ff1493"/><stop offset="1" stop-color="#ad1457"/></radialGradient></defs><ellipse cx="66" cy="74" rx="59" ry="20" fill="none" stroke="#fffafd" stroke-width="1.5" transform="rotate(-28 66 74)"/><path d="M65 103 31 70C4 42 43 12 65 42 87 12 126 42 99 70Z" fill="url(#glam-heart-material)" stroke="#fffafd" stroke-width="1.5"/><path d="M36 50c2-9 11-13 18-9" fill="none" stroke="#fffafd" stroke-width="4" stroke-linecap="round" opacity=".85"/><path d="m108 10 3 10 10 3-10 3-3 10-3-10-10-3 10-3Z" fill="#fffafd"/><circle cx="19" cy="96" r="3" fill="#ff69b4"/></svg>';
  document.body.append(atmosphere, canvas, toggle);
  const banner = document.querySelector('.campus-discovery');
  if (banner) banner.append(ornament);

  let enabled = true;
  try { enabled = localStorage.getItem('nexus-glam-effects') !== 'off'; } catch { /* Storage is optional. */ }
  let frame = 0;
  let particles = [];
  let lastTime = 0;
  let lastEmission = 0;
  let width = innerWidth;
  let height = innerHeight;
  const colors = ['#d81b60', '#ff69b4', '#fffafd', '#ad1457'];
  const canAnimate = () => enabled && desktop.matches && !reduced.matches && !document.hidden;

  function resize() {
    width = innerWidth;
    height = innerHeight;
    const dpr = Math.min(devicePixelRatio || 1, 1.5);
    canvas.width = Math.round(width * dpr);
    canvas.height = Math.round(height * dpr);
    if (ctx) ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  }
  function stop() {
    cancelAnimationFrame(frame);
    frame = 0;
    particles = [];
    if (ctx) ctx.clearRect(0, 0, width, height);
  }
  function sync() {
    html.classList.toggle('glam-fx-paused', !enabled || document.hidden || !desktop.matches);
    toggle.setAttribute('aria-pressed', String(enabled));
    const label = enabled ? 'Tắt hiệu ứng lấp lánh' : 'Bật hiệu ứng lấp lánh';
    toggle.setAttribute('aria-label', label);
    toggle.title = label;
    if (!canAnimate()) stop();
  }
  function drawStar(x, y, size, rotation) {
    ctx.save();
    ctx.translate(x, y);
    ctx.rotate(rotation);
    ctx.beginPath();
    for (let n = 0; n < 8; n++) {
      const angle = n * Math.PI / 4;
      const radius = n % 2 ? size * .23 : size;
      const px = Math.cos(angle) * radius;
      const py = Math.sin(angle) * radius;
      if (n === 0) ctx.moveTo(px, py); else ctx.lineTo(px, py);
    }
    ctx.closePath();
    ctx.fill();
    ctx.restore();
  }
  function tick(time) {
    if (!canAnimate() || !ctx) { stop(); return; }
    const delta = Math.min((time - lastTime) / 16.67 || 1, 2);
    lastTime = time;
    ctx.clearRect(0, 0, width, height);
    particles = particles.filter(p => time - p.born < p.life);
    for (const p of particles) {
      const progress = (time - p.born) / p.life;
      p.x += p.vx * delta;
      p.y += p.vy * delta;
      p.vy += .028 * delta;
      ctx.globalAlpha = Math.sin(Math.PI * Math.min(1, progress + .08)) * .85;
      ctx.fillStyle = p.color;
      drawStar(p.x, p.y, p.size * (1 - progress * .65), p.rotation + progress);
    }
    ctx.globalAlpha = 1;
    frame = particles.length ? requestAnimationFrame(tick) : 0;
  }
  function emit(x, y, burst = false) {
    if (!canAnimate() || !ctx) return;
    const time = performance.now();
    const count = burst ? 14 : 2;
    for (let i = 0; i < count; i++) {
      const angle = burst ? i / count * Math.PI * 2 : Math.random() * Math.PI * 2;
      const speed = burst ? 1.5 + Math.random() * 2.2 : .3;
      particles.push({ x, y, vx: Math.cos(angle) * speed, vy: Math.sin(angle) * speed - .3, born: time, life: burst ? 850 : 600, size: burst ? 4 + Math.random() * 5 : 3 + Math.random() * 4, color: colors[i % colors.length], rotation: Math.random() });
    }
    particles = particles.slice(-90);
    if (!frame) { lastTime = time; frame = requestAnimationFrame(tick); }
  }
  function pointerMove(event) {
    if (!finePointer.matches || event.pointerType === 'touch' || performance.now() - lastEmission < 55) return;
    lastEmission = performance.now();
    emit(event.clientX, event.clientY);
  }
  function pointerUp(event) {
    if (event.target instanceof Element && event.target.closest('button:not(:disabled), a') && !toggle.contains(event.target)) emit(event.clientX, event.clientY, true);
  }
  function switchEffects() {
    enabled = !enabled;
    try { localStorage.setItem('nexus-glam-effects', enabled ? 'on' : 'off'); } catch { /* Storage is optional. */ }
    sync();
  }
  // Only the banner's authored material loops; pause it when the banner is out of view.
  const observer = 'IntersectionObserver' in window ? new IntersectionObserver(entries => {
    for (const entry of entries) entry.target.classList.toggle('glam-banner-offscreen', !entry.isIntersecting);
  }) : null;
  if (observer && banner) observer.observe(banner);
  const greeting = document.querySelector('.dashboard-intro h1');
  if (observer && greeting) observer.observe(greeting);
  window.addEventListener('resize', resize, { passive: true });
  window.addEventListener('pointermove', pointerMove, { passive: true });
  window.addEventListener('pointerup', pointerUp, { passive: true });
  document.addEventListener('visibilitychange', sync);
  desktop.addEventListener('change', sync);
  reduced.addEventListener('change', sync);
  toggle.addEventListener('click', switchEffects);
  resize();
  sync();
  return () => {
    stop(); observer?.disconnect();
    window.removeEventListener('resize', resize);
    window.removeEventListener('pointermove', pointerMove);
    window.removeEventListener('pointerup', pointerUp);
    document.removeEventListener('visibilitychange', sync);
    desktop.removeEventListener('change', sync);
    reduced.removeEventListener('change', sync);
    toggle.removeEventListener('click', switchEffects);
    atmosphere.remove(); canvas.remove(); toggle.remove(); ornament.remove();
    html.classList.remove('glam-fx-paused');
    banner?.classList.remove('glam-banner-offscreen');
    greeting?.classList.remove('glam-banner-offscreen');
  };
}
