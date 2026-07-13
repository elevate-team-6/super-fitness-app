part of 'main_layout_cubit.dart';

class MainLayoutState extends Equatable {
  final int currentIndex;
  final dynamic extra; // For passing data between tabs (e.g., workout category)

  const MainLayoutState({this.currentIndex = 0, this.extra});

  MainLayoutState copyWith({int? currentIndex, dynamic extra}) {
    return MainLayoutState(
      currentIndex: currentIndex ?? this.currentIndex,
      extra: extra ?? this.extra,
    );
  }

  @override
  List<Object?> get props => [currentIndex, extra];
}
