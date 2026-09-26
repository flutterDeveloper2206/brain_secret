import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/app_document_field.dart';
import '../../../../core/widgets/app_searchable_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/form_section_card.dart';
import '../../../../core/widgets/responsive_form_grid.dart';
import '../../controllers/franchise_profile_controller.dart';

class FranchiseProfileForm extends GetView<FranchiseProfileController> {
  const FranchiseProfileForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          if (kDebugMode) const _DebugDataSection(),
          const _BusinessDetailsSection(),
          const _ContactSection(),
          const _AddressSection(),
          const _BankingSection(),
          const _DocumentsSection(),
          const _StatusSection(),
        ],
      ),
    );
  }
}

class _DebugDataSection extends GetView<FranchiseProfileController> {
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
          label: const Text('Fill Test Franchise Data'),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}

class _BusinessDetailsSection extends GetView<FranchiseProfileController> {
  const _BusinessDetailsSection();

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'Business Details',
      icon: Icons.storefront_outlined,
      child: ResponsiveFormGrid(
        children: [
          AppTextField(
            controller: controller.franchiseCodeController,
            label: 'Franchise Code',
            prefixIcon: Icons.tag,
            readOnly: true,
            enabled: false,
          ),
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
                  v == null ? 'Company is required' : null,
            ),
          ),
          AppTextField(
            controller: controller.franchiseNameController,
            label: 'Franchise Name',
            hint: 'Franchise name',
            prefixIcon: Icons.business_outlined,
            textCapitalization: TextCapitalization.words,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Franchise name is required'
                : null,
          ),
          AppTextField(
            controller: controller.ownerNameController,
            label: 'Owner Name',
            hint: 'Owner name',
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Owner name is required'
                : null,
          ),
          AppTextField(
            controller: controller.gstNumberController,
            label: 'GST Number',
            hint: 'GSTIN',
            prefixIcon: Icons.receipt_long_outlined,
            textCapitalization: TextCapitalization.characters,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'GST number is required'
                : null,
          ),
        ],
      ),
    );
  }
}

class _ContactSection extends GetView<FranchiseProfileController> {
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
          AppTextField(
            controller: controller.websiteController,
            label: 'Website',
            hint: 'https://',
            prefixIcon: Icons.language_outlined,
            keyboardType: TextInputType.url,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Website is required' : null,
          ),
        ],
      ),
    );
  }
}

class _AddressSection extends GetView<FranchiseProfileController> {
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
            controller: controller.pinController,
            label: 'PIN Code',
            hint: '6-digit PIN',
            prefixIcon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'PIN is required';
              if (v.trim().length != 6) return 'Enter a valid 6-digit PIN';
              return null;
            },
          ),
          AppTextField(
            controller: controller.addressController,
            label: 'Full Address',
            hint: 'Full address',
            prefixIcon: Icons.home_outlined,
            maxLines: 2,
            minLines: 1,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Full address is required'
                : null,
          ),
        ],
      ),
    );
  }
}

class _BankingSection extends GetView<FranchiseProfileController> {
  const _BankingSection();

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'Banking',
      icon: Icons.account_balance_outlined,
      child: ResponsiveFormGrid(
        children: [
          AppTextField(
            controller: controller.bankNameController,
            label: 'Bank Name',
            hint: 'Bank name',
            prefixIcon: Icons.account_balance,
            textCapitalization: TextCapitalization.words,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Bank name is required'
                : null,
          ),
          AppTextField(
            controller: controller.accountHolderController,
            label: 'Account Holder',
            hint: 'Account holder name',
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Account holder is required'
                : null,
          ),
          AppTextField(
            controller: controller.accountNumberController,
            label: 'Account Number',
            hint: 'Account number',
            prefixIcon: Icons.numbers,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Account number is required'
                : null,
          ),
          AppTextField(
            controller: controller.ifscController,
            label: 'IFSC',
            hint: 'IFSC code',
            prefixIcon: Icons.qr_code_outlined,
            textCapitalization: TextCapitalization.characters,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'IFSC is required' : null,
          ),
        ],
      ),
    );
  }
}

class _DocumentsSection extends GetView<FranchiseProfileController> {
  const _DocumentsSection();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final editing = controller.isEditMode.value;
      return FormSectionCard(
        title: 'Documents',
        subtitle: editing
            ? 'Upload a new PAN only if you want to replace it'
            : 'PAN card is required',
        icon: Icons.folder_outlined,
        child: ResponsiveFormGrid(
          children: [
            AppDocumentField(
              label: editing ? 'PAN Card (optional)' : 'PAN Card',
              fileName: controller.panDocName,
              onPick: controller.pickPanDocument,
            ),
          ],
        ),
      );
    });
  }
}

class _StatusSection extends GetView<FranchiseProfileController> {
  const _StatusSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FormSectionCard(
      title: 'Status',
      icon: Icons.toggle_on_outlined,
      child: Obx(
        () => Material(
          color: theme.colorScheme.surface.withValues(alpha: 0.42),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.22),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: SwitchListTile.adaptive(
            value: controller.isActive.value,
            onChanged: (value) => controller.isActive.value = value,
            secondary: Icon(
              Icons.check_circle_outline,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Active'),
            subtitle: Text(controller.isActive.value ? 'Yes' : 'No'),
            activeTrackColor: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
