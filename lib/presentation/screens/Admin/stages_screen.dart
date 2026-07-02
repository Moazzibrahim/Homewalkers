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
import 'package:homewalkers_app/presentation/widgets/marketer/delete_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/update_stage_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/update_stage_type_dialog.dart';
import 'package:intl/intl.dart';

class StagesScreen extends StatefulWidget {
  const StagesScreen({super.key});

  @override
  State<StagesScreen> createState() => _StagesScreenState();
}

class _StagesScreenState extends State<StagesScreen>
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
          create: (context) => StagesCubit(StagesApiService())..fetchStages(),
        ),
        BlocProvider(
          create:
              (context) =>
                  GetStageTypesCubit(StageTypeApiService())..fetchStageTypes(),
        ),
      ],
      child: BlocListener<AddInMenuCubit, AddInMenuState>(
        listener: (context, state) {
          if (state is AddInMenuSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            context.read<StagesCubit>().fetchStages();
            context.read<GetStageTypesCubit>().fetchStageTypes();
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
            title: "Stages",
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
                                ? "Active Pipelines"
                                : "Stage Types",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isLight ? Colors.black87 : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _tabController.index == 0
                                ? "Manage your property sales lifecycle"
                                : "Manage your stage categories",
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
                    children: [
                      _buildStagesTab(context),
                      _buildStageTypesTab(context),
                    ],
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
  Widget _buildStagesTab(BuildContext context) {
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
  Widget _buildStageTypesTab(BuildContext context) {
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
  // STAGE CARD  (new design)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStageCard(StageDatas stage, BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final mainColor =
        isLight ? Constants.maincolor : Constants.mainDarkmodecolor;

    // Determine icon & badge color by stage type name
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
                    const SizedBox(width: 8),
                    // Badge
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

          // Actions
          _buildActionButtons(
            context,
            mainColor,
            onRefresh: () => _showUpdateStageDialog(context, stage),
            onDelete:
                () => _showDeleteDialog(context, stage.id.toString(), "stage"),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STAGE TYPE CARD  (new design)
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

          // Actions
          _buildActionButtons(
            context,
            mainColor,
            onRefresh: () => _showUpdateStageTypeDialog(context, stageType),
            onDelete:
                () => _showDeletestageTypeDialog(
                  context,
                  stageType.id.toString(),
                  "Stage Type",
                ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Shared action buttons (refresh + delete)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildActionButtons(
    BuildContext context,
    Color mainColor, {
    required VoidCallback onRefresh,
    required VoidCallback onDelete,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onRefresh,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.refresh_rounded, color: mainColor, size: 20),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onDelete,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFBA1A1A).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFBA1A1A),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers for icon / color mapping
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
                          ..fetchStageTypes(),
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

  void _showUpdateStageDialog(BuildContext context, StageDatas stage) {
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
                          ..fetchStageTypes(),
              ),
            ],
            child: UpdateStageDialog(
              title: "Stage",
              oldComment: stage.comment,
              oldName: stage.name,
              oldStageTypeId: stage.stagetype?.id,
              onAdd: (name, comment, stageType) {
                context.read<AddInMenuCubit>().updateStage(
                  name,
                  stage.id.toString(),
                  stageType,
                  comment,
                );
              },
            ),
          ),
    );
  }

  void _showUpdateStageTypeDialog(BuildContext context, StageDatam stage) {
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
                          ..fetchStageTypes(),
              ),
            ],
            child: UpdateStageTypeDialog(
              title: "Stage Type",
              initialComment: stage.comment,
              initialName: stage.name,
              onAdd: (name, comment) {
                context.read<AddInMenuCubit>().updateStagetype(
                  name,
                  stage.id.toString(),
                  comment,
                );
              },
            ),
          ),
    );
  }

  void _showDeleteDialog(BuildContext context, String id, String title) {
    showDialog(
      context: context,
      builder:
          (_) => BlocProvider.value(
            value: context.read<AddInMenuCubit>(),
            child: DeleteDialog(
              onCancel: () => Navigator.of(context).pop(),
              onConfirm: () {
                Navigator.of(context).pop();
                context.read<AddInMenuCubit>().updateStageStatus(id, false);
              },
              title: title,
            ),
          ),
    );
  }

  void _showDeletestageTypeDialog(
    BuildContext context,
    String id,
    String title,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => BlocProvider.value(
            value: context.read<AddInMenuCubit>(),
            child: DeleteDialog(
              onCancel: () => Navigator.of(context).pop(),
              onConfirm: () {
                Navigator.of(context).pop();
                context.read<AddInMenuCubit>().updateStageTypeStatus(id, false);
              },
              title: title,
            ),
          ),
    );
  }
}
