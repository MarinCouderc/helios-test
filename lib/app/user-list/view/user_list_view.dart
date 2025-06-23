import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helios/app/shared/shared.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  int _currentPage = 1;
  bool _isLoadingMore = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && !_isLoadingMore && _searchQuery.isEmpty) {
      _loadMoreUsers();
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterUsers();
    });
  }

  void _filterUsers() {
    if (_searchQuery.isEmpty) {
      _filteredUsers = List.from(_allUsers);
    } else {
      _filteredUsers = _allUsers.where((user) {
        final fullName = '${user.name.first} ${user.name.last}'.toLowerCase();
        final email = user.email.toLowerCase();
        final phone = user.phone.toLowerCase();
        final gender = user.gender.toLowerCase();

        return fullName.contains(_searchQuery) ||
               email.contains(_searchQuery) ||
               phone.contains(_searchQuery) ||
               gender.contains(_searchQuery);
      }).toList();
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
              _searchController.clear();
              await context.read<UserListCubit>().getUsers(1);
            },
            child: _buildBody(context, users),
          );
        },
      ),
      bottomNavigationBar: const SimpleNavbar(),
    );
  }

  Widget _buildBody(BuildContext context, List<UserModel>? users) {
    if (users == null) {
      return Column(
        children: [
          _buildSearchBar(),
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
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

    _filterUsers();

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: _allUsers.isEmpty
              ? _buildEmptyWidget()
              : _filteredUsers.isEmpty && _searchQuery.isNotEmpty
                  ? _buildNoSearchResultsWidget()
                  : _buildUserList(),
        ),
      ],
    );
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

  Widget _buildSearchBar() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: context.l10n.userListSearchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _searchController.clear,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
        ),
      ),
    );
  }

  Widget _buildUserList() {
    final displayUsers = _searchQuery.isEmpty ? _allUsers : _filteredUsers;
    final showLoadingIndicator = _isLoadingMore && _searchQuery.isEmpty;

    return ListView.builder(
      controller: _scrollController,
      itemCount: showLoadingIndicator ? displayUsers.length + 1 : displayUsers.length,
      itemBuilder: (context, index) {
        if (index >= displayUsers.length) {
          return _buildLoadingIndicator();
        }
        return UserItemWidget(user: displayUsers[index]);
      },
    );
  }

  Widget _buildNoSearchResultsWidget() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.userListNoSearchResults,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.userListClearSearch,
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

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}