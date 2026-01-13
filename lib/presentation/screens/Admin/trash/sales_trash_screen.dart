// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/core/utils/formatters.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_cities_api_service.dart';
import 'package:homewalkers_app/data/models/all_sales_model.dart';
import 'package:homewalkers_app/presentation/viewModels/Add_in_menu/cubit/add_in_menu_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/cities/cubit/get_cities_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_state.dart';
import 'package:homewalkers_app/presentation/widgets/add_sales_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';

class SalesTrashScreen extends StatelessWidget {
  const SalesTrashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              SalesCubit(GetAllSalesApiService())..fetchAllSalesInTrash(),
      child: BlocListener<AddInMenuCubit, AddInMenuState>(
        listener: (context, state) {
          print("BlocListener Triggered: $state");
          if (state is AddInMenuSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Done successfully')));
            // اطلب من الـ GetCommunicationWaysCubit ان يعيد تحميل البيانات
            context.read<SalesCubit>().fetchAllSalesInTrash();
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
            title: "sales",
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
                                  BlocProvider<GetCitiesCubit>(
                                    create:
                                        (_) => GetCitiesCubit(
                                          GetCitiesApiService(),
                                        ),
                                  ),
                                  BlocProvider<SalesCubit>(
                                    create:
                                        (_) =>
                                            SalesCubit(GetAllSalesApiService())
                                              ..fetchAllSalesInTrash(),
                                  ),
                                ],
                                child: AddSalesDialog(
                                  onAdd: ({
                                    required name,
                                    required city,
                                    required userId,
                                    required teamleaderId,
                                    required managerId,
                                    required isActive,
                                    required notes,
                                  }) {
                                    context.read<AddInMenuCubit>().addSales(
                                      name,
                                      city,
                                      userId,
                                      teamleaderId,
                                      managerId,
                                      isActive,
                                      notes,
                                    );
                                  },
                                ),
                              ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text(
                        "Add New Sales",
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
                  child: BlocBuilder<SalesCubit, SalesState>(
                    builder: (context, state) {
                      if (state is SalesLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is SalesLoaded) {
                        final ways = state.salesData.data;
                        if (ways!.isEmpty) {
                          return const Center(child: Text('No sales Found.'));
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
                      } else if (state is SalesError) {
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
    SalesData communicationWay,
    Color mainColor,
    BuildContext context,
  ) {
    final name = communicationWay.name ?? 'No Name';
    final dateTime = communicationWay.createdAt;
    final formattedDate = Formatters.formatDate(dateTime!);
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
                  "sales Name : $name",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
                  "creation date : $formattedDate",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Spacer(),
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
                  context.read<AddInMenuCubit>().updateSalesStatus(
                    true,
                    communicationWay.id.toString(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
