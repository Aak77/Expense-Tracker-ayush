// =============================================
// FinTrack — Auth State Management
// =============================================

const TOKEN_KEY = 'fintrack_token';
const REFRESH_KEY = 'fintrack_refresh';
const USER_KEY = 'fintrack_user';

export function getToken() {
  return localStorage.getItem(TOKEN_KEY);
}

export function getRefreshToken() {
  return localStorage.getItem(REFRESH_KEY);
}

export function getUser() {
  try {
    const raw = localStorage.getItem(USER_KEY);
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
}

export function setTokens(accessToken, refreshToken) {
  localStorage.setItem(TOKEN_KEY, accessToken);
  if (refreshToken) {
    localStorage.setItem(REFRESH_KEY, refreshToken);
  }
}

export function setUser(user) {
  localStorage.setItem(USER_KEY, JSON.stringify(user));
}

export function clearAuth() {
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(REFRESH_KEY);
  localStorage.removeItem(USER_KEY);
}

export function isAuthenticated() {
  const token = getToken();
  if (!token) return false;

  // Check if token is expired (basic JWT decode)
  try {
    const payload = JSON.parse(atob(token.split('.')[1]));
    const expiry = payload.exp * 1000;
    return Date.now() < expiry;
  } catch {
    return false;
  }
}

export function getUserName() {
  const user = getUser();
  if (!user) return 'User';
  return user.full_name || user.email?.split('@')[0] || 'User';
}

export function getUserInitials() {
  const name = getUserName();
  const parts = name.split(' ');
  if (parts.length >= 2) {
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
  return name.substring(0, 2).toUpperCase();
}
