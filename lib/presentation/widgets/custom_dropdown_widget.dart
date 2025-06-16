import 'package:flutter/material.dart';

class CustomDropdownField extends StatelessWidget {
  final String hint;
  final List<String?> items;
  final String? value; // ✅ Add this line
  final Function(String?)? onChanged;

  const CustomDropdownField({
    super.key,
    required this.hint,
    required this.items,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.black,
          fontFamily: 'Montserrat',
        ),
        value: value, // ✅ Use the external value instead of internal state
        items:
            items
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item!,
                      style: TextStyle(
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Color(0xff080719)
                                : Color(0xffFFFFFF),
                      ),
                    ),
                  ),
                )
                .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Color.fromRGBO(143, 146, 146, 1),
            fontWeight: FontWeight.w400,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xffE1E1E1)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
