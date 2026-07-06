class AppTables {
  static const String userProfiles    = 'user_profiles';
  static const String merchants       = 'merchants';
  static const String customers       = 'customers';
  static const String requests        = 'requests';
  static const String transactions    = 'transactions';
  static const String transactionItems = 'transaction_items';
  static const String wallets         = 'wallets';
  static const String notifications   = 'notifications';
  static const String ads             = 'ads';
}

class AppRpc {
  static const String getMerchantDashboard = 'get_merchant_dashboard';
  static const String getAdminDashboard    = 'get_admin_dashboard';
}

class UserType {
  static const String merchant = 'merchant';
  static const String customer = 'customer';
  static const String admin    = 'admin';
}

class RequestStatus {
  static const int pending  = 0;
  static const int accepted = 1;
  static const int blocked  = 2;
}

class TransactionType {
  static const String debt    = 'debt';
  static const String payment = 'payment';
}
