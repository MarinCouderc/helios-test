import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:helios/app/user-list/model/user.dart';

class UserListCubit extends Cubit<List<UserModel>?> {
  UserListCubit({Dio? dio})
      : _dio = dio ?? Dio(),
        super(null);

  static String api = 'https://randomuser.me/api/';
  static int pageSize = 20;

  final Dio _dio;

  Future<void> getUsers(int page) async {
    final users = await _fetchUsers(page);
    emit(users);
  }

  Future<List<UserModel>?> _fetchUsers(int page) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(api, queryParameters: {
        'page': page,
        'results': pageSize,
      });

      final usersJson = response.data?['results'] as List<dynamic>;
      final users = usersJson.map((json) {
        return UserModel.fromJson(json as Map<String, dynamic>);
      }).toList();

      return users;
    } on DioException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      // todo later: snackbar
    }

    return null;
  }
}