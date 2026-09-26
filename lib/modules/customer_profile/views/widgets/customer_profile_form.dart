import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_searchable_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/form_section_card.dart';
import '../../../../core/widgets/responsive_form_grid.dart';
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
          const _CompanyAssignmentSection(),
          const _BasicInformationSection(),
          const _AddressSection(),
          const _PersonalInformationSection(),
          const _FamilySection(),
          const _MedicalSection(),
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
    final theme = Theme.of(context);
    return FormSectionCard(
      title: 'Family',
      icon: Icons.family_restroom_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResponsiveFormGrid(
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Family members',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: controller.addFamilyMember,
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('Add family member'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            final members = controller.familyMembers;
            if (members.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'No family members added yet.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (var i = 0; i < members.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _FamilyMemberCard(index: i, item: members[i]),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _FamilyMemberCard extends GetView<CustomerProfileController> {
  const _FamilyMemberCard({required this.index, required this.item});

  final int index;
  final FamilyMemberFormItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.25),
        ),
        color: theme.colorScheme.surface.withValues(alpha: 0.35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Member ${index + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Remove',
                onPressed: () => controller.removeFamilyMember(index),
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          ResponsiveFormGrid(
            children: [
              AppTextField(
                controller: item.fullNameController,
                label: 'Full Name',
                hint: 'Family member name',
                prefixIcon: Icons.badge_outlined,
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Full name is required'
                    : null,
              ),
              AppTextField(
                controller: item.emailController,
                label: 'Email',
                hint: 'Email address',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              AppTextField(
                controller: item.educationController,
                label: 'Education',
                hint: 'Education',
                prefixIcon: Icons.school_outlined,
              ),
              AppTextField(
                controller: item.dateOfBirthController,
                label: 'Date of Birth',
                hint: 'Select date of birth',
                prefixIcon: Icons.cake_outlined,
                readOnly: true,
                onTap: () => controller.pickFamilyMemberDob(context, index),
              ),
              AppTextField(
                controller: item.ageController,
                label: 'Age',
                hint: 'Age',
                prefixIcon: Icons.numbers_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
              ),
              AppTextField(
                controller: item.emergencyContactController,
                label: 'Emergency Contact',
                hint: 'Contact number',
                prefixIcon: Icons.contact_phone_outlined,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),
            ],
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

class _CompanyAssignmentSection extends GetView<CustomerProfileController> {
  const _CompanyAssignmentSection();

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'Company Assignment',
      subtitle: 'Select company, then franchise',
      icon: Icons.apartment_outlined,
      child: ResponsiveFormGrid(
        children: [
          Obx(
            () => AppSearchableDropdownField<int>(
              label: 'Company',
              hint: 'Select company',
              prefixIcon: Icons.apartment_outlined,
              value: controller.selectedCompanyId.value,
              displayLabel: controller.selectedCompanyLabel,
              items: controller.companyDropdownItems,
              isLoading: controller.isLoadingCompanies.value,
              loadItems: controller.loadCompanies,
              searchHint: 'Search company…',
              onChanged: controller.onCompanySelected,
              validator: (v) =>
                  v == null || v <= 0 ? 'Company is required' : null,
            ),
          ),
          Obx(() {
            final hasCompany = controller.selectedCompanyId.value != null;
            return AppSearchableDropdownField<int>(
              label: 'Franchise',
              hint: hasCompany ? 'Select franchise' : 'Select company first',
              prefixIcon: Icons.storefront_outlined,
              value: controller.selectedFranchiseCode.value,
              displayLabel: controller.selectedFranchiseLabel,
              items: controller.franchiseDropdownItems,
              isLoading: controller.isLoadingFranchises.value,
              enabled: hasCompany,
              loadItems: hasCompany ? controller.loadFranchisesSheet : null,
              searchHint: 'Search franchise…',
              emptyMessage: hasCompany
                  ? 'No franchises for this company'
                  : 'Select a company first',
              onChanged: controller.onFranchiseSelected,
              validator: (v) =>
                  v == null || v <= 0 ? 'Franchise is required' : null,
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
    return Material(
      color: theme.colorScheme.surface.withValues(alpha: 0.42),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.22),
        ),
      ),
      clipBehavior: Clip.antiAlias,
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
