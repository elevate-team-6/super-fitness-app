import 'package:equatable/equatable.dart';

class HomeUserEntity extends Equatable {
  final String name;
  final String? image;

  const HomeUserEntity({
    required this.name,
    this.image,
  });

  static const HomeUserEntity empty = HomeUserEntity(
    name: 'Ahmed', // Default as per requirement
    image: null,
  );

  @override
  List<Object?> get props => [name, image];
}
