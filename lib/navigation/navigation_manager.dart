import '../app_states/app_settings.dart';

abstract class INavigationService {
  Future<Object?> navigateToPage<T>({required String path, Object? data});
  Future<T?> navigateToPageClear<T>({required String path, Object? data});
  Future<T?> backToPageClear<T>({required String path, Object? data});
}

class NavigationService implements INavigationService {
  @override
  Future<Object?> navigateToPage<T>({
    required String path,
    Object? data,
  }) async {
    final previousPage = AppSettings.instance.currentPage;
    AppSettings.instance.pageStackCount += 1;
    AppSettings.instance.currentPage = path;

    return AppSettings.instance.navigatorKey.currentState
        ?.pushNamed(path, arguments: data)
        .then((value) {
      AppSettings.instance.currentPage = previousPage;
      AppSettings.instance.pageStackCount -= 1;
      return value;
    });
  }

  @override
  Future<T?> navigateToPageClear<T>({
    required String path,
    Object? data,
  }) async {
    AppSettings.instance.pageStackCount = 1;
    AppSettings.instance.currentPage = path;
    final navigator = AppSettings.instance.navigatorKey.currentState;
    if (navigator == null) return null;

    return navigator.pushNamedAndRemoveUntil<T>(
      path,
      (route) => false,
      arguments: data,
    );
  }

  @override
  Future<T?> backToPageClear<T>({
    required String path,
    Object? data,
  }) async {
    AppSettings.instance.pageStackCount = 1;
    AppSettings.instance.currentPage = path;
    final navigator = AppSettings.instance.navigatorKey.currentState;
    if (navigator == null) return null;

    return navigator.pushNamedAndRemoveUntil<T>(
      path,
      (route) => false,
      arguments: data,
    );
  }

  Future<T?> navigateToPageReplacement<T>({
    required String path,
    Object? data,
  }) async {
    AppSettings.instance.pageStackCount = 1;
    AppSettings.instance.currentPage = path;

    return AppSettings.instance.navigatorKey.currentState
        ?.pushReplacementNamed<T, dynamic>(path, arguments: data);
  }
}
