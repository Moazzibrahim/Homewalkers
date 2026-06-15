// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'dart:developer';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/campaign_api_service.dart';
import 'package:homewalkers_app/data/data_sources/communication_way_api_service.dart';
import 'package:homewalkers_app/data/data_sources/create_lead_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_channels_api_service.dart';
import 'package:homewalkers_app/data/data_sources/projects_api_service.dart';
import 'package:homewalkers_app/data/data_sources/stages_api_service.dart';
import 'package:homewalkers_app/presentation/viewModels/campaigns/get/cubit/get_campaigns_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/channels/channels_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/channels/channels_state.dart';
import 'package:homewalkers_app/presentation/viewModels/communication_ways/cubit/get_communication_ways_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/create_lead/cubit/create_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/projects/projects_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/custom_text_field_widget.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateLeadScreen extends StatefulWidget {
  const CreateLeadScreen({super.key});

  @override
  State<CreateLeadScreen> createState() => _CreateLeadScreenState();
}

class _CreateLeadScreenState extends State<CreateLeadScreen> {
  final TextEditingController _dateController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _budgetController = TextEditingController();
  final TextEditingController _salesSearchController = TextEditingController();
  late TextEditingController _campaignRedirectLinkController;

  final List<Map<String, TextEditingController>> _qaControllers = [];

  // Changed to support multi-select for projects
  List<String> _selectedProjectIds = [];
  List<String> _selectedProjectNames = [];

  String? selectedProjectId; // kept for backward compat with cubit call
  String? selectedStageId;
  String? selectedStageName;
  String? _selectedCommunicationWayId;
  String? _selectedChannelId;
  String? _selectedCampaignId;
  String? _selectedSalesId;
  bool isCold = false;
  String? _fullPhoneNumber;
  String? _selectedSalesFcmToken;
  String? role;
  String? id;
  String? name;
  List<String> _selectedSalesFcmTokens = [];
  // Sales multi-select
  List<String> _selectedSalesIds = [];
  List<String> _selectedSalesNames = [];

  // Channel multi-select
  List<String> _selectedChannelIds = [];
  List<String> _selectedChannelNames = [];
  List<String> _selectedCampaignIds = [];
  List<String> _selectedCampaignNames = [];

  Color get _mainColor =>
      Theme.of(context).brightness == Brightness.light
          ? Constants.maincolor
          : Constants.mainDarkmodecolor;

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: DropdownButtonFormField<T>(
        isExpanded: true,
        value: value,
        items: items,
        onChanged: onChanged,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _mainColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  void _openSalesSelectionPanel(BuildContext context, SalesLoaded state) {
    final searchController = TextEditingController();
    final isTeamLeader = role?.toLowerCase() == 'team leader';
    final isManager = role?.toLowerCase() == 'manager';

    final filteredSales =
        state.salesData.data?.where((sales) {
          final r = sales.userlog?.role?.toLowerCase();
          final n = sales.name;

          // أولاً استبعد default m دايماً
          if (n?.toLowerCase() == 'default m') return false;

          // لو team leader، اظهر بس السيلز اللي teamLeaderName بتاعهم = اسم اليوزر الحالي
          if (isTeamLeader) {
            return r == 'sales' &&
                (sales.teamleader?.name?.toLowerCase() == name?.toLowerCase());
          }

          if (isManager) {
            return (r == 'sales' || r == 'team leader') &&
                (sales.manager?.name?.toLowerCase() == name?.toLowerCase());
          }

          // غير كده اظهر الكل (admin, marketer, etc.)
          return r == 'sales' || r == 'team leader' || r == 'manager';
        }).toList() ??
        [];

    filteredSales.sort((a, b) {
      if ((a.name ?? '').toLowerCase() == 'no sales') return -1;
      if ((b.name ?? '').toLowerCase() == 'no sales') return 1;
      return 0;
    });

    List<String> tempIds = List.from(_selectedSalesIds);
    List<String> tempNames = List.from(_selectedSalesNames);
    List<String> tempTokens = List.from(_selectedSalesFcmTokens);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final query = searchController.text.toLowerCase();
            final filtered =
                query.isEmpty
                    ? filteredSales
                    : filteredSales
                        .where(
                          (s) => (s.name ?? '').toLowerCase().contains(query),
                        )
                        .toList();

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: _mainColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Sales Selection",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _mainColor,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        hintText: "Search sales...",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder:
                          (_, __) => Divider(
                            height: 1,
                            color: Colors.grey.shade100,
                            indent: 16,
                            endIndent: 16,
                          ),
                      itemBuilder: (_, index) {
                        final sale = filtered[index];
                        final isSelected = tempIds.contains(sale.id);
                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                tempIds.remove(sale.id);
                                tempNames.remove(sale.name);
                                tempTokens.removeWhere(
                                  (t) =>
                                      sale.userlog?.fcmTokens
                                          ?.map((e) => e.token ?? '')
                                          .contains(t) ??
                                      false,
                                );
                              } else {
                                tempIds.add(sale.id!);
                                tempNames.add(sale.name!);
                                final tokens =
                                    sale.userlog?.fcmTokens
                                        ?.map((e) => e.token ?? '')
                                        .where((t) => t.isNotEmpty)
                                        .toList() ??
                                    [];
                                if (tokens.isEmpty &&
                                    sale.userlog?.fcmtoken != null) {
                                  tempTokens.add(sale.userlog!.fcmtoken!);
                                } else {
                                  tempTokens.addAll(tokens);
                                }
                              }
                            });
                          },
                          child: Container(
                            color:
                                isSelected
                                    ? _mainColor.withOpacity(0.04)
                                    : Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  if (isSelected)
                                    Container(
                                      width: 3,
                                      height: 20,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: _mainColor,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      sale.name ?? '',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                        color:
                                            isSelected
                                                ? _mainColor
                                                : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check,
                                      color: _mainColor,
                                      size: 18,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      24 + MediaQuery.of(context).padding.bottom, // ✅
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedSalesIds = List.from(tempIds);
                            _selectedSalesNames = List.from(tempNames);
                            _selectedSalesId =
                                _selectedSalesIds.isNotEmpty
                                    ? _selectedSalesIds.first
                                    : null;
                            _selectedSalesFcmTokens = List.from(tempTokens);
                          });
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _mainColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Confirm Selection",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openChannelSelectionPanel(BuildContext context, ChannelLoaded state) {
    final searchController = TextEditingController(); // 👈 أضفنا search
    List<String> tempIds = List.from(_selectedChannelIds);
    List<String> tempNames = List.from(_selectedChannelNames);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final query = searchController.text.toLowerCase();
            final filtered =
                query.isEmpty
                    ? state.channelResponse.data
                    : state.channelResponse.data
                        .where((c) => c.name.toLowerCase().contains(query))
                        .toList();

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: _mainColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Channel Selection",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _mainColor,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 👇 Search field جديد
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        hintText: "Search channels...",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder:
                          (_, __) => Divider(
                            height: 1,
                            color: Colors.grey.shade100,
                            indent: 16,
                            endIndent: 16,
                          ),
                      itemBuilder: (_, index) {
                        final channel = filtered[index];
                        final isSelected = tempIds.contains(channel.id);
                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                tempIds.remove(channel.id);
                                tempNames.remove(channel.name);
                              } else {
                                tempIds.add(channel.id!);
                                tempNames.add(channel.name);
                              }
                            });
                          },
                          child: Container(
                            color:
                                isSelected
                                    ? _mainColor.withOpacity(0.04)
                                    : Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  if (isSelected)
                                    Container(
                                      width: 3,
                                      height: 20,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: _mainColor,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      channel.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                        color:
                                            isSelected
                                                ? _mainColor
                                                : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check,
                                      color: _mainColor,
                                      size: 18,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      24 + MediaQuery.of(context).padding.bottom, // ✅
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedChannelIds = List.from(tempIds);
                            _selectedChannelNames = List.from(tempNames);
                            _selectedChannelId =
                                _selectedChannelIds.isNotEmpty
                                    ? _selectedChannelIds.first
                                    : null;
                          });
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _mainColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Confirm Selection",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _addQuestionAnswerField() {
    if (_qaControllers.length < 5) {
      setState(() {
        _qaControllers.add({
          'question': TextEditingController(),
          'answer': TextEditingController(),
        });
      });
    }
  }

  void _removeQuestionAnswerField(int index) {
    setState(() {
      _qaControllers[index]['question']?.dispose();
      _qaControllers[index]['answer']?.dispose();
      _qaControllers.removeAt(index);
    });
  }

  Map<String, String> _getQAForSubmission() {
    Map<String, String> qaMap = {};
    for (int i = 0; i < _qaControllers.length; i++) {
      final question = _qaControllers[i]['question']?.text.trim() ?? '';
      final answer = _qaControllers[i]['answer']?.text.trim() ?? '';
      if (question.isNotEmpty && answer.isNotEmpty) {
        qaMap['question${i + 1}_text'] = question;
        qaMap['question${i + 1}_answer'] = answer;
      }
    }
    return qaMap;
  }

  bool get _isAdminOrMarketer {
    return role?.toLowerCase() == 'admin' || role?.toLowerCase() == 'marketer';
  }

  @override
  void initState() {
    super.initState();
    _campaignRedirectLinkController = TextEditingController();
    _addQuestionAnswerField();
    init();
  }

  @override
  void dispose() {
    _campaignRedirectLinkController.dispose();
    for (var qa in _qaControllers) {
      qa['question']?.dispose();
      qa['answer']?.dispose();
    }
    super.dispose();
  }

  void init() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role');
      id = prefs.getString('savedid');
      name = prefs.getString('name');
      log("Role: $role, ID: $id, Name: $name");
    });
  }

  // ─── Project Selection Panel ───────────────────────────────────────────────

  void _openProjectSelectionPanel(BuildContext context, ProjectsSuccess state) {
    final searchController = TextEditingController();
    List<String> tempSelectedIds = List.from(_selectedProjectIds);
    List<String> tempSelectedNames = List.from(_selectedProjectNames);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final allProjects = state.projectsModel.data ?? [];
            final query = searchController.text.toLowerCase();
            final filtered =
                query.isEmpty
                    ? allProjects
                    : allProjects
                        .where(
                          (p) => (p.name ?? '').toLowerCase().contains(query),
                        )
                        .toList();

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                children: [
                  // ── Header ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: _mainColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Project Selection",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _mainColor,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Search ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        hintText: "Search projects...",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  // ── List ────────────────────────────────────────────
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder:
                          (_, __) => Divider(
                            height: 1,
                            color: Colors.grey.shade100,
                            indent: 16,
                            endIndent: 16,
                          ),
                      itemBuilder: (_, index) {
                        final project = filtered[index];
                        final isSelected = tempSelectedIds.contains(project.id);
                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                tempSelectedIds.remove(project.id);
                                tempSelectedNames.remove(project.name);
                              } else {
                                tempSelectedIds.add(project.id!);
                                tempSelectedNames.add(project.name!);
                              }
                            });
                          },
                          child: Container(
                            color:
                                isSelected
                                    ? _mainColor.withOpacity(0.04)
                                    : Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  if (isSelected)
                                    Container(
                                      width: 3,
                                      height: 20,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: _mainColor,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      project.name ?? '',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                        color:
                                            isSelected
                                                ? _mainColor
                                                : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check,
                                      color: _mainColor,
                                      size: 18,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ── Confirm Button ───────────────────────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      24 + MediaQuery.of(context).padding.bottom, // ✅
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedProjectIds = List.from(tempSelectedIds);
                            _selectedProjectNames = List.from(
                              tempSelectedNames,
                            );
                            selectedProjectId =
                                _selectedProjectIds.isNotEmpty
                                    ? _selectedProjectIds.first
                                    : null;
                          });
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _mainColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Confirm Selection",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openCampaignSelectionPanel(
    BuildContext context,
    GetCampaignsSuccess state,
  ) {
    final searchController = TextEditingController();
    List<String> tempIds = List.from(_selectedCampaignIds);
    List<String> tempNames = List.from(_selectedCampaignNames);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final allCampaigns = state.campaigns.data ?? [];
            final query = searchController.text.toLowerCase();
            final filtered =
                query.isEmpty
                    ? allCampaigns
                    : allCampaigns
                        .where(
                          (c) => (c.campainName ?? '').toLowerCase().contains(
                            query,
                          ),
                        )
                        .toList();

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: _mainColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Campaign Selection",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _mainColor,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        hintText: "Search campaigns...",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder:
                          (_, __) => Divider(
                            height: 1,
                            color: Colors.grey.shade100,
                            indent: 16,
                            endIndent: 16,
                          ),
                      itemBuilder: (_, index) {
                        final campaign = filtered[index];
                        final isSelected = tempIds.contains(campaign.id);
                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                tempIds.remove(campaign.id);
                                tempNames.remove(campaign.campainName);
                              } else {
                                tempIds.add(campaign.id!);
                                tempNames.add(campaign.campainName!);
                              }
                            });
                          },
                          child: Container(
                            color:
                                isSelected
                                    ? _mainColor.withOpacity(0.04)
                                    : Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  if (isSelected)
                                    Container(
                                      width: 3,
                                      height: 20,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: _mainColor,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      campaign.campainName ?? '',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                        color:
                                            isSelected
                                                ? _mainColor
                                                : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check,
                                      color: _mainColor,
                                      size: 18,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      24 + MediaQuery.of(context).padding.bottom, // ✅
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedCampaignIds = List.from(tempIds);
                            _selectedCampaignNames = List.from(tempNames);
                            _selectedCampaignId =
                                _selectedCampaignIds.isNotEmpty
                                    ? _selectedCampaignIds.first
                                    : null;
                          });
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _mainColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Confirm Selection",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCampaignField(BuildContext context) {
    return BlocBuilder<GetCampaignsCubit, GetCampaignsState>(
      builder: (context, state) {
        if (state is GetCampaignsSuccess) {
          return GestureDetector(
            onTap: () => _openCampaignSelectionPanel(context, state),
            child: _buildSelectionContainer(
              hint: "Choose Campaign",
              selectedNames: _selectedCampaignNames,
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // ─── Project Field with chips ──────────────────────────────────────────────
  Widget _buildProjectField(BuildContext context) {
    return BlocBuilder<ProjectsCubit, ProjectsState>(
      builder: (context, state) {
        if (state is ProjectsSuccess) {
          return GestureDetector(
            onTap: () => _openProjectSelectionPanel(context, state),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 54),
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      _selectedProjectIds.isNotEmpty
                          ? _mainColor.withOpacity(0.4)
                          : Colors.grey.shade200,
                ),
              ),
              child:
                  _selectedProjectIds.isEmpty
                      ? Row(
                        children: [
                          Text(
                            "Choose Project",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey.shade500,
                          ),
                        ],
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Choose Project",
                            style: TextStyle(
                              color: _mainColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              ..._selectedProjectNames.map(
                                (pName) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _mainColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _mainColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    pName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _mainColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.grey.shade500,
                                size: 18,
                              ),
                            ],
                          ),
                        ],
                      ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // ── Sales Field ──────────────────────────────────────────────
  Widget _buildSalesField(BuildContext context) {
    return BlocBuilder<SalesCubit, SalesState>(
      builder: (context, state) {
        if (state is SalesLoaded) {
          return GestureDetector(
            onTap: () => _openSalesSelectionPanel(context, state),
            child: _buildSelectionContainer(
              hint: "Choose Sales",
              selectedNames: _selectedSalesNames,
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // ── Channel Field ──────────────────────────────────────────────
  Widget _buildChannelField(BuildContext context) {
    return BlocBuilder<ChannelCubit, ChannelState>(
      builder: (context, state) {
        if (state is ChannelLoaded) {
          return GestureDetector(
            onTap: () => _openChannelSelectionPanel(context, state),
            child: _buildSelectionContainer(
              hint: "Choose Channel",
              selectedNames: _selectedChannelNames,
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // ── مساعد مشترك للـ container ──────────────────────────────────
  Widget _buildSelectionContainer({
    required String hint,
    required List<String> selectedNames,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 54),
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              selectedNames.isNotEmpty
                  ? _mainColor.withOpacity(0.4)
                  : Colors.grey.shade200,
        ),
      ),
      child:
          selectedNames.isEmpty
              ? Row(
                children: [
                  Text(
                    hint,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey.shade500,
                  ),
                ],
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hint,
                    style: TextStyle(
                      color: _mainColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...selectedNames.map(
                        (n) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _mainColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _mainColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            n,
                            style: TextStyle(
                              fontSize: 12,
                              color: _mainColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey.shade500,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ProjectsCubit(ProjectsApiService())..fetchProjects(),
        ),
        BlocProvider(
          create: (_) => StagesCubit(StagesApiService())..fetchStages(),
        ),
        BlocProvider(
          create:
              (_) =>
                  GetCommunicationWaysCubit(CommunicationWayApiService())
                    ..fetchCommunicationWays(),
        ),
        BlocProvider(
          create: (_) => ChannelCubit(GetChannelsApiService())..fetchChannels(),
        ),
        BlocProvider(
          create:
              (_) => GetCampaignsCubit(CampaignApiService())..fetchCampaigns(),
        ),
        BlocProvider(
          create:
              (_) =>
                  SalesCubit(GetAllSalesApiService())
                    ..fetchAllSales()
                    ..fetchSalesOfSpecificUser(),
        ),
        BlocProvider(create: (_) => CreateLeadCubit(CreateLeadApiService())),
      ],
      child: Builder(
        builder: (context) {
          return BlocListener<CreateLeadCubit, CreateLeadState>(
            listener: (context, state) {
              if (state is CreateLeadSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                Future.delayed(const Duration(milliseconds: 1500), () {
                  Navigator.pop(context);
                });
              } else if (state is CreateLeadFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Scaffold(
              backgroundColor:
                  Theme.of(context).brightness == Brightness.light
                      ? Constants.backgroundlightmode
                      : Constants.backgroundDarkmode,
              appBar: CustomAppBar(
                title: "create lead",
                onBack: () => Navigator.pop(context),
              ),
              body: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  16 + MediaQuery.of(context).padding.bottom, // ✅ أضف ده
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ──────────────────────────────────────
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _mainColor,
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Create New Lead",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Fields ──────────────────────────────────────
                      _buildStyledTextField(
                        hint: "Full Name",
                        controller: _nameController,
                        icon: Icons.person_outline_rounded,
                      ),

                      _buildStyledTextField(
                        hint: "Email Address",
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: IntlPhoneField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: _mainColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                          initialCountryCode: 'AE',
                          onChanged: (phone) {
                            setState(() {
                              _fullPhoneNumber = phone.completeNumber;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 4),

                      // ── Project (custom panel) ───────────────────────
                      _buildProjectField(context),

                      const SizedBox(height: 4),

                      // ── Sales ────────────────────────────────────────
                      if (role != "Sales") _buildSalesField(context),

                      // ── Channel ──────────────────────────────────────
                      _buildChannelField(context),

                      // ── Campaign ──────────────────────────────────────
                      _buildCampaignField(context),

                      // ── Campaign Redirect Link (Admin/Marketer only) ──
                      if (_isAdminOrMarketer) ...[
                        _buildStyledTextField(
                          hint: "Campaign Redirect Link (Optional)",
                          controller: _campaignRedirectLinkController,
                          icon: Icons.link_rounded,
                        ),
                      ],

                      // ── Communication Way ─────────────────────────────
                      BlocBuilder<
                        GetCommunicationWaysCubit,
                        GetCommunicationWaysState
                      >(
                        builder: (context, state) {
                          if (state is GetCommunicationWaysLoaded) {
                            return _buildDropdown<String>(
                              hint: "Choose Communication Way",
                              value: _selectedCommunicationWayId,
                              items:
                                  state.response.data!.map((way) {
                                    return DropdownMenuItem<String>(
                                      value: way.id,
                                      child: Text(way.name!),
                                    );
                                  }).toList(),
                              onChanged:
                                  (val) => setState(
                                    () => _selectedCommunicationWayId = val,
                                  ),
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),

                      _buildStyledTextField(
                        hint: "Budget",
                        controller: _budgetController,
                        icon: Icons.attach_money_rounded,
                        keyboardType: TextInputType.number,
                      ),

                      // ── Q&A Section (Admin/Marketer only) ─────────────
                      if (_isAdminOrMarketer) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Questions & Answers",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Optional · up to 5 pairs",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _qaControllers.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Q&A #${index + 1}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const Spacer(),
                                            if (index > 0)
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red,
                                                  size: 20,
                                                ),
                                                onPressed:
                                                    () =>
                                                        _removeQuestionAnswerField(
                                                          index,
                                                        ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        CustomTextField(
                                          hint: "Question ${index + 1}",
                                          controller:
                                              _qaControllers[index]['question']!,
                                        ),
                                        const SizedBox(height: 6),
                                        CustomTextField(
                                          hint: "Answer ${index + 1}",
                                          controller:
                                              _qaControllers[index]['answer']!,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              if (_qaControllers.length < 5)
                                Center(
                                  child: TextButton.icon(
                                    onPressed: _addQuestionAnswerField,
                                    icon: const Icon(Icons.add_circle_outline),
                                    label: const Text("Add Question & Answer"),
                                    style: TextButton.styleFrom(
                                      foregroundColor: _mainColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 8),

                      _buildStyledTextField(
                        hint: "Notes",
                        controller: _notesController,
                        icon: Icons.notes_rounded,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 12),

                      // ── Lead Type Toggle ─────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Lead Type",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  isCold ? "Cold" : "Fresh",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isCold ? Colors.blue : Colors.green,
                                  ),
                                ),
                                Switch(
                                  activeColor: _mainColor,
                                  value: isCold,
                                  onChanged:
                                      (value) => setState(() => isCold = value),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Action Buttons ──────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _mainColor,
                                side: BorderSide(color: _mainColor),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Cancel"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: BlocBuilder<
                              CreateLeadCubit,
                              CreateLeadState
                            >(
                              builder: (context, state) {
                                final isLoading = state is CreateLeadLoading;
                                return ElevatedButton(
                                  onPressed:
                                      isLoading
                                          ? null
                                          : () async {
                                            if (_nameController.text.isEmpty ||
                                                _phoneController.text.isEmpty ||
                                                _budgetController
                                                    .text
                                                    .isEmpty ||
                                                _selectedProjectIds.isEmpty ||
                                                _selectedChannelIds.isEmpty ||
                                                _selectedCampaignIds.isEmpty) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Please fill all required fields',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }

                                            final formattedPhone =
                                                _fullPhoneNumber?.replaceAll(
                                                  '+',
                                                  '',
                                                ) ??
                                                '';

                                            final qaData =
                                                _isAdminOrMarketer
                                                    ? _getQAForSubmission()
                                                    : <String, String>{};

                                            await context.read<CreateLeadCubit>().createLead(
                                              name: _nameController.text,
                                              email: _emailController.text,
                                              phone: formattedPhone,
                                              project:
                                                  _selectedProjectIds.first,
                                              sales:
                                                  role == 'Sales'
                                                      ? id!
                                                      : _selectedSalesId!,
                                              notes: _notesController.text,
                                              leedtype:
                                                  isCold ? "Cold" : "Fresh",
                                              chanel: _selectedChannelId ?? '',
                                              communicationway:
                                                  _selectedCommunicationWayId ??
                                                  '',
                                              dayonly: _dateController.text,
                                              lastStageDateUpdated:
                                                  _dateController.text,
                                              campaign:
                                                  _selectedCampaignId ?? '',
                                              budget: _budgetController.text,
                                              campaignRedirectLink:
                                                  _isAdminOrMarketer
                                                      ? _campaignRedirectLinkController
                                                          .text
                                                      : '',
                                              question1_text:
                                                  qaData['question1_text'] ??
                                                  '',
                                              question1_answer:
                                                  qaData['question1_answer'] ??
                                                  '',
                                              question2_text:
                                                  qaData['question2_text'] ??
                                                  '',
                                              question2_answer:
                                                  qaData['question2_answer'] ??
                                                  '',
                                              question3_text:
                                                  qaData['question3_text'] ??
                                                  '',
                                              question3_answer:
                                                  qaData['question3_answer'] ??
                                                  '',
                                              question4_text:
                                                  qaData['question4_text'] ??
                                                  '',
                                              question4_answer:
                                                  qaData['question4_answer'] ??
                                                  '',
                                              question5_text:
                                                  qaData['question5_text'] ??
                                                  '',
                                              question5_answer:
                                                  qaData['question5_answer'] ??
                                                  '',
                                            );
                                            if (state is CreateLeadSuccess) {
                                              if (_selectedSalesFcmTokens
                                                  .isNotEmpty) {
                                                context
                                                    .read<NotificationCubit>()
                                                    .sendNotificationToTokens(
                                                      title: "Lead",
                                                      body:
                                                          "Lead has been created ✅",
                                                      fcmTokens:
                                                          _selectedSalesFcmTokens,
                                                    );
                                              }
                                            }
                                          },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _mainColor,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                  child:
                                      isLoading
                                          ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                          : const Text(
                                            "Add Lead",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                );
                              },
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
        },
      ),
    );
  }

  // ── Helper: styled text field ──────────────────────────────────────────────
  Widget _buildStyledTextField({
    required String hint,
    required TextEditingController controller,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon:
              icon != null
                  ? Icon(icon, color: Colors.grey.shade400, size: 20)
                  : null,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _mainColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
