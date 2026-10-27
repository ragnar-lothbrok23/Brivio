import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../main.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../widgets/fullscreen_image_viewer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _imagePicker = ImagePicker();
  late final _nameController = TextEditingController(text: widget.user.name);
  late String? _photoBase64 = widget.user.photoBase64;
  bool _isSavingName = false;
  bool _isSavingPhoto = false;

  Future<void> _pickAndSavePhoto(ImageSource source) async {
    final picked = await _imagePicker.pickImage(source: source, maxWidth: 800, imageQuality: 70);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final base64Photo = base64Encode(bytes);
    setState(() => _isSavingPhoto = true);
    try {
      await _authService.updatePhoto(widget.user.uid, base64Photo);
      if (mounted) setState(() => _photoBase64 = base64Photo);
    } finally {
      if (mounted) setState(() => _isSavingPhoto = false);
    }
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || name == widget.user.name) return;
    setState(() => _isSavingName = true);
    try {
      await _authService.updateName(widget.user.uid, name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.nameUpdated)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingName = false);
    }
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final formKey = GlobalKey<FormState>();
    final currentController = TextEditingController();
    final newController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool isSaving = false;
        bool obscureCurrent = true;
        bool obscureNew = true;
        String? errorMessage;
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(l10n.changePassword),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: currentController,
                      obscureText: obscureCurrent,
                      decoration: InputDecoration(
                        labelText: l10n.currentPasswordLabel,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureCurrent
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () =>
                              setDialogState(() => obscureCurrent = !obscureCurrent),
                        ),
                      ),
                      validator: (value) =>
                          (value == null || value.isEmpty) ? l10n.enterCurrentPassword : null,
                    ),
                    TextFormField(
                      controller: newController,
                      obscureText: obscureNew,
                      decoration: InputDecoration(
                        labelText: l10n.newPasswordLabel,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                        ),
                      ),
                      validator: (value) =>
                          (value == null || value.length < 6) ? l10n.atLeast6Chars : null,
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() {
                            isSaving = true;
                            errorMessage = null;
                          });
                          try {
                            await _authService.changePassword(
                              currentPassword: currentController.text,
                              newPassword: newController.text,
                            );
                            if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                          } on FirebaseAuthException catch (e) {
                            setDialogState(() {
                              isSaving = false;
                              errorMessage = e.message ?? 'Failed to change password';
                            });
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.change),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileSettings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: GestureDetector(
              onTap: (_photoBase64 == null || _photoBase64!.isEmpty)
                  ? null
                  : () => showFullscreenImage(context, _photoBase64!),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: (_photoBase64 == null || _photoBase64!.isEmpty)
                        ? null
                        : MemoryImage(base64Decode(_photoBase64!)),
                    child: (_photoBase64 == null || _photoBase64!.isEmpty)
                        ? const Icon(Icons.person, size: 48)
                        : null,
                  ),
                  if (_isSavingPhoto)
                    const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _isSavingPhoto ? null : () => _pickAndSavePhoto(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: Text(l10n.camera),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: _isSavingPhoto ? null : () => _pickAndSavePhoto(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: Text(l10n.gallery),
              ),
            ],
          ),
          const Divider(height: 32),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: l10n.nameField),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isSavingName ? null : _saveName,
              child: _isSavingName
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.save),
            ),
          ),
          const Divider(height: 32),
          ListTile(title: Text(l10n.emailLabel), subtitle: Text(widget.user.email)),
          ListTile(
            title: Text(l10n.roleLabel),
            subtitle: Text(localizedRoleLabel(context, widget.user.role)),
          ),
          const Divider(height: 32),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text(l10n.changePassword),
              onTap: () => _showChangePasswordDialog(context),
            ),
          ),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: Text(l10n.darkMode),
              value: BrivioApp.of(context).isDarkMode,
              onChanged: (value) async {
                await BrivioApp.of(context).setDarkMode(value);
                if (mounted) setState(() {});
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.language_outlined),
              title: Text(l10n.language),
              trailing: DropdownButton<String>(
                value: BrivioApp.of(context).locale.languageCode,
                underline: const SizedBox.shrink(),
                items: [
                  for (final entry in kSupportedLanguages.entries)
                    DropdownMenuItem(value: entry.key, child: Text(entry.value)),
                ],
                onChanged: (code) async {
                  if (code == null) return;
                  await BrivioApp.of(context).setLocale(code);
                  await _authService.updateLanguage(widget.user.uid, code);
                  if (mounted) setState(() {});
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
