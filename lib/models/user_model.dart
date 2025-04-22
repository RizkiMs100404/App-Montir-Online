class UserModel {
  String? uid;
  String? email;
  String? name;
  String? phone;
  String? address;

  UserModel({this.uid, this.email, this.name, this.phone, this.address});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      phone: map['phone'],
      address: map['address'],
    );
  }
}
