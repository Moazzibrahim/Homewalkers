// lib/presentation/screens/request_leads_screen.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/core/utils/dialog_utils.dart';
import 'package:homewalkers_app/data/data_sources/request_leads_api_service.dart';
import 'package:homewalkers_app/data/models/request_leads_model.dart';
import 'package:homewalkers_app/presentation/viewModels/request_leads/request_leads_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/request_leads/request_leads_state.dart';
import 'package:homewalkers_app/presentation/widgets/number_input_widget.dart';

class RequestLeadsScreen extends StatefulWidget {
  const RequestLeadsScreen({super.key});

  @override
  State<RequestLeadsScreen> createState() => _RequestLeadsScreenState();
}

class _RequestLeadsScreenState extends State<RequestLeadsScreen> {
  int _requestedLeadsCount = 5;
  int _maxAllowedLeads = 50;
  int _remainingLeads = 0;
  bool _isCalculating = true;

  @override
  void initState() {
    super.initState();
    _calculateRemainingLeads();
  }

  Future<void> _calculateRemainingLeads() async {
    final apiService = RequestLeadsFromDataApiService();

    try {
      final response = await apiService.getAllRequests(page: 1, limit: 1);
      if (response.status == 'success') {
        setState(() {
          _remainingLeads = 50;
          _maxAllowedLeads = 50;
          _isCalculating = false;
        });
      } else {
        setState(() {
          _isCalculating = false;
        });
      }
    } catch (e) {
      setState(() {
        _isCalculating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = ResponsiveHelper.isTablet(context);

    return BlocProvider(
      create: (context) => RequestLeadsCubit(RequestLeadsFromDataApiService()),
      child: Scaffold(
        backgroundColor:
            isDark
                ? Constants.backgroundDarkmode
                : Constants.backgroundlightmode,
        appBar: AppBar(
          title: const Text(
            'Request New Leads',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: isDark ? Constants.backgroundDarkmode : Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocConsumer<RequestLeadsCubit, RequestLeadsState>(
          listener: (context, state) {
            if (state is RequestLeadsSuccess) {
              _showSuccessDialog(context, state.response);
            } else if (state is RequestLeadsFailure) {
              DialogUtils.showAlertDialog(context, 'Error', state.message);
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 32 : 20,
                        vertical: 20,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildHeader(context),
                          const SizedBox(height: 24),
                          _buildInfoCard(context),
                          const SizedBox(height: 24),
                          NumberInputField(
                            initialValue: 5,
                            minValue: 1,
                            maxValue: _maxAllowedLeads,
                            step: 1,
                            label: 'Number of Leads to Request',
                            hintText: 'Enter number of leads',
                            onValueChanged: (value) {
                              setState(() {
                                _requestedLeadsCount = value;
                              });
                            },
                          ),
                          const SizedBox(height: 32),
                          _buildRequestButton(context, state),
                          const SizedBox(height: 16),
                          _buildNote(context),
                        ]),
                      ),
                    ),
                  ],
                ),
                if (state is RequestLeadsLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Constants.maincolor.withOpacity(0.1),
            Constants.maincolor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.rocket_launch_outlined,
            size: 60,
            color: Constants.maincolor,
          ),
          const SizedBox(height: 12),
          Text(
            'Get New Leads',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Request leads from the data centre pool',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1e1e1e) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Constants.maincolor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.info_outline,
              color: Constants.maincolor,
              size: isTablet ? 28 : 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Leads',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isCalculating ? '...' : '$_remainingLeads leads available',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Max $_maxAllowedLeads leads per request',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestButton(BuildContext context, RequestLeadsState state) {
    final isEnabled = state is! RequestLeadsLoading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed:
            isEnabled
                ? () {
                  // ✅ حفظ الـ context الحالي قبل فتح الديالوج
                  final currentContext = context;

                  showDialog(
                    context: currentContext,
                    builder:
                        (dialogContext) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text(
                            'Confirm Request',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: Text(
                            'Are you sure you want to request $_requestedLeadsCount leads?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(dialogContext); // يقفل الديالوج

                                // ✅ استخدام الـ context المحفوظ من الـ build
                                final cubit =
                                    currentContext.read<RequestLeadsCubit>();
                                cubit.requestLeads(
                                  requestedLimit: _requestedLeadsCount,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Constants.maincolor,
                              ),
                              child: const Text(
                                'OK',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                  );
                }
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.maincolor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          'Request $_requestedLeadsCount Leads',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildNote(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isDark ? Colors.amber.shade900 : Colors.amber.shade50)
            .withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: isDark ? Colors.amber.shade300 : Colors.amber.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Leads will be assigned to you automatically. Check your dashboard for updates.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.amber.shade300 : Colors.amber.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, RequestLeadsResponse response) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final summary = response.data?.summary;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: BoxConstraints(maxWidth: isTablet ? 500 : 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Constants.maincolor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Constants.maincolor,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Success!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    response.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  if (summary != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow(
                            'Requested Leads',
                            '${summary.requested}',
                            Icons.request_page,
                          ),
                          const Divider(),
                          _buildSummaryRow(
                            'Transferred to you',
                            '${summary.transferred}',
                            Icons.assignment_turned_in,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // ✅ إغلاق الديالوج فقط بدون إرجاع قيمة
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Close'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // ✅ إغلاق الديالوج ثم إرجاع true للشاشة السابقة
                            Navigator.pop(context); // إغلاق الديالوج
                            Navigator.pop(
                              context,
                              true,
                            ); // إغلاق الشاشة وإرجاع true
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Constants.maincolor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Back to Dashboard',
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
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    IconData icon, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Constants.maincolor),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? Constants.maincolor : null,
            ),
          ),
        ],
      ),
    );
  }
}
