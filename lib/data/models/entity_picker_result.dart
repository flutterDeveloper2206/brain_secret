class EntityPickerResult {
  const EntityPickerResult({
    required this.companyId,
    required this.companyName,
    required this.franchiseId,
    required this.franchiseName,
    required this.customerId,
    required this.customerName,
    required this.familyId,
    required this.familyName,
  });

  final int companyId;
  final String companyName;
  final int franchiseId;
  final String franchiseName;
  final int customerId;
  final String customerName;
  final int familyId;
  final String familyName;
}
