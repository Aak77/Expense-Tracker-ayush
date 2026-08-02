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

const API_BASE = '/api/v1/admin/analytics';

// ─── Chart.js Global Defaults ────────────────────────────────────────────────

function configureChartDefaults() {
  const Chart = window.Chart;
  Chart.defaults.color = '#9ca3b0';
  Chart.defaults.borderColor = 'rgba(255,255,255,0.04)';
  Chart.defaults.font.family = "'Inter', sans-serif";
  Chart.defaults.font.size = 12;
  Chart.defaults.plugins.legend.labels.usePointStyle = true;
  Chart.defaults.plugins.legend.labels.pointStyle = 'circle';
  Chart.defaults.plugins.legend.labels.padding = 16;
  Chart.defaults.plugins.tooltip.backgroundColor = 'rgba(13,13,26,0.92)';
  Chart.defaults.plugins.tooltip.borderColor = 'rgba(37,99,235,0.3)';
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

// ─── Formatting Helpers ──────────────────────────────────────────────────────

function formatINR(amount) {
  if (amount >= 10000000) return '₹' + (amount / 10000000).toFixed(2) + ' Cr';
  if (amount >= 100000) return '₹' + (amount / 100000).toFixed(2) + ' L';
  if (amount >= 1000) return '₹' + (amount / 1000).toFixed(1) + 'K';
  return '₹' + amount.toFixed(0);
}

function formatNumber(n) {
  if (n >= 1000) return (n / 1000).toFixed(1) + 'K';
  return n.toLocaleString('en-IN');
}

// ─── API Fetcher ─────────────────────────────────────────────────────────────

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

// ─── Dashboard Initialization ────────────────────────────────────────────────

export async function initDashboard() {
  configureChartDefaults();

  // Fetch all data in parallel from the live backend
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
  if (incEl) incEl.textContent = formatINR(data.total_income);
  
  const expEl = document.getElementById('kpi-expenses');
  if (expEl) expEl.textContent = formatINR(data.total_expenses);
  
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
        y: { beginAtZero: true, grid: { color: 'rgba(255,255,255,0.03)' } },
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
          grid: { color: 'rgba(255,255,255,0.03)' },
          ticks: { callback: (v) => formatINR(v) },
        },
        x: { grid: { display: false } },
      },
      plugins: {
        tooltip: {
          callbacks: {
            label: (ctx) => `${ctx.dataset.label}: ${formatINR(ctx.parsed.y)}`,
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
        borderColor: 'rgba(6, 6, 15, 0.8)',
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
              return `${ctx.label.split(' (')[0]}: ${formatINR(ctx.parsed)} (${pct}%)`;
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
          grid: { color: 'rgba(255,255,255,0.03)' },
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
            afterLabel: (ctx) => `Total: ${formatINR(data[ctx.dataIndex].total_spent)}`,
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
          grid: { color: 'rgba(255,255,255,0.03)' },
          title: { display: true, text: 'Number of Users', color: '#9ca3b0' },
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
        borderColor: 'rgba(6, 6, 15, 0.8)',
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
              return `${ctx.label.split(' (')[0]}: ${formatINR(ctx.parsed)} (${pct}%) (${assets[ctx.dataIndex].count} users)`;
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
      container.innerHTML = '<p style="color: var(--text-muted); text-align:center; padding:40px;">No cohort data available.</p>';
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
          grid: { color: 'rgba(255,255,255,0.03)' },
          title: { display: true, text: 'Retention Rate (%)', color: '#9ca3b0' },
          ticks: {
            callback: (val) => `${val}%`,
          }
        },
        x: {
          grid: { display: false },
          title: { display: true, text: 'Months Since Signup', color: '#9ca3b0' },
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
    if (container) container.innerHTML = '<p style="color: var(--text-muted); text-align:center; padding:40px;">No anomalies detected.</p>';
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
