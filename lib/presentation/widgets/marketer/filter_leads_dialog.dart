// filter_leads_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:homewalkers_app/presentation/widgets/custom_dropdown_widget.dart';
import 'package:homewalkers_app/presentation/widgets/custom_text_field_widget.dart';
import 'package:country_picker/country_picker.dart'; // تأكد أن هذا المستورد موجود

class FilterDialog extends StatefulWidget {
  // 🟡 جديد: لاستقبال القيم الأولية (الحالية) للفلاتر
  final String? initialCountry;
  final String? initialDeveloper;
  final String? initialProject;
  final String? initialStage;
  final String? initialChannel;
  final String? initialSales;
  final String? initialCommunicationWay;
  final String? initialCampaign;
  final String? initialSearchName; // 🟡 لاستقبال نص البحث من الشاشة الرئيسية

  const FilterDialog({
    super.key,
    this.initialCountry,
    this.initialDeveloper,
    this.initialProject,
    this.initialStage,
    this.initialChannel,
    this.initialSales,
    this.initialCommunicationWay,
    this.initialCampaign,
    this.initialSearchName,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  // 🟡 استخدم TextEditingController مع قيمة أولية
  late TextEditingController _nameController;

  String? _selectedCountry; // 🟡 تم تغيير الاسم ليكون أوضح
  String? _selectedDeveloper;
  String? _selectedProject;
  String? _selectedStage;
  String? _selectedChannel;
  String? _selectedCommunicationWay;
  String? _selectedCampaign;
  String? _selectedSales;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialSearchName,
    ); // 🟡 تهيئة بنص البحث الحالي
    _selectedCountry = widget.initialCountry;
    _selectedDeveloper = widget.initialDeveloper;
    _selectedProject = widget.initialProject;
    _selectedStage = widget.initialStage;
    _selectedChannel = widget.initialChannel;
    _selectedSales = widget.initialSales;
    _selectedCommunicationWay = widget.initialCommunicationWay;
    _selectedCampaign = widget.initialCampaign;

    // ❌ احذف هذا الاستدعاء. الـ dialog لا يجلب بيانات Leads
    // context.read<GetLeadsMarketerCubit>().getLeadsByMarketer();
  }

  @override
  void dispose() {
    _nameController.dispose(); // 🟡 مهم: التخلص من الـ controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? Constants.maincolor
                            : Constants.mainDarkmodecolor,
                    child: const Icon(Icons.tune, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Filter',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed:
                        () => Navigator.pop(
                          context,
                          null,
                        ), // 🟡 إرجاع null عند الإغلاق
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 🟡 الـ CustomTextField ده هيستخدم كـ 'query' للبحث عن الاسم أو الايميل أو الرقم
              CustomTextField(
                hint: "Search Name, Email, or Phone",
                controller: _nameController,
              ),
              const SizedBox(height: 12),
               GestureDetector(
                onTap: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode: true,
                    onSelect: (Country country) {
                      setState(() {
                        _selectedCountry = country.name;
                      });
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedCountry ?? "Select Country",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? const Color(0xff080719)
                                      : const Color(0xffFFFFFF),
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // 🟡 CustomDropdownField لباقي الفلاتر
              BlocBuilder<SalesCubit, SalesState>(
                builder: (context, state) {
                  if (state is SalesLoaded) {
                    final filteredSales =
                        state.salesData.data?.where((sales) {
                          final role = sales.userlog?.role?.toLowerCase();
                          return role == 'sales' || role == 'team leader'|| role == 'manager';
                        }).toList() ??
                        [];
                    return CustomDropdownField(
                      hint: "Choose Sales",
                      items: filteredSales.map((e) => e.name ?? '').toList(),
                      value: _selectedSales,
                      onChanged: (value) {
                        setState(() => _selectedSales = value);
                      },
                    );
                  } else if (state is SalesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SalesError) {
                    return Text("Error: ${state.message}");
                  }
                  return const SizedBox(); // Default empty widget
                },
              ),
              const SizedBox(height: 12),
              BlocBuilder<DevelopersCubit, DevelopersState>(
                builder: (context, state) {
                  if (state is DeveloperLoading) {
                    return const CircularProgressIndicator();
                  } else if (state is DeveloperSuccess) {
                    final items =
                        state.developersModel.data
                            .map((dev) => dev.name)
                            .toList();
                    return CustomDropdownField(
                      hint: "Choose Developer",
                      items: items,
                      value: _selectedDeveloper,
                      onChanged:
                          (val) => setState(() => _selectedDeveloper = val),
                    );
                  } else if (state is DeveloperError) {
                    return Text(
                      "Error: ${state.error}",
                      style: const TextStyle(color: Colors.red),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              const SizedBox(height: 12),
              BlocBuilder<ChannelCubit, ChannelState>(
                builder: (context, state) {
                  if (state is ChannelLoading) {
                    return const CircularProgressIndicator();
                  } else if (state is ChannelLoaded) {
                    final items =
                        state.channelResponse.data
                            .map((dev) => dev.name)
                            .toList();
                    return CustomDropdownField(
                      hint: "Choose channel",
                      items: items,
                      value: _selectedChannel,
                      onChanged:
                          (val) => setState(() => _selectedChannel = val),
                    );
                  } else if (state is ChannelError) {
                    return Text(
                      "Error: ${state.message}",
                      style: const TextStyle(color: Colors.red),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              const SizedBox(height: 12),
              BlocBuilder<ProjectsCubit, ProjectsState>(
                builder: (context, state) {
                  if (state is ProjectsLoading) {
                    return const CircularProgressIndicator();
                  } else if (state is ProjectsSuccess) {
                    final items =
                        state.projectsModel.data!
                            .map((project) => project.name)
                            .toList();
                    return CustomDropdownField(
                      hint: "Choose Project",
                      items: items,
                      value: _selectedProject,
                      onChanged:
                          (val) => setState(() => _selectedProject = val),
                    );
                  } else if (state is ProjectsError) {
                    return Text(
                      "Error: ${state.error}",
                      style: const TextStyle(color: Colors.red),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              const SizedBox(height: 12),
              BlocBuilder<GetCampaignsCubit, GetCampaignsState>(
                builder: (context, state) {
                  if (state is GetCampaignsLoading) {
                    return const CircularProgressIndicator();
                  } else if (state is GetCampaignsSuccess) {
                    final items =
                        state.campaigns.data!
                            .map((campaign) => campaign.campainName)
                            .toList();
                    return CustomDropdownField(
                      hint: "Choose Campaign",
                      items: items,
                      value: _selectedCampaign,
                      onChanged:
                          (val) => setState(() => _selectedCampaign = val),
                    );
                  } else if (state is GetCampaignsFailure) {
                    return Text(
                      "Error: ${state.message}",
                      style: const TextStyle(color: Colors.red),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              const SizedBox(height: 12),
              BlocBuilder<GetCommunicationWaysCubit, GetCommunicationWaysState>(
                builder: (context, state) {
                  if (state is GetCommunicationWaysLoading) {
                    return const CircularProgressIndicator();
                  } else if (state is GetCommunicationWaysLoaded) {
                    final items =
                        state.response.data!
                            .map((communicationway) => communicationway.name)
                            .toList();
                    return CustomDropdownField(
                      hint: "Choose communication way",
                      items: items,
                      value: _selectedCommunicationWay,
                      onChanged:
                          (val) =>
                              setState(() => _selectedCommunicationWay = val),
                    );
                  } else if (state is GetCommunicationWaysError) {
                    return Text(
                      "Error: ${state.message}",
                      style: const TextStyle(color: Colors.red),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              const SizedBox(height: 12),
              BlocBuilder<StagesCubit, StagesState>(
                builder: (context, state) {
                  if (state is StagesLoading) {
                    return const CircularProgressIndicator();
                  } else if (state is StagesLoaded) {
                    final items =
                        state.stages.map((stage) => stage.name).toList();
                    return CustomDropdownField(
                      hint: "Choose Stage",
                      items: items,
                      value: _selectedStage,
                      onChanged: (value) {
                        setState(() {
                          _selectedStage = value;
                        });
                      },
                    );
                  } else if (state is StagesError) {
                    return Text(
                      "Error: ${state.message}",
                      style: const TextStyle(color: Colors.red),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              const SizedBox(height: 20),
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
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _nameController.clear();
                          _selectedCountry = null;
                          _selectedDeveloper = null;
                          _selectedProject = null;
                          _selectedStage = null;
                          _selectedChannel = null;
                          _selectedSales = null;
                          _selectedCommunicationWay = null;
                          _selectedCampaign = null;
                        });
                        // 🟡 عند الـ Reset، نرجع قيم فارغة (أو null) للشاشة الرئيسية ونقفل الـ Dialog
                        Navigator.pop(context, {
                          'name': null,
                          'country': null,
                          'developer': null,
                          'project': null,
                          'stage': null,
                          'channel': null,
                          'sales': null,
                          'communicationWay': null,
                          'campaign': null,
                        });
                      },
                      child: const Text(
                        "Reset",
                        style: TextStyle(
                          color: Color(0xff326677),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // 🟡 عند الـ Apply، نرجع كل قيم الفلاتر المختارة
                        Navigator.pop(context, {
                          'name':
                              _nameController.text.trim().isEmpty
                                  ? null
                                  : _nameController.text.trim(),
                          'country': _selectedCountry,
                          'developer': _selectedDeveloper,
                          'project': _selectedProject,
                          'stage': _selectedStage,
                          'channel': _selectedChannel,
                          'sales': _selectedSales,
                          'communicationWay': _selectedCommunicationWay,
                          'campaign': _selectedCampaign,
                        });
                        // ❌ لا تستدعي filterLeadsMarketer هنا. الشاشة الرئيسية هي اللي هتستدعيها.
                        // context.read<GetLeadsMarketerCubit>().filterLeadsMarketer(...)
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.light
                                ? Constants.maincolor
                                : Constants.mainDarkmodecolor,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        "Apply",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
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
