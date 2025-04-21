class ToiletData {
  final String lokasi;
  final String toiletNumber;
  final String status;

  ToiletData({
    required this.lokasi,
    required this.toiletNumber,
    required this.status,
  });

  factory ToiletData.fromFirestore(Map<String, dynamic> json) {
    return ToiletData(
      lokasi: json['lokasi'],
      toiletNumber: json['nomor'],
      status: json['status'],
    );
  }
}
