import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sehatak/core/constants/app_colors.dart';

// ✅ Shimmer مثل إنستغرام - تحميل البوستات
class InstagramShimmer extends StatelessWidget {
  final int itemCount;
  final bool isDark;

  const InstagramShimmer({
    super.key,
    this.itemCount = 3,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: itemCount,
        itemBuilder: (context, index) => _buildShimmerItem(),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(  // ✅ إزالة const
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 100,
                      height: 10,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(  // ✅ إزالة const
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              4,
              (index) => Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 150,
            height: 12,
            color: Colors.white,
          ),
          const SizedBox(height: 4),
          Container(
            width: 200,
            height: 10,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

/// ✅ Shimmer للقائمة (مثل فيسبوك)
class ListShimmer extends StatelessWidget {
  final int itemCount;
  final bool isDark;

  const ListShimmer({
    super.key,
    this.itemCount = 5,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: itemCount,
        itemBuilder: (context, index) => _buildShimmerItem(),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(  // ✅ إزالة const
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 14,
                  color: Colors.white,
                ),
                const SizedBox(height: 6),
                Container(
                  width: 150,
                  height: 12,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                Container(
                  width: 80,
                  height: 10,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ Shimmer للشبكة (مثل Pinterest)
class GridShimmer extends StatelessWidget {
  final int crossAxisCount;
  final bool isDark;

  const GridShimmer({
    super.key,
    this.crossAxisCount = 2,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      enabled: true,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.75,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(  // ✅ إزالة const
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// ✅ Shimmer للدردشة (مثل واتساب)
class ChatShimmer extends StatelessWidget {
  final bool isDark;

  const ChatShimmer({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 8,
        itemBuilder: (context, index) {
          final isMe = index % 2 == 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!isMe)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                const SizedBox(width: 8),
                Container(
                  width: isMe ? 150 : 200,
                  height: 40,
                  decoration: BoxDecoration(  // ✅ إزالة const
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                      bottomRight: isMe ? Radius.zero : const Radius.circular(12),
                    ),
                  ),
                ),
                if (isMe)
                  const SizedBox(width: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ✅ Shimmer للبروفايل (مثل تويتر)
class ProfileShimmer extends StatelessWidget {
  final bool isDark;

  const ProfileShimmer({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      enabled: true,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.only(top: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 150,
            height: 20,
            color: Colors.white,
          ),
          const SizedBox(height: 6),
          Container(
            width: 100,
            height: 14,
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              3,
              (index) => Column(
                children: [
                  Container(
                    width: 40,
                    height: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 60,
                    height: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(
            4,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 150,
                    height: 14,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
