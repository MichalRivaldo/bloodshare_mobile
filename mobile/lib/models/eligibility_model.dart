class EligibilityModel {
  final bool isEligible;
  final String? lastDonorAt;
  final String? nextEligibleAt;
  final int daysRemaining;
  final String message;

  const EligibilityModel({
    required this.isEligible,
    this.lastDonorAt,
    this.nextEligibleAt,
    required this.daysRemaining,
    required this.message,
  });

  factory EligibilityModel.fromJson(Map<String, dynamic> json) => EligibilityModel(
    isEligible:    json['isEligible'] as bool? ?? false,
    lastDonorAt:   json['lastDonorAt'] as String?,
    nextEligibleAt:json['nextEligibleAt'] as String?,
    daysRemaining: (json['daysRemaining'] as num?)?.toInt() ?? 0,
    message:       json['message'] as String? ?? '',
  );
}
