// ignore_for_file: avoid_print, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_users_for_signup_api_service.dart';
import 'package:homewalkers_app/data/models/all_users_model_for_add_users.dart';
import 'package:homewalkers_app/presentation/viewModels/Add_in_menu/cubit/add_in_menu_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/get_all_users_signup/cubit/getalluserssignup_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';

class UsersTrashScreen extends StatefulWidget {
  const UsersTrashScreen({super.key});

  @override
  State<UsersTrashScreen> createState() => _UsersTrashScreenState();
}

class _UsersTrashScreenState extends State<UsersTrashScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final mainColor =
        isLight ? Constants.maincolor : Constants.mainDarkmodecolor;

    return BlocProvider(
      create:
          (context) =>
              GetalluserssignupCubit(GetAllUsersForSignupApiService())
                ..fetchUsersInTrash(),
      child: BlocListener<AddInMenuCubit, AddInMenuState>(
        listener: (context, state) {
          print("BlocListener Triggered: $state");
          if (state is AddInMenuSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Done successfully')));
            context.read<GetalluserssignupCubit>().fetchUsersInTrash();
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
            title: "Users Trash",
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

                // ── Section Header ───────────────────────────────────
                Row(
                  children: [
                    Text(
                      "DELETED USERS",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isLight ? Colors.grey[500] : Colors.grey[400],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Divider(
                        color: isLight ? Colors.grey[300] : Colors.grey[700],
                        thickness: 1,
                      ),
                    ),
                  ],
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
                              if (_searchQuery.isEmpty) return true;
                              return (u.name ?? '').toLowerCase().contains(
                                _searchQuery,
                              );
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Left: avatar + name + role ───────────────────────────
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
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 12,
                    color: mainColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isLight ? Colors.grey[500] : Colors.grey[400],
                  ),
                ),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 12,
                    color: isLight ? Colors.grey[500] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Right: restore button ────────────────────────────────
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor:
                          isLight ? Colors.white : const Color(0xFF1E1E1E),
                      title: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: mainColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.restore_from_trash_rounded,
                              color: mainColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Restore User",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      content: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isLight ? Colors.grey[700] : Colors.grey[300],
                          ),
                          children: [
                            const TextSpan(
                              text: "Are you sure you want to restore ",
                            ),
                            TextSpan(
                              text: name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isLight ? Colors.black87 : Colors.white,
                              ),
                            ),
                            const TextSpan(text: "?"),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.read<AddInMenuCubit>().updateUserStatus(
                              user.id.toString(),
                              true,
                            );
                          },
                          child: const Text(
                            "Restore",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.restore_from_trash_rounded,
                color: mainColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
