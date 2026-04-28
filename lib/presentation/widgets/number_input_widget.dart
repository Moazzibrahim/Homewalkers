// lib/presentation/widgets/number_input_field.dart

import 'package:flutter/material.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/core/utils/dialog_utils.dart';

class NumberInputField extends StatefulWidget {
  final int? initialValue;
  final int minValue;
  final int maxValue;
  final int step;
  final ValueChanged<int> onValueChanged;
  final String label;
  final String? hintText;
  final bool enabled;

  const NumberInputField({
    super.key,
    this.initialValue,
    this.minValue = 1,
    this.maxValue = 100,
    this.step = 1,
    required this.onValueChanged,
    required this.label,
    this.hintText,
    this.enabled = true,
  });

  @override
  State<NumberInputField> createState() => _NumberInputFieldState();
}

class _NumberInputFieldState extends State<NumberInputField> {
  late TextEditingController _controller;
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue ?? widget.minValue;
    _controller = TextEditingController(text: _currentValue.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateValue(int newValue) {
    setState(() {
      _currentValue = newValue.clamp(widget.minValue, widget.maxValue);
      _controller.text = _currentValue.toString();
    });
    widget.onValueChanged(_currentValue);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = ResponsiveHelper.isTablet(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xff1e1e1e) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              // Decrement button
              _buildIconButton(
                icon: Icons.remove,
                onPressed: widget.enabled && _currentValue > widget.minValue
                    ? () => _updateValue(_currentValue - widget.step)
                    : null,
                isDark: isDark,
              ),
              // Number input field
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: widget.enabled,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText ?? 'Enter number',
                    hintStyle: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null) {
                      _updateValue(parsed);
                    }
                  },
                ),
              ),
              // Increment button
              _buildIconButton(
                icon: Icons.add,
                onPressed:
                    widget.enabled && _currentValue < widget.maxValue
                        ? () => _updateValue(_currentValue + widget.step)
                        : null,
                isDark: isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Show remaining info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'You can request up to ${widget.maxValue} leads',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ),
            Text(
              'Min: ${widget.minValue}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: onPressed != null 
            ? (isDark ? Constants.mainDarkmodecolor : Constants.maincolor)
            : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        color: onPressed != null 
            ? Colors.white
            : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }
}