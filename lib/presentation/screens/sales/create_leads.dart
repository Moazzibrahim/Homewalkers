// ignore_for_file: use_build_context_synchronously
import 'dart:developer';

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
  String? selectedProjectId;
  String? selectedStageId;
  String? selectedStageName; // 👈 -- الخطوة 1: إضافة متغير جديد لاسم المرحلة
  String? _selectedCommunicationWayId;
  String? _selectedChannelId;
  String? _selectedCampaignId;
  String? _selectedSalesId;
  bool isCold = true; // أو false حسب الافتراضي
  String? _fullPhoneNumber;
  String? _selectedSalesFcmToken;

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),
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
          create: (_) => SalesCubit(GetAllSalesApiService())..fetchAllSales(),
        ),
        BlocProvider(create: (_) => CreateLeadCubit(CreateLeadApiService())),
      ],
      child: Builder(
        builder: (context) {
          return BlocListener<CreateLeadCubit, CreateLeadState>(
            listener: (context, state) {
              if (state is CreateLeadSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lead Created Successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Go back to the previous screen after a short delay
                Future.delayed(const Duration(milliseconds: 1500), () {
                  Navigator.pop(context);
                });
              } else if (state is CreateLeadFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to create lead'),
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
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ... Header Row ...
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Constants.maincolor
                                      : Constants.mainDarkmodecolor,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Create New Lead",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        hint: "Full Name",
                        controller: _nameController,
                      ),
                      CustomTextField(
                        hint: "Email Address",
                        controller: _emailController,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: IntlPhoneField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          initialCountryCode: 'AE',
                          // 👈 -- الخطوة 2: تحديث المتغير عند تغيير الرقم
                          onChanged: (phone) {
                            setState(() {
                              _fullPhoneNumber = phone.completeNumber;
                            });
                          },
                        ),
                      ),
                      // ... other dropdowns ...
                      const SizedBox(height: 12),
                      // Project Dropdown
                      BlocBuilder<ProjectsCubit, ProjectsState>(
                        builder: (context, state) {
                          if (state is ProjectsSuccess) {
                            return _buildDropdown<String>(
                              hint: "Choose Project",
                              value: selectedProjectId,
                              items:
                                  state.projectsModel.data!.map((project) {
                                    return DropdownMenuItem<String>(
                                      value: project.id,
                                      child: Text(project.name!),
                                    );
                                  }).toList(),
                              onChanged:
                                  (val) =>
                                      setState(() => selectedProjectId = val),
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      // --- MODIFIED: Stage Dropdown ---
                      BlocBuilder<StagesCubit, StagesState>(
                        builder: (context, state) {
                          if (state is StagesLoaded) {
                            return _buildDropdown<String>(
                              hint: "Choose Stage",
                              value: selectedStageId,
                              items:
                                  state.stages.map((stage) {
                                    return DropdownMenuItem<String>(
                                      value: stage.id,
                                      child: Text(stage.name!),
                                    );
                                  }).toList(),
                              // 👈 -- الخطوة 2: تحديث كلا المتغيرين عند التغيير
                              onChanged: (val) {
                                setState(() {
                                  selectedStageId = val;
                                  // Find the stage name corresponding to the selected ID
                                  selectedStageName =
                                      state.stages
                                          .firstWhere(
                                            (stage) => stage.id == val,
                                            orElse: () => state.stages.first,
                                          )
                                          .name;
                                });
                              },
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      // ... other dropdowns ...
                      BlocBuilder<SalesCubit, SalesState>(
                        builder: (context, state) {
                          if (state is SalesLoaded) {
                            final filteredSales =
                                state.salesData.data?.where((sales) {
                                  final role =
                                      sales.userlog?.role?.toLowerCase();
                                  return role == 'sales' ||
                                      role == 'team leader' ||
                                      role == 'manager';
                                }).toList() ??
                                [];
                            return _buildDropdown<String>(
                              hint: "Choose Sales",
                              value: _selectedSalesId,
                              items:
                                  filteredSales.map((sale) {
                                    return DropdownMenuItem<String>(
                                      value: sale.id,
                                      child: Text(sale.name ?? 'Unnamed'),
                                    );
                                  }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedSalesId = val;
                                  // Find the selected sales person and get their fcm token
                                  _selectedSalesFcmToken =
                                      filteredSales
                                          .firstWhere((sale) => sale.id == val)
                                          .userlog!
                                          .fcmtoken;
                                  log(
                                    "Selected Sales FCM Token: $_selectedSalesFcmToken",
                                  );
                                });
                              },
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      BlocBuilder<ChannelCubit, ChannelState>(
                        builder: (context, state) {
                          if (state is ChannelLoaded) {
                            return _buildDropdown<String>(
                              hint: "Choose Channel",
                              value: _selectedChannelId,
                              items:
                                  state.channelResponse.data.map((channel) {
                                    return DropdownMenuItem<String>(
                                      value: channel.id,
                                      child: Text(channel.name),
                                    );
                                  }).toList(),
                              onChanged:
                                  (val) =>
                                      setState(() => _selectedChannelId = val),
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      BlocBuilder<GetCampaignsCubit, GetCampaignsState>(
                        builder: (context, state) {
                          if (state is GetCampaignsSuccess) {
                            return _buildDropdown<String>(
                              hint: "Choose Campaign",
                              value: _selectedCampaignId,
                              items:
                                  state.campaigns.data!.map((campaign) {
                                    return DropdownMenuItem<String>(
                                      value: campaign.id,
                                      child: Text(campaign.campainName!),
                                    );
                                  }).toList(),
                              onChanged:
                                  (val) =>
                                      setState(() => _selectedCampaignId = val),
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 12),
                      CustomTextField(
                        hint: "Notes",
                        controller: _notesController,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Leed Type",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                isCold ? "Cold" : "Fresh",
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 8),
                              Switch(
                                value: isCold,
                                onChanged: (value) {
                                  setState(() {
                                    isCold = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Constants.maincolor
                                        : Constants.mainDarkmodecolor,
                                side: BorderSide(
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Constants.maincolor
                                          : Constants.mainDarkmodecolor,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Cancel"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                // ✅ تحقق من المدخلات قبل الإرسال
                                if (_nameController.text.isEmpty ||
                                    _emailController.text.isEmpty ||
                                    _phoneController.text.isEmpty ||
                                    selectedProjectId == null ||
                                    selectedStageId == null ||
                                    _selectedChannelId == null ||
                                    _selectedCommunicationWayId == null ||
                                    _selectedCampaignId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
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
                                    _fullPhoneNumber?.replaceAll('+', '') ?? '';
                                final isSuccess = await context
                                    .read<CreateLeadCubit>()
                                    .createLead(
                                      name: _nameController.text,
                                      email: _emailController.text,
                                      phone: formattedPhone,
                                      project: selectedProjectId ?? '',
                                      sales: _selectedSalesId ?? '',
                                      notes: _notesController.text,
                                      leedtype: isCold ? "Cold" : "Fresh",
                                      stage: selectedStageId ?? '',
                                      chanel: _selectedChannelId ?? '',
                                      communicationway:
                                          _selectedCommunicationWayId ?? '',
                                      dayonly: _dateController.text,
                                      lastStageDateUpdated:
                                          _dateController.text,
                                      campaign: _selectedCampaignId ?? '',
                                    );
                                if (isSuccess) {
                                  context
                                      .read<NotificationCubit>()
                                      .sendNotificationToToken(
                                        title: "Lead",
                                        body:
                                            " lead has been created ✅ to you ",
                                        fcmtokennnn: _selectedSalesFcmToken!,
                                      );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Constants.maincolor
                                        : Constants.mainDarkmodecolor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Add Lead",
                                style: TextStyle(color: Colors.white),
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
        },
      ),
    );
  }
}
