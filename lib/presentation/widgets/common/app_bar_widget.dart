import 'package:flutter/material.dart';

class AgileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? accentColor;
  final List<Widget>? actions;
  final Widget? bottom;

  const AgileAppBar({
    super.key,
    required this.title,
    this.accentColor,
    this.actions,
    this.bottom,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          if (accentColor != null) ...[
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
          ],
          Text(title),
        ],
      ),
      actions: actions,
    );
  }
}
