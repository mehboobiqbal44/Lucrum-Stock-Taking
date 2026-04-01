import 'package:flutter/material.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/main_shell/views/main_shell.dart';
import '../../features/checkin/views/checkin_screen.dart';
import '../../features/stock_request/views/stock_request_screen.dart';
import '../../features/stock_request/views/add_item_screen.dart';
import '../../features/stock_take/views/stock_take_screen.dart';
import '../models/route_stop_model.dart';

class AppRouter {
  static const login = '/login';
  static const main = '/main';
  static const routes = '/main';
  static const checkin = '/checkin';
  static const stockRequest = '/stock-request';
  static const addItem = '/stock-request/add-item';
  static const stockTake = '/stock-take';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _buildRoute(const LoginScreen());
      case main:
        return _buildRoute(const MainShell());
      case checkin:
        final stop = settings.arguments as RouteStopModel;
        return _buildRoute(CheckinScreen(stop: stop));
      case stockRequest:
        final stopId = settings.arguments as String;
        return _buildRoute(StockRequestScreen(stopId: stopId));
      case addItem:
        return _buildRoute(const AddItemScreen());
      case stockTake:
        final stopId = settings.arguments as String;
        return _buildRoute(StockTakeScreen(stopId: stopId));
      default:
        return _buildRoute(const LoginScreen());
    }
  }

  static MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}
