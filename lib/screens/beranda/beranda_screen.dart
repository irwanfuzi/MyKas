
import 'package:flutter/material.dart';

import '../../models/quick_action_item.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_icons.dart';
import '../../widgets/customize_quick_actions_sheet.dart';

class BerandaScreen extends StatefulWidget {
  final Map<String, dynamic>? summaryData;
  final VoidCallback? onNavigateToAnalisis;

  const BerandaScreen({
    super.key,
    this.summaryData,
    this.onNavigateToAnalisis,
  });

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  bool _showAllKantongSubPage = false;
  bool _isSaldoVisible = true;

  List<QuickActionItem> _userQuickActions = QuickActionItem.defaultList;

  String _formatCurrency(dynamic rawNominal) {
    if (rawNominal == null) return 'Rp0';
    String strVal = rawNominal.toString().replaceAll(RegExp(r'[^0-9]'), '');
    if (strVal.isEmpty) return 'Rp0';

    final intValue = int.tryParse(strVal) ?? 0;
    final buffer = StringBuffer();
    final numStr = intValue.toString();

    for (int i = 0; i < numStr.length; i++) {
      if (i > 0 && (numStr.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(numStr[i]);
    }
    return 'Rp$buffer';
  }

  void _openTambahAkunModal(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    if (isDesktop) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: const TambahAkunFormContent(),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const TambahAkunFormContent(),
        ),
      );
    }
  }

  void _openPengaturanKantongBottomSheet(BuildContext context, String namaKantong) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.colorScheme.surface;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = theme.colorScheme.onSurfaceVariant;
    final tileBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final borderColor = theme.colorScheme.outline.withOpacity(0.3);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: subtitleColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengaturan Kantong',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      Text(
                        namaKantong,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: subtitleColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(AppIcons.x, size: 18, color: textColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSettingTileItem(
                context: context,
                icon: AppIcons.pencil,
                title: 'Ubah Nama & Kategori',
                subtitle: 'Ganti nama, jenis, atau ikon kantong',
                tileBg: tileBg,
                borderColor: borderColor,
                textColor: textColor,
                subtitleColor: subtitleColor,
                onTap: () => Navigator.pop(context),
              ),
              _buildSettingTileItem(
                context: context,
                icon: AppIcons.sliders,
                title: 'Atur Limit Pengeluaran',
                subtitle: 'Pasang batas budget bulanan kantong ini',
                tileBg: tileBg,
                borderColor: borderColor,
                textColor: textColor,
                subtitleColor: subtitleColor,
                onTap: () => Navigator.pop(context),
              ),
              _buildSettingTileItem(
                context: context,
                icon: AppIcons.checkCircle2,
                title: 'Jadikan Kantong Utama',
                subtitle: 'Gunakan sebagai sumber dana default',
                tileBg: tileBg,
                borderColor: borderColor,
                textColor: textColor,
                subtitleColor: subtitleColor,
                onTap: () => Navigator.pop(context),
              ),
              _buildSettingTileItem(
                context: context,
                icon: AppIcons.trash2,
                title: 'Hapus Kantong',
                subtitle: 'Keluarkan kantong ini dari daftar MyKas',
                tileBg: tileBg,
                borderColor: borderColor,
                textColor: const Color(0xFFEF4444),
                subtitleColor: subtitleColor,
                iconColor: const Color(0xFFEF4444),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingTileItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color tileBg,
    required Color borderColor,
    required Color textColor,
    required Color subtitleColor,
    Color iconColor = const Color(0xFF2563EB),
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: subtitleColor,
          ),
        ),
        trailing: Icon(AppIcons.chevronRight, size: 16, color: subtitleColor),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleBackPress() {
    if (_showAllKantongSubPage) {
      setState(() {
        _showAllKantongSubPage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final rawSaldo = widget.summaryData?['saldo'] ?? 'Rp 11.250.000';

    final List riwayat = widget.summaryData?['riwayat'] as List? ?? [
      {
        'judul': 'Gudeg Bu Dani Solo',
        'kategori': 'Kuliner & Makanan',
        'tanggal': 'Hari Ini, 12:45',
        'nominal': '45000',
        'jenis': 'pengeluaran',
        'icon': AppIcons.utensils,
      },
      {
        'judul': 'Gaji Bulanan Utama',
        'kategori': 'Payroll Inflow',
        'tanggal': '25 Agu 2026',
        'nominal': '8500000',
        'jenis': 'pemasukan',
        'icon': AppIcons.wallet,
      },
      {
        'judul': 'GoFood Indonesia',
        'kategori': 'Layanan Antar',
        'tanggal': '24 Agu 2026',
        'nominal': '68000',
        'jenis': 'pengeluaran',
        'icon': AppIcons.shoppingBag,
      },
      {
        'judul': 'Supermarket Transmart',
        'kategori': 'Kebutuhan Harian',
        'tanggal': '22 Agu 2026',
        'nominal': '235000',
        'jenis': 'pengeluaran',
        'icon': AppIcons.shoppingCart,
      },
      {
        'judul': 'Token Listrik PLN',
        'kategori': 'Tagihan Harian',
        'tanggal': '20 Agu 2026',
        'nominal': '100000',
        'jenis': 'pengeluaran',
        'icon': AppIcons.sliders,
      },
    ];

    final recentTransactions = riwayat.take(5).toList();

    // Dinamis membaca theme mode aplikasi
    final surfaceColor = theme.scaffoldBackgroundColor;
    final cardBg = theme.colorScheme.surface;
    final borderColor = theme.colorScheme.outline.withOpacity(isDark ? 0.35 : 0.2);
    final textColor = theme.colorScheme.onSurface;
    final textMuted = theme.colorScheme.onSurfaceVariant;
    const brandBlue = Color(0xFF2563EB); // Soft Royal Blue

    return PopScope(
      canPop: !_showAllKantongSubPage,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _showAllKantongSubPage) {
          _handleBackPress();
        }
      },
      child: Container(
        color: brandBlue,
        child: SafeArea(
          bottom: false,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              reverseDuration: const Duration(milliseconds: 250),
              switchInCurve: Curves.fastOutSlowIn,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                final isSubPage = child.key == const ValueKey('SemuaKantongSubPage');

                final Tween<Offset> slideTween = isSubPage
                    ? Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
                    : Tween<Offset>(begin: const Offset(-0.2, 0.0), end: Offset.zero);

                return SlideTransition(
                  position: slideTween.animate(animation),
                  child: child,
                );
              },
              child: _showAllKantongSubPage
                  ? _buildSemuaKantongSubPage(textColor, textMuted, cardBg, borderColor, surfaceColor, isDark)
                  : _buildMainBerandaView(
                      rawSaldo,
                      recentTransactions,
                      textColor,
                      textMuted,
                      cardBg,
                      borderColor,
                      surfaceColor,
                      isDark,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainBerandaView(
    String rawSaldo,
    List recentTransactions,
    Color textColor,
    Color textMuted,
    Color cardBg,
    Color borderColor,
    Color surfaceColor,
    bool isDark,
  ) {
    return LayoutBuilder(
      key: const ValueKey('MainBerandaView'),
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;
        const brandBlue = Color(0xFF2563EB);

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isDesktop ? 1100 : 540),
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                // TopBar Pinned
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _OvoStyleTopBarDelegate(),
                ),

                // Card Saldo
                SliverToBoxAdapter(
                  child: Container(
                    color: brandBlue,
                    child: Stack(
                      children: [
                        Positioned(
                          right: -25,
                          top: -15,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 4, 18, 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Total Saldo',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.85),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isSaldoVisible = !_isSaldoVisible;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Icon(
                                        _isSaldoVisible ? AppIcons.eye : AppIcons.eyeOff,
                                        color: Colors.white.withOpacity(0.85),
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                                child: Text(
                                  _isSaldoVisible ? rawSaldo : '••••••••••••',
                                  key: ValueKey<bool>(_isSaldoVisible),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(AppIcons.clock, color: Colors.white.withOpacity(0.7), size: 11),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Updated 2m ago',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Content Body (Dinamis Sesuai Mode Light/Dark)
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? 28.0 : 18.0,
                      14.0,
                      isDesktop ? 28.0 : 18.0,
                      40.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: borderColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (isDesktop) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 6,
                                child: Column(
                                  children: [
                                    _buildKantongKeuanganSection(textColor, textMuted, cardBg, borderColor, isDark, true),
                                    const SizedBox(height: 22),
                                    _buildQuickActionsSection(textColor, isDark, true),
                                    const SizedBox(height: 22),
                                    _buildMyInsightCard(textColor, textMuted, isDark),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 6,
                                child: Column(
                                  children: [
                                    _buildRencanaKeuanganSection(textColor, textMuted, cardBg, borderColor, isDark, true),
                                    const SizedBox(height: 22),
                                    _buildRecentTransactionsSection(recentTransactions, textColor, textMuted, cardBg, borderColor, isDark),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          _buildKantongKeuanganSection(textColor, textMuted, cardBg, borderColor, isDark, false),
                          const SizedBox(height: 22),
                          _buildQuickActionsSection(textColor, isDark, false),
                          const SizedBox(height: 22),
                          _buildMyInsightCard(textColor, textMuted, isDark),
                          const SizedBox(height: 22),
                          _buildRencanaKeuanganSection(textColor, textMuted, cardBg, borderColor, isDark, false),
                          const SizedBox(height: 22),
                          _buildRecentTransactionsSection(recentTransactions, textColor, textMuted, cardBg, borderColor, isDark),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // KANTONG KEUANGAN
  // ==========================================
  Widget _buildKantongKeuanganSection(
    Color textColor,
    Color textMuted,
    Color cardBg,
    Color borderColor,
    bool isDark,
    bool isDesktop,
  ) {
    const brandBlue = Color(0xFF2563EB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Kantong Keuangan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: brandBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '3 Terhubung',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: brandBlue,
                    ),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _showAllKantongSubPage = true;
                });
              },
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'Lihat Semua >',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: brandBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: isDesktop ? 2.0 : 1.65,
          children: [
            _buildWalletCard('BSI', const Color(0xFF00A39D), 'BSI Hasanah', 'Rp 4.250.000', cardBg, borderColor, textColor, textMuted),
            _buildWalletCard('MANDIRI', const Color(0xFFD97706), 'Mandiri Utama', 'Rp 6.000.000', cardBg, borderColor, textColor, textMuted),
            _buildWalletCard('GOPAY', const Color(0xFF00AED6), 'GoPay Wallet', 'Rp 1.000.000', cardBg, borderColor, textColor, textMuted),
            _buildAddAccountCard(isDark, textMuted),
          ],
        ),
      ],
    );
  }

  Widget _buildWalletCard(
    String badge,
    Color badgeBg,
    String title,
    String amount,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color textMuted,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(4)),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _openPengaturanKantongBottomSheet(context, title),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Icon(AppIcons.chevronRight, size: 14, color: textMuted),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: textMuted,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                _isSaldoVisible ? amount : '••••••••',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddAccountCard(bool isDark, Color textMuted) {
    const brandBlue = Color(0xFF2563EB);

    return InkWell(
      onTap: () => _openTambahAkunModal(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: brandBlue.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(AppIcons.plus, color: brandBlue, size: 14),
              ),
              const SizedBox(height: 6),
              Text(
                '+ Tambah Akun',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // QUICK ACTIONS
  // ==========================================
  Widget _buildQuickActionsSection(Color textColor, bool isDark, bool isDesktop) {
    final activeActions = _userQuickActions.where((item) => item.isEnabled).take(4).toList();
    const brandBlue = Color(0xFF2563EB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aksi Cepat',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.2,
              ),
            ),
            InkWell(
              onTap: () {
                CustomizeQuickActionsSheet.show(
                  context,
                  currentItems: _userQuickActions,
                  onSave: (updatedList) {
                    setState(() {
                      _userQuickActions = updatedList;
                    });
                  },
                );
              },
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: brandBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        activeActions.isEmpty
            ? SizedBox(
                height: 50,
                child: Center(
                  child: Text(
                    'Belum ada aksi cepat dipilih.',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: activeActions.map((act) {
                  return Expanded(
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: brandBlue.withOpacity(isDark ? 0.2 : 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(AppIcons.sparkles, color: brandBlue, size: 20),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            act.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  // ==========================================
  // MY INSIGHT CARD
  // ==========================================
  Widget _buildMyInsightCard(Color textColor, Color textMuted, bool isDark) {
    const honeyGold = Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: honeyGold.withOpacity(isDark ? 0.35 : 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: honeyGold.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(AppIcons.sparkles, color: honeyGold, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Insight',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? textColor : const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pengeluaran menurun 12%! Hemat Rp1.450.000 pada pos non-primer dibanding minggu lalu.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? textMuted : const Color(0xFFB45309),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // RENCANA KEUANGAN
  // ==========================================
  Widget _buildRencanaKeuanganSection(
    Color textColor,
    Color textMuted,
    Color cardBg,
    Color borderColor,
    bool isDark,
    bool isDesktop,
  ) {
    final double totalBudget = widget.summaryData?['total_budget']?.toDouble() ?? 5000000.0;
    final double terpakaiBudget = widget.summaryData?['terpakai_budget']?.toDouble() ?? 2804178.0;
    final double sisaBudget = (totalBudget - terpakaiBudget).clamp(0, totalBudget);
    final double budgetRatio = (terpakaiBudget / totalBudget).clamp(0.0, 1.0);

    final double terkumpulTujuan = widget.summaryData?['terkumpul_tujuan']?.toDouble() ?? 10500000.0;
    final double targetTujuan = widget.summaryData?['target_tujuan']?.toDouble() ?? 15000000.0;
    final double tujuanRatio = (terkumpulTujuan / targetTujuan).clamp(0.0, 1.0);

    const brandBlue = Color(0xFF2563EB);
    const honeyGold = Color(0xFFF59E0B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rencana Keuangan',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.2,
              ),
            ),
            InkWell(
              onTap: widget.onNavigateToAnalisis,
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'Lihat Detail >',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: brandBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // BUDGET BULAN INI
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Budget Bulan Ini',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textMuted,
                          ),
                        ),
                        Icon(AppIcons.sliders, size: 12, color: textMuted),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isSaldoVisible ? 'Sisa ${_formatCurrency(sisaBudget)}' : '••••••••',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          Container(
                            height: 5,
                            width: double.infinity,
                            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
                          ),
                          FractionallySizedBox(
                            widthFactor: budgetRatio,
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                gradient: LinearGradient(
                                  colors: budgetRatio > 0.8
                                      ? [honeyGold, const Color(0xFFEF4444)]
                                      : [const Color(0xFF10B981), const Color(0xFF059669)],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Terpakai ${(budgetRatio * 100).toInt()}%',
                      style: TextStyle(fontSize: 9.5, color: textMuted, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // TUJUAN KEUANGAN
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tujuan Keuangan',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textMuted,
                          ),
                        ),
                        const Icon(AppIcons.checkCircle2, size: 12, color: honeyGold),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isSaldoVisible ? _formatCurrency(terkumpulTujuan) : '••••••••',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          Container(
                            height: 5,
                            width: double.infinity,
                            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
                          ),
                          FractionallySizedBox(
                            widthFactor: tujuanRatio,
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: honeyGold,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Target ${_formatCurrency(targetTujuan)} (${(tujuanRatio * 100).toInt()}%)',
                      style: TextStyle(fontSize: 9.5, color: textMuted, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // RIWAYAT TRANSAKSI
  // ==========================================
  Widget _buildRecentTransactionsSection(
    List recentTransactions,
    Color textColor,
    Color textMuted,
    Color cardBg,
    Color borderColor,
    bool isDark,
  ) {
    const brandBlue = Color(0xFF2563EB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Transaksi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.2,
              ),
            ),
            InkWell(
              onTap: widget.onNavigateToAnalisis,
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: brandBlue,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(AppIcons.chevronRight, size: 14, color: brandBlue),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: recentTransactions.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      'Belum ada transaksi dicatat.',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTransactions.length,
                  separatorBuilder: (context, index) => Divider(color: borderColor, height: 1),
                  itemBuilder: (context, index) {
                    final item = recentTransactions[index];
                    final isPemasukan = item['jenis'] == 'pemasukan';
                    final formattedNominal = _formatCurrency(item['nominal']);

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: brandBlue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          (item['icon'] as IconData?) ?? AppIcons.receipt,
                          color: brandBlue,
                          size: 16,
                        ),
                      ),
                      title: Text(
                        item['judul'] ?? 'Transaksi',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      subtitle: Text(
                        '${item['tanggal'] ?? 'Hari ini'} • ${item['kategori'] ?? 'Umum'}',
                        style: TextStyle(
                          fontSize: 11,
                          color: textMuted,
                        ),
                      ),
                      trailing: Text(
                        '${isPemasukan ? '+' : '-'}$formattedNominal',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isPemasukan ? const Color(0xFF10B981) : textColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSemuaKantongSubPage(
    Color textColor,
    Color textMuted,
    Color cardBg,
    Color borderColor,
    Color surfaceColor,
    bool isDark,
  ) {
    const brandBlue = Color(0xFF2563EB);

    return Container(
      key: const ValueKey('SemuaKantongSubPage'),
      color: surfaceColor,
      child: Column(
        children: [
          Container(
            color: brandBlue,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: _handleBackPress,
                  icon: const Icon(AppIcons.arrowLeft, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Semua Kantong Keuangan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSubPageWalletTile('BSI Hasanah', 'BSI', const Color(0xFF00A39D), 'Rp 4.250.000', cardBg, borderColor, textColor, textMuted),
                _buildSubPageWalletTile('Mandiri Utama', 'MANDIRI', const Color(0xFFD97706), 'Rp 6.000.000', cardBg, borderColor, textColor, textMuted),
                _buildSubPageWalletTile('GoPay Wallet', 'GOPAY', const Color(0xFF00AED6), 'Rp 1.000.000', cardBg, borderColor, textColor, textMuted),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => _openTambahAkunModal(context),
                    icon: const Icon(AppIcons.plus, size: 16, color: brandBlue),
                    label: const Text(
                      'Tambah Kantong Baru',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: brandBlue,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: brandBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubPageWalletTile(
    String title,
    String badge,
    Color badgeBg,
    String amount,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color textMuted,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
            child: Text(
              badge,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isSaldoVisible ? amount : '••••••••',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openPengaturanKantongBottomSheet(context, title),
            icon: Icon(AppIcons.moreVertical, size: 18, color: textMuted),
          ),
        ],
      ),
    );
  }
}

class TambahAkunFormContent extends StatefulWidget {
  const TambahAkunFormContent({super.key});

  @override
  State<TambahAkunFormContent> createState() => _TambahAkunFormContentState();
}

class _TambahAkunFormContentState extends State<TambahAkunFormContent> {
  String _jenisKantong = 'Bank';
  final TextEditingController _namaCtrl = TextEditingController();
  final TextEditingController _saldoCtrl = TextEditingController();

  @override
  void dispose() {
    _namaCtrl.dispose();
    _saldoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.colorScheme.surface;
    final textColor = theme.colorScheme.onSurface;
    final fillColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    const brandBlue = Color(0xFF2563EB);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tambah Kantong Keuangan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(AppIcons.x, size: 18, color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _jenisKantong,
            decoration: InputDecoration(
              labelText: 'Jenis Kantong',
              filled: true,
              fillColor: fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            items: ['Bank', 'E-Wallet', 'Tunai', 'Investasi']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _jenisKantong = val);
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _namaCtrl,
            decoration: InputDecoration(
              labelText: 'Nama Kantong / Akun',
              hintText: 'Contoh: Mandiri Utama / GoPay',
              filled: true,
              fillColor: fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _saldoCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Saldo Awal (Rp)',
              hintText: 'Contoh: 1000000',
              filled: true,
              fillColor: fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Kantong berhasil ditambahkan!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: brandBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Simpan Kantong',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// DELEGATE TOP BAR
// =========================================================
class _OvoStyleTopBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 56.0;

  @override
  double get maxExtent => 56.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    const brandBlue = Color(0xFF2563EB);
    const honeyGold = Color(0xFFF59E0B);

    return Container(
      color: brandBlue,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(AppIcons.user, color: Colors.white, size: 16),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'MyKas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(AppIcons.bell, color: Colors.white, size: 16),
              ),
              Positioned(
                right: 7,
                top: 7,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: honeyGold,
                    shape: BoxShape.circle,
                    border: Border.all(color: brandBlue, width: 1.2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
