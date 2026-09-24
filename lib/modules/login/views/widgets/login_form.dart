import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../controllers/login_controller.dart';

class LoginForm extends GetView<LoginController> {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome back',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to continue to ${AppConstants.appName}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 28),
          AppTextField(
            controller: controller.emailController,
            label: 'Email / Username',
            hint: 'you@example.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) {
                return 'Email / username is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Obx(
            () => AppTextField(
              controller: controller.passwordController,
              label: 'Password',
              hint: 'Enter your password',
              prefixIcon: Icons.lock_outline,
              obscureText: controller.obscurePassword.value,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => controller.login(),
              suffixIcon: IconButton(
                onPressed: controller.togglePasswordVisibility,
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
              validator: (value) {
                final password = value ?? '';
                if (password.isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 28),
          Obx(
            () => CustomButton(
              text: 'Sign In',
              icon: Icons.login,
              width: double.infinity,
              isLoading: controller.isLoading.value,
              onPressed: controller.login,
            ),
          ),
        ],
      ),
    );
  }
}
