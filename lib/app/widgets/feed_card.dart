// 1. Dans lib/app/widgets/feed_card.dart - gardez seulement FeedCard
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../core/values/app_colors.dart';
import '../modules/home/controllers/home_controller.dart';

class FeedCard extends StatelessWidget {
  final FeedPost post;

  const FeedCard({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implementation FeedCard uniquement
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildContent(),
            if (post.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildImages(),
            ],
            const SizedBox(height: 12),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primaryGreen,
          backgroundImage: post.author.avatar != null 
              ? CachedNetworkImageProvider(post.author.avatar!)
              : null,
          child: post.author.avatar == null
              ? Text(
                  post.author.name.isNotEmpty ? post.author.name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.author.name,
                style: Get.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              Text(
                timeago.format(post.createdAt),
                style: Get.textTheme.bodySmall?.copyWith(
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.title.isNotEmpty) ...[
          Text(
            post.title,
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          post.body,
          style: Get.textTheme.bodyMedium?.copyWith(
            color: AppColors.darkGray,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildImages() {
    if (post.images.isEmpty) return const SizedBox();
    
    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: post.images.length,
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            margin: EdgeInsets.only(right: index < post.images.length - 1 ? 8 : 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: post.images[index],
                fit: BoxFit.cover,
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
                    child: Icon(Icons.broken_image, color: AppColors.mediumGray),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        _buildActionButton(
          icon: post.isLiked ? Icons.favorite : Icons.favorite_outline,
          label: post.likesCount.toString(),
          color: post.isLiked ? AppColors.error : AppColors.mediumGray,
          onTap: () {
            // Handle like action
          },
        ),
        const SizedBox(width: 24),
        _buildActionButton(
          icon: Icons.chat_bubble_outline,
          label: post.commentsCount.toString(),
          color: AppColors.mediumGray,
          onTap: () {
            // Handle comment action
          },
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            // Handle share action
          },
          icon: const Icon(
            Icons.share_outlined,
            color: AppColors.mediumGray,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

