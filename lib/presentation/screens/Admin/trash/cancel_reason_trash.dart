// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/core/utils/formatters.dart';
import 'package:homewalkers_app/data/data_sources/cancel_reason_api_service.dart';
import 'package:homewalkers_app/data/models/cancel_reason_model.dart';
import 'package:homewalkers_app/presentation/viewModels/Add_in_menu/cubit/add_in_menu_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/cancel_reason/cubit/get_cancel_reason_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/add_cancel_reason_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/delete_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/update_dialog.dart';

class CancelReasonTrash extends StatelessWidget {
  const CancelReasonTrash({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              GetCancelReasonCubit(CancelReasonApiService())
                ..fetchCancelReasonsInTrash(),
      child: BlocListener<AddInMenuCubit, AddInMenuState>(
        listener: (context, state) {
          print("BlocListener Triggered: $state");
          if (state is AddInMenuSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('added successfully')));
            // اطلب من الـ GetCommunicationWaysCubit ان يعيد تحميل البيانات
            context.read<GetCancelReasonCubit>().fetchCancelReasonsInTrash();
          } else if (state is AddInMenuError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text(' error')));
          }
        },
        child: Scaffold(
          appBar: CustomAppBar(
            title: "cancel reasons",
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
                              (_) => BlocProvider.value(
                                value:
                                    context
                                        .read<
                                          AddInMenuCubit
                                        >(), // استخدم نفس الـ cubit
                                child: AddCancelReasonDialog(
                                  onAdd: (value) {
                                    context.read<AddInMenuCubit>().addDeveloper(
                                      value,
                                    );
                                  },
                                  title: "cancel reasons",
                                ),
                              ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text(
                        "Add New cancel reason",
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
                    GetCancelReasonCubit,
                    GetCancelReasonState
                  >(
                    builder: (context, state) {
                      if (state is GetCancelReasonLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is GetCancelReasonLoaded) {
                        final dsvelopers = state.response.data;
                        if (dsvelopers!.isEmpty) {
                          return const Center(
                            child: Text('No cancel reasons Found.'),
                          );
                        }
                        return ListView.separated(
                          itemCount: dsvelopers.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final developer = dsvelopers[index];
                            return _buildCommunicationCard(
                              developer,
                              Constants.maincolor,
                              context,
                            );
                          },
                        );
                      } else if (state is GetCancelReasonError) {
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
    CancelReason campaignData,
    Color mainColor,
    BuildContext context,
  ) {
    final name = campaignData.cancelReason;
    final dateTime = DateTime.parse(campaignData.createdAt!);
    final formattedDate = Formatters.formatDate(dateTime);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFFE5F4F5),
                child: Icon(
                  Icons.contact_mail,
                  size: 16,
                  color:
                      Theme.of(context).brightness == Brightness.light
                          ? Constants.maincolor
                          : Constants.mainDarkmodecolor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "cancel reason Name : $name",
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFFE5F4F5),
                child: Icon(
                  Icons.calendar_today,
                  size: 16,
                  color:
                      Theme.of(context).brightness == Brightness.light
                          ? Constants.maincolor
                          : Constants.mainDarkmodecolor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Creation Date : $formattedDate",
                  style: GoogleFonts.montserrat(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color:
                      Theme.of(context).brightness == Brightness.light
                          ? Constants.maincolor
                          : Constants.mainDarkmodecolor,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (_) => BlocProvider.value(
                          value: context.read<AddInMenuCubit>(),
                          child: UpdateDialog(
                            title: "cancel reason",
                            onAdd: (value) {
                              context.read<AddInMenuCubit>().updateCancelReason(
                                value,
                                campaignData.id.toString(),
                              );
                            },
                          ),
                        ),
                  );
                },
              ),
              InkWell(
              onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (_) => BlocProvider.value(value: context.read<AddInMenuCubit>(),
                          child: DeleteDialog(
                            onCancel: () => Navigator.of(context).pop(),
                            onConfirm: () {
                              // تنفيذ الحذف
                              Navigator.of(context).pop();
                              context.read<AddInMenuCubit>().deleteCancelReason(campaignData.id.toString(),);
                            },
                            title: "Cancel Reason",
                          ),
                        ),
                  );
                },
                child: Image.asset("assets/images/delete.png"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
