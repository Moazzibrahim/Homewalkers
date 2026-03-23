// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/constants.dart';
import '../../data/data_sources/domains/fetch_domains_api_servive.dart';
import 'login_screen.dart';

class CompanySelectionScreen extends StatefulWidget {
  const CompanySelectionScreen({super.key});

  @override
  State<CompanySelectionScreen> createState() => _CompanySelectionScreenState();
}

class _CompanySelectionScreenState extends State<CompanySelectionScreen> {
  final companyController = TextEditingController();
  bool isLoading = false;

  Future<void> _searchCompany() async {
    final companyName = companyController.text.trim();
    if (companyName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a company name")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final domain = await CompanyApiService.getCompanyDomainByName(
        companyName,
      );

      if (domain == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Company not found or inactive")),
        );
      } else {
        // حفظ domain
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('company_domain', domain);

        // تعيين baseUrl
        Constants.baseUrl = "https://$domain/api/v1";

        // الانتقال لشاشة Login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      print('❌ Exception: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Constants.backgroundlightmode,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06,
              vertical: screenHeight * 0.06,
            ),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.22),
                Text(
                  "Please enter your company name to continue",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),

                // 🔹 Input Field
                TextField(
                  controller: companyController,
                  decoration: InputDecoration(
                    hintText: "Enter Company Name",
                    prefixIcon: const Icon(
                      Icons.business,
                      color: Constants.maincolor,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),

                // 🔹 Search Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.maincolor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    onPressed: isLoading ? null : _searchCompany,
                    child:
                        isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              "Continue",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
