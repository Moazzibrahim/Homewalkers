import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/data/models/lead_comments_model.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_state.dart';
import 'package:homewalkers_app/presentation/widgets/custom_add_comment_sheet.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesCommentsScreen extends StatelessWidget {
  final String leedId;
  final TextStyle titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  final TextStyle subtitleStyle = TextStyle(color: Colors.grey);

  final TextStyle commentTextStyle = TextStyle(fontSize: 14);

  SalesCommentsScreen({super.key, required this.leedId});

  Future<String> checkAuthName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    return name ?? 'User';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              LeadCommentsCubit(GetAllLeadCommentsApiService())
                ..fetchLeadComments(leedId),
      child: Scaffold(
        appBar: CustomAppBar(
          title: "comments",
          onBack: () => Navigator.pop(context),
        ),
        body: BlocBuilder<LeadCommentsCubit, LeadCommentsState>(
          builder: (context, state) {
            if (state is LeadCommentsLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is LeadCommentsError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is LeadCommentsLoaded) {
              final leadComments = state.leadComments;
              log("lead id: $leedId");

              if (leadComments.data == null || leadComments.data!.isEmpty) {
                return Center(child: Text('No comments found'));
              }

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: leadComments.data!.length,
                itemBuilder: (context, index) {
                  final dataItem = leadComments.data![index];

                  // نقدر نبني كارت لكل DataItem ويعرض أول comment عنده
                  return buildCommentCard(context, dataItem);
                },
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  Widget buildCommentCard(BuildContext context, DataItem dataItem) {
    final TextStyle commentTitleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color:
          Theme.of(context).brightness == Brightness.light
              ? Constants.maincolor
              : Constants.mainDarkmodecolor,
    );

    final firstComment = dataItem.comments?.first.firstcomment;
    final secondComment = dataItem.comments?.first.secondcomment;
    // final commentDate = dataItem.comments?.first.stageDate;

    String formatDate(DateTime? date) {
      if (date == null) return '';
      return '${date.day}/${date.month}/${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // CircleAvatar(
                //   backgroundImage: AssetImage('assets/images/avatar.png'),
                //   radius: 20,
                // ),
                // SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder(
                      future: checkAuthName(), // ✅ جلب الاسم
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text(" ....");
                        } else if (snapshot.hasError) {
                          return const Text('Error fetching name');
                        } else {
                          return Text(
                            '${snapshot.data}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? const Color(0xff080719)
                                      : Colors.white,
                            ),
                          );
                        }
                      },
                    ),
                    Text('Sales', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Text('First action', style: commentTitleStyle),
            Text(
              firstComment?.text ?? 'No First Comment',
              style: TextStyle(fontSize: 14),
            ),
            if (firstComment?.date != null)
              Text(
                "comment at :${formatDate(firstComment!.date)}",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            SizedBox(height: 6),
            Text('Second action', style: commentTitleStyle),
            Text(
              secondComment?.text ?? 'No Second Comment',
              style: TextStyle(fontSize: 14),
            ),
            if (secondComment?.date != null)
              Text(
                "comment at : ${formatDate(secondComment!.date)}",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder:
                          (_) => AddCommentBottomSheet(
                            buttonName: "Edit comment",
                            optionalName: "Edit",
                          ),
                    );
                  },
                  style: TextButton.styleFrom(
                    minimumSize: Size(60, 32),
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? Constants.maincolor
                            : Constants.mainDarkmodecolor,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text('Edit', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
