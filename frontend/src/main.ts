import './style.css';
import { initDashboard } from './dashboard.js';

document.querySelector<HTMLDivElement>('#app')!.innerHTML = `
<!-- Ambient Background Effects -->
<div class="ambient-glow"></div>
<div class="ambient-orb ambient-orb-1"></div>
<div class="ambient-orb ambient-orb-2"></div>

<div class="app-shell">

  <!-- Top Header Bar -->
  <header class="top-header">
    <div class="header-left">
      <div class="user-avatar" id="user-avatar">
        <span id="user-initials">FT</span>
      </div>
      <div class="greeting-block">
        <span class="greeting-label" id="greeting-label">Hello</span>
        <span class="greeting-name" id="greeting-name">FinTrack 👋</span>
      </div>
    </div>
    <div class="header-right">
      <button class="icon-btn" id="theme-toggle" aria-label="Toggle theme">
        <span class="material-symbols-outlined theme-toggle-icon" id="theme-icon">dark_mode</span>
      </button>
      <button class="icon-btn" aria-label="Search">
        <span class="material-symbols-outlined">search</span>
      </button>
      <button class="icon-btn" aria-label="Notifications">
        <span class="material-symbols-outlined">notifications</span>
      </button>
    </div>
  </header>

  <!-- Main Content -->
  <main class="main-content">

    <!-- Hero Balance Card -->
    <section class="hero-card animate-in animate-in-1">
      <div class="hero-label">Total Balance</div>
      <div class="hero-balance-row">
        <div class="hero-balance" id="hero-balance">—</div>
        <div class="hero-trend-badge" id="hero-trend">
          <span class="material-symbols-outlined">trending_up</span>
          <span id="hero-trend-value">—</span>
        </div>
      </div>
      <div class="hero-sub" id="hero-sub"></div>
      <div class="hero-progress">
        <div class="hero-progress-header">
          <span class="hero-progress-label">Goal Progress</span>
          <span class="hero-progress-value" id="hero-progress-pct">0%</span>
        </div>
        <div class="hero-progress-track">
          <div class="hero-progress-fill" id="hero-progress-fill" style="width: 0%"></div>
        </div>
      </div>
    </section>

    <!-- Cards Carousel -->
    <section class="cards-section animate-in animate-in-2">
      <div class="cards-section-header">
        <span class="cards-section-title">Cards</span>
        <button class="cards-section-action">Add +</button>
      </div>
      <div class="cards-carousel" id="cards-carousel">
        <!-- Cards populated dynamically -->
      </div>
    </section>

    <!-- Quick Actions -->
    <section class="quick-actions animate-in animate-in-3" id="quick-actions">
      <div class="quick-action-item">
        <div class="quick-action-icon"><span class="material-symbols-outlined">arrow_outward</span></div>
        <span class="quick-action-label">Send</span>
      </div>
      <div class="quick-action-item">
        <div class="quick-action-icon"><span class="material-symbols-outlined">add</span></div>
        <span class="quick-action-label">Add Funds</span>
      </div>
      <div class="quick-action-item">
        <div class="quick-action-icon"><span class="material-symbols-outlined">qr_code_scanner</span></div>
        <span class="quick-action-label">Scan & Pay</span>
      </div>
      <div class="quick-action-item">
        <div class="quick-action-icon"><span class="material-symbols-outlined">south</span></div>
        <span class="quick-action-label">Withdraw</span>
      </div>
      <div class="quick-action-item">
        <div class="quick-action-icon"><span class="material-symbols-outlined">account_balance_wallet</span></div>
        <span class="quick-action-label">Budgets</span>
      </div>
      <div class="quick-action-item">
        <div class="quick-action-icon"><span class="material-symbols-outlined">flag</span></div>
        <span class="quick-action-label">Goals</span>
      </div>
      <div class="quick-action-item">
        <div class="quick-action-icon"><span class="material-symbols-outlined">bar_chart</span></div>
        <span class="quick-action-label">Analytics</span>
      </div>
      <div class="quick-action-item">
        <div class="quick-action-icon"><span class="material-symbols-outlined">grid_view</span></div>
        <span class="quick-action-label">More</span>
      </div>
    </section>

    <!-- Summary Stats -->
    <section class="stats-grid animate-in animate-in-4">
      <div class="stat-card">
        <div class="stat-icon stat-icon-income">
          <span class="material-symbols-outlined">south_west</span>
        </div>
        <div>
          <div class="stat-label">Income</div>
          <div class="stat-value stat-value-income" id="stat-income">—</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon stat-icon-expense">
          <span class="material-symbols-outlined">north_east</span>
        </div>
        <div>
          <div class="stat-label">Expenses</div>
          <div class="stat-value stat-value-expense" id="stat-expenses">—</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon stat-icon-savings">
          <span class="material-symbols-outlined">savings</span>
        </div>
        <div>
          <div class="stat-label">Savings</div>
          <div class="stat-value stat-value-savings" id="stat-savings">—</div>
        </div>
      </div>
    </section>

    <!-- Category Spending -->
    <section class="section-card animate-in animate-in-5">
      <div class="section-header-row">
        <div>
          <div class="section-title">Category Spending</div>
          <div class="section-subtitle">Monthly breakdown</div>
        </div>
      </div>
      <div class="category-chart-container" id="category-chart-container">
        <div class="donut-wrapper">
          <svg viewBox="0 0 36 36" id="category-donut">
            <circle cx="18" cy="18" r="15.915" fill="transparent" stroke="var(--border-subtle)" stroke-width="3"></circle>
          </svg>
          <div class="donut-center">
            <span class="donut-center-label">Expenses</span>
            <span class="donut-center-value" id="donut-total">—</span>
          </div>
        </div>
        <div class="category-legend" id="category-legend">
          <div class="empty-state">
            <span class="material-symbols-outlined">donut_large</span>
            <div class="empty-state-text">Loading categories...</div>
          </div>
        </div>
      </div>
    </section>

    <!-- Recent Transactions -->
    <section class="section-card animate-in animate-in-6">
      <div class="section-header-row">
        <div class="section-title">Latest Transactions</div>
        <button class="section-action">
          View All
          <span class="material-symbols-outlined">arrow_forward</span>
        </button>
      </div>
      <div id="transactions-list">
        <div class="empty-state">
          <span class="material-symbols-outlined">receipt_long</span>
          <div class="empty-state-text">Loading transactions...</div>
        </div>
      </div>
    </section>

    <!-- Usage / Budget Stats (like Card Usage in design) -->
    <section class="section-card animate-in animate-in-7">
      <div class="section-header-row">
        <div class="section-title">Budget Overview</div>
      </div>
      <div class="usage-stats-grid" id="budget-stats">
        <div class="usage-stat-card">
          <div class="usage-stat-label">This Month Spent</div>
          <div class="usage-stat-value" id="budget-this-month">—</div>
          <div class="usage-progress">
            <div class="usage-progress-track">
              <div class="usage-progress-fill usage-progress-fill-blue" id="budget-this-month-fill" style="width: 0%"></div>
            </div>
            <span class="usage-pct-badge" id="budget-this-month-pct">0%</span>
          </div>
        </div>
        <div class="usage-stat-card">
          <div class="usage-stat-label">Overall Budget</div>
          <div class="usage-stat-value" id="budget-overall">—</div>
          <div class="usage-progress">
            <div class="usage-progress-track">
              <div class="usage-progress-fill usage-progress-fill-green" id="budget-overall-fill" style="width: 0%"></div>
            </div>
            <span class="usage-pct-badge" id="budget-overall-pct">0%</span>
          </div>
        </div>
      </div>
    </section>

    <!-- Analytics Dashboard Section -->
    <div class="section-divider-title animate-in animate-in-8">📊 Analytics Dashboard</div>

    <!-- Live Data Badges -->
    <div style="display: flex; gap: 8px; flex-wrap: wrap;">
      <span class="live-badge"><span class="pulse-dot"></span> Live Data</span>
      <span class="updated-badge" id="last-updated">Loading...</span>
    </div>

    <!-- KPI Cards -->
    <section class="kpi-grid" id="kpi-grid">
      <div class="kpi-card">
        <div class="kpi-label">Total Users</div>
        <div class="kpi-value accent" id="kpi-users">—</div>
        <div class="kpi-sub" id="kpi-active-users"></div>
      </div>
      <div class="kpi-card">
        <div class="kpi-label">Total Transactions</div>
        <div class="kpi-value accent" id="kpi-transactions">—</div>
      </div>
      <div class="kpi-card">
        <div class="kpi-label">Total Income</div>
        <div class="kpi-value income" id="kpi-income">—</div>
      </div>
      <div class="kpi-card">
        <div class="kpi-label">Total Expenses</div>
        <div class="kpi-value expense" id="kpi-expenses">—</div>
      </div>
      <div class="kpi-card">
        <div class="kpi-label">Avg Savings Rate</div>
        <div class="kpi-value accent" id="kpi-savings-rate">—</div>
      </div>
      <div class="kpi-card">
        <div class="kpi-label">Budget Adoption</div>
        <div class="kpi-value accent" id="kpi-budget-adoption">—</div>
        <div class="kpi-sub" id="kpi-goal-rate"></div>
      </div>
    </section>

    <!-- Charts Section -->
    <div class="charts-section">
      <!-- Growth & Revenue -->
      <div class="section-divider-title">Growth & Revenue Trends</div>

      <div class="chart-card" style="animation-delay: 0.1s;">
        <h3>User Growth</h3>
        <div class="chart-canvas-wrapper"><canvas id="chart-user-growth"></canvas></div>
      </div>
      <div class="chart-card" style="animation-delay: 0.2s;">
        <h3>Income vs Expenses</h3>
        <div class="chart-canvas-wrapper"><canvas id="chart-income-expense"></canvas></div>
      </div>

      <!-- Spending Analysis -->
      <div class="section-divider-title" style="grid-column: 1 / -1;">Spending Analysis</div>

      <div class="chart-card" style="animation-delay: 0.3s;">
        <h3>Spending by Category</h3>
        <div class="chart-canvas-wrapper"><canvas id="chart-spending-category"></canvas></div>
      </div>
      <div class="chart-card" style="animation-delay: 0.4s;">
        <h3>Top Merchants</h3>
        <div class="chart-canvas-wrapper"><canvas id="chart-top-merchants"></canvas></div>
      </div>

      <!-- User Segments -->
      <div class="section-divider-title" style="grid-column: 1 / -1;">User Segments</div>

      <div class="chart-card" style="animation-delay: 0.5s;">
        <h3>User Activity Distribution</h3>
        <div class="chart-canvas-wrapper"><canvas id="chart-activity-histogram"></canvas></div>
      </div>
      <div class="chart-card" style="animation-delay: 0.6s;">
        <h3>Asset Type Distribution</h3>
        <div class="chart-canvas-wrapper"><canvas id="chart-asset-types"></canvas></div>
      </div>

      <!-- Cohort Retention -->
      <div class="section-divider-title" style="grid-column: 1 / -1;">Cohort Retention Analysis</div>

      <div class="chart-card full-width" style="animation-delay: 0.7s;">
        <h3>Monthly Cohort Retention</h3>
        <div class="chart-canvas-wrapper" id="cohort-chart-container">
          <canvas id="chart-cohort-retention"></canvas>
        </div>
      </div>

      <!-- Anomaly Detection -->
      <div class="section-divider-title" style="grid-column: 1 / -1;">Anomaly Detection</div>

      <div class="chart-card full-width" style="animation-delay: 0.8s;">
        <h3>Largest Expense Transactions (Outlier Review)</h3>
        <div id="anomaly-table-container">
          <div class="empty-state">
            <span class="material-symbols-outlined">psychology</span>
            <div class="empty-state-text">Loading anomalies...</div>
          </div>
        </div>
      </div>
    </div>

  </main>

  <!-- Bottom Navigation -->
  <nav class="bottom-nav">
    <div class="nav-links">
      <a class="nav-link active" href="#">
        <span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">home</span>
        <span class="nav-link-label">Home</span>
      </a>
      <a class="nav-link" href="#">
        <span class="material-symbols-outlined">history</span>
        <span class="nav-link-label">History</span>
      </a>
      <a class="nav-link" href="#">
        <span class="material-symbols-outlined">credit_card</span>
        <span class="nav-link-label">Cards</span>
      </a>
      <a class="nav-link" href="#">
        <span class="material-symbols-outlined">person</span>
        <span class="nav-link-label">Profile</span>
      </a>
    </div>
    <button class="nav-fab" aria-label="Scan QR">
      <span class="material-symbols-outlined">qr_code_scanner</span>
    </button>
  </nav>

</div>
`;

// Initialize the dashboard (fetches live data from API)
initDashboard();
