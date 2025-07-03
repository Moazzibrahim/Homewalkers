import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_all_users_api_service.dart';
import 'package:homewalkers_app/presentation/viewModels/get_all_users/cubit/get_all_users_cubit.dart';// Import user service
import 'package:homewalkers_app/presentation/screens/Admin/admin_tabs_screen.dart';// Import user cubit
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_state.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/data/models/all_sales_model.dart';

class AdminSalesSceen extends StatelessWidget {
  const AdminSalesSceen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use MultiBlocProvider to have access to both cubits in the widget tree
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SalesCubit(GetAllSalesApiService())..fetchAllSales(),
        ),
        BlocProvider(
          create: (_) => GetAllUsersCubit(GetAllUsersApiService())..fetchLeadCounts(),
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light ? Constants.backgroundlightmode : Constants.backgroundDarkmode,
        appBar: CustomAppBar(
          title: "Sales",
          onBack: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminTabsScreen()),
            );
          },
        ),
        // This builder is for the main list of sales from SalesCubit
        body: BlocBuilder<SalesCubit, SalesState>(
          builder: (context, salesState) {
            if (salesState is SalesLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (salesState is SalesError) {
              return Center(child: Text(salesState.message));
            }
            if (salesState is SalesLoaded) {
              final List<SalesData> allSales = salesState.salesData.data ?? [];

              // This builder gets the lead counts from GetAllUsersCubit
              return BlocBuilder<GetAllUsersCubit, GetAllUsersState>(
                builder: (context, usersState) {
                  // Get the map of lead counts. If the state is not success, use an empty map.
                  final leadCounts = (usersState is UsersLeadCountSuccess)
                      ? usersState.leadCounts
                      : <String, int>{};

                  // Map the sales data to a new list that includes the lead count
                  final List<_SalesWithLeadCount> salesList = allSales
                      .where((s) => s.userlog != null)
                      .map((s) => _SalesWithLeadCount(
                            user: s.userlog!,
                            // Look up the count from the map. If not found, default to 0.
                            leadCount: leadCounts[s.userlog!.id] ?? 0,
                          ))
                      .toList();

                  // Sort the final list by lead count in descending order
                  salesList.sort((a, b) => b.leadCount.compareTo(a.leadCount));

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: salesList.length,
                    itemBuilder: (context, index) {
                      final item = salesList[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(
                            item.user.name ?? 'No Name',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("Role: ${item.user.role ?? 'Unknown'}"),
                          trailing: Chip(
                            label: Text(
                              '${item.leadCount} Leads',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: Theme.of(context).brightness == Brightness.light
                                ? Constants.maincolor
                                : Constants.mainDarkmodecolor,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }
            return const SizedBox.shrink(); // Default empty state
          },
        ),
      ),
    );
  }
}

// Helper class to hold the combined data for the UI
class _SalesWithLeadCount {
  final UserLogsModel user;
  final int leadCount;

  _SalesWithLeadCount({required this.user, required this.leadCount});
}