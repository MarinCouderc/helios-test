import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helios/app/user-list/cubit/user_list_cubit.dart';
import 'package:helios/app/user-list/model/user.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late UserListCubit userListCubit;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://randomuser.me/api/'));
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockDio = MockDio();
    userListCubit = UserListCubit(dio: mockDio);
  });

  tearDown(() {
    userListCubit.close();
  });

  group('UserListCubit', () {
    test('initial state is null', () {
      expect(userListCubit.state, isNull);
    });

    final mockUserJson = {
      'gender': 'male',
      'name': {'title': 'Mr', 'first': 'John', 'last': 'Doe'},
      'email': 'john.doe@example.com',
      'phone': '123-456-7890',
      'id': {'name': 'ID', 'value': '12345'},
      'picture': {
        'large': 'large.jpg',
        'medium': 'medium.jpg',
        'thumbnail': 'thumbnail.jpg'
      },
    };

    final mockResponseData = {
      'results': [mockUserJson],
      'info': {'page': 1}
    };

    final expectedUserList = [UserModel.fromJson(mockUserJson)];
    final tDioException = DioException(requestOptions: RequestOptions(path: ''));

    group('getUsers success', () {
      setUp(() {
        when(() => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer(
              (_) async => Response(
            requestOptions: RequestOptions(),
            data: mockResponseData,
            statusCode: 200,
          ),
        );
      });

      blocTest<UserListCubit, List<UserModel>?>(
        'emits a list of UserModel when getUsers is called successfully',
        build: () => userListCubit,
        act: (cubit) => cubit.getUsers(1),
        expect: () => [
          expectedUserList,
        ],
        verify: (_) {
          verify(() => mockDio.get<Map<String, dynamic>>(
            UserListCubit.api,
            queryParameters: {
              'page': 1,
              'results': UserListCubit.pageSize,
            },
          )).called(1);
        },
      );
    });

    group('getUsers failure', () {
      setUp(() {
        when(() => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        )).thenThrow(tDioException);
      });

      blocTest<UserListCubit, List<UserModel>?>(
        'emits null when DioException occurs',
        build: () => userListCubit,
        act: (cubit) => cubit.getUsers(1),
        expect: () => [
          isNull,
        ],
        verify: (_) {
          verify(() => mockDio.get<Map<String, dynamic>>(any(),
              queryParameters: any(named: 'queryParameters'))).called(1);
        },
      );
    });
  });
}
