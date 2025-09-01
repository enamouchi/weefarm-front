import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../routes/app_routes.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              
              // Logo
              _buildLogo(),
              
              const SizedBox(height: 40),
              
              // Welcome Text
              _buildWelcomeText(),
              
              const SizedBox(height: 60),
              
              // Action Buttons
              _buildActionButtons(),
              
              const SizedBox(height: 30),
              
              // Login Link
              _buildLoginLink(),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _LogoPatternPainter(),
            ),
          ),
          
          // WeeFarm text
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Stylized "W" and "F" letters
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogoLetter('W'),
                    const SizedBox(width: 2),
                    _buildLogoLetter('F'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'WeeFarm',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLogoLetter(String letter) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'welcome_title'.tr,
          textAlign: TextAlign.center,
          style: Theme.of(Get.context!).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'welcome_subtitle'.tr,
          textAlign: TextAlign.center,
          style: Theme.of(Get.context!).textTheme.bodyLarge?.copyWith(
            color: AppColors.mediumGray,
            height: 1.5,
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary action - Register
        CustomButton(
          text: 'create_account'.tr,
          onPressed: () => Get.toNamed(Routes.REGISTER),
          backgroundColor: AppColors.primaryGreen,
          textColor: AppColors.white,
          width: double.infinity,
          height: 56,
          borderRadius: 16,
          elevation: 4,
          shadowColor: AppColors.primaryGreen.withOpacity(0.3),
        ),
        
        const SizedBox(height: 16),
        
        // Secondary action - Browse as guest (optional)
        CustomButton(
          text: 'browse_marketplace'.tr,
          onPressed: () => Get.toNamed(Routes.MARKETPLACE),
          backgroundColor: AppColors.white,
          textColor: AppColors.primaryGreen,
          borderColor: AppColors.primaryGreen,
          width: double.infinity,
          height: 56,
          borderRadius: 16,
        ),
      ],
    );
  }
  
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'already_have_account'.tr,
          style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
            color: AppColors.mediumGray,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Get.toNamed(Routes.LOGIN),
          child: Text(
            'login'.tr,
            style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

class _LogoPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    // Draw leaf-like patterns
    final path = Path();
    
    // Top-right leaf
    path.moveTo(size.width * 0.7, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.15,
      size.width * 0.9,
      size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.4,
      size.width * 0.7,
      size.height * 0.35,
    );
    path.close();
    
    // Bottom-left leaf
    path.moveTo(size.width * 0.3, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.85,
      size.width * 0.1,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.6,
      size.width * 0.3,
      size.height * 0.65,
    );
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}