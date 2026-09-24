import 'package:get/get.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/widgets/glass_popup.dart';
import '../../../core/widgets/glass_snackbar.dart';
import '../../../data/models/franchise.dart';
import '../../../data/repositories/franchise_repo.dart';
import '../../../routes/app_routes.dart';

class FranchiseDetailsController extends GetxController {
  FranchiseDetailsController({required this.franchiseRepository});

  final FranchiseRepository franchiseRepository;

  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isToggling = false.obs;
  final Rxn<Franchise> franchise = Rxn<Franchise>();

  late final int franchiseCode;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is int) {
      franchiseCode = args;
    } else if (args is Franchise) {
      franchiseCode = args.franchiseCode;
      franchise.value = args;
    } else if (args is Map && args['franchiseCode'] != null) {
      franchiseCode = int.tryParse(args['franchiseCode'].toString()) ?? 0;
    } else {
      franchiseCode = int.tryParse(args?.toString() ?? '') ?? 0;
    }
    loadDetails();
  }

  Future<void> loadDetails() async {
    if (franchiseCode <= 0) {
      ErrorHandler.handleError(ServerException('Invalid franchise code.'));
      return;
    }

    isLoading.value = true;
    try {
      final response = await franchiseRepository.getFranchise(franchiseCode);
      franchise.value = response.franchise;
    } catch (e) {
      ErrorHandler.handleError(e, popOnNotFound: true);
    } finally {
      isLoading.value = false;
    }
  }

  void openEdit() {
    final current = franchise.value;
    if (current == null) return;
    Get.toNamed(
      Routes.franchiseProfile,
      arguments: {'franchiseCode': current.franchiseCode},
    )?.then((result) {
      if (result == true) {
        loadDetails();
      }
    });
  }

  Future<void> toggleActive() async {
    final current = franchise.value;
    if (current == null || isToggling.value) return;

    final nextLabel = current.isActive ? 'Inactive' : 'Active';
    final confirmed = await GlassPopup.confirm(
      title: 'Change Status',
      message:
          'Mark ${current.franchiseName.isEmpty ? 'this franchise' : current.franchiseName} as $nextLabel?',
      confirmText: 'Confirm',
    );
    if (!confirmed) return;

    isToggling.value = true;
    try {
      final response = await franchiseRepository.toggleFranchiseActive(
        current.franchiseCode,
      );
      await loadDetails();
      GlassSnackbar.success(
        response.message.isEmpty
            ? 'Franchise status updated successfully.'
            : response.message,
        title: 'Status Updated',
      );
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      isToggling.value = false;
    }
  }

  Future<void> confirmDelete() async {
    final current = franchise.value;
    if (current == null || isDeleting.value) return;

    final confirmed = await GlassPopup.confirm(
      title: 'Delete Franchise',
      message:
          'Delete ${current.franchiseName.isEmpty ? 'this franchise' : current.franchiseName}?',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;

    isDeleting.value = true;
    try {
      final response = await franchiseRepository.softDeleteFranchise(
        current.franchiseCode,
      );
      // Pop before the snackbar, otherwise Get.back() closes the snackbar route.
      Get.back(result: true);
      Future<void>.delayed(const Duration(milliseconds: 150), () {
        GlassSnackbar.success(
          response.message.isEmpty
              ? 'Franchise deleted successfully.'
              : response.message,
          title: 'Deleted',
        );
      });
    } catch (e) {
      ErrorHandler.handleError(e, popOnNotFound: true);
    } finally {
      isDeleting.value = false;
    }
  }
}
