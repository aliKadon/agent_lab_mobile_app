
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:logger/logger.dart';

import '../services/api_constants.dart';
import '../services/datasource/local_datasource/local_datasource_impl.dart';
import '../services/datasource/remote_datasource/remote_datasource_impl.dart';
import '../services/local_storage/key_value_storage_service.dart';
import '../services/repository/repository_impl.dart';
import '../utils/constants/constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final _dio = Dio();
  _dio.interceptors.add(LogInterceptor(
    request: true,
    requestBody: true,
    responseBody: true,
    responseHeader: false,
    error: true,
    logPrint: (log) => print(log), // Optional: for better formatting
  ));

  // _dio.interceptors.add(QueuedInterceptorsWrapper(
  //   onError: (error, handler) {
  //     final isUnauthorized = error.response?.statusCode == 401;
  //
  //     if (isUnauthorized) {
  //       throw RefreshTokenExpiredFailure;
  //       // return handler.reject(error);
  //     }
  //     return handler.next(error);
  //   },
  // ));

  return _dio;
});

final baseUrlProvider = Provider<BaseUrl>((ref) {
  return BaseUrl(
    hostUrlDev: Constants.devBaseUrl,
    // hostUrlDev: Constants.baseUrl,
    hostUrl: Constants.baseUrl,
  );
});

final remoteDataSourceProvider = Provider<RemoteDataSourceImp>((ref) {
  return RemoteDataSourceImp(
    dio: ref.watch(dioProvider),
    log: ref.watch(loggerProvider),
    baseUrl: ref.watch(baseUrlProvider),
  );
});

final loggerProvider = Provider<Logger>((ref) {
  Logger logger = Logger();
  return logger;
});

final keyValueStorageServiceProvider = Provider<KeyValueStorageService>(
  (ref) => KeyValueStorageService(),
);

final localDataSourceProvider = Provider<LocalDataSourceImp>((ref) {
  final keyValueStorageProvider = ref.watch(keyValueStorageServiceProvider);
  return LocalDataSourceImp(keyValueStorageService: keyValueStorageProvider);
});

final repositoryProvider = Provider<RepositoryImpl>((ref) {
  final remoteDataSource = ref.watch(remoteDataSourceProvider);
  final localDataSource = ref.watch(localDataSourceProvider);
  final logger = ref.watch(loggerProvider);

  return RepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    log: logger,
  );
});


final bottomSheetStateProvider = StateProvider<bool>((ref) => false);
final knowledgeBottomSheetStateProvider = StateProvider<bool>((ref) => false);