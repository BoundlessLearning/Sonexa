import 'package:flutter/material.dart';

import 'package:sonexa/core/localization/app_localizations.dart';

class ServerConnectionForm extends StatefulWidget {
  const ServerConnectionForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
    this.errorMessage,
  });

  final void Function(String baseUrl, String username, String password)
  onSubmit;
  final bool isLoading;
  final String? errorMessage;

  @override
  State<ServerConnectionForm> createState() => _ServerConnectionFormState();
}

class _ServerConnectionFormState extends State<ServerConnectionForm> {
  final _formKey = GlobalKey<FormState>();
  final _serverUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _serverUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    widget.onSubmit(
      _serverUrlController.text.trim(),
      _usernameController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _serverUrlController,
            enabled: !widget.isLoading,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.link),
              hintText: 'https://music.example.com',
              labelText: l10n.serverAddress,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.enterServerAddress;
              }
              final trimmed = value.trim();
              if (!trimmed.startsWith('http://') &&
                  !trimmed.startsWith('https://')) {
                return l10n.serverAddressProtocolRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _usernameController,
            enabled: !widget.isLoading,
            autocorrect: false,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person),
              labelText: l10n.username,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.enterUsername;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            enabled: !widget.isLoading,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock),
              labelText: l10n.password,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.enterPassword;
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          if (widget.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 18,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: widget.isLoading ? null : _handleSubmit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                widget.isLoading
                    ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                    : Text(l10n.connect, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
