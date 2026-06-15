import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/Admin_with_pagination/fetch_data_with_pagination.dart';
import 'package:homewalkers_app/data/data_sources/fetch_admin_sales_api_service.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_leads_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/All_leads_with_pagination/cubit/all_leads_cubit_with_pagination_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/adminSales/admin_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/adminSales/admin_sales_state.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_tabs_screen.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:shimmer/shimmer.dart';

class AdminSalesSceen extends StatefulWidget {
  final bool showNavBar; // ← أضف ده

  const AdminSalesSceen({super.key, this.showNavBar = true});

  @override
  State<AdminSalesSceen> createState() => _AdminSalesSceenState();
}

class _AdminSalesSceenState extends State<AdminSalesSceen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTabletDevice = () {
      final data = MediaQuery.of(context);
      final physicalSize = data.size;
      final diagonal = math.sqrt(
        math.pow(physicalSize.width, 2) + math.pow(physicalSize.height, 2),
      );
      final inches = diagonal / (data.devicePixelRatio * 160);
      return inches >= 7.0;
    }();

    final double tabletScale = isTabletDevice ? 0.85 : 1.0;
    final double tabletFontScale = isTabletDevice ? 0.9 : 1.0;
    final double tabletWidthScale = isTabletDevice ? 0.85 : 1.0;
    final double tabletHeightScale = isTabletDevice ? 0.9 : 1.0;

    return BlocProvider(
      create:
          (_) =>
              AdminSalesCubit(FetchAdminSalesApiService())
                ..fetchSalesLeadsCount(),
      child: Scaffold(
      bottomNavigationBar:
          widget.showNavBar
              ? SharedAdminNavBar(currentIndex: 2)
              : null, 
        backgroundColor:
            Theme.of(context).brightness == Brightness.light
                ? Constants.backgroundlightmode
                : Constants.backgroundDarkmode,
        appBar: CustomAppBar(
          title: "Sales",
          onBack: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminTabsScreen()),
            );
          },
        ),
        body: Column(
          children: [
            // ── Search Bar ──────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                (16 * tabletWidthScale).w,
                (16 * tabletHeightScale).h,
                (16 * tabletWidthScale).w,
                (8 * tabletHeightScale).h,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).brightness == Brightness.light
                          ? Color(0xffE6E8EB)
                          : Color(0xff333333),
                  borderRadius: BorderRadius.circular((10 * tabletScale).r),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search sales agents by name...',
                    hintStyle: TextStyle(
                      color: Color(0xff737783),
                      fontSize: (14 * tabletFontScale).sp,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Color(0xff737783),
                      size: (20 * tabletFontScale).sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: (16 * tabletWidthScale).w,
                      vertical: (14 * tabletHeightScale).h,
                    ),
                  ),
                ),
              ),
            ),

            // ── List ────────────────────────────────────
            Expanded(
              child: BlocBuilder<AdminSalesCubit, AdminSalesState>(
                builder: (context, state) {
                  if (state is AdminSalesLoading) {
                    return _buildShimmerList(
                      context,
                      isTabletDevice,
                      tabletScale,
                      tabletFontScale,
                      tabletWidthScale,
                      tabletHeightScale,
                    );
                  }

                  if (state is AdminSalesError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: TextStyle(fontSize: (16 * tabletFontScale).sp),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (state is AdminSalesLoaded) {
                    final salesList =
                        (state.data.data ?? []).where((item) {
                          final name = (item.salesName ?? '').toLowerCase();
                          return !name.contains('no sales') &&
                              !name.startsWith('default') &&
                              (_searchQuery.isEmpty ||
                                  name.contains(_searchQuery));
                        }).toList();

                    if (salesList.isEmpty) {
                      return Center(
                        child: Text(
                          'No sales agents found',
                          style: TextStyle(
                            fontSize: (14 * tabletFontScale).sp,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }

                    if (isTabletDevice) {
                      return GridView.builder(
                        padding: EdgeInsets.all((16 * tabletScale).r),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: (16 * tabletWidthScale).w,
                          mainAxisSpacing: (16 * tabletHeightScale).h,
                          childAspectRatio: 1.8,
                        ),
                        itemCount: salesList.length,
                        itemBuilder: (context, index) {
                          final item = salesList[index];
                          return _buildSalesCard(
                            item.salesName ?? 'No Name',
                            (item.activeLeadsCount ?? 0).toInt(),
                            item.salesId ?? '', // ✅ أضف ده
                            context,
                            isTabletDevice,
                            tabletScale,
                            tabletFontScale,
                            tabletWidthScale,
                            tabletHeightScale,
                          );
                        },
                      );
                    } else {
                      return ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: (16 * tabletWidthScale).w,
                          vertical: (8 * tabletHeightScale).h,
                        ),
                        itemCount: salesList.length,
                        itemBuilder: (context, index) {
                          final item = salesList[index];
                          return _buildSalesCard(
                            item.salesName ?? 'No Name',
                            (item.activeLeadsCount ?? 0).toInt(),
                            item.salesId ?? '', // ✅ أضف ده
                            context,
                            isTabletDevice,
                            tabletScale,
                            tabletFontScale,
                            tabletWidthScale,
                            tabletHeightScale,
                          );
                        },
                      );
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesCard(
    String name,
    int leadsCount,
    String salesId, // ✅ أضف ده
    BuildContext context,
    bool isTabletDevice,
    double tabletScale,
    double tabletFontScale,
    double tabletWidthScale,
    double tabletHeightScale,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ Avatar initials
    final initials =
        name
            .trim()
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
            .join();

    return Container(
      margin: EdgeInsets.only(bottom: (12 * tabletHeightScale).h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1e1e1e) : Colors.white,
        borderRadius: BorderRadius.circular((16 * tabletScale).r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: (8 * tabletScale).r,
            offset: Offset(0, (2 * tabletHeightScale).h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all((16 * tabletScale).r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row: Avatar + Name + Leads ──
            Row(
              children: [
                // Avatar
                Container(
                  width: (56 * tabletWidthScale).w,
                  height: (56 * tabletHeightScale).h,
                  decoration: BoxDecoration(
                    color: Constants.maincolor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular((12 * tabletScale).r),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: (18 * tabletFontScale).sp,
                        fontWeight: FontWeight.bold,
                        color: Constants.maincolor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: (12 * tabletWidthScale).w),

                // Name + Role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: (15 * tabletFontScale).sp,
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? Colors.white : const Color(0xFF0D1B2A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: (2 * tabletHeightScale).h),
                      Text(
                        'Sales',
                        style: TextStyle(
                          fontSize: (13 * tabletFontScale).sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),

                // Leads Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: (12 * tabletWidthScale).w,
                    vertical: (6 * tabletHeightScale).h,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? Constants.maincolor.withOpacity(0.2)
                            : const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular((20 * tabletScale).r),
                  ),
                  child: Text(
                    '$leadsCount Leads',
                    style: TextStyle(
                      fontSize: (13 * tabletFontScale).sp,
                      fontWeight: FontWeight.w600,
                      color: Constants.maincolor,
                    ),
                  ),
                ),
              ],
            ),

            // ── Divider ──
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: (12 * tabletHeightScale).h,
              ),
              child: Divider(
                height: 1,
                color: isDark ? Colors.grey[800] : Colors.grey[100],
              ),
            ),

            // ── View Details ──
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => BlocProvider(
                          create:
                              (_) => AllLeadsCubitWithPagination(
                                LeadsApiServiceWithQuery(),
                              ),
                          child: AdminLeadsScreen(
                            data: false,
                            transferefromdata: true,
                            salesIdss: [salesId],
                            leadsCount: leadsCount,
                          ),
                        ),
                  ),
                );
              },
              child: Row(
                children: [
                  Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: (14 * tabletFontScale).sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff003178),
                    ),
                  ),
                  SizedBox(width: (4 * tabletWidthScale).w),
                  Icon(
                    Icons.chevron_right,
                    size: (16 * tabletFontScale).sp,
                    color: Constants.maincolor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList(
    BuildContext context,
    bool isTabletDevice,
    double tabletScale,
    double tabletFontScale,
    double tabletWidthScale,
    double tabletHeightScale,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: (16 * tabletWidthScale).w,
        vertical: (8 * tabletHeightScale).h,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            margin: EdgeInsets.only(bottom: (12 * tabletHeightScale).h),
            padding: EdgeInsets.all((16 * tabletScale).r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular((16 * tabletScale).r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: (56 * tabletWidthScale).w,
                      height: (56 * tabletHeightScale).h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          (12 * tabletScale).r,
                        ),
                      ),
                    ),
                    SizedBox(width: (12 * tabletWidthScale).w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: (16 * tabletHeightScale).h,
                            width: double.infinity,
                            color: Colors.white,
                          ),
                          SizedBox(height: (6 * tabletHeightScale).h),
                          Container(
                            height: (12 * tabletHeightScale).h,
                            width: (80 * tabletWidthScale).w,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: (80 * tabletWidthScale).w,
                      height: (32 * tabletHeightScale).h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          (20 * tabletScale).r,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: (12 * tabletHeightScale).h),
                Container(height: 1, color: Colors.white),
                SizedBox(height: (12 * tabletHeightScale).h),
                Container(
                  height: (13 * tabletHeightScale).h,
                  width: (100 * tabletWidthScale).w,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
