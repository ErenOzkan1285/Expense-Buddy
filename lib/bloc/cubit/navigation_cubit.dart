import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'navigation_state.dart';

enum AppScreen { home, barChart, wallet, profile }

class NavigationCubit extends Cubit<AppScreen> {
  NavigationCubit() : super(AppScreen.home);

  void navigateTo(AppScreen screen) {
    emit(screen);
  }
}
