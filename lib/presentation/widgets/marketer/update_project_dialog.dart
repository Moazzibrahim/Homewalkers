import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';

class UpdateProjectDialog extends StatefulWidget {
  final void Function(String, num)? onAdd;
  final String? title;
  final String? initialValue;
  final num? initialStartPrice;

  const UpdateProjectDialog({
    super.key,
    this.onAdd,
    this.title,
    this.initialValue,
    this.initialStartPrice,
  });

  @override
  State<UpdateProjectDialog> createState() => _NewCommunicationDialogState();
}

class _NewCommunicationDialogState extends State<UpdateProjectDialog> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _startPriceController = TextEditingController();

  bool _hasChanges = false;

  void _checkChanges() {
    final nameChanged = _controller.text.trim() != (widget.initialValue ?? '');
    final priceChanged =
        _startPriceController.text.trim() !=
        (widget.initialStartPrice?.toString() ?? '');
    setState(() {
      _hasChanges = nameChanged || priceChanged;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue ?? '';
    _startPriceController.text = widget.initialStartPrice?.toString() ?? '';

    _controller.addListener(_checkChanges);
    _startPriceController.addListener(_checkChanges);
  }

  @override
  void dispose() {
    _controller.removeListener(_checkChanges);
    _startPriceController.removeListener(_checkChanges);
    _controller.dispose();
    _startPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final mainColor =
        isLight ? Constants.maincolor : Constants.mainDarkmodecolor;
    final textColor = isLight ? Colors.black : Colors.white;
    final backgroundColor = isLight ? Colors.white : const Color(0xFF1E1E1E);
    final hintTextColor = isLight ? Colors.grey : Colors.grey[400];
    final borderColor =
        isLight ? Constants.maincolor : Constants.mainDarkmodecolor;
    final cancelTextColor = isLight ? Constants.maincolor : Colors.grey[300];

    return Dialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Row
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: mainColor,
                  child: Image.asset("assets/images/Vector.png"),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Update ${widget.title}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close, color: textColor),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Input Field - Name
            TextField(
              controller: _controller,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "${widget.title} Name",
                hintStyle: TextStyle(color: hintTextColor),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: mainColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Input Field - Start Price
            TextField(
              controller: _startPriceController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Start Price",
                hintStyle: TextStyle(color: hintTextColor),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: mainColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: mainColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: cancelTextColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _hasChanges
                            ? () {
                              if (widget.onAdd != null) {
                                final name = _controller.text.trim();
                                final priceText =
                                    _startPriceController.text.trim();

                                // استخدم القيمة القديمة إذا لم تتغير
                                final updatedName =
                                    name.isNotEmpty
                                        ? name
                                        : (widget.initialValue ?? '');
                                final updatedPrice =
                                    priceText.isNotEmpty
                                        ? num.tryParse(priceText) ??
                                            widget.initialStartPrice ??
                                            0
                                        : widget.initialStartPrice ?? 0;

                                widget.onAdd!(updatedName, updatedPrice);
                              }
                              Navigator.of(context).pop();
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      "Update",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
