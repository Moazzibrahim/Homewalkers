import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/viewModels/cities/cubit/get_cities_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/get_all_users_signup/cubit/getalluserssignup_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_state.dart';
// قم باستيراد نماذج البيانات الخاصة بك
import 'package:homewalkers_app/data/models/all_sales_model.dart'; // تأكد من صحة هذا المسار

class AddSalesDialog extends StatefulWidget {
  final void Function({
    required String name,
    required String userId,
    required List<String> city, // ستستمر هذه القائمة في استقبال IDs كـ String
    required String teamleaderId,
    required String managerId,
    required bool isActive,
    required String notes,
  })
  onAdd;

  const AddSalesDialog({super.key, required this.onAdd});

  @override
  State<AddSalesDialog> createState() => _AddSalesDialogState();
}

class _AddSalesDialogState extends State<AddSalesDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isActive = true;
  String? _selectedManagerId;
  String? _selectedTeamLeaderId;
  String? _selectedUserId;
  // تم التغيير لتخزين IDs المدن بدلاً من الأسماء
  final List<String> _selectedCityIds = [];

  @override
  void initState() {
    super.initState();
    // جلب البيانات اللازمة للنموذج عند بدء التشغيل
    context.read<GetCitiesCubit>().fetchCities();
    context.read<SalesCubit>().fetchAllSales();
    context.read<GetalluserssignupCubit>().fetchUsers();
  }

  // ── Design tokens محسوبة مرة واحدة ──
  bool get _isLight => Theme.of(context).brightness == Brightness.light;
  Color get _mainColor =>
      _isLight ? Constants.maincolor : Constants.mainDarkmodecolor;
  Color get _textColor => _isLight ? const Color(0xff111827) : Colors.white;
  Color get _subTextColor =>
      _isLight ? Colors.grey.shade500 : Colors.grey[400]!;
  Color get _backgroundColor =>
      _isLight ? Colors.white : const Color(0xff1E1E1E);
  Color get _fieldFillColor =>
      _isLight ? const Color(0xffF7F8FA) : const Color(0xff2A2A2A);
  Color get _fieldBorderColor =>
      _isLight ? const Color(0xffE5E7EB) : Colors.grey.shade800;

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: _subTextColor, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: _fieldFillColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _fieldBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _fieldBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _mainColor, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: _subTextColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _mainColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.person_add_alt_1_rounded,
                      color: _mainColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Add New Sales",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: _textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Fill in the details to create a sales member",
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: _subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color:
                            _isLight
                                ? Colors.grey.shade100
                                : Colors.white.withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 18, color: _subTextColor),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ── Body (scrollable) ───────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel("Basic info"),
                      _buildTextField(_nameController, 'Name'),
                      const SizedBox(height: 14),
                      _buildUser(),

                      const SizedBox(height: 20),
                      _sectionLabel("Reporting"),
                      _buildUserDropdowns(),

                      const SizedBox(height: 20),
                      _sectionLabel("Cities"),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: _fieldFillColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _fieldBorderColor),
                        ),
                        child: _buildCityCheckboxes(),
                      ),

                      const SizedBox(height: 20),
                      _sectionLabel("Notes"),
                      _buildTextField(
                        _notesController,
                        'Notes',
                        isRequired: false,
                      ),

                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _fieldFillColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _fieldBorderColor),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Active",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: _textColor,
                                ),
                              ),
                            ),
                            Switch(
                              activeColor: _mainColor,
                              value: _isActive,
                              onChanged: (value) {
                                setState(() {
                                  _isActive = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ),

            // ── Action Buttons ──────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _fieldBorderColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: _textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _mainColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // تحقق من أن النموذج صالح وأن المدن والمستخدمين قد تم اختيارهم
                          if (_formKey.currentState!.validate() &&
                              _selectedCityIds.isNotEmpty &&
                              _selectedManagerId != null &&
                              _selectedTeamLeaderId != null) {
                            widget.onAdd(
                              name: _nameController.text,
                              userId: _selectedUserId!,
                              city: _selectedCityIds,
                              teamleaderId: _selectedTeamLeaderId!,
                              managerId: _selectedManagerId!,
                              isActive: _isActive,
                              notes: _notesController.text,
                            );
                            Navigator.of(context).pop();
                          } else if (_selectedCityIds.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select at least one city.',
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          "Add",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDropdowns() {
    return BlocBuilder<SalesCubit, SalesState>(
      builder: (context, state) {
        if (state is SalesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SalesLoaded) {
          final allUsers = state.salesData.data ?? [];
          // --- للمساعدة في اكتشاف الأخطاء: هذا السطر سيطبع كل الأدوار في الـ console ---
          for (var user in allUsers) {
            print('User Role: ${user.userlog?.role}');
          }
          // --------------------------------------------------------------------------
          final Map<String, SalesData> uniqueUsers = {
            for (var user in allUsers.where((u) => u.id != null))
              user.id!: user,
          };
          // فلترة المدراء من القائمة الفريدة، مع مقارنة الدور بدون حساسية لحالة الأحرف
          final managers =
              uniqueUsers.values
                  .where(
                    (user) =>
                        user.userlog?.role?.toLowerCase() == 'manager' &&
                        user.name != null,
                  )
                  .toList();
          // فلترة قادة الفرق
          final teamLeaders =
              uniqueUsers.values
                  .where(
                    (user) =>
                        user.userlog?.role?.toLowerCase() == 'team leader' &&
                        user.name != null,
                  )
                  .toList();
          return Column(
            children: [
              _buildDropdown(
                label: 'Manager',
                selectedValue: _selectedManagerId,
                items: managers,
                onChanged: (value) {
                  setState(() {
                    _selectedManagerId = value;
                  });
                },
              ),
              const SizedBox(height: 14),
              _buildDropdown(
                label: 'Team Leader',
                selectedValue: _selectedTeamLeaderId,
                items: teamLeaders,
                onChanged: (value) {
                  setState(() {
                    _selectedTeamLeaderId = value;
                  });
                },
              ),
            ],
          );
        }
        if (state is SalesError) {
          return Text(
            "Failed to load users: ${state.message}",
            style: const TextStyle(color: Colors.redAccent),
          );
        }
        return Text("Loading users...", style: TextStyle(color: _subTextColor));
      },
    );
  }

  Widget _buildUser() {
    return BlocBuilder<GetalluserssignupCubit, GetalluserssignupState>(
      builder: (context, state) {
        if (state is GetalluserssignupLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is GetalluserssignupSuccess) {
          final users = state.users.data ?? [];

          return DropdownButtonFormField<String>(
            decoration: _inputDecoration('User'),
            hint: Text('Select user', style: TextStyle(color: _subTextColor)),
            value: _selectedUserId, // أو استخدم متغير آخر حسب الدور
            validator:
                (value) =>
                    value == null || value.isEmpty
                        ? 'Please select a user'
                        : null,
            onChanged: (value) {
              setState(() {
                _selectedUserId = value; // يمكنك تغييرها حسب الاستخدام
              });
            },
            items:
                users.where((user) => user.id != null && user.name != null).map(
                  (user) {
                    return DropdownMenuItem<String>(
                      value: user.id!,
                      child: Text(user.name!),
                    );
                  },
                ).toList(),
          );
        }
        if (state is GetalluserssignupFailure) {
          return Text(
            "Failed to load users: ${state.message}",
            style: const TextStyle(color: Colors.redAccent),
          );
        }
        return Text("Loading users...", style: TextStyle(color: _subTextColor));
      },
    );
  }

  Widget _buildCityCheckboxes() {
    return BlocBuilder<GetCitiesCubit, GetCitiesState>(
      builder: (context, state) {
        if (state is GetCitiesLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is GetCitiesSuccess && state.cities != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                state.cities!.map((city) {
                  // التحقق من أن للمدينة اسم و ID
                  if (city.id == null || city.name == null) {
                    return const SizedBox.shrink(); // تجاهل المدينة إذا كانت بياناتها غير مكتملة
                  }
                  return CheckboxListTile(
                    activeColor: _mainColor,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    // التحقق من وجود ID المدينة في القائمة المحددة
                    value: _selectedCityIds.contains(city.id),
                    title: Text(
                      city.name!,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _textColor,
                      ),
                    ),
                    onChanged: (selected) {
                      setState(() {
                        final cityId = city.id!;
                        if (selected == true) {
                          _selectedCityIds.add(cityId);
                        } else {
                          _selectedCityIds.remove(cityId);
                        }
                      });
                    },
                  );
                }).toList(),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              "Failed to load cities.",
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: _textColor, fontWeight: FontWeight.w600),
      decoration: _inputDecoration(label),
      validator:
          isRequired
              ? (value) =>
                  value == null || value.isEmpty
                      ? 'This field is required'
                      : null
              : null,
    );
  }

  // ويدجت مساعد لإنشاء القوائم المنسدلة
  Widget _buildDropdown({
    required String label,
    required String? selectedValue,
    required List<SalesData> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: _inputDecoration(label),
      hint: Text(
        'Select $label'.toLowerCase(),
        style: TextStyle(color: _subTextColor),
      ),
      value: selectedValue,
      validator:
          (value) =>
              value == null || value.isEmpty ? 'Please select a $label' : null,
      onChanged: onChanged,
      items:
          items.map((user) {
            return DropdownMenuItem<String>(
              value: user.id,
              child: Text(user.name ?? 'Unnamed User'),
            );
          }).toList(),
    );
  }
}
