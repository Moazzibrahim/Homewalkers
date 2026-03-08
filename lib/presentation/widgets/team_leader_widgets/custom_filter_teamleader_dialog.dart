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
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/projects/projects_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_leads_count_in_team_leader_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_leads_team_leader_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_dropdown_widget.dart';
import 'package:homewalkers_app/presentation/widgets/custom_text_field_widget.dart';
import 'package:country_picker/country_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showFilterDialogTeamLeader(
  BuildContext context,
  GetLeadsTeamLeaderCubit leadsCubit,
  bool? data,
  bool? transferedData,
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
          child: FilterDialog(data: data, transferedData: transferedData),
        ),
  );
}

class FilterDialog extends StatefulWidget {
  final bool? data;
  final bool? transferedData;
  const FilterDialog({super.key, this.data, this.transferedData});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  final TextEditingController nameController = TextEditingController();
  Country? selectedCountry;
  String? selectedDeveloper;
  String? selectedProject;
  String? selectedStage;
  String? selectedChannel;
  String? selectedSalesId;
  List<Country> countries = [];
  String? selectedSales;
  String? teamleaderid;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _lastStageUpdateStart;
  DateTime? _lastStageUpdateEnd;

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

  // ✅ دالة متجاوبة لبناء حقل التاريخ
  Widget buildDateField(
    String label,
    DateTime? value,
    Function(DateTime) onDatePicked,
    bool isTabletDevice,
    double tabletScale,
    double tabletFontScale,
    double tabletWidthScale,
    double tabletHeightScale,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: (8 * tabletHeightScale).h),
      child: GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (picked != null) onDatePicked(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(
              fontSize: (14 * tabletFontScale).sp,
              color: const Color.fromRGBO(143, 146, 146, 1),
              fontWeight: FontWeight.w400,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular((8 * tabletScale).r),
              borderSide: BorderSide(
                color: const Color(0xffE1E1E1),
                width: (1 * tabletScale).r,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: (12 * tabletWidthScale).w,
              vertical: (16 * tabletHeightScale).h,
            ),
            suffixIcon: Icon(
              Icons.calendar_today,
              size: (20 * tabletFontScale).sp,
            ),
          ),
          child: Text(
            value != null ? "${value.toLocal()}".split(' ')[0] : label,
            style: TextStyle(
              fontSize: (14 * tabletFontScale).sp,
              fontWeight: FontWeight.w400,
              color:
                  Theme.of(context).brightness == Brightness.light
                      ? const Color(0xff080719)
                      : const Color(0xffFFFFFF),
              fontFamily: 'Montserrat',
            ),
          ),
        ),
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
                    // textStyle: TextStyle(fontSize: (14 * tabletFontScale).sp),
                  ),
                ),
                SizedBox(height: (12 * tabletHeightScale).h),

                // 🌍 Country Picker - متجاوب
                SizedBox(height: (12 * tabletHeightScale).h),

                // 👤 Sales Dropdown - متجاوب
                BlocBuilder<
                  GetLeadsCountInTeamLeaderCubit,
                  GetLeadsCountInTeamLeaderState
                >(
                  builder: (context, state) {
                    if (state is GetLeadsCountInTeamLeaderLoaded) {
                      final filteredSales =
                          state.data.data?.where((sales) {
                            return sales.salesName != null;
                          }).toList() ??
                          [];

                      return SizedBox(
                        child: CustomDropdownField(
                          hint: "Choose Sales",
                          // 👇 نعرض الاسم
                          items:
                              filteredSales
                                  .map((e) => e.salesName ?? '')
                                  .toList(),

                          // 👇 نجيب الاسم من خلال الـ id المختار
                          value:
                              selectedSalesId == null
                                  ? null
                                  : filteredSales
                                      .where(
                                        (e) => e.salesID == selectedSalesId,
                                      )
                                      .isNotEmpty
                                  ? filteredSales
                                      .firstWhere(
                                        (e) => e.salesID == selectedSalesId,
                                      )
                                      .salesName
                                  : null,

                          onChanged: (value) {
                            final selected = filteredSales.firstWhere(
                              (e) => e.salesName == value,
                            );

                            setState(() {
                              selectedSalesId = selected.salesID;
                            });

                            log("Selected Sales Name: ${selected.salesName}");
                            log("Selected Sales ID: ${selected.salesID}");
                          },
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
                SizedBox(height: (12 * tabletHeightScale).h),

                // 🏗️ Developer Dropdown - متجاوب
                BlocBuilder<DevelopersCubit, DevelopersState>(
                  builder: (context, state) {
                    if (state is DeveloperLoading) {
                      return Center(
                        child: SizedBox(
                          height: (24 * tabletHeightScale).h,
                          width: (24 * tabletWidthScale).w,
                          child: const CircularProgressIndicator(),
                        ),
                      );
                    } else if (state is DeveloperSuccess) {
                      final items =
                          state.developersModel.data
                              .map((dev) => dev.name)
                              .toList();
                      return SizedBox(
                        height:
                            isTabletDevice ? (50 * tabletHeightScale).h : null,
                        child: CustomDropdownField(
                          hint: "Choose Developer",
                          items: items,
                          value: selectedDeveloper,
                          onChanged:
                              (val) => setState(() => selectedDeveloper = val),
                          //   textStyle: TextStyle(fontSize: (14 * tabletFontScale).sp),
                        ),
                      );
                    } else if (state is DeveloperError) {
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

                // 📡 Channel Dropdown - متجاوب
                BlocBuilder<ChannelCubit, ChannelState>(
                  builder: (context, state) {
                    if (state is ChannelLoading) {
                      return Center(
                        child: SizedBox(
                          height: (24 * tabletHeightScale).h,
                          width: (24 * tabletWidthScale).w,
                          child: const CircularProgressIndicator(),
                        ),
                      );
                    } else if (state is ChannelLoaded) {
                      final items =
                          state.channelResponse.data
                              .map((dev) => dev.name)
                              .toList();
                      return SizedBox(
                        height:
                            isTabletDevice ? (50 * tabletHeightScale).h : null,
                        child: CustomDropdownField(
                          hint: "Choose channel",
                          items: items,
                          value: selectedChannel,
                          onChanged:
                              (val) => setState(() => selectedChannel = val),
                          //   textStyle: TextStyle(fontSize: (14 * tabletFontScale).sp),
                        ),
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

                // 🏢 Project Dropdown - متجاوب
                BlocBuilder<ProjectsCubit, ProjectsState>(
                  builder: (context, state) {
                    if (state is ProjectsLoading) {
                      return Center(
                        child: SizedBox(
                          height: (24 * tabletHeightScale).h,
                          width: (24 * tabletWidthScale).w,
                          child: const CircularProgressIndicator(),
                        ),
                      );
                    } else if (state is ProjectsSuccess) {
                      final items =
                          state.projectsModel.data!
                              .map((project) => project.name)
                              .toList();
                      return SizedBox(
                        height:
                            isTabletDevice ? (50 * tabletHeightScale).h : null,
                        child: CustomDropdownField(
                          hint: "Choose Project",
                          items: items,
                          value: selectedProject,
                          onChanged:
                              (val) => setState(() => selectedProject = val),
                          // textStyle: TextStyle(fontSize: (14 * tabletFontScale).sp),
                        ),
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

                // 🎯 Stage Dropdown - متجاوب
                BlocBuilder<StagesCubit, StagesState>(
                  builder: (context, state) {
                    if (state is StagesLoading) {
                      return Center(
                        child: SizedBox(
                          height: (24 * tabletHeightScale).h,
                          width: (24 * tabletWidthScale).w,
                          child: const CircularProgressIndicator(),
                        ),
                      );
                    } else if (state is StagesLoaded) {
                      final items =
                          state.stages.map((stage) => stage.name).toList();
                      return SizedBox(
                        height:
                            isTabletDevice ? (50 * tabletHeightScale).h : null,
                        child: CustomDropdownField(
                          hint: "Choose Stage",
                          items: items,
                          value: selectedStage,
                          onChanged: (value) {
                            setState(() {
                              selectedStage = value;
                            });
                          },
                        ),
                      );
                    } else if (state is StagesError) {
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

                // 📅 Date Fields - متجاوبة
                buildDateField(
                  "Last Stage Update (Start)",
                  _lastStageUpdateStart,
                  (picked) => setState(() => _lastStageUpdateStart = picked),
                  isTabletDevice,
                  tabletScale,
                  tabletFontScale,
                  tabletWidthScale,
                  tabletHeightScale,
                ),
                buildDateField(
                  "Last Stage Update (End)",
                  _lastStageUpdateEnd,
                  (picked) => setState(() => _lastStageUpdateEnd = picked),
                  isTabletDevice,
                  tabletScale,
                  tabletFontScale,
                  tabletWidthScale,
                  tabletHeightScale,
                ),
                buildDateField(
                  "Creation Date (Start)",
                  _startDate,
                  (picked) => setState(() => _startDate = picked),
                  isTabletDevice,
                  tabletScale,
                  tabletFontScale,
                  tabletWidthScale,
                  tabletHeightScale,
                ),
                buildDateField(
                  "Creation Date (End)",
                  _endDate,
                  (picked) => setState(() => _endDate = picked),
                  isTabletDevice,
                  tabletScale,
                  tabletFontScale,
                  tabletWidthScale,
                  tabletHeightScale,
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
                            selectedSales = null;
                            _startDate = null;
                            _endDate = null;
                            _lastStageUpdateStart = null;
                            _lastStageUpdateEnd = null;
                          });
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
                          log("selectedsales: $selectedSales");

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
