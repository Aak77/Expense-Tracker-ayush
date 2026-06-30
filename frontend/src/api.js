// =============================================
// FinTrack — API Client
// =============================================

import { getToken, getRefreshToken, setTokens, clearAuth } from './auth.js';

const BASE_URL = '/api/v1';

/**
 * Core fetch wrapper with JWT auth
 */
async function request(method, path, body = null, options = {}) {
  const headers = {
    'Content-Type': 'application/json',
    ...options.headers,
  };

  const token = getToken();
  if (token && !options.noAuth) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const config = {
    method,
    headers,
  };

  if (body && method !== 'GET') {
    config.body = JSON.stringify(body);
  }

  const response = await fetch(`${BASE_URL}${path}`, config);

  // Handle 401 — try refresh
  if (response.status === 401 && !options.noAuth && !options.isRetry) {
    const refreshed = await tryRefreshToken();
    if (refreshed) {
      return request(method, path, body, { ...options, isRetry: true });
    }
    clearAuth();
    window.location.hash = '#/login';
    throw new Error('Session expired');
  }

  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    const error = new Error(errorData.detail || `Request failed: ${response.status}`);
    error.status = response.status;
    error.data = errorData;
    throw error;
  }

  if (response.status === 204) return null;
  return response.json();
}

/**
 * Attempt to refresh the access token
 */
async function tryRefreshToken() {
  const refreshToken = getRefreshToken();
  if (!refreshToken) return false;

  try {
    const response = await fetch(`${BASE_URL}/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refresh_token: refreshToken }),
    });

    if (!response.ok) return false;

    const data = await response.json();
    setTokens(data.access_token, data.refresh_token);
    return true;
  } catch {
    return false;
  }
}

// =============================================
// Auth API
// =============================================

export const authApi = {
  login: (email, password) =>
    request('POST', '/auth/login', { email, password }, { noAuth: true }),

  register: (fullName, email, password) =>
    request('POST', '/auth/register', {
      full_name: fullName,
      email,
      password,
    }, { noAuth: true }),

  forgotPassword: (email) =>
    request('POST', '/auth/forgot-password', { email }, { noAuth: true }),

  getProfile: () => request('GET', '/auth/me'),

  updateProfile: (data) => request('PUT', '/auth/profile', data),

  changePassword: (currentPassword, newPassword) =>
    request('PUT', '/auth/change-password', {
      current_password: currentPassword,
      new_password: newPassword,
    }),

  logout: () => {
    const refreshToken = getRefreshToken();
    const promise = request('POST', '/auth/logout', { refresh_token: refreshToken }).catch(() => {});
    clearAuth();
    return promise;
  },

  deleteAccount: () => request('DELETE', '/auth/account'),
};

// =============================================
// Transactions API
// =============================================

export const transactionsApi = {
  list: (params = {}) => {
    const query = new URLSearchParams();
    if (params.type) query.set('type', params.type);
    if (params.category) query.set('category', params.category);
    if (params.search) query.set('search', params.search);
    if (params.start_date) query.set('start_date', params.start_date);
    if (params.end_date) query.set('end_date', params.end_date);
    if (params.skip) query.set('skip', params.skip);
    if (params.limit) query.set('limit', params.limit);
    const qs = query.toString();
    return request('GET', `/transactions${qs ? '?' + qs : ''}`);
  },

  get: (id) => request('GET', `/transactions/${id}`),

  create: (data) => request('POST', '/transactions', data),

  update: (id, data) => request('PUT', `/transactions/${id}`, data),

  delete: (id) => request('DELETE', `/transactions/${id}`),
};

// =============================================
// Budgets API
// =============================================

export const budgetsApi = {
  list: (params = {}) => {
    const query = new URLSearchParams();
    if (params.month) query.set('month', params.month);
    if (params.year) query.set('year', params.year);
    const qs = query.toString();
    return request('GET', `/budgets${qs ? '?' + qs : ''}`);
  },

  create: (data) => request('POST', '/budgets', data),

  update: (id, data) => request('PUT', `/budgets/${id}`, data),

  delete: (id) => request('DELETE', `/budgets/${id}`),
};

// =============================================
// Savings Goals API
// =============================================

export const goalsApi = {
  list: () => request('GET', '/savings-goals'),

  get: (id) => request('GET', `/savings-goals/${id}`),

  create: (data) => request('POST', '/savings-goals', data),

  update: (id, data) => request('PUT', `/savings-goals/${id}`, data),

  delete: (id) => request('DELETE', `/savings-goals/${id}`),

  addContribution: (id, amount) =>
    request('POST', `/savings-goals/${id}/contribute`, { amount }),
};

// =============================================
// Net Worth API (Assets & Liabilities)
// =============================================

export const netWorthApi = {
  getSummary: () => request('GET', '/net-worth/summary'),

  // Assets
  listAssets: () => request('GET', '/net-worth/assets'),
  createAsset: (data) => request('POST', '/net-worth/assets', data),
  updateAsset: (id, data) => request('PUT', `/net-worth/assets/${id}`, data),
  deleteAsset: (id) => request('DELETE', `/net-worth/assets/${id}`),

  // Liabilities
  listLiabilities: () => request('GET', '/net-worth/liabilities'),
  createLiability: (data) => request('POST', '/net-worth/liabilities', data),
  updateLiability: (id, data) => request('PUT', `/net-worth/liabilities/${id}`, data),
  deleteLiability: (id) => request('DELETE', `/net-worth/liabilities/${id}`),

  // History
  getHistory: (params = {}) => {
    const query = new URLSearchParams();
    if (params.months) query.set('months', params.months);
    const qs = query.toString();
    return request('GET', `/net-worth/history${qs ? '?' + qs : ''}`);
  },

  snapshot: () => request('POST', '/net-worth/snapshot'),
};

// =============================================
// Analytics API
// =============================================

export const analyticsApi = {
  dashboard: () => request('GET', '/analytics/dashboard'),

  spending: (params = {}) => {
    const query = new URLSearchParams();
    if (params.month) query.set('month', params.month);
    if (params.year) query.set('year', params.year);
    const qs = query.toString();
    return request('GET', `/analytics/spending${qs ? '?' + qs : ''}`);
  },

  trends: (params = {}) => {
    const query = new URLSearchParams();
    if (params.months) query.set('months', params.months);
    const qs = query.toString();
    return request('GET', `/analytics/trends${qs ? '?' + qs : ''}`);
  },

  categoryComparison: (params = {}) => {
    const query = new URLSearchParams();
    if (params.month) query.set('month', params.month);
    if (params.year) query.set('year', params.year);
    const qs = query.toString();
    return request('GET', `/analytics/category-comparison${qs ? '?' + qs : ''}`);
  },

  charts: (params = {}) => {
    const query = new URLSearchParams();
    if (params.period) query.set('period', params.period);
    const qs = query.toString();
    return request('GET', `/analytics/charts${qs ? '?' + qs : ''}`);
  },
};

// =============================================
// Insights API
// =============================================

export const insightsApi = {
  get: () => request('GET', '/insights'),
};
