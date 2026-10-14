import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../providers/credit_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/form_widgets.dart';
import '../widgets/teal_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ---- photo ----

  void _photoOptions(BuildContext context) {
    final hasPhoto = context.read<ProfileProvider>().profile.photoPath != null;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pick(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pick(context, ImageSource.camera);
              },
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: kRed),
                title: const Text('Remove photo',
                    style: TextStyle(color: kRed)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final messenger = ScaffoldMessenger.of(context);
                  final err =
                      await context.read<ProfileProvider>().removePhoto();
                  if (err != null) {
                    messenger.showSnackBar(SnackBar(content: Text(err)));
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final messenger = ScaffoldMessenger.of(context);
    final profile = context.read<ProfileProvider>();
    try {
      final picked = await ImagePicker()
          .pickImage(source: source, maxWidth: 800, imageQuality: 85);
      if (picked == null) return; // user cancelled
      final err = await profile.updatePhoto(picked.path);
      if (err != null) messenger.showSnackBar(SnackBar(content: Text(err)));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Could not open the camera or gallery.')));
    }
  }

  // ---- name ----

  Future<void> _editName(BuildContext context) async {
    final profile = context.read<ProfileProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _EditNameDialog(initial: profile.profile.name),
    );
    if (name == null || name == profile.profile.name) return;
    final err = await profile.updateName(name);
    messenger.showSnackBar(SnackBar(content: Text(err ?? 'Name updated')));
  }

  // ---- clear storage ----

  Future<void> _clearStorage(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear storage?'),
        content: const Text(
            'All your expenses and saved credits will be deleted permanently.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Clear', style: TextStyle(color: kRed))),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final expenses = context.read<ExpenseProvider>();
    final credits = context.read<CreditProvider>();
    final err = await expenses.clearAll() ?? await credits.clearAll();
    messenger.showSnackBar(SnackBar(content: Text(err ?? 'Storage cleared')));
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final hasData = context.watch<ExpenseProvider>().expenses.isNotEmpty ||
        context.watch<CreditProvider>().credits.isNotEmpty;

    final photo = profile.photoPath;
    final photoFile = (photo != null && File(photo).existsSync())
        ? File(photo)
        : null;

    return Scaffold(
      appBar: const TealHeader(title: 'Profile'),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _photoOptions(context),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: const Color(0xFFD9D9D9),
                      backgroundImage:
                          photoFile != null ? FileImage(photoFile) : null,
                      child: photoFile == null
                          ? const Icon(Icons.person,
                              size: 60, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      right: -2,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                            color: kTeal, shape: BoxShape.circle),
                        child: const Icon(Icons.photo_camera,
                            size: 13, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: () => _editName(context),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(profile.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.edit, size: 13, color: kGrey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: hasData ? () => _clearStorage(context) : null,
                style: OutlinedButton.styleFrom(
                  shape: const StadiumBorder(),
                  side: BorderSide(color: hasData ? kGrey : kBorder),
                ),
                child: Text('Clear Storage',
                    style: TextStyle(
                        fontSize: 12, color: hasData ? kGrey : kGrey)),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  final String initial;
  const _EditNameDialog({required this.initial});

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit name'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          maxLength: 30,
          textCapitalization: TextCapitalization.words,
          decoration: fieldDecoration(hint: 'Your name'),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Name cannot be empty' : null,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        TextButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
