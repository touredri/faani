class OrderFormDraft {
  const OrderFormDraft({
    required this.modeleId,
    required this.tailleurId,
    required this.photoPath,
    required this.mesureId,
    required this.expectedDate,
    required this.clientName,
    required this.clientPhone,
    required this.price,
  });

  final String modeleId;
  final String tailleurId;
  final String photoPath;
  final String mesureId;
  final String expectedDate;
  final String clientName;
  final String clientPhone;
  final String price;

  Map<String, String> toJson() => {
        'modeleId': modeleId,
        'tailleurId': tailleurId,
        'photoPath': photoPath,
        'mesureId': mesureId,
        'expectedDate': expectedDate,
        'clientName': clientName,
        'clientPhone': clientPhone,
        'price': price,
      };

  factory OrderFormDraft.fromJson(Map<String, dynamic> json) {
    return OrderFormDraft(
      modeleId: json['modeleId']?.toString() ?? '',
      tailleurId: json['tailleurId']?.toString() ?? '',
      photoPath: json['photoPath']?.toString() ?? '',
      mesureId: json['mesureId']?.toString() ?? '',
      expectedDate: json['expectedDate']?.toString() ?? '',
      clientName: json['clientName']?.toString() ?? '',
      clientPhone: json['clientPhone']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
    );
  }
}
