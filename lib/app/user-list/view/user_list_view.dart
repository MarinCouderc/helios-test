import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helios/app/user-list/cubit/user_list_cubit.dart';
import 'package:helios/app/user-list/model/user.dart';
import 'package:helios/app/user-list/view/widgets/user_item_widget.dart';
import 'package:helios/l10n/l10n.dart';

class UserListView extends StatelessWidget {
  const UserListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserListCubit()..getUsers(1),
      child: const UserListPage(),
    );
  }
}

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final ScrollController _scrollController = ScrollController();
  final List<UserModel> _allUsers = [];
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && !_isLoadingMore) {
      _loadMoreUsers();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _loadMoreUsers() async {
    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;
    await context.read<UserListCubit>().getUsers(_currentPage);

    setState(() {
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<UserListCubit, List<UserModel>?>(
        builder: (context, users) {
          return RefreshIndicator(
            onRefresh: () async {
              _currentPage = 1;
              _allUsers.clear();
              await context.read<UserListCubit>().getUsers(1);
            },
            child: _buildBody(context, users),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<UserModel>? users) {
    if (users == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_currentPage == 1) {
      _allUsers.clear();
    }

    for (final user in users) {
      if (!_allUsers.any((existingUser) => existingUser.email == user.email)) {
        _allUsers.add(user);
      }
    }

    if (_allUsers.isEmpty) {
      return _buildEmptyWidget();
    }

    return _buildUserList();
  }

  Widget _buildEmptyWidget() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.userListNoUserFound,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.userListRefresh,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _isLoadingMore ? _allUsers.length + 1 : _allUsers.length,
      itemBuilder: (context, index) {
        if (index >= _allUsers.length) {
          return _buildLoadingIndicator();
        }
        return UserItemWidget(user: _allUsers[index]);
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}