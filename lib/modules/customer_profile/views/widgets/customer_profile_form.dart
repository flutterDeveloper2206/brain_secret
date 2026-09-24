import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/form_section_card.dart';
import '../../../../core/widgets/responsive_form_grid.dart';
import '../../../../data/models/franchise_dropdown.dart';
import '../../controllers/customer_profile_controller.dart';

class CustomerProfileForm extends GetView<CustomerProfileController> {
  const CustomerProfileForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          if (kDebugMode) const _DebugDataSection(),
          const _BasicInformationSection(),
          const _AddressSection(),
          const _PersonalInformationSection(),
          const _FamilySection(),
          const _MedicalSection(),
          const _BrainSecretsSection(),
        ],
      ),
    );
  }
}

class _DebugDataSection extends GetView<CustomerProfileController> {
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
          label: const Text('Fill Test Customer Data'),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}

class _BasicInformationSection extends GetView<CustomerProfileController> {
  const _BasicInformationSection();

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'Basic Information',
      icon: Icons.person_outline,
      child: ResponsiveFormGrid(
        children: [
          AppTextField(
            controller: controller.customerIdController,
            label: 'Customer ID',
            prefixIcon: Icons.tag,
            readOnly: true,
            enabled: false,
          ),
          AppTextField(
            controller: controller.fullNameController,
            label: 'Full Name',
            hint: 'Enter full name',
            prefixIcon: Icons.badge_outlined,
            textCapitalization: TextCapitalization.words,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Full name is required'
                : null,
          ),
          Obx(
            () => AppTextField(
              controller: controller.mobileController,
              label: 'Mobile Number (OTP Verified)',
              hint: '10-digit mobile number',
              prefixIcon: Icons.phone_android_outlined,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              onChanged: (_) => controller.mobileVerified.value =
                  controller.mobileController.text.trim().length == 10,
              suffixIcon: controller.mobileVerified.value
                  ? Icon(
                      Icons.verified,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Mobile number is required';
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
            label: 'Email Address',
            hint: 'you@example.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              final email = v?.trim() ?? '';
              if (email.isEmpty) return 'Email is required';
              if (!GetUtils.isEmail(email)) return 'Enter a valid email';
              return null;
            },
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
            controller: controller.dateOfBirthController,
            label: 'Date of Birth',
            hint: 'Select date of birth',
            prefixIcon: Icons.calendar_month_outlined,
            readOnly: true,
            onTap: () => controller.pickDateOfBirth(context),
            suffixIcon: const Icon(Icons.arrow_drop_down),
            validator: (_) => controller.dateOfBirth.value == null
                ? 'Date of birth is required'
                : null,
          ),
          AppTextField(
            controller: controller.photoUrlController,
            label: 'Photo URL',
            hint: 'https://example.com/photo.jpg',
            prefixIcon: Icons.image_outlined,
            keyboardType: TextInputType.url,
          ),
          AppTextField(
            controller: controller.ageController,
            label: 'Age (Auto calculated)',
            hint: 'Auto',
            prefixIcon: Icons.cake_outlined,
            readOnly: true,
            enabled: false,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Age is required' : null,
          ),
        ],
      ),
    );
  }
}

class _AddressSection extends GetView<CustomerProfileController> {
  const _AddressSection();

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'Address',
      icon: Icons.location_on_outlined,
      child: ResponsiveFormGrid(
        children: [
          AppTextField(
            controller: controller.countryController,
            label: 'Country',
            hint: 'Country',
            prefixIcon: Icons.public_outlined,
            textCapitalization: TextCapitalization.words,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Country is required' : null,
          ),
          AppTextField(
            controller: controller.stateController,
            label: 'State',
            hint: 'State',
            prefixIcon: Icons.map_outlined,
            textCapitalization: TextCapitalization.words,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'State is required' : null,
          ),
          AppTextField(
            controller: controller.cityController,
            label: 'City',
            hint: 'City',
            prefixIcon: Icons.location_city_outlined,
            textCapitalization: TextCapitalization.words,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'City is required' : null,
          ),
          AppTextField(
            controller: controller.pinCodeController,
            label: 'PIN Code',
            hint: '6-digit PIN',
            prefixIcon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'PIN code is required';
              if (v.trim().length != 6) return 'Enter a valid 6-digit PIN';
              return null;
            },
          ),
          AppTextField(
            controller: controller.fullAddressController,
            label: 'Full Address',
            hint: 'Street, landmark, etc.',
            prefixIcon: Icons.home_outlined,
            maxLines: 3,
            minLines: 2,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Full address is required'
                : null,
          ),
        ],
      ),
    );
  }
}

class _PersonalInformationSection extends GetView<CustomerProfileController> {
  const _PersonalInformationSection();

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'Personal Information',
      icon: Icons.work_outline,
      child: ResponsiveFormGrid(
        children: [
          AppTextField(
            controller: controller.occupationController,
            label: 'Occupation',
            hint: 'Your occupation',
            prefixIcon: Icons.work_outline,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Occupation is required'
                : null,
          ),
          AppTextField(
            controller: controller.companyController,
            label: 'Organization',
            hint: 'Organization name',
            prefixIcon: Icons.business_outlined,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Organization is required'
                : null,
          ),
          AppTextField(
            controller: controller.educationController,
            label: 'Education',
            hint: 'Highest education',
            prefixIcon: Icons.school_outlined,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Education is required'
                : null,
          ),
          Obx(
            () => AppDropdownField<String>(
              label: 'Marital Status',
              value: controller.maritalStatus.value,
              prefixIcon: Icons.favorite_border,
              items: controller.maritalStatuses
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => controller.maritalStatus.value = v,
              validator: (v) => v == null ? 'Select marital status' : null,
            ),
          ),
          Obx(
            () => AppDropdownField<String>(
              label: 'Preferred Language',
              value: controller.preferredLanguage.value,
              prefixIcon: Icons.translate_outlined,
              items: controller.languages
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => controller.preferredLanguage.value = v,
              validator: (v) => v == null ? 'Select preferred language' : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _FamilySection extends GetView<CustomerProfileController> {
  const _FamilySection();

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'Family',
      icon: Icons.family_restroom_outlined,
      child: ResponsiveFormGrid(
        children: [
          AppTextField(
            controller: controller.fatherNameController,
            label: "Father's Name",
            hint: "Father's name",
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? "Father's name is required"
                : null,
          ),
          AppTextField(
            controller: controller.motherNameController,
            label: "Mother's Name",
            hint: "Mother's name",
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? "Mother's name is required"
                : null,
          ),
          AppTextField(
            controller: controller.spouseNameController,
            label: 'Spouse Name',
            hint: 'Spouse name',
            prefixIcon: Icons.people_outline,
            textCapitalization: TextCapitalization.words,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Spouse name is required'
                : null,
          ),
          AppTextField(
            controller: controller.emergencyContactController,
            label: 'Emergency Contact',
            hint: 'Emergency contact number',
            prefixIcon: Icons.contact_phone_outlined,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Emergency contact is required';
              }
              if (v.trim().length != 10) {
                return 'Enter a valid 10-digit number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _MedicalSection extends GetView<CustomerProfileController> {
  const _MedicalSection();

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'Medical',
      icon: Icons.medical_services_outlined,
      child: ResponsiveFormGrid(
        children: [
          Obx(
            () => _ToggleField(
              title: 'Any Medical Issue',
              subtitle: controller.hasMedicalIssue.value ? 'Yes' : 'No',
              icon: Icons.health_and_safety_outlined,
              value: controller.hasMedicalIssue.value,
              onChanged: (value) => controller.hasMedicalIssue.value = value,
            ),
          ),
          Obx(
            () => _ToggleField(
              title: 'Any Psychological Issue',
              subtitle: controller.hasPsychologicalIssue.value ? 'Yes' : 'No',
              icon: Icons.psychology_outlined,
              value: controller.hasPsychologicalIssue.value,
              onChanged: (value) =>
                  controller.hasPsychologicalIssue.value = value,
            ),
          ),
          Obx(
            () => _ToggleField(
              title: 'Hand Dominance',
              subtitle: controller.isRightHandDominant.value
                  ? 'Right hand'
                  : 'Left hand',
              icon: Icons.back_hand_outlined,
              value: controller.isRightHandDominant.value,
              onChanged: (value) =>
                  controller.isRightHandDominant.value = value,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrainSecretsSection extends GetView<CustomerProfileController> {
  const _BrainSecretsSection();

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'Company Assignment',
      subtitle: 'Customer company and franchise codes',
      icon: Icons.apartment_outlined,
      child: ResponsiveFormGrid(
        children: [
          AppTextField(
            controller: controller.companyCodeController,
            label: 'Company Code',
            hint: 'Enter company code',
            prefixIcon: Icons.apartment_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Company code is required'
                : null,
          ),
          Obx(() {
            // Valid unique franchise codes only — never use 0 as dropdown value.
            final seen = <int>{};
            final items = <FranchiseDropdownItem>[];
            for (final item in controller.franchiseOptions) {
              if (item.franchiseCode <= 0) continue;
              if (!seen.add(item.franchiseCode)) continue;
              items.add(item);
            }

            final rawCurrent =
                controller.selectedFranchiseCode.value ??
                int.tryParse(controller.franchiseCodeController.text.trim());
            final current =
                (rawCurrent != null && rawCurrent > 0) ? rawCurrent : null;

            if (current != null &&
                !items.any((e) => e.franchiseCode == current)) {
              items.insert(
                0,
                FranchiseDropdownItem(
                  franchiseCode: current,
                  franchiseName: 'Current',
                ),
              );
            }

            if (items.isEmpty) {
              return AppTextField(
                controller: controller.franchiseCodeController,
                label: 'Franchise Code',
                hint: 'Enter franchise code',
                prefixIcon: Icons.storefront_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final code = int.tryParse(v?.trim() ?? '') ?? 0;
                  if (code <= 0) return 'Franchise code is required';
                  return null;
                },
              );
            }

            final resolved = current != null &&
                    items.any((e) => e.franchiseCode == current)
                ? current
                : null;

            return AppDropdownField<int>(
              label: 'Franchise',
              hint: 'Select franchise',
              prefixIcon: Icons.storefront_outlined,
              value: resolved,
              items: [
                for (final item in items)
                  DropdownMenuItem<int>(
                    value: item.franchiseCode,
                    child: Text(
                      item.franchiseName.isEmpty
                          ? '${item.franchiseCode}'
                          : '${item.franchiseCode} · ${item.franchiseName}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: controller.onFranchiseSelected,
              validator: (v) {
                if (v != null && v > 0) return null;
                final typed =
                    int.tryParse(
                      controller.franchiseCodeController.text.trim(),
                    ) ??
                    0;
                if (typed > 0) return null;
                return 'Franchise is required';
              },
            );
          }),
        ],
      ),
    );
  }
}

class _ToggleField extends StatelessWidget {
  const _ToggleField({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.22),
        ),
      ),
      child: SwitchListTile.adaptive(
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        activeTrackColor: theme.colorScheme.primary,
      ),
    );
  }
}
