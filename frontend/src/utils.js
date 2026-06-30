// =============================================
// FinTrack — Utility Functions
// =============================================

/**
 * Format a number as Indian Rupees (₹)
 * e.g., 145000 → "₹1,45,000"
 */
export function formatINR(amount, showSign = false) {
  if (amount == null || isNaN(amount)) return '₹0';
  const abs = Math.abs(amount);
  const formatted = abs.toLocaleString('en-IN', {
    maximumFractionDigits: 0,
    minimumFractionDigits: 0,
  });
  const sign = showSign ? (amount >= 0 ? '+' : '-') : (amount < 0 ? '-' : '');
  return `${sign}₹${formatted}`;
}

/**
 * Format with decimals
 */
export function formatINRDecimal(amount) {
  if (amount == null || isNaN(amount)) return '₹0.00';
  const abs = Math.abs(amount);
  const formatted = abs.toLocaleString('en-IN', {
    maximumFractionDigits: 2,
    minimumFractionDigits: 2,
  });
  return `${amount < 0 ? '-' : ''}₹${formatted}`;
}

/**
 * Format date relative to today
 */
export function formatRelativeDate(dateStr) {
  const date = new Date(dateStr);
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const yesterday = new Date(today);
  yesterday.setDate(yesterday.getDate() - 1);

  const d = new Date(date);
  d.setHours(0, 0, 0, 0);

  if (d.getTime() === today.getTime()) return 'Today';
  if (d.getTime() === yesterday.getTime()) return 'Yesterday';

  return date.toLocaleDateString('en-IN', {
    day: '2-digit',
    month: 'short',
    year: date.getFullYear() !== today.getFullYear() ? 'numeric' : undefined,
  });
}

/**
 * Format date with time
 */
export function formatDateTime(dateStr) {
  const date = new Date(dateStr);
  const datePart = formatRelativeDate(dateStr);
  const timePart = date.toLocaleTimeString('en-IN', {
    hour: '2-digit',
    minute: '2-digit',
    hour12: true,
  });
  return `${datePart}, ${timePart}`;
}

/**
 * Format full date
 */
export function formatFullDate(dateStr) {
  const date = new Date(dateStr);
  return date.toLocaleDateString('en-IN', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  });
}

/**
 * Get greeting based on time of day
 */
export function getGreeting() {
  const hour = new Date().getHours();
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

/**
 * Map category to Material Symbols icon name
 */
export function getCategoryIcon(category) {
  const map = {
    'food': 'restaurant',
    'food_dining': 'restaurant',
    'dining': 'restaurant',
    'groceries': 'local_grocery_store',
    'transport': 'commute',
    'transportation': 'commute',
    'shopping': 'shopping_bag',
    'entertainment': 'movie',
    'leisure': 'movie',
    'health': 'medical_services',
    'healthcare': 'medical_services',
    'housing': 'home_repair_service',
    'rent': 'home_repair_service',
    'utilities': 'electric_bolt',
    'bills': 'receipt',
    'education': 'school',
    'travel': 'flight',
    'salary': 'work',
    'income': 'payments',
    'investment': 'monitoring',
    'savings': 'savings',
    'insurance': 'health_and_safety',
    'personal': 'person',
    'electronics': 'devices',
    'fuel': 'directions_car',
    'other': 'more_horiz',
  };
  return map[(category || '').toLowerCase()] || 'category';
}

/**
 * Map category to color classes
 */
export function getCategoryColor(category) {
  const map = {
    'food': { bg: 'bg-primary/10', text: 'text-primary', border: 'border-primary/20' },
    'food_dining': { bg: 'bg-primary/10', text: 'text-primary', border: 'border-primary/20' },
    'dining': { bg: 'bg-purple-500/10', text: 'text-purple-400', border: 'border-purple-500/20' },
    'transport': { bg: 'bg-secondary-container/20', text: 'text-secondary', border: 'border-secondary/20' },
    'transportation': { bg: 'bg-teal-500/10', text: 'text-teal-400', border: 'border-teal-500/20' },
    'shopping': { bg: 'bg-secondary-container/20', text: 'text-secondary', border: 'border-secondary/20' },
    'entertainment': { bg: 'bg-error-container/20', text: 'text-error', border: 'border-error/20' },
    'leisure': { bg: 'bg-orange-500/10', text: 'text-orange-400', border: 'border-orange-500/20' },
    'health': { bg: 'bg-green-500/10', text: 'text-green-400', border: 'border-green-500/20' },
    'housing': { bg: 'bg-primary-container/20', text: 'text-primary', border: 'border-primary/20' },
    'salary': { bg: 'bg-green-500/20', text: 'text-green-400', border: 'border-green-500/20' },
    'income': { bg: 'bg-green-500/20', text: 'text-green-400', border: 'border-green-500/20' },
    'investment': { bg: 'bg-primary-container/20', text: 'text-primary', border: 'border-primary/20' },
  };
  return map[(category || '').toLowerCase()] || {
    bg: 'bg-surface-variant',
    text: 'text-on-surface-variant',
    border: 'border-outline-variant',
  };
}

/**
 * Debounce function
 */
export function debounce(fn, delay = 300) {
  let timer;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => fn(...args), delay);
  };
}

/**
 * Simple ID generator
 */
export function uid() {
  return Date.now().toString(36) + Math.random().toString(36).substr(2);
}
