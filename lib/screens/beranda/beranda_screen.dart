import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/quick_action_item.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_icons.dart';
import '../../widgets/customize_quick_actions_sheet.dart';

// =============================================================================
// DESIGN TOKENS (OBSIDIAN KINETIC / ROYAL PRECISION)
// =============================================================================
const double _kMaxWidth = 520;
const double _kRadiusCard = 20.0;
const double _kRadiusAction = 14.0;
const double _kPadCard = 16.0;

const Color _brandBlue = Color(0xFF3B82F6);
const Color _brandBlueActive = Color(0xFF2563EB);
const Color _incomeGreen = Color(0xFF10B981);
const Color _expenseRed = Color(0xFFEF4444);
const Color _honeyGold = Color(0xFFF59E0B);
const Color _accentPurple = Color(0xFF8B5CF6);

TextStyle _tsUI(double size, FontWeight w, Color c, {double? height, double? ls}) {
  return GoogleFonts.plusJakartaSans(
    fontSize: size,
    fontWeight: w,
    color: c,
    height: height,
    letterSpacing: ls,
  );
}

TextStyle _tsNum(double size, FontWeight w, Color c, {double? height, double? ls}) {
  return GoogleFonts.inter(
    fontSize: size,
    fontWeight: w,
    color: c,
    height: height,
    letterSpacing: ls,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}

Color _op(Color c, double o) => c.withOpacity(o);

class _Palette {
  final bool isDark;
  final Color baseBg, headerBg, surfaceCard, surfaceElevated, border, textPrimary, textSecondary, textMuted, track;

  const _Palette({
    required this.isDark,
    required this.baseBg,
    required this.headerBg,
    required this.surfaceCard,
    required this.surfaceElevated,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.track,
  });

  factory _Palette.of(BuildContext context) {
    final d = Theme.of(context).brightness == Brightness.dark;
    return _Palette(
      isDark: d,
      baseBg: d ? const Color(0xFF0A0E18) : const Color(0xFFF8FAFC),
      headerBg: d ? const Color(0xFF0F131D) : const Color(0xFF1E40AF),
      surfaceCard: d ? const Color(0xFF171B26) : Colors.white,
      surfaceElevated: d ? const Color(0xFF1E2433) : const Color(0xFFF1F5F9),
      border: d ? const Color(0xFF232938) : const Color(0xFFE2E8F0),
      textPrimary: d ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
      textSecondary: d ? const Color(0xFF94A3B8) : const Color(0xFF475569),
      textMuted: d ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
      track: d ? const Color(0xFF232938) : const Color(0xFFE2E8F0),
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
  bool _hasUnreadNotification = true;

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

  void _openProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _p.surfaceCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: _p.textMuted.withOpacity(0.3), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Profil & Pengaturan', style: _tsUI(18, FontWeight.w800, _p.textPrimary)),
                IconButton(onPressed: () => Navigator.pop(context), icon: Icon(AppIcons.x, size: 18, color: _p.textPrimary)),
              ],
            ),
            const SizedBox(height: 16),
            _buildActionModalTile(AppIcons.user, 'Akun Saya (Irwan Fuzi Saputra)', 'Kelola informasi pribadi & keamanan biometrik', () {}),
            _buildActionModalTile(AppIcons.sliders, 'Pengaturan Limit Transaksi', 'Atur batas harian dan bulanan', () {}),
            _buildActionModalTile(AppIcons.checkCircle2, 'Keamanan & Biometrik', 'Konfigurasi sidik jari & PIN', () {}),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berhasil keluar akun', style: _tsUI(13, FontWeight.w600, Colors.white)), backgroundColor: _expenseRed));
                },
                style: ElevatedButton.styleFrom(backgroundColor: _expenseRed, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text('Keluar Aplikasi', style: _tsUI(14, FontWeight.w700, Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openNotificationModal() {
    setState(() => _hasUnreadNotification = false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _p.surfaceCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: _p.textMuted.withOpacity(0.3), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pusat Notifikasi', style: _tsUI(18, FontWeight.w800, _p.textPrimary)),
                IconButton(onPressed: () => Navigator.pop(context), icon: Icon(AppIcons.x, size: 18, color: _p.textPrimary)),
              ],
            ),
            const SizedBox(height: 16),
            _buildNotificationItem('Arus Kas Sehat', 'Pengeluaran Anda turun 18% minggu ini. Pertahankan!', 'Baru saja'),
            _buildNotificationItem('Setoran Target Berhasil', 'Target tabungan rumah telah disetor sebesar Rp 1.500.000.', 'Kemarin'),
            _buildNotificationItem('Pengingat Tagihan PLN', 'Tagihan listrik bulanan jatuh tempo dalam 2 hari.', '2 hari lalu'),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String desc, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _p.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: _tsUI(13, FontWeight.w700, _p.textPrimary)),
              Text(time, style: _tsUI(10, FontWeight.w500, _p.textMuted)),
            ],
          ),
          const SizedBox(height: 4),
          Text(desc, style: _tsUI(12, FontWeight.w500, _p.textSecondary)),
        ],
      ),
    );
  }

  void _openTransferModal() {
    _showActionDialog('Transfer Dana', 'Masukkan nomor rekening tujuan & nominal transfer.', 'Lanjutkan Transfer');
  }

  void _openTopUpModal() {
    _showActionDialog('Top Up Saldo', 'Pilih e-wallet atau Virtual Account tujuan pengisian.', 'Top Up Sekarang');
  }

  void _openSetorTargetModal() {
    _showActionDialog('Setor Target Finansial', 'Masukkan nominal setoran kilat untuk kantong target Anda.', 'Setor Tabungan');
  }

  void _showActionDialog(String title, String subtitle, String buttonText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _p.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: _tsUI(16, FontWeight.w700, _p.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle, style: _tsUI(12, FontWeight.w500, _p.textSecondary)),
            const SizedBox(height: 14),
            TextField(
              style: _tsNum(13, FontWeight.w600, _p.textPrimary),
              decoration: InputDecoration(
                labelText: 'Nominal (Rp)',
                filled: true,
                fillColor: _p.surfaceElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: _tsUI(13, FontWeight.w600, _p.textMuted))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title berhasil diproses!', style: _tsUI(13, FontWeight.w600, Colors.white)), backgroundColor: _incomeGreen));
            },
            style: ElevatedButton.styleFrom(backgroundColor: _brandBlue, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(buttonText, style: _tsUI(13, FontWeight.w700, Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openInsightModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: _p.surfaceCard, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: _p.textMuted.withOpacity(0.3), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Analisis My Insight ✨', style: _tsUI(18, FontWeight.w800, _p.textPrimary)),
            const SizedBox(height: 12),
            Text('Pengeluaran Anda minggu ini turun 18% dibanding minggu lalu. Penghematan terbesar terjadi pada kategori Kuliner & F&B dan Belanja Harian. Arus kas dalam kondisi sangat sehat.', style: _tsUI(13, FontWeight.w500, _p.textSecondary)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _openBudgetDetailModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: _p.surfaceCard, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: _p.textMuted.withOpacity(0.3), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Detail Alokasi Sisa Budget', style: _tsUI(18, FontWeight.w800, _p.textPrimary)),
            const SizedBox(height: 12),
            Text('Limit Bulanan: Rp 8.000.000\nTerpakai: Rp 7.520.000\nSisa Budget: Rp 480.000 (94% terpakai)', style: _tsNum(13, FontWeight.w600, _p.textSecondary)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _openTargetDetailModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: _p.surfaceCard, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: _p.textMuted.withOpacity(0.3), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Detail Target Finansial', style: _tsUI(18, FontWeight.w800, _p.textPrimary)),
            const SizedBox(height: 12),
            Text('Target Utama: Rp 60.000.000\nTerkumpul: Rp 55.200.000 (92%)\nKurang: Rp 4.800.000 lagi untuk mencapai target.', style: _tsNum(13, FontWeight.w600, _p.textSecondary)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _openTransactionReceiptModal(Map item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: _p.surfaceCard, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: _p.textMuted.withOpacity(0.3), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Struk Digital Transaksi', style: _tsUI(18, FontWeight.w800, _p.textPrimary)),
            const SizedBox(height: 16),
            _buildReceiptRow('Judul Transaksi', item['judul']),
            _buildReceiptRow('Kategori', item['kategori']),
            _buildReceiptRow('Tanggal', item['tanggal']),
            _buildReceiptRow('Sumber Dana', item['badge']),
            _buildReceiptRow('Nominal', '${item['jenis'] == 'pemasukan' ? '+' : '-'}${_formatCurrency(item['nominal'])}'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: _tsUI(12, FontWeight.w500, _p.textSecondary)),
          Text(value, style: _tsUI(13, FontWeight.w700, _p.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildActionModalTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: _p.surfaceElevated, borderRadius: BorderRadius.circular(14), border: Border.all(color: _p.border)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: _op(_brandBlue, 0.15), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: _brandBlue),
        ),
        title: Text(title, style: _tsUI(13, FontWeight.w600, _p.textPrimary)),
        subtitle: Text(subtitle, style: _tsUI(11, FontWeight.w500, _p.textSecondary)),
        trailing: Icon(AppIcons.chevronRight, size: 16, color: _p.textMuted),
      ),
    );
  }

  void _openTambahAkunModal(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    if (isDesktop) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: const TambahAkunFormContent()),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: const TambahAkunFormContent(),
        ),
      );
    }
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
        color: _p.surfaceElevated,
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
        title: Text(title, style: _tsUI(13, FontWeight.w600, textColor ?? _p.textPrimary)),
        subtitle: Text(subtitle, style: _tsUI(11, FontWeight.w500, _p.textSecondary)),
        trailing: Icon(AppIcons.chevronRight, size: 16, color: _p.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _openPengaturanKantongBottomSheet(BuildContext context, String namaKantong) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(color: _p.surfaceCard, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: _p.textMuted.withOpacity(0.3), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pengaturan Kantong', style: _tsUI(16, FontWeight.w700, _p.textPrimary)),
                      Text(namaKantong, style: _tsUI(12, FontWeight.w500, _p.textSecondary)),
                    ],
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: Icon(AppIcons.x, size: 18, color: _p.textPrimary)),
                ],
              ),
              const SizedBox(height: 16),
              _buildSettingTileItem(context: context, icon: AppIcons.pencil, title: 'Ubah Nama & Kategori', subtitle: 'Ganti nama, jenis, atau ikon kantong', onTap: () => Navigator.pop(context)),
              _buildSettingTileItem(context: context, icon: AppIcons.sliders, title: 'Atur Limit Pengeluaran', subtitle: 'Pasang batas budget bulanan kantong ini', onTap: () => Navigator.pop(context)),
              _buildSettingTileItem(context: context, icon: AppIcons.checkCircle2, title: 'Jadikan Kantong Utama', subtitle: 'Gunakan sebagai sumber dana default', onTap: () => Navigator.pop(context)),
              _buildSettingTileItem(context: context, icon: AppIcons.trash2, title: 'Hapus Kantong', subtitle: 'Keluarkan kantong ini dari daftar MyKas', iconColor: _expenseRed, textColor: _expenseRed, onTap: () => Navigator.pop(context)),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
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

    final rawSaldo = widget.summaryData?['saldo'] ?? 'Rp 24.850.000';

    final List riwayat = widget.summaryData?['riwayat'] as List? ?? [
      {
        'judul': 'Supermarket Papaya Fresh',
        'kategori': 'Belanja Bulanan',
        'tanggal': 'Hari ini',
        'nominal': '348500',
        'jenis': 'pengeluaran',
        'icon': AppIcons.shoppingCart,
        'badge': 'BCA',
      },
      {
        'judul': 'Gaji Bulanan',
        'kategori': 'Penghasilan',
        'tanggal': '25 Okt',
        'nominal': '14500000',
        'jenis': 'pemasukan',
        'icon': AppIcons.wallet,
        'badge': 'Mandiri',
      },
      {
        'judul': 'Kopi Kenangan Mantan',
        'kategori': 'Kuliner & F&B',
        'tanggal': '24 Okt',
        'nominal': '38000',
        'jenis': 'pengeluaran',
        'icon': AppIcons.utensils,
        'badge': 'GoPay',
      },
      {
        'judul': 'PLN & Internet',
        'kategori': 'Tagihan Utilitas',
        'tanggal': '23 Okt',
        'nominal': '450000',
        'jenis': 'pengeluaran',
        'icon': AppIcons.sliders,
        'badge': 'BCA',
      },
    ];

    final recentTransactions = riwayat.take(4).toList();

    return PopScope(
      canPop: !_showAllKantongSubPage,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _showAllKantongSubPage) {
          _handleBackPress();
        }
      },
      child: Container(
        color: _p.headerBg,
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
    return SizedBox.expand(
      key: const ValueKey('MainBerandaView'),
      child: LayoutBuilder(
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
                    delegate: _CollapsingHeaderDelegate(
                      isSaldoVisible: _isSaldoVisible,
                      rawSaldo: rawSaldo,
                      onToggleSaldo: () {
                        setState(() {
                          _isSaldoVisible = !_isSaldoVisible;
                        });
                      },
                      palette: _p,
                      onTapProfile: _openProfileModal,
                      onTapNotification: _openNotificationModal,
                      hasUnreadNotification: _hasUnreadNotification,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _p.baseBg,
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
                          const SizedBox(height: 12),
                          _buildPortofolioKasSection(),
                          const SizedBox(height: 20),
                          _buildAksiCepatSection(),
                          const SizedBox(height: 20),
                          _buildMyInsightCard(),
                          const SizedBox(height: 20),
                          _buildRencanaKeuanganSection(),
                          const SizedBox(height: 20),
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
      ),
    );
  }

  Widget _buildPortofolioKasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Portofolio Kas', style: _tsUI(16, FontWeight.w700, _p.textPrimary, ls: -0.01)),
            InkWell(
              onTap: () {
                setState(() {
                  _showAllKantongSubPage = true;
                });
              },
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Text('Kelola', style: _tsUI(12, FontWeight.w600, _brandBlue)),
                    const SizedBox(width: 2),
                    const Icon(AppIcons.chevronRight, size: 14, color: _brandBlue),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 98,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildPortofolioCard('BCA', _brandBlue, 'Bank BCA', '•• 8291', 'Utama', '14.300.000'),
              const SizedBox(width: 10),
              _buildPortofolioCard('MDR', const Color(0xFF0F172A), 'Bank Mandiri', '•• 3409', 'Operasional', '4.550.000', customBadgeColor: _honeyGold),
              const SizedBox(width: 10),
              _buildPortofolioCard('GOPAY', const Color(0xFF00AED6), 'GoPay', 'e-Wallet', 'Harian', '2.800.000'),
              const SizedBox(width: 10),
              _buildAddAccountTile(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPortofolioCard(String code, Color badgeColor, String title, String sub, String status, String amount, {Color? customBadgeColor}) {
    return InkWell(
      onTap: () => _openPengaturanKantongBottomSheet(context, title),
      borderRadius: BorderRadius.circular(_kRadiusCard),
      child: Container(
        width: 215,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _p.surfaceCard,
          borderRadius: BorderRadius.circular(_kRadiusCard),
          border: Border.all(color: _p.border, width: 1.0),
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
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(code, style: _tsUI(9, FontWeight.w800, badgeColor == const Color(0xFF0F172A) ? _honeyGold : Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: _tsUI(14, FontWeight.w600, _p.textPrimary)),
                        Text(sub, style: _tsUI(12, FontWeight.w500, _p.textSecondary)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: status == 'Utama' ? _op(_brandBlue, 0.15) : _p.surfaceElevated,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(status, style: _tsUI(10, FontWeight.w700, status == 'Utama' ? _brandBlue : _p.textSecondary, ls: 0.02)),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Saldo Tersedia', style: _tsUI(12, FontWeight.w500, _p.textSecondary)),
                Text(_isSaldoVisible ? 'Rp $amount' : 'Rp ••••••••', style: _tsNum(14, FontWeight.w700, _p.textPrimary, ls: -0.3)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAccountTile() {
    return InkWell(
      onTap: () => _openTambahAkunModal(context),
      borderRadius: BorderRadius.circular(_kRadiusCard),
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: _op(_p.surfaceElevated, 0.6),
          borderRadius: BorderRadius.circular(_kRadiusCard),
          border: Border.all(color: _p.border, width: 1.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _op(_brandBlue, 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(AppIcons.plus, color: _brandBlue, size: 16),
            ),
            const SizedBox(height: 6),
            Text('Tambah Akun', style: _tsUI(12, FontWeight.w600, _p.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildAksiCepatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Aksi Cepat', style: _tsUI(16, FontWeight.w700, _p.textPrimary, ls: -0.01)),
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
              child: Text('Atur', style: _tsUI(12, FontWeight.w600, _brandBlue)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: _p.surfaceCard,
            borderRadius: BorderRadius.circular(_kRadiusCard),
            border: Border.all(color: _p.border, width: 1.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionItem('Transfer', AppIcons.arrowUpRight, _brandBlue, _openTransferModal),
              _buildQuickActionItem('Top Up', AppIcons.plus, _incomeGreen, _openTopUpModal),
              _buildQuickActionItem('Setor Target', AppIcons.checkCircle2, _honeyGold, _openSetorTargetModal),
              _buildQuickActionItem('Lainnya', AppIcons.sliders, _accentPurple, () {
                CustomizeQuickActionsSheet.show(
                  context,
                  currentItems: _userQuickActions,
                  onSave: (updatedList) {
                    setState(() => _userQuickActions = updatedList);
                  },
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_kRadiusAction),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _op(color, 0.15),
              borderRadius: BorderRadius.circular(_kRadiusAction),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(title, style: _tsUI(12, FontWeight.w600, _p.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildMyInsightCard() {
    return InkWell(
      onTap: _openInsightModal,
      borderRadius: BorderRadius.circular(_kRadiusCard),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _p.isDark
                ? const [Color(0xFF1E2433), Color(0xFF171B26)]
                : const [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          ),
          borderRadius: BorderRadius.circular(_kRadiusCard),
          border: Border.all(color: _p.border, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(AppIcons.sparkles, color: _honeyGold, size: 12),
                    ),
                    const SizedBox(width: 6),
                    Text('MY INSIGHT ✨', style: _tsUI(11, FontWeight.w800, Colors.white, ls: 0.02)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text('Pekan Ini', style: _tsUI(10, FontWeight.w600, Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: _tsUI(12, FontWeight.w500, Colors.white.withOpacity(0.95), height: 1.3),
                children: [
                  const TextSpan(text: 'Pengeluaran turun '),
                  TextSpan(text: '18%', style: _tsNum(12, FontWeight.w700, _honeyGold)),
                  const TextSpan(text: ' minggu ini. Arus kas dalam kondisi '),
                  TextSpan(text: 'sangat sehat', style: _tsUI(12, FontWeight.w700, Colors.white)),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRencanaKeuanganSection() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _openBudgetDetailModal,
            borderRadius: BorderRadius.circular(_kRadiusCard),
            child: Container(
              padding: const EdgeInsets.all(_kPadCard),
              decoration: BoxDecoration(
                color: _p.surfaceCard,
                borderRadius: BorderRadius.circular(_kRadiusCard),
                border: Border.all(color: _p.border, width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: _expenseRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('Sisa Budget', style: _tsUI(12, FontWeight.w600, _p.textPrimary)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _op(_expenseRed, 0.15),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text('94%', style: _tsNum(10, FontWeight.w700, _expenseRed)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isSaldoVisible ? 'Rp 480.000' : 'Rp ••••••••',
                    style: _tsNum(18, FontWeight.w700, _p.textPrimary, ls: -0.3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.94,
                      backgroundColor: _p.track,
                      valueColor: const AlwaysStoppedAnimation<Color>(_expenseRed),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Terpakai 7,52 Jt', style: _tsUI(12, FontWeight.w500, _p.textSecondary)),
                      Text('Limit 8 Jt', style: _tsUI(12, FontWeight.w600, _p.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: _openTargetDetailModal,
            borderRadius: BorderRadius.circular(_kRadiusCard),
            child: Container(
              padding: const EdgeInsets.all(_kPadCard),
              decoration: BoxDecoration(
                color: _p.surfaceCard,
                borderRadius: BorderRadius.circular(_kRadiusCard),
                border: Border.all(color: _p.border, width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: _incomeGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('Target Finansial', style: _tsUI(12, FontWeight.w600, _p.textPrimary)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _op(_incomeGreen, 0.15),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text('92%', style: _tsNum(10, FontWeight.w700, _incomeGreen)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isSaldoVisible ? 'Rp 55.200.000' : 'Rp ••••••••',
                    style: _tsNum(18, FontWeight.w700, _p.textPrimary, ls: -0.3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.92,
                      backgroundColor: _p.track,
                      valueColor: const AlwaysStoppedAnimation<Color>(_incomeGreen),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Hampir Finish!', style: _tsUI(12, FontWeight.w500, _p.textSecondary)),
                      Text('Target 60 Jt', style: _tsUI(12, FontWeight.w600, _p.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
            Text('Aktivitas Terbaru', style: _tsUI(16, FontWeight.w700, _p.textPrimary, ls: -0.01)),
            Text('${recentTransactions.length} Transaksi', style: _tsUI(12, FontWeight.w500, _p.textSecondary)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: _p.surfaceCard,
            borderRadius: BorderRadius.circular(_kRadiusCard),
            border: Border.all(color: _p.border, width: 1.0),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentTransactions.length,
            separatorBuilder: (context, index) => Divider(color: _p.border, height: 1),
            itemBuilder: (context, index) {
              final item = recentTransactions[index];
              final isPemasukan = item['jenis'] == 'pemasukan';
              final formattedNominal = _formatCurrency(item['nominal']);

              return ListTile(
                onTap: () => _openTransactionReceiptModal(item),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _op(_brandBlue, 0.15),
                    borderRadius: BorderRadius.circular(_kRadiusAction),
                  ),
                  child: Icon(
                    (item['icon'] as IconData?) ?? AppIcons.receipt,
                    color: _brandBlue,
                    size: 18,
                  ),
                ),
                title: Text(
                  item['judul'] ?? 'Transaksi',
                  style: _tsUI(14, FontWeight.w600, _p.textPrimary),
                ),
                subtitle: Text(
                  '${item['tanggal']} • ${item['kategori']}',
                  style: _tsUI(12, FontWeight.w500, _p.textSecondary),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isPemasukan ? '+' : '-'}$formattedNominal',
                      style: _tsNum(14, FontWeight.w700, isPemasukan ? _incomeGreen : _p.textPrimary, ls: -0.2),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: _p.surfaceElevated,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(item['badge'] ?? 'BCA', style: _tsUI(10, FontWeight.w700, _p.textSecondary, ls: 0.02)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSemuaKantongSubPage() {
    return SizedBox.expand(
      key: const ValueKey('SemuaKantongSubPage'),
      child: Container(
        color: _p.baseBg,
        child: Column(
          children: [
            Container(
              color: _p.headerBg,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _handleBackPress,
                    icon: const Icon(AppIcons.arrowLeft, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Text('Semua Kantong Keuangan', style: _tsUI(18, FontWeight.w800, Colors.white)),
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
                      label: Text('Tambah Kantong Baru', style: _tsUI(13, FontWeight.w700, _brandBlue)),
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
      ),
    );
  }

  Widget _buildSubPageWalletTile(String title, String badge, Color badgeBg, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(_kPadCard),
      decoration: BoxDecoration(
        color: _p.surfaceCard,
        borderRadius: BorderRadius.circular(_kRadiusCard),
        border: Border.all(color: _p.border, width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
            child: Text(badge, style: _tsUI(10, FontWeight.w800, Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _tsUI(12, FontWeight.w500, _p.textSecondary)),
                const SizedBox(height: 2),
                Text(
                  _isSaldoVisible ? amount : 'Rp ••••••••',
                  style: _tsNum(14, FontWeight.w700, _p.textPrimary, ls: -0.3),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openPengaturanKantongBottomSheet(context, title),
            icon: Icon(AppIcons.moreVertical, size: 18, color: _p.textSecondary),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// COLLAPSING HEADER DELEGATE
// =============================================================================
class _CollapsingHeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isSaldoVisible;
  final String rawSaldo;
  final VoidCallback onToggleSaldo;
  final _Palette palette;
  final VoidCallback onTapProfile;
  final VoidCallback onTapNotification;
  final bool hasUnreadNotification;

  const _CollapsingHeaderDelegate({
    required this.isSaldoVisible,
    required this.rawSaldo,
    required this.onToggleSaldo,
    required this.palette,
    required this.onTapProfile,
    required this.onTapNotification,
    required this.hasUnreadNotification,
  });

  @override
  double get minExtent => 56.0;

  @override
  double get maxExtent => 175.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    final double expandedOpacity = (1.0 - (progress * 2.2)).clamp(0.0, 1.0);
    final double collapsedOpacity = ((progress - 0.25) * 1.8).clamp(0.0, 1.0);
    final double iconScale = 1.0 - (progress * 0.12);

    return Container(
      decoration: BoxDecoration(
        color: palette.headerBg,
        border: progress >= 0.95
            ? Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 1.0))
            : null,
      ),
      child: Stack(
        children: [
          // Expanded State (Awal sebelum di-scroll)
          Positioned.fill(
            child: Opacity(
              opacity: expandedOpacity,
              child: Transform.translate(
                offset: Offset(0, -shrinkOffset * 0.5),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: onTapProfile,
                            borderRadius: BorderRadius.circular(18),
                            child: Transform.scale(
                              scale: iconScale,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(AppIcons.user, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                          Text(
                            'MyKas',
                            style: _tsUI(18, FontWeight.w800, Colors.white, ls: -0.01),
                          ),
                          InkWell(
                            onTap: onTapNotification,
                            borderRadius: BorderRadius.circular(18),
                            child: Transform.scale(
                              scale: iconScale,
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(AppIcons.bell, color: Colors.white, size: 18),
                                  ),
                                  if (hasUnreadNotification)
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
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            'Total Saldo',
                            style: _tsUI(12, FontWeight.w500, Colors.white.withOpacity(0.9)),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: onToggleSaldo,
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                isSaldoVisible ? AppIcons.eye : AppIcons.eyeOff,
                                color: Colors.white.withOpacity(0.9),
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isSaldoVisible ? rawSaldo : 'Rp ••••••••',
                        style: _tsNum(32, FontWeight.w800, Colors.white, ls: -0.02),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Diperbarui 09:41 WIB',
                        style: _tsUI(12, FontWeight.w500, Colors.white.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Collapsed State (Saat digulir, mempertahankan Ikon Notifikasi di kanan & transisi mulus)
          Positioned.fill(
            child: Opacity(
              opacity: collapsedOpacity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Kiri: Sapaan Halo Irwan bergeser halus dari profil
                    InkWell(
                      onTap: onTapProfile,
                      borderRadius: BorderRadius.circular(18),
                      child: Transform.translate(
                        offset: Offset(18 * (1.0 - collapsedOpacity), 0),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(AppIcons.user, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo,',
                                  style: _tsUI(12, FontWeight.w500, Colors.white.withOpacity(0.8)),
                                ),
                                Text(
                                  'Irwan',
                                  style: _tsUI(14, FontWeight.w600, Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Kanan: Dual-Tier Saldo berdampingan dengan Ikon Notifikasi aktif
                    Row(
                      children: [
                        Transform.translate(
                          offset: Offset(-18 * (1.0 - collapsedOpacity), 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Total Saldo',
                                style: _tsUI(11, FontWeight.w500, Colors.white.withOpacity(0.8)),
                              ),
                              Text(
                                isSaldoVisible ? rawSaldo : 'Rp ••••••',
                                style: _tsNum(13, FontWeight.w700, Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: onTapNotification,
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(AppIcons.bell, color: Colors.white, size: 18),
                              ),
                              if (hasUnreadNotification)
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CollapsingHeaderDelegate oldDelegate) {
    return oldDelegate.isSaldoVisible != isSaldoVisible ||
        oldDelegate.rawSaldo != rawSaldo ||
        oldDelegate.palette != palette ||
        oldDelegate.hasUnreadNotification != hasUnreadNotification;
  }
}

// =============================================================================
// FORM TAMBAH AKUN CONTENT
// =============================================================================
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
        color: p.surfaceCard,
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
                color: p.textMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tambah Kantong Keuangan', style: _tsUI(17, FontWeight.w800, p.textPrimary)),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(AppIcons.x, size: 18, color: p.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _jenisKantong,
            dropdownColor: p.surfaceCard,
            decoration: InputDecoration(
              labelText: 'Jenis Kantong',
              filled: true,
              fillColor: p.surfaceElevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            items: ['Bank', 'E-Wallet', 'Tunai', 'Investasi']
                .map((e) => DropdownMenuItem(value: e, child: Text(e, style: _tsUI(13, FontWeight.w500, p.textPrimary))))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _jenisKantong = val);
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _namaCtrl,
            style: _tsUI(13, FontWeight.w500, p.textPrimary),
            decoration: InputDecoration(
              labelText: 'Nama Kantong / Akun',
              hintText: 'Contoh: Mandiri Utama / GoPay',
              filled: true,
              fillColor: p.surfaceElevated,
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
            style: _tsNum(13, FontWeight.w500, p.textPrimary),
            decoration: InputDecoration(
              labelText: 'Saldo Awal (Rp)',
              hintText: 'Contoh: 1000000',
              filled: true,
              fillColor: p.surfaceElevated,
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
                    content: Text('Kantong berhasil ditambahkan!', style: _tsUI(13, FontWeight.w600, Colors.white)),
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
              child: Text('Simpan Kantong', style: _tsUI(13, FontWeight.w700, Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
