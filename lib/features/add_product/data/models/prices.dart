class MetalPrice {
 String metalName;
   double karat18;
  double karat14;
  double karat24;
   double karat22;

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
      karat18: double.parse(json['18K:']),
      karat14: double.parse(json['14K:']),
      karat24: double.parse(json['24K:']),
      karat22: double.parse(json['22K:']),
    );
  }
}
