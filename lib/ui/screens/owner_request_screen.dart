import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:rawang_melodies/data/remote/api_service.dart';

/// Artist/organization onboarding request. Goes to the admin portal as
/// pending — admin creates the account + profile and hands over
/// credentials via a social app. At least 5 facebook/youtube video
/// links are required as proof.
class OwnerRequestScreen extends StatefulWidget {
  const OwnerRequestScreen({super.key});

  @override
  State<OwnerRequestScreen> createState() => _OwnerRequestScreenState();
}

class _OwnerRequestScreenState extends State<OwnerRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _requesterNameCtrl = TextEditingController();
  final _requesterPhoneCtrl = TextEditingController();
  final List<TextEditingController> _linkCtrls =
      List.generate(5, (_) => TextEditingController());

  String _ownerModel = 'Singer';
  PlatformFile? _avatar;
  String? _avatarError;
  bool _submitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _descCtrl.dispose();
    _requesterNameCtrl.dispose();
    _requesterPhoneCtrl.dispose();
    for (final c in _linkCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  bool _isVideoLink(String v) {
    final t = v.trim().toLowerCase();
    if (t.isEmpty) return false;
    return t.contains('facebook.com') ||
        t.contains('fb.watch') ||
        t.contains('youtube.com') ||
        t.contains('youtu.be');
  }

  int get _validLinkCount =>
      _linkCtrls.where((c) => _isVideoLink(c.text)).length;

  Future<void> _pickAvatar() async {
    final files = await FilePicker.pickFiles(
      type: FileType.image,
    );
    if (files.isEmpty) return;
    final file = files.first;
    final ext = (file.extension ?? '').toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
      setState(() => _avatarError = 'Only JPG/PNG/WEBP images are accepted.');
      return;
    }
    final size = file.lengthSync() ?? await file.length();
    if (size > ApiService.maxAvatarFileBytes) {
      setState(() => _avatarError = 'Image too large (max 5 MB).');
      return;
    }
    if (file.path == null) {
      setState(() => _avatarError = 'Could not read the selected image.');
      return;
    }
    setState(() {
      _avatarError = null;
      _avatar = file;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_avatar?.path == null) {
      setState(() => _avatarError = 'Please attach the owner avatar photo.');
      return;
    }
    final links =
        _linkCtrls.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    if (links.length < 5 || !_linkCtrls.every((c) => c.text.trim().isEmpty || _isVideoLink(c.text))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attach at least 5 facebook or youtube video links.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await ApiService.submitOwnerRequest(
        name: _nameCtrl.text.trim(),
        ownerModel: _ownerModel,
        phone: _phoneCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        requesterName: _requesterNameCtrl.text.trim(),
        requesterPhone: _requesterPhoneCtrl.text.trim(),
        videoLinks: links,
        avatarPath: _avatar!.path!,
      );
      if (mounted) setState(() => _submitted = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Register Artist / Organization')),
      body: _submitted ? _buildSuccess(theme) : _buildForm(theme),
    );
  }

  Widget _buildSuccess(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            const Text(
              'Request sent!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'The admin will review your videos and contact you via social app with your login.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _ownerModel,
              decoration: const InputDecoration(labelText: 'Registering as *'),
              items: const [
                DropdownMenuItem(value: 'Singer', child: Text('Singer / Artist')),
                DropdownMenuItem(value: 'Organization', child: Text('Organization')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _ownerModel = v);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Stage / Organization Name *'),
              validator: (v) => (v == null || v.trim().length < 2) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Contact Phone (optional)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'About / Bio (optional)'),
            ),
            const SizedBox(height: 16),
            Text('Owner avatar photo *',
                style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickAvatar,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _avatar?.path == null
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 28),
                            SizedBox(height: 4),
                            Text('Tap to attach photo (JPG/PNG/WEBP, max 5 MB)',
                                style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_avatar!.path!),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() => _avatar = null),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black54,
                                ),
                                child: const Icon(Icons.clear, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            if (_avatarError != null) ...[
              const SizedBox(height: 4),
              Text(_avatarError!, style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
            ],
            const SizedBox(height: 16),
            Text('Your contact (for login delivery) *',
                style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _requesterNameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Your Name *'),
              validator: (v) => (v == null || v.trim().length < 2) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _requesterPhoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Your Phone *',
                hintText: 'Login phone for the new account',
              ),
              validator: (v) => (v == null || v.trim().length < 7) ? 'Enter valid phone' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text('Proof videos * (min 5 facebook/youtube links)',
                      style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _linkCtrls.add(TextEditingController())),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ..._linkCtrls.asMap().entries.map((entry) {
              final i = entry.key;
              final ctrl = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextFormField(
                  controller: ctrl,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    labelText: 'Video link ${i + 1}${i < 5 ? ' *' : ''}',
                    hintText: 'https://youtube.com/... or facebook.com/...',
                    suffixIcon: i >= 5
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() {
                              ctrl.dispose();
                              _linkCtrls.removeAt(i);
                            }),
                          )
                        : null,
                  ),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return i < 5 ? 'Required' : null;
                    if (!_isVideoLink(t)) return 'Must be a facebook or youtube link';
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
              );
            }),
            Text('$_validLinkCount / 5 valid links',
                style: TextStyle(
                  fontSize: 12,
                  color: _validLinkCount >= 5 ? Colors.green : theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send),
                label: Text(_submitting ? 'Sending...' : 'Send Request'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
