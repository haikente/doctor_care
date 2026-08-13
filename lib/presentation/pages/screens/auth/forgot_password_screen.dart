import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onInputChanged);
    _emailController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    if (mounted) setState(() {});
  }

  bool get _isEmailValid {
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PasswordResetSent) {
            setState(() => _emailSent = true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.tr('reset_email_sent')),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.08),
                  theme.colorScheme.secondary.withOpacity(0.06),
                  theme.colorScheme.surface,
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTopBar(theme, isLoading),
                      const Gap(34),
                      _buildHero(theme),
                      const Gap(28),
                      _buildFormCard(theme, isLoading),
                      const Gap(18),
                      _buildInfoCard(theme),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme, bool isLoading) {
    return Row(
      children: [
        Material(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: isLoading ? null : () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: theme.colorScheme.onSurface,
                size: 22,
              ),
            ),
          ),
        ),
        const Gap(12),
        Text(
          context.tr('forgot_password_title'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildHero(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.colorScheme.primary, const Color(0xFF20A386)],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.22),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Icon(
            Icons.mark_email_unread_outlined,
            color: Colors.white,
            size: 42,
          ),
        ),
        const Gap(24),
        Text(
          context.tr('reset_password_title'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            height: 1.08,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const Gap(12),
        Text(
          context.tr('reset_password_desc'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: theme.colorScheme.onSurface.withOpacity(0.62),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(ThemeData theme, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr('email'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Gap(10),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            enabled: !isLoading,
            decoration: InputDecoration(
              hintText: context.tr('your_email_hint'),
              prefixIcon: Icon(
                Icons.email_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.dividerColor.withOpacity(0.16),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return context.tr('please_enter_email');
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value.trim())) {
                return context.tr('invalid_email_format');
              }
              return null;
            },
            onFieldSubmitted: (_) => _submit(isLoading),
          ),
          if (_emailSent) ...[const Gap(12), _buildSentNotice(theme)],
          const Gap(20),
          SizedBox(
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isLoading || !_isEmailValid
                      ? [Colors.blue.shade100, Colors.blue.shade200]
                      : [theme.colorScheme.primary, const Color(0xFF1F8F7A)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: isLoading || !_isEmailValid
                    ? null
                    : () => _submit(isLoading),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        context.tr('send_reset_link'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ),
          const Gap(12),
          TextButton.icon(
            onPressed: isLoading ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.login_rounded, size: 18),
            label: Text(context.tr('back_to_login')),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentNotice(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
          const Gap(10),
          Expanded(
            child: Text(
              context.tr('reset_email_sent'),
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.78),
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('note'),
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(5),
                Text(
                  context.tr('reset_password_note_bullets'),
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.66),
                    fontSize: 12,
                    height: 1.42,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submit(bool isLoading) {
    if (isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      ResetPasswordEvent(_emailController.text.trim()),
    );
  }
}
