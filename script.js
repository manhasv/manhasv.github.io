document.addEventListener('DOMContentLoaded', () => {
    
    // 1. Dynamic Year in Footer
    const yearSpan = document.getElementById('year');
    if(yearSpan) {
        yearSpan.textContent = new Date().getFullYear();
    }

    // 2. Active Link Highlighting
    // Automatically highlights the nav link corresponding to the current page
    const currentLocation = location.href;
    const menuItem = document.querySelectorAll('.site-nav a');
    const menuLength = menuItem.length;
    
    for (let i = 0; i < menuLength; i++) {
        if (menuItem[i].href === currentLocation) {
            menuItem[i].className = "active";
        }
    }

    // 3. Optional: Add fade-in effect to main content
    const content = document.querySelector('.content-wrapper');
    content.style.opacity = 0;
    content.style.transition = 'opacity 0.5s ease-in-out';
    
    setTimeout(() => {
        content.style.opacity = 1;
    }, 100);
});