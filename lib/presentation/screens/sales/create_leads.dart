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

  // 👇 حقل جديد لرابط إعادة التوجيه
  late TextEditingController _campaignRedirectLinkController;

  // 👇 قوائم للأسئلة والأجوبة الديناميكية
  final List<Map<String, TextEditingController>> _qaControllers = [];

  String? selectedProjectId;
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

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        isExpanded: true,
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

  // 👇 دالة لإضافة حقل سؤال وجواب جديد
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

  // 👇 دالة لحذف حقل سؤال وجواب
  void _removeQuestionAnswerField(int index) {
    setState(() {
      _qaControllers[index]['question']?.dispose();
      _qaControllers[index]['answer']?.dispose();
      _qaControllers.removeAt(index);
    });
  }

  // 👇 دالة لجلب بيانات الأسئلة والأجوبة بالتنسيق المطلوب للكيوبيت
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

  // 👇 دالة للتحقق إذا كان المستخدم Admin أو Marketer
  bool get _isAdminOrMarketer {
    return role?.toLowerCase() == 'admin' || role?.toLowerCase() == 'marketer';
  }

  @override
  void initState() {
    super.initState();
    _campaignRedirectLinkController = TextEditingController();
    _addQuestionAnswerField(); // 👇 إضافة أول حقل سؤال وجواب افتراضياً
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
      log("Role: $role");
      log("ID: $id");
      log("Name: $name");
    });
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
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
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
                          onChanged: (phone) {
                            setState(() {
                              _fullPhoneNumber = phone.completeNumber;
                            });
                          },
                        ),
                      ),

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
                                      child: Text(
                                        project.name!,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(fontSize: 14),
                                      ),
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

                      if (role != "Sales")
                        BlocBuilder<SalesCubit, SalesState>(
                          builder: (context, state) {
                            if (state is SalesLoaded) {
                              final filteredSales =
                                  state.salesData.data?.where((sales) {
                                    final role =
                                        sales.userlog?.role?.toLowerCase();
                                    final name = sales.name;
                                    return (role == 'sales' ||
                                            role == 'team leader' ||
                                            role == 'manager') &&
                                        name?.toLowerCase() != 'default m';
                                  }).toList() ??
                                  [];

                              filteredSales.sort((a, b) {
                                if ((a.name ?? '').toLowerCase() ==
                                    'no sales') {
                                  return -1;
                                }
                                if ((b.name ?? '').toLowerCase() ==
                                    'no sales') {
                                  return 1;
                                }
                                return 0;
                              });

                              return DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: const Text("Choose Sales"),
                                  value: _selectedSalesId,
                                  items:
                                      filteredSales.map((sale) {
                                        return DropdownMenuItem<String>(
                                          value: sale.id,
                                          child: Text(
                                            sale.name ?? 'Unnamed',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                  dropdownSearchData: DropdownSearchData(
                                    searchController: _salesSearchController,
                                    searchInnerWidgetHeight: 60,
                                    searchInnerWidget: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: TextField(
                                        controller: _salesSearchController,
                                        decoration: InputDecoration(
                                          hintText: 'Search sales...',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    searchMatchFn: (item, searchValue) {
                                      return item.child
                                          .toString()
                                          .toLowerCase()
                                          .contains(searchValue.toLowerCase());
                                    },
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedSalesId = val;
                                      _selectedSalesFcmToken =
                                          filteredSales
                                              .firstWhere(
                                                (sale) => sale.id == val,
                                              )
                                              .userlog
                                              ?.fcmtoken;
                                    });
                                  },
                                  onMenuStateChange: (isOpen) {
                                    if (!isOpen) {
                                      _salesSearchController.clear();
                                    }
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(),
                                    ),
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 300,
                                  ),
                                ),
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
                                      child: Text(
                                        campaign.campainName!,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(fontSize: 14),
                                      ),
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

                      // 👇 حقل Campaign Redirect Link - يظهر فقط للـ Admin أو Marketer
                      if (_isAdminOrMarketer) ...[
                        const SizedBox(height: 12),
                        CustomTextField(
                          hint: "Campaign Redirect Link (Optional)",
                          controller: _campaignRedirectLinkController,
                        ),
                      ],

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
                        hint: "Budget",
                        controller: _budgetController,
                        textInputType: TextInputType.number,
                      ),

                      // 👇 قسم الأسئلة والأجوبة الديناميكية - يظهر فقط للـ Admin أو Marketer
                      if (_isAdminOrMarketer) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Questions & Answers (Optional)",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Add up to 5 Q&A pairs",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // عرض حقول الأسئلة والأجوبة
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _qaControllers.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
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
                                        const SizedBox(height: 8),
                                        CustomTextField(
                                          hint: "Question ${index + 1}",
                                          controller:
                                              _qaControllers[index]['question']!,
                                        ),
                                        const SizedBox(height: 8),
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

                              // 👇 زر إضافة سؤال وجواب جديد
                              if (_qaControllers.length < 5)
                                Center(
                                  child: TextButton.icon(
                                    onPressed: _addQuestionAnswerField,
                                    icon: const Icon(Icons.add_circle_outline),
                                    label: const Text("Add Question & Answer"),
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Constants.maincolor
                                              : Constants.mainDarkmodecolor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],

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
                                activeColor:
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Constants.maincolor
                                        : Constants.mainDarkmodecolor,
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
                                                selectedProjectId == null ||
                                                _selectedChannelId == null ||
                                                _selectedCampaignId == null) {
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

                                            // 👇 تجهيز بيانات الأسئلة والأجوبة (فقط إذا كان المستخدم Admin/Marketer)
                                            final qaData =
                                                _isAdminOrMarketer
                                                    ? _getQAForSubmission()
                                                    : <String, String>{};

                                            await context.read<CreateLeadCubit>().createLead(
                                              name: _nameController.text,
                                              email: _emailController.text,
                                              phone: formattedPhone,
                                              project: selectedProjectId ?? '',
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

                                              // 👇 إضافة الحقول الجديدة (فقط إذا كان المستخدم Admin/Marketer)
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
                                            // ⚡ إرسال الإشعار
                                            if (state is CreateLeadSuccess) {
                                              context
                                                  .read<NotificationCubit>()
                                                  .sendNotificationToToken(
                                                    title: "Lead",
                                                    body:
                                                        "Lead has been created ✅ to you",
                                                    fcmtokennnn:
                                                        _selectedSalesFcmToken!,
                                                  );
                                              log(
                                                "Notification sent to token: $_selectedSalesFcmToken",
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
}
