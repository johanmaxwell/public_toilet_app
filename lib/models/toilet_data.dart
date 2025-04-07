class ToiletData {
  final String gedung;
  final String lokasi;
  final String gender;
  final String toiletNumber;
  final String status;

  ToiletData({
    required this.gedung,
    required this.lokasi,
    required this.gender,
    required this.toiletNumber,
    required this.status,
  });

  factory ToiletData.fromFirestore(Map<String, dynamic> json) {
    return ToiletData(
      gedung: json['gedung'],
      lokasi: json['lokasi'],
      gender: json['gender'],
      toiletNumber: json['nomor'],
      status: json['status'],
    );
  }
}
