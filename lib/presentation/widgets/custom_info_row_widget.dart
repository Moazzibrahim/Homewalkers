import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:url_launcher/url_launcher.dart';

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

  bool get isLink =>
      value.startsWith('http://') || value.startsWith('https://');

  Future<void> _launchLink() async {
    final uri = Uri.parse(value);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 8 : 4,
        horizontal: isTablet ? 8 : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: isTablet ? 24 : 18, color: Constants.maincolor),
          SizedBox(width: isTablet ? 12 : 8),

          /// Content
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: isTablet ? 18 : 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff6A6A75),
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: '$label : ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: isTablet ? 18 : 14,
                    ),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child:
                        isLink
                            ? GestureDetector(
                              onTap: _launchLink,
                              onLongPress: () {
                                Clipboard.setData(ClipboardData(text: value));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Copied to clipboard'),
                                  ),
                                );
                              },
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 14,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            )
                            : SelectableText(
                              value,
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 14,
                                color: const Color(0xff6A6A75),
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
