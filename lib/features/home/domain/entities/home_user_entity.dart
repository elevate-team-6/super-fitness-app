import 'package:equatable/equatable.dart';

class HomeUserEntity extends Equatable {
  final String name;
  final String? image;

  const HomeUserEntity({required this.name, this.image});

  static const HomeUserEntity empty = HomeUserEntity(
    name: 'Athlete', // More general for a gym app
    image: null,
  );

  @override
  List<Object?> get props => [name, image];
}
