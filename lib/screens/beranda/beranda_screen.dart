import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/quick_action_item.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_icons.dart';
import '../../widgets/customize_quick_actions_sheet.dart';

// =============================================================================
// DESIGN TOKENS (MYKAS FINTECH FLAT PREMIUM)
// =============================================================================
const double _kMaxWidth = 520;
const double _kRadiusCard = 22;
const double _kPadCard = 16;

const Color _brandBlue = Color(0xFF2563EB); // Soft Royal Blue MyKas
const Color _incomeGreen = Color(0xFF10B981);
const Color _expenseRed = Color(0xFFEF4444);
const Color _honeyGold = Color(0xFFF59E0B);
const Color _accentPurple = Color(0xFF8B5CF6);
const Color _slate = Color(0xFF94A3B8);

TextStyle _ts(double size, FontWeight w, Color c, {double? height, double? ls}) {
  return GoogleFonts.inter(
    fontSize: size,
    fontWeight: w,
    color: c,
    height: height,
    letterSpacing: ls,
  );
}

Color _op(Color c, double o) => c.withOpacity(o);

class _Palette {
  final bool isDark;
  final Color bg, surface, surfaceAlt, border, text, muted, track;

  const _Palette({
    required this.isDark,
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.text,
    required this.muted,
    required this.track,
  });

  factory _Palette.of(BuildContext context) {
    final t = Theme.of(context);
    final d = t.brightness == Brightness.dark;
    return _Palette(
      isDark: d,
      bg: d ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      surface: d ? const Color(0xFF1E293B) : Colors.white,
      surfaceAlt: d ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      border: t.colorScheme.outline.withOpacity(d ? 0.25 : 0.10),
      text: t.colorScheme.onSurface,
      muted: t.colorScheme.onSurfaceVariant,
      track: d ? Colors.white10 : const Color(0xFFE2E8F0),
    );
  }
}

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
  late _Palette _p;

  String _formatCurrency(dynamic rawNominal) {
    if (rawNominal == null) return 'Rp 0';
    String strVal = rawNominal.toString().replaceAll(RegExp(r'[^0-9]'), '');
    if (strVal.isEmpty) return 'Rp 0';

    final intValue = int.tryParse(strVal) ?? 0;
    final buffer = StringBuffer();
    final numStr = intValue.toString();

    for (int i = 0; i < numStr.length; i++) {
      if (i > 0 && (numStr.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(numStr[i]);
    }
    return 'Rp $buffer';
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: _p.surface,
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
                    color: _p.muted.withOpacity(0.3),
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
                      Text('Pengaturan Kantong', style: _ts(16, FontWeight.w800, _p.text)),
                      Text(namaKantong, style: _ts(12, FontWeight.w500, _p.muted)),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(AppIcons.x, size: 18, color: _p.text),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSettingTileItem(
                context: context,
                icon: AppIcons.pencil,
                title: 'Ubah Nama & Kategori',
                subtitle: 'Ganti nama, jenis, atau ikon kantong',
                onTap: () => Navigator.pop(context),
              ),
              _buildSettingTileItem(
                context: context,
                icon: AppIcons.sliders,
                title: 'Atur Limit Pengeluaran',
                subtitle: 'Pasang batas budget bulanan kantong ini',
                onTap: () => Navigator.pop(context),
              ),
              _buildSettingTileItem(
                context: context,
                icon: AppIcons.checkCircle2,
                title: 'Jadikan Kantong Utama',
                subtitle: 'Gunakan sebagai sumber dana default',
                onTap: () => Navigator.pop(context),
              ),
              _buildSettingTileItem(
                context: context,
                icon: AppIcons.trash2,
                title: 'Hapus Kantong',
                subtitle: 'Keluarkan kantong ini dari daftar MyKas',
                iconColor: _expenseRed,
                textColor: _expenseRed,
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
    Color iconColor = _brandBlue,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _p.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _p.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _op(iconColor, 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        title: Text(title, style: _ts(13, FontWeight.w700, textColor ?? _p.text)),
        subtitle: Text(subtitle, style: _ts(11, FontWeight.w500, _p.muted)),
        trailing: Icon(AppIcons.chevronRight, size: 16, color: _p.muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
    _p = _Palette.of(context);

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

    return PopScope(
      canPop: !_showAllKantongSubPage,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _showAllKantongSubPage) {
          _handleBackPress();
        }
      },
      child: Container(
        color: _brandBlue,
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
                  ? _buildSemuaKantongSubPage()
                  : _buildMainBerandaView(rawSaldo, recentTransactions),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainBerandaView(String rawSaldo, List recentTransactions) {
    return LayoutBuilder(
      key: const ValueKey('MainBerandaView'),
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kMaxWidth),
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _OvoStyleTopBarDelegate(),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _p.isDark
                            ? const [Color(0xFF1E40AF), Color(0xFF2563EB)]
                            : const [Color(0xFF2563EB), Color(0xFF3B82F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Total Saldo',
                              style: _ts(12, FontWeight.w500, Colors.white.withOpacity(0.85)),
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
                          child: Text(
                            _isSaldoVisible ? rawSaldo : 'Rp ••••••••••',
                            key: ValueKey<bool>(_isSaldoVisible),
                            style: _ts(26, FontWeight.w900, Colors.white, ls: -0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(AppIcons.clock, color: Colors.white.withOpacity(0.7), size: 11),
                            const SizedBox(width: 4),
                            Text(
                              'Updated 2m ago',
                              style: _ts(11, FontWeight.w500, Colors.white.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _p.bg,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: _p.isDark
                          ? null
                          : const [
                              BoxShadow(
                                color: Color(0x080F172A),
                                blurRadius: 16,
                                offset: Offset(0, -4),
                              ),
                            ],
                    ),
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? 28.0 : 16.0,
                      12.0,
                      isDesktop ? 28.0 : 16.0,
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
                              color: _p.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildKantongKeuanganSection(isDesktop),
                        const SizedBox(height: 16),
                        _buildQuickActionsSection(isDesktop),
                        const SizedBox(height: 16),
                        _buildMyInsightCard(),
                        const SizedBox(height: 16),
                        _buildRencanaKeuanganSection(isDesktop),
                        const SizedBox(height: 16),
                        _buildRecentTransactionsSection(recentTransactions),
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

  Widget _buildKantongKeuanganSection(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text('Kantong Keuangan', style: _ts(14, FontWeight.w800, _p.text)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: _op(_brandBlue, 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('3 Terhubung', style: _ts(10, FontWeight.w700, _brandBlue)),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text('Lihat Semua >', style: _ts(11.5, FontWeight.w700, _brandBlue)),
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
          childAspectRatio: isDesktop ? 2.0 : 1.7,
          children: [
            _buildWalletCard('BSI', const Color(0xFF00A39D), 'BSI Hasanah', 'Rp 4.250.000'),
            _buildWalletCard('MANDIRI', _honeyGold, 'Mandiri Utama', 'Rp 6.000.000'),
            _buildWalletCard('GOPAY', const Color(0xFF00AED6), 'GoPay Wallet', 'Rp 1.000.000'),
            _buildAddAccountCard(),
          ],
        ),
      ],
    );
  }

  Widget _buildWalletCard(String badge, Color badgeBg, String title, String amount) {
    return Container(
      padding: const EdgeInsets.all(_kPadCard),
      decoration: BoxDecoration(
        color: _p.surface,
        borderRadius: BorderRadius.circular(_kRadiusCard),
        border: Border.all(color: _p.border),
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
                decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
                child: Text(badge, style: _ts(9, FontWeight.w900, Colors.white)),
              ),
              InkWell(
                onTap: () => _openPengaturanKantongBottomSheet(context, title),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Icon(AppIcons.chevronRight, size: 14, color: _p.muted),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _ts(11, FontWeight.w500, _p.muted), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(
                _isSaldoVisible ? amount : 'Rp ••••••••',
                style: _ts(13.5, FontWeight.w800, _p.text, ls: -0.3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddAccountCard() {
    return InkWell(
      onTap: () => _openTambahAkunModal(context),
      borderRadius: BorderRadius.circular(_kRadiusCard),
      child: Container(
        decoration: BoxDecoration(
          color: _p.surface,
          borderRadius: BorderRadius.circular(_kRadiusCard),
          border: Border.all(color: _p.border, width: 1.2),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _op(_brandBlue, 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(AppIcons.plus, color: _brandBlue, size: 16),
              ),
              const SizedBox(height: 6),
              Text('+ Tambah Akun', style: _ts(11, FontWeight.w700, _brandBlue)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(bool isDesktop) {
    final activeActions = _userQuickActions.where((item) => item.isEnabled).take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Aksi Cepat', style: _ts(14, FontWeight.w800, _p.text)),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text('Edit', style: _ts(11.5, FontWeight.w700, _brandBlue)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: _p.surface,
            borderRadius: BorderRadius.circular(_kRadiusCard),
            border: Border.all(color: _p.border),
          ),
          child: activeActions.isEmpty
              ? SizedBox(
                  height: 50,
                  child: Center(
                    child: Text('Belum ada aksi cepat dipilih.', style: _ts(12, FontWeight.w500, _p.muted)),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: activeActions.map((act) {
                    return InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _op(_brandBlue, _p.isDark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(AppIcons.sparkles, color: _brandBlue, size: 20),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 64,
                            child: Text(
                              act.title,
                              textAlign: TextAlign.center,
                              style: _ts(11, FontWeight.w600, _p.text),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildMyInsightCard() {
    return Container(
      padding: const EdgeInsets.all(_kPadCard),
      decoration: BoxDecoration(
        color: _p.isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(_kRadiusCard),
        border: Border.all(color: _op(_accentPurple, 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _op(_accentPurple, 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(AppIcons.sparkles, color: _accentPurple, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Insight', style: _ts(12.5, FontWeight.w800, _p.text)),
                const SizedBox(height: 2),
                Text(
                  'Pengeluaran menurun 12%! Hemat Rp1.450.000 pada pos non-primer dibanding minggu lalu.',
                  style: _ts(11, FontWeight.w500, _p.muted, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRencanaKeuanganSection(bool isDesktop) {
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
            Text('Rencana Keuangan', style: _ts(14, FontWeight.w800, _p.text)),
            InkWell(
              onTap: widget.onNavigateToAnalisis,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text('Lihat Detail >', style: _ts(11.5, FontWeight.w700, _brandBlue)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(_kPadCard),
                decoration: BoxDecoration(
                  color: _p.surface,
                  borderRadius: BorderRadius.circular(_kRadiusCard),
                  border: Border.all(color: _p.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Budget Bulan Ini', style: _ts(11, FontWeight.w600, _p.muted)),
                        Icon(AppIcons.sliders, size: 12, color: _p.muted),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isSaldoVisible ? 'Sisa ${_formatCurrency(sisaBudget)}' : 'Rp ••••••••',
                      style: _ts(13, FontWeight.w800, _p.text, ls: -0.2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          Container(
                            height: 6,
                            width: double.infinity,
                            color: _p.track,
                          ),
                          FractionallySizedBox(
                            widthFactor: budgetRatio,
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: budgetRatio > 0.8 ? _expenseRed : _incomeGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Terpakai ${(budgetRatio * 100).toInt()}%',
                      style: _ts(9.5, FontWeight.w500, _p.muted),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(_kPadCard),
                decoration: BoxDecoration(
                  color: _p.surface,
                  borderRadius: BorderRadius.circular(_kRadiusCard),
                  border: Border.all(color: _p.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tujuan Keuangan', style: _ts(11, FontWeight.w600, _p.muted)),
                        const Icon(AppIcons.checkCircle2, size: 12, color: _honeyGold),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isSaldoVisible ? _formatCurrency(terkumpulTujuan) : 'Rp ••••••••',
                      style: _ts(13, FontWeight.w800, _p.text, ls: -0.2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          Container(
                            height: 6,
                            width: double.infinity,
                            color: _p.track,
                          ),
                          FractionallySizedBox(
                            widthFactor: tujuanRatio,
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: _honeyGold,
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
                      style: _ts(9.5, FontWeight.w500, _p.muted),
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

  Widget _buildRecentTransactionsSection(List recentTransactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Riwayat Transaksi', style: _ts(14, FontWeight.w800, _p.text)),
            InkWell(
              onTap: widget.onNavigateToAnalisis,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Text('Lihat Semua', style: _ts(11.5, FontWeight.w700, _brandBlue)),
                    const SizedBox(width: 2),
                    const Icon(AppIcons.chevronRight, size: 14, color: _brandBlue),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: _p.surface,
            borderRadius: BorderRadius.circular(_kRadiusCard),
            border: Border.all(color: _p.border),
          ),
          child: recentTransactions.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Text('Belum ada transaksi dicatat.', style: _ts(12, FontWeight.w500, _p.muted)),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTransactions.length,
                  separatorBuilder: (context, index) => Divider(color: _p.border, height: 1),
                  itemBuilder: (context, index) {
                    final item = recentTransactions[index];
                    final isPemasukan = item['jenis'] == 'pemasukan';
                    final formattedNominal = _formatCurrency(item['nominal']);

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _op(_brandBlue, 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          (item['icon'] as IconData?) ?? AppIcons.receipt,
                          color: _brandBlue,
                          size: 16,
                        ),
                      ),
                      title: Text(
                        item['judul'] ?? 'Transaksi',
                        style: _ts(12.5, FontWeight.w700, _p.text),
                      ),
                      subtitle: Text(
                        '${item['tanggal'] ?? 'Hari ini'} • ${item['kategori'] ?? 'Umum'}',
                        style: _ts(11, FontWeight.w500, _p.muted),
                      ),
                      trailing: Text(
                        '${isPemasukan ? '+' : '-'}$formattedNominal',
                        style: _ts(13, FontWeight.w800, isPemasukan ? _incomeGreen : _p.text, ls: -0.2),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSemuaKantongSubPage() {
    return Container(
      key: const ValueKey('SemuaKantongSubPage'),
      color: _p.bg,
      child: Column(
        children: [
          Container(
            color: _brandBlue,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: _handleBackPress,
                  icon: const Icon(AppIcons.arrowLeft, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 8),
                Text('Semua Kantong Keuangan', style: _ts(18, FontWeight.w800, Colors.white)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSubPageWalletTile('BSI Hasanah', 'BSI', const Color(0xFF00A39D), 'Rp 4.250.000'),
                _buildSubPageWalletTile('Mandiri Utama', 'MANDIRI', _honeyGold, 'Rp 6.000.000'),
                _buildSubPageWalletTile('GoPay Wallet', 'GOPAY', const Color(0xFF00AED6), 'Rp 1.000.000'),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => _openTambahAkunModal(context),
                    icon: const Icon(AppIcons.plus, size: 16, color: _brandBlue),
                    label: Text('Tambah Kantong Baru', style: _ts(13, FontWeight.w700, _brandBlue)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _brandBlue),
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

  Widget _buildSubPageWalletTile(String title, String badge, Color badgeBg, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(_kPadCard),
      decoration: BoxDecoration(
        color: _p.surface,
        borderRadius: BorderRadius.circular(_kRadiusCard),
        border: Border.all(color: _p.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
            child: Text(badge, style: _ts(10, FontWeight.w900, Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _ts(11.5, FontWeight.w500, _p.muted)),
                const SizedBox(height: 2),
                Text(
                  _isSaldoVisible ? amount : 'Rp ••••••••',
                  style: _ts(14, FontWeight.w800, _p.text, ls: -0.3),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openPengaturanKantongBottomSheet(context, title),
            icon: Icon(AppIcons.moreVertical, size: 18, color: _p.muted),
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
    final p = _Palette.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: p.surface,
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
                color: p.muted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tambah Kantong Keuangan', style: _ts(17, FontWeight.w800, p.text)),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(AppIcons.x, size: 18, color: p.text),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _jenisKantong,
            dropdownColor: p.surface,
            decoration: InputDecoration(
              labelText: 'Jenis Kantong',
              filled: true,
              fillColor: p.surfaceAlt,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            items: ['Bank', 'E-Wallet', 'Tunai', 'Investasi']
                .map((e) => DropdownMenuItem(value: e, child: Text(e, style: _ts(13, FontWeight.w500, p.text))))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _jenisKantong = val);
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _namaCtrl,
            style: _ts(13, FontWeight.w500, p.text),
            decoration: InputDecoration(
              labelText: 'Nama Kantong / Akun',
              hintText: 'Contoh: Mandiri Utama / GoPay',
              filled: true,
              fillColor: p.surfaceAlt,
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
            style: _ts(13, FontWeight.w500, p.text),
            decoration: InputDecoration(
              labelText: 'Saldo Awal (Rp)',
              hintText: 'Contoh: 1000000',
              filled: true,
              fillColor: p.surfaceAlt,
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
                  SnackBar(
                    content: Text('Kantong berhasil ditambahkan!', style: _ts(13, FontWeight.w600, Colors.white)),
                    backgroundColor: _incomeGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text('Simpan Kantong', style: _ts(13, FontWeight.w700, Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _OvoStyleTopBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 56.0;

  @override
  double get maxExtent => 56.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _brandBlue,
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
          Expanded(
            child: Center(
              child: Text(
                'MyKas',
                style: _ts(18, FontWeight.w800, Colors.white, ls: -0.5),
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
                    color: _honeyGold,
                    shape: BoxShape.circle,
                    border: Border.all(color: _brandBlue, width: 1.2),
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
