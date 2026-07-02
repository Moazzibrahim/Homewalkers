// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/edit_lead/edit_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/campaigns/get/cubit/get_campaigns_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/channels/channels_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/channels/channels_state.dart';
import 'package:homewalkers_app/presentation/viewModels/communication_ways/cubit/get_communication_ways_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/projects/projects_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';

class EditLeadDialog extends StatefulWidget {
  final String userId;
  final String? initialName;
  final String? initialEmail;
  final String? initialPhone;
  final String? initialPhone2;
  final String? initialWhatsappNumber;
  final String? initialNotes;
  final String? initialProjectId;
  final String? initialStageId;
  final String? initialStalesId;
  final String? initialChannelId;
  final String? initialCampaignId;
  final String? initialCommunicationWayId;
  final bool? isCold;
  final void Function()? onSuccess;

  const EditLeadDialog({
    super.key,
    required this.userId,
    this.initialName,
    this.initialEmail,
    this.initialPhone,
    this.initialPhone2,
    this.initialWhatsappNumber,
    this.initialNotes,
    this.initialProjectId,
    this.initialStageId,
    this.initialStalesId,
    this.initialChannelId,
    this.initialCampaignId,
    this.initialCommunicationWayId,
    this.isCold,
    this.onSuccess,
  });

  @override
  State<EditLeadDialog> createState() => _EditLeadDialogState();
}

class _EditLeadDialogState extends State<EditLeadDialog> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController phone2Controller;
  late TextEditingController whatsappNumberController;
  late TextEditingController notesController;

  String? selectedProjectId;
  String? selectedProjectName;
  String? selectedStageId;
  String? selectedStageName;
  String? selectedChannelId;
  String? selectedChannelName;
  String? selectedCampaignId;
  String? selectedCampaignName;
  String? selectedStalesId;
  String? selectedCommunicationWayId;
  String? selectedCommunicationWayName;
  bool isCold = true;

  Color get _mainColor =>
      Theme.of(context).brightness == Brightness.light
          ? Constants.maincolor
          : Constants.mainDarkmodecolor;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName ?? '');
    emailController = TextEditingController(text: widget.initialEmail ?? '');
    phoneController = TextEditingController(text: widget.initialPhone ?? '');
    phone2Controller = TextEditingController(text: widget.initialPhone2 ?? '');
    whatsappNumberController = TextEditingController(
      text: widget.initialWhatsappNumber ?? '',
    );
    notesController = TextEditingController(text: widget.initialNotes ?? '');
    selectedProjectId = widget.initialProjectId;
    selectedStageId = widget.initialStageId;
    selectedChannelId = widget.initialChannelId;
    selectedStalesId = widget.initialStalesId;
    selectedCampaignId = widget.initialCampaignId;
    selectedCommunicationWayId = widget.initialCommunicationWayId;
    isCold = widget.isCold ?? true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initNamesFromState();
  }

  void _initNamesFromState() {
    // ── Project ──────────────────────────────────────
    if (selectedProjectName == null && selectedProjectId != null) {
      final projectState = context.read<ProjectsCubit>().state;
      if (projectState is ProjectsSuccess) {
        final match = projectState.projectsModel.data?.firstWhere(
          (p) => p.id.toString() == selectedProjectId,
          orElse: () => null as dynamic,
        );
        if (match != null) selectedProjectName = match.name;
      }
    }

    // ── Stage ────────────────────────────────────────
    if (selectedStageName == null && selectedStageId != null) {
      final stageState = context.read<StagesCubit>().state;
      if (stageState is StagesLoaded) {
        final match = stageState.stages.firstWhere(
          (s) => s.id.toString() == selectedStageId,
          orElse: () => null as dynamic,
        );
        if (match != null) selectedStageName = match.name;
      }
    }

    // ── Channel ──────────────────────────────────────
    if (selectedChannelName == null && selectedChannelId != null) {
      final channelState = context.read<ChannelCubit>().state;
      if (channelState is ChannelLoaded) {
        final match = channelState.channelResponse.data.firstWhere(
          (c) => c.id.toString() == selectedChannelId,
          orElse: () => null as dynamic,
        );
        if (match != null) selectedChannelName = match.name;
      }
    }

    // ── Campaign ─────────────────────────────────────
    if (selectedCampaignName == null && selectedCampaignId != null) {
      final campaignState = context.read<GetCampaignsCubit>().state;
      if (campaignState is GetCampaignsSuccess) {
        final match = campaignState.campaigns.data?.firstWhere(
          (c) => c.id.toString() == selectedCampaignId,
          orElse: () => null as dynamic,
        );
        if (match != null) selectedCampaignName = match.campainName;
      }
    }

    // ── Communication Way ─────────────────────────────
    if (selectedCommunicationWayName == null &&
        selectedCommunicationWayId != null) {
      final wayState = context.read<GetCommunicationWaysCubit>().state;
      if (wayState is GetCommunicationWaysLoaded) {
        final match = wayState.response.data?.firstWhere(
          (w) => w.id.toString() == selectedCommunicationWayId,
          orElse: () => null as dynamic,
        );
        if (match != null) selectedCommunicationWayName = match.name;
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    phone2Controller.dispose();
    whatsappNumberController.dispose();
    notesController.dispose();
    super.dispose();
  }

  // ── Generic Search Bottom Sheet ─────────────────────────────
  void _openSearchPanel<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) labelOf,
    required String Function(T) idOf,
    required String? selectedId,
    required void Function(String id, String name) onConfirm,
  }) {
    final searchController = TextEditingController();
    String? tempId = selectedId;
    String? tempName;

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
                    ? items
                    : items
                        .where(
                          (item) => labelOf(item).toLowerCase().contains(query),
                        )
                        .toList();

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                children: [
                  // ── Header ──────────────────────────────────
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
                          title,
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

                  // ── Search ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        hintText: "Search...",
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

                  // ── List ────────────────────────────────────
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
                        final item = filtered[index];
                        final isSelected = tempId == idOf(item);
                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              tempId = idOf(item);
                              tempName = labelOf(item);
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
                                      labelOf(item),
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

                  // ── Confirm Button ───────────────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      MediaQuery.of(ctx).padding.bottom +
                          16, // ← ctx مش context، وزود padding
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (tempId != null && tempName != null) {
                            onConfirm(tempId!, tempName!);
                          }
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

  // ── Helper: Selection Container ─────────────────────────────
  Widget _buildSelectionContainer({
    required String hint,
    required String? selectedName,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final bool hasValue = selectedName != null && selectedName.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color:
                  hasValue ? _mainColor.withOpacity(0.4) : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey.shade400, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasValue ? selectedName : hint,
                  style: TextStyle(
                    fontSize: 14,
                    color: hasValue ? Colors.black87 : Colors.grey.shade500,
                    fontWeight: hasValue ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper: styled text field ──────────────────────────────
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _mainColor,
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Edit Lead",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade100,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable Content ─────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStyledTextField(
                      hint: "Full Name",
                      controller: nameController,
                      icon: Icons.person_outline_rounded,
                    ),
                    _buildStyledTextField(
                      hint: "Email Address",
                      controller: emailController,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildStyledTextField(
                      hint: "Phone Number",
                      controller: phoneController,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildStyledTextField(
                      hint: "Notes",
                      controller: notesController,
                      icon: Icons.notes_rounded,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 4),

                    // ── Project ────────────────────────────────
                    BlocBuilder<ProjectsCubit, ProjectsState>(
                      builder: (context, state) {
                        if (state is ProjectsSuccess) {
                          // ✅ أول ما الداتا توصل، جيب الاسم أوتوماتيك
                          if (selectedProjectName == null &&
                              selectedProjectId != null) {
                            final match = state.projectsModel.data?.firstWhere(
                              (p) => p.id.toString() == selectedProjectId,
                              orElse: () => null as dynamic,
                            );
                            if (match != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                setState(
                                  () => selectedProjectName = match.name,
                                );
                              });
                            }
                          }
                          return _buildSelectionContainer(
                            hint: "Choose Project",
                            selectedName: selectedProjectName,
                            icon: Icons.business_outlined,
                            onTap:
                                () => _openSearchPanel(
                                  context: context,
                                  title: "Project Selection",
                                  items: state.projectsModel.data!,
                                  labelOf: (p) => p.name ?? '',
                                  idOf: (p) => p.id.toString(),
                                  selectedId: selectedProjectId,
                                  onConfirm:
                                      (id, name) => setState(() {
                                        selectedProjectId = id;
                                        selectedProjectName = name;
                                      }),
                                ),
                          );
                        } else if (state is ProjectsLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return const SizedBox();
                      },
                    ),

                    // ── Stage ──────────────────────────────────
                    BlocBuilder<StagesCubit, StagesState>(
                      builder: (context, state) {
                        if (state is StagesLoaded) {
                          if (selectedStageName == null &&
                              selectedStageId != null) {
                            final match = state.stages.firstWhere(
                              (s) => s.id.toString() == selectedStageId,
                              orElse: () => null as dynamic,
                            );
                            if (match != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                setState(() => selectedStageName = match.name);
                              });
                            }
                          }
                          return _buildSelectionContainer(
                            hint: "Choose Stage",
                            selectedName: selectedStageName,
                            icon: Icons.timeline_outlined,
                            onTap:
                                () => _openSearchPanel(
                                  context: context,
                                  title: "Stage Selection",
                                  items: state.stages,
                                  labelOf: (s) => s.name ?? '',
                                  idOf: (s) => s.id.toString(),
                                  selectedId: selectedStageId,
                                  onConfirm:
                                      (id, name) => setState(() {
                                        selectedStageId = id;
                                        selectedStageName = name;
                                      }),
                                ),
                          );
                        } else if (state is StagesLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return const SizedBox();
                      },
                    ),

                    // ── Channel ────────────────────────────────
                    BlocBuilder<ChannelCubit, ChannelState>(
                      builder: (context, state) {
                        if (state is ChannelLoaded) {
                          if (selectedChannelName == null &&
                              selectedChannelId != null) {
                            final match = state.channelResponse.data.firstWhere(
                              (c) => c.id.toString() == selectedChannelId,
                              orElse: () => null as dynamic,
                            );
                            if (match != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                setState(
                                  () => selectedChannelName = match.name,
                                );
                              });
                            }
                          }
                          return _buildSelectionContainer(
                            hint: "Choose Channel",
                            selectedName: selectedChannelName,
                            icon: Icons.wifi_tethering_outlined,
                            onTap:
                                () => _openSearchPanel(
                                  context: context,
                                  title: "Channel Selection",
                                  items: state.channelResponse.data,
                                  labelOf: (c) => c.name,
                                  idOf: (c) => c.id.toString(),
                                  selectedId: selectedChannelId,
                                  onConfirm:
                                      (id, name) => setState(() {
                                        selectedChannelId = id;
                                        selectedChannelName = name;
                                      }),
                                ),
                          );
                        } else if (state is ChannelLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return const SizedBox();
                      },
                    ),

                    // ── Campaign ───────────────────────────────
                    BlocBuilder<GetCampaignsCubit, GetCampaignsState>(
                      builder: (context, state) {
                        if (state is GetCampaignsSuccess) {
                          if (selectedCampaignName == null &&
                              selectedCampaignId != null) {
                            final match = state.campaigns.data?.firstWhere(
                              (c) => c.id.toString() == selectedCampaignId,
                              orElse: () => null as dynamic,
                            );
                            if (match != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                setState(
                                  () =>
                                      selectedCampaignName = match.campainName,
                                );
                              });
                            }
                          }
                          return _buildSelectionContainer(
                            hint: "Choose Campaign",
                            selectedName: selectedCampaignName,
                            icon: Icons.campaign_outlined,
                            onTap:
                                () => _openSearchPanel(
                                  context: context,
                                  title: "Campaign Selection",
                                  items: state.campaigns.data!,
                                  labelOf: (c) => c.campainName ?? '',
                                  idOf: (c) => c.id.toString(),
                                  selectedId: selectedCampaignId,
                                  onConfirm:
                                      (id, name) => setState(() {
                                        selectedCampaignId = id;
                                        selectedCampaignName = name;
                                      }),
                                ),
                          );
                        } else if (state is GetCampaignsLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return const SizedBox();
                      },
                    ),

                    // ── Communication Way ──────────────────────
                    BlocBuilder<
                      GetCommunicationWaysCubit,
                      GetCommunicationWaysState
                    >(
                      builder: (context, state) {
                        if (state is GetCommunicationWaysLoaded) {
                          if (selectedCommunicationWayName == null &&
                              selectedCommunicationWayId != null) {
                            final match = state.response.data?.firstWhere(
                              (w) =>
                                  w.id.toString() == selectedCommunicationWayId,
                              orElse: () => null as dynamic,
                            );
                            if (match != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                setState(
                                  () =>
                                      selectedCommunicationWayName = match.name,
                                );
                              });
                            }
                          }
                          return _buildSelectionContainer(
                            hint: "Choose Communication Way",
                            selectedName: selectedCommunicationWayName,
                            icon: Icons.chat_bubble_outline_rounded,
                            onTap:
                                () => _openSearchPanel(
                                  context: context,
                                  title: "Communication Way",
                                  items: state.response.data!,
                                  labelOf: (w) => w.name ?? '',
                                  idOf: (w) => w.id.toString(),
                                  selectedId: selectedCommunicationWayId,
                                  onConfirm:
                                      (id, name) => setState(() {
                                        selectedCommunicationWayId = id;
                                        selectedCommunicationWayName = name;
                                      }),
                                ),
                          );
                        } else if (state is GetCommunicationWaysLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return const SizedBox();
                      },
                    ),

                    const SizedBox(height: 12),

                    // ── Lead Type Toggle ───────────────────────
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
                                activeThumbColor: _mainColor,
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

                    // ── Action Buttons ─────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _mainColor,
                              side: BorderSide(color: _mainColor),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BlocConsumer<EditLeadCubit, EditLeadState>(
                            listener: (context, state) {
                              if (state is EditLeadSuccess) {
                                Navigator.pop(context);
                                if (widget.onSuccess != null) {
                                  widget.onSuccess!();
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Edited Successfully'),
                                  ),
                                );
                              } else if (state is EditLeadFailure) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Edit Failed: ${state.error}',
                                    ),
                                  ),
                                );
                              }
                            },
                            builder: (context, state) {
                              final isLoading = state is EditLeadLoading;
                              return ElevatedButton(
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
                                onPressed:
                                    isLoading
                                        ? null
                                        : () {
                                          final Map<String, dynamic>
                                          updatedFields = {};

                                          if (nameController.text
                                              .trim()
                                              .isNotEmpty) {
                                            updatedFields['name'] =
                                                nameController.text.trim();
                                          }
                                          if (emailController.text
                                              .trim()
                                              .isNotEmpty) {
                                            updatedFields['email'] =
                                                emailController.text.trim();
                                          }
                                          if (phoneController.text
                                              .trim()
                                              .isNotEmpty) {
                                            updatedFields['phone'] =
                                                phoneController.text.trim();
                                          }
                                          if (notesController.text
                                              .trim()
                                              .isNotEmpty) {
                                            updatedFields['notes'] =
                                                notesController.text.trim();
                                          }
                                          if (selectedProjectId != null &&
                                              selectedProjectId!.isNotEmpty) {
                                            updatedFields['project'] =
                                                selectedProjectId;
                                          }
                                          if (selectedStageId != null &&
                                              selectedStageId!.isNotEmpty) {
                                            updatedFields['stage'] =
                                                selectedStageId;
                                          }
                                          if (selectedChannelId != null &&
                                              selectedChannelId!.isNotEmpty) {
                                            updatedFields['chanel'] =
                                                selectedChannelId;
                                          }
                                          if (selectedCommunicationWayId !=
                                                  null &&
                                              selectedCommunicationWayId!
                                                  .isNotEmpty) {
                                            updatedFields['communicationway'] =
                                                selectedCommunicationWayId;
                                          }
                                          if (selectedCampaignId != null &&
                                              selectedCampaignId!.isNotEmpty) {
                                            updatedFields['campaign'] =
                                                selectedCampaignId;
                                          }

                                          updatedFields['leedtype'] =
                                              isCold ? "Cold" : "Fresh";

                                          if (updatedFields.length == 1) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'No changes to update',
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          context.read<EditLeadCubit>().editLead(
                                            userId: widget.userId,
                                            salesIdd: widget.initialStalesId,
                                            name: updatedFields['name'],
                                            email: updatedFields['email'],
                                            phone: updatedFields['phone'],
                                            notes: updatedFields['notes'],
                                            project: updatedFields['project'],
                                            stage: updatedFields['stage'],
                                            chanel: updatedFields['chanel'],
                                            communicationway:
                                                updatedFields['communicationway'],
                                            leedtype: updatedFields['leedtype'],
                                            campaign: updatedFields['campaign'],
                                          );
                                        },
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
                                          "Save Changes",
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
          ],
        ),
      ),
    );
  }
}
