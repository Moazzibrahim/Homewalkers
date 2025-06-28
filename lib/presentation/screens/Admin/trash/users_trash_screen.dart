// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_users_for_signup_api_service.dart';
import 'package:homewalkers_app/data/models/all_users_model_for_add_users.dart';
import 'package:homewalkers_app/presentation/viewModels/Add_in_menu/cubit/add_in_menu_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/get_all_users_signup/cubit/getalluserssignup_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/add_users_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/update_password_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/update_user_dialog.dart';

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
            ).showSnackBar(const SnackBar(content: Text('added successfully')));
            // اطلب من الـ GetCommunicationWaysCubit ان يعيد تحميل البيانات
            context.read<GetalluserssignupCubit>().fetchUsersInTrash();
          } else if (state is AddInMenuError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text(' error')));
          }
        },
        child: Scaffold(
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
    final id = user.id.toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
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
          const SizedBox(height: 20),
          Row(
            children: [
              const Spacer(),
              InkWell(
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
                            onUpdate: ({
                              required String id,
                              required String name,
                              required String email,
                              required String phone,
                              required String role,
                            }) {
                              context.read<AddInMenuCubit>().updateUser(
                                name,
                                id,
                                email,
                                phone,
                                role,
                              );
                            },
                          ),
                        ),
                  );
                },
                child: Image.asset(
                  "assets/images/edit_new.png",
                  color:
                      Theme.of(context).brightness == Brightness.light
                          ? Constants.maincolor
                          : Constants.mainDarkmodecolor,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (_) => BlocProvider.value(
                          value: context.read<AddInMenuCubit>(),
                          child: UpdateUserPasswordDialog(
                            userId:
                                id, // Replace with the actual user ID you're passing
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
                child: Image.asset("assets/images/change_pass.png"),
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
        Expanded(
          child: Text(text, style: GoogleFonts.montserrat(fontSize: 13)),
        ),
      ],
    );
  }
}
