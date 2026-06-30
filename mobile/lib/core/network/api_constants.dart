class ApiConstants {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS simulator, or your local network IP
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1'; 
  
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Transactions
  static const String transactions = '/transactions';

  // Budgets
  static const String budgets = '/budgets';

  // Savings Goals
  static const String savingsGoals = '/savings-goals';

  // Net Worth
  static const String netWorthSummary = '/net-worth/summary';
  static const String netWorthAssets = '/net-worth/assets';
  static const String netWorthLiabilities = '/net-worth/liabilities';
  static const String netWorthHistory = '/net-worth/history';

  // Analytics
  static const String dashboard = '/analytics/dashboard';
  static const String analyticsSpending = '/analytics/spending';
  static const String insights = '/insights';
}
