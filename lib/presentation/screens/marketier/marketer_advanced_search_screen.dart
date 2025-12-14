import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/presentation/screens/marketier/marketer_lead_details_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/marketier_tabs_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/get_leads_marketer_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_state.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';

class MarketerAdvancedSearchScreen extends StatefulWidget {
  const MarketerAdvancedSearchScreen({super.key});

  @override
  State<MarketerAdvancedSearchScreen> createState() =>
      _MarketerAdvancedSearchScreenState();
}

class _MarketerAdvancedSearchScreenState
    extends State<MarketerAdvancedSearchScreen> {
  String? selectedFilterType;
  // ✅  الخطوة 1: تعديل المتغيرات للتعامل مع الـ ID
  String? selectedSalesId; // <-- بدلاً من selectedSales
  Map<String, String> salesMap = {}; // <-- Map لتخزين (ID, Name)

  String? selectedCountry;
  String? selectedUser;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final TextEditingController _commentDateController = TextEditingController();
  bool _hasSearched = false;
  final List<String> filterTypes = [
    'Sales',
    'Country',
    'Creation Date',
    'All Lead Between Different Dates',
    'All Leads With Sales Between Different 2 Date',
    'All Leads With Last Comment Date',
  ];

  // لتحويل التاريخ إلى بداية اليوم
  // ✅ دالة مُعدّلة: تحول التاريخ المحلي إلى بداية اليوم بالتوقيت العالمي
  // ✅ دالة مُعدّلة: تحول التاريخ المحلي إلى بداية اليوم بالتوقيت العالمي (UTC)
  String _formatFullDate(String date) {
    try {
      // 1. تحليل التاريخ كنص للحصول على كائن DateTime بالتوقيت المحلي
      final localDate = DateTime.parse(date);
      // 2. تحويله إلى التوقيت العالمي المنسق (UTC) وإرجاعه كنص
      return localDate.toUtc().toIso8601String();
    } catch (e) {
      // Fallback في حال كان التنسيق مختلفاً
      return date;
    }
  }

  // ✅ دالة جديدة وأكثر دقة: تحسب نهاية اليوم المحدد وتحولها إلى UTC
  String _formatEndDate(String date) {
    try {
      // 1. تحليل التاريخ كنص للحصول على بداية اليوم بالتوقيت المحلي
      final localDate = DateTime.parse(date);
      // 2. حساب نهاية اليوم بإضافة يوم كامل وطرح ميلي ثانية واحدة
      final endOfDay = DateTime(
        localDate.year,
        localDate.month,
        localDate.day,
        23,
        59,
        59,
        999,
      );
      // 3. تحويل لحظة نهاية اليوم إلى التوقيت العالمي (UTC) وإرجاعها كنص
      return endOfDay.toUtc().toIso8601String();
    } catch (e) {
      // Fallback
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SalesCubit>(
          create: (_) => SalesCubit(GetAllSalesApiService())..fetchAllSales(),
        ),
        // ✅ الخطوة 2: تصحيح إنشاء الـ Cubit واستدعاء الدالة لجلب البيانات
        BlocProvider<GetLeadsMarketerCubit>(
          create:
              (_) =>
                  GetLeadsMarketerCubit(GetLeadsService())
                    ..getLeadsByMarketer(),
        ),
      ],
      child: Scaffold(
        backgroundColor:
            Theme.of(context).brightness == Brightness.light
                ? Constants.backgroundlightmode
                : Constants.backgroundDarkmode,
        appBar: CustomAppBar(
          title: "Advanced Search",
          onBack: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MarketierTabsScreen()),
            );
          },
        ),
        // ✅ الخطوة 3: استخدام BlocListener للاستماع لحالة SalesCubit وتعبئة الـ Map
        body: BlocListener<SalesCubit, SalesState>(
          listener: (context, state) {
            if (state is SalesLoaded) {
              setState(() {
                salesMap = {
                  for (var sale in state.salesData.data!)
                    if (sale.id != null && sale.name != null)
                      sale.id!: sale.name!,
                };
              });
            }
          },
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<GetLeadsMarketerCubit, GetLeadsMarketerState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Choose",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: selectedFilterType,
                decoration: _dropdownDecoration(),
                hint: const Text("Select filter"),
                items:
                    filterTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFilterType = value;
                    selectedSalesId = null;
                    selectedUser = null;
                    selectedCountry = null;
                  });
                },
              ),
              const SizedBox(height: 24),
              // Conditional UI based on filter
              if (selectedFilterType == 'Sales') ...[
                // ✅ الخطوة 4: تعديل Dropdown الخاص بالـ Sales
                _buildSalesDropdown("Choose Sales"),
              ] else if (selectedFilterType == 'Country') ...[
                _buildCountryPicker("Choose Country"),
              ] else if (selectedFilterType == 'Creation Date') ...[
                _buildDatePickerField(
                  "Select Creation Date",
                  controller: _dateController,
                ),
              ] else if (selectedFilterType ==
                  'All Lead Between Different Dates') ...[
                _buildDatePickerField(
                  "From Date",
                  controller: _fromDateController,
                ),
                _buildDatePickerField("To Date", controller: _toDateController),
              ] else if (selectedFilterType ==
                  'All Leads With Sales Between Different 2 Date') ...[
                _buildSalesDropdown("Choose Sales"),
                _buildDatePickerField(
                  "From Date",
                  controller: _fromDateController,
                ),
                _buildDatePickerField("To Date", controller: _toDateController),
              ] else if (selectedFilterType ==
                  'All Leads With Last Comment Date') ...[
                _buildDatePickerField(
                  "Comment Date",
                  controller: _commentDateController,
                ),
              ],
              const SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      // ... (Cancel Button code remains the same)
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Constants.maincolor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MarketierTabsScreen(),
                            ),
                          ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Constants.maincolor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.maincolor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        setState(() => _hasSearched = true);
                        // ✅ الخطوة 5: تمرير الـ ID بدلاً من الاسم
                        context
                            .read<GetLeadsMarketerCubit>()
                            .filterLeadsMarketerForAdvancedSearch(
                              sales: selectedSalesId, // <-- تمرير الـ ID
                              country: selectedCountry,
                              user: selectedUser,
                              creationDate:
                                  _dateController.text.isNotEmpty
                                      ? _formatFullDate(_dateController.text)
                                      : null,
                              fromDate:
                                  _fromDateController.text.isNotEmpty
                                      ? _formatFullDate(
                                        _fromDateController.text,
                                      )
                                      : null,
                              toDate:
                                  _toDateController.text.isNotEmpty
                                      ? _formatEndDate(
                                        _toDateController.text,
                                      ) // ✅  دقيق جدًا
                                      : null,
                              commentDate:
                                  _commentDateController.text.isNotEmpty
                                      ? _formatFullDate(
                                        _commentDateController.text,
                                      )
                                      : null,
                            );
                      },
                      child: const Text(
                        "Search",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Search Results
              if (_hasSearched) ...[
                if (state is GetLeadsMarketerLoading)
                  const Center(child: CircularProgressIndicator())
                else if (state is GetLeadsMarketerFailure)
                  Center(
                    child: Text(
                      state.errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                else if (state is GetLeadsMarketerSuccess) ...[
                  if (state.leadsResponse.data!.isEmpty)
                    const Center(child: Text("No results found."))
                  else ...[
                    Text(
                      "Results (${state.leadsResponse.data!.length}):",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...state.leadsResponse.data!.map((lead) {
                      return Card(
                        // ... (Card UI for results remains the same)
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Constants.maincolor
                                            : Constants.mainDarkmodecolor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      lead.name ?? "No Name",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final firstVersion =
                                          (lead.allVersions != null &&
                                                  lead.allVersions!.isNotEmpty)
                                              ? lead.allVersions!.first
                                              : null;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (
                                                context,
                                              ) => MarketerLeadDetailsScreen(
                                                leedId: lead.id!,
                                                leadName: lead.name,
                                                leadEmail: lead.email,
                                                leadPhone: lead.phone,
                                                leadStageId:
                                                    lead.stage?.id ?? '',
                                                leadStage:
                                                    lead.stage?.name ?? '',
                                                leadChannel:
                                                    lead.chanel?.name ?? '',
                                                leadCreationDate:
                                                    lead.createdAt ?? "",
                                                leadLastComment:
                                                    lead.lastcommentdate,
                                                leadCreationTime:
                                                    lead.createdAt,
                                                leadNotes: "",
                                                leadProject:
                                                    lead.project?.name ?? '',
                                                leadcampaign:
                                                    lead.campaign?.name ?? '',
                                                leaddeveloper:
                                                    lead
                                                        .project
                                                        ?.developer
                                                        ?.name ??
                                                    '',
                                                salesfcmtoken:
                                                    lead
                                                        .sales!
                                                        .userlog!
                                                        .fcmtokenn!,
                                                leadSalesName:
                                                    lead.sales?.name ?? '',
                                                leadversions: lead.allVersions,
                                                leadversionscampaign:
                                                    firstVersion
                                                        ?.campaignName ??
                                                    "No campaign",
                                                leadversionsproject:
                                                    firstVersion?.projectName ??
                                                    "No project",
                                                leadversionsdeveloper:
                                                    firstVersion
                                                        ?.developerName ??
                                                    "No developer",
                                                leadversionschannel:
                                                    firstVersion?.channelName ??
                                                    "No channel",
                                                leadversionscreationdate:
                                                    firstVersion?.versionDate ??
                                                    "No date",
                                                leadversionscommunicationway:
                                                    firstVersion
                                                        ?.communicationWay ??
                                                    "No communication way",
                                                leadStages: [lead.stage?.id],
                                              ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "view more",
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? Constants.maincolor
                                                : Colors.white,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Constants.maincolor
                                            : Constants.mainDarkmodecolor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(lead.phone ?? "No Phone"),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (lead.email != null) ...[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.email,
                                      color:
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Constants.maincolor
                                              : Constants.mainDarkmodecolor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(lead.email!),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (lead.stage?.name != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      color:
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Constants.maincolor
                                              : Constants.mainDarkmodecolor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(lead.stage!.name!),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  // ✅ الخطوة 6: إنشاء دالة خاصة بـ Sales Dropdown
  Widget _buildSalesDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: selectedSalesId,
          decoration: _dropdownDecoration(),
          hint: Text(label),
          // عرض أسماء الموظفين
          items:
              salesMap.entries
                  .map(
                    (entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
          // عند الاختيار، قم بتخزين الـ ID
          onChanged: (val) => setState(() => selectedSalesId = val),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // (DatePicker and CountryPicker methods remain the same)
  Widget _buildDatePickerField(
    String label, {
    required TextEditingController controller,
  }) {
    // ... same as your code
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: label,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              final formattedDate =
                  "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
              controller.text = formattedDate;
            }
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCountryPicker(String label) {
    // ... same as your code
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          readOnly: true,
          controller: TextEditingController(
            text: selectedCountry != null ? "+$selectedCountry" : "",
          ),
          decoration: InputDecoration(
            hintText: "Select Country",
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: const Icon(Icons.arrow_drop_down),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
          onTap: () {
            showCountryPicker(
              context: context,
              showPhoneCode: true,
              onSelect: (Country country) {
                setState(() {
                  selectedCountry = country.phoneCode;
                });
              },
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  InputDecoration _dropdownDecoration() {
    // ... same as your code
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
    );
  }
}
