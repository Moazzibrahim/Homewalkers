// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_users_for_signup_api_service.dart';
import 'package:homewalkers_app/data/models/all_users_model_for_add_users.dart';
import 'package:homewalkers_app/presentation/viewModels/Add_in_menu/cubit/add_in_menu_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/get_all_users_signup/cubit/getalluserssignup_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/add_users_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';

class UsersTrashScreen extends StatelessWidget {
  const UsersTrashScreen({super.key});
  @override
  Widget build(BuildContext context) {
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
            // اطلب من الـ GetCommunicationWaysCubit ان يعيد تحميل البيانات
            context.read<GetalluserssignupCubit>().fetchUsersInTrash();
          } else if (state is AddInMenuError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text(' error')));
          }
        },
        child: Scaffold(
          backgroundColor:
              Theme.of(context).brightness == Brightness.light
                  ? Constants.backgroundlightmode
                  : Constants.backgroundDarkmode,
          appBar: CustomAppBar(
            title: "users",
            onBack: () {
              Navigator.pop(context);
            },
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (_) => MultiBlocProvider(
                                providers: [
                                  BlocProvider.value(
                                    value:
                                        context
                                            .read<
                                              AddInMenuCubit
                                            >(), // استخدم نفس الـ cubit
                                  ),
                                  BlocProvider<GetalluserssignupCubit>(
                                    create:
                                        (_) => GetalluserssignupCubit(
                                          GetAllUsersForSignupApiService(),
                                        )..fetchUsersInTrash(),
                                  ),
                                ],
                                child: AddUsersDialog(
                                  onAdd: ({
                                    required String name,
                                    String?
                                    imagePath, // ✅ تعديل هنا: بدل image --> imagePath
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
                                      imagePath!, // ✅ تمرير المسار هنا
                                    );
                                  },
                                ),
                              ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text(
                        "Add New user",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.light
                                ? Constants.maincolor
                                : Constants.mainDarkmodecolor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<
                    GetalluserssignupCubit,
                    GetalluserssignupState
                  >(
                    builder: (context, state) {
                      if (state is GetalluserssignupLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is GetalluserssignupSuccess) {
                        final ways = state.users.data;
                        if (ways!.isEmpty) {
                          return const Center(child: Text('No users Found.'));
                        }
                        return ListView.separated(
                          itemCount: ways.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final way = ways[index];
                            return _buildCommunicationCard(
                              way,
                              Constants.maincolor,
                              context,
                            );
                          },
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

  Widget _buildCommunicationCard(
    UserData user,
    Color mainColor,
    BuildContext context,
  ) {
    final name = user.name ?? 'No Name';
    final role = user.role ?? 'No Role';
    final email = user.email ?? 'No Email';
    final phone = user.phone ?? 'No Phone';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color:
            Theme.of(context).brightness == Brightness.light
                ? Colors
                    .white // لون الكارت في light mode
                : const Color(0xFF1E1E1E),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).brightness == Brightness.light
                    ? Colors.grey.withOpacity(0.2)
                    : Colors.black.withOpacity(0.5),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(context, Icons.person, "User Name: $name"),
          const SizedBox(height: 12),
          _infoRow(context, Icons.badge, "Role: $role"),
          const SizedBox(height: 12),
          _infoRow(context, Icons.email, "Email: $email"),
          const SizedBox(height: 12),
          _infoRow(context, Icons.phone, "Phone: $phone"),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                child: Icon(
                  Icons.restore_from_trash,
                  color:
                      Theme.of(context).brightness == Brightness.light
                          ? Constants.maincolor
                          : Constants.mainDarkmodecolor,
                  size: 30.0,
                ),
                onTap: () {
                  context.read<AddInMenuCubit>().updateUserStatus(
                    user.id.toString(),
                    true,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: const Color(0xFFE5F4F5),
          child: Icon(
            icon,
            size: 16,
            color:
                Theme.of(context).brightness == Brightness.light
                    ? Constants.maincolor
                    : Constants.mainDarkmodecolor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 13))),
      ],
    );
  }
}
