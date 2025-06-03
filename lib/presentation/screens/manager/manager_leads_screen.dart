// ignore_for_file: avoid_print, use_build_context_synchronously, unrelated_type_equality_checks, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/presentation/screens/manager/leads_details_screen_manager.dart';
import 'package:homewalkers_app/presentation/screens/manager/tabs_screen_manager.dart';
import 'package:homewalkers_app/presentation/screens/sales/create_leads.dart';
import 'package:homewalkers_app/presentation/viewModels/Manager/cubit/get_manager_leads_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_state.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/manager/manager_custom_filter_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ManagerLeadsScreen extends StatelessWidget {
  final String? stageName;
  const ManagerLeadsScreen({super.key, this.stageName});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
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

    return BlocBuilder<GetManagerLeadsCubit, GetManagerLeadsState>(
      builder: (context, state) {
        if (state is GetManagerLeadsSuccess && stageName != null) {
          // نفلتر مرة واحدة فقط
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<GetManagerLeadsCubit>().filterLeadsByStageInManager(
              stageName!,
            );
          });
        }
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: CustomAppBar(
            title: 'Leads',
            onBack: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TabsScreenManager()),
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
                          context
                              .read<GetManagerLeadsCubit>()
                              .filterLeadsManager(query: value.trim());
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
                                Theme.of(context).brightness ==
                                        Brightness.light
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
                          showFilterDialogManager(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Create Lead Button
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 10.h,
                ),
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
                    icon: const Icon(
                      Icons.add,
                      size: 20,
                      color: Colors.white,
                    ),
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
                    if (state is GetManagerLeadsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is GetManagerLeadsSuccess) {
                      final leads = state.leads.data;
                      if (leads!.isEmpty) {
                        return const Center(child: Text('No leads found.'));
                      }
                      return ListView.builder(
                        itemCount: leads.length,
                        itemBuilder: (context, index) {
                          final lead = leads[index];
                          final leadstageupdated = lead.stagedateupdated;
                          final leadStagetype = lead.stage?.name ?? "";
                          // تحويل التاريخ من String إلى DateTime
                          DateTime? stageUpdatedDate;
                          if (leadstageupdated != null) {
                            try {
                              stageUpdatedDate = DateTime.parse(
                                leadstageupdated,
                              );
                            } catch (_) {
                              stageUpdatedDate = null;
                            }
                          }
                          bool isOutdated = false;
                          if (stageUpdatedDate != null &&
                              (leadStagetype == "Done Deal" ||
                                  leadStagetype == "Transfer" ||
                                  leadStagetype == "Fresh" ||
                                  leadStagetype == "Not Interested")) {
                            final now = DateTime.now();
                            final difference =
                                now.difference(stageUpdatedDate).inMinutes;
                            isOutdated =
                                difference >
                                1; // اعتبره قديم إذا مرّ أكثر من يوم
                          }
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // الجهة اليسرى: الاسم + المرحلة + Last Comment
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lead.name ?? "",
                                          style: GoogleFonts.montserrat(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                        ),
                                        SizedBox(height: 10.h),
                                        Row(
                                          children: [
                                            getStatusIcon(
                                              lead.stage!.name ?? "",
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              lead.stage?.name ?? "none",
                                              style: GoogleFonts.montserrat(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Theme.of(
                                                          context,
                                                        ).brightness ==
                                                        Brightness.light
                                                    ? Constants.maincolor
                                                    : Constants
                                                        .mainDarkmodecolor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) {
                                                return Dialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: BlocProvider(
                                                    create:
                                                        (
                                                          _,
                                                        ) => LeadCommentsCubit(
                                                          GetAllLeadCommentsApiService(),
                                                        )..fetchLeadComments(
                                                          lead.id!,
                                                        ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            16.0,
                                                          ),
                                                      child: BlocBuilder<
                                                        LeadCommentsCubit,
                                                        LeadCommentsState
                                                      >(
                                                        builder: (
                                                          context,
                                                          state,
                                                        ) {
                                                          if (state
                                                              is LeadCommentsLoading) {
                                                            return const SizedBox(
                                                              height: 100,
                                                              child: Center(
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              ),
                                                            );
                                                          } else if (state
                                                              is LeadCommentsError) {
                                                            return SizedBox(
                                                              height: 100,
                                                              child: Center(
                                                                child: Text(
                                                                  "No comments available.",
                                                                ),
                                                              ),
                                                            );
                                                          } else if (state
                                                              is LeadCommentsLoaded) {
                                                            final data =
                                                                state
                                                                    .leadComments
                                                                    .data;
                                                            if (data ==
                                                                    null ||
                                                                data.isEmpty) {
                                                              return const Text(
                                                                'No comments available.',
                                                              );
                                                            }
                                                            final firstItem =
                                                                data.first;
                                                            final firstComment =
                                                                firstItem.comments?.isNotEmpty ==
                                                                        true
                                                                    ? firstItem
                                                                        .comments!
                                                                        .first
                                                                    : null;
                                                            return Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                  "Last Comment",
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                const Text(
                                                                  "Comment",
                                                                  style: TextStyle(
                                                                    color:
                                                                        Constants
                                                                            .maincolor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Text(
                                                                  firstComment
                                                                          ?.firstcomment
                                                                          ?.text ??
                                                                      'No first comment available.',
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                const Text(
                                                                  "Action (Plan)",
                                                                  style: TextStyle(
                                                                    color:
                                                                        Constants
                                                                            .maincolor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Text(
                                                                  firstComment
                                                                          ?.secondcomment
                                                                          ?.text ??
                                                                      'No second comment available.',
                                                                ),
                                                              ],
                                                            );
                                                          } else {
                                                            return const SizedBox(
                                                              height: 100,
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: Text(
                                            "Last Comment",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // الجهة اليمنى: View More + phone + WhatsApp
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      (stageUpdatedDate != null &&
                                              (leadStagetype == "Done Deal" ||
                                                  leadStagetype ==
                                                      "Transfer" ||
                                                  leadStagetype == "Fresh" ||
                                                  leadStagetype ==
                                                      "Not Interested"))
                                          ? SizedBox()
                                          : Icon(
                                            isOutdated
                                                ? Icons.close
                                                : Icons.check_circle,
                                            color:
                                                isOutdated
                                                    ? Colors.red
                                                    : Colors.green,
                                            size: 24,
                                          ),
                                      const SizedBox(height: 3),
                                      InkWell(
                                        onTap: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (
                                                    _,
                                                  ) => LeadsDetailsScreenManager(
                                                    leedId: lead.id!,
                                                    leadName: lead.name ?? '',
                                                    leadPhone:
                                                        lead.phone ?? '',
                                                    leadEmail:
                                                        lead.email ?? '',
                                                    leadStage:
                                                        lead.stage?.name ??
                                                        '',
                                                    leadStageId:
                                                        lead.stage?.id ?? '',
                                                    leadChannel:
                                                        lead.chanel?.name ??
                                                        '',
                                                    leadCreationDate:
                                                        lead.createdAt != null
                                                            ? formatDateTime(
                                                              lead.createdAt!,
                                                            )
                                                            : '',
                                                    leadProject:
                                                        lead.project?.name ??
                                                        '',
                                                    leadLastComment:
                                                        lead.lastcommentdate ??
                                                        '',
                                                    leadcampaign:
                                                        lead.campaign?.name ??
                                                        "campaign",
                                                    leadNotes:
                                                        lead.notes ??
                                                        "no notes",
                                                    leaddeveloper:
                                                        lead
                                                            .project
                                                            ?.developer
                                                            ?.name ??
                                                        "no developer",
                                                  ),
                                            ),
                                          );
                                          context
                                              .read<GetManagerLeadsCubit>()
                                              .getLeadsByManager();
                                        },
                                        child: Text(
                                          'View More',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                Theme.of(
                                                          context,
                                                        ).brightness ==
                                                        Brightness.light
                                                    ? Constants.maincolor
                                                    : Constants
                                                        .mainDarkmodecolor,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap:
                                            () => makePhoneCall(
                                              lead.phone ?? '',
                                            ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.phone,
                                              color:
                                                  Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.light
                                                      ? Constants.maincolor
                                                      : Constants
                                                          .mainDarkmodecolor,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              lead.phone ?? '',
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: () async {
                                          final phone = lead.phone?.replaceAll(
                                            RegExp(r'\D'),
                                            '',
                                          ); // removes all non-digit chars
                                          final url = "https://wa.me/$phone";
                                          if (await canLaunchUrl(
                                            Uri.parse(url),
                                          )) {
                                            await launchUrl(
                                              Uri.parse(url),
                                              mode:
                                                  LaunchMode
                                                      .externalApplication,
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Could not open WhatsApp.",
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            FaIcon(
                                              FontAwesomeIcons.whatsapp,
                                              color:
                                                  Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.light
                                                      ? Constants.maincolor
                                                      : Constants
                                                          .mainDarkmodecolor,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              lead.phone ?? '',
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else if (state is GetManagerLeadsFailure) {
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
