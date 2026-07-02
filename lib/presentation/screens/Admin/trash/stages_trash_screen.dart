// ignore_for_file: avoid_print, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/core/utils/formatters.dart';
import 'package:homewalkers_app/data/data_sources/get_stage_types_api_service.dart';
import 'package:homewalkers_app/data/data_sources/stages_api_service.dart';
import 'package:homewalkers_app/data/models/stage_type_model.dart';
import 'package:homewalkers_app/data/models/stages_models.dart';
import 'package:homewalkers_app/presentation/viewModels/Add_in_menu/cubit/add_in_menu_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/stage_types/cubit/get_stage_types_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/add_stage_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/add_stage_type_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';

class StagesTrashScreen extends StatefulWidget {
  const StagesTrashScreen({super.key});

  @override
  State<StagesTrashScreen> createState() => _StagesScreenState();
}

class _StagesScreenState extends State<StagesTrashScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final mainColor =
        isLight ? Constants.maincolor : Constants.mainDarkmodecolor;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) =>
                  StagesCubit(StagesApiService())..fetchStagesInTrash(),
        ),
        BlocProvider(
          create:
              (context) =>
                  GetStageTypesCubit(StageTypeApiService())
                    ..fetchStageTypesInTrash(),
        ),
      ],
      child: BlocListener<AddInMenuCubit, AddInMenuState>(
        listener: (context, state) {
          if (state is AddInMenuSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            context.read<StagesCubit>().fetchStagesInTrash();
            context.read<GetStageTypesCubit>().fetchStageTypesInTrash();
          } else if (state is AddInMenuError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Scaffold(
          backgroundColor:
              isLight
                  ? Constants.backgroundlightmode
                  : Constants.backgroundDarkmode,
          appBar: CustomAppBar(
            title: "Stages Trash",
            onBack: () => Navigator.pop(context),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── Tab Bar (pill style) ──────────────────────────────
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isLight ? const Color(0xFFF0F0F0) : Colors.grey[800],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: mainColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor:
                        isLight ? Colors.black54 : Colors.grey[400],
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                    dividerColor: Colors.transparent,
                    tabs: const [Tab(text: "Stages"), Tab(text: "Types")],
                  ),
                ),

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
                      hintText:
                          _tabController.index == 0
                              ? "Search stages..."
                              : "Search types...",
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _tabController.index == 0
                                ? "Deleted Stages"
                                : "Deleted Types",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isLight ? Colors.black87 : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _tabController.index == 0
                                ? "Restore previously deleted stages"
                                : "Restore previously deleted types",
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  isLight ? Colors.grey[500] : Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ── FAB Add Button ─────────────────────────────
                    GestureDetector(
                      onTap: () {
                        if (_tabController.index == 0) {
                          _showAddStageDialog(context);
                        } else {
                          _showAddStageTypeDialog(context);
                        }
                      },
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
                ),

                const SizedBox(height: 16),

                // ── Tab Content ──────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildStagesTab(), _buildStageTypesTab()],
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
  // STAGES TAB
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStagesTab() {
    return BlocBuilder<StagesCubit, StagesState>(
      builder: (context, state) {
        if (state is StagesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StagesLoaded) {
          final stages =
              state.stages.where((s) {
                if (_searchQuery.isEmpty) return true;
                return (s.name ?? '').toLowerCase().contains(_searchQuery) ||
                    (s.stagetype?.name ?? '').toLowerCase().contains(
                      _searchQuery,
                    );
              }).toList();

          if (stages.isEmpty) {
            return const Center(child: Text('No stages found.'));
          }
          return ListView.separated(
            itemCount: stages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder:
                (context, index) => _buildStageCard(stages[index], context),
          );
        } else if (state is StagesError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STAGE TYPES TAB
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStageTypesTab() {
    return BlocBuilder<GetStageTypesCubit, GetStageTypesState>(
      builder: (context, state) {
        if (state is GetStageTypesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is GetStageTypesSuccess) {
          final stageTypes =
              (state.response.data ?? []).where((s) {
                if (_searchQuery.isEmpty) return true;
                return (s.name ?? '').toLowerCase().contains(_searchQuery) ||
                    (s.comment ?? '').toLowerCase().contains(_searchQuery);
              }).toList();

          if (stageTypes.isEmpty) {
            return const Center(child: Text('No stage types found.'));
          }
          return ListView.separated(
            itemCount: stageTypes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder:
                (context, index) =>
                    _buildStageTypeCard(stageTypes[index], context),
          );
        } else if (state is GetStageTypesFailure) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STAGE CARD
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStageCard(StageDatas stage, BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final mainColor =
        isLight ? Constants.maincolor : Constants.mainDarkmodecolor;

    final typeName = (stage.stagetype?.name ?? '').toLowerCase();
    final iconData = _stageIcon(typeName);
    final iconBgColor = _stageIconBg(typeName);
    final badgeColor = _stageBadgeColor(typeName);
    final badgeLabel = stage.stagetype?.name?.toUpperCase() ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(iconData, color: mainColor, size: 26),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        stage.name ?? 'N/A',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isLight ? Colors.black87 : Colors.white,
                        ),
                      ),
                    ),
                    if (badgeLabel.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badgeLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: badgeColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Created: ${stage.createdAt != null ? Formatters.formatDate(stage.createdAt!) : 'N/A'}",
                  style: TextStyle(
                    fontSize: 12,
                    color: isLight ? Colors.grey[500] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),

          // Restore button
          IconButton(
            icon: Icon(Icons.restore_from_trash, color: mainColor, size: 24),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor:
                          isLight ? Colors.white : const Color(0xFF1E1E1E),
                      title: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: mainColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.restore_from_trash_rounded,
                              color: mainColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Restore Stage",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      content: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isLight ? Colors.grey[700] : Colors.grey[300],
                          ),
                          children: [
                            const TextSpan(
                              text: "Are you sure you want to restore ",
                            ),
                            TextSpan(
                              text: stage.name ?? 'this stage',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isLight ? Colors.black87 : Colors.white,
                              ),
                            ),
                            const TextSpan(text: "?"),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.read<AddInMenuCubit>().updateStageStatus(
                              stage.id.toString(),
                              true,
                            );
                          },
                          child: const Text(
                            "Restore",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
              );
            },
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STAGE TYPE CARD
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStageTypeCard(StageDatam stageType, BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final mainColor =
        isLight ? Constants.maincolor : Constants.mainDarkmodecolor;

    final typeName = (stageType.name ?? '').toLowerCase();
    final iconData = _stageIcon(typeName);
    final iconBgColor = _stageIconBg(typeName);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(iconData, color: mainColor, size: 26),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stageType.name ?? 'N/A',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isLight ? Colors.black87 : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Created: ${stageType.createdAt != null ? DateFormat('yyyy-MM-dd').format(DateTime.parse(stageType.createdAt!)) : 'N/A'}",
                  style: TextStyle(
                    fontSize: 12,
                    color: isLight ? Colors.grey[500] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),

          // Restore button
          IconButton(
            icon: Icon(Icons.restore_from_trash, color: mainColor, size: 24),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor:
                          isLight ? Colors.white : const Color(0xFF1E1E1E),
                      title: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: mainColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.restore_from_trash_rounded,
                              color: mainColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Restore Type",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      content: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isLight ? Colors.grey[700] : Colors.grey[300],
                          ),
                          children: [
                            const TextSpan(
                              text: "Are you sure you want to restore ",
                            ),
                            TextSpan(
                              text: stageType.name ?? 'this type',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isLight ? Colors.black87 : Colors.white,
                              ),
                            ),
                            const TextSpan(text: "?"),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            context
                                .read<AddInMenuCubit>()
                                .updateStageTypeStatus(
                                  stageType.id.toString(),
                                  true,
                                );
                          },
                          child: const Text(
                            "Restore",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
              );
            },
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────
  IconData _stageIcon(String typeName) {
    if (typeName.contains('follow')) return Icons.assignment_outlined;
    if (typeName.contains('pending') || typeName.contains('wait')) {
      return Icons.hourglass_empty_rounded;
    }
    if (typeName.contains('close') ||
        typeName.contains('done') ||
        typeName.contains('deal')) {
      return Icons.verified_rounded;
    }
    return Icons.layers_outlined;
  }

  Color _stageIconBg(String typeName) {
    if (typeName.contains('follow')) return const Color(0xFFE8EEF9);
    if (typeName.contains('pending') || typeName.contains('wait')) {
      return const Color(0xFFF0F0F0);
    }
    if (typeName.contains('close') ||
        typeName.contains('done') ||
        typeName.contains('deal')) {
      return const Color(0xFFFFF3E0);
    }
    return const Color(0xFFE8EEF9);
  }

  Color _stageBadgeColor(String typeName) {
    if (typeName.contains('follow')) return const Color(0xFF4A6CF7);
    if (typeName.contains('pending') || typeName.contains('wait')) {
      return const Color(0xFF9E9E9E);
    }
    if (typeName.contains('close') ||
        typeName.contains('done') ||
        typeName.contains('deal')) {
      return const Color(0xFFE65100);
    }
    return const Color(0xFF4A6CF7);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DIALOGS  (logic unchanged)
  // ─────────────────────────────────────────────────────────────────────────
  void _showAddStageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: context.read<AddInMenuCubit>()),
              BlocProvider<GetStageTypesCubit>(
                create:
                    (_) =>
                        GetStageTypesCubit(StageTypeApiService())
                          ..fetchStageTypesInTrash(),
              ),
            ],
            child: AddStageDialog(
              onAdd: ({required name, comment, required stageType}) {
                context.read<AddInMenuCubit>().addStage(
                  name,
                  stageType,
                  comment!,
                );
              },
            ),
          ),
    );
  }

  void _showAddStageTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => BlocProvider.value(
            value: context.read<AddInMenuCubit>(),
            child: AddStageTypeDialog(
              onAdd: (name, comment) {
                context.read<AddInMenuCubit>().addStagetype(name, comment);
              },
            ),
          ),
    );
  }
}
