import 'package:flutter/material.dart';
import 'package:homewalkers_app/core/constants/constants.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Constants.maincolor),
          const SizedBox(width: 8),
          Text(
            '$label : ',
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xff6A6A75),
            ),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xff6A6A75),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
