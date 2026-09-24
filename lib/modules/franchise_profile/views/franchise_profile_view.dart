import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/profile_form_scaffold.dart';
import '../controllers/franchise_profile_controller.dart';
import 'widgets/franchise_profile_form.dart';

class FranchiseProfileView extends GetView<FranchiseProfileController> {
  const FranchiseProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final editing = controller.isEditMode.value;
      if (controller.isLoading.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      return ProfileFormScaffold(
        title: editing ? 'Edit Franchise' : 'Create Franchise',
        saveLabel: editing ? 'Update Franchise' : 'Create Franchise',
        form: const FranchiseProfileForm(),
        isSaving: controller.isSaving,
        onSave: controller.saveProfile,
      );
    });
  }
}
