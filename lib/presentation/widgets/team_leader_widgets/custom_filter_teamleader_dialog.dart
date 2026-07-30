// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'dart:math' as math; // ✅ للكشف عن التابلت
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/developers_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_channels_api_service.dart';
import 'package:homewalkers_app/data/data_sources/projects_api_service.dart';
import 'package:homewalkers_app/data/data_sources/stages_api_service.dart';
import 'package:homewalkers_app/data/data_sources/team_leader/get_leads_count.dart';
import 'package:homewalkers_app/presentation/viewModels/channels/channels_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/channels/channels_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/developers/developers_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/projects/projects_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_leads_count_in_team_leader_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_leads_team_leader_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_text_field_widget.dart';
import 'package:country_picker/country_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showFilterDialogTeamLeader(
  BuildContext context,
  GetLeadsTeamLeaderCubit leadsCubit,
  bool? data,
  bool? transferedData,
  Function(Map<String, dynamic>)? onFiltersApplied, // ✅ أضف هذا الـ parameter
) {
  showDialog(
    context: context,
    builder:
        (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: leadsCubit),
            BlocProvider(
              create:
                  (_) =>
                      DevelopersCubit(DeveloperApiService())..getDevelopers(),
            ),
            BlocProvider(
              create:
                  (_) => ProjectsCubit(ProjectsApiService())..fetchProjects(),
            ),
            BlocProvider(
              create: (_) => StagesCubit(StagesApiService())..fetchStages(),
            ),
            BlocProvider(
              create:
                  (_) => ChannelCubit(GetChannelsApiService())..fetchChannels(),
            ),
            BlocProvider(
              create:
                  (context) =>
                      GetLeadsCountInTeamLeaderCubit(GetLeadsCountApiService())
                        ..fetchLeadsCount(),
            ),
          ],
          child: FilterDialog(
            data: data,
            transferedData: transferedData,
            onFiltersApplied: onFiltersApplied, // ✅ تمرير الـ callback
          ),
        ),
  );
}

class FilterDialog extends StatefulWidget {
  final bool? data;
  final bool? transferedData;
  final Function(Map<String, dynamic>)? onFiltersApplied; // ✅ أضف هذا

  const FilterDialog({
    super.key,
    this.data,
    this.transferedData,
    this.onFiltersApplied, // ✅ أضف هذا
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  final TextEditingController nameController = TextEditingController();
  Country? selectedCountry;

  // ✅ single-select values (بدل الـ Sets)
  String? selectedDeveloper;
  String? selectedProject;
  String? selectedStage;
  String? selectedChannel;
  String? selectedSalesId;
  String? selectedSales; // اسم السيلز المختار (للعرض)

  List<Country> countries = [];
  String? teamleaderid;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _lastStageUpdateStart;
  DateTime? _lastStageUpdateEnd;

  bool _showSales = false;
  bool _showDevelopers = false;
  bool _showProjects = false;
  bool _showStages = false;
  bool _showChannels = false;

  final TextEditingController _salesSearchController = TextEditingController();
  final TextEditingController _developersSearchController =
      TextEditingController();
  final TextEditingController _projectsSearchController =
      TextEditingController();
  final TextEditingController _channelsSearchController =
      TextEditingController();
  final TextEditingController _stagesSearchController = TextEditingController();

  String _salesSearchQuery = '';
  String _developersSearchQuery = '';
  String _projectsSearchQuery = '';
  String _channelsSearchQuery = '';
  String _stagesSearchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<GetLeadsTeamLeaderCubit>().fetchTeamLeaderLeadsWithPagination(
      data: widget.data,
      transferefromdata: widget.transferedData,
    );
    _loadTeamLeaderId();
  }

  Future<void> _loadTeamLeaderId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      teamleaderid = prefs.getString("teamLeaderIddspecific");
    });
    debugPrint("teamleaderid: $teamleaderid");
  }

  /// ✅ Section بحث + اختيار عنصر واحد بس (single-select)
  Widget buildSingleSelectSection({
    required String title,
    required IconData icon,
    required List<String> items,
    required String? selectedItem,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Function(String) onItemTapped,
    required VoidCallback onClearSelection,
    required TextEditingController searchController,
    required String searchQuery,
    required Function(String) onSearchChanged,
    Color? iconColor,
    bool isTabletDevice = false,
    double tabletScale = 1.0,
    double tabletFontScale = 1.0,
  }) {
    final filteredItems =
        searchQuery.isEmpty
            ? items
            : items
                .where(
                  (item) =>
                      item.toLowerCase().contains(searchQuery.toLowerCase()),
                )
                .toList();

    return Container(
      margin: EdgeInsets.only(bottom: (12 * tabletScale).r),
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular((10 * tabletScale).r),
        border: Border.all(color: const Color(0xffE1E1E1)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: EdgeInsets.all((8 * tabletScale).r),
              decoration: BoxDecoration(
                color: (iconColor ?? Constants.maincolor).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? Constants.maincolor,
                size: (18 * tabletFontScale).sp,
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: (14 * tabletFontScale).sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle:
                selectedItem != null
                    ? Text(
                      selectedItem,
                      style: TextStyle(
                        fontSize: (12 * tabletFontScale).sp,
                        color: Constants.maincolor,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                    : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedItem != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                    onPressed: onClearSelection,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                SizedBox(width: (4 * tabletScale).w),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
              ],
            ),
            onTap: onToggle,
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, size: 18),
                  suffixIcon:
                      searchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged('');
                            },
                          )
                          : null,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
          if (isExpanded)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child:
                  filteredItems.isEmpty
                      ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'No results found',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      )
                      : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredItems.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final isSelected = item == selectedItem;
                          return InkWell(
                            onTap: () => onItemTapped(item),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            isSelected
                                                ? Constants.maincolor
                                                : null,
                                        fontWeight:
                                            isSelected ? FontWeight.w500 : null,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Constants.maincolor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
        ],
      ),
    );
  }

  // ✅ دالة متجاوبة لبناء حقل التاريخ
  Widget buildDateField({
    required String label,
    required IconData icon,
    required DateTime? value,
    required Function(DateTime) onDatePicked,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Constants.maincolor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Constants.maincolor, size: 20),
        ),
        title: Text(
          value != null ? "${value.day}/${value.month}/${value.year}" : label,
          style: TextStyle(
            fontSize: 14,
            color: value != null ? Constants.maincolor : Colors.grey,
            fontWeight: value != null ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        trailing: const Icon(
          Icons.calendar_today,
          size: 18,
          color: Colors.grey,
        ),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(primary: Constants.maincolor),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) onDatePicked(picked);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ كشف نوع الجهاز داخل الـ build
    final bool isTabletDevice = () {
      final data = MediaQuery.of(context);
      final physicalSize = data.size;
      final diagonal = math.sqrt(
        math.pow(physicalSize.width, 2) + math.pow(physicalSize.height, 2),
      );
      final inches = diagonal / (data.devicePixelRatio * 160);
      return inches >= 7.0;
    }();

    // ✅ عوامل التصغير حسب الجهاز
    final double tabletScale = isTabletDevice ? 0.85 : 1.0;
    final double tabletFontScale = isTabletDevice ? 0.9 : 1.0;
    final double tabletWidthScale = isTabletDevice ? 0.85 : 1.0;
    final double tabletHeightScale = isTabletDevice ? 0.9 : 1.0;

    return Dialog(
      insetPadding: EdgeInsets.all(
        isTabletDevice ? (24 * tabletWidthScale).w : (16 * tabletWidthScale).w,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular((16 * tabletScale).r),
      ),
      child: Container(
        width:
            isTabletDevice
                ? MediaQuery.of(context).size.width * 0.7
                : double.maxFinite,
        constraints: BoxConstraints(
          maxHeight:
              isTabletDevice ? 800.h : MediaQuery.of(context).size.height * 0.9,
          maxWidth: isTabletDevice ? 800.w : double.infinity,
        ),
        child: Padding(
          padding: EdgeInsets.all((16 * tabletScale).r),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🎯 Header - متجاوب
                Row(
                  children: [
                    CircleAvatar(
                      radius: (20 * tabletScale).r,
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Constants.maincolor
                              : Constants.mainDarkmodecolor,
                      child: Icon(
                        Icons.tune,
                        color: Colors.white,
                        size: (18 * tabletFontScale).sp,
                      ),
                    ),
                    SizedBox(width: (10 * tabletWidthScale).w),
                    Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: (16 * tabletFontScale).sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, size: (24 * tabletFontScale).sp),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: (40 * tabletWidthScale).w,
                        minHeight: (40 * tabletHeightScale).h,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: (12 * tabletHeightScale).h),

                // 📝 CustomTextField - متجاوب
                SizedBox(
                  height: isTabletDevice ? (50 * tabletHeightScale).h : null,
                  child: CustomTextField(
                    hint: "Full Name",
                    controller: nameController,
                  ),
                ),
                SizedBox(height: (12 * tabletHeightScale).h),
                SizedBox(height: (12 * tabletHeightScale).h),

                // 👤 Sales - single select
                BlocBuilder<
                  GetLeadsCountInTeamLeaderCubit,
                  GetLeadsCountInTeamLeaderState
                >(
                  builder: (context, state) {
                    if (state is GetLeadsCountInTeamLeaderLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is GetLeadsCountInTeamLeaderLoaded) {
                      final filteredSales =
                          state.data.data
                              ?.where((s) => s.salesName != null)
                              .toList() ??
                          [];
                      final items =
                          filteredSales.map((e) => e.salesName!).toList();

                      return buildSingleSelectSection(
                        title: "Sales",
                        icon: Icons.person_outline,
                        items: items,
                        selectedItem: selectedSales,
                        isExpanded: _showSales,
                        onToggle:
                            () => setState(() => _showSales = !_showSales),
                        onItemTapped: (name) {
                          final matched = filteredSales.firstWhere(
                            (e) => e.salesName == name,
                          );
                          setState(() {
                            if (selectedSales == name) {
                              // إلغاء الاختيار لو دوس على نفس العنصر
                              selectedSales = null;
                              selectedSalesId = null;
                            } else {
                              selectedSales = name;
                              selectedSalesId = matched.salesID;
                            }
                          });
                        },
                        onClearSelection: () {
                          setState(() {
                            selectedSales = null;
                            selectedSalesId = null;
                          });
                        },
                        searchController: _salesSearchController,
                        searchQuery: _salesSearchQuery,
                        onSearchChanged:
                            (v) => setState(() => _salesSearchQuery = v),
                        isTabletDevice: isTabletDevice,
                        tabletScale: tabletScale,
                        tabletFontScale: tabletFontScale,
                      );
                    } else if (state is GetLeadsCountInTeamLeaderError) {
                      return Text("error: ${state.message}");
                    }
                    return const SizedBox();
                  },
                ),
                SizedBox(height: (12 * tabletHeightScale).h),

                // 🏗️ Developers - single select
                BlocBuilder<DevelopersCubit, DevelopersState>(
                  builder: (context, state) {
                    if (state is DeveloperLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is DeveloperSuccess) {
                      final items =
                          state.developersModel.data
                              .map((dev) => dev.name ?? '')
                              .toList();
                      return buildSingleSelectSection(
                        title: "Developers",
                        icon: Icons.business,
                        items: items,
                        selectedItem: selectedDeveloper,
                        isExpanded: _showDevelopers,
                        onToggle:
                            () => setState(
                              () => _showDevelopers = !_showDevelopers,
                            ),
                        onItemTapped: (item) {
                          setState(() {
                            selectedDeveloper =
                                selectedDeveloper == item ? null : item;
                          });
                        },
                        onClearSelection: () {
                          setState(() => selectedDeveloper = null);
                        },
                        searchController: _developersSearchController,
                        searchQuery: _developersSearchQuery,
                        onSearchChanged:
                            (v) => setState(() => _developersSearchQuery = v),
                        isTabletDevice: isTabletDevice,
                        tabletScale: tabletScale,
                        tabletFontScale: tabletFontScale,
                      );
                    } else if (state is DeveloperError) {
                      return Text("error: ${state.error}");
                    }
                    return const SizedBox.shrink();
                  },
                ),
                SizedBox(height: (12 * tabletHeightScale).h),

                // 📢 Channels - single select
                BlocBuilder<ChannelCubit, ChannelState>(
                  builder: (context, state) {
                    if (state is ChannelLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ChannelLoaded) {
                      final items =
                          state.channelResponse.data
                              .map((channel) => channel.name ?? '')
                              .toList();
                      return buildSingleSelectSection(
                        title: "Channels",
                        icon: Icons.campaign,
                        items: items,
                        selectedItem: selectedChannel,
                        isExpanded: _showChannels,
                        onToggle:
                            () =>
                                setState(() => _showChannels = !_showChannels),
                        onItemTapped: (item) {
                          setState(() {
                            selectedChannel =
                                selectedChannel == item ? null : item;
                          });
                        },
                        onClearSelection: () {
                          setState(() => selectedChannel = null);
                        },
                        searchController: _channelsSearchController,
                        searchQuery: _channelsSearchQuery,
                        onSearchChanged:
                            (v) => setState(() => _channelsSearchQuery = v),
                        isTabletDevice: isTabletDevice,
                        tabletScale: tabletScale,
                        tabletFontScale: tabletFontScale,
                      );
                    } else if (state is ChannelError) {
                      return Text(
                        "error: ${state.message}",
                        style: TextStyle(
                          fontSize: (14 * tabletFontScale).sp,
                          color: Colors.red,
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
                SizedBox(height: (12 * tabletHeightScale).h),

                // 🏢 Projects - single select
                BlocBuilder<ProjectsCubit, ProjectsState>(
                  builder: (context, state) {
                    if (state is ProjectsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ProjectsSuccess) {
                      final items =
                          state.projectsModel.data!
                              .map((project) => project.name ?? '')
                              .toList();
                      return buildSingleSelectSection(
                        title: "Projects",
                        icon: Icons.apartment,
                        items: items,
                        selectedItem: selectedProject,
                        isExpanded: _showProjects,
                        onToggle:
                            () =>
                                setState(() => _showProjects = !_showProjects),
                        onItemTapped: (item) {
                          setState(() {
                            selectedProject =
                                selectedProject == item ? null : item;
                          });
                        },
                        onClearSelection: () {
                          setState(() => selectedProject = null);
                        },
                        searchController: _projectsSearchController,
                        searchQuery: _projectsSearchQuery,
                        onSearchChanged:
                            (v) => setState(() => _projectsSearchQuery = v),
                        isTabletDevice: isTabletDevice,
                        tabletScale: tabletScale,
                        tabletFontScale: tabletFontScale,
                      );
                    } else if (state is ProjectsError) {
                      return Text(
                        "error: ${state.error}",
                        style: TextStyle(
                          fontSize: (14 * tabletFontScale).sp,
                          color: Colors.red,
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
                SizedBox(height: (12 * tabletHeightScale).h),

                // 🗺️ Stages - single select
                BlocBuilder<StagesCubit, StagesState>(
                  builder: (context, state) {
                    if (state is StagesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is StagesLoaded) {
                      final items =
                          state.stages.map((s) => s.name ?? '').toList();
                      return buildSingleSelectSection(
                        title: "Stages",
                        icon: Icons.schema,
                        items: items,
                        selectedItem: selectedStage,
                        isExpanded: _showStages,
                        onToggle:
                            () => setState(() => _showStages = !_showStages),
                        onItemTapped: (item) {
                          setState(() {
                            selectedStage = selectedStage == item ? null : item;
                          });
                        },
                        onClearSelection: () {
                          setState(() => selectedStage = null);
                        },
                        searchController: _stagesSearchController,
                        searchQuery: _stagesSearchQuery,
                        onSearchChanged:
                            (v) => setState(() => _stagesSearchQuery = v),
                        isTabletDevice: isTabletDevice,
                        tabletScale: tabletScale,
                        tabletFontScale: tabletFontScale,
                      );
                    } else if (state is StagesError) {
                      return Text("error: ${state.message}");
                    }
                    return const SizedBox.shrink();
                  },
                ),
                SizedBox(height: (12 * tabletHeightScale).h),
                buildDateField(
                  label: "Last Stage Update (Start)",
                  icon: Icons.update,
                  value: _lastStageUpdateStart,
                  onDatePicked: (picked) {
                    setState(() => _lastStageUpdateStart = picked);
                  },
                ),
                buildDateField(
                  label: "Last Stage Update (End)",
                  icon: Icons.update,
                  value: _lastStageUpdateEnd,
                  onDatePicked: (picked) {
                    setState(() => _lastStageUpdateEnd = picked);
                  },
                ),
                buildDateField(
                  label: "Creation Date (Start)",
                  icon: Icons.assignment_add,
                  value: _startDate,
                  onDatePicked: (picked) {
                    setState(() => _startDate = picked);
                  },
                ),
                buildDateField(
                  label: "Creation Date (End)",
                  icon: Icons.assignment_add,
                  value: _endDate,
                  onDatePicked: (picked) {
                    setState(() => _endDate = picked);
                  },
                ),
                SizedBox(height: (20 * tabletHeightScale).h),

                // 🔘 Buttons Row - متجاوبة
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Constants.maincolor
                                    : Constants.mainDarkmodecolor,
                            width: (1 * tabletScale).r,
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: (10 * tabletHeightScale).h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              (4 * tabletScale).r,
                            ),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            nameController.clear();
                            selectedCountry = null;
                            selectedDeveloper = null;
                            selectedProject = null;
                            selectedStage = null;
                            selectedChannel = null;
                            selectedSalesId = null;
                            selectedSales = null;
                            _startDate = null;
                            _endDate = null;
                            _lastStageUpdateStart = null;
                            _lastStageUpdateEnd = null;
                          });

                          final clearedFilters = {
                            'name': null,
                            'developerId': null,
                            'projectId': null,
                            'stageId': null,
                            'channelId': null,
                            'salesId': null,
                            'creationDateFrom': null,
                            'creationDateTo': null,
                            'stageDateFrom': null,
                            'stageDateTo': null,
                          };
                          widget.onFiltersApplied?.call(clearedFilters);

                          context
                              .read<GetLeadsTeamLeaderCubit>()
                              .fetchTeamLeaderLeadsWithPagination(
                                data: widget.data,
                                transferefromdata: widget.transferedData,
                              );
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Reset",
                          style: TextStyle(
                            color: Constants.maincolor,
                            fontSize: (16 * tabletFontScale).sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: (10 * tabletWidthScale).w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          bool isValidDateRange(
                            DateTime? start,
                            DateTime? end,
                          ) {
                            return (start == null && end == null) ||
                                (start != null && end != null);
                          }

                          Future<void> showValidationDialog(
                            String message,
                          ) async {
                            return showDialog(
                              context: context,
                              builder:
                                  (_) => AlertDialog(
                                    title: Text(
                                      "Incomplete Date Range",
                                      style: TextStyle(
                                        fontSize: (18 * tabletFontScale).sp,
                                      ),
                                    ),
                                    content: Text(
                                      message,
                                      style: TextStyle(
                                        fontSize: (14 * tabletFontScale).sp,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(context).pop(),
                                        child: Text(
                                          "OK",
                                          style: TextStyle(
                                            fontSize: (14 * tabletFontScale).sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                          }

                          if (!isValidDateRange(_startDate, _endDate)) {
                            showValidationDialog(
                              "Please select both start and end date for creation date.",
                            );
                            return;
                          }
                          if (!isValidDateRange(
                            _lastStageUpdateStart,
                            _lastStageUpdateEnd,
                          )) {
                            showValidationDialog(
                              "Please select both start and end date for last stage update.",
                            );
                            return;
                          }

                          log("selectedDeveloper: $selectedDeveloper");
                          log("selectedSales: $selectedSales");

                          // ✅ جمع قيم الفلاتر
                          final appliedFilters = {
                            'name':
                                nameController.text.trim().isEmpty
                                    ? null
                                    : nameController.text.trim(),
                            'developerId': selectedDeveloper,
                            'projectId': selectedProject,
                            'stageId': selectedStage,
                            'channelId': selectedChannel,
                            'salesId': selectedSalesId,
                            'creationDateFrom': _startDate,
                            'creationDateTo': _endDate,
                            'stageDateFrom': _lastStageUpdateStart,
                            'stageDateTo': _lastStageUpdateEnd,
                          };

                          // ✅ استدعاء الـ callback قبل إغلاق الـ Dialog
                          widget.onFiltersApplied?.call(appliedFilters);

                          context
                              .read<GetLeadsTeamLeaderCubit>()
                              .fetchTeamLeaderLeadsWithPagination(
                                search:
                                    nameController.text.trim().isEmpty
                                        ? null
                                        : nameController.text.trim(),
                                developerId: selectedDeveloper,
                                projectId: selectedProject,
                                stageId: selectedStage,
                                channelId: selectedChannel,
                                salesId: selectedSalesId,
                                creationDateFrom: _startDate,
                                creationDateTo: _endDate,
                                stageDateFrom: _lastStageUpdateStart,
                                stageDateTo: _lastStageUpdateEnd,
                                data: widget.data,
                                transferefromdata: widget.transferedData,
                              );

                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.light
                                  ? Constants.maincolor
                                  : Constants.mainDarkmodecolor,
                          padding: EdgeInsets.symmetric(
                            vertical: (10 * tabletHeightScale).h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              (4 * tabletScale).r,
                            ),
                          ),
                        ),
                        child: Text(
                          "Apply",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: (18 * tabletFontScale).sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
