// ignore_for_file: file_names, deprecated_member_use, must_be_immutable, unused_field

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:intl/intl.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_state.dart';
import 'package:homewalkers_app/presentation/viewModels/meeting/cubit/meetingcomments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/meeting/cubit/meetingcomments_state.dart';
import 'package:homewalkers_app/data/models/meetingComments_model.dart';

class MeetingCommentsScreen extends StatefulWidget {
  String? userId;
  MeetingCommentsScreen({super.key, this.userId});

  @override
  State<MeetingCommentsScreen> createState() => _MeetingCommentsScreenState();
}

class _MeetingCommentsScreenState extends State<MeetingCommentsScreen> {
  final ScrollController _scrollController = ScrollController();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _salesController =
      TextEditingController(); // للبحث في المبيعات

  // Multi Selection
  String? _selectedStageIds;
  String? _selectedStageNames;
  String? _selectedSalesIds;
  String? _selectedSalesNames;

  // Single Selection (optional)
  String? _selectedDeveloperId;

  // Dates
  String? _stageDateFrom;
  String? _stageDateTo;
  String? _commentDateFrom;
  String? _commentDateTo;

  @override
  void initState() {
    super.initState();

    final cubit = context.read<MeetingCommentsCubit>();
    cubit.fetchMeetingComments(userId: widget.userId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StagesCubit>().fetchStages();
      context.read<SalesCubit>().fetchSales();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 150 &&
          !cubit.isFetching &&
          cubit.hasNextPage) {
        cubit.fetchMeetingComments(isLoadMore: true);
      }
    });
  }

  String formatDateDubai(String? date) {
    if (date == null) return "-";

    final parsed = DateTime.tryParse(date);
    if (parsed == null) return "-";

    // تحويل التوقيت لتوقيت دبي (UTC +4)
    final dubaiTime = parsed.toUtc().add(const Duration(hours: 4));

    return DateFormat('dd MMM yyyy • hh:mm a').format(dubaiTime);
  }

  /// 🔹 Filter Sheet
  void _showFilterSheet() {
    final cubit = context.read<MeetingCommentsCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Header مع زر إغلاق
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Filters",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    /// 🔹 Lead Name
                    _buildFilterSection(
                      title: "Lead Name",
                      child: TextField(
                        controller: _nameController,
                        decoration: _buildInputDecoration(
                          hintText: "Enter lead name",
                          prefixIcon: Icons.person_outline,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 🔹 Phone
                    _buildFilterSection(
                      title: "Phone Number",
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _buildInputDecoration(
                          hintText: "Enter phone number",
                          prefixIcon: Icons.phone_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 🔹 Stages
                    _buildFilterSection(
                      title: "Stage",
                      child: BlocBuilder<StagesCubit, StagesState>(
                        builder: (context, state) {
                          if (state is StagesLoaded) {
                            final allowedStages =
                                state.stages.where((stage) {
                                  final name = stage.name?.toLowerCase();
                                  return name == 'eoi' ||
                                      name == 'done deal' ||
                                      name == 'meeting';
                                }).toList();

                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedStageIds,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.flag_outlined,
                                    color: Colors.grey,
                                  ),
                                ),
                                hint: const Text("Choose Stage"),
                                items:
                                    allowedStages.map((stage) {
                                      return DropdownMenuItem<String>(
                                        value: stage.id,
                                        child: Text(
                                          stage.name ?? '',
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setModalState(() {
                                    _selectedStageIds = value;
                                    final selectedStage = allowedStages
                                        .firstWhere(
                                          (e) => e.id == value,
                                          orElse: () => allowedStages.first,
                                        );
                                    _selectedStageNames = selectedStage.name;
                                  });
                                },
                              ),
                            );
                          }

                          if (state is StagesLoading) {
                            return const Center(
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// 📅 Stage Dates Section
                    _buildFilterSection(
                      title: "Stage Date Range",
                      child: Column(
                        children: [
                          _buildDatePicker(
                            "From",
                            _stageDateFrom,
                            (v) => setModalState(() => _stageDateFrom = v),
                          ),
                          const SizedBox(height: 12),
                          _buildDatePicker(
                            "To",
                            _stageDateTo,
                            (v) => setModalState(() => _stageDateTo = v),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// 📅 Comment Dates Section
                    _buildFilterSection(
                      title: "Comment Date Range",
                      child: Column(
                        children: [
                          _buildDatePicker(
                            "From",
                            _commentDateFrom,
                            (v) => setModalState(() => _commentDateFrom = v),
                          ),
                          const SizedBox(height: 12),
                          _buildDatePicker(
                            "To",
                            _commentDateTo,
                            (v) => setModalState(() => _commentDateTo = v),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    /// 🔹 Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _selectedStageIds = null;
                                _selectedStageNames = null;
                                _selectedDeveloperId = null;
                                _nameController.clear();
                                _phoneController.clear();
                                _stageDateFrom = null;
                                _stageDateTo = null;
                                _commentDateFrom = null;
                                _commentDateTo = null;
                              });
                              Navigator.pop(context);
                              cubit.fetchMeetingComments(userId: widget.userId);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.shade400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Reset",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              cubit.fetchMeetingComments(
                                userId: widget.userId,
                                stageIds: _selectedStageIds,
                                leadNames:
                                    _nameController.text.isNotEmpty
                                        ? _nameController.text
                                        : null,
                                phones:
                                    _phoneController.text.isNotEmpty
                                        ? _phoneController.text
                                        : null,
                                stageDateFrom: _stageDateFrom,
                                stageDateTo: _stageDateTo,
                                commentCreatedFrom: _commentDateFrom,
                                commentCreatedTo: _commentDateTo,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Constants.maincolor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Apply",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// دالة مساعدة لبناء أقسام الفلتر بشكل موحد
  Widget _buildFilterSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  /// دالة مساعدة لبناء Decoration موحد لحقول الإدخال
  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
      prefixIcon: Icon(prefixIcon, color: Colors.grey.shade500, size: 22),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.white,
    );
  }

  /// دالة بناء منتقي التاريخ
  Widget _buildDatePicker(
    String label,
    String? value,
    Function(String?) onSelect,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2040),
          initialDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF2563EB),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          String dateTimeString;
          if (label.contains("From")) {
            dateTimeString =
                DateTime(
                  picked.year,
                  picked.month,
                  picked.day,
                  0,
                  0,
                  0,
                ).toIso8601String();
          } else {
            dateTimeString =
                DateTime(
                  picked.year,
                  picked.month,
                  picked.day,
                  23,
                  59,
                  59,
                ).toIso8601String();
          }
          onSelect(dateTimeString);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value != null
                    ? DateFormat('dd MMM yyyy').format(DateTime.parse(value))
                    : "Select $label",
                style: TextStyle(
                  fontSize: 15,
                  color: value != null ? Colors.black87 : Colors.grey.shade500,
                ),
              ),
            ),
            if (value != null)
              IconButton(
                onPressed: () => onSelect(null),
                icon: Icon(Icons.close, size: 16, color: Colors.grey.shade400),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  String formatDate(String? date) {
    if (date == null) return "-";
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return "-";
    return DateFormat('dd MMM yyyy • hh:mm a').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MeetingCommentsCubit>();

    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Meeting Comments",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: BlocBuilder<MeetingCommentsCubit, MeetingCommentsState>(
        builder: (context, state) {
          if (state is MeetingCommentsLoading && cubit.allComments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MeetingCommentsFailure) {
            return Center(child: Text(state.error));
          }
          final comments = cubit.allComments;

          if (comments.isEmpty) {
            return const Center(
              child: Text(
                "No Results Found",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh:
                () async => cubit.fetchMeetingComments(userId: widget.userId),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: comments.length + (cubit.hasNextPage ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= comments.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _buildProfessionalCard(comments[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfessionalCard(LeadHistoryData item) {
    final lead = item.lead;
    final project = lead?.project;
    final stage = item.stage;
    final commentUserName = item.commentBy?.name ?? "Unknown";

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  lead?.name ?? "No Name",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  stage?.name ?? "-",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow("Project", project?.name),
          _infoRow("Developer", project?.developer?.name),
          _infoRow("Sales Developer", item.salesdeveloperName),
          _infoRow("City", project?.city?.name),
          _infoRow("Phone", lead?.phone),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 14),
          // Comment writer
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  commentUserName.isNotEmpty
                      ? commentUserName[0].toUpperCase()
                      : "U",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  commentUserName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Comment text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item.comment ?? "",
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Stage Date: ${formatDate(item.stageDate)}",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          Text(
            "Comment Date: ${formatDateDubai(item.createdAt)}",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),

          if (item.replies != null && item.replies!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  "Replies (${item.replies!.length})",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                children:
                    item.replies!.map((reply) {
                      final replyUserName = reply.user?.name ?? "Unknown";
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.green.shade100,
                                  child: Text(
                                    replyUserName.isNotEmpty
                                        ? replyUserName[0].toUpperCase()
                                        : "R",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    replyUserName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              reply.comment ?? "",
                              style: const TextStyle(fontSize: 14, height: 1.4),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              formatDate(reply.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          Expanded(
            child: Text(value ?? "-", style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
