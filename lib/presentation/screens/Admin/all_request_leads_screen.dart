// lib/presentation/screens/requests/requests_history_screen.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/request_leads_api_service.dart';
import 'package:homewalkers_app/data/models/all_sales_model.dart';
import 'package:homewalkers_app/data/models/get_all_lead_requests_model.dart';
import 'package:homewalkers_app/presentation/viewModels/request_leads/request_leads_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/request_leads/request_leads_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_state.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestsHistoryScreen extends StatefulWidget {
  const RequestsHistoryScreen({super.key});

  @override
  State<RequestsHistoryScreen> createState() => _RequestsHistoryScreenState();
}

class _RequestsHistoryScreenState extends State<RequestsHistoryScreen> {
  late final ScrollController _scrollController;
  late final RequestLeadsCubit _requestLeadsCubit;
  late final SalesCubit _salesCubit;
  String _selectedFilter = 'all';
  SalesData? _selectedSales;
  String _userRole = ''; // Add this to store user role

  final Map<String, String> _filterOptions = {
    'all': 'All',
    'completed': 'Completed',
    'failed': 'Failed',
    'pending': 'Pending',
    'recent': 'Last 30 Days',
  };

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _requestLeadsCubit = RequestLeadsCubit(RequestLeadsFromDataApiService());
    _salesCubit = SalesCubit(GetAllSalesApiService());

    _loadUserRoleAndData(); // Create a new method to handle async operations

    // Add scroll listener for infinite scroll
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadUserRoleAndData() async {
    await _loadUserRole(); // Wait for role to load

    final prefs = await SharedPreferences.getInstance();
    final salesId = prefs.getString('salesId') ?? '';
    _userRole = prefs.getString('role') ?? '';
    // Only fetch all sales if user is admin
    if (_userRole.toLowerCase() == 'admin') {
      _salesCubit.fetchAllSales();
      // Load initial data with salesId if available
      _requestLeadsCubit.getAllRequests(isRefresh: true);
    } else {
      _requestLeadsCubit.getAllRequests(
        isRefresh: true,
        userId: salesId.isEmpty ? null : salesId,
      );
    }
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('role') ?? '';
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _requestLeadsCubit.loadMoreRequests();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _requestLeadsCubit.close();
    _salesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _requestLeadsCubit),
        BlocProvider.value(value: _salesCubit),
      ],
      child: Scaffold(
        backgroundColor:
            isDark
                ? Constants.backgroundDarkmode
                : Constants.backgroundlightmode,
        appBar: _buildAppBar(isDark),
        body: RefreshIndicator(
          onRefresh: () => _refreshData(), // Updated to use new method
          color: Constants.maincolor,
          child: Column(
            children: [
              if (_userRole.toLowerCase() == 'admin')
                // Sales Filter Dropdown
                _buildSalesFilter(isDark),
              // Requests List
              Expanded(
                child: BlocConsumer<RequestLeadsCubit, RequestLeadsState>(
                  listener: (context, state) {
                    if (state is GetAllRequestsFailure) {
                      _showSnackbar(context, state.message, isError: true);
                    }
                    if (state is RequestLeadsSuccess) {
                      _showSnackbar(
                        context,
                        'Leads requested successfully!',
                        isError: false,
                      );
                    }
                    if (state is RequestLeadsFailure) {
                      _showSnackbar(context, state.message, isError: true);
                    }
                  },
                  builder: (context, state) {
                    if (state is GetAllRequestsLoading &&
                        _requestLeadsCubit.state is! GetAllRequestsSuccess) {
                      return _buildShimmerLoader();
                    }

                    if (state is GetAllRequestsSuccess) {
                      if (state.requests.isEmpty) {
                        return _buildEmptyState();
                      }

                      return Column(
                        children: [
                          _buildFilterChips(),
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              itemCount: state.requests.length + 1,
                              itemBuilder: (context, index) {
                                if (index >= state.requests.length) {
                                  return _buildLoadingMoreIndicator(
                                    state.hasReachedMax,
                                  );
                                }
                                return _buildRequestCard(
                                  state.requests[index],
                                  isDark,
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }

                    return _buildInitialState();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalesFilter(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1e1e1e) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white24 : Colors.grey.shade200,
          ),
        ),
      ),
      child: BlocBuilder<SalesCubit, SalesState>(
        builder: (context, state) {
          if (state is SalesLoading) {
            return Container(
              height: 50.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                border: Border.all(color: Constants.maincolor.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Constants.maincolor,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Loading sales...',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is SalesLoaded) {
            final salesList = state.salesData.data ?? [];

            // ✅ الحل الكامل للمشكلة
            // التحقق من وجود الـ _selectedSales في اللستة الجديدة
            // لو مش موجود، نرجعه null
            if (_selectedSales != null) {
              final isStillValid = salesList.any(
                (s) => s.userlog?.id == _selectedSales?.userlog?.id,
              );
              if (!isStillValid) {
                // استخدام addPostFrameCallback لتجنب setState أثناء البناء
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _selectedSales = null;
                    });
                  }
                });
              }
            }

            if (salesList.isEmpty) {
              return Container(
                height: 50.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Constants.maincolor.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 20.sp,
                      color: Constants.maincolor,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'No sales available',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            // ✅ تحديد القيمة الحالية الصحيحة للـ DropdownButton
            // نتأكد إن القيمة موجودة في اللستة الجديدة
            final currentValue =
                (_selectedSales != null &&
                        salesList.any(
                          (s) => s.userlog?.id == _selectedSales?.userlog?.id,
                        ))
                    ? _selectedSales
                    : null;

            // لو القيمة اتغيرت، نحدث المتغير الفعلي
            if (currentValue != _selectedSales) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _selectedSales = currentValue;
                  });
                }
              });
            }

            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Constants.maincolor.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<SalesData?>(
                  isExpanded: true,
                  hint: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 20.sp,
                          color: Constants.maincolor,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Filter by Sales Person',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color:
                                isDark ? Colors.white54 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ✅ استخدام currentValue بدل _selectedSales مباشرة
                  value: currentValue,
                  items: [
                    // Add "All Sales" option
                    DropdownMenuItem<SalesData?>(
                      value: null,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Row(
                          children: [
                            Icon(
                              Icons.all_inclusive,
                              size: 20.sp,
                              color: Constants.maincolor,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'All Sales',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color:
                                    isDark
                                        ? Colors.white
                                        : const Color(0xFF0D1B2A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ...salesList.map((sales) {
                      return DropdownMenuItem<SalesData?>(
                        value: sales,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16.r,
                                backgroundColor: Constants.maincolor
                                    .withOpacity(0.1),
                                child: Text(
                                  sales.name?.substring(0, 1).toUpperCase() ??
                                      'S',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Constants.maincolor,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  sales.name ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        isDark
                                            ? Colors.white
                                            : const Color(0xFF0D1B2A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                  onChanged: (SalesData? newValue) {
                    setState(() {
                      _selectedSales = newValue;
                    });

                    final userId = newValue?.userlog?.id;
                    if (userId != null && userId.isNotEmpty) {
                      _requestLeadsCubit.filterByUserId(userId);
                    } else {
                      _requestLeadsCubit.clearFilters();
                    }
                  },
                  dropdownColor:
                      isDark ? const Color(0xff1e1e1e) : Colors.white,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Constants.maincolor,
                    size: 24.sp,
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark ? Colors.white : const Color(0xFF0D1B2A),
                  ),
                ),
              ),
            );
          }

          if (state is SalesError) {
            return Container(
              height: 50.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 20.sp, color: Colors.red),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Failed to load sales',
                      style: TextStyle(fontSize: 14.sp, color: Colors.red),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      size: 20.sp,
                      color: Constants.maincolor,
                    ),
                    onPressed: () => _salesCubit.fetchAllSales(),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? Constants.backgroundDarkmode : Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requests History',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0D1B2A),
            ),
          ),
          Text(
            'Track your lead requests',
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.calendar_today,
            color: Constants.maincolor,
            size: 20.sp,
          ),
          onPressed: () => _showDateRangePicker(context),
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.filter_list,
            color: Constants.maincolor,
            size: 20.sp,
          ),
          onSelected: (value) {
            setState(() => _selectedFilter = value);
            switch (value) {
              case 'all':
                _requestLeadsCubit.clearFilters();
                break;
              case 'completed':
                _requestLeadsCubit.getCompletedRequests();
                break;
              case 'failed':
                _requestLeadsCubit.getFailedRequests();
                break;
              case 'pending':
                _requestLeadsCubit.getPendingRequests();
                break;
              case 'recent':
                _requestLeadsCubit.getRecentRequests();
                break;
            }
          },
          itemBuilder:
              (context) =>
                  _filterOptions.entries.map((entry) {
                    return PopupMenuItem(
                      value: entry.key,
                      child: Row(
                        children: [
                          if (_selectedFilter == entry.key)
                            Icon(
                              Icons.check,
                              color: Constants.maincolor,
                              size: 18.sp,
                            ),
                          if (_selectedFilter == entry.key)
                            SizedBox(width: 8.w),
                          Text(entry.value),
                        ],
                      ),
                    );
                  }).toList(),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'All', 'value': 'all', 'icon': Icons.all_inclusive},
      {'label': 'Completed', 'value': 'completed', 'icon': Icons.check_circle},
      {'label': 'Failed', 'value': 'failed', 'icon': Icons.error},
      {'label': 'Pending', 'value': 'pending', 'icon': Icons.hourglass_empty},
    ];

    return BlocBuilder<RequestLeadsCubit, RequestLeadsState>(
      builder: (context, state) {
        String currentFilter = 'all';
        if (state is GetAllRequestsSuccess) {
          currentFilter = state.currentStatus ?? 'all';
        }

        return Container(
          height: 50.h,
          margin: EdgeInsets.symmetric(vertical: 8.h),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: filters.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final filter = filters[index];
              final isSelected = currentFilter == filter['value'];

              return FilterChip(
                label: Text(filter['label'] as String),
                selected: isSelected,
                onSelected: (_) {
                  final value = filter['value'] as String;
                  if (value == 'all') {
                    _requestLeadsCubit.clearFilters();
                  } else {
                    _requestLeadsCubit.getAllRequests(
                      isRefresh: true,
                      status: value,
                    );
                  }
                },
                avatar: Icon(
                  filter['icon'] as IconData,
                  size: 16.sp,
                  color: isSelected ? Colors.white : Constants.maincolor,
                ),
                labelStyle: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : Constants.maincolor,
                ),
                backgroundColor:
                    isSelected ? Constants.maincolor : Colors.white,
                selectedColor: Constants.maincolor,
                shape: StadiumBorder(
                  side: BorderSide(
                    color:
                        isSelected
                            ? Constants.maincolor
                            : Constants.maincolor.withOpacity(0.3),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              );
            },
          ),
        );
      },
    );
  }

  void _showSnackbar(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.r),
      ),
    );
  }

  void _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Constants.maincolor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      _requestLeadsCubit.filterByDateRange(
        fromDate: picked.start,
        toDate: picked.end,
      );
    }
  }

  void _showRequestDetails(RequestLog request) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: isDark ? Constants.backgroundDarkmode : Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20.r),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 12.h),
                        height: 4.h,
                        width: 40.w,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: EdgeInsets.all(16.r),
                          children: [
                            // Header
                            Row(
                              children: [
                                _buildStatusBadge(request.status),
                                const Spacer(),
                                Text(
                                  request.formattedDate,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color:
                                        isDark
                                            ? Colors.white54
                                            : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),

                            // Request ID
                            Container(
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color:
                                    isDark
                                        ? const Color(0xff1e1e1e)
                                        : Constants.backgroundlightmode,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Request ID',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color:
                                          isDark
                                              ? Colors.white54
                                              : Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    request.id,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isDark
                                              ? Colors.white
                                              : const Color(0xFF0D1B2A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // Stats Grid - استخدم SizedBox بارتفاع ثابت
                            SizedBox(
                              height: 130.h, // ارتفاع ثابت للـ GridView
                              child: GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 3,
                                childAspectRatio: 1.2,
                                crossAxisSpacing: 12.w,
                                mainAxisSpacing: 12.h,
                                children: [
                                  _buildStatCard(
                                    'Requested',
                                    request.requestedlimit.toString(),
                                    Icons.assignment,
                                    isDark,
                                  ),
                                  _buildStatCard(
                                    'Transferred',
                                    request.actualtransferredcount.toString(),
                                    Icons.check_circle,
                                    isDark,
                                    color: Colors.green,
                                  ),
                                  _buildStatCard(
                                    'Max Allowed',
                                    request.maxallowedlimit.toString(),
                                    Icons.trending_up,
                                    isDark,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // User Info
                            _buildDetailSection('User Information', [
                              _buildDetailRow(
                                'Name',
                                request.userid.name,
                                isDark,
                              ),
                              _buildDetailRow(
                                'Email',
                                request.userid.email,
                                isDark,
                              ),
                              _buildDetailRow(
                                'Role',
                                request.userid.role,
                                isDark,
                              ),
                            ], isDark),
                            SizedBox(height: 16.h),

                            // Sales Info
                            _buildDetailSection('Sales Information', [
                              _buildDetailRow(
                                'Sales Name',
                                request.salesid.name,
                                isDark,
                              ),
                              _buildDetailRow(
                                'Transfer From',
                                request.transferfrom.name,
                                isDark,
                              ),
                              _buildDetailRow(
                                'Transfer To',
                                request.transferto.name,
                                isDark,
                              ),
                            ], isDark),
                            SizedBox(height: 16.h),

                            // Notes
                            if (request.notes.isNotEmpty)
                              _buildDetailSection('Notes', [
                                Text(
                                  request.notes,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : Colors.grey.shade700,
                                  ),
                                ),
                              ], isDark),

                            if (request.error != null) ...[
                              SizedBox(height: 16.h),
                              _buildDetailSection('Error', [
                                Text(
                                  request.error!,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.red,
                                  ),
                                ),
                              ], isDark),
                            ],
                            SizedBox(height: 16.h),

                            // Leads List
                            _buildDetailSection(
                              'Leads Received (${request.leadsids.length})',
                              request.leadsids
                                  .map((lead) => _buildLeadCard(lead, isDark))
                                  .toList(),
                              isDark,
                            ),
                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    bool isDark, {
    Color? color,
  }) {
    return Container(
      padding: EdgeInsets.all(5.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1e1e1e) : Constants.backgroundlightmode,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24.sp, color: color ?? Constants.maincolor),
          SizedBox(height: 5.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color ?? (isDark ? Colors.white : const Color(0xFF0D1B2A)),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0D1B2A),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color:
                isDark
                    ? const Color(0xff1e1e1e)
                    : Constants.backgroundlightmode,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? Colors.white : const Color(0xFF0D1B2A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadCard(LeadBasicInfo lead, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isDark ? Constants.backgroundDarkmode : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: Constants.maincolor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              color: Constants.maincolor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lead.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0D1B2A),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  lead.phone,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                ),
                if (lead.project != null)
                  Text(
                    lead.project!.name,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          if (lead.stage != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _getStageColor(lead.stage!.name).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                lead.stage!.name,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: _getStageColor(lead.stage!.name),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStageColor(String stage) {
    switch (stage.toLowerCase()) {
      case 'fresh':
        return Colors.green;
      case 'interested':
        return Colors.blue;
      case 'not interested':
        return Colors.red;
      case 'transfer':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRequestCard(RequestLog request, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1e1e1e) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showRequestDetails(request),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildStatusBadge(request.status),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14.sp,
                          color: isDark ? Colors.white54 : Colors.grey.shade500,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          request.formattedDate,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color:
                                isDark ? Colors.white54 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Request #${request.id.substring(0, 8)}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark
                                      ? Colors.white
                                      : const Color(0xFF0D1B2A),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            request.userid.name,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color:
                                  isDark
                                      ? Colors.white54
                                      : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Constants.maincolor,
                            Constants.maincolor.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${request.leadsids.length}',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Leads',
                              style: TextStyle(
                                fontSize: 8.sp,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _buildInfoTile(
                      icon: Icons.assignment_outlined,
                      label: 'Requested',
                      value: request.requestedlimit.toString(),
                      isDark: isDark,
                    ),
                    SizedBox(width: 16.w),
                    _buildInfoTile(
                      icon: Icons.check_circle_outline,
                      label: 'Transferred',
                      value: request.actualtransferredcount.toString(),
                      isDark: isDark,
                      valueColor: Colors.green,
                    ),
                    SizedBox(width: 16.w),
                    _buildInfoTile(
                      icon: Icons.trending_up,
                      label: 'Max Allowed',
                      value: request.maxallowedlimit.toString(),
                      isDark: isDark,
                    ),
                  ],
                ),
                if (request.error != null) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 16.sp,
                          color: Colors.red,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            request.error!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.red,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    switch (status) {
      case 'completed':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'failed':
        color = Colors.red;
        icon = Icons.error;
        break;
      case 'pending':
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    Color? valueColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: isDark ? Colors.white54 : Colors.grey.shade500,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color:
                  valueColor ??
                  (isDark ? Colors.white : const Color(0xFF0D1B2A)),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: 5,
      itemBuilder:
          (context, index) => Container(
            margin: EdgeInsets.only(bottom: 12.h),
            height: 160.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: const ShimmerEffect(),
          ),
    );
  }

  Widget _buildLoadingMoreIndicator(bool hasReachedMax) {
    if (hasReachedMax) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Center(
          child: Text(
            'No more requests',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 24.w,
              height: 24.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Constants.maincolor),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Loading more...',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              color: Constants.maincolor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history, size: 50.sp, color: Constants.maincolor),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Requests Found',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            'Pull down to refresh or request new leads',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => _refreshData(),
            icon: Icon(Icons.refresh, size: 18.sp),
            label: Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.maincolor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ تحديث دالة الـ _refreshData لإعادة تعيين _selectedSales
  Future<void> _refreshData() async {
    final prefs = await SharedPreferences.getInstance();
    final salesId = prefs.getString('salesId') ?? '';

    // ✅ إعادة تعيين _selectedSales عند الرفريش
    setState(() {
      _selectedSales = null;
    });

    // Apply same logic as initState
    if (_userRole.toLowerCase() == 'admin') {
      _salesCubit.fetchAllSales(); // Refresh sales list for admin
      _requestLeadsCubit.getAllRequests(
        isRefresh: true,
        // userId: salesId.isEmpty ? null : salesId, // Commented as in your code
      );
    } else {
      _requestLeadsCubit.getAllRequests(
        isRefresh: true,
        userId: salesId.isEmpty ? null : salesId,
      );
    }
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: Constants.maincolor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.swipe_down,
              size: 40.sp,
              color: Constants.maincolor,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Pull down to load requests',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// Shimmer Effect Widget
class ShimmerEffect extends StatefulWidget {
  const ShimmerEffect({super.key});

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          height: 160.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                colors: [
                  Colors.grey.shade200,
                  Colors.grey.shade100,
                  Colors.grey.shade200,
                ],
                stops: const [0.0, 0.5, 1.0],
                begin: Alignment(-1 + _controller.value * 2, 0),
                end: Alignment(1 + _controller.value * 2, 0),
              ).createShader(rect);
            },
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        height: 160.h,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }
}
