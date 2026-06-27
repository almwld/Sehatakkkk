import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// ✅ شيمر زجاجي أسود متحرك مثل إنستغرام
class GlassShimmer extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final double borderRadius;

  const GlassShimmer({
    super.key,
    required this.child,
    this.isLoading = true,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[700]!,
      period: const Duration(milliseconds: 1500),
      direction: ShimmerDirection.ltr,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: child,
      ),
    );
  }
}

/// ✅ شيمر البوستات مثل إنستغرام
class InstagramPostShimmer extends StatelessWidget {
  final int itemCount;

  const InstagramPostShimmer({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[700]!,
      period: const Duration(milliseconds: 1500),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemCount,
        itemBuilder: (context, index) => _buildPostShimmer(),
      ),
    );
  }

  Widget _buildPostShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Header (صورة + اسم)
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.grey[700],
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
                      color: Colors.grey[700],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 80,
                      height: 10,
                      color: Colors.grey[700],
                    ),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.grey[700],
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ✅ الصورة
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          // ✅ الأزرار
          Row(
            children: List.generate(
              4,
              (index) => Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 12),
                decoration: const BoxDecoration(
                  color: Colors.grey[700],
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // ✅ النص
          Container(
            width: 150,
            height: 12,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 4),
          Container(
            width: 100,
            height: 10,
            color: Colors.grey[700],
          ),
        ],
      ),
    );
  }
}

/// ✅ شيمر القائمة (List)
class ListShimmer extends StatelessWidget {
  final int itemCount;

  const ListShimmer({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[700]!,
      period: const Duration(milliseconds: 1500),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemCount,
        itemBuilder: (context, index) => _buildItemShimmer(),
      ),
    );
  }

  Widget _buildItemShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.grey[700],
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
                  color: Colors.grey[700],
                ),
                const SizedBox(height: 6),
                Container(
                  width: 120,
                  height: 12,
                  color: Colors.grey[700],
                ),
                const SizedBox(height: 4),
                Container(
                  width: 60,
                  height: 10,
                  color: Colors.grey[700],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ شيمر الشبكة (Grid) مثل Pinterest
class GridShimmer extends StatelessWidget {
  final int crossAxisCount;

  const GridShimmer({super.key, this.crossAxisCount = 2});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[700]!,
      period: const Duration(milliseconds: 1500),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.7,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// ✅ شيمر الدردشة (Chat) مثل واتساب
class ChatShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[700]!,
      period: const Duration(milliseconds: 1500),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
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
                      color: Colors.grey[700],
                      shape: BoxShape.circle,
                    ),
                  ),
                const SizedBox(width: 8),
                Container(
                  width: isMe ? 120 : 160,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                      bottomRight: isMe ? Radius.zero : const Radius.circular(12),
                    ),
                  ),
                ),
                if (isMe) const SizedBox(width: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}
