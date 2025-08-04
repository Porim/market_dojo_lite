// Dark mode functionality
export function initDarkMode() {
  // Check for saved dark mode preference or default to light mode
  const currentTheme = localStorage.getItem('theme') || 'light';
  
  // Apply the saved theme on load
  if (currentTheme === 'dark') {
    document.documentElement.classList.add('dark');
  }
  
  // Set up toggle buttons
  const darkModeToggles = document.querySelectorAll('[data-dark-mode-toggle]');
  
  darkModeToggles.forEach(toggle => {
    // Update toggle state
    updateToggleState(toggle, currentTheme === 'dark');
    
    toggle.addEventListener('click', () => {
      const isDark = document.documentElement.classList.toggle('dark');
      localStorage.setItem('theme', isDark ? 'dark' : 'light');
      
      // Update all toggle states
      darkModeToggles.forEach(t => updateToggleState(t, isDark));
    });
  });
}

function updateToggleState(toggle, isDark) {
  const sunIcon = toggle.querySelector('.sun-icon');
  const moonIcon = toggle.querySelector('.moon-icon');
  
  if (sunIcon && moonIcon) {
    if (isDark) {
      sunIcon.classList.remove('hidden');
      moonIcon.classList.add('hidden');
    } else {
      sunIcon.classList.add('hidden');
      moonIcon.classList.remove('hidden');
    }
  }
}