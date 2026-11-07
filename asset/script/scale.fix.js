var metas = document.getElementsByTagName('meta');
var i;
if (navigator.userAgent.match(/iPhone/i)) {
  for (i=0; i<metas.length; i++) {
    if (metas[i].name == "viewport") {
      metas[i].content = "width=device-width, minimum-scale=1.0, maximum-scale=1.0";
    }
  }
  document.addEventListener("gesturestart", gestureStart, false);
}
function gestureStart() {
  for (i=0; i<metas.length; i++) {
    if (metas[i].name == "viewport") {
      metas[i].content = "width=device-width, minimum-scale=0.25, maximum-scale=1.6";
    }
  }
}
const navLinks = document.querySelectorAll('.nav-link');
  const tabs = document.querySelectorAll('.tab-content > div');

  navLinks.forEach(link => {
  link.addEventListener('click', () => {
      navLinks.forEach(l => l.classList.remove('active'));
      tabs.forEach(t => t.classList.remove('active'));

      link.classList.add('active');
      document.getElementById(link.dataset.tab).classList.add('active');
    });
});

const themeToggle = document.querySelector('.theme-toggle');

if (themeToggle) {
  themeToggle.addEventListener('click', () => {
    const root = document.documentElement;
    const next = root.getAttribute('data-theme') === 'light' ? 'dark' : 'light';

    if (next === 'light') {
      root.setAttribute('data-theme', 'light');
    } else {
      root.removeAttribute('data-theme');
    }

    try {
      localStorage.setItem('theme', next);
    } catch (e) { }
  });
}

// "View in 3D": create the embedded viewer on click, remove it on close
// (splats are heavy, so nothing loads until someone asks for it).
document.querySelectorAll('.viewer-toggle').forEach(btn => {
  btn.addEventListener('click', () => {
    const viewer = btn.closest('.item').querySelector('.item-viewer');
    if (!viewer) return;

    const open = btn.getAttribute('aria-expanded') === 'true';
    if (open) {
      viewer.replaceChildren();
      viewer.hidden = true;
      btn.setAttribute('aria-expanded', 'false');
      btn.querySelector('.label').textContent = 'View in 3D';
    } else {
      const frame = document.createElement('iframe');
      frame.src = btn.dataset.src;
      frame.title = 'Interactive 3D Gaussian Splatting viewer';
      frame.allow = 'fullscreen; xr-spatial-tracking';
      frame.allowFullscreen = true;
      viewer.replaceChildren(frame);
      viewer.hidden = false;
      btn.setAttribute('aria-expanded', 'true');
      btn.querySelector('.label').textContent = 'Hide 3D';
    }
  });
});

