// ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use, use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/screens/marketier/marketier_tabs_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/auth/auth_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/theme/theme_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class MarketerProfileScreen extends StatelessWidget {
  const MarketerProfileScreen({super.key});

  // ── original logic (unchanged) ──────────────────────────────
  Future<String> checkAuthName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    return name ?? 'User';
  }

  Future<String> checkAuthphone() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('phone');
    return phone ?? '';
  }

  Future<String> checkAuthEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    return email ?? 'sales@gmail.com';
  }

  Future<String> getCreatedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('createdAt');
    print("CreatedAt: $value");
    return value!;
  }

  Future<String> getUpdatedAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('updatedAt') ?? '';
  }

  Future<bool> isUserActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('active') ?? false;
  }

  // ── helpers ─────────────────────────────────────────────────
  String _formatDate(String raw) {
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  Color _mainColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? Constants.maincolor
          : Constants.mainDarkmodecolor;

  // ── build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    print("Current ThemeMode: ${context.watch<ThemeCubit>().state}");
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color main = _mainColor(context);
    final Color bg =
        isDark ? Constants.backgroundDarkmode : Constants.backgroundlightmode;
    final Color cardBg = isDark ? const Color(0xFF252535) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: CustomAppBar(
        title: "Profile",
        onBack: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MarketierTabsScreen()),
          );
        },
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          // ── Avatar + name ──────────────────────────────────
          _buildHeader(context, main, cardBg),
          const SizedBox(height: 10),

          // ── Security & Status ──────────────────────────────
          _sectionLabel("SECURITY & STATUS", context),
          const SizedBox(height: 10),
          _buildStatusCard(context, main),
          const SizedBox(height: 12),
          _buildDatesCard(context, main),
          const SizedBox(height: 14),

          // ── Connectivity ───────────────────────────────────
          _sectionLabel("CONNECTIVITY", context),
          const SizedBox(height: 10),
          _buildConnectivityCard(context, main, cardBg),
          const SizedBox(height: 14),

          // ── Interface ──────────────────────────────────────
          _sectionLabel("INTERFACE", context),
          const SizedBox(height: 10),
          _buildDarkModeCard(context, main),
          const SizedBox(height: 14),

          // ── Sign Out ───────────────────────────────────────
          _buildSignOutButton(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── HEADER ───────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, Color main, Color cardBg) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: cardBg,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: Icon(
                  Icons.person,
                  size: 48,
                  color: main.withOpacity(0.5),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5A623),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.verified, size: 13, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<String>(
          future: checkAuthName(),
          builder: (context, snap) => Text(
            snap.data ?? '...',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.light
                  ? const Color(0xFF0D0D1A)
                  : Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              "MARKETER",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── STATUS CARD ──────────────────────────────────────────────
  Widget _buildStatusCard(BuildContext context, Color main) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC3C6D4).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F7).withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFC3C6D4).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Icon(Icons.shield_outlined, color: main, size: 20),
        ),
        title: Text(
          "ACCOUNT STATUS",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade400,
            letterSpacing: 0.8,
          ),
        ),
        subtitle: const Text(
          "Verified Identity",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        trailing: FutureBuilder<bool>(
          future: isUserActive(),
          builder: (context, snap) {
            final isActive = snap.data ?? false;
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFEF5350),
                  width: 0.5,
                ),
              ),
              child: Text(
                isActive ? "ACTIVE" : "INACTIVE",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isActive
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828),
                  letterSpacing: 0.5,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── DATES CARD ───────────────────────────────────────────────
  Widget _buildDatesCard(BuildContext context, Color main) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC3C6D4).withOpacity(0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: FutureBuilder<String>(
              future: getCreatedAt(),
              builder: (context, snap) {
                String formatted = '...';
                if (snap.connectionState == ConnectionState.done &&
                    snap.hasData) {
                  formatted = _formatDate(snap.data!);
                }
                return _dateCell(
                  context,
                  icon: Icons.calendar_today_outlined,
                  label: "ENROLLED",
                  value: formatted,
                  main: main,
                );
              },
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          Expanded(
            child: FutureBuilder<String>(
              future: getUpdatedAt(),
              builder: (context, snap) {
                String formatted = '...';
                if (snap.connectionState == ConnectionState.done &&
                    snap.hasData &&
                    snap.data!.isNotEmpty) {
                  formatted = _formatDate(snap.data!);
                }
                return _dateCell(
                  context,
                  icon: Icons.history_outlined,
                  label: "MODIFIED",
                  value: formatted,
                  main: main,
                  alignRight: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateCell(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color main,
    bool alignRight = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: alignRight ? 16 : 0,
        right: alignRight ? 0 : 16,
      ),
      child: Column(
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade400),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ── CONNECTIVITY CARD ────────────────────────────────────────
  Widget _buildConnectivityCard(
      BuildContext context, Color main, Color cardBg) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC3C6D4).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          FutureBuilder<String>(
            future: checkAuthEmail(),
            builder: (context, snap) => _connectivityRow(
              context: context,
              icon: Icons.alternate_email,
              label: "PRIMARY EMAIL",
              value: snap.data ?? '...',
              main: main,
              cardBg: cardBg,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<String>(
            future: checkAuthphone(),
            builder: (context, snap) => _connectivityRow(
              context: context,
              icon: Icons.phone_android_outlined,
              label: "PRIVATE LINE",
              value: snap.data ?? '...',
              main: main,
              cardBg: cardBg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _connectivityRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color main,
    required Color cardBg,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: main, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.copy_outlined,
            size: 18,
            color: Colors.grey.shade400,
          ),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("$label copied"),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── DARK MODE CARD ───────────────────────────────────────────
  Widget _buildDarkModeCard(BuildContext context, Color main) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC3C6D4).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          final isDark = themeMode == ThemeMode.dark;
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: main.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDark
                    ? Icons.nights_stay_outlined
                    : Icons.wb_sunny_outlined,
                color: main,
                size: 20,
              ),
            ),
            title: const Text(
              "Dark Mode",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            trailing: Switch(
              value: isDark,
              onChanged: (_) async {
                print("Toggling theme");
                context.read<ThemeCubit>().toggleTheme();
              },
              activeColor: main,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              thumbColor: WidgetStateProperty.resolveWith<Color?>(
                  (states) => Colors.white),
              thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Icon(Icons.nights_stay_outlined,
                      size: 14, color: Color(0xff434652));
                }
                return const Icon(Icons.wb_sunny_outlined,
                    size: 14, color: Color(0xff434652));
              }),
            ),
          );
        },
      ),
    );
  }

  // ── SIGN OUT BUTTON ──────────────────────────────────────────
  Widget _buildSignOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => context.read<AuthCubit>().logout(context),
        icon: const Icon(Icons.logout_outlined,
            color: Color(0xffBA1A1A), size: 18),
        label: const Text(
          "SIGN OUT",
          style: TextStyle(
            color: Color(0xffBA1A1A),
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 1.2,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color(0xffBA1A1A).withOpacity(0.05),
          side: const BorderSide(color: Color(0xffBA1A1A), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ── SECTION LABEL ────────────────────────────────────────────
  Widget _sectionLabel(String text, BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade400,
          letterSpacing: 1.0,
        ),
      );
}