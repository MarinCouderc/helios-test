import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.gender,
    required this.name,
    required this.email,
    required this.phone,
    required this.id,
    required this.picture,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      gender: json['gender'] as String,
      name: NameModel.fromJson(json['name'] as Map<String, dynamic>),
      email: json['email'] as String,
      phone: json['phone'] as String,
      id: IdModel.fromJson(json['id'] as Map<String, dynamic>),
      picture: PictureModel.fromJson(json['picture'] as Map<String, dynamic>),
    );
  }
  final String gender;
  final NameModel name;
  final String email;
  final String phone;
  final IdModel id;
  final PictureModel picture;

  @override
  List<Object?> get props => [
    gender,
    name,
    email,
    phone,
    id,
    picture,
  ];
}

class NameModel extends Equatable {
  const NameModel({
    required this.title,
    required this.first,
    required this.last,
  });

  factory NameModel.fromJson(Map<String, dynamic> json) {
    return NameModel(
      title: json['title'] as String,
      first: json['first'] as String,
      last: json['last'] as String,
    );
  }
  final String title;
  final String first;
  final String last;

  @override
  List<Object?> get props => [title, first, last];
}

class IdModel extends Equatable {
  const IdModel({required this.name, this.value});

  factory IdModel.fromJson(Map<String, dynamic> json) {
    return IdModel(
      name: json['name'] as String,
      value: json['value'] as String?,
    );
  }
  final String name;
  final String? value;

  @override
  List<Object?> get props => [name, value];
}

class PictureModel extends Equatable {
  const PictureModel({
    required this.large,
    required this.medium,
    required this.thumbnail,
  });

  factory PictureModel.fromJson(Map<String, dynamic> json) {
    return PictureModel(
      large: json['large'] as String,
      medium: json['medium'] as String,
      thumbnail: json['thumbnail'] as String,
    );
  }
  final String large;
  final String medium;
  final String thumbnail;

  @override
  List<Object?> get props => [large, medium, thumbnail];
}