class MetalPrice {
  String metalName;
  String karat18;
  String karat14;
  String karat24;
  String karat22;

  MetalPrice({
    required this.metalName,
    required this.karat18,
    required this.karat14,
    required this.karat24,
    required this.karat22,
  });

  factory MetalPrice.fromJson(Map<String, dynamic> json) {
    return MetalPrice(
      metalName: json['metalName'],
      karat18: json['18K:'].toString(),
      karat14: json['14K:'].toString(),
      karat24: json['24K:'].toString(),
      karat22: json['22K:'].toString(),
    );
  }
}
