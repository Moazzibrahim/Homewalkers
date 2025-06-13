import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:homewalkers_app/presentation/screens/manager/tabs_screen_manager.dart';
import 'package:homewalkers_app/presentation/viewModels/Manager/cubit/get_manager_leads_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';

class ManagerTeamLeaderScreen extends StatefulWidget {
  const ManagerTeamLeaderScreen({super.key});

  @override
  State<ManagerTeamLeaderScreen> createState() =>
      _ManagerTeamLeaderScreenState();
}

class _ManagerTeamLeaderScreenState extends State<ManagerTeamLeaderScreen> {
  String? selectedTeamLeaderName; // اسم الـ Team Leader المختار
  Map<String, List<LeadData>> groupedLeads = {}; // تخزين الـ data المجمعة

  @override
  void initState() {
    super.initState();
    // طلب البيانات عند بدء الشاشة
    context.read<GetManagerLeadsCubit>().getLeadsByManager();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Team Leaders",
        onBack: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TabsScreenManager()),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<GetManagerLeadsCubit, GetManagerLeadsState>(
          builder: (context, state) {
            if (state is GetManagerLeadsSuccess) {
              // نحصل على الخريطة المجمعة
              groupedLeads =
                  context
                      .read<GetManagerLeadsCubit>()
                      .getSalesGroupedByTeamLeader();
              if (groupedLeads.isEmpty) {
                return const Center(child: Text("لا يوجد Team Leaders."));
              }
              // إذا لم يتم اختيار أي team leader، اختار الأول تلقائياً
              selectedTeamLeaderName ??= groupedLeads.keys.first;
              final salesList = groupedLeads[selectedTeamLeaderName] ?? [];
              final uniqueSales =
                  {
                    for (var lead in salesList)
                      if (lead.sales?.id != null) lead.sales!.id!: lead,
                  }.values.toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Team Leader and Sales That related with you.",
                    style: TextStyle(
                      color: Color(0xff7F8689),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 12),
                  // Dropdown لاختيار team leader بناء على أسماء المفاتيح في الخريطة
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: "Select Team Leaders",
                      hintStyle: TextStyle(
                        color: Color(0xffABABAD),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      filled: true,
                      // fillColor: Color(0xffF4F6F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    value: selectedTeamLeaderName,
                    items:
                        groupedLeads.keys.map((leaderName) {
                          return DropdownMenuItem<String>(
                            value: leaderName,
                            child: Text(leaderName),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTeamLeaderName = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  // تفاصيل الـ Team Leader (يمكنك تعديلها حسب البيانات المتوفرة لديك)
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color:
                          Brightness.light == Theme.of(context).brightness
                              ? Colors.grey[100] // لون الخلفية البيضاء
                              : Color(0xff1e1e1e),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedTeamLeaderName ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text("Role: Team Leader"),
                              SizedBox(height: 4),
                              Text(
                                "Email: ${salesList.first.sales?.teamleader?.email ?? 'No email'}",
                              ),
                              // يمكنك إضافة بيانات أخرى إذا كانت متاحة
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Your Sales",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              Brightness.light == Theme.of(context).brightness
                                  ? Colors
                                      .black // لون الخلفية البيضاء
                                  : Colors.white,
                        ),
                      ),
                      Text(
                        "leads Count",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              Brightness.light == Theme.of(context).brightness
                                  ? Colors
                                      .black // لون الخلفية البيضاء
                                  : Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),

                  // قائمة الـ sales التابعين للـ team leader المحدد
                  // فلترة السيلز عشان تبقى unique
                  Expanded(
                    child: ListView.builder(
                      itemCount: uniqueSales.length,
                      itemBuilder: (context, index) {
                        final salesLead = uniqueSales[index];
                        final sales = salesLead.sales;

                        final leadCount =
                            salesList
                                .where((lead) => lead.sales?.id == sales?.id)
                                .length;

                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(sales?.name ?? 'Unknown Sales'),
                              Text('$leadCount Leads'),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else if (state is GetManagerLeadsLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is GetManagerLeadsFailure) {
              return Center(child: Text(state.message));
            }
            return Center(child: Text("لا توجد بيانات."));
          },
        ),
      ),
    );
  }
}
