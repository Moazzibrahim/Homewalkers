import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/fetch_admin_sales_api_service.dart';
import 'package:homewalkers_app/presentation/viewModels/adminSales/admin_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/adminSales/admin_sales_state.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_tabs_screen.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:shimmer/shimmer.dart';

class AdminSalesSceen extends StatelessWidget {
  const AdminSalesSceen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              AdminSalesCubit(FetchAdminSalesApiService())
                ..fetchSalesLeadsCount(),

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
        body: BlocBuilder<AdminSalesCubit, AdminSalesState>(
          builder: (context, state) {
            if (state is AdminSalesLoading) {
              return _buildShimmerList(context);
            }

            if (state is AdminSalesError) {
              return Center(child: Text(state.message));
            }

            if (state is AdminSalesLoaded) {
              final salesList = state.data.data ?? [];

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
                        item.salesName ?? 'No Name',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Chip(
                        label: Text(
                          '${item.activeLeadsCount ?? 0} Leads',
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
