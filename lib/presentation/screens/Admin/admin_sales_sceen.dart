import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_tabs_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_state.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/data/models/all_sales_model.dart';

class AdminSalesSceen extends StatelessWidget {
  const AdminSalesSceen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SalesCubit(GetAllSalesApiService())..fetchAllSales(),
      child: Scaffold(
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
          builder: (context, state) {
            if (state is SalesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SalesError) {
              return Center(child: Text(state.message));
            } else if (state is SalesLoaded) {
              final List<SalesData> allSales = state.salesData.data ?? [];

              // تحويل البيانات إلى قائمة من (_SalesWithLeadCount)
              final List<_SalesWithLeadCount> salesList =
                  allSales
                      .where((s) => s.userlog != null)
                      .map(
                        (s) => _SalesWithLeadCount(
                          user: s.userlog!,
                          leadCount: s.assignedLeads ?? 0,
                        ),
                      )
                      .toList();

              // ترتيب من أكثر عدد leads إلى أقل
              salesList.sort((a, b) => b.leadCount.compareTo(a.leadCount));

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: salesList.length,
                itemBuilder: (context, index) {
                  final item = salesList[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        item.user.name ?? 'No Name',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Role: ${item.user.role ?? 'Unknown'}"),
                      trailing: Chip(
                        label: Text(
                          '${item.leadCount} Leads',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor:Theme.of(context).brightness == Brightness.light ? Constants.maincolor : Constants.mainDarkmodecolor,
                      ),
                    ),
                  );
                },
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}

class _SalesWithLeadCount {
  final UserLogsModel user;
  int leadCount;

  _SalesWithLeadCount({required this.user, required this.leadCount});
}
