class CompanyData {
  final String id;
  final String? privacy;
  final String? kodeAkses;

  CompanyData({
    required this.id,
    required this.privacy,
    required this.kodeAkses,
  });

  factory CompanyData.fromFirestore(
    String id,
    String? privacy,
    String? kodeAkses,
  ) {
    return CompanyData(
      id: id,
      privacy: privacy ?? 'public',
      kodeAkses: kodeAkses,
    );
  }
}
