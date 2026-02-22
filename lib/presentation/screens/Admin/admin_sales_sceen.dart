import 'dart:math' as math; // ✅ للكشف عن التابلت
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ✅ مهم للتجاوب
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/fetch_admin_sales_api_service.dart';
import 'package:homewalkers_app/presentation/viewModels/adminSales/admin_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/adminSales/admin_sales_state.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_tabs_screen.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:shimmer/shimmer.dart';

class AdminSalesSceen extends StatelessWidget {
  const AdminSalesSceen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ كشف نوع الجهاز داخل الـ build
    final bool isTabletDevice = () {
      final data = MediaQuery.of(context);
      final physicalSize = data.size;
      final diagonal = math.sqrt(
        math.pow(physicalSize.width, 2) + math.pow(physicalSize.height, 2),
      );
      final inches = diagonal / (data.devicePixelRatio * 160);
      return inches >= 7.0;
    }();
    
    // ✅ عوامل التصغير حسب الجهاز
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
        backgroundColor:
            Theme.of(context).brightness == Brightness.light
                ? Constants.backgroundlightmode
                : Constants.backgroundDarkmode,
        appBar: CustomAppBar(
          title: "Sales",
          onBack: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminTabsScreen(),
              ),
            );
          },
        ),
        body: BlocBuilder<AdminSalesCubit, AdminSalesState>(
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
                child: Padding(
                  padding: EdgeInsets.all((16 * tabletScale).r),
                  child: Text(
                    state.message,
                    style: TextStyle(
                      fontSize: (16 * tabletFontScale).sp,
                      color:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black87
                              : Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (state is AdminSalesLoaded) {
              final salesList = state.data.data ?? [];

              // ✅ استخدام GridView للتابلت لعرض أكثر من عمود
              if (isTabletDevice) {
                return GridView.builder(
                  padding: EdgeInsets.all((16 * tabletScale).r),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // ✅ تابلت: عمودين
                    crossAxisSpacing: (16 * tabletWidthScale).w,
                    mainAxisSpacing: (16 * tabletHeightScale).h,
                    childAspectRatio: 1.8, // ✅ نسبة مناسبة للكارد
                  ),
                  itemCount: salesList.length,
                  itemBuilder: (context, index) {
                    final item = salesList[index];
                    return _buildSalesCard(
                      item.salesName ?? 'No Name',
                      (item.activeLeadsCount ?? 0).toInt(),
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
                // ✅ موبايل: ListView عادي
                return ListView.builder(
                  padding: EdgeInsets.all((16 * tabletScale).r),
                  itemCount: salesList.length,
                  itemBuilder: (context, index) {
                    final item = salesList[index];
                    return _buildSalesCard(
                      item.salesName ?? 'No Name',
                      (item.activeLeadsCount ?? 0).toInt(),
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
    );
  }

  // 💳 كارد السيلز - متجاوب بالكامل
  Widget _buildSalesCard(
    String name,
    int leadsCount,
    BuildContext context,
    bool isTabletDevice,
    double tabletScale,
    double tabletFontScale,
    double tabletWidthScale,
    double tabletHeightScale,
  ) {
    return Card(
      elevation: (2 * tabletScale).r,
      margin: EdgeInsets.symmetric(
        vertical: (8 * tabletHeightScale).h,
        horizontal: isTabletDevice ? 0 : (0 * tabletWidthScale).w,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular((12 * tabletScale).r),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: (16 * tabletWidthScale).w,
          vertical: (12 * tabletHeightScale).h,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: (16 * tabletFontScale).sp,
                      color:
                          Theme.of(context).brightness == Brightness.light
                              ? const Color(0xFF0D1B2A)
                              : Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: (4 * tabletHeightScale).h),
                  Text(
                    'Sales',
                    style: TextStyle(
                      fontSize: (12 * tabletFontScale).sp,
                      color:
                          Theme.of(context).brightness == Brightness.light
                              ? Constants.maincolor
                              : Constants.mainDarkmodecolor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: (12 * tabletWidthScale).w,
                vertical: (6 * tabletHeightScale).h,
              ),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? Constants.maincolor
                        : Constants.mainDarkmodecolor,
                borderRadius: BorderRadius.circular((16 * tabletScale).r),
              ),
              child: Text(
                '$leadsCount ${leadsCount == 1 ? 'Lead' : 'Leads'}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: (14 * tabletFontScale).sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔆 Shimmer loading list - متجاوب بالكامل
  Widget _buildShimmerList(
    BuildContext context,
    bool isTabletDevice,
    double tabletScale,
    double tabletFontScale,
    double tabletWidthScale,
    double tabletHeightScale,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isTabletDevice) {
      // ✅ تابلت: GridView Shimmer
      return GridView.builder(
        padding: EdgeInsets.all((16 * tabletScale).r),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: (16 * tabletWidthScale).w,
          mainAxisSpacing: (16 * tabletHeightScale).h,
          childAspectRatio: 1.8,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            highlightColor: isDark ? Colors.grey[500]! : Colors.grey[100]!,
            child: Card(
              color: isDark ? Colors.grey[800] : Colors.white,
              elevation: (2 * tabletScale).r,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular((12 * tabletScale).r),
              ),
              child: Container(
                padding: EdgeInsets.all((16 * tabletScale).r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: (20 * tabletHeightScale).h,
                      width: double.infinity,
                      color: isDark ? Colors.grey[700] : Colors.white,
                    ),
                    SizedBox(height: (8 * tabletHeightScale).h),
                    Container(
                      height: (16 * tabletHeightScale).h,
                      width: (80 * tabletWidthScale).w,
                      color: isDark ? Colors.grey[600] : Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      // ✅ موبايل: ListView Shimmer
      return ListView.builder(
        padding: EdgeInsets.all((16 * tabletScale).r),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            highlightColor: isDark ? Colors.grey[500]! : Colors.grey[100]!,
            child: Card(
              color: isDark ? Colors.grey[800] : Colors.white,
              elevation: (2 * tabletScale).r,
              margin: EdgeInsets.symmetric(
                vertical: (8 * tabletHeightScale).h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular((12 * tabletScale).r),
              ),
              child: ListTile(
                title: Container(
                  height: (16 * tabletHeightScale).h,
                  width: double.infinity,
                  color: isDark ? Colors.grey[700] : Colors.white,
                ),
                subtitle: Container(
                  height: (12 * tabletHeightScale).h,
                  width: (100 * tabletWidthScale).w,
                  margin: EdgeInsets.only(top: (8 * tabletHeightScale).h),
                  color: isDark ? Colors.grey[600] : Colors.white,
                ),
                trailing: Container(
                  width: (80 * tabletWidthScale).w,
                  height: (32 * tabletHeightScale).h,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.white,
                    borderRadius: BorderRadius.circular(
                      (16 * tabletScale).r,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }
}