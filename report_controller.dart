import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../core/api_constants.dart';
import '../../views/reports/pdf_debt_report_service.dart';


class ReportController extends GetxController {
  var isLoading = false.obs;
  var reports = [].obs;

  // فلاتر البحث
  var fromDate = DateTime.now().obs;
  var toDate = DateTime.now().obs;
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
      int? merchantId = box.read("Profile-id");

      final response = await http.post(
        Uri.parse(ApiConstants.getReports),
        headers: ApiConstants.getHeaders(),
        body: jsonEncode({
          "merchant_id": merchantId,
          "from": fromDate.value.toString().split(' ')[0],
          "to": toDate.value.toString().split(' ')[0],
          "type": selectedType.value,
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        reports.value = result['data'] ?? [];
      }
    } catch (e) {
      print("Error fetching reports: $e");
    } finally {
      isLoading(false);
    }
  }

  /// دالة طباعة تقرير الديون الإجمالي للمتجر
  Future<void> printMerchantDebtsReport(int merchantId) async {
    try {
      isLoading(true);
      // استدعاء الـ API الجديد
      var response = await http.get(Uri.parse(ApiConstants.getMerchantData(merchantId)));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {

          // استدعاء دالة الـ PDF (الثانية) التي صممناها سابقاً
          await PdfDebtReportService.generateDebtReport(
            storeInfo: data['store_info'],
            customersList: data['customers'],
            globalSummary: data['summary'],
          );
        }
      }
    } catch (e) {
      Get.snackbar("خطأ", "فشل إنشاء التقرير الإجمالي: $e");
    } finally {
      isLoading(false);
    }
  }

}


