// lib/app/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/values/app_colors.dart';
import '../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isListView;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  const ProductCard({
    Key? key,
    required this.product,
    this.isListView = false,
    this.onTap,
    this.onFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: isListView ? _buildListView() : _buildGridView(),
      ),
    );
  }

  Widget _buildGridView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImage(),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              const SizedBox(height: 4),
              _buildFarmerName(),
              const SizedBox(height: 8),
              _buildPriceAndFavorite(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    return Row(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: _buildImage(),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(),
                const SizedBox(height: 4),
                _buildFarmerName(),
                const SizedBox(height: 8),
                _buildDescription(),
                const SizedBox(height: 8),
                _buildPriceAndFavorite(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    return Container(
      height: isListView ? double.infinity : 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.lightGray,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: product.images.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: product.images.first,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => Container(
                      color: AppColors.lightGray,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.lightGray,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppColors.mediumGray,
                          size: 40,
                        ),
                      ),
                    ),
                  )
                : Container(
                    color: AppColors.lightGray,
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        color: AppColors.mediumGray,
                        size: 40,
                      ),
                    ),
                  ),
          ),
          if (product.isOrganic)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'organic'.tr,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      product.name,
      style: Get.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      ),
      maxLines: isListView ? 2 : 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFarmerName() {
    return Text(
      'by ${product.farmerName ?? 'Unknown'.tr}',
      style: Get.textTheme.bodySmall?.copyWith(
        color: AppColors.mediumGray,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription() {
    if (!isListView || product.description.isEmpty) return const SizedBox();
    
    return Text(
      product.description,
      style: Get.textTheme.bodySmall?.copyWith(
        color: AppColors.darkGray,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPriceAndFavorite() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${product.price.toStringAsFixed(2)} ${'tnd'.tr}',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            if (product.unit.isNotEmpty)
              Text(
                'per ${product.unit}',
                style: Get.textTheme.bodySmall?.copyWith(
                  color: AppColors.mediumGray,
                ),
              ),
          ],
        ),
        GestureDetector(
          onTap: onFavorite,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              product.isFavorited ? Icons.favorite : Icons.favorite_outline,
              color: product.isFavorited ? AppColors.error : AppColors.mediumGray,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}