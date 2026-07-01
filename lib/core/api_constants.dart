///
class ApiConstants {
  // الرابط الأساسي
  static const String baseUrl = "http://192.168.88.123/merchant-customer-api/mc_api";




  /// ---------------------------عمليات الامان ------------------------------------///
  /// رابط انشاء حساب
  static const String register = "${ApiConstants.baseUrl}/auth/register.php";

  /// رابط تسجيل الدخول
  static const String login = "${ApiConstants.baseUrl}/auth/login.php";

  /// رابط رمز التحقق
  static const String verifyOtp = "${ApiConstants.baseUrl}/auth/otp_handler.php";

  /// رابط اعادة تعيين كلمة المرور
  static const String forgotPassword = "${ApiConstants.baseUrl}/auth/password_handler.php?action=forgot";

  /// رابط تغيير كلمة المرور
  static const String resetPassword = "${ApiConstants.baseUrl}/auth/password_handler.php?action=reset";







  ///-------------------------------------[جانب التاجر] ---------------------------------------------------

  /// رابط ارسال طلب الى العميل
  static const String sendAddRequest = "${ApiConstants.baseUrl}/requests/send_customer_request.php";

  /// هذا الرابط سيعالج القبول، الرفض، وإرسال طلب جديد
  static const String respondRequest = "${ApiConstants.baseUrl}/requests/update_request_status.php";

  /// رابط جلب طلبات الانضمام لعميل محدد
  static String getPendingRequestsUrl(int userId) => "${ApiConstants.baseUrl}/requests/get_requests.php?userId=$userId";

  /// تحويل العميل من ظيف الى حساب مستخدم
  static const String updateFullCustomerRequest = "${ApiConstants.baseUrl}/merchants/update_full_customer.php";

  /// رابط جلب بيانات الواجهة الرئيسية للتاجر
  static String getDashboardStats(int merchantId) => "${ApiConstants.baseUrl}/merchants/get_dashboard_merchants.php?merchantId=$merchantId";

  /// رابط اضافة محفظة
  static String addWallet() => "${ApiConstants.baseUrl}/merchants/wallets_manager.php";

  ///  دالة جلب التقارير العامة
  static  String getMerchantOverallReports() => "${ApiConstants.baseUrl}/reports/get_merchant_overall_reports.php";

  /// رابط حذف محفظة
  static String deleteWallet(int walletId) => "${ApiConstants.baseUrl}/merchants/wallets_manager.php?wallet_id=$walletId";

  /// رابط لجلب العملاء المرتبطين بالتاجر
  static String getCustomerByMerchant(int merchantId) => "${ApiConstants.baseUrl}/merchants/get_my_customers.php?merchant_id=$merchantId";

  /// جلب العملاء في دالة واحدة تدعم البحث والفلترة
  static String getMerchantCustomers(int merchantId, {String search = '', String filter = 'all'}) => "${ApiConstants.baseUrl}/merchants/get_customers.php?merchantId=$merchantId&filter=$filter&search=$search";

  /// رابط اضافة دين
  static const String addDebtTransaction = "${ApiConstants.baseUrl}/transactions/add_debt_transaction.php";

  /// رابط تعديل دين
  static const String updateTransaction = "${ApiConstants.baseUrl}/transactions/update_transaction.php";

  /// رابط حذف دين
  static const String deletedTransaction = "${ApiConstants.baseUrl}/transactions/delete_transaction.php";

  /// رابط جلب بيانات عملية
  static String getTransaction(int transactionId) => "${ApiConstants.baseUrl}/transactions/get_transaction_info.php?id=$transactionId";

  /// رابط اضافة سند قبض
  static const String addPayment = "${ApiConstants.baseUrl}/transactions/add_payment.php"; // تسجيل سداد
  /// رابط تعديل سند الدفع
  static const String updatePayment = "${ApiConstants.baseUrl}/transactions/edit_payment.php"; // تسجيل سداد




  /// ----------------------------------------------جانب العميل-----------------------------------------------------

  /// رابط جلب البيانات لواجهة العميل
  static String getDashboardUrl(int userId) => "${ApiConstants.baseUrl}/customers/get_dashboard_customers.php?userId=$userId";

  /// رابط جلب المتاجر المقبولة للعميل
  static String getAcceptedMerchantsUrl(int userId) => "${ApiConstants.baseUrl}/customers/accepted_merchants.php?userId=$userId";

  ///رابط تفاصيل العلاقة بين العميل وبقالة محددة
  static String getMerchantDetailsUrl(int merchantId, int userId) => "${ApiConstants.baseUrl}/customers/merchant_details_in_customer.php?merchantId=$merchantId&userId=$userId";

  /// رابط جلب جميع المحافظ على حسب التاجر
  static String getWallets(int merchantId) => "${ApiConstants.baseUrl}/merchants/wallets_manager.php?merchant_id=$merchantId";








  /// ----------------------------------------------- التقارير ---------------------------------------

  /// 7. التقارير العامة (كشف حساب شامل)
  static String getGeneralReports(int merchantId, int userId) => "${ApiConstants.baseUrl}/reports/general_reports.php?merchantId=$merchantId&requestId=$userId";

  ///
  static String getReportData(int requestId) => "${ApiConstants.baseUrl}/reports/get_report_data.php?type=customer&requestId=$requestId";

  ///
  static const String getReports = "${ApiConstants.baseUrl}/reports/get_reports.php";

  /// 6. تقارير السداد (الأموال التي دفعها العميل)
  static String getPaymentReports(int merchantId, int userId) => "${ApiConstants.baseUrl}/transactions/payment_reports.php?merchantId=$merchantId&userId=$userId";

  /// جلب بيانات تقرير اجمالي العملاء للتاجر
  static String getMerchantData(int merchantId) => "${ApiConstants.baseUrl}/reports/get_merchant_debts.php?merchantId=$merchantId";








  /// --- الإشعارات ---
  static String getNotifications(int userId) => "${ApiConstants.baseUrl}/notifications/get_notifications.php?userId=$userId";

  /// رابط قراءة الاشعارات بطريقة فردية
  static const String readSingleNotification = "${ApiConstants.baseUrl}/notifications/mark_single_notification_read.php";

  /// رابط قراءة كل الاشعارات
  static const String readAllNotification = "${ApiConstants.baseUrl}/notifications/mark_notifications_read.php";

  /// جلب بيانات لوحة المدير
  static const String getDataAdminDach = "${ApiConstants.baseUrl}/admin/get_admin_dashboard.php";

   /// جلب الاعلانات المعروضة للمستخدمين
  static const String getAds = "${ApiConstants.baseUrl}/ads/get_ads.php";

  static const String updateAdClicks = "${ApiConstants.baseUrl}/ads/update_ad_clicks.php";

  /// رابط جلب بيانات الاعلانات كامل لمدير التطبيق
  static const String getAdsStatus = "${ApiConstants.baseUrl}/admin/admin_get_all_ads.php";

  /// رابط اضافة اعلان
  static const String addAds = "${ApiConstants.baseUrl}/admin/add_ad.php";

  /// جلب جميع المستخدمين للادمين
  static const String getUserToAdmin = "${ApiConstants.baseUrl}/admin/get_all_users.php";
  /// تفعيل وايقاف مستخدم
  static const String userActive = "${ApiConstants.baseUrl}/admin/user_active.php";

  ///
  static const String manageSubscription = "${ApiConstants.baseUrl}/admin/subscriptions/manage_subscription.php";





  ///
  static Map<String, String> getHeaders() => {
    'Accept': 'application/json',
    'Content-Type': 'application/x-www-form-urlencoded',
  };
}
