import 'package:flutter/material.dart';
import '../core/constants.dart';

class TealHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  const TealHeader({super.key, required this.title, this.showBack = false});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: kTeal,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      toolbarHeight: 70,
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.maybePop(context),
            )
          : null,
      title: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }
}
