import 'package:flutter/material.dart';
import 'package:homewalkers_app/core/constants/constants.dart';

class DeleteDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String? title;

  const DeleteDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trash Icon Section
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: Color.fromRGBO(15, 118, 135, 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Image.asset("assets/images/trash.png")),
            ),
            const SizedBox(height: 24),
            // Text Section
            Text(
              "Are you sure to delete $title ...?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              "This item will be deleted from $title",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Constants.maincolor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'No',
                      style: TextStyle(
                        color: Constants.maincolor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Constants.maincolor
                              : Constants.mainDarkmodecolor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Yes , Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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
