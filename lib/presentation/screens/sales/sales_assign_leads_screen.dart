// ignore_for_file: library_private_types_in_public_api, unused_local_variable
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/core/utils/dialog_utils.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/presentation/screens/sales_tabs_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_leads_sales/get_leads_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/custom_show_assign_dialog.dart';

class SalesAssignLeadsScreen extends StatefulWidget {
  final bool? data;
  final bool? transferfromdata;
  const SalesAssignLeadsScreen({super.key, this.data, this.transferfromdata});

  @override
  _SalesAssignLeadsScreenState createState() => _SalesAssignLeadsScreenState();
}

class _SalesAssignLeadsScreenState extends State<SalesAssignLeadsScreen> {
  List<bool> selected = [];
  List _leads = [];
  List? leadResponse;
  String? leadIdd;

  ScrollController _scrollController = ScrollController(); // ✅
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // أول صفحة
      context.read<GetLeadsCubit>().fetchSalesLeadsWithPagination(
        data: widget.data ?? false,
        transferefromdata: widget.transferfromdata ?? false,
        resetPagination: true,
      );
    });

    // ✅ إضافة Listener للـ scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        // وصلنا تقريبًا لنهاية القائمة، اطلب الصفحة التالية
        context.read<GetLeadsCubit>().fetchSalesLeadsWithPagination(
          data: widget.data ?? false,
          transferefromdata: widget.transferfromdata ?? false,
          isLoadMore: true, // مهم جدًا
          resetPagination: false,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounceTimer?.cancel(); // إلغاء التايمر عند الخروج
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final isTablet = ResponsiveHelper.isTablet(context);
    final isLargeTablet = ResponsiveHelper.isLargeTablet(context);

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:
          Theme.of(context).brightness == Brightness.light
              ? Constants.backgroundlightmode
              : Constants.backgroundDarkmode,
      appBar: CustomAppBar(
        title: "Assign",
        onBack: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SalesTabsScreen()),
          );
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal:
                  isLargeTablet
                      ? 32
                      : isTablet
                      ? 24
                      : 12,
              vertical: isLargeTablet ? 20 : 12,
            ),

            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameController,
                    onChanged: (value) {
                      _debounceTimer?.cancel();
                      _debounceTimer = Timer(
                        const Duration(milliseconds: 500),
                        () {
                          context
                              .read<GetLeadsCubit>()
                              .fetchSalesLeadsWithPagination(
                                search: value.trim(),
                                data: widget.data ?? false,
                                transferefromdata:
                                    widget.transferfromdata ?? false,
                                resetPagination: true,
                              );
                        },
                      );
                    },
                    decoration: InputDecoration(
                      hintText: 'Search',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 16,
                        vertical: isTablet ? 18 : 12,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Constants.maincolor
                                  : Constants.mainDarkmodecolor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Constants.maincolor
                                  : Constants.mainDarkmodecolor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Constants.maincolor
                                  : Constants.mainDarkmodecolor,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTapDown:
                      (details) =>
                          _showAssignMenu(context, details.globalPosition),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Constants.maincolor
                                : Constants.mainDarkmodecolor,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.more_vert,
                      color:
                          Theme.of(context).brightness == Brightness.light
                              ? Constants.maincolor
                              : Constants.mainDarkmodecolor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<GetLeadsCubit, GetLeadsState>(
              builder: (context, state) {
                if (state is GetSalesLeadsWithPaginationLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is GetSalesLeadsWithPaginationSuccess) {
                  _leads = state.model.data ?? [];

                  // إعداد قائمة الاختيار حسب عدد البيانات
                  if (selected.length != _leads.length) {
                    selected = List.generate(_leads.length, (index) => false);
                  }

                  return isTablet
                      ? GridView.builder(
                        controller: _scrollController, // ✅
                        padding: EdgeInsets.symmetric(
                          horizontal: isLargeTablet ? 32 : 24,
                          vertical: 16,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isLargeTablet ? 2 : 1,
                          childAspectRatio: isLargeTablet ? 4.5 : 4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _leads.length,
                        itemBuilder: (context, index) {
                          final lead = _leads[index];
                          leadIdd = lead.id.toString();
                          return buildUserTile(
                            lead.name ?? 'No Name',
                            lead.stage?.name ?? 'No Status',
                            index,
                          );
                        },
                      )
                      : ListView.builder(
                        controller: _scrollController, // ✅
                        itemCount: _leads.length,
                        itemBuilder: (context, index) {
                          final lead = _leads[index];
                          leadIdd = lead.id.toString();
                          return buildUserTile(
                            lead.name ?? 'No Name',
                            lead.stage?.name ?? 'No Status',
                            index,
                          );
                        },
                      );
                } else if (state is GetLeadsError) {
                  return Center(child: Text(" ${state.message}"));
                } else {
                  return Center(child: Text("no data found"));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignDialog() async {
    final selectedIndices =
        selected
            .asMap()
            .entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    if (selectedIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select at least one lead")),
      );
      return;
    }

    final selectedLeads = selectedIndices.map((i) => _leads[i]).toList();

    await showDialog(
      context: context,
      builder:
          (context) => BlocBuilder<GetLeadsCubit, GetLeadsState>(
            builder: (context, state) {
              if (state is GetSalesLeadsWithPaginationLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is GetSalesLeadsWithPaginationSuccess) {
                leadResponse = state.model.data ?? [];
              } else if (state is GetSalesLeadsWithPaginationError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
                return SizedBox.shrink();
              }

              return BlocProvider(
                create: (_) => SalesCubit(GetAllSalesApiService()),
                child: AssignDialog(
                  leadIds: selectedLeads.map((e) => e.id ?? 0).toList(),
                  leadId: leadIdd,
                  leadResponse: leadResponse,
                  mainColor:
                      Theme.of(context).brightness == Brightness.light
                          ? Constants.maincolor
                          : Constants.mainDarkmodecolor,

                  onSuccess: () {
                    // ← هنا بعد نجاح العملية، أرسل طلب إعادة تحميل الليدز
                    context.read<GetLeadsCubit>().fetchSalesLeadsWithPagination(
                      data: widget.data ?? false,
                      transferefromdata: widget.transferfromdata ?? false,
                    );
                  },
                ),
              );
            },
          ),
    );
  }

  void _showAssignMenu(BuildContext context, Offset position) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'assign',
          child: Text('Assign Leads'),
          onTap: () => Future.delayed(Duration.zero, () => _showAssignDialog()),
        ),
      ],
    );
  }

  Widget buildUserTile(String name, String status, int index) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.light
                ? Colors.grey[100]
                : Colors.black87,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  status,
                  style: TextStyle(
                    color:
                        Theme.of(context).brightness == Brightness.light
                            ? Constants.maincolor
                            : Constants.mainDarkmodecolor,
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: selected[index],
            shape: ContinuousRectangleBorder(),
            activeColor:
                Theme.of(context).brightness == Brightness.light
                    ? Constants.maincolor
                    : Constants.mainDarkmodecolor,
            onChanged: (val) {
              setState(() {
                selected[index] = val!;
              });
            },
          ),
        ],
      ),
    );
  }
}
