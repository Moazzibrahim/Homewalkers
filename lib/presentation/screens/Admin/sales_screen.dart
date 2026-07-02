// ignore_for_file: avoid_print, unrelated_type_equality_checks
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/core/utils/formatters.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_all_users_for_signup_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_cities_api_service.dart';
import 'package:homewalkers_app/data/models/all_sales_model.dart';
import 'package:homewalkers_app/presentation/viewModels/Add_in_menu/cubit/add_in_menu_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/cities/cubit/get_cities_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/get_all_users_signup/cubit/getalluserssignup_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_state.dart';
import 'package:homewalkers_app/presentation/widgets/add_sales_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/delete_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/update_dialog.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
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
      create: (context) => SalesCubit(GetAllSalesApiService())..fetchAllSales(),
      child: BlocListener<AddInMenuCubit, AddInMenuState>(
        listener: (context, state) {
          print("BlocListener Triggered: $state");
          if (state is AddInMenuSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Done successfully')));
            context.read<SalesCubit>().fetchAllSales();
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
            title: "Sales",
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
                      hintText: "Search by name or email...",
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
                Builder(
                  builder: (context) {
                    return Row(
                      children: [
                        // Label
                        Text(
                          "RECENT ACCOUNTS",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                isLight ? Colors.grey[500] : Colors.grey[400],
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Divider line
                        Expanded(
                          child: Divider(
                            color:
                                isLight ? Colors.grey[300] : Colors.grey[700],
                            thickness: 1,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // ── FAB Add Button ─────────────────────────────
                        GestureDetector(
                          onTap: () => _showAddDialog(context),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: mainColor,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: mainColor.withOpacity(0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

                // ── List ─────────────────────────────────────────────
                Expanded(
                  child: BlocBuilder<SalesCubit, SalesState>(
                    builder: (context, state) {
                      if (state is SalesLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is SalesLoaded) {
                        final allItems = state.salesData.data ?? [];
                        final filtered =
                            allItems.where((s) {
                              if (_searchQuery.isEmpty) return true;
                              return (s.name ?? '').toLowerCase().contains(
                                _searchQuery,
                              );
                            }).toList();

                        if (filtered.isEmpty) {
                          return const Center(child: Text('No sales found.'));
                        }

                        return ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder:
                              (context, index) =>
                                  _buildSalesCard(filtered[index], context),
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

  // ─────────────────────────────────────────────────────────────────────────
  // SALES CARD
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSalesCard(SalesData sale, BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final mainColor =
        isLight ? Constants.maincolor : Constants.mainDarkmodecolor;

    final name = sale.name ?? 'No Name';
    final formattedDate =
        sale.createdAt != null ? Formatters.formatDate(sale.createdAt!) : 'N/A';

    // Status badge
    // salesIsActivate may be non-bool (e.g., dynamic/Object). Normalize to bool.
    final bool isActive = sale.salesIsActivate == "true";
    final statusLabel = isActive ? 'ACTIVE EXECUTIVE' : 'REVIEW REQUIRED';
    final statusColor =
        isActive ? const Color(0xFF4CAF50) : const Color(0xFFFFC107);

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
          // ── Left: name + date + status ───────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isLight ? Colors.black87 : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                // Date
                Text(
                  "Created $formattedDate",
                  style: TextStyle(
                    fontSize: 13,
                    color: isLight ? Colors.grey[500] : Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 10),
                // Status dot + label
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isLight ? Colors.grey[500] : Colors.grey[400],
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Right: action buttons ────────────────────────────────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Refresh button
              _actionButton(
                icon: Icons.refresh_rounded,
                color: mainColor,
                bgColor: mainColor.withOpacity(0.08),
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (_) => BlocProvider.value(
                          value: context.read<AddInMenuCubit>(),
                          child: UpdateDialog(
                            initialValue: sale.name,
                            title: "sales",
                            onAdd: (value) {
                              context.read<AddInMenuCubit>().updateSales(
                                value,
                                sale.id.toString(),
                              );
                            },
                          ),
                        ),
                  );
                },
              ),
              const SizedBox(width: 8),
              // Delete button
              _actionButton(
                icon: Icons.delete_outline_rounded,
                color: const Color(0xFFBA1A1A),
                bgColor: const Color(0xFFBA1A1A).withOpacity(0.08),
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (_) => BlocProvider.value(
                          value: context.read<AddInMenuCubit>(),
                          child: DeleteDialog(
                            onCancel: () => Navigator.of(context).pop(),
                            onConfirm: () {
                              Navigator.of(context).pop();
                              context.read<AddInMenuCubit>().updateSalesStatus(
                                false,
                                sale.id.toString(),
                              );
                            },
                            title: "sales",
                          ),
                        ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Reusable icon action button
  // ─────────────────────────────────────────────────────────────────────────
  Widget _actionButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Add dialog  (logic unchanged)
  // ─────────────────────────────────────────────────────────────────────────
  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: context.read<AddInMenuCubit>()),
              BlocProvider<GetCitiesCubit>(
                create: (_) => GetCitiesCubit(GetCitiesApiService()),
              ),
              BlocProvider<SalesCubit>(
                create:
                    (_) => SalesCubit(GetAllSalesApiService())..fetchAllSales(),
              ),
              BlocProvider(
                create:
                    (_) =>
                        GetalluserssignupCubit(GetAllUsersForSignupApiService())
                          ..fetchUsers(),
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
  }
}
