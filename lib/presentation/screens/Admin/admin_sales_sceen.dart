import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_all_users_api_service.dart';
import 'package:homewalkers_app/presentation/viewModels/get_all_users/cubit/get_all_users_cubit.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_tabs_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_state.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/data/models/all_sales_model.dart';
import 'package:shimmer/shimmer.dart';

class AdminSalesSceen extends StatelessWidget {
  const AdminSalesSceen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SalesCubit(GetAllSalesApiService())..fetchAllSales(),
        ),
        BlocProvider(
          create:
              (_) =>
                  GetAllUsersCubit(GetAllUsersApiService())..fetchLeadCounts(),
        ),
      ],
      child: Scaffold(
        backgroundColor:
            Theme.of(context).brightness == Brightness.light
                ? Constants.backgroundlightmode
                : Constants.backgroundDarkmode,
        appBar: CustomAppBar(
          title: "Sales",
          onBack: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminTabsScreen()),
            );
          },
        ),
        body: BlocBuilder<SalesCubit, SalesState>(
          builder: (context, salesState) {
            if (salesState is SalesLoading) {
              return _buildShimmerList(context);
            }

            if (salesState is SalesError) {
              return Center(child: Text(salesState.message));
            }

            if (salesState is SalesLoaded) {
              final allSales = salesState.salesData.data ?? [];

              return BlocBuilder<GetAllUsersCubit, GetAllUsersState>(
                builder: (context, usersState) {
                  final leadCounts =
                      (usersState is UsersLeadCountSuccess)
                          ? usersState.leadCounts
                          : <String, int>{};

                  final salesList =
                      allSales
                          .where((s) => s.userlog != null)
                          .map(
                            (s) => _SalesWithLeadCount(
                              user: s.userlog!,
                              leadCount: leadCounts[s.userlog!.id] ?? 0,
                            ),
                          )
                          .toList()
                        ..sort((a, b) => b.leadCount.compareTo(a.leadCount));

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: salesList.length,
                    itemBuilder: (context, index) {
                      final item = salesList[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            item.user.name ?? 'No Name',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Role: ${item.user.role ?? 'Unknown'}",
                          ),
                          trailing: Chip(
                            label: Text(
                              '${item.leadCount} Leads',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.light
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

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // 🔆 Shimmer loading list while waiting for data
  Widget _buildShimmerList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          highlightColor: isDark ? Colors.grey[500]! : Colors.grey[100]!,
          child: Card(
            color: isDark ? Colors.grey[800] : Colors.white,
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Container(
                height: 16,
                color: isDark ? Colors.grey[700] : Colors.white,
              ),
              subtitle: Container(
                height: 12,
                margin: const EdgeInsets.only(top: 8),
                color: isDark ? Colors.grey[600] : Colors.white,
              ),
              trailing: Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// 🔁 Helper class to hold user and lead count
class _SalesWithLeadCount {
  final UserLogsModel user;
  final int leadCount;

  _SalesWithLeadCount({required this.user, required this.leadCount});
}
