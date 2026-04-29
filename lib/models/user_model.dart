import 'package:firebase_database/firebase_database.dart';

class UserModel {
  final String? phone;
  final String? name;
  final String? id;
  final String? email;

  UserModel({
    this.phone,
    this.name,
    this.id,
    this.email,
  });

  factory UserModel.fromSnapshot(DataSnapshot snap) {
    final data = snap.value as Map?;
    return UserModel(
      id: snap.key,
      phone: data?['phone'],
      name: data?['name'],
      email: data?['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'name': name,
      'id': id,
      'email': email,
    };
  }
}