import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';

class HomeLazyList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final int initialItems;
  final int batchSize;

  const HomeLazyList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.initialItems = 4,
    this.batchSize = 4,
  });

  @override
  Widget build(BuildContext context) {
    return _LazyListView<T>(
      items: items,
      itemBuilder: itemBuilder,
      initialItems: initialItems,
      batchSize: batchSize,
    );
  }
}

class _LazyListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final int initialItems;
  final int batchSize;

  const _LazyListView({
    required this.items,
    required this.itemBuilder,
    required this.initialItems,
    required this.batchSize,
  });

  @override
  State<_LazyListView> createState() => _LazyListViewState<T>();
}

class _LazyListViewState<T> extends State<_LazyListView<T>> {
  int _visibleItems = 0;

  @override
  void initState() {
    super.initState();
    _visibleItems = widget.initialItems;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...widget.items.take(_visibleItems).map(
          (item) => widget.itemBuilder(context, item),
        ),
        if (_visibleItems < widget.items.length)
          GestureDetector(
            onTap: () {
              setState(() {
                _visibleItems = (_visibleItems + widget.batchSize)
                    .clamp(0, widget.items.length);
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'عرض المزيد (${widget.items.length - _visibleItems})',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
