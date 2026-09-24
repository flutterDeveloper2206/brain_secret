import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/app_document_field.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/form_section_card.dart';
import '../../../../core/widgets/responsive_form_grid.dart';
import '../../controllers/staff_profile_controller.dart';

class StaffProfileForm extends GetView<StaffProfileController> {
  const StaffProfileForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          if (kDebugMode) const _DebugDataSection(),
          const _PersonalSection(),
          const _ContactSection(),
          const _EmploymentSection(),
          const _LoginSection(),
          const _PermissionsSection(),
        ],
      ),
    );
  }
}

class _DebugDataSection extends GetView<StaffProfileController> {
  const _DebugDataSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: controller.fillDebugData,
          icon: const Icon(Icons.science_outlined),
          label: const Text('Fill Test Staff Data'),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}

class _PersonalSection extends GetView<StaffProfileController> {
  const _PersonalSection();

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'Personal',
      icon: Icons.person_outline,
      child: ResponsiveFormGrid(
        children: [
          AppTextField(
            controller: controller.fullNameController,
            label: 'Full Name',
            hint: 'Full name',
            prefixIcon: Icons.badge_outlined,
            textCapitalization: TextCapitalization.words,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
          ),
          AppTextField(
            controller: controller.employeeIdController,
            label: 'Employee ID (Auto)',
            prefixIcon: Icons.tag,
            readOnly: true,
            enabled: false,
          ),
          AppDocumentField(
            label: 'Profile Photo',
            fileName: controller.profilePhoto,
            onPick: controller.pickProfilePhoto,
          ),
          Obx(
            () => AppDropdownField<String>(
              label: 'Gender',
              value: controller.gender.value,
              prefixIcon: Icons.wc_outlined,
              items: controller.genders
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => controller.gender.value = v,
              validator: (v) => v == null ? 'Select gender' : null,
            ),
          ),
          AppTextField(
            controller: controller.dobController,
            label: 'DOB',
            hint: 'Select date of birth',
            prefixIcon: Icons.calendar_month_outlined,
            readOnly: true,
            onTap: () => controller.pickDateOfBirth(context),
            suffixIcon: const Icon(Icons.arrow_drop_down),
            validator: (_) => controller.dateOfBirth.value == null
                ? 'DOB is required'
                : null,
          ),
        ],
      ),
    );
  }
}

class _ContactSection extends GetView<StaffProfileController> {
  const _ContactSection();

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'Contact',
      icon: Icons.contact_phone_outlined,
      child: ResponsiveFormGrid(
        children: [
          Obx(
            () => AppTextField(
              controller: controller.mobileController,
              label: 'Mobile',
              hint: '10-digit mobile number',
              prefixIcon: Icons.phone_android_outlined,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              suffixIcon: controller.mobileVerified.value
                  ? Icon(
                      Icons.verified,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Mobile is required';
                }
                if (v.trim().length != 10) {
                  return 'Enter a valid 10-digit number';
                }
                return null;
              },
            ),
          ),
          AppTextField(
            controller: controller.emailController,
            label: 'Email',
            hint: 'email@example.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              final email = v?.trim() ?? '';
              if (email.isEmpty) return 'Email is required';
              if (!GetUtils.isEmail(email)) return 'Enter a valid email';
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _EmploymentSection extends GetView<StaffProfileController> {
  const _EmploymentSection();

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'Employment',
      icon: Icons.work_outline,
      child: ResponsiveFormGrid(
        children: [
          AppTextField(
            controller: controller.departmentController,
            label: 'Department',
            hint: 'Department',
            prefixIcon: Icons.apartment_outlined,
            textCapitalization: TextCapitalization.words,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Department is required'
                : null,
          ),
          AppTextField(
            controller: controller.designationController,
            label: 'Designation',
            hint: 'Designation',
            prefixIcon: Icons.badge_outlined,
            textCapitalization: TextCapitalization.words,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Designation is required'
                : null,
          ),
          AppTextField(
            controller: controller.reportingManagerController,
            label: 'Reporting Manager',
            hint: 'Manager name (optional)',
            prefixIcon: Icons.supervisor_account_outlined,
            textCapitalization: TextCapitalization.words,
          ),
          AppTextField(
            controller: controller.joiningDateController,
            label: 'Date of Joining',
            hint: 'Select joining date',
            prefixIcon: Icons.event_available_outlined,
            readOnly: true,
            onTap: () => controller.pickJoiningDate(context),
            suffixIcon: const Icon(Icons.arrow_drop_down),
            validator: (_) => controller.dateOfJoining.value == null
                ? 'Date of joining is required'
                : null,
          ),
        ],
      ),
    );
  }
}

class _LoginSection extends GetView<StaffProfileController> {
  const _LoginSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormSectionCard(
      title: 'Login',
      icon: Icons.lock_outline,
      child: Column(
        children: [
          ResponsiveFormGrid(
            children: [
              AppTextField(
                controller: controller.usernameController,
                label: 'Username',
                hint: 'Username (optional)',
                prefixIcon: Icons.person_outline,
              ),
              Obx(
                () => AppTextField(
                  controller: controller.passwordController,
                  label: 'Password',
                  hint: 'Password (optional)',
                  prefixIcon: Icons.lock_outline,
                  obscureText: controller.obscurePassword.value,
                  suffixIcon: IconButton(
                    onPressed: controller.togglePasswordVisibility,
                    icon: Icon(
                      controller.obscurePassword.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
            () => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Two Factor Authentication',
                style: theme.textTheme.bodyLarge,
              ),
              value: controller.twoFactorEnabled.value,
              onChanged: (v) => controller.twoFactorEnabled.value = v,
              activeThumbColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionsSection extends GetView<StaffProfileController> {
  const _PermissionsSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormSectionCard(
      title: 'Permissions',
      icon: Icons.admin_panel_settings_outlined,
      child: Column(
        children: [
          _PermissionTile(
            label: 'View Clients',
            value: controller.viewClients,
            theme: theme,
          ),
          _PermissionTile(
            label: 'Add Clients',
            value: controller.addClients,
            theme: theme,
          ),
          _PermissionTile(
            label: 'Capture Fingerprints',
            value: controller.captureFingerprints,
            theme: theme,
          ),
          _PermissionTile(
            label: 'Upload Reports',
            value: controller.uploadReports,
            theme: theme,
          ),
          _PermissionTile(
            label: 'Download Reports',
            value: controller.downloadReports,
            theme: theme,
          ),
          _PermissionTile(
            label: 'Manage Staff',
            value: controller.manageStaff,
            theme: theme,
          ),
          _PermissionTile(
            label: 'View Analytics',
            value: controller.viewAnalytics,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final RxBool value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: theme.textTheme.bodyLarge),
        value: value.value,
        onChanged: (v) => value.value = v ?? false,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: theme.colorScheme.primary,
      ),
    );
  }
}
