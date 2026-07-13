import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'main_layout_state.dart';

@injectable
class MainLayoutCubit extends Cubit<MainLayoutState> {
  MainLayoutCubit() : super(const MainLayoutState());

  void changeTab(int index, {dynamic extra}) {
    emit(state.copyWith(currentIndex: index, extra: extra));
  }
}
