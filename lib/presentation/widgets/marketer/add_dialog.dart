import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';

class AddDialog extends StatefulWidget {
  final void Function(String)? onAdd;
  final String? title;

  const AddDialog({super.key, this.onAdd, this.title});

  @override
  State<AddDialog> createState() => _NewCommunicationDialogState();
}

class _NewCommunicationDialogState extends State<AddDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    widget.onAdd?.call(value);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final mainColor =
        isLight ? Constants.maincolor : Constants.mainDarkmodecolor;
    final textColor = isLight ? const Color(0xff111827) : Colors.white;
    final backgroundColor = isLight ? Colors.white : const Color(0xff1E1E1E);
    final subTextColor = isLight ? Colors.grey.shade500 : Colors.grey[400];
    final fieldFillColor =
        isLight ? const Color(0xffF7F8FA) : const Color(0xff2A2A2A);
    final fieldBorderColor =
        isLight ? const Color(0xffE5E7EB) : Colors.grey.shade800;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: mainColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/images/add.svg",
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(mainColor, BlendMode.srcIn),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "New ${widget.title}",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Enter the details below",
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: subTextColor,
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
                          isLight
                              ? Colors.grey.shade100
                              : Colors.white.withOpacity(0.06),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 18, color: subTextColor),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // ── Input Field ─────────────────────
            TextField(
              controller: _controller,
              autofocus: true,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: "${widget.title} name",
                hintStyle: TextStyle(
                  color: subTextColor,
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor: fieldFillColor,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: fieldBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: fieldBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: mainColor, width: 1.6),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ── Action Buttons ──────────────────
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: fieldBorderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: textColor,
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
                      onPressed: _hasText ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        disabledBackgroundColor: mainColor.withOpacity(0.35),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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
          ],
        ),
      ),
    );
  }
}
