import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_tabs_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_leads_sales/get_leads_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/custom_filter_dialog.dart';

class TeamLeaderSalesScreen extends StatelessWidget {
  const TeamLeaderSalesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();

    return BlocBuilder<GetLeadsCubit, GetLeadsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: CustomAppBar(
            title: 'Sales',
            onBack: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeamLeaderTabsScreen(),
                ),
              );
            },
          ),
          body: Column(
            children: [
              // Search & Filter
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
                            name:
                                nameController.text.trim().isEmpty
                                    ? null
                                    : nameController.text.trim(),
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
              // إضافة العناوين فوق القائمة
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18.0,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sales Name',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Constants.maincolor
                                : Constants
                                    .mainDarkmodecolor, // نفس اللون الظاهر في الصورة
                      ),
                    ),
                    Text(
                      'Leads Number',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Constants.maincolor
                                : Constants.mainDarkmodecolor,
                      ),
                    ),
                  ],
                ),
              ),
              // List of Sales
              Expanded(
                child: ListView.builder(
                  itemCount: 10,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  index == 1 ? 'Amira Mohamed' : 'Jhon Smith',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Sales',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Constants.maincolor
                                            : Constants.mainDarkmodecolor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Constants.maincolor
                                        : Constants.mainDarkmodecolor,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '50',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Constants.maincolor
                                        : Constants.mainDarkmodecolor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
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
