import 'package:bloc/bloc.dart';

import '../utils/logger.dart';

/// Quan sát vòng đời của mọi Bloc/Cubit để hỗ trợ debug.
///
/// Đăng ký trong bootstrap: `Bloc.observer = const AppBlocObserver();`
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    AppLogger.d('${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLogger.e('${bloc.runtimeType}', error, stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
