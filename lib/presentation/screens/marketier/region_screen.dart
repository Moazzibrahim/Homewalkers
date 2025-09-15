// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/core/utils/formatters.dart';
import 'package:homewalkers_app/data/data_sources/get_cities_api_service.dart';
import 'package:homewalkers_app/data/models/regions_model.dart';
import 'package:homewalkers_app/presentation/viewModels/Add_in_menu/cubit/add_in_menu_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/cities/cubit/get_cities_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/add_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/delete_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/update_dialog.dart';

class RegionScreen extends StatelessWidget {
  const RegionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => GetCitiesCubit(GetCitiesApiService())..fetchRegions(),
      child: BlocListener<AddInMenuCubit, AddInMenuState>(
        listener: (context, state) {
          print("BlocListener Triggered: $state");
          if (state is AddInMenuSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Done successfully')));
            // اطلب من الـ GetCommunicationWaysCubit ان يعيد تحميل البيانات
            context.read<GetCitiesCubit>().fetchRegions();
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
            title: "Regions",
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
                                child: AddDialog(
                                  onAdd: (value) {
                                    context.read<AddInMenuCubit>().addRegion(
                                      value,
                                    );
                                  },
                                  title: "region",
                                ),
                              ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text(
                        "Add New Region",
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
                  child: BlocBuilder<GetCitiesCubit, GetCitiesState>(
                    builder: (context, state) {
                      if (state is GetCitiesLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is GetCitiesSuccess) {
                        final regions = state.regions;
                        if (regions!.isEmpty) {
                          return const Center(child: Text('No regions Found.'));
                        }
                        return ListView.separated(
                          itemCount: regions.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final region = regions[index];
                            return _buildCommunicationCard(
                              region,
                              Constants.maincolor,
                              context,
                            );
                          },
                        );
                      } else if (state is GetCitiesFailure) {
                        return Center(child: Text('Error: ${state.error}'));
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
    Region developerData,
    Color mainColor,
    BuildContext context,
  ) {
    final name = developerData.name;
    final dateTime = developerData.createdAt;
    final formattedDate = Formatters.formatDate(dateTime);
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
                  "region Name : $name",
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
                            initialValue: developerData.name,
                            title: "region",
                            onAdd: (value) {
                              context.read<AddInMenuCubit>().updateRegion(
                                value,
                                developerData.id.toString(),
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
                        (_) => BlocProvider.value(
                          value: context.read<AddInMenuCubit>(),
                          child: DeleteDialog(
                            onCancel: () => Navigator.of(context).pop(),
                            onConfirm: () {
                              // تنفيذ الحذف
                              Navigator.of(context).pop();
                              context.read<AddInMenuCubit>().updateRegionStatus(
                                developerData.id.toString(),
                                false,
                                name,
                              );
                            },
                            title: "region",
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
