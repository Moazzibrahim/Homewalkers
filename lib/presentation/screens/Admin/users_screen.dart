// ignore_for_file: avoid_print, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_users_for_signup_api_service.dart';
import 'package:homewalkers_app/data/models/all_users_model_for_add_users.dart';
import 'package:homewalkers_app/presentation/viewModels/Add_in_menu/cubit/add_in_menu_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/get_all_users_signup/cubit/getalluserssignup_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/add_users_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/delete_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/update_password_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/update_user_dialog.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  Map<String, bool> switchStates = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'all'; // 'all' | 'active' | 'inactive'
  String? _roleFilter; // null = all roles

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _filterPill(
    String label,
    bool isSelected,
    Color mainColor,
    bool isLight,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? mainColor
                  : (isLight ? Colors.grey[100] : Colors.grey[800]),
          borderRadius: BorderRadius.circular(20),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: mainColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color:
                isSelected
                    ? Colors.white
                    : (isLight ? Colors.grey[600] : Colors.grey[400]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final mainColor =
        isLight ? Constants.maincolor : Constants.mainDarkmodecolor;

    return BlocProvider(
      create:
          (context) =>
              GetalluserssignupCubit(GetAllUsersForSignupApiService())
                ..fetchUsers(),
      child: BlocListener<AddInMenuCubit, AddInMenuState>(
        listener: (context, state) {
          print("BlocListener Triggered: $state");
          if (state is AddInMenuSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Done successfully')));
            context.read<GetalluserssignupCubit>().fetchUsers();
          } else if (state is AddInMenuError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('error')));
          }
        },
        child: Scaffold(
          backgroundColor:
              isLight
                  ? Constants.backgroundlightmode
                  : Constants.backgroundDarkmode,
          appBar: CustomAppBar(
            title: "Users",
            onBack: () => Navigator.pop(context),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── Search Bar ───────────────────────────────────────
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: isLight ? Colors.white : Colors.grey[850],
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search users...",
                      hintStyle: TextStyle(
                        color: isLight ? Colors.grey[400] : Colors.grey[500],
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isLight ? Colors.grey[400] : Colors.grey[500],
                        size: 22,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Section Header + Filters ─────────────────────────────
                Builder(
                  builder: (context) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "ALL USERS",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color:
                                    isLight
                                        ? Colors.grey[500]
                                        : Colors.grey[400],
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Divider(
                                color:
                                    isLight
                                        ? Colors.grey[300]
                                        : Colors.grey[700],
                                thickness: 1,
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => _showAddDialog(context),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: mainColor,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: mainColor.withOpacity(0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ── Status Filter Pills ──────────────────────────
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _filterPill(
                                'All',
                                _statusFilter == 'all',
                                mainColor,
                                isLight,
                                () => setState(() => _statusFilter = 'all'),
                              ),
                              const SizedBox(width: 8),
                              _filterPill(
                                'Active',
                                _statusFilter == 'active',
                                mainColor,
                                isLight,
                                () => setState(() => _statusFilter = 'active'),
                              ),
                              const SizedBox(width: 8),
                              _filterPill(
                                'Inactive',
                                _statusFilter == 'inactive',
                                mainColor,
                                isLight,
                                () =>
                                    setState(() => _statusFilter = 'inactive'),
                              ),
                              const SizedBox(width: 16),
                              // Divider
                              Container(
                                width: 1,
                                height: 20,
                                color:
                                    isLight
                                        ? Colors.grey[300]
                                        : Colors.grey[700],
                              ),
                              const SizedBox(width: 16),
                              // ── Role Filter Pills ──────────────────────
                              _filterPill(
                                'All Roles',
                                _roleFilter == null,
                                mainColor,
                                isLight,
                                () => setState(() => _roleFilter = null),
                              ),
                              const SizedBox(width: 8),
                              _filterPill(
                                'Sales',
                                _roleFilter == 'Sales',
                                mainColor,
                                isLight,
                                () => setState(() => _roleFilter = 'Sales'),
                              ),
                              const SizedBox(width: 8),
                              _filterPill(
                                'Team Leader',
                                _roleFilter == 'TeamLeader',
                                mainColor,
                                isLight,
                                () =>
                                    setState(() => _roleFilter = 'TeamLeader'),
                              ),
                              const SizedBox(width: 8),
                              _filterPill(
                                'Manager',
                                _roleFilter == 'Manager',
                                mainColor,
                                isLight,
                                () => setState(() => _roleFilter = 'Manager'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

                // ── List ─────────────────────────────────────────────
                Expanded(
                  child: BlocBuilder<
                    GetalluserssignupCubit,
                    GetalluserssignupState
                  >(
                    builder: (context, state) {
                      if (state is GetalluserssignupLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is GetalluserssignupSuccess) {
                        final all = state.users.data ?? [];
                        final filtered =
                            all.where((u) {
                              // Search filter
                              if (_searchQuery.isNotEmpty &&
                                  !(u.name ?? '').toLowerCase().contains(
                                    _searchQuery,
                                  )) {
                                return false;
                              }
                              // Status filter
                              if (_statusFilter == 'active' &&
                                  !(u.active ?? false)) {
                                return false;
                              }
                              if (_statusFilter == 'inactive' &&
                                  (u.active ?? false)) {
                                return false;
                              }
                              // Role filter
                              if (_roleFilter != null &&
                                  (u.role ?? '') != _roleFilter) {
                                return false;
                              }
                              return true;
                            }).toList();

                        if (filtered.isEmpty) {
                          return const Center(child: Text('No users found.'));
                        }

                        return ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder:
                              (context, index) =>
                                  _buildUserCard(filtered[index], context),
                        );
                      } else if (state is GetalluserssignupFailure) {
                        return Center(child: Text('Error: ${state.message}'));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // USER CARD
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildUserCard(UserData user, BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final mainColor =
        isLight ? Constants.maincolor : Constants.mainDarkmodecolor;

    final name = user.name ?? 'No Name';
    final role = user.role ?? 'No Role';
    final email = user.email ?? 'No Email';
    final phone = user.phone ?? 'No Phone';
    final opencomments = user.opencomments ?? false;
    final closeDoneDealcomments = user.closeDoneDealcomments ?? false;
    final id = user.id.toString();
    final isActive = switchStates[user.id] ?? user.active ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 14),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color:
                isLight
                    ? Colors.grey.withOpacity(0.12)
                    : Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Row: avatar + name + role / action buttons ───────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: mainColor.withOpacity(0.12),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name + role
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isLight ? Colors.black87 : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: mainColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        role,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: mainColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _actionButton(
                    child: SvgPicture.asset(
                      "assets/images/pen.svg",
                      color: mainColor,
                      width: 18,
                      height: 18,
                    ),
                    bgColor: mainColor.withOpacity(0.08),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (_) => BlocProvider.value(
                              value: context.read<AddInMenuCubit>(),
                              child: UpdateUserDialog(
                                id: id,
                                name: name,
                                email: email,
                                phone: phone,
                                role: role,
                                opencomments: opencomments,
                                closeDoneDealcomments: closeDoneDealcomments,
                                onUpdate: ({
                                  required String id,
                                  required String name,
                                  required String email,
                                  required String phone,
                                  required String role,
                                  required bool opencomments,
                                  required bool closeDoneDealcomments,
                                }) {
                                  context.read<AddInMenuCubit>().updateUser(
                                    name,
                                    id,
                                    email,
                                    phone,
                                    role,
                                    opencomments,
                                    closeDoneDealcomments,
                                  );
                                },
                              ),
                            ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  _actionButton(
                    child: SvgPicture.asset(
                      "assets/images/update.svg",
                      width: 18,
                      height: 18,
                    ),
                    bgColor: Colors.orange.withOpacity(0.08),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (_) => BlocProvider.value(
                              value: context.read<AddInMenuCubit>(),
                              child: UpdateUserPasswordDialog(
                                userId: id,
                                onUpdatePassword: (
                                  userId,
                                  currentPassword,
                                  newPassword,
                                  confirmPassword,
                                ) {
                                  return context
                                      .read<AddInMenuCubit>()
                                      .updateUserPassword(
                                        userId,
                                        currentPassword,
                                        newPassword,
                                        confirmPassword,
                                      );
                                },
                              ),
                            ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  _actionButton(
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFBA1A1A),
                      size: 18,
                    ),
                    bgColor: const Color(0xFFBA1A1A).withOpacity(0.08),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (_) => BlocProvider.value(
                              value: context.read<AddInMenuCubit>(),
                              child: DeleteDialog(
                                onCancel: () => Navigator.of(context).pop(),
                                onConfirm: () {
                                  Navigator.of(context).pop();
                                  context
                                      .read<AddInMenuCubit>()
                                      .updateUserStatus(
                                        user.id.toString(),
                                        false,
                                      );
                                },
                                title: "user",
                              ),
                            ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(
            color: isLight ? Colors.grey[100] : Colors.grey[800],
            thickness: 1,
          ),
          const SizedBox(height: 8),

          // ── Info rows ────────────────────────────────────────────
          _infoChip(Icons.email_outlined, email, isLight, mainColor),
          const SizedBox(height: 6),
          _infoChip(Icons.phone_outlined, phone, isLight, mainColor),

          const SizedBox(height: 10),

          // ── Status toggle ────────────────────────────────────────
          Row(
            children: [
              Icon(
                isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
                size: 16,
                color: isActive ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                isActive ? "Active" : "Inactive",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.green : Colors.grey,
                ),
              ),
              const Spacer(),
              Switch(
                value: isActive,
                onChanged: (value) {
                  setState(() => switchStates[user.id!] = value);
                  context.read<AddInMenuCubit>().updateUserStatus(
                    user.id!,
                    value,
                  );
                },
                activeColor: mainColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, bool isLight, Color mainColor) {
    return Row(
      children: [
        Icon(icon, size: 15, color: mainColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: isLight ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required Widget child,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: child),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: context.read<AddInMenuCubit>()),
              BlocProvider<GetalluserssignupCubit>(
                create:
                    (_) =>
                        GetalluserssignupCubit(GetAllUsersForSignupApiService())
                          ..fetchUsers(),
              ),
            ],
            child: AddUsersDialog(
              onAdd: ({
                required String name,
                String? imagePath,
                required String email,
                required String phone,
                required String password,
                required String passwordConfirm,
                required String role,
              }) {
                context.read<AddInMenuCubit>().addUsers(
                  name,
                  email,
                  phone,
                  password,
                  passwordConfirm,
                  role,
                  imagePath!,
                );
              },
            ),
          ),
    );
  }
}
