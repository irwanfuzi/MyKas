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
            constraints: const BoxConstraints(maxWidth: 420),
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
    final tileBg = isDark ? const Color(0xFF1E222D) : const Color(0xFFF8FAFC);
    final borderColor = theme.colorScheme.outline.withOpacity(0.3);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 30,
                  height: 3,
                  decoration: BoxDecoration(
                    color: subtitleColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        namaKantong,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: subtitleColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(AppIcons.x, size: 16, color: textColor),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 10),
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
    Color iconColor = AppTheme.brandPrimary,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 9.5,
            color: subtitleColor,
          ),
        ),
        trailing: Icon(AppIcons.chevronRight, size: 13, color: subtitleColor),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

    final surfaceColor = theme.scaffoldBackgroundColor;
    final cardBg = theme.colorScheme.surface;
    final borderColor = theme.colorScheme.outline.withOpacity(0.3);
    final textColor = theme.colorScheme.onSurface;
    final textMuted = theme.colorScheme.onSurfaceVariant;

    return PopScope(
      canPop: !_showAllKantongSubPage,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _showAllKantongSubPage) {
          _handleBackPress();
        }
      },
      child: Container(
        color: AppTheme.brandPrimary,
        child: SafeArea(
          bottom: false,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              reverseDuration: const Duration(milliseconds: 200),
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

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isDesktop ? 1000 : 480), // Rampingkan max-width
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                // TopBar PINNED Mengambang
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _OvoStyleTopBarDelegate(),
                ),

                // Area Total Saldo
                SliverToBoxAdapter(
                  child: Container(
                    color: AppTheme.brandPrimary,
                    padding: const EdgeInsets.fromLTRB(14, 2, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Total Saldo',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isSaldoVisible = !_isSaldoVisible;
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Icon(
                                  _isSaldoVisible ? AppIcons.eye : AppIcons.eyeOff,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                          child: Text(
                            _isSaldoVisible ? rawSaldo : '••••••••••••',
                            key: ValueKey<bool>(_isSaldoVisible),
                            style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(AppIcons.clock, color: Colors.white.withOpacity(0.7), size: 10),
                            const SizedBox(width: 3),
                            Text(
                              'Updated 2m ago',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Body Kartu Konten
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.35 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? 20.0 : 12.0, // Padding samping rapat
                      10.0,
                      isDesktop ? 20.0 : 12.0,
                      20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 30,
                            height: 3,
                            decoration: BoxDecoration(
                              color: borderColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        if (isDesktop) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 6,
                                child: Column(
                                  children: [
                                    _buildKantongKeuanganSection(textColor, textMuted, cardBg, borderColor, isDark, true),
                                    const SizedBox(height: 12),
                                    _buildQuickActionsSection(textColor, isDark, true),
                                    const SizedBox(height: 12),
                                    _buildMyInsightCard(textColor, textMuted, isDark),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                flex: 6,
                                child: Column(
                                  children: [
                                    _buildRencanaKeuanganSection(textColor, textMuted, cardBg, borderColor, isDark, true),
                                    const SizedBox(height: 12),
                                    _buildRecentTransactionsSection(recentTransactions, textColor, textMuted, cardBg, borderColor, isDark),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          _buildKantongKeuanganSection(textColor, textMuted, cardBg, borderColor, isDark, false),
                          const SizedBox(height: 12),
                          _buildQuickActionsSection(textColor, isDark, false),
                          const SizedBox(height: 12),
                          _buildMyInsightCard(textColor, textMuted, isDark),
                          const SizedBox(height: 12),
                          _buildRencanaKeuanganSection(textColor, textMuted, cardBg, borderColor, isDark, false),
                          const SizedBox(height: 12),
                          _buildRecentTransactionsSection(recentTransactions, textColor, textMuted, cardBg, borderColor, isDark),
                        ],

                        const SizedBox(height: 16),
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
  // KANTONG KEUANGAN (ASPECT RATIO 2.5 - LEAN)
  // ==========================================
  Widget _buildKantongKeuanganSection(
    Color textColor,
    Color textMuted,
    Color cardBg,
    Color borderColor,
    bool isDark,
    bool isDesktop,
  ) {
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
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppTheme.brandPrimary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '3 Terhubung',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.brandPrimary,
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
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.brandPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          childAspectRatio: isDesktop ? 2.6 : 2.5, // Rasio pipih ramping
          children: [
            _buildWalletCard('BSI', const Color(0xFF00A39D), 'BSI Hasanah', 'Rp 4.250.000', cardBg, borderColor, textColor, textMuted),
            _buildWalletCard('MANDIRI', const Color(0xFFF59E0B), 'Mandiri Utama', 'Rp 6.000.000', cardBg, borderColor, textColor, textMuted),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
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
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(3)),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 7.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _openPengaturanKantongBottomSheet(context, title),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Icon(AppIcons.chevronRight, size: 11, color: textMuted),
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
                  fontSize: 9,
                  color: textMuted,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _isSaldoVisible ? amount : '••••••••',
                style: TextStyle(
                  fontSize: 11.5,
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
    return InkWell(
      onTap: () => _openTambahAkunModal(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            width: 1.0,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  color: AppTheme.brandPrimary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(AppIcons.plus, color: AppTheme.brandPrimary, size: 10),
              ),
              const SizedBox(width: 4),
              Text(
                'Tambah Akun',
                style: TextStyle(
                  fontSize: 9.5,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aksi Cepat',
              style: TextStyle(
                fontSize: 13,
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
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.brandPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        activeActions.isEmpty
            ? SizedBox(
                height: 36,
                child: Center(
                  child: Text(
                    'Belum ada aksi cepat dipilih.',
                    style: TextStyle(
                      fontSize: 10,
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
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.brandPrimary.withOpacity(0.18)
                                  : AppTheme.brandPrimary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(act.icon, color: AppTheme.brandPrimary, size: 16),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            act.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.brandPrimary.withOpacity(0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(AppIcons.sparkles, color: Color(0xFFF59E0B), size: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Insight',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Pengeluaran menurun 12%! Hemat Rp1.450.000 pada pos non-primer dibanding minggu lalu.',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: textMuted,
                    height: 1.2,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rencana Keuangan',
              style: TextStyle(
                fontSize: 13,
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
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.brandPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            // BUDGET BULAN INI
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(8),
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
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: textMuted,
                          ),
                        ),
                        Icon(AppIcons.sliders, size: 10, color: textMuted),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _isSaldoVisible ? 'Sisa ${_formatCurrency(sisaBudget)}' : '••••••••',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2.5),
                      child: Stack(
                        children: [
                          Container(
                            height: 4,
                            width: double.infinity,
                            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
                          ),
                          FractionallySizedBox(
                            widthFactor: budgetRatio,
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2.5),
                                gradient: LinearGradient(
                                  colors: budgetRatio > 0.8
                                      ? [const Color(0xFFF59E0B), AppTheme.expenseRed]
                                      : [AppTheme.incomeGreen, const Color(0xFF10B981)],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Terpakai ${(budgetRatio * 100).toInt()}%',
                      style: TextStyle(fontSize: 8, color: textMuted, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 5),

            // TUJUAN KEUANGAN
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(8),
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
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: textMuted,
                          ),
                        ),
                        Icon(AppIcons.checkCircle2, size: 10, color: AppTheme.brandPrimary),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _isSaldoVisible ? _formatCurrency(terkumpulTujuan) : '••••••••',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2.5),
                      child: Stack(
                        children: [
                          Container(
                            height: 4,
                            width: double.infinity,
                            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
                          ),
                          FractionallySizedBox(
                            widthFactor: tujuanRatio,
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppTheme.brandPrimary,
                                borderRadius: BorderRadius.circular(2.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Target ${_formatCurrency(targetTujuan)} (${(tujuanRatio * 100).toInt()}%)',
                      style: TextStyle(fontSize: 8, color: textMuted, fontWeight: FontWeight.w500),
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
  // RIWAYAT TRANSAKSI (DENSE LIST)
  // ==========================================
  Widget _buildRecentTransactionsSection(
    List recentTransactions,
    Color textColor,
    Color textMuted,
    Color cardBg,
    Color borderColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Transaksi',
              style: TextStyle(
                fontSize: 13,
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
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.brandPrimary,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(AppIcons.chevronRight, size: 11, color: AppTheme.brandPrimary),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: recentTransactions.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Center(
                    child: Text(
                      'Belum ada transaksi dicatat.',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 10.5,
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
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      leading: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppTheme.brandPrimary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          (item['icon'] as IconData?) ?? AppIcons.receipt,
                          color: AppTheme.brandPrimary,
                          size: 14,
                        ),
                      ),
                      title: Text(
                        item['judul'] ?? 'Transaksi',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      subtitle: Text(
                        '${item['tanggal'] ?? 'Hari ini'} • ${item['kategori'] ?? 'Umum'}',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: textMuted,
                        ),
                      ),
                      trailing: Text(
                        '${isPemasukan ? '+' : '-'}$formattedNominal',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: isPemasukan ? AppTheme.incomeGreen : textColor,
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
    return Container(
      key: const ValueKey('SemuaKantongSubPage'),
      color: surfaceColor,
      child: Column(
        children: [
          Container(
            color: AppTheme.brandPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: _handleBackPress,
                  icon: const Icon(AppIcons.arrowLeft, color: Colors.white, size: 18),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Semua Kantong Keuangan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _buildSubPageWalletTile('BSI Hasanah', 'BSI', const Color(0xFF00A39D), 'Rp 4.250.000', cardBg, borderColor, textColor, textMuted),
                _buildSubPageWalletTile('Mandiri Utama', 'MANDIRI', const Color(0xFFF59E0B), 'Rp 6.000.000', cardBg, borderColor, textColor, textMuted),
                _buildSubPageWalletTile('GoPay Wallet', 'GOPAY', const Color(0xFF00AED6), 'Rp 1.000.000', cardBg, borderColor, textColor, textMuted),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: () => _openTambahAkunModal(context),
                    icon: const Icon(AppIcons.plus, size: 14, color: AppTheme.brandPrimary),
                    label: const Text(
                      'Tambah Kantong Baru',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.brandPrimary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.brandPrimary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(3.5)),
            child: Text(
              badge,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: textMuted,
                  ),
                ),
                Text(
                  _isSaldoVisible ? amount : '••••••••',
                  style: TextStyle(
                    fontSize: 12,
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
            icon: Icon(AppIcons.moreVertical, size: 15, color: textMuted),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
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
    final fillColor = isDark ? const Color(0xFF1E222D) : const Color(0xFFF1F5F9);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 30,
              height: 3,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tambah Kantong Keuangan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(AppIcons.x, size: 16, color: textColor),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _jenisKantong,
            decoration: InputDecoration(
              labelText: 'Jenis Kantong',
              isDense: true,
              filled: true,
              fillColor: fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            items: ['Bank', 'E-Wallet', 'Tunai', 'Investasi']
                .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12))))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _jenisKantong = val);
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _namaCtrl,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              labelText: 'Nama Kantong / Akun',
              hintText: 'Contoh: Mandiri Utama / GoPay',
              isDense: true,
              filled: true,
              fillColor: fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _saldoCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              labelText: 'Saldo Awal (Rp)',
              hintText: 'Contoh: 1000000',
              isDense: true,
              filled: true,
              fillColor: fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Kantong berhasil ditambahkan!'),
                    backgroundColor: AppTheme.incomeGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.brandPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Simpan Kantong',
                style: TextStyle(
                  fontSize: 12,
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
// DELEGATE TOP BAR (PINNED 52PX HIGHLY PROPORTIONAL)
// =========================================================
class _OvoStyleTopBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 52.0;

  @override
  double get maxExtent => 52.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.brandPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(AppIcons.user, color: Colors.white, size: 15),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'MyKas',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(AppIcons.bell, color: Colors.white, size: 15),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.brandPrimary, width: 1.0),
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
