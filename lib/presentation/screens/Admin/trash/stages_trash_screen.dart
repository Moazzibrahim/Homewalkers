// ignore_for_file: avoid_print, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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

class StagesTrashScreen extends StatefulWidget {
  const StagesTrashScreen({super.key});

  @override
  State<StagesTrashScreen> createState() => _StagesScreenState();
}

class _StagesScreenState extends State<StagesTrashScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          appBar: CustomAppBar(
            title: "Stages",
            onBack: () => Navigator.pop(context),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TabBar(
                        controller: _tabController,
                        labelColor: Theme.of(context).primaryColor,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Theme.of(context).primaryColor,
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: const [Tab(text: "Stages"), Tab(text: "Types")],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_tabController.index == 0) {
                          _showAddStageDialog(context);
                        } else {
                          _showAddStageTypeDialog(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.maincolor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _tabController.index == 0
                            ? "+ Add New Stage"
                            : "+ Add New Type",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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

  Widget _buildStagesTab() {
    return BlocBuilder<StagesCubit, StagesState>(
      builder: (context, state) {
        if (state is StagesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StagesLoaded) {
          final stages = state.stages;
          if (stages.isEmpty) {
            return const Center(child: Text('No stages Found.'));
          }
          return ListView.separated(
            itemCount: stages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildStageCard(stages[index], context);
            },
          );
        } else if (state is StagesError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStageTypesTab() {
    return BlocBuilder<GetStageTypesCubit, GetStageTypesState>(
      builder: (context, state) {
        if (state is GetStageTypesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is GetStageTypesSuccess) {
          // Assuming your model is StageTypeModel which contains List<StageDatam>
          final stageTypes = state.response.data ?? [];
          if (stageTypes.isEmpty) {
            return const Center(child: Text('No stage types Found.'));
          }
          return ListView.separated(
            itemCount: stageTypes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildStageTypeCard(stageTypes[index], context);
            },
          );
        } else if (state is GetStageTypesFailure) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStageCard(StageDatas stage, BuildContext context) {
    final theme = Theme.of(context);
    final iconColor =
        theme.brightness == Brightness.light
            ? Constants.maincolor
            : Constants.mainDarkmodecolor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            context,
            Icons.label_outline,
            "Stage Name",
            stage.name ?? 'N/A',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            Icons.layers_outlined,
            "Stage Type",
            stage.stagetype?.name ?? 'N/A',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            Icons.calendar_today_outlined,
            "Creation Date",
            stage.createdAt != null
                ? Formatters.formatDate(stage.createdAt!)
                : "N/A",
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Spacer(),
              InkWell(
                child: Icon(
                  Icons.restore_from_trash,
                  color: iconColor,
                  size: 30.0,
                ),
                onTap: () {
                  context.read<AddInMenuCubit>().updateStageStatus(
                    stage.id.toString(),
                    true,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStageTypeCard(StageDatam stageType, BuildContext context) {
    final theme = Theme.of(context);
    final iconColor =
        theme.brightness == Brightness.light
            ? Constants.maincolor
            : Constants.mainDarkmodecolor;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            context,
            Icons.layers_outlined,
            "Stage Type Name",
            stageType.name ?? 'N/A',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            Icons.comment_outlined,
            "Comment",
            stageType.comment ?? '',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            Icons.calendar_today_outlined,
            "Creation Date",
            stageType.createdAt != null ? stageType.createdAt! : "N/A",
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Spacer(),
              InkWell(
                child: Icon(
                  Icons.restore_from_trash,
                  color: iconColor,
                  size: 30.0,
                ),
                onTap: () {
                  context.read<AddInMenuCubit>().updateStageTypeStatus(
                    stageType.id.toString(),
                    true,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final iconColor =
        Theme.of(context).brightness == Brightness.light
            ? Constants.maincolor
            : Constants.mainDarkmodecolor;
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: const Color(0xFFE5F4F5),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "$label : $value",
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // --- DIALOGS ---
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
              onAdd: ({required name, required comment, required stageType}) {
                context.read<AddInMenuCubit>().addStage(
                  name,
                  stageType,
                  comment,
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
