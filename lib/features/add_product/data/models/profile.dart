
class User {
  final String? phoneNumber;
  final String? name;
  final String? email;
  final String? address;
  final String? pincode;
  final String? gender;
  final String? dateOfBirth;
  final String? spouseDateOfBirth;
  final String? anniversary;

  User({
    this.phoneNumber,
    this.name,
    this.email,
    this.address,
    this.pincode,
    this.gender,
    this.dateOfBirth,
    this.spouseDateOfBirth,
    this.anniversary,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      phoneNumber: json['phoneNumber'],
      name: json['name'],
      email: json['email'],
      address: json['address'],
      pincode: json['pincode'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      spouseDateOfBirth: json['spouseDateOfBirth'],
      anniversary: json['anniversary'],
    );
  }
}
