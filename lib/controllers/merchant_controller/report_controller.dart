import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/app_constants.dart';
import '../../core/supabase_service.dart';
import '../../services/pdf_debt_report_service.dart';

class ReportController extends GetxController {
  var isLoading    = false.obs;
  var reports      = [].obs;

  var fromDate     = DateTime.now().obs;
  var toDate       = DateTime.now().obs;
  var selectedType = "كافه التقارير".obs;

  final box = GetStorage();

  @override
  void onInit() {
    fetchReports();
    super.onInit();
  }

  Future<void> fetchReports() async {
    try {
      isLoading(true);
      final merchantId = box.read("Profile-id");

      var query = SupabaseService.client
          .from(AppTables.transactions)
          .select('*, requests(customers(customer_name, phone))')
          .eq('merchant_id', merchantId)
          .gte('date', fromDate.value.toString().split(' ')[0])
          .lte('date', toDate.value.toString().split(' ')[0]);

      if (selectedType.value != 'كافه التقارير') {
        final typeFilter = selectedType.value == 'الديون'
            ? TransactionType.debt
            : TransactionType.payment;
        query = query.eq('type', typeFilter);
      }

      final data = await query.order('date', ascending: false);
      reports.value = data;
    } catch (e) {
      print("Error fetching reports: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> printMerchantDebtsReport(String merchantId) async {
    try {
      isLoading(true);

      final merchant = await SupabaseService.client
          .from(AppTables.merchants)
          .select()
          .eq('id', merchantId)
          .single();

      final requests = await SupabaseService.client
          .from(AppTables.requests)
          .select('*, customers(customer_name, phone, address)')
          .eq('merchant_id', merchantId)
          .eq('status', RequestStatus.accepted);

      double totalDebt = 0;
      for (var r in requests) {
        totalDebt += (r['total_debt'] as num?)?.toDouble() ?? 0;
      }

      await PdfDebtReportService.generateDebtReport(
        storeInfo: {
          'name':    merchant['merchant_name'],
          'phone':   merchant['phone'],
          'address': merchant['business_name'] ?? '',
        },
        customersList: (requests as List).map((r) => {
          'name':       r['customers']?['customer_name'],
          'phone':      r['customers']?['phone'],
          'total_debt': r['total_debt'],
          'debt_limit': r['account_limit'],
        }).toList(),
        globalSummary: {
          'total_customers': requests.length,
          'total_debt':      totalDebt,
        },
      );
    } catch (e) {
      Get.snackbar("خطأ", "فشل إنشاء التقرير الإجمالي: $e");
    } finally {
      isLoading(false);
    }
  }
}
