import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/profile_form_scaffold.dart';
import '../controllers/customer_profile_controller.dart';
import 'widgets/customer_profile_form.dart';

class CustomerProfileView extends GetView<CustomerProfileController> {
  const CustomerProfileView({super.key});

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
        form: const CustomerProfileForm(),
        isSaving: controller.isSaving,
        onSave: controller.saveProfile,
      );
    });
  }
}
