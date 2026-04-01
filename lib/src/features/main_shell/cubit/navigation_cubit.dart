import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0);

  void switchTab(int index) => emit(index);

  void goToDashboard() => emit(0);
  void goToRoutes() => emit(1);
  void goToProfile() => emit(2);
}
