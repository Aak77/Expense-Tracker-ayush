import './style.css';
import { initDashboard } from './dashboard.js';

document.querySelector<HTMLDivElement>('#app')!.innerHTML = `
<div class="dashboard" id="dashboard">
  <!-- Header -->
  <header class="dashboard-header">
    <h1>FinTrack Analytics Dashboard</h1>
    <div class="header-meta">
      <span class="header-badge"><span class="dot"></span> Live Data</span>
      <span class="header-badge" id="last-updated">Loading...</span>
    </div>
  </header>

  <!-- KPI Summary Cards -->
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

  <!-- Charts Row 1 -->
  <div class="section-title">Growth & Revenue Trends</div>
  <section class="charts-grid">
    <div class="chart-card" style="animation-delay: 0.1s;">
      <h3>User Growth</h3>
      <div class="chart-canvas-wrapper"><canvas id="chart-user-growth"></canvas></div>
    </div>
    <div class="chart-card" style="animation-delay: 0.2s;">
      <h3>Income vs Expenses</h3>
      <div class="chart-canvas-wrapper"><canvas id="chart-income-expense"></canvas></div>
    </div>
  </section>

  <!-- Charts Row 2 -->
  <div class="section-title">Spending Analysis</div>
  <section class="charts-grid">
    <div class="chart-card" style="animation-delay: 0.3s;">
      <h3>Spending by Category</h3>
      <div class="chart-canvas-wrapper"><canvas id="chart-spending-category"></canvas></div>
    </div>
    <div class="chart-card" style="animation-delay: 0.4s;">
      <h3>Top Merchants</h3>
      <div class="chart-canvas-wrapper"><canvas id="chart-top-merchants"></canvas></div>
    </div>
  </section>

  <!-- Charts Row 3 -->
  <div class="section-title">User Segments</div>
  <section class="charts-grid">
    <div class="chart-card" style="animation-delay: 0.5s;">
      <h3>User Activity Distribution</h3>
      <div class="chart-canvas-wrapper"><canvas id="chart-activity-histogram"></canvas></div>
    </div>
    <div class="chart-card" style="animation-delay: 0.6s;">
      <h3>Asset Type Distribution</h3>
      <div class="chart-canvas-wrapper"><canvas id="chart-asset-types"></canvas></div>
    </div>
  </section>

  <!-- Cohort Heatmap -->
  <div class="section-title">Cohort Retention Analysis</div>
  <section class="charts-grid">
    <div class="chart-card full-width" style="animation-delay: 0.7s;">
      <h3>Monthly Cohort Retention</h3>
      <div class="chart-canvas-wrapper" id="cohort-chart-container">
        <canvas id="chart-cohort-retention"></canvas>
      </div>
    </div>
  </section>

  <!-- Anomaly Detection -->
  <div class="section-title">Anomaly Detection</div>
  <section class="charts-grid">
    <div class="chart-card full-width" style="animation-delay: 0.8s;">
      <h3>Largest Expense Transactions (Outlier Review)</h3>
      <div id="anomaly-table-container">
        <p style="color: var(--text-muted); text-align: center; padding: 40px;">Loading anomalies...</p>
      </div>
    </div>
  </section>
</div>
`;

// Initialize the dashboard (fetches live data from API)
initDashboard();
