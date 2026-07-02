// ignore_for_file: avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class RegionScreen extends StatefulWidget {
  const RegionScreen({super.key});

  @override
  State<RegionScreen> createState() => _RegionScreenState();
}

class _RegionScreenState extends State<RegionScreen> {
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
      create:
          (context) => GetCitiesCubit(GetCitiesApiService())..fetchRegions(),
      child: BlocListener<AddInMenuCubit, AddInMenuState>(
        listener: (context, state) {
          print("BlocListener Triggered: $state");
          if (state is AddInMenuSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Done successfully')));
            context.read<GetCitiesCubit>().fetchRegions();
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
            title: "Regions",
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
                      hintText: "Search regions...",
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
                        Text(
                          "ALL REGIONS",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                isLight ? Colors.grey[500] : Colors.grey[400],
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Divider(
                            color:
                                isLight ? Colors.grey[300] : Colors.grey[700],
                            thickness: 1,
                          ),
                        ),
                        const SizedBox(width: 10),
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
                  child: BlocBuilder<GetCitiesCubit, GetCitiesState>(
                    builder: (context, state) {
                      if (state is GetCitiesLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is GetCitiesSuccess) {
                        final all = state.regions ?? [];
                        final filtered =
                            all.where((r) {
                              if (_searchQuery.isEmpty) return true;
                              return (r.name ?? '').toLowerCase().contains(
                                _searchQuery,
                              );
                            }).toList();

                        if (filtered.isEmpty) {
                          return const Center(child: Text('No regions found.'));
                        }

                        return ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder:
                              (context, index) =>
                                  _buildCard(filtered[index], context),
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

  // ─────────────────────────────────────────────────────────────────────────
  // CARD
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCard(Region region, BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final mainColor =
        isLight ? Constants.maincolor : Constants.mainDarkmodecolor;
    final formattedDate = Formatters.formatDate(region.createdAt);

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
          // ── Left: name + date ────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  region.name ?? '-',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isLight ? Colors.black87 : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: isLight ? Colors.grey[400] : Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 13,
                        color: isLight ? Colors.grey[500] : Colors.grey[400],
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
                            initialValue: region.name,
                            title: "region",
                            onAdd: (value) {
                              context.read<AddInMenuCubit>().updateRegion(
                                value,
                                region.id.toString(),
                              );
                            },
                          ),
                        ),
                  );
                },
              ),
              const SizedBox(width: 8),
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
                              context.read<AddInMenuCubit>().updateRegionStatus(
                                region.id.toString(),
                                false,
                                region.name,
                              );
                            },
                            title: "region",
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

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => BlocProvider.value(
            value: context.read<AddInMenuCubit>(),
            child: AddDialog(
              onAdd: (value) {
                context.read<AddInMenuCubit>().addRegion(value);
              },
              title: "region",
            ),
          ),
    );
  }
}
