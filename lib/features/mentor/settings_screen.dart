import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/colors.dart';
import '../../core/services/claude_service.dart';
import '../../providers/mentor_provider.dart' show mentorUserNamePrefKey;

/// Ajustes del Mentor IA: API key de Claude y personalización (nombre).
class MentorSettingsScreen extends StatefulWidget {
  const MentorSettingsScreen({super.key});

  @override
  State<MentorSettingsScreen> createState() => _MentorSettingsScreenState();
}

class _MentorSettingsScreenState extends State<MentorSettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final ClaudeService _claude = ClaudeService();

  bool _loading = true;
  bool _verifying = false;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = await _claude.getApiKey();
    if (!mounted) return;
    setState(() {
      _apiKeyController.text = apiKey ?? '';
      _nameController.text = prefs.getString(mentorUserNamePrefKey) ?? '';
      _loading = false;
    });
  }

  Future<void> _saveApiKey(String value) => _claude.setApiKey(value.trim());

  Future<void> _saveName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(mentorUserNamePrefKey, value.trim());
  }

  Future<void> _openConsole() async {
    await launchUrl(
      Uri.parse('https://console.anthropic.com'),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _verifyConnection() async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      _showSnack('Ingresa tu API key primero.', success: false);
      return;
    }
    await _saveApiKey(apiKey);

    setState(() => _verifying = true);
    try {
      await _claude.sendMessage(
        userMessage: 'Responde solo con "OK".',
        history: const [],
        systemPrompt: 'Eres un chequeo de conexión. Responde brevemente.',
      );
      if (!mounted) return;
      _showSnack('✅ Conexión exitosa', success: true);
    } catch (e) {
      if (!mounted) return;
      _showSnack(
        '❌ ${e.toString().replaceFirst('Exception: ', '')}',
        success: false,
      );
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  void _showSnack(String message, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppColors.success : AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Ajustes del Mentor',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const _SectionTitle('API de Claude'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: _obscureApiKey,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'sk-ant-...',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureApiKey
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () =>
                            setState(() => _obscureApiKey = !_obscureApiKey),
                      ),
                    ),
                    onChanged: _saveApiKey,
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _openConsole,
                    child: const Text(
                      'Obtén tu API key en console.anthropic.com',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _verifying ? null : _verifyConnection,
                      child: _verifying
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Verificar conexión'),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const _SectionTitle('Sobre el Mentor'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Tu nombre',
                      labelStyle: const TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _saveName,
                  ),
                ],
              ),
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textMuted,
        fontWeight: FontWeight.bold,
        fontSize: 12,
        letterSpacing: 0.5,
      ),
    );
  }
}
