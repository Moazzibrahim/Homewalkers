import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
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
  String? selectedSales;
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

   // ✅ الخطوة 1: إضافة دوال معالجة التاريخ الدقيقة
  String _formatFullDate(String date) {
    try {
      final localDate = DateTime.parse(date);
      return localDate.toUtc().toIso8601String();
    } catch (e) {
      return date;
    }
  }

  String _formatEndDate(String date) {
    try {
      final localDate = DateTime.parse(date);
      final endOfDay = DateTime(localDate.year, localDate.month, localDate.day, 23, 59, 59, 999);
      return endOfDay.toUtc().toIso8601String();
    } catch (e) {
      return date;
    }
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SalesCubit>(
          create: (_) => SalesCubit(GetAllSalesApiService())..fetchAllSales(),
        ),
      ],
      child: BlocBuilder<GetLeadsMarketerCubit, GetLeadsMarketerState>(
        builder: (context, leadsState) {
          return Scaffold(
            backgroundColor:
                  Theme.of(context).brightness == Brightness.light
                      ? Constants.backgroundlightmode
                      : Constants.backgroundDarkmode,
            appBar: CustomAppBar(
              title: "Advanced Search",
              onBack: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MarketierTabsScreen(),
                  ),
                );
              },
            ),
            body: BlocBuilder<SalesCubit, SalesState>(
              builder: (context, salesState) {
                List<String> salesList = [];
                if (salesState is SalesLoaded) {
                  salesList =
                      salesState.salesData.data!
                          .map((e) => e.name ?? '')
                          .where((name) => name.isNotEmpty)
                          .toList();
                }
                return _buildBody(context, salesList);
              },
            ),
          );
        },
      ),
    );
  }
  Widget _buildBody(BuildContext context, List<String> salesOptions) {
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
                    selectedSales = null;
                    selectedUser = null;
                    selectedCountry = null;
                  });
                },
              ),
              const SizedBox(height: 24),
              // Dropdowns حسب الفلتر
              if (selectedFilterType == 'Sales') ...[
                _buildDropdown(
                  "Choose Sales",
                  salesOptions,
                  selectedSales,
                  (val) => setState(() => selectedSales = val),
                ),
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
                _buildDropdown(
                  "Choose Sales",
                  salesOptions,
                  selectedSales,
                  (val) => setState(() => selectedSales = val),
                ),
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
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2B6777)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.push(context,MaterialPageRoute(builder: (context)=> const MarketierTabsScreen())),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Color(0xFF2B6777)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B6777),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                      final cubit = context.read<GetLeadsMarketerCubit>();
                        setState(() => _hasSearched = true); // <-- هنا
                      cubit.filterLeadsMarketerForAdvancedSearch(
                        sales: selectedSales,
                        country: selectedCountry,
                        user: selectedUser,
                        creationDate: _dateController.text.isNotEmpty
                                  ? _formatFullDate(_dateController.text)
                                  : null,
                              fromDate: _fromDateController.text.isNotEmpty
                                  ? _formatFullDate(_fromDateController.text)
                                  : null,
                              toDate: _toDateController.text.isNotEmpty
                                  ? _formatEndDate(_toDateController.text)
                                  : null,
                              commentDate: _commentDateController.text.isNotEmpty
                                  ? _formatFullDate(_commentDateController.text)
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
              // ✅ نتائج البحث
              if (_hasSearched) ...[
              if (state is GetLeadsMarketerLoading) ...[
                const Center(child: CircularProgressIndicator()),
              ] else if (state is GetLeadsMarketerFailure) ...[
                Text(
                  state.errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ] else if (state is GetLeadsMarketerSuccess) ...[
                const Text(
                  "Results:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...state.leadsResponse.data!.map((lead) {
                return Card(
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
            Icon(Icons.person, color: Theme.of(context).brightness == Brightness.light ?Constants.maincolor: Constants.mainDarkmodecolor),
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
            Spacer(),
            TextButton(onPressed: (){
              Navigator.push(context,MaterialPageRoute(builder:(context)=> MarketerLeadDetailsScreen(leedId: lead.id!,leadName: lead.name,leadEmail: lead.email,leadPhone: lead.phone,leadStageId: lead.stage!.id!,salesfcmtoken: lead.sales!.userlog!.fcmtokenn!,
              leadStage: lead.stage!.name,leadChannel: lead.chanel!.name!,leadCreationDate:DateTime.parse(lead.createdAt!).toUtc().toString(),leadLastComment: lead.lastcommentdate,leadCreationTime: lead.createdAt,leadNotes: lead.notes,leadProject: lead.project!.name,leadcampaign: lead.campaign!.name,leaddeveloper: lead.project!.developer!.name,) ));
            }, child: Text("view more", style: TextStyle(color: Theme.of(context).brightness == Brightness.light ?Constants.maincolor: Constants.mainDarkmodecolor))),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.phone, color: Theme.of(context).brightness == Brightness.light ?Constants.maincolor: Constants.mainDarkmodecolor),
            const SizedBox(width: 8),
            Text(lead.phone ?? "No Phone"),
          ],
        ),
        const SizedBox(height: 8),
        if (lead.email != null) ...[
          Row(
            children: [
              Icon(Icons.email, color: Theme.of(context).brightness == Brightness.light ?Constants.maincolor: Constants.mainDarkmodecolor),
              const SizedBox(width: 8),
              Text(lead.email!),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.chat_bubble_outline, color: Theme.of(context).brightness == Brightness.light ?Constants.maincolor: Constants.mainDarkmodecolor),
              const SizedBox(width: 8),
              Text(lead.stage!.name!),
            ],  
          )
        ],
      ],
    ),
  ),
);

                }),
              ],
            ],
            ],
          ),
        );
      },
    );
  }
  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
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
          value: selectedValue,
          decoration: _dropdownDecoration(),
          hint: Text(label),
          items:
              items
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDatePickerField(
    String label, {
    required TextEditingController controller,
  }) {
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
          controller: TextEditingController(text: selectedCountry),
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
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
    );
  }
}
