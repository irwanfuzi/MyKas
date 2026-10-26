import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyKasApp());
}

class MyKasApp extends StatelessWidget {
  const MyKasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyKas - Personal Finance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: ThemeMode.system,
      home: const MyKasHomeScreen(),
    );
  }
}

class MyKasHomeScreen extends StatefulWidget {
  const MyKasHomeScreen({super.key});

  @override
  State<MyKasHomeScreen> createState() => _MyKasHomeScreenState();
}

class _MyKasHomeScreenState extends State<MyKasHomeScreen> {
  bool _isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFF0F172A),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 1. Background Canvas Layer (Royal Blue Gradient)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 260,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1E40AF),
                        Color(0xFF2563EB),
                        Color(0xFF3B82F6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              // 2. Top Navigation Bar (Fixed Header)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Avatar + Greeting
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.person_outline_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Halo,',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: const Color(0xFFDBEAFE).withOpacity(0.8),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  'Budi Santoso',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Right: Total Saldo Compact & Bell Notifikasi
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Total Saldo',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: const Color(0xFFDBEAFE).withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _isBalanceVisible ? 'Rp 24.850.000' : 'Rp ••••••••',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECA201),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF1D4ED8),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Hero Balance Card (Dibawah Top Bar)
              Positioned(
                top: 96,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Total Saldo Utama',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFFDBEAFE).withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isBalanceVisible = !_isBalanceVisible;
                            });
                          },
                          child: Icon(
                            _isBalanceVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 16,
                            color: const Color(0xFFBFDBFE),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isBalanceVisible ? 'Rp 24.850.000' : 'Rp ••••••••••',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Diperbarui 09:41 WIB',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFFDBEAFE).withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Main Curved Sheet Content
              Positioned.fill(
                top: 210,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 24,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Drag Handle Handle Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Scrollable Main Content Body
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                          physics: const BouncingScrollPhysics(),
                          children: [
                            // Section 1: Portofolio Kas
                            _buildSectionHeader(
                              context,
                              title: 'Portofolio Kas',
                              actionText: 'Kelola',
                              onActionTap: () {},
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 100,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                clipBehavior: Clip.none,
                                children: [
                                  _buildBankCard(
                                    context,
                                    badgeText: 'BCA',
                                    badgeBg: const Color(0xFF2563EB),
                                    badgeTextColor: Colors.white,
                                    title: 'Bank BCA',
                                    subtitle: '•• 8291',
                                    tag: 'UTAMA',
                                    tagBg: const Color(0xFFEFF6FF),
                                    tagText: const Color(0xFF2563EB),
                                    amount: '14.300.000',
                                  ),
                                  const SizedBox(width: 10),
                                  _buildBankCard(
                                    context,
                                    badgeText: 'MDR',
                                    badgeBg: const Color(0xFF0F172A),
                                    badgeTextColor: const Color(0xFFF59E0B),
                                    title: 'Bank Mandiri',
                                    subtitle: '•• 3409',
                                    tag: 'OPERASIONAL',
                                    tagBg: const Color(0xFFF1F5F9),
                                    tagText: const Color(0xFF475569),
                                    amount: '4.550.000',
                                  ),
                                  const SizedBox(width: 10),
                                  _buildBankCard(
                                    context,
                                    badgeText: 'GOPAY',
                                    badgeBg: const Color(0xFF00AED6),
                                    badgeTextColor: Colors.white,
                                    title: 'GoPay',
                                    subtitle: 'e-Wallet',
                                    tag: 'HARIAN',
                                    tagBg: const Color(0xFFF1F5F9),
                                    tagText: const Color(0xFF475569),
                                    amount: '2.800.000',
                                  ),
                                  const SizedBox(width: 10),
                                  _buildAddAccountButton(context),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Section 2: Aksi Cepat
                            _buildSectionHeader(
                              context,
                              title: 'Aksi Cepat',
                              actionText: 'Atur',
                              onActionTap: () {},
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white10
                                      : const Color(0xFFF1F5F9),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildQuickActionItem(
                                    context,
                                    title: 'Transfer',
                                    icon: Icons.swap_horiz_rounded,
                                    iconColor: const Color(0xFF2563EB),
                                    bgColor: const Color(0xFFEFF6FF),
                                  ),
                                  _buildQuickActionItem(
                                    context,
                                    title: 'Top Up',
                                    icon: Icons.account_balance_wallet_rounded,
                                    iconColor: const Color(0xFF10B981),
                                    bgColor: const Color(0xFFECFDF5),
                                  ),
                                  _buildQuickActionItem(
                                    context,
                                    title: 'Setor Target',
                                    icon: Icons.track_changes_rounded,
                                    iconColor: const Color(0xFFD97706),
                                    bgColor: const Color(0xFFFFFBEB),
                                  ),
                                  _buildQuickActionItem(
                                    context,
                                    title: 'Lainnya',
                                    icon: Icons.grid_view_rounded,
                                    iconColor: const Color(0xFF64748B),
                                    bgColor: const Color(0xFFF1F5F9),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Section 3: My Insight
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1E3A8A),
                                    Color(0xFF1D4ED8),
                                    Color(0xFF2563EB),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2563EB).withOpacity(0.25),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.15),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.auto_awesome,
                                              size: 14,
                                              color: Color(0xFFFCD34D),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'MY INSIGHT',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Pekan Ini',
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFFDBEAFE),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: const Color(0xFFDBEAFE),
                                        height: 1.4,
                                      ),
                                      children: const [
                                        TextSpan(text: 'Pengeluaran turun '),
                                        TextSpan(
                                          text: '18%',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFCD34D),
                                          ),
                                        ),
                                        TextSpan(
                                            text: ' minggu ini. Arus kas dalam kondisi '),
                                        TextSpan(
                                          text: 'sangat sehat.',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String actionText,
    required VoidCallback onActionTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        GestureDetector(
          onTap: onActionTap,
          child: Row(
            children: [
              Text(
                actionText,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2563EB),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: Color(0xFF2563EB),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBankCard(
    BuildContext context, {
    required String badgeText,
    required Color badgeBg,
    required Color badgeTextColor,
    required String title,
    required String subtitle,
    required String tag,
    required Color tagBg,
    required Color tagText,
    required String amount,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 215,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badgeText,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: badgeTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tagBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: tagText,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saldo Tersedia',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 1),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  children: [
                    const TextSpan(
                      text: 'Rp ',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    TextSpan(text: amount),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddAccountButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white20 : const Color(0xFFCBD5E1),
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Color(0xFF2563EB),
                size: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tambah Akun',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
          ),
        ),
      ],
    );
  }
}
