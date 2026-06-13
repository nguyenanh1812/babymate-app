import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/router/app_routes.dart';
import '../features/home/presentation/pages/main_shell.dart';

/// Cấu hình điều hướng dùng `go_router`.
///
/// Đặt ở tầng app (không thuộc `core`) vì cần biết các page của feature.
/// Các màn hình phụ (thêm bé, ghi hoạt động...) điều hướng bằng
/// `Navigator.push` do cần tham số; route chính khai báo tại đây.
abstract final class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const MainShell(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Không tìm thấy trang: ${state.uri}')),
    ),
  );
}
