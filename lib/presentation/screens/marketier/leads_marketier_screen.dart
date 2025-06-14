import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/screens/marketier/marketer_lead_details_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/marketier_tabs_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/create_leads.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LeadsMarketierScreen extends StatelessWidget {
  final String? stageName;
  const LeadsMarketierScreen({super.key,this.stageName});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // عدد التابات
      child: Scaffold(
        // backgroundColor: const Color(0xFFF9F9F9),
        appBar: CustomAppBar(
          title: "Profile",
          onBack: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MarketierTabsScreen()),
            );
          },
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TabBar(
                      isScrollable: true,
                      labelColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Constants.maincolor
                              : Constants.mainDarkmodecolor,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                      ),
                      indicatorColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Constants.maincolor
                              : Constants.mainDarkmodecolor,
                      tabs: const [
                        Tab(text: "Manage Leads"),
                        Tab(text: "Leads Trash"),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Constants.maincolor
                              : Constants.mainDarkmodecolor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateLeadScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Create Lead",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                children: [
                  _buildLeadList(context, "35", false),
                  _buildLeadList(context, "8", true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadList(BuildContext context, String count, bool isTrash) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Row(
            children: [
              Text(
                isTrash ? "All Leads in Trash" : "All Leads",
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).brightness == Brightness.light
                          ? Constants.maincolor
                          : Constants.mainDarkmodecolor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(count, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: 3,
            itemBuilder:
                (context, index) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Mr. Ahmed Ali Ali",
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "Younishomewalkers Sales",
                                  style: GoogleFonts.montserrat(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Constants.maincolor
                                      : Constants.mainDarkmodecolor,
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.copy, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          MarketerLeadDetailsScreen(leedId: ""),
                                ),
                              );
                            },
                            child: Text(
                              "View More",
                              style: GoogleFonts.montserrat(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Constants.maincolor
                                        : Constants.mainDarkmodecolor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.image,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Constants.maincolor
                                    : Constants.mainDarkmodecolor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Follow Up",
                            style: GoogleFonts.montserrat(fontSize: 12),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.phone,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Constants.maincolor
                                    : Constants.mainDarkmodecolor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "971502365120",
                            style: GoogleFonts.montserrat(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.refresh,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Constants.maincolor
                                    : Constants.mainDarkmodecolor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          ),
        ),
      ],
    );
  }
}
