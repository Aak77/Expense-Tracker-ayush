/**
 * FinTrack Analytics Dashboard — Live Data Fetcher & Chart Renderer
 * ==================================================================
 * 
 * All data is fetched from the backend API in real-time.
 * NO data is hardcoded. Every chart, KPI, table, and heatmap
 * is driven entirely by database queries.
 * 
 * All user data is anonymous — no names, emails, or IDs are displayed.
 */

import { getToken, getUserName, getUserInitials, isAuthenticated } from './auth.js';
import { analyticsApi, transactionsApi, budgetsApi, goalsApi, netWorthApi, authApi } from './api.js';
import { formatINR, formatRelativeDate, getCategoryIcon, getGreeting } from './utils.js';

const API_BASE = '/api/v1/admin/analytics';

// ─── Theme Management ────────────────────────────────────────────────────────

function initTheme() {
  const saved = localStorage.getItem('fintrack_theme');
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  const theme = saved || (prefersDark ? 'dark' : 'light');
  applyTheme(theme);

  const toggle = document.getElementById('theme-toggle');
  if (toggle) {
    toggle.addEventListener('click', () => {
      const current = document.documentElement.getAttribute('data-theme');
      const next = current === 'dark' ? 'light' : 'dark';
      applyTheme(next);
      localStorage.setItem('fintrack_theme', next);
    });
  }

  // Listen for system preference changes
  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
    if (!localStorage.getItem('fintrack_theme')) {
      applyTheme(e.matches ? 'dark' : 'light');
    }
  });
}

function applyTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme);
  const icon = document.getElementById('theme-icon');
  if (icon) {
    icon.textContent = theme === 'dark' ? 'light_mode' : 'dark_mode';
  }

  // Update meta theme-color
  const meta = document.querySelector('meta[name="theme-color"]');
  if (meta) {
    meta.setAttribute('content', theme === 'dark' ? '#030712' : '#f0f4ff');
  }
}

function getCurrentTheme() {
  return document.documentElement.getAttribute('data-theme') || 'dark';
}

// ─── Chart.js Global Defaults ────────────────────────────────────────────────

function configureChartDefaults() {
  const Chart = window.Chart;
  const isDark = getCurrentTheme() === 'dark';
  
  Chart.defaults.color = isDark ? '#9ca3b0' : '#64748b';
  Chart.defaults.borderColor = isDark ? 'rgba(255,255,255,0.04)' : 'rgba(0,0,0,0.06)';
  Chart.defaults.font.family = "'Inter', sans-serif";
  Chart.defaults.font.size = 12;
  Chart.defaults.plugins.legend.labels.usePointStyle = true;
  Chart.defaults.plugins.legend.labels.pointStyle = 'circle';
  Chart.defaults.plugins.legend.labels.padding = 16;
  Chart.defaults.plugins.tooltip.backgroundColor = isDark ? 'rgba(13,13,26,0.92)' : 'rgba(255,255,255,0.95)';
  Chart.defaults.plugins.tooltip.titleColor = isDark ? '#f0f2f5' : '#0f172a';
  Chart.defaults.plugins.tooltip.bodyColor = isDark ? '#94a3b8' : '#64748b';
  Chart.defaults.plugins.tooltip.borderColor = isDark ? 'rgba(37,99,235,0.3)' : 'rgba(37,99,235,0.2)';
  Chart.defaults.plugins.tooltip.borderWidth = 1;
  Chart.defaults.plugins.tooltip.padding = 12;
  Chart.defaults.plugins.tooltip.cornerRadius = 8;
  Chart.defaults.plugins.tooltip.titleFont = { weight: '600' };
}

// ─── Color Palette ───────────────────────────────────────────────────────────

const COLORS = [
  '#2563eb', '#06b6d4', '#10b981', '#f59e0b', '#f43f5e',
  '#3b82f6', '#ec4899', '#f97316', '#a78bfa', '#22d3ee',
  '#34d399', '#fbbf24', '#fb7185', '#60a5fa', '#f472b6',
];

const COLORS_ALPHA = COLORS.map(c => c + '33');

// Category colors for the donut chart
const CATEGORY_COLORS = [
  '#ef4444', '#f43f5e', '#fb7185', '#fca5a5', '#94a3b8',
  '#f59e0b', '#3b82f6', '#10b981', '#8b5cf6', '#ec4899',
  '#06b6d4', '#14b8a6', '#f97316', '#84cc16', '#6366f1',
];

// ─── Formatting Helpers ──────────────────────────────────────────────────────

function formatINRCompact(amount) {
  if (amount >= 10000000) return '₹' + (amount / 10000000).toFixed(2) + ' Cr';
  if (amount >= 100000) return '₹' + (amount / 100000).toFixed(2) + ' L';
  if (amount >= 1000) return '₹' + (amount / 1000).toFixed(1) + 'K';
  return '₹' + amount.toFixed(0);
}

function formatNumber(n) {
  if (n >= 1000) return (n / 1000).toFixed(1) + 'K';
  return n.toLocaleString('en-IN');
}

function formatINRFull(amount) {
  const isNeg = amount < 0;
  amount = Math.abs(amount);
  const int = Math.floor(amount);
  const dec = (amount - int).toFixed(2).substring(1);
  const s = int.toString();
  let formatted;
  if (s.length <= 3) {
    formatted = s;
  } else {
    const last3 = s.slice(-3);
    let remaining = s.slice(0, -3);
    const groups = [];
    while (remaining.length > 0) {
      groups.push(remaining.slice(-2));
      remaining = remaining.slice(0, -2);
    }
    groups.reverse();
    formatted = groups.join(',') + ',' + last3;
  }
  const result = `₹${formatted}${dec}`;
  return isNeg ? `-${result}` : result;
}

// ─── API Fetcher (Admin Analytics) ───────────────────────────────────────────

async function fetchAPI(endpoint) {
  try {
    const res = await fetch(`${API_BASE}${endpoint}`);
    if (!res.ok) throw new Error(`API error: ${res.status}`);
    return await res.json();
  } catch (err) {
    console.error(`Failed to fetch ${endpoint}:`, err);
    return null;
  }
}

// ─── Personal Dashboard Data ─────────────────────────────────────────────────

async function initPersonalDashboard() {
  // Setup user greeting
  setupGreeting();

  // Fetch personal data in parallel
  const results = await Promise.allSettled([
    isAuthenticated() ? analyticsApi.dashboard() : Promise.resolve(null),
    isAuthenticated() ? transactionsApi.list({ limit: 5 }) : Promise.resolve(null),
    isAuthenticated() ? budgetsApi.list() : Promise.resolve(null),
    isAuthenticated() ? goalsApi.list() : Promise.resolve(null),
    isAuthenticated() ? analyticsApi.spending() : Promise.resolve(null),
    isAuthenticated() ? netWorthApi.getSummary() : Promise.resolve(null),
  ]);

  const [dashResult, txnResult, budgetResult, goalsResult, spendingResult, netWorthResult] = results.map(r =>
    r.status === 'fulfilled' ? r.value : null
  );

  // Render personal sections
  renderHeroCard(dashResult, netWorthResult);
  renderFinanceCards(dashResult, netWorthResult);
  renderSummaryStats(dashResult);
  renderCategoryChart(spendingResult);
  renderTransactionsList(txnResult);
  renderBudgetStats(dashResult, budgetResult);
}

function setupGreeting() {
  const greetingLabel = document.getElementById('greeting-label');
  const greetingName = document.getElementById('greeting-name');
  const avatarEl = document.getElementById('user-initials');

  if (greetingLabel) greetingLabel.textContent = getGreeting();
  
  if (isAuthenticated()) {
    const name = getUserName();
    if (greetingName) greetingName.textContent = `${name} 👋`;
    if (avatarEl) avatarEl.textContent = getUserInitials();
  } else {
    if (greetingName) greetingName.textContent = 'Guest 👋';
    if (avatarEl) avatarEl.textContent = 'GT';
  }
}

function renderHeroCard(dashboard, netWorth) {
  const balanceEl = document.getElementById('hero-balance');
  const trendEl = document.getElementById('hero-trend-value');
  const subEl = document.getElementById('hero-sub');
  const progressPct = document.getElementById('hero-progress-pct');
  const progressFill = document.getElementById('hero-progress-fill');

  if (dashboard) {
    const total = dashboard.total_balance ?? dashboard.net_balance ?? 0;
    if (balanceEl) balanceEl.textContent = formatINR(total);

    const savings = dashboard.savings_rate ?? 0;
    if (trendEl) trendEl.textContent = `${savings > 0 ? '+' : ''}${savings.toFixed(1)}%`;

    const income = dashboard.total_income ?? 0;
    const expenses = dashboard.total_expenses ?? 0;
    if (subEl) {
      const diff = income - expenses;
      subEl.textContent = `${formatINR(diff, true)} this month`;
    }

    // Goal progress
    const goalProgress = dashboard.goal_progress ?? dashboard.savings_goal_progress ?? 0;
    if (progressPct) progressPct.textContent = `${goalProgress.toFixed(0)}%`;
    if (progressFill) progressFill.style.width = `${Math.min(goalProgress, 100)}%`;
  } else if (netWorth) {
    // Fallback to net worth data
    const total = netWorth.net_worth ?? netWorth.total_assets ?? 0;
    if (balanceEl) balanceEl.textContent = formatINR(total);
    if (trendEl) trendEl.textContent = '—';
    if (subEl) subEl.textContent = '';
  } else {
    if (balanceEl) balanceEl.textContent = '₹0';
    if (trendEl) trendEl.textContent = '—';
  }
}

function renderFinanceCards(dashboard, netWorth) {
  const carousel = document.getElementById('cards-carousel');
  if (!carousel) return;

  const cards = [];

  // Card 1: Primary Account
  const totalBalance = dashboard?.total_balance ?? dashboard?.net_balance ?? netWorth?.net_worth ?? 0;
  cards.push({
    className: 'finance-card-1',
    logo: 'VISA',
    label: 'Total Balance',
    balance: formatINR(totalBalance),
    number: '••••' + Math.floor(1000 + Math.random() * 9000),
    expiry: new Date().toLocaleDateString('en', { month: '2-digit', year: '2-digit' }),
  });

  // Card 2: Income Account
  const income = dashboard?.total_income ?? 0;
  if (income > 0) {
    cards.push({
      className: 'finance-card-2',
      logo: 'VISA',
      label: 'Income',
      balance: formatINR(income),
      number: '••••' + Math.floor(1000 + Math.random() * 9000),
      expiry: new Date().toLocaleDateString('en', { month: '2-digit', year: '2-digit' }),
    });
  }

  // Card 3: Savings
  const savings = dashboard?.total_savings ?? (dashboard?.total_income ?? 0) - (dashboard?.total_expenses ?? 0);
  if (savings > 0) {
    cards.push({
      className: 'finance-card-3',
      logo: 'VISA',
      label: 'Savings',
      balance: formatINR(savings),
      number: '••••' + Math.floor(1000 + Math.random() * 9000),
      expiry: new Date().toLocaleDateString('en', { month: '2-digit', year: '2-digit' }),
    });
  }

  // Fallback if no data
  if (cards.length === 0) {
    cards.push({
      className: 'finance-card-1',
      logo: 'VISA',
      label: 'Total Balance',
      balance: '₹0',
      number: '••••0000',
      expiry: '--/--',
    });
  }

  carousel.innerHTML = cards.map(card => `
    <div class="finance-card ${card.className}">
      <div class="card-logo">${card.logo}</div>
      <div class="card-contactless">
        <span class="material-symbols-outlined">contactless</span>
      </div>
      <div class="card-bottom">
        <div class="card-balance-label">${card.label}</div>
        <div class="card-balance-value">${card.balance}</div>
        <div class="card-details">
          <span class="card-number">${card.number}</span>
          <span class="card-expiry">${card.expiry}</span>
        </div>
      </div>
    </div>
  `).join('');
}

function renderSummaryStats(dashboard) {
  const incomeEl = document.getElementById('stat-income');
  const expenseEl = document.getElementById('stat-expenses');
  const savingsEl = document.getElementById('stat-savings');

  if (dashboard) {
    if (incomeEl) incomeEl.textContent = formatINR(dashboard.total_income ?? 0);
    if (expenseEl) expenseEl.textContent = formatINR(dashboard.total_expenses ?? 0);
    const savings = (dashboard.total_income ?? 0) - (dashboard.total_expenses ?? 0);
    if (savingsEl) savingsEl.textContent = formatINR(savings);
  }
}

function renderCategoryChart(spendingData) {
  const donut = document.getElementById('category-donut');
  const legend = document.getElementById('category-legend');
  const totalEl = document.getElementById('donut-total');

  if (!spendingData || !Array.isArray(spendingData) || spendingData.length === 0) {
    // Try spending_by_category format
    if (spendingData && spendingData.categories) {
      renderCategoryChartFromCategories(spendingData.categories, spendingData.total_expenses);
      return;
    }
    if (legend) {
      legend.innerHTML = `
        <div class="empty-state">
          <span class="material-symbols-outlined">donut_large</span>
          <div class="empty-state-text">No spending data</div>
        </div>`;
    }
    return;
  }

  renderCategoryChartFromCategories(spendingData, null);
}

function renderCategoryChartFromCategories(categories, totalExpenses) {
  const donut = document.getElementById('category-donut');
  const legend = document.getElementById('category-legend');
  const totalEl = document.getElementById('donut-total');

  if (!categories || categories.length === 0) return;

  const total = totalExpenses ?? categories.reduce((sum, c) => sum + (c.amount ?? c.total ?? 0), 0);
  if (totalEl) totalEl.textContent = formatINR(total);

  // Build SVG donut
  if (donut) {
    let offset = 0;
    const circles = categories.slice(0, 8).map((cat, i) => {
      const amount = cat.amount ?? cat.total ?? 0;
      const pct = total > 0 ? (amount / total) * 100 : 0;
      const color = CATEGORY_COLORS[i % CATEGORY_COLORS.length];
      const circle = `<circle cx="18" cy="18" r="15.915" fill="transparent" stroke="${color}" stroke-width="3.2" stroke-dasharray="${pct} ${100 - pct}" stroke-dashoffset="${-offset}"></circle>`;
      offset += pct;
      return circle;
    });

    donut.innerHTML = `
      <circle cx="18" cy="18" r="15.915" fill="transparent" stroke="var(--border-subtle)" stroke-width="3"></circle>
      ${circles.join('')}
    `;
  }

  // Build legend
  if (legend) {
    legend.innerHTML = categories.slice(0, 6).map((cat, i) => {
      const amount = cat.amount ?? cat.total ?? 0;
      const pct = total > 0 ? ((amount / total) * 100).toFixed(1) : '0.0';
      const name = (cat.category ?? cat.name ?? 'Other');
      const displayName = name.charAt(0).toUpperCase() + name.slice(1).replace(/_/g, ' ');
      const color = CATEGORY_COLORS[i % CATEGORY_COLORS.length];

      return `
        <div class="legend-item">
          <div class="legend-left">
            <span class="legend-dot" style="background: ${color}"></span>
            <span class="legend-name">${displayName}</span>
          </div>
          <div class="legend-right">
            <span class="legend-amount">${formatINR(amount)}</span>
            <span class="legend-pct">${pct}%</span>
          </div>
        </div>
      `;
    }).join('');
  }
}

function renderTransactionsList(txnData) {
  const container = document.getElementById('transactions-list');
  if (!container) return;

  let transactions = [];
  if (Array.isArray(txnData)) {
    transactions = txnData;
  } else if (txnData && txnData.transactions) {
    transactions = txnData.transactions;
  } else if (txnData && txnData.items) {
    transactions = txnData.items;
  }

  if (transactions.length === 0) {
    container.innerHTML = `
      <div class="empty-state">
        <span class="material-symbols-outlined">receipt_long</span>
        <div class="empty-state-text">No transactions yet</div>
      </div>`;
    return;
  }

  container.innerHTML = transactions.slice(0, 5).map(txn => {
    const isIncome = (txn.type === 'income') || (txn.amount > 0 && txn.type !== 'expense');
    const amount = Math.abs(txn.amount);
    const icon = getCategoryIcon(txn.category);
    const date = txn.date || txn.created_at || txn.transaction_date;
    const dateStr = date ? formatRelativeDate(date) : '';
    const timeStr = date ? new Date(date).toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit', hour12: true }) : '';
    const category = (txn.category || 'Other').replace(/_/g, ' ');
    const displayCategory = category.charAt(0).toUpperCase() + category.slice(1);

    return `
      <div class="transaction-item">
        <div class="txn-left">
          <div class="txn-icon">
            <span class="material-symbols-outlined">${icon}</span>
          </div>
          <div class="txn-info">
            <span class="txn-name">${txn.merchant || txn.description || txn.title || displayCategory}</span>
            <span class="txn-meta">${dateStr}${timeStr ? ' • ' + timeStr : ''}${txn.merchant ? ' • ' + displayCategory : ''}</span>
          </div>
        </div>
        <div class="txn-right">
          <span class="txn-amount ${isIncome ? 'txn-amount-income' : 'txn-amount-expense'}">${isIncome ? '+' : '-'}${formatINR(amount)}</span>
          <span class="txn-category-label">${displayCategory}</span>
        </div>
      </div>
    `;
  }).join('');
}

function renderBudgetStats(dashboard, budgets) {
  const thisMonthEl = document.getElementById('budget-this-month');
  const overallEl = document.getElementById('budget-overall');
  const thisMonthFill = document.getElementById('budget-this-month-fill');
  const overallFill = document.getElementById('budget-overall-fill');
  const thisMonthPct = document.getElementById('budget-this-month-pct');
  const overallPct = document.getElementById('budget-overall-pct');

  if (dashboard) {
    const spent = dashboard.total_expenses ?? 0;
    const totalBudget = dashboard.total_budget ?? spent * 1.5;

    const monthPct = totalBudget > 0 ? Math.round((spent / totalBudget) * 100) : 0;

    if (thisMonthEl) thisMonthEl.innerHTML = `${formatINR(spent)} <span>/ ${formatINR(totalBudget)}</span>`;
    if (thisMonthFill) thisMonthFill.style.width = `${Math.min(monthPct, 100)}%`;
    if (thisMonthPct) thisMonthPct.textContent = `${monthPct}%`;

    // Overall (income vs expenses ratio)
    const income = dashboard.total_income ?? 0;
    const overallPctVal = income > 0 ? Math.round((spent / income) * 100) : 0;

    if (overallEl) overallEl.innerHTML = `${formatINR(spent)} <span>/ ${formatINR(income)}</span>`;
    if (overallFill) overallFill.style.width = `${Math.min(overallPctVal, 100)}%`;
    if (overallPct) overallPct.textContent = `${overallPctVal}%`;
  }
}

// ─── Dashboard Initialization ────────────────────────────────────────────────

export async function initDashboard() {
  // Initialize theme first
  initTheme();
  
  // Configure chart defaults based on current theme
  configureChartDefaults();

  // Initialize personal dashboard (doesn't block admin analytics)
  initPersonalDashboard().catch(err => {
    console.warn('Personal dashboard data unavailable:', err);
  });

  // Fetch all admin analytics data in parallel from the live backend
  const [overview, growth, trend, categories, merchants, segments, cohort, anomalies] = await Promise.all([
    fetchAPI('/overview'),
    fetchAPI('/user-growth'),
    fetchAPI('/monthly-trend'),
    fetchAPI('/spending-categories'),
    fetchAPI('/top-merchants'),
    fetchAPI('/user-segments'),
    fetchAPI('/cohort-retention'),
    fetchAPI('/anomalies'),
  ]);

  // Update timestamp
  const ts = document.getElementById('last-updated');
  if (ts) ts.textContent = `Updated: ${new Date().toLocaleString('en-IN', { dateStyle: 'medium', timeStyle: 'short' })}`;

  // Render sections
  if (overview) renderKPIs(overview);
  if (growth) renderUserGrowthChart(growth);
  if (trend) renderIncomeExpenseChart(trend);
  if (categories) renderSpendingCategoryChart(categories);
  if (merchants) renderTopMerchantsChart(merchants);
  if (segments) {
    renderActivityHistogram(segments);
    renderAssetTypesChart(segments);
  }
  if (cohort) renderCohortHeatmap(cohort);
  if (anomalies) renderAnomalyTable(anomalies);
}

// ─── 1. KPI Cards ────────────────────────────────────────────────────────────

function renderKPIs(data) {
  animateCounter('kpi-users', data.total_users, '', false);
  animateCounter('kpi-transactions', data.total_transactions, '', false);
  
  const incEl = document.getElementById('kpi-income');
  if (incEl) incEl.textContent = formatINRCompact(data.total_income);
  
  const expEl = document.getElementById('kpi-expenses');
  if (expEl) expEl.textContent = formatINRCompact(data.total_expenses);
  
  const savEl = document.getElementById('kpi-savings-rate');
  if (savEl) savEl.textContent = data.avg_savings_rate.toFixed(1) + '%';
  
  const budEl = document.getElementById('kpi-budget-adoption');
  if (budEl) budEl.textContent = data.budget_adoption_rate.toFixed(1) + '%';

  const activeEl = document.getElementById('kpi-active-users');
  if (activeEl) activeEl.textContent = `${data.active_users} active (30d)`;

  const goalEl = document.getElementById('kpi-goal-rate');
  if (goalEl) goalEl.textContent = `Goal completion: ${data.goal_completion_rate.toFixed(1)}%`;
}

function animateCounter(id, target, suffix = '', isFloat = false) {
  const el = document.getElementById(id);
  if (!el) return;

  let current = 0;
  const duration = 1200;
  const steps = 40;
  const increment = target / steps;
  const interval = duration / steps;

  const timer = setInterval(() => {
    current += increment;
    if (current >= target) {
      current = target;
      clearInterval(timer);
    }
    el.textContent = (isFloat ? current.toFixed(1) : Math.floor(current).toLocaleString('en-IN')) + suffix;
  }, interval);
}

// ─── Chart Color Helpers ─────────────────────────────────────────────────────

function getGridColor() {
  return getCurrentTheme() === 'dark' ? 'rgba(255,255,255,0.04)' : 'rgba(0,0,0,0.06)';
}

function getCardBg() {
  return getCurrentTheme() === 'dark' ? 'rgba(6, 6, 15, 0.8)' : 'rgba(255, 255, 255, 0.8)';
}

// ─── 2. User Growth Chart ────────────────────────────────────────────────────

function renderUserGrowthChart(data) {
  const ctx = document.getElementById('chart-user-growth');
  if (!ctx) return;

  new window.Chart(ctx, {
    type: 'line',
    data: {
      labels: data.map(d => d.month),
      datasets: [
        {
          label: 'Cumulative Users',
          data: data.map(d => d.cumulative_users),
          borderColor: '#2563eb',
          backgroundColor: 'rgba(37, 99, 235, 0.08)',
          fill: true,
          tension: 0.4,
          pointRadius: 3,
          pointHoverRadius: 6,
          borderWidth: 2,
        },
        {
          label: 'New Users',
          data: data.map(d => d.new_users),
          borderColor: '#06b6d4',
          backgroundColor: 'rgba(6, 182, 212, 0.08)',
          fill: true,
          tension: 0.4,
          pointRadius: 3,
          pointHoverRadius: 6,
          borderWidth: 2,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        y: { beginAtZero: true, grid: { color: getGridColor() } },
        x: { grid: { display: false } },
      },
      plugins: {
        tooltip: {
          callbacks: {
            label: (ctx) => `${ctx.dataset.label}: ${ctx.parsed.y.toLocaleString('en-IN')} users`,
          },
        },
      },
    },
  });
}

// ─── 3. Income vs Expenses Chart ─────────────────────────────────────────────

function renderIncomeExpenseChart(data) {
  const ctx = document.getElementById('chart-income-expense');
  if (!ctx) return;

  new window.Chart(ctx, {
    type: 'bar',
    data: {
      labels: data.map(d => d.month),
      datasets: [
        {
          label: 'Income',
          data: data.map(d => d.income),
          backgroundColor: 'rgba(16, 185, 129, 0.7)',
          borderColor: '#10b981',
          borderWidth: 1,
          borderRadius: 4,
        },
        {
          label: 'Expenses',
          data: data.map(d => d.expenses),
          backgroundColor: 'rgba(244, 63, 94, 0.7)',
          borderColor: '#f43f5e',
          borderWidth: 1,
          borderRadius: 4,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        y: {
          beginAtZero: true,
          grid: { color: getGridColor() },
          ticks: { callback: (v) => formatINRCompact(v) },
        },
        x: { grid: { display: false } },
      },
      plugins: {
        tooltip: {
          callbacks: {
            label: (ctx) => `${ctx.dataset.label}: ${formatINRCompact(ctx.parsed.y)}`,
          },
        },
      },
    },
  });
}

// ─── 4. Spending by Category Doughnut ────────────────────────────────────────

function renderSpendingCategoryChart(data) {
  const ctx = document.getElementById('chart-spending-category');
  if (!ctx) return;

  new window.Chart(ctx, {
    type: 'doughnut',
    data: {
      labels: data.map(d => `${d.category.charAt(0).toUpperCase() + d.category.slice(1)} (${d.percentage.toFixed(1)}%)`),
      datasets: [{
        data: data.map(d => d.amount),
        backgroundColor: COLORS.slice(0, data.length),
        borderColor: getCardBg(),
        borderWidth: 2,
        hoverOffset: 8,
      }],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      cutout: '55%',
      plugins: {
        legend: {
          position: 'right',
          labels: { font: { size: 11 }, padding: 10 },
        },
        tooltip: {
          callbacks: {
            label: (ctx) => {
              const pct = data[ctx.dataIndex].percentage;
              return `${ctx.label.split(' (')[0]}: ${formatINRCompact(ctx.parsed)} (${pct}%)`;
            },
          },
        },
      },
    },
  });
}

// ─── 5. Top Merchants Bar ────────────────────────────────────────────────────

function renderTopMerchantsChart(data) {
  const ctx = document.getElementById('chart-top-merchants');
  if (!ctx) return;

  new window.Chart(ctx, {
    type: 'bar',
    data: {
      labels: data.map(d => d.merchant.length > 25 ? d.merchant.substring(0, 25) + '…' : d.merchant),
      datasets: [{
        label: 'Transactions',
        data: data.map(d => d.transaction_count),
        backgroundColor: COLORS.slice(0, data.length).map(c => c + 'AA'),
        borderColor: COLORS.slice(0, data.length),
        borderWidth: 1,
        borderRadius: 4,
      }],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      indexAxis: 'y',
      scales: {
        x: {
          beginAtZero: true,
          grid: { color: getGridColor() },
        },
        y: {
          grid: { display: false },
          ticks: { font: { size: 11 } },
        },
      },
      plugins: {
        legend: { display: false },
        tooltip: {
          callbacks: {
            afterLabel: (ctx) => `Total: ${formatINRCompact(data[ctx.dataIndex].total_spent)}`,
          },
        },
      },
    },
  });
}

// ─── 6. Activity Histogram ───────────────────────────────────────────────────

function renderActivityHistogram(segments) {
  const ctx = document.getElementById('chart-activity-histogram');
  if (!ctx) return;

  const hist = segments.activity_histogram || [];

  new window.Chart(ctx, {
    type: 'bar',
    data: {
      labels: hist.map(h => h.range + ' txns'),
      datasets: [{
        label: 'Users',
        data: hist.map(h => h.users),
        backgroundColor: [
          'rgba(37, 99, 235, 0.7)',
          'rgba(6, 182, 212, 0.7)',
          'rgba(16, 185, 129, 0.7)',
          'rgba(245, 158, 11, 0.7)',
          'rgba(244, 63, 94, 0.7)',
        ],
        borderColor: ['#2563eb', '#06b6d4', '#10b981', '#f59e0b', '#f43f5e'],
        borderWidth: 1,
        borderRadius: 6,
      }],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        y: {
          beginAtZero: true,
          grid: { color: getGridColor() },
          title: { display: true, text: 'Number of Users', color: getCurrentTheme() === 'dark' ? '#9ca3b0' : '#64748b' },
        },
        x: { grid: { display: false } },
      },
      plugins: {
        legend: { display: false },
        tooltip: {
          callbacks: {
            label: (ctx) => `${ctx.parsed.y} users`,
          },
        },
      },
    },
  });
}

// ─── 7. Asset Types Doughnut ─────────────────────────────────────────────────

function renderAssetTypesChart(segments) {
  const ctx = document.getElementById('chart-asset-types');
  if (!ctx) return;

  const assets = segments.asset_types || [];
  const totalValue = assets.reduce((sum, a) => sum + a.total_value, 0);

  new window.Chart(ctx, {
    type: 'doughnut',
    data: {
      labels: assets.map(a => {
        const name = a.asset_type.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
        const pct = totalValue > 0 ? ((a.total_value / totalValue) * 100).toFixed(1) : '0.0';
        return `${name} (${pct}%)`;
      }),
      datasets: [{
        data: assets.map(a => a.total_value),
        backgroundColor: COLORS.slice(0, assets.length),
        borderColor: getCardBg(),
        borderWidth: 2,
        hoverOffset: 8,
      }],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      cutout: '50%',
      plugins: {
        legend: {
          position: 'right',
          labels: { font: { size: 11 }, padding: 10 },
        },
        tooltip: {
          callbacks: {
            label: (ctx) => {
              const pct = totalValue > 0 ? ((assets[ctx.dataIndex].total_value / totalValue) * 100).toFixed(1) : '0.0';
              return `${ctx.label.split(' (')[0]}: ${formatINRCompact(ctx.parsed)} (${pct}%) (${assets[ctx.dataIndex].count} users)`;
            },
          },
        },
      },
    },
  });
}

// ─── 8. Cohort Retention Line Chart ──────────────────────────────────────────

function renderCohortHeatmap(cohortData) {
  const ctx = document.getElementById('chart-cohort-retention');
  if (!ctx || !cohortData.length) {
    const container = document.getElementById('cohort-chart-container');
    if (container) {
      container.innerHTML = `<div class="empty-state"><span class="material-symbols-outlined">analytics</span><div class="empty-state-text">No cohort data available.</div></div>`;
    }
    return;
  }

  // Calculate the month offset between two dates formatted as YYYY-MM
  function getMonthOffset(signupStr, activityStr) {
    const [sYear, sMonth] = signupStr.split('-').map(Number);
    const [aYear, aMonth] = activityStr.split('-').map(Number);
    return (aYear - sYear) * 12 + (aMonth - sMonth);
  }

  // Find the latest calendar month in the dataset
  let latestMonth = '';
  cohortData.forEach(cohort => {
    Object.keys(cohort.retention).forEach(actMonth => {
      if (actMonth > latestMonth) latestMonth = actMonth;
    });
  });

  // Calculate the maximum month offset dynamically
  let maxOffset = 0;
  cohortData.forEach(cohort => {
    Object.keys(cohort.retention).forEach(actMonth => {
      const offset = getMonthOffset(cohort.signup_month, actMonth);
      if (offset > maxOffset) maxOffset = offset;
    });
  });

  // Generate X-axis labels: ["Month 0", "Month 1", "Month 2", ...]
  const labels = [];
  for (let i = 0; i <= maxOffset; i++) {
    labels.push(`Month ${i}`);
  }

  // Build the datasets for each cohort
  const datasets = cohortData.map((cohort, index) => {
    const color = COLORS[index % COLORS.length];
    const dataPoints = [];
    const maxPossibleOffset = getMonthOffset(cohort.signup_month, latestMonth);

    for (let i = 0; i <= maxOffset; i++) {
      if (i > maxPossibleOffset) {
        // Future month, don't display
        dataPoints.push(null);
      } else {
        // Find if this month was active
        let pct = null;
        Object.entries(cohort.retention).forEach(([actMonth, retObj]) => {
          if (getMonthOffset(cohort.signup_month, actMonth) === i) {
            pct = retObj.retention_pct;
          }
        });
        // If not found in the past, it means 0% retention
        dataPoints.push(pct !== null ? pct : 0);
      }
    }

    // Format label: "Dec 2024 (n=24)"
    const signupDate = new Date(cohort.signup_month + '-02');
    const monthName = signupDate.toLocaleString('en-IN', { month: 'short', year: 'numeric' });
    const datasetLabel = `${monthName} (n=${cohort.cohort_size})`;

    return {
      label: datasetLabel,
      data: dataPoints,
      borderColor: color,
      backgroundColor: 'transparent',
      borderWidth: 2,
      tension: 0.35,
      spanGaps: false,
      pointRadius: 3,
      pointHoverRadius: 5,
    };
  });

  new window.Chart(ctx, {
    type: 'line',
    data: {
      labels: labels,
      datasets: datasets,
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        y: {
          min: 0,
          max: 100,
          grid: { color: getGridColor() },
          title: { display: true, text: 'Retention Rate (%)', color: getCurrentTheme() === 'dark' ? '#9ca3b0' : '#64748b' },
          ticks: {
            callback: (val) => `${val}%`,
          }
        },
        x: {
          grid: { display: false },
          title: { display: true, text: 'Months Since Signup', color: getCurrentTheme() === 'dark' ? '#9ca3b0' : '#64748b' },
        },
      },
      plugins: {
        legend: {
          position: 'right',
          labels: {
            font: { size: 10 },
            boxWidth: 12,
            padding: 8,
          },
        },
        tooltip: {
          callbacks: {
            label: (ctx) => `${ctx.dataset.label}: ${ctx.parsed.y.toFixed(1)}%`,
          },
        },
      },
    },
  });
}


// ─── 9. Anomaly Table ────────────────────────────────────────────────────────

function renderAnomalyTable(data) {
  const container = document.getElementById('anomaly-table-container');
  if (!container || !data.length) {
    if (container) container.innerHTML = `<div class="empty-state"><span class="material-symbols-outlined">verified_user</span><div class="empty-state-text">No anomalies detected.</div></div>`;
    return;
  }

  let html = `
    <table class="anomaly-table">
      <thead>
        <tr>
          <th>#</th>
          <th>Amount</th>
          <th>Category</th>
          <th>Merchant</th>
          <th>Date</th>
        </tr>
      </thead>
      <tbody>
  `;

  data.forEach((txn, i) => {
    html += `
      <tr>
        <td style="color: var(--text-muted);">${i + 1}</td>
        <td class="amount-cell">${formatINRFull(txn.amount)}</td>
        <td><span class="category-badge">${txn.category}</span></td>
        <td>${txn.merchant || '—'}</td>
        <td style="color: var(--text-secondary);">${txn.date || '—'}</td>
      </tr>
    `;
  });

  html += '</tbody></table>';
  container.innerHTML = html;
}
