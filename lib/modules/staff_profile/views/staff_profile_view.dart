import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/profile_form_scaffold.dart';
import '../controllers/staff_profile_controller.dart';
import 'widgets/staff_profile_form.dart';

class StaffProfileView extends GetView<StaffProfileController> {
  const StaffProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      }

      return ProfileFormScaffold(
        title: controller.screenTitle,
        saveLabel: controller.saveLabel,
        form: const StaffProfileForm(),
        isSaving: controller.isSaving,
        onSave: controller.saveProfile,
      );
    });
  }
}
