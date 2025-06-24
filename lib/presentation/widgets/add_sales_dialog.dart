import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/presentation/viewModels/cities/cubit/get_cities_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_state.dart';
// قم باستيراد نماذج البيانات الخاصة بك
import 'package:homewalkers_app/data/models/all_sales_model.dart'; // تأكد من صحة هذا المسار

class AddSalesDialog extends StatefulWidget {
  final void Function({
    required String name,
    required List<String> city, // ستستمر هذه القائمة في استقبال IDs كـ String
    required String teamleaderId,
    required String managerId,
    required bool isActive,
    required String notes,
  }) onAdd;

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
  // تم التغيير لتخزين IDs المدن بدلاً من الأسماء
  final List<String> _selectedCityIds = [];

  @override
  void initState() {
    super.initState();
    // جلب البيانات اللازمة للنموذج عند بدء التشغيل
    context.read<GetCitiesCubit>().fetchCities();
    context.read<SalesCubit>().fetchAllSales(); // جلب المستخدمين للقوائم المنسدلة
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add New Sales"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_nameController, 'Name'),
              const SizedBox(height: 16),

              // Dropdowns for Manager and Team Leader
              _buildUserDropdowns(),

              const SizedBox(height: 16),
              const Text("Select Cities:", style: TextStyle(fontWeight: FontWeight.bold)),
              // Cities Checkboxes
              _buildCityCheckboxes(),

              const SizedBox(height: 8),
              _buildTextField(_notesController, 'Notes'),
              Row(
                children: [
                  const Text("Active"),
                  const SizedBox(width: 10),
                  Switch(
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            // تحقق من أن النموذج صالح وأن المدن والمستخدمين قد تم اختيارهم
            if (_formKey.currentState!.validate() &&
                _selectedCityIds.isNotEmpty &&
                _selectedManagerId != null &&
                _selectedTeamLeaderId != null) {
              widget.onAdd(
                name: _nameController.text,
                // إرسال قائمة الـ IDs
                city: _selectedCityIds,
                teamleaderId: _selectedTeamLeaderId!,
                managerId: _selectedManagerId!,
                isActive: _isActive,
                notes: _notesController.text,
              );
              Navigator.of(context).pop();
            } else if (_selectedCityIds.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select at least one city.')));
            }
          },
          child: const Text("Add"),
        ),
      ],
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
          allUsers.forEach((user) => print('User Role: ${user.userlog?.role}'));
          // --------------------------------------------------------------------------

          final Map<String, SalesData> uniqueUsers = {
            for (var user in allUsers.where((u) => u.id != null)) user.id!: user
          };

          // فلترة المدراء من القائمة الفريدة، مع مقارنة الدور بدون حساسية لحالة الأحرف
          final managers = uniqueUsers.values
              .where((user) =>
                  user.userlog?.role?.toLowerCase() == 'manager' && user.name != null)
              .toList();

          // فلترة قادة الفرق
          final teamLeaders = uniqueUsers.values
              .where((user) =>
                  user.userlog?.role?.toLowerCase() == 'team leader' && user.name != null)
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
              const SizedBox(height: 8),
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
          return Text("Failed to load users: ${state.message}");
        }
        return const Text("Loading users...");
      },
    );
  }
  
  Widget _buildCityCheckboxes() {
    return BlocBuilder<GetCitiesCubit, GetCitiesState>(
      builder: (context, state) {
        if (state is GetCitiesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is GetCitiesSuccess && state.cities != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: state.cities!.map((city) {
              // التحقق من أن للمدينة اسم و ID
              if (city.id == null || city.name == null) {
                return const SizedBox.shrink(); // تجاهل المدينة إذا كانت بياناتها غير مكتملة
              }
              return CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                // التحقق من وجود ID المدينة في القائمة المحددة
                value: _selectedCityIds.contains(city.id),
                title: Text(city.name!),
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
          return const Text("Failed to load cities.");
        }
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'This field is required' : null,
      ),
    );
  }

  // ويدجت مساعد لإنشاء القوائم المنسدلة
  Widget _buildDropdown({
    required String label,
    required String? selectedValue,
    required List<SalesData> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        hint: Text(' ${label.toLowerCase()}s '),
        value: selectedValue,
        validator: (value) => value == null || value.isEmpty ? 'Please select a $label' : null,
        onChanged: onChanged,
        items: items.map((user) {
          return DropdownMenuItem<String>(
            value: user.id,
            child: Text(user.name ?? 'Unnamed User'),
          );
        }).toList(),
      ),
    );
  }
}
