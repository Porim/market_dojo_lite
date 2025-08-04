// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "channels"
import "./react_rfq_filter"
import { initDarkMode } from "./dark_mode"

// Initialize dark mode on page load
document.addEventListener('DOMContentLoaded', () => {
  initDarkMode();
});

// Initialize dark mode after Turbo navigation
document.addEventListener('turbo:load', () => {
  initDarkMode();
});
