// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:homewalkers_app/presentation/screens/manager/tabs_screen_manager.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';

class managerTeamLeaderScreen extends StatelessWidget {
  final List<Map<String, String>> salesList = List.generate(
    7,
    (index) => {
      "name": "Fady Mohamed",
      "location": "Sharja",
      "image": "https://i.pravatar.cc/100?img=3",
    },
  );

  managerTeamLeaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Team Leaders",
        onBack: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TabsScreenManager()),
          );
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Team Leader and Sales That related with you.",
                  style: TextStyle(
                    color: Color(0xff7F8689),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: "Select Team Leaders",
                    hintStyle: TextStyle(
                      color: Color(0xffABABAD),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xffFFFFFF)),
                    ),
                  ),
                  items: [],
                  onChanged: (_) {},
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Ahmed Younes",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "(Active)",
                                  style: TextStyle(
                                    color: Color.fromRGBO(11, 96, 59, 1),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Text("Role: Team Leader"),
                            Text("Email: @moazibrahim894"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Your Sales",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                itemCount: salesList.length,
                itemBuilder: (context, index) {
                  final sale = salesList[index];
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(sale['image']!),
                    ),
                    title: Text(sale['name']!),
                    trailing: Text(sale['location']!),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
