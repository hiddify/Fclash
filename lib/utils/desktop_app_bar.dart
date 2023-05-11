import 'package:flutter/material.dart';

class DesktopAppBar extends StatelessWidget {
  const DesktopAppBar({
    super.key,
    this.height = 68,
    required this.child,
  });

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      delegate: DesktopAppBarDelegate(
        height: height,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(width: 0.05)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class DesktopAppBarDelegate extends SliverPersistentHeaderDelegate {
  DesktopAppBarDelegate({
    required this.height,
    required this.child,
  });

  final double height;
  final Widget child;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
