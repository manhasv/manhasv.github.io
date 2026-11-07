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
