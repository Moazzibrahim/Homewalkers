// ignore_for_file: avoid_print, use_build_context_synchronously, unrelated_type_equality_checks, deprecated_member_use, unused_local_variable
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/presentation/screens/sales/create_leads.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_leads_details_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales_tabs_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_leads_sales/get_leads_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_state.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/custom_filter_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SalesLeadsScreen extends StatelessWidget {
  final String? stageName;
  const SalesLeadsScreen({super.key, this.stageName});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    bool isOutdated = false;
    String formatDateTime(String dateStr) {
      try {
        final dateTime = DateTime.parse(dateStr);
        final day = dateTime.day.toString().padLeft(2, '0');
        final month = dateTime.month.toString().padLeft(2, '0');
        final year = dateTime.year;
        final hour = dateTime.hour.toString().padLeft(2, '0');
        final minute = dateTime.minute.toString().padLeft(2, '0');
        return '$day/$month/$year - $hour:$minute';
      } catch (e) {
        return dateStr; // fallback في حال كان التاريخ مش صحيح
      }
    }

    Widget getStatusIcon(String status) {
      switch (status) {
        case 'Follow Up':
          return Icon(
            Icons.mark_email_unread_outlined,
            color:
                Theme.of(context).brightness == Brightness.light
                    ? Constants.maincolor
                    : Constants.mainDarkmodecolor,
          );
        case 'Follow':
          return Icon(
            Icons.mark_email_unread_outlined,
            color:
                Theme.of(context).brightness == Brightness.light
                    ? Constants.maincolor
                    : Constants.mainDarkmodecolor,
          );
        case 'Meeting':
          return Icon(
            Icons.chat_bubble_outline,
            color:
                Theme.of(context).brightness == Brightness.light
                    ? Constants.maincolor
                    : Constants.mainDarkmodecolor,
          );
        case 'Done Deal':
          return Icon(
            Icons.check_box_outlined,
            color:
                Theme.of(context).brightness == Brightness.light
                    ? Constants.maincolor
                    : Constants.mainDarkmodecolor,
          );
        case 'Interested':
          return Icon(
            FontAwesomeIcons.check,
            color:
                Theme.of(context).brightness == Brightness.light
                    ? Constants.maincolor
                    : Constants.mainDarkmodecolor,
          );
        case 'Not Interested':
          return Icon(
            FontAwesomeIcons.timesCircle,
            color:
                Theme.of(context).brightness == Brightness.light
                    ? Constants.maincolor
                    : Constants.mainDarkmodecolor,
          );
        case 'Fresh':
          return Icon(
            Icons.new_releases,
            color:
                Theme.of(context).brightness == Brightness.light
                    ? Constants.maincolor
                    : Constants.mainDarkmodecolor,
          );
        case 'Transfer':
          return Icon(
            Icons.no_transfer,
            color:
                Theme.of(context).brightness == Brightness.light
                    ? Constants.maincolor
                    : Constants.mainDarkmodecolor,
          );
        default:
          return const Icon(Icons.info_outline);
      }
    }

    void makePhoneCall(String phoneNumber) async {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.platformDefault);
      } else {
        print('Could not launch $phoneUri');
      }
    }

    return BlocBuilder<GetLeadsCubit, GetLeadsState>(
      builder: (context, state) {
        if (state is GetLeadsSuccess && stageName != null) {
          // نفلتر مرة واحدة فقط
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<GetLeadsCubit>().filterLeadsByStageName(stageName!);
          });
        }
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: CustomAppBar(
            title: 'Leads',
            onBack: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SalesTabsScreen()),
              );
            },
          ),
          body: Column(
            children: [
              // Search & filter
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        onChanged: (value) {
                          context.read<GetLeadsCubit>().filterLeads(
                            query: value.trim(),
                          );
                        },
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: GoogleFonts.montserrat(
                            color: Color(0xff969696),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Constants.maincolor
                                    : Constants.mainDarkmodecolor,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Constants.maincolor
                                      : Constants.mainDarkmodecolor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Constants.maincolor
                                      : Constants.mainDarkmodecolor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      height: 50.h,
                      width: 50.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F1F2),
                        border: Border.all(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Constants.maincolor
                                  : Constants.mainDarkmodecolor,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.filter_list,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Constants.maincolor
                                  : Constants.mainDarkmodecolor,
                        ),
                        onPressed: () {
                          showFilterDialog(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Create Lead Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Constants.maincolor
                              : Constants.mainDarkmodecolor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateLeadScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 20, color: Colors.white),
                    label: Text(
                      'Create Lead',
                      style: GoogleFonts.montserrat(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              // Leads List Based on State
              Expanded(
                child: Builder(
                  builder: (_) {
                    if (state is GetLeadsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is GetLeadsSuccess) {
                      final leads = state.assignedModel.data;
                      if (leads!.isEmpty) {
                        return const Center(child: Text('No leads found.'));
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<GetLeadsCubit>().fetchLeads();
                        },
                        child: ListView.builder(
                          itemCount: leads.length,
                          itemBuilder: (context, index) {
                          final lead = leads[index];
                          final salesfcmtoken=lead.sales?.teamleader?.fcmtokenn;
                          final prefs = SharedPreferences.getInstance();
                          final fcmToken = prefs.then((prefs) => prefs.setString('fcm_token_sales', salesfcmtoken ?? ''));
                          log("fcmToken of sales: $salesfcmtoken");
                            final leadstageupdated = lead.stagedateupdated;
                            final leadStagetype = lead.stage?.name ?? "";
                            // تحويل التاريخ من String إلى DateTime
                            DateTime? stageUpdatedDate;
                            if (leadstageupdated != null) {
                              try {
                                stageUpdatedDate = DateTime.parse(
                                  leadstageupdated,
                                );
                                log("stageUpdatedDate: $stageUpdatedDate");
                                log("stage type: $leadStagetype");
                              } catch (_) {
                                stageUpdatedDate = null;
                              }
                            }
                            if (stageUpdatedDate != null) {
                              final now = DateTime.now().toUtc();
                              print("now: $now");
                              final difference =
                                  now.difference(stageUpdatedDate).inMinutes;
                              print("difference: $difference");
                              isOutdated =
                                  difference >
                                  1; // اعتبره قديم إذا مرّ أكثر من دقيقة
                              print("isOutdated: $isOutdated");
                            }
return Card(
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------- Row 1: Name and Status Icon ----------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                lead.name ?? "No Name",
                style: GoogleFonts.montserrat(fontSize: 16.sp, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            (stageUpdatedDate != null && (leadStagetype == "Done Deal" || leadStagetype == "Transfer" || leadStagetype == "Fresh" || leadStagetype == "Not Interested"))
                ? const SizedBox()
                : Icon(
                    isOutdated ? Icons.cancel : Icons.check_circle,
                    color: isOutdated ? Colors.red : Colors.green,
                    size: 24,
                  ),
          ],
        ),
        SizedBox(height: 12.h),

        // ---------- Row 2: Sales Person ----------
        Row(
          children: [
            Icon(Icons.person_pin_outlined, color: Theme.of(context).brightness == Brightness.light ? Constants.maincolor : Constants.mainDarkmodecolor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                lead.sales?.name ?? "No Sales",
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // ---------- Row 3: Stage Info ----------
        // Total Submissions is removed as it's not in the provided code logic
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                getStatusIcon(lead.stage?.name ?? ""),
                const SizedBox(width: 6),
                Text(
                  lead.stage?.name ?? "none",
                  style: GoogleFonts.montserrat(fontSize: 11.sp, fontWeight: FontWeight.w400),
                ),
              ],
            ),
            Row(
              children: [
                Text("Σ", style: TextStyle(color: Theme.of(context).brightness == Brightness.light ? Constants.maincolor : Constants.mainDarkmodecolor, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                const SizedBox(width: 3),
                Text(
                  // Logic from your new code
                  "Total Submission: ${lead.totalSubmissions}",
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // ---------- Row 4: WhatsApp and Phone Call ----------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () async {
                final phone = lead.phone?.replaceAll(RegExp(r'\D'), '');
                final url = "https://wa.me/$phone";
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open WhatsApp.")));
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(FontAwesomeIcons.whatsapp, color: Theme.of(context).brightness == Brightness.light ? Constants.maincolor : Constants.mainDarkmodecolor, size: 18),
                  const SizedBox(width: 8),
                  Text(lead.phone ?? '', style: TextStyle(fontSize: 11.sp)),
                ],
              ),
            ),
            InkWell(
              onTap: () => makePhoneCall(lead.phone ?? ''),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone, color: Theme.of(context).brightness == Brightness.light ? Constants.maincolor : Constants.mainDarkmodecolor, size: 18),
                  const SizedBox(width: 8),
                  Text(lead.phone ?? '', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // ---------- Row 5: Last Comment Button ----------
        // The action icons (Edit, Copy) are removed as they are not in the provided logic or are requested to be removed.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).brightness == Brightness.light ? Constants.maincolor : Constants.mainDarkmodecolor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) {
                    return Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: BlocProvider(
                        create: (_) => LeadCommentsCubit(GetAllLeadCommentsApiService())..fetchLeadComments(lead.id!),
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: BlocBuilder<LeadCommentsCubit, LeadCommentsState>(builder: (context, state) {
                              if (state is LeadCommentsLoading) {
                                return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
                              } else if (state is LeadCommentsError) {
                                return SizedBox(height: 100, child: Center(child: Text("No comments available.")));
                              } else if (state is LeadCommentsLoaded) {
                                final data = state.leadComments.data;
                                if (data == null || data.isEmpty) {
                                  return const Text('No comments available.');
                                }
                                final firstItem = data.first;
                                final firstComment = firstItem.comments?.isNotEmpty == true ? firstItem.comments!.first : null;
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Last Comment", style: TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 10),
                                    const Text("Comment", style: TextStyle(color: Constants.maincolor, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 5),
                                    Text(firstComment?.firstcomment?.text ?? 'No comment available.'),
                                    const SizedBox(height: 10),
                                    const Text("Action (Plan)", style: TextStyle(color: Constants.maincolor, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 5),
                                    Text(firstComment?.secondcomment?.text ?? 'No action available.'),
                                  ],
                                );
                              } else {
                                return const SizedBox(height: 100, child: Text("no comments"));
                              }
                            })),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 16),
              label: const Text("Last Comment", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            // Empty container as there are no action buttons on the right
            const SizedBox.shrink(),
          ],
        ),

        // ---------- Row 6: View More Link ----------
        SizedBox(height: 8.h),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () async {
              // Navigation and refresh logic from this specific code
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SalesLeadsDetailsScreen(
                    leedId: lead.id!,
                    leadName: lead.name ?? '',
                    leadPhone: lead.phone ?? '',
                    leadEmail: lead.email ?? '',
                    leadStage: lead.stage?.name ?? '',
                    leadStageId: lead.stage?.id ?? '',
                    leadChannel: lead.chanel?.name ?? '',
                    leadCreationDate: lead.createdAt != null ? formatDateTime(lead.createdAt!) : '',
                    leadProject: lead.project?.name ?? '',
                    leadLastComment: lead.lastcommentdate ?? '',
                    leadcampaign: lead.campaign?.name ?? "campaign",
                    leadNotes: lead.notes ?? "no notes",
                    leaddeveloper: lead.project?.developer?.name ?? "no developer",
                    fcmtoken: salesfcmtoken,
                  ),
                ),
              );
              context.read<GetLeadsCubit>().fetchLeads(showLoading: false);
            },
            child: Text(
              'View More',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.light ? Constants.maincolor : Constants.mainDarkmodecolor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    ),
  ),
);
                          },
                        ),
                      );
                    } else if (state is GetLeadsError) {
                      return Center(child: Text(' ${state.message}'));
                    } else {
                      return const Center(child: Text('No leads found.'));
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
