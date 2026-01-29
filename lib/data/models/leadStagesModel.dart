// ignore_for_file: file_names

class LeadStageRequest {
  final String lastStageDateUpdated;
  final String stage;
  final String stageDateUpdated;
  final String? unitNumber;
  final String? unitPrice;
  final String? commissionRatio;
  final String? commissionMoney;
  final String? cashbackRatio;
  final String? cashbackMoney;
  final num? eoi;
  final num? reservation;

  LeadStageRequest({
    required this.lastStageDateUpdated,
    required this.stage,
    required this.stageDateUpdated,
    this.unitNumber,
    this.unitPrice,
    this.commissionRatio,
    this.commissionMoney,
    this.cashbackRatio,
    this.cashbackMoney,
    this.eoi,
    this.reservation,
  });

  Map<String, dynamic> toJson() => {
        "last_stage_date_updated": lastStageDateUpdated,
        "stage": stage,
        "stagedateupdated": stageDateUpdated,
        "unit_price": unitPrice,
        "unitnumber": unitNumber,
        "review": false,
        "commissionratio": commissionRatio,
        "commissionmoney": commissionMoney,
        "cashbackratio": cashbackRatio,
        "cashbackmoney": cashbackMoney,
        "Reservation": reservation,
        "Eoi": eoi,
      };
}
