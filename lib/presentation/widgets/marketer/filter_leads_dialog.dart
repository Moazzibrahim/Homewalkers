// filter_leads_dialog.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/viewModels/campaigns/get/cubit/get_campaigns_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/channels/channels_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/channels/channels_state.dart';
import 'package:homewalkers_app/presentation/viewModels/communication_ways/cubit/get_communication_ways_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/developers/developers_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/projects/projects_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_text_field_widget.dart';

class FilterDialog extends StatefulWidget {
  final List<String>? initialSalesIds;
  final List<String>? initialDeveloperIds;
  final List<String>? initialProjectIds;
  final List<String>? initialStageIds;
  final List<String>? initialChannelIds;
  final List<String>? initialCommunicationWayIds;
  final List<String>? initialCampaignIds;
  final String? initialSearchName;

  // ✅ إضافة القيم القديمة للـ Single Select والتواريخ
  final String? initialAddedBy;
  final String? initialAssignedFrom;
  final String? initialAssignedTo;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final DateTime? initialLastStageUpdateStart;
  final DateTime? initialLastStageUpdateEnd;
  final DateTime? initialLastCommentDateStart;
  final DateTime? initialLastCommentDateEnd;
  final DateTime? initialOldStageStartDate;
  final DateTime? initialOldStageEndDate;

  const FilterDialog({
    super.key,
    this.initialSalesIds,
    this.initialDeveloperIds,
    this.initialProjectIds,
    this.initialStageIds,
    this.initialChannelIds,
    this.initialCommunicationWayIds,
    this.initialCampaignIds,
    this.initialSearchName,
    this.initialAddedBy,
    this.initialAssignedFrom,
    this.initialAssignedTo,
    this.initialStartDate,
    this.initialEndDate,
    this.initialLastStageUpdateStart,
    this.initialLastStageUpdateEnd,
    this.initialLastCommentDateStart,
    this.initialLastCommentDateEnd,
    this.initialOldStageStartDate,
    this.initialOldStageEndDate,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late TextEditingController _nameController;

  // ✅ عوامل التصغير responsive
  late bool isTabletDevice;
  late double tabletScale;
  late double tabletFontScale;
  late double tabletWidthScale;
  late double tabletHeightScale;

  // ✅ متغيرات للـ IDs
  List<String> _selectedSalesIds = [];
  List<String> _selectedSalesNames = [];

  List<String> _selectedDeveloperIds = [];
  List<String> _selectedDeveloperNames = [];

  List<String> _selectedProjectIds = [];
  List<String> _selectedProjectNames = [];

  List<String> _selectedStageIds = [];
  List<String> _selectedStageNames = [];

  List<String> _selectedChannelIds = [];
  List<String> _selectedChannelNames = [];

  List<String> _selectedCommunicationWayIds = [];
  List<String> _selectedCommunicationWayNames = [];

  List<String> _selectedCampaignIds = [];
  List<String> _selectedCampaignNames = [];

  // ✅ متغيرات Added By / Assigned From / Assigned To (لسه single selection)
  String? _selectedAddedBy;
  String? _selectedAssignedFrom;
  String? _selectedAssignedTo;
  String? _selectedAddedById;
  String? _selectedAssignedFromId;
  String? _selectedAssignedToId;

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _lastStageUpdateStart;
  DateTime? _lastStageUpdateEnd;
  DateTime? _lastCommentDateStart;
  DateTime? _lastCommentDateEnd;
  DateTime? _oldStageStartDate;
  DateTime? _oldStageEndDate;

  // ✅ متغيرات لتخزين القيم الأصلية (للرجوع إليها عند الإلغاء)
  late List<String> _originalSalesIds;
  late List<String> _originalDeveloperIds;
  late List<String> _originalProjectIds;
  late List<String> _originalStageIds;
  late List<String> _originalChannelIds;
  late List<String> _originalCommunicationWayIds;
  late List<String> _originalCampaignIds;
  late String? _originalAddedBy;
  late String? _originalAssignedFrom;
  late String? _originalAssignedTo;
  late String? _originalAddedById;
  late String? _originalAssignedFromId;
  late String? _originalAssignedToId;
  late DateTime? _originalStartDate;
  late DateTime? _originalEndDate;
  late DateTime? _originalLastStageUpdateStart;
  late DateTime? _originalLastStageUpdateEnd;
  late DateTime? _originalLastCommentDateStart;
  late DateTime? _originalLastCommentDateEnd;
  late DateTime? _originalOldStageStartDate;
  late DateTime? _originalOldStageEndDate;
  late String _originalSearchText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialSearchName);

    // ✅ تجهيز القيم الابتدائية
    _selectedSalesIds = widget.initialSalesIds ?? [];
    _selectedDeveloperIds = widget.initialDeveloperIds ?? [];
    _selectedProjectIds = widget.initialProjectIds ?? [];
    _selectedStageIds = widget.initialStageIds ?? [];
    _selectedChannelIds = widget.initialChannelIds ?? [];
    _selectedCommunicationWayIds = widget.initialCommunicationWayIds ?? [];
    _selectedCampaignIds = widget.initialCampaignIds ?? [];

    // ✅ تهيئة القيم الأخرى
    _selectedAddedById = widget.initialAddedBy;
    _selectedAssignedFromId = widget.initialAssignedFrom;
    _selectedAssignedToId = widget.initialAssignedTo;
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _lastStageUpdateStart = widget.initialLastStageUpdateStart;
    _lastStageUpdateEnd = widget.initialLastStageUpdateEnd;
    _lastCommentDateStart = widget.initialLastCommentDateStart;
    _lastCommentDateEnd = widget.initialLastCommentDateEnd;
    _oldStageStartDate = widget.initialOldStageStartDate;
    _oldStageEndDate = widget.initialOldStageEndDate;

    // ✅ حفظ القيم الأصلية (للرجوع إليها عند الإلغاء)
    _originalSalesIds = List.from(_selectedSalesIds);
    _originalDeveloperIds = List.from(_selectedDeveloperIds);
    _originalProjectIds = List.from(_selectedProjectIds);
    _originalStageIds = List.from(_selectedStageIds);
    _originalChannelIds = List.from(_selectedChannelIds);
    _originalCommunicationWayIds = List.from(_selectedCommunicationWayIds);
    _originalCampaignIds = List.from(_selectedCampaignIds);
    _originalAddedById = _selectedAddedById;
    _originalAssignedFromId = _selectedAssignedFromId;
    _originalAssignedToId = _selectedAssignedToId;
    _originalStartDate = _startDate;
    _originalEndDate = _endDate;
    _originalLastStageUpdateStart = _lastStageUpdateStart;
    _originalLastStageUpdateEnd = _lastStageUpdateEnd;
    _originalLastCommentDateStart = _lastCommentDateStart;
    _originalLastCommentDateEnd = _lastCommentDateEnd;
    _originalOldStageStartDate = _oldStageStartDate;
    _originalOldStageEndDate = _oldStageEndDate;
    _originalSearchText = _nameController.text;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ حساب عوامل التصغير بناءً على حجم الشاشة
    final data = MediaQuery.of(context);
    final physicalSize = data.size;
    final diagonal = math.sqrt(
      math.pow(physicalSize.width, 2) + math.pow(physicalSize.height, 2),
    );
    final inches = diagonal / (data.devicePixelRatio * 160);
    isTabletDevice = inches >= 7.0;

    tabletScale = isTabletDevice ? 0.85 : 1.0;
    tabletFontScale = isTabletDevice ? 0.9 : 1.0;
    tabletWidthScale = isTabletDevice ? 0.85 : 1.0;
    tabletHeightScale = isTabletDevice ? 0.9 : 1.0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Widget buildDateField(
    String label,
    DateTime? value,
    Function(DateTime) onDatePicked,
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
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular((8 * tabletScale).r),
              borderSide: const BorderSide(color: Colors.black),
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
    return Dialog(
      insetPadding: EdgeInsets.all((16 * tabletScale).r),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular((16 * tabletScale).r),
      ),
      child: Padding(
        padding: EdgeInsets.all((16 * tabletScale).r),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: (20 * tabletFontScale).r,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? Constants.maincolor
                            : Constants.mainDarkmodecolor,
                    child: Icon(
                      Icons.tune,
                      size: (20 * tabletFontScale).sp,
                      color: Colors.white,
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
                    onPressed: () {
                      // ✅ عند الضغط على X، نرجع القيم الأصلية (بدون تغيير)
                      Navigator.pop(context, {
                        'name': _originalSearchText,
                        'salesIds': _originalSalesIds,
                        'developerIds': _originalDeveloperIds,
                        'projectIds': _originalProjectIds,
                        'stageIds': _originalStageIds,
                        'channelIds': _originalChannelIds,
                        'campaignIds': _originalCampaignIds,
                        'communicationWayIds': _originalCommunicationWayIds,
                        'addedBy': _originalAddedById,
                        'assignedFrom': _originalAssignedFromId,
                        'assignedTo': _originalAssignedToId,
                        'startDate': _originalStartDate,
                        'endDate': _originalEndDate,
                        'lastStageUpdateStart': _originalLastStageUpdateStart,
                        'lastStageUpdateEnd': _originalLastStageUpdateEnd,
                        'lastCommentDateStart': _originalLastCommentDateStart,
                        'lastCommentDateEnd': _originalLastCommentDateEnd,
                        'oldStageDateStart': _originalOldStageStartDate,
                        'oldStageDateEnd': _originalOldStageEndDate,
                      });
                    },
                    padding: EdgeInsets.all((8 * tabletScale).r),
                    constraints: BoxConstraints(
                      minWidth: (40 * tabletWidthScale).w,
                      minHeight: (40 * tabletHeightScale).h,
                    ),
                  ),
                ],
              ),
              SizedBox(height: (12 * tabletHeightScale).h),

              // Search Field
              CustomTextField(
                hint: "Search Name, Email, or Phone",
                controller: _nameController,
              ),
              SizedBox(height: (12 * tabletHeightScale).h),

              // Sales Multi Select
              BlocBuilder<SalesCubit, SalesState>(
                builder: (context, state) {
                  if (state is SalesLoaded) {
                    final filteredSales =
                        state.salesData.data?.where((sales) {
                          final role = sales.userlog?.role?.toLowerCase();
                          return role == 'sales' ||
                              role == 'team leader' ||
                              role == 'manager';
                        }).toList() ??
                        [];

                    final items =
                        filteredSales.map((e) {
                          return MultiSelectItem(
                            id: e.id ?? '',
                            name: e.name ?? '',
                          );
                        }).toList();

                    return MultiSelectDropdown(
                      hint: "Choose Sales (Multiple)",
                      items: items,
                      selectedIds: _selectedSalesIds,
                      selectedNames: _selectedSalesNames,
                      onSelectionChanged: (ids, names) {
                        setState(() {
                          _selectedSalesIds = ids;
                          _selectedSalesNames = names;
                        });
                      },
                    );
                  } else if (state is SalesLoading) {
                    return Center(
                      child: SizedBox(
                        height: (24 * tabletHeightScale).h,
                        width: (24 * tabletWidthScale).w,
                        child: const CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is SalesError) {
                    return Text(
                      "Error: ${state.message}",
                      style: TextStyle(fontSize: (14 * tabletFontScale).sp),
                    );
                  }
                  return const SizedBox();
                },
              ),
              SizedBox(height: (12 * tabletHeightScale).h),

              // Developers Multi Select
              BlocBuilder<DevelopersCubit, DevelopersState>(
                builder: (context, state) {
                  if (state is DeveloperSuccess) {
                    final items =
                        state.developersModel.data.map((dev) {
                          return MultiSelectItem(id: dev.id, name: dev.name);
                        }).toList();

                    return MultiSelectDropdown(
                      hint: "Choose Developers (Multiple)",
                      items: items,
                      selectedIds: _selectedDeveloperIds,
                      selectedNames: _selectedDeveloperNames,
                      onSelectionChanged: (ids, names) {
                        setState(() {
                          _selectedDeveloperIds = ids;
                          _selectedDeveloperNames = names;
                        });
                      },
                    );
                  } else if (state is DeveloperLoading) {
                    return Center(
                      child: SizedBox(
                        height: (24 * tabletHeightScale).h,
                        width: (24 * tabletWidthScale).w,
                        child: const CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is DeveloperError) {
                    return Text(
                      "Error: ${state.error}",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: (14 * tabletFontScale).sp,
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              SizedBox(height: (12 * tabletHeightScale).h),

              // Channels Multi Select
              BlocBuilder<ChannelCubit, ChannelState>(
                builder: (context, state) {
                  if (state is ChannelLoaded) {
                    final items =
                        state.channelResponse.data.map((channel) {
                          return MultiSelectItem(
                            id: channel.id,
                            name: channel.name,
                          );
                        }).toList();

                    return MultiSelectDropdown(
                      hint: "Choose Channels (Multiple)",
                      items: items,
                      selectedIds: _selectedChannelIds,
                      selectedNames: _selectedChannelNames,
                      onSelectionChanged: (ids, names) {
                        setState(() {
                          _selectedChannelIds = ids;
                          _selectedChannelNames = names;
                        });
                      },
                    );
                  } else if (state is ChannelLoading) {
                    return Center(
                      child: SizedBox(
                        height: (24 * tabletHeightScale).h,
                        width: (24 * tabletWidthScale).w,
                        child: const CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is ChannelError) {
                    return Text(
                      "Error: ${state.message}",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: (14 * tabletFontScale).sp,
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              SizedBox(height: (12 * tabletHeightScale).h),

              // Projects Multi Select
              BlocBuilder<ProjectsCubit, ProjectsState>(
                builder: (context, state) {
                  if (state is ProjectsSuccess) {
                    final items =
                        state.projectsModel.data!.map((project) {
                          return MultiSelectItem(
                            id: project.id!,
                            name: project.name!,
                          );
                        }).toList();

                    return MultiSelectDropdown(
                      hint: "Choose Projects (Multiple)",
                      items: items,
                      selectedIds: _selectedProjectIds,
                      selectedNames: _selectedProjectNames,
                      onSelectionChanged: (ids, names) {
                        setState(() {
                          _selectedProjectIds = ids;
                          _selectedProjectNames = names;
                        });
                      },
                    );
                  } else if (state is ProjectsLoading) {
                    return Center(
                      child: SizedBox(
                        height: (24 * tabletHeightScale).h,
                        width: (24 * tabletWidthScale).w,
                        child: const CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is ProjectsError) {
                    return Text(
                      "Error: ${state.error}",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: (14 * tabletFontScale).sp,
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              SizedBox(height: (12 * tabletHeightScale).h),

              // Campaigns Multi Select
              BlocBuilder<GetCampaignsCubit, GetCampaignsState>(
                builder: (context, state) {
                  if (state is GetCampaignsSuccess) {
                    final items =
                        state.campaigns.data!.map((campaign) {
                          return MultiSelectItem(
                            id: campaign.id!,
                            name: campaign.campainName!,
                          );
                        }).toList();

                    return MultiSelectDropdown(
                      hint: "Choose Campaigns (Multiple)",
                      items: items,
                      selectedIds: _selectedCampaignIds,
                      selectedNames: _selectedCampaignNames,
                      onSelectionChanged: (ids, names) {
                        setState(() {
                          _selectedCampaignIds = ids;
                          _selectedCampaignNames = names;
                        });
                      },
                    );
                  } else if (state is GetCampaignsLoading) {
                    return Center(
                      child: SizedBox(
                        height: (24 * tabletHeightScale).h,
                        width: (24 * tabletWidthScale).w,
                        child: const CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is GetCampaignsFailure) {
                    return Text(
                      "Error: ${state.message}",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: (14 * tabletFontScale).sp,
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              SizedBox(height: (12 * tabletHeightScale).h),

              // Communication Ways Multi Select
              BlocBuilder<GetCommunicationWaysCubit, GetCommunicationWaysState>(
                builder: (context, state) {
                  if (state is GetCommunicationWaysLoaded) {
                    final items =
                        state.response.data!.map((way) {
                          return MultiSelectItem(id: way.id!, name: way.name!);
                        }).toList();

                    return MultiSelectDropdown(
                      hint: "Choose Communication Ways (Multiple)",
                      items: items,
                      selectedIds: _selectedCommunicationWayIds,
                      selectedNames: _selectedCommunicationWayNames,
                      onSelectionChanged: (ids, names) {
                        setState(() {
                          _selectedCommunicationWayIds = ids;
                          _selectedCommunicationWayNames = names;
                        });
                      },
                    );
                  } else if (state is GetCommunicationWaysLoading) {
                    return Center(
                      child: SizedBox(
                        height: (24 * tabletHeightScale).h,
                        width: (24 * tabletWidthScale).w,
                        child: const CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is GetCommunicationWaysError) {
                    return Text(
                      "Error: ${state.message}",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: (14 * tabletFontScale).sp,
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              SizedBox(height: (12 * tabletHeightScale).h),

              // Stages Multi Select
              BlocBuilder<StagesCubit, StagesState>(
                builder: (context, state) {
                  if (state is StagesLoaded) {
                    final items =
                        state.stages.map((stage) {
                          return MultiSelectItem(
                            id: stage.id!,
                            name: stage.name!,
                          );
                        }).toList();

                    return MultiSelectDropdown(
                      hint: "Choose Stages (Multiple)",
                      items: items,
                      selectedIds: _selectedStageIds,
                      selectedNames: _selectedStageNames,
                      onSelectionChanged: (ids, names) {
                        setState(() {
                          _selectedStageIds = ids;
                          _selectedStageNames = names;
                        });
                      },
                    );
                  } else if (state is StagesLoading) {
                    return Center(
                      child: SizedBox(
                        height: (24 * tabletHeightScale).h,
                        width: (24 * tabletWidthScale).w,
                        child: const CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is StagesError) {
                    return Text(
                      "Error: ${state.message}",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: (14 * tabletFontScale).sp,
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              SizedBox(height: (12 * tabletHeightScale).h),

              // Stage Date Fields
              buildDateField("Stage Date (Start)", _oldStageStartDate, (
                picked,
              ) {
                _oldStageStartDate = picked;
                setState(() {});
              }),
              SizedBox(height: (14 * tabletHeightScale).h),
              buildDateField("Stage Date (End)", _oldStageEndDate, (picked) {
                _oldStageEndDate = picked;
                setState(() {});
              }),
              SizedBox(height: (14 * tabletHeightScale).h),
              // Added By / Assigned From / Assigned To (Single Selection)
              BlocBuilder<SalesCubit, SalesState>(
                builder: (context, state) {
                  if (state is SalesLoaded) {
                    final users = state.salesData.data ?? [];
                    return Column(
                      children: [
                        // Single Select Dropdown for Added By
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: (12 * tabletWidthScale).w,
                            vertical: (4 * tabletHeightScale).h,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(
                              (8 * tabletScale).r,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: Text(
                                _selectedAddedBy ?? "Choose Added By",
                                style: TextStyle(
                                  fontSize: (14 * tabletFontScale).sp,
                                  color:
                                      _selectedAddedBy == null
                                          ? Colors.black
                                          : Theme.of(context).brightness ==
                                              Brightness.light
                                          ? const Color(0xff080719)
                                          : const Color(0xffFFFFFF),
                                ),
                              ),
                              items:
                                  users
                                      .where((e) => e.userlog?.name != null)
                                      .map((e) {
                                        return DropdownMenuItem<String>(
                                          value: e.userlog?.id,
                                          child: Text(
                                            e.userlog?.name ?? '',
                                            style: TextStyle(
                                              fontSize:
                                                  (14 * tabletFontScale).sp,
                                            ),
                                          ),
                                        );
                                      })
                                      .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  final user = users.firstWhere(
                                    (e) => e.userlog?.id == value,
                                  );
                                  setState(() {
                                    _selectedAddedById = value;
                                    _selectedAddedBy = user.userlog?.name;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: (12 * tabletHeightScale).h),

                        // Single Select Dropdown for Assigned From
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: (12 * tabletWidthScale).w,
                            vertical: (4 * tabletHeightScale).h,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(
                              (8 * tabletScale).r,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: Text(
                                _selectedAssignedFrom ?? "Choose Assigned From",
                                style: TextStyle(
                                  fontSize: (14 * tabletFontScale).sp,
                                  color:
                                      _selectedAssignedFrom == null
                                          ? Colors.black
                                          : Theme.of(context).brightness ==
                                              Brightness.light
                                          ? const Color(0xff080719)
                                          : const Color(0xffFFFFFF),
                                ),
                              ),
                              items:
                                  users
                                      .where((e) => e.userlog?.name != null)
                                      .map((e) {
                                        return DropdownMenuItem<String>(
                                          value: e.userlog?.id,
                                          child: Text(
                                            e.userlog?.name ?? '',
                                            style: TextStyle(
                                              fontSize:
                                                  (14 * tabletFontScale).sp,
                                            ),
                                          ),
                                        );
                                      })
                                      .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  final user = users.firstWhere(
                                    (e) => e.userlog?.id == value,
                                  );
                                  setState(() {
                                    _selectedAssignedFromId = value;
                                    _selectedAssignedFrom = user.userlog?.name;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: (12 * tabletHeightScale).h),

                        // Single Select Dropdown for Assigned To
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: (12 * tabletWidthScale).w,
                            vertical: (4 * tabletHeightScale).h,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(
                              (8 * tabletScale).r,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: Text(
                                _selectedAssignedTo ?? "Choose Assigned To",
                                style: TextStyle(
                                  fontSize: (14 * tabletFontScale).sp,
                                  color:
                                      _selectedAssignedTo == null
                                          ? Colors.black
                                          : Theme.of(context).brightness ==
                                              Brightness.light
                                          ? const Color(0xff080719)
                                          : const Color(0xffFFFFFF),
                                ),
                              ),
                              items:
                                  users.map((e) {
                                    return DropdownMenuItem<String>(
                                      value: e.id,
                                      child: Text(
                                        e.name ?? '',
                                        style: TextStyle(
                                          fontSize: (14 * tabletFontScale).sp,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  final user = users.firstWhere(
                                    (e) => e.id == value,
                                  );
                                  setState(() {
                                    _selectedAssignedToId = value;
                                    _selectedAssignedTo = user.name;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
              SizedBox(height: (14 * tabletHeightScale).h),

              // Creation Date Fields
              buildDateField("Creation Date (Start)", _startDate, (picked) {
                _startDate = picked;
                setState(() {});
              }),
              SizedBox(height: (12 * tabletHeightScale).h),
              buildDateField("Creation Date (End)", _endDate, (picked) {
                _endDate = picked;
                setState(() {});
              }),
              SizedBox(height: (14 * tabletHeightScale).h),

              // Last Stage Update Fields
              buildDateField(
                "Last Stage Update (Start)",
                _lastStageUpdateStart,
                (picked) {
                  _lastStageUpdateStart = picked;
                  setState(() {});
                },
              ),
              SizedBox(height: (14 * tabletHeightScale).h),
              buildDateField("Last Stage Update (End)", _lastStageUpdateEnd, (
                picked,
              ) {
                _lastStageUpdateEnd = picked;
                setState(() {});
              }),
              SizedBox(height: (14 * tabletHeightScale).h),

              // Last Comment Date Fields
              buildDateField(
                "Last Comment Date (Start)",
                _lastCommentDateStart,
                (picked) {
                  _lastCommentDateStart = picked;
                  setState(() {});
                },
              ),
              SizedBox(height: (14 * tabletHeightScale).h),
              buildDateField("Last Comment Date (End)", _lastCommentDateEnd, (
                picked,
              ) {
                _lastCommentDateEnd = picked;
                setState(() {});
              }),
              SizedBox(height: (20 * tabletHeightScale).h),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          width: (1 * tabletScale).w,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Constants.maincolor
                                  : Constants.mainDarkmodecolor,
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
                          // تنظيف كل الفلاتر
                          _nameController.clear();

                          // Multi select lists
                          _selectedSalesIds = [];
                          _selectedSalesNames = [];
                          _selectedDeveloperIds = [];
                          _selectedDeveloperNames = [];
                          _selectedProjectIds = [];
                          _selectedProjectNames = [];
                          _selectedStageIds = [];
                          _selectedStageNames = [];
                          _selectedChannelIds = [];
                          _selectedChannelNames = [];
                          _selectedCommunicationWayIds = [];
                          _selectedCommunicationWayNames = [];
                          _selectedCampaignIds = [];
                          _selectedCampaignNames = [];

                          // Single select
                          _selectedAddedBy = null;
                          _selectedAssignedFrom = null;
                          _selectedAssignedTo = null;
                          _selectedAddedById = null;
                          _selectedAssignedFromId = null;
                          _selectedAssignedToId = null;

                          // Dates
                          _startDate = null;
                          _endDate = null;
                          _lastStageUpdateStart = null;
                          _lastStageUpdateEnd = null;
                          _lastCommentDateStart = null;
                          _lastCommentDateEnd = null;
                          _oldStageStartDate = null;
                          _oldStageEndDate = null;
                        });

                        Navigator.pop(context, {
                          'name': null,
                          'salesIds': <String>[],
                          'developerIds': <String>[],
                          'projectIds': <String>[],
                          'stageIds': <String>[],
                          'channelIds': <String>[],
                          'campaignIds': <String>[],
                          'communicationWayIds': <String>[],
                          'addedBy': null,
                          'assignedFrom': null,
                          'assignedTo': null,
                          'startDate': null,
                          'endDate': null,
                          'lastStageUpdateStart': null,
                          'lastStageUpdateEnd': null,
                          'lastCommentDateStart': null,
                          'lastCommentDateEnd': null,
                          'oldStageDateStart': null,
                          'oldStageDateEnd': null,
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
                        bool isValidDateRange(DateTime? start, DateTime? end) {
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

                        if (!isValidDateRange(
                          _lastCommentDateStart,
                          _lastCommentDateEnd,
                        )) {
                          showValidationDialog(
                            "Please select both start and end date for last comment date.",
                          );
                          return;
                        }

                        if (!isValidDateRange(
                          _oldStageStartDate,
                          _oldStageEndDate,
                        )) {
                          showValidationDialog(
                            "Please select both start and end date for old stage date.",
                          );
                          return;
                        }

                        Navigator.pop(context, {
                          'name':
                              _nameController.text.trim().isEmpty
                                  ? null
                                  : _nameController.text.trim(),
                          'salesIds': _selectedSalesIds,
                          'developerIds': _selectedDeveloperIds,
                          'projectIds': _selectedProjectIds,
                          'stageIds': _selectedStageIds,
                          'channelIds': _selectedChannelIds,
                          'campaignIds': _selectedCampaignIds,
                          'communicationWayIds': _selectedCommunicationWayIds,
                          'addedBy': _selectedAddedById,
                          'assignedFrom': _selectedAssignedFromId,
                          'assignedTo': _selectedAssignedToId,
                          'startDate': _startDate,
                          'endDate': _endDate,
                          'lastStageUpdateStart': _lastStageUpdateStart,
                          'lastStageUpdateEnd': _lastStageUpdateEnd,
                          'lastCommentDateStart': _lastCommentDateStart,
                          'lastCommentDateEnd': _lastCommentDateEnd,
                          'oldStageDateStart': _oldStageStartDate,
                          'oldStageDateEnd': _oldStageEndDate,
                        });
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
    );
  }
}

class MultiSelectItem {
  final String id;
  final String name;

  MultiSelectItem({required this.id, required this.name});
}

class MultiSelectDropdown extends StatefulWidget {
  final String hint;
  final List<MultiSelectItem> items;
  final List<String> selectedIds;
  final List<String> selectedNames;
  final Function(List<String>, List<String>) onSelectionChanged;

  const MultiSelectDropdown({
    super.key,
    required this.hint,
    required this.items,
    required this.selectedIds,
    required this.selectedNames,
    required this.onSelectionChanged,
  });

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : const Color(0xff000000),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: InkWell(
        onTap: () => _showMultiSelectDialog(context),
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.selectedNames.isEmpty
                      ? widget.hint
                      : widget.selectedNames.join(', '),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color:
                        isDark
                            ? Colors.white
                            : (widget.selectedNames.isEmpty
                                ? Colors.black
                                : const Color(0xff000000)),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                size: 20.sp,
                color: isDark ? Colors.white : Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMultiSelectDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // نسخة محلية من التحديدات
    List<String> tempSelectedIds = List.from(widget.selectedIds);
    List<String> tempSelectedNames = List.from(widget.selectedNames);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            widget.hint,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final isSelected = tempSelectedIds.contains(item.id);

                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            tempSelectedIds.remove(item.id);
                            tempSelectedNames.remove(item.name);
                          } else {
                            tempSelectedIds.add(item.id);
                            tempSelectedNames.add(item.name);
                          }
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8.h,
                          horizontal: 8.w,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24.w,
                              height: 24.w,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? (isDark
                                              ? Constants.mainDarkmodecolor
                                              : Constants.maincolor)
                                          : Colors.grey,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4.r),
                                color:
                                    isSelected
                                        ? (isDark
                                            ? Constants.mainDarkmodecolor
                                            : Constants.maincolor)
                                        : Colors.transparent,
                              ),
                              child:
                                  isSelected
                                      ? Icon(
                                        Icons.check,
                                        size: 18.sp,
                                        color: Colors.white,
                                      )
                                      : null,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              ),
            ),
            TextButton(
              onPressed: () {
                widget.onSelectionChanged(tempSelectedIds, tempSelectedNames);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor:
                    isDark ? Constants.mainDarkmodecolor : Constants.maincolor,
              ),
              child: Text(
                'OK',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
