// lib/modules/plant_analysis/controllers/plant_scanner_controller.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../../core/services/api_service.dart';

class PlantScannerController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = Get.find<ApiService>();
  
  var selectedImage = Rx<File?>(null);
  var isAnalyzing = false.obs;
  var analysisResult = Rx<Map<String, dynamic>?>(null);
  var analysisHistory = <Map<String, dynamic>>[].obs;

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (image != null) {
        selectedImage.value = File(image.path);
        analysisResult.value = null;
        
        Get.snackbar(
          'تم اختيار الصورة', 
          'جاهز للتحليل',
          backgroundColor: Colors.green[100],
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ', 
        'فشل في اختيار الصورة: ${e.toString()}',
        backgroundColor: Colors.red[100],
      );
    }
  }

  Future<void> analyzeImage() async {
    if (selectedImage.value == null) {
      Get.snackbar('تحذير', 'يرجى اختيار صورة أولا');
      return;
    }
    
    try {
      isAnalyzing.value = true;
      
      final result = await _apiService.postMultipart(
        '/plant-analysis/analyze',
        selectedImage.value!,
        'plantImage'
      );
      
      if (result['success'] == true) {
        analysisResult.value = result['analysis'];
        
        // Add to history
        analysisHistory.insert(0, {
          'analysis': result['analysis'],
          'image_path': selectedImage.value!.path,
          'timestamp': DateTime.now(),
        });
        
        // Keep only last 10 analyses
        if (analysisHistory.length > 10) {
          analysisHistory.removeRange(10, analysisHistory.length);
        }
        
        Get.snackbar(
          'تم التحليل', 
          result['message'] ?? 'تم تحليل الصورة بنجاح',
          backgroundColor: Colors.green[100],
          duration: Duration(seconds: 3),
        );
      } else {
        throw Exception(result['error'] ?? 'فشل في التحليل');
      }
      
    } catch (e) {
      print('Analysis error: $e');
      Get.snackbar(
        'خطأ في التحليل', 
        'تعذر تحليل الصورة. جاري عرض نتائج تجريبية.',
        backgroundColor: Colors.orange[100],
        duration: Duration(seconds: 4),
      );
      
      // Provide demo analysis
      analysisResult.value = _getDemoAnalysis();
    } finally {
      isAnalyzing.value = false;
    }
  }

  Map<String, dynamic> _getDemoAnalysis() {
    final plants = ['طماطم', 'زيتون', 'برتقال', 'فلفل'];
    final randomPlant = plants[DateTime.now().microsecond % plants.length];
    
    return {
      'plant': {
        'name': 'Demo Plant',
        'arabicName': randomPlant,
        'confidence': 0.8,
      },
      'diseases': [
        {
          'ar': 'بقع بنية على الأوراق',
          'treatment': 'استخدم مبيد فطري وحسن التهوية'
        }
      ],
      'recommendations': [
        'النبات يحتاج عناية خاصة',
        'راقب الري وتجنب الإفراط',
        'استشر خبير زراعي للتأكد',
        'هذه نتائج تجريبية للعرض'
      ],
      // FIXED: Use correct DateTime method
      'analysisDate': DateTime.now().toIso8601String(),
    };
  }

  void showAnalysisHistory() {
    if (analysisHistory.isEmpty) {
      Get.snackbar('لا توجد سجلات', 'لم تقم بتحليل أي صور بعد');
      return;
    }

    Get.dialog(
      AlertDialog(
        title: Text('سجل التحليلات السابقة'),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: analysisHistory.length,
            itemBuilder: (context, index) {
              final analysis = analysisHistory[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: FileImage(File(analysis['image_path'])),
                  ),
                  title: Text(analysis['analysis']['plant']['arabicName']),
                  subtitle: Text(
                    'تم في: ${analysis['timestamp'].toString().substring(0, 19)}'
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.visibility),
                    onPressed: () {
                      Get.back();
                      analysisResult.value = analysis['analysis'];
                      selectedImage.value = File(analysis['image_path']);
                    },
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void retakePhoto() {
    selectedImage.value = null;
    analysisResult.value = null;
  }

  void shareAnalysis() {
    if (analysisResult.value == null) return;
    
    final result = analysisResult.value!;
    final shareText = '''
نتيجة تحليل النبات - WeeFarm:
🌱 النوع: ${result['plant']['arabicName']}
${result['diseases'].isNotEmpty ? '⚠️ مشاكل: ${result['diseases'].map((d) => d['ar']).join('، ')}' : '✅ النبات يبدو صحي'}

التوصيات:
${result['recommendations'].map((r) => '• $r').join('\n')}

تطبيق WeeFarm - السوق الزراعي التونسي الذكي
    ''';
    
    Get.snackbar('مشاركة', 'تم نسخ النتيجة. يمكنك مشاركتها الآن');
  }
}