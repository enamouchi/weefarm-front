import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../controllers/plant_scanner_controller.dart';

class PlantScannerView extends StatelessWidget {
  final controller = Get.put(PlantScannerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تشخيص أمراض النباتات'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: controller.showAnalysisHistory,
            tooltip: 'سجل التحليلات',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInstructionsCard(),
            SizedBox(height: 20),
            _buildImageSection(),
            SizedBox(height: 20),
            Expanded(child: _buildAnalysisSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue[700]),
                SizedBox(width: 8),
                Text('تعليمات التصوير', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            Text('• صور الأوراق أو الثمار المصابة بوضوح'),
            Text('• تأكد من الإضاءة الجيدة'),
            Text('• اقترب من النبات للحصول على تفاصيل أكثر'),
            Text('• تجنب الظلال والانعكاسات'),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Obx(() => Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (controller.selectedImage.value != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  controller.selectedImage.value!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: controller.retakePhoto,
                    icon: Icon(Icons.refresh),
                    label: Text('صورة جديدة'),
                  ),
                  if (controller.analysisResult.value != null)
                    TextButton.icon(
                      onPressed: controller.shareAnalysis,
                      icon: Icon(Icons.share),
                      label: Text('مشاركة'),
                    ),
                ],
              ),
            ],
            
            if (controller.selectedImage.value == null) ...[
              Icon(Icons.add_a_photo, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text('اختر صورة للنبات لبدء التحليل', style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 16),
            ],
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => controller.pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt),
                  label: Text('التقط صورة'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.pickImage(ImageSource.gallery),
                  icon: Icon(Icons.photo_library),
                  label: Text('من المعرض'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
                ),
              ],
            ),
            
            if (controller.selectedImage.value != null) ...[
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.isAnalyzing.value 
                      ? null 
                      : controller.analyzeImage,
                  icon: controller.isAnalyzing.value 
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(Icons.psychology),
                  label: Text(controller.isAnalyzing.value ? 'جاري التحليل...' : 'تحليل الصورة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ));
  }

  Widget _buildAnalysisSection() {
    return Obx(() {
      final result = controller.analysisResult.value;
      if (result == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.eco, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text('نتائج التحليل ستظهر هنا', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        );
      }
      
      return SingleChildScrollView(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('نتائج التحليل', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Divider(),
                
                // Plant identification
                _buildResultSection(
                  'نوع النبات',
                  result['plant']['arabicName'],
                  Icons.local_florist,
                  Colors.green,
                ),
                
                // Confidence level
                _buildResultSection(
                  'مستوى الثقة',
                  '${(result['plant']['confidence'] * 100).toInt()}%',
                  Icons.verified,
                  Colors.blue,
                ),
                
                // Diseases found
                if (result['diseases'].isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text('المشاكل المكتشفة:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[700])),
                  ...result['diseases'].map<Widget>((disease) => 
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange, size: 16),
                          SizedBox(width: 8),
                          Expanded(child: Text(disease['ar'])),
                        ],
                      ),
                    )
                  ),
                ] else ...[
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('لا توجد مشاكل واضحة', style: TextStyle(color: Colors.green[700])),
                    ],
                  ),
                ],
                
                // Recommendations
                if (result['recommendations'].isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text('التوصيات العلاجية:', 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  ...result['recommendations'].map<Widget>((rec) => 
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                          SizedBox(width: 8),
                          Expanded(child: Text(rec)),
                        ],
                      ),
                    )
                  ),
                ],
                
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.yellow[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.yellow[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange[700]),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'هذا التحليل إرشادي. للحصول على تشخيص دقيق، استشر خبير زراعي.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildResultSection(String title, String content, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 8),
          Text('$title: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(content)),
        ],
      ),
    );
  }
}
