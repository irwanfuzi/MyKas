import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// =============================================================================
// DESIGN TOKENS
// =============================================================================
const double _kMaxWidth = 480; // layout selalu ringkas ala aplikasi mobile
const double _kRadiusCard = 20;
const double _kRadiusInner = 14;
const double _kPadCard = 16;

const Color _brandBlue = Color(0xFF2563EB);
const Color _incomeGreen = Color(0xFF10B981);
const Color _expenseRed = Color(0xFFEF4444);
const Color _honeyGold = Color(0xFFF59E0B);
const Color _accentPurple = Color(0xFF8B5CF6);
const Color _slate = Color(0xFF94A3B8);

const List<String> _months = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

/// Skala tipografi tunggal: ukuran terkecil 11, supaya tetap terbaca.
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

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _rp(int v) {
  final s = v.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return '${v < 0 ? '-' : ''}Rp $b';
}

String _rpJt(int v) {
  final m = v / 1000000;
  final t = m == m.roundToDouble()
      ? m.toStringAsFixed(0)
      : m.toStringAsFixed(1).replaceAll('.', ',');
  return 'Rp $t jt';
}

String _mask(bool hide, int v) => hide ? 'Rp ••••••' : _rp(v);
String _maskJt(bool hide, int v) => hide ? 'Rp •••' : _rpJt(v);

String _fmtRange(DateTimeRange r) {
  final s = r.start;
  final e = r.end;
  if (s.year == e.year && s.month == e.month) {
    return '${s.day} – ${e.day} ${_months[s.month - 1]} ${e.year}';
  }
  if (s.year == e.year) {
    return '${s.day} ${_months[s.month - 1]} – ${e.day} ${_months[e.month - 1]} ${e.year}';
  }
  return '${s.day} ${_months[s.month - 1]} ${s.year} – ${e.day} ${_months[e.month - 1]} ${e.year}';
}

String _fmtDate(DateTime d) => '${d.day} ${_months[d.month - 1].substring(0, 3)} ${d.year}';

Color _ratioColor(double r) {
  if (r >= 0.9) return _expenseRed;
  if (r >= 0.75) return _honeyGold;
  return _brandBlue;
}

String _ratioLabel(double r) => r >= 0.9 ? 'Kritis' : (r >= 0.75 ? 'Waspada' : 'Aman');

Color _ratioStatusColor(double r) =>
    r >= 0.9 ? _expenseRed : (r >= 0.75 ? _honeyGold : _incomeGreen);

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
      bg: d ? const Color(0xFF0F172A) : const Color(0xFFF5F7FB),
      surface: d ? const Color(0xFF1E293B) : Colors.white,
      surfaceAlt: d ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      border: t.colorScheme.outline.withOpacity(d ? 0.35 : 0.10),
      text: t.colorScheme.onSurface,
      muted: t.colorScheme.onSurfaceVariant,
      track: d ? Colors.white10 : const Color(0xFFE2E8F0),
    );
  }
}

// =============================================================================
// DATA CONTOH (ganti dengan data asli / summaryData)
// =============================================================================
class _Bar {
  final String label;
  final int income;
  final int expense;
  const _Bar(this.label, this.income, this.expense);
}

class _Cat {
  final String name;
  final int amount;
  final Color color;
  final IconData icon;
  const _Cat(this.name, this.amount, this.color, this.icon);
}

class _BudgetItem {
  final String name;
  final int used;
  final int limit;
  final IconData icon;
  const _BudgetItem(this.name, this.used, this.limit, this.icon);
}

class _Txn {
  final String title;
  final String category;
  final IconData icon;
  final Color color;
  final String date;
  final int amount;
  const _Txn(this.title, this.category, this.icon, this.color, this.date, this.amount);
}

class _Contribution {
  final String title;
  final DateTime date;
  final int amount;
  const _Contribution(this.title, this.date, this.amount);
}

const int _kIncome = 8000000;
const int _kExpense = 5200000;
const int _kBudgetLimit = 5000000;
const int _kBudgetUsed = 3500000;
const int _kGoalTarget = 10000000;
const int _kFoodLastMonth = 1580000;

const List<_Cat> _kExpenseCats = [
  _Cat('Makanan', 1820000, Color(0xFFF97316), Icons.restaurant_rounded),
  _Cat('Belanja', 1300000, Color(0xFF8B5CF6), Icons.shopping_bag_outlined),
  _Cat('Tagihan', 1040000, Color(0xFF3B82F6), Icons.receipt_long_outlined),
  _Cat('Lainnya', 1040000, _slate, Icons.more_horiz_rounded),
];

const List<_BudgetItem> _kBudgetItems = [
  _BudgetItem('Makanan', 1820000, 2200000, Icons.restaurant_rounded),
  _BudgetItem('Belanja', 1300000, 1800000, Icons.shopping_bag_outlined),
  _BudgetItem('Transportasi', 380000, 1000000, Icons.directions_bus_outlined),
];

const List<_Txn> _kTxns = [
  _Txn('Belanja bulanan', 'Belanja', Icons.shopping_bag_outlined, Color(0xFF8B5CF6), '12 Okt', 850000),
  _Txn('Listrik & internet', 'Tagihan', Icons.receipt_long_outlined, Color(0xFF3B82F6), '5 Okt', 640000),
  _Txn('Makan malam keluarga', 'Makanan', Icons.restaurant_rounded, Color(0xFFF97316), '9 Okt', 420000),
  _Txn('Top up e-wallet', 'Lainnya', Icons.more_horiz_rounded, _slate, '14 Okt', 400000),
];

const Map<String, List<_Bar>> _kCashFlowData = {
  'Bulan Ini': [
    _Bar('Mgg 1', 2400000, 1400000),
    _Bar('Mgg 2', 1500000, 1000000),
    _Bar('Mgg 3', 1700000, 900000),
    _Bar('Mgg 4', 1100000, 800000),
    _Bar('Mgg 5', 1300000, 1100000),
  ],
  '3 Bulan': [
    _Bar('Agu', 7000000, 5000000),
    _Bar('Sep', 7500000, 5600000),
    _Bar('Okt', 8000000, 5200000),
  ],
  'Tahun Ini': [
    _Bar('Jan', 6800000, 5400000),
    _Bar('Feb', 7000000, 5500000),
    _Bar('Mar', 7200000, 5600000),
    _Bar('Apr', 7000000, 5800000),
    _Bar('Mei', 7400000, 5400000),
    _Bar('Jun', 7500000, 5700000),
    _Bar('Jul', 7600000, 5500000),
    _Bar('Agu', 7000000, 5000000),
    _Bar('Sep', 7500000, 5600000),
    _Bar('Okt', 8000000, 5200000),
  ],
};

// =============================================================================
// KOMPONEN BERSAMA
// =============================================================================
class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;

  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(_kPadCard),
    this.color,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    final radius = BorderRadius.circular(_kRadiusCard);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: p.isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0D0F172A),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: color ?? p.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: borderColor ?? p.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const _SectionTitle(this.title, {this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: _ts(16, FontWeight.w700, p.text, ls: -0.2)),
          ),
          if (action != null)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(action!, style: _ts(13, FontWeight.w600, _brandBlue)),
                    const Icon(Icons.chevron_right_rounded, size: 18, color: _brandBlue),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _Bubble(this.icon, this.color, {this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _op(color, 0.14),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }
}

class _Progress extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const _Progress(this.value, this.color, {this.height = 8});

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: Container(
            height: height,
            color: p.track,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: v.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(height),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _op(color, 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: _ts(
          12,
          FontWeight.w700,
          color == _honeyGold ? const Color(0xFFB45309) : color,
        ),
      ),
    );
  }
}

class _DonutView extends StatelessWidget {
  final List<DonutSection> sections;
  final Widget center;
  final double? total;
  final double size;
  final double stroke;

  const _DonutView({
    required this.sections,
    required this.center,
    this.total,
    this.size = 92,
    this.stroke = 10,
  });

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) {
          return CustomPaint(
            painter: DonutChartPainter(
              sections: sections,
              backgroundColor: p.track,
              total: total,
              progress: t,
              strokeWidth: stroke,
            ),
            child: child,
          );
        },
        child: Center(child: center),
      ),
    );
  }
}

/// Halaman detail (subpage) dengan lebar terbatas dan CTA bawah opsional.
class _PageShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? bottom;

  const _PageShell({
    required this.title,
    required this.children,
    this.subtitle,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      appBar: AppBar(
        backgroundColor: p.bg,
        foregroundColor: p.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: _ts(18, FontWeight.w700, p.text, ls: -0.3)),
            if (subtitle != null)
              Text(subtitle!, style: _ts(12, FontWeight.w500, p.muted)),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kMaxWidth),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              physics: const ClampingScrollPhysics(),
              children: children,
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _kMaxWidth),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: bottom,
                  ),
                ),
              ),
            ),
    );
  }
}

Future<T?> _push<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(MaterialPageRoute<T>(builder: (_) => page));
}

Future<T?> _showSheet<T>(
  BuildContext context,
  Widget Function(BuildContext ctx, StateSetter setSheet) builder,
) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: _kMaxWidth),
    builder: (ctx) => StatefulBuilder(builder: builder),
  );
}

// =============================================================================
// SCREEN
// =============================================================================
class AnalisisScreen extends StatefulWidget {
  final Map<String, dynamic>? summaryData;

  /// Dipanggil saat pengguna menekan "Buat PDF". Sambungkan ke paket
  /// `pdf` + `printing` (atau layanan backend) di aplikasi Anda.
  final Future<void> Function(DateTimeRange range)? onExportPdf;

  /// Opsional: simpan/bagikan CSV sebagai file. Bila null, CSV disalin ke clipboard.
  final Future<void> Function(String csv, DateTimeRange range)? onExportCsv;

  /// Dipanggil dari empty state ("Catat Transaksi").
  final VoidCallback? onAddTransaction;

  const AnalisisScreen({
    super.key,
    this.summaryData,
    this.onExportPdf,
    this.onExportCsv,
    this.onAddTransaction,
  });

  @override
  State<AnalisisScreen> createState() => _AnalisisScreenState();
}

class _AnalisisScreenState extends State<AnalisisScreen> {
  // ---- Periode
  String? _selectedSegment = 'Bulan';
  late DateTimeRange _range = _rangeFor('Bulan');

  // ---- Cash flow
  String _cashFlowFilter = 'Bulan Ini';
  int? _selectedBar;

  // ---- Pengaturan tampilan
  bool _hideAmounts = false;
  bool _showInsight = true;
  bool _showGoals = true;

  // ---- Data yang bisa berubah
  int _goalSaved = 6000000;

  // Toggle empty state
  final bool _isEmptyState = false;

  late _Palette _p;

  String _money(int v) => _mask(_hideAmounts, v);
  String _moneyJt(int v) => _maskJt(_hideAmounts, v);

  // ---------------------------------------------------------------------------
  // PERIODE
  // ---------------------------------------------------------------------------
  DateTimeRange _rangeFor(String segment) {
    final now = DateTime.now();
    switch (segment) {
      case 'Minggu':
        final start = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        return DateTimeRange(start: start, end: start.add(const Duration(days: 6)));
      case 'Tahun':
        return DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year, 12, 31),
        );
      default:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0),
        );
    }
  }

  String? _matchSegment(DateTimeRange r) {
    for (final s in const ['Minggu', 'Bulan', 'Tahun']) {
      final x = _rangeFor(s);
      if (_sameDay(x.start, r.start) && _sameDay(x.end, r.end)) return s;
    }
    return null;
  }

  void _onSegmentChanged(String segment) {
    setState(() {
      _selectedSegment = segment;
      _range = _rangeFor(segment);
    });
  }

  Future<void> _selectDateRangePicker() async {
    final picked = await showModalBottomSheet<DateTimeRange>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: _kMaxWidth),
      builder: (_) => _RangeSheet(
        p: _p,
        initial: _range,
        firstDate: DateTime(2020),
        lastDate: DateTime(DateTime.now().year + 1, 12, 31),
      ),
    );

    if (picked != null && mounted) {
      setState(() {
        _range = picked;
        _selectedSegment = _matchSegment(picked);
      });
    }
  }

  void _showNotification(String title) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(title, style: _ts(13, FontWeight.w600, Colors.white)),
        backgroundColor: _brandBlue,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // NAVIGASI (subpage)
  // ---------------------------------------------------------------------------
  void _openExpense() =>
      _push<void>(context, _ExpensePage(hide: _hideAmounts, range: _range));

  void _openBudget() => _push<void>(context, _BudgetPage(hide: _hideAmounts));

  void _openGoal() => _push<void>(
        context,
        _GoalPage(
          hide: _hideAmounts,
          saved: _goalSaved,
          onChanged: (v) => setState(() => _goalSaved = v),
        ),
      );

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    _p = _Palette.of(context);

    return Scaffold(
      backgroundColor: _p.bg,
      appBar: AppBar(
        backgroundColor: _p.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Text('Analisis', style: _ts(24, FontWeight.w700, _p.text, ls: -0.6)),
        actions: [
          IconButton(
            tooltip: 'Pengaturan analisis',
            icon: Icon(Icons.tune_rounded, color: _p.text, size: 22),
            onPressed: _showSettingsSheet,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kMaxWidth),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              physics: const ClampingScrollPhysics(),
              children: [
                _buildSegmentedFilter(),
                const SizedBox(height: 10),
                _buildDateRangeSelector(),
                const SizedBox(height: 18),
                if (_isEmptyState)
                  _buildEmptyState()
                else ...[
                  _buildFinancialSummaryHero(),
                  const SizedBox(height: 20),
                  _buildQuickActions(),
                  const SizedBox(height: 28),
                  const _SectionTitle('Arus Kas'),
                  _buildCashFlowCard(),
                  const SizedBox(height: 28),
                  _SectionTitle('Pengeluaran', action: 'Lihat semua', onAction: _openExpense),
                  _buildExpenseCard(),
                  const SizedBox(height: 28),
                  _SectionTitle('Anggaran', action: 'Detail', onAction: _openBudget),
                  _buildBudgetCard(),
                  const SizedBox(height: 28),
                  if (_showGoals) ...[
                    _SectionTitle('Tujuan', action: 'Detail', onAction: _openGoal),
                    _buildGoalCard(),
                    const SizedBox(height: 28),
                  ],
                  if (_showInsight) ...[
                    const _SectionTitle('Insight'),
                    _buildInsightCard(),
                    const SizedBox(height: 28),
                  ],
                  const _SectionTitle('Laporan'),
                  _buildReportTile(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // FILTER PERIODE
  // ===========================================================================
  Widget _buildSegmentedFilter() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _p.isDark ? _p.surface : const Color(0xFFE9EEF6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _p.border),
      ),
      child: Row(
        children: ['Minggu', 'Bulan', 'Tahun'].map((segment) {
          final selected = _selectedSegment == segment;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _onSegmentChanged(segment),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? _brandBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: _op(_brandBlue, 0.30),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  segment,
                  style: _ts(
                    13.5,
                    selected ? FontWeight.w700 : FontWeight.w500,
                    selected ? Colors.white : _p.muted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: _selectDateRangePicker,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_rounded, size: 14, color: _p.muted),
              const SizedBox(width: 8),
              Text(_fmtRange(_range), style: _ts(13, FontWeight.w600, _p.text)),
              const SizedBox(width: 2),
              Icon(Icons.expand_more_rounded, size: 18, color: _p.muted),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HERO (datar, dengan sparkline)
  // ===========================================================================
  List<double> _netTrend() {
    var acc = 0;
    return _kCashFlowData['Bulan Ini']!.map((b) {
      acc += b.income - b.expense;
      return acc.toDouble();
    }).toList();
  }

  Widget _buildFinancialSummaryHero() {
    final net = _kIncome - _kExpense;
    final divider = Colors.white.withOpacity(0.18);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_kRadiusCard + 4),
        gradient: LinearGradient(
          colors: _p.isDark
              ? const [Color(0xFF1E3A8A), Color(0xFF2563EB)]
              : const [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _op(_brandBlue, _p.isDark ? 0.20 : 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Arus Kas Bersih',
                style: _ts(13, FontWeight.w500, Colors.white.withOpacity(0.85)),
              ),
              const SizedBox(width: 4),
              InkResponse(
                radius: 18,
                onTap: _showNetInfoSheet,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_up_rounded, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text('12%', style: _ts(12, FontWeight.w700, Colors.white)),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: _hideAmounts ? 'Tampilkan nominal' : 'Sembunyikan nominal',
                visualDensity: VisualDensity.compact,
                onPressed: () => setState(() => _hideAmounts = !_hideAmounts),
                icon: Icon(
                  _hideAmounts
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _money(net),
                    style: _ts(28, FontWeight.w800, Colors.white, ls: -0.8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 84,
                height: 34,
                child: CustomPaint(
                  painter: _SparklinePainter(values: _netTrend(), color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _hideAmounts
                ? 'Hemat dibanding bulan lalu'
                : 'Hemat Rp 600.000 dibanding bulan lalu',
            style: _ts(12.5, FontWeight.w500, Colors.white.withOpacity(0.8)),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: divider),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _heroMetric(
                  title: 'Pemasukan',
                  amount: _kIncome,
                  icon: Icons.arrow_upward_rounded,
                  iconColor: const Color(0xFF6EE7B7),
                ),
              ),
              Container(width: 1, height: 36, color: divider),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: _heroMetric(
                    title: 'Pengeluaran',
                    amount: _kExpense,
                    icon: Icons.arrow_downward_rounded,
                    iconColor: const Color(0xFFFCA5A5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroMetric({
    required String title,
    required int amount,
    required IconData icon,
    required Color iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _ts(12, FontWeight.w500, Colors.white.withOpacity(0.8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            _money(amount),
            style: _ts(16, FontWeight.w700, Colors.white, ls: -0.2),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // AKSI CEPAT
  // ===========================================================================
  Widget _buildQuickActions() {
    return Row(
      children: [
        _quick(Icons.pie_chart_outline_rounded, 'Pengeluaran', _accentPurple, _openExpense),
        _quick(Icons.track_changes_rounded, 'Anggaran', _brandBlue, _openBudget),
        _quick(Icons.emoji_events_outlined, 'Tujuan', _honeyGold, _openGoal),
        _quick(Icons.receipt_long_outlined, 'Laporan', _incomeGreen,
            () => _showExportSheet('PDF')),
      ],
    );
  }

  Widget _quick(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              _Bubble(icon, color, size: 52),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _ts(12, FontWeight.w600, _p.text),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // ARUS KAS
  // ===========================================================================
  Widget _buildCashFlowCard() {
    final data = _kCashFlowData[_cashFlowFilter] ?? _kCashFlowData['Bulan Ini']!;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterTabs(),
          const SizedBox(height: 14),
          _buildChartReadout(data),
          const SizedBox(height: 14),
          _buildCashFlowBarVisual(data),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartLegend('Pemasukan', _incomeGreen),
              const SizedBox(width: 20),
              _buildChartLegend('Pengeluaran', _expenseRed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    const keys = ['Bulan Ini', '3 Bulan', 'Tahun Ini'];
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _p.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: keys.map((k) {
          final selected = _cashFlowFilter == k;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() {
                _cashFlowFilter = k;
                _selectedBar = null;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? _p.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: selected && !_p.isDark
                      ? const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  k,
                  style: _ts(
                    12.5,
                    selected ? FontWeight.w700 : FontWeight.w500,
                    selected ? _p.text : _p.muted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartReadout(List<_Bar> data) {
    final idx = _selectedBar;
    final b = (idx != null && idx < data.length) ? data[idx] : null;

    return SizedBox(
      height: 24,
      child: b == null
          ? Row(
              children: [
                Icon(Icons.touch_app_outlined, size: 15, color: _p.muted),
                const SizedBox(width: 6),
                Text(
                  'Ketuk batang untuk melihat detail',
                  style: _ts(12.5, FontWeight.w500, _p.muted),
                ),
              ],
            )
          : FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(b.label, style: _ts(13, FontWeight.w700, _p.text)),
                  const SizedBox(width: 14),
                  _buildChartLegend(_money(b.income), _incomeGreen, strong: true),
                  const SizedBox(width: 12),
                  _buildChartLegend(_money(b.expense), _expenseRed, strong: true),
                ],
              ),
            ),
    );
  }

  Widget _buildChartLegend(String label, Color color, {bool strong = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: strong
              ? _ts(12.5, FontWeight.w700, _p.text)
              : _ts(12, FontWeight.w500, _p.muted),
        ),
      ],
    );
  }

  Widget _chartBar(double height, Color color, double width) {
    return Container(
      width: width,
      height: max(0, height),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(width / 2),
          bottom: const Radius.circular(2),
        ),
      ),
    );
  }

  Widget _buildCashFlowBarVisual(List<_Bar> data) {
    const chartHeight = 140.0;
    const labelArea = 26.0;
    const barMax = chartHeight - labelArea - 4;
    final barW = data.length > 6 ? 6.0 : 10.0;
    final maxV = data.fold<int>(0, (m, b) => max(m, max(b.income, b.expense)));

    return SizedBox(
      height: chartHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: labelArea),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  4,
                  (_) => Container(height: 1, color: _op(_p.muted, 0.12)),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              key: ValueKey(_cashFlowFilter),
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, t, _) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(data.length, (i) {
                    final b = data[i];
                    final dim = _selectedBar != null && _selectedBar != i;
                    final selected = _selectedBar == i;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _selectedBar = selected ? null : i),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: dim ? 0.35 : 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _chartBar(barMax * (b.income / maxV) * t, _incomeGreen, barW),
                                  const SizedBox(width: 3),
                                  _chartBar(barMax * (b.expense / maxV) * t, _expenseRed, barW),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 16,
                                child: Text(
                                  b.label,
                                  maxLines: 1,
                                  style: _ts(
                                    11,
                                    selected ? FontWeight.w700 : FontWeight.w500,
                                    selected ? _p.text : _p.muted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // KARTU RINGKAS (tap -> subpage)
  // ===========================================================================
  Widget _buildExpenseCard() {
    return _Card(
      onTap: _openExpense,
      child: Row(
        children: [
          _DonutView(
            size: 92,
            sections: _kExpenseCats
                .map((c) => DonutSection(value: c.amount.toDouble(), color: c.color))
                .toList(),
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total', style: _ts(11, FontWeight.w500, _p.muted)),
                Text(
                  _moneyJt(_kExpense),
                  style: _ts(12.5, FontWeight.w800, _p.text),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: _kExpenseCats.map((c) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: c.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          c.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _ts(13, FontWeight.w500, _p.text),
                        ),
                      ),
                      Text(
                        '${(c.amount / _kExpense * 100).round()}%',
                        style: _ts(13, FontWeight.w700, _p.text),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard() {
    final ratio = _kBudgetUsed / _kBudgetLimit;
    final left = _kBudgetLimit - _kBudgetUsed;

    return _Card(
      onTap: _openBudget,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: _moneyJt(_kBudgetUsed),
                        style: _ts(20, FontWeight.w800, _p.text, ls: -0.4),
                      ),
                      TextSpan(
                        text: '  dari ${_moneyJt(_kBudgetLimit)}',
                        style: _ts(13, FontWeight.w500, _p.muted),
                      ),
                    ],
                  ),
                ),
              ),
              _StatusChip(_ratioLabel(ratio), _ratioStatusColor(ratio)),
            ],
          ),
          const SizedBox(height: 14),
          _Progress(ratio, _ratioColor(ratio), height: 8),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sisa ${_moneyJt(left)}', style: _ts(12.5, FontWeight.w600, _p.text)),
              Text('${(ratio * 100).round()}% terpakai',
                  style: _ts(12.5, FontWeight.w500, _p.muted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard() {
    final ratio = _goalSaved / _kGoalTarget;

    return _Card(
      onTap: _openGoal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _Bubble(Icons.flight_takeoff_rounded, _honeyGold, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dana Liburan', style: _ts(14, FontWeight.w700, _p.text)),
                    const SizedBox(height: 2),
                    Text(
                      '${_moneyJt(_goalSaved)} dari ${_moneyJt(_kGoalTarget)}',
                      style: _ts(12.5, FontWeight.w500, _p.muted),
                    ),
                  ],
                ),
              ),
              Text('${(ratio * 100).round()}%',
                  style: _ts(18, FontWeight.w800, _p.text, ls: -0.4)),
            ],
          ),
          const SizedBox(height: 14),
          _Progress(ratio, _honeyGold),
        ],
      ),
    );
  }

  Widget _buildInsightCard() {
    return _Card(
      color: _p.isDark ? const Color(0xFF1E1B4B) : const Color(0xFFF5F3FF),
      borderColor: _op(_accentPurple, 0.25),
      onTap: _showInsightSheet,
      child: Row(
        children: [
          const _Bubble(Icons.lightbulb_outline_rounded, _accentPurple, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengeluaran makanan naik 15% dibanding bulan lalu.',
                  style: _ts(14, FontWeight.w700, _p.text, height: 1.35),
                ),
                const SizedBox(height: 4),
                Text(
                  'Coba tekan pengeluaran kuliner minggu ini.',
                  style: _ts(12.5, FontWeight.w500, _p.muted, height: 1.35),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: 20, color: _p.muted),
        ],
      ),
    );
  }

  Widget _buildReportTile() {
    return _Card(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () => _showExportSheet('PDF'),
      child: Row(
        children: [
          const _Bubble(Icons.receipt_long_outlined, _brandBlue, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Laporan Keuangan', style: _ts(14, FontWeight.w700, _p.text)),
                const SizedBox(height: 2),
                Text('Unduh dalam format PDF atau CSV',
                    style: _ts(12.5, FontWeight.w500, _p.muted)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: 20, color: _p.muted),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return _Card(
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _op(_brandBlue, 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.analytics_outlined, size: 34, color: _brandBlue),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum Ada Transaksi Cukup',
            textAlign: TextAlign.center,
            style: _ts(17, FontWeight.w700, _p.text),
          ),
          const SizedBox(height: 8),
          Text(
            'Catat pemasukan dan pengeluaran secara rutin untuk melihat analisis grafik lengkap.',
            textAlign: TextAlign.center,
            style: _ts(13, FontWeight.w500, _p.muted, height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _brandBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 46),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.add_rounded, size: 20, color: Colors.white),
            label: Text('Catat Transaksi', style: _ts(13.5, FontWeight.w700, Colors.white)),
            onPressed: () {
              if (widget.onAddTransaction != null) {
                widget.onAddTransaction!();
              } else {
                _showNotification('Halaman pencatatan belum tersambung');
              }
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BOTTOM SHEET (aksi cepat & pilihan singkat)
  // ===========================================================================

  // ---- Pengaturan
  void _showSettingsSheet() {
    _showSheet<void>(context, (ctx, setSheet) {
      Widget row(String title, String sub, bool value, ValueChanged<bool> onChanged) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: _ts(14.5, FontWeight.w600, _p.text)),
                    const SizedBox(height: 2),
                    Text(sub, style: _ts(12.5, FontWeight.w500, _p.muted)),
                  ],
                ),
              ),
              Switch(
                value: value,
                activeTrackColor: _brandBlue,
                onChanged: (v) {
                  setState(() => onChanged(v));
                  setSheet(() {});
                },
              ),
            ],
          ),
        );
      }

      return _SheetFrame(
        p: _p,
        title: 'Pengaturan Analisis',
        subtitle: 'Atur apa yang tampil di layar ini',
        child: Column(
          children: [
            row('Sembunyikan nominal', 'Samarkan jumlah uang di layar', _hideAmounts,
                (v) => _hideAmounts = v),
            Divider(height: 1, color: _p.border),
            row('Tampilkan tujuan keuangan', 'Progres tabungan dan target', _showGoals,
                (v) => _showGoals = v),
            Divider(height: 1, color: _p.border),
            row('Tampilkan insight', 'Saran berdasarkan pola pengeluaran', _showInsight,
                (v) => _showInsight = v),
          ],
        ),
      );
    });
  }

  // ---- Info arus kas bersih
  void _showNetInfoSheet() {
    final net = _kIncome - _kExpense;
    _showSheet<void>(context, (ctx, setSheet) {
      Widget line(String label, String value, {bool bold = false, Color? color}) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: _ts(14, bold ? FontWeight.w700 : FontWeight.w500, _p.text)),
              Text(value,
                  style: _ts(14, bold ? FontWeight.w800 : FontWeight.w600, color ?? _p.text)),
            ],
          ),
        );
      }

      return _SheetFrame(
        p: _p,
        title: 'Arus Kas Bersih',
        subtitle: _fmtRange(_range),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selisih antara total uang masuk dan uang keluar pada periode yang dipilih. '
              'Nilai positif berarti kamu menyisakan uang.',
              style: _ts(13.5, FontWeight.w500, _p.muted, height: 1.5),
            ),
            const SizedBox(height: 12),
            line('Pemasukan', _money(_kIncome), color: _incomeGreen),
            line('Pengeluaran', '- ${_money(_kExpense)}', color: _expenseRed),
            Divider(height: 16, color: _p.border),
            line('Arus kas bersih', _money(net), bold: true),
          ],
        ),
      );
    });
  }

  // ---- Insight
  void _showInsightSheet() {
    final food = _kExpenseCats.first.amount;
    final diff = food - _kFoodLastMonth;
    final pct = (diff / _kFoodLastMonth * 100).round();

    _showSheet<void>(context, (ctx, setSheet) {
      Widget compare(String label, int value, double ratio, Color color) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: _ts(13.5, FontWeight.w600, _p.text)),
                  Text(_money(value), style: _ts(13.5, FontWeight.w700, _p.text)),
                ],
              ),
              const SizedBox(height: 8),
              _Progress(ratio, color),
            ],
          ),
        );
      }

      Widget tip(String text) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.check_circle_rounded, size: 18, color: _incomeGreen),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(text, style: _ts(13.5, FontWeight.w500, _p.text, height: 1.4)),
              ),
            ],
          ),
        );
      }

      return _SheetFrame(
        p: _p,
        title: 'Insight Makanan',
        subtitle: 'Naik $pct% (${_money(diff)}) dibanding bulan lalu',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            compare('Bulan lalu', _kFoodLastMonth, _kFoodLastMonth / food, _slate),
            compare('Bulan ini', food, 1, _expenseRed),
            const SizedBox(height: 10),
            Text('Saran untuk kamu', style: _ts(13, FontWeight.w700, _p.muted, ls: 0.2)),
            const SizedBox(height: 14),
            tip('Batasi makan di luar dan pesan antar, mulai dari minggu ini.'),
            tip('Siapkan bekal untuk hari kerja agar pengeluaran harian lebih stabil.'),
            tip('Samakan anggaran makanan dengan rata-rata bulan lalu.'),
          ],
        ),
      );
    });
  }

  // ---- Ekspor
  String _buildCsv() {
    final b = StringBuffer()
      ..writeln('Laporan Keuangan MyKas')
      ..writeln('Periode,"${_fmtRange(_range)}"')
      ..writeln()
      ..writeln('Ringkasan,Jumlah')
      ..writeln('Pemasukan,$_kIncome')
      ..writeln('Pengeluaran,$_kExpense')
      ..writeln('Arus Kas Bersih,${_kIncome - _kExpense}')
      ..writeln()
      ..writeln('Kategori,Jumlah,Persentase');
    for (final c in _kExpenseCats) {
      b.writeln('${c.name},${c.amount},${(c.amount / _kExpense * 100).round()}%');
    }
    return b.toString();
  }

  Future<void> _runExport(String fmt, BuildContext sheetCtx) async {
    if (fmt == 'CSV') {
      final csv = _buildCsv();
      Navigator.of(sheetCtx).pop();
      if (widget.onExportCsv != null) {
        await widget.onExportCsv!(csv, _range);
      } else {
        await Clipboard.setData(ClipboardData(text: csv));
        if (mounted) _showNotification('CSV disalin ke clipboard');
      }
    } else if (widget.onExportPdf != null) {
      Navigator.of(sheetCtx).pop();
      await widget.onExportPdf!(_range);
    } else {
      _showNotification('Ekspor PDF belum tersambung di aplikasi ini');
    }
  }

  void _showExportSheet(String initialFormat) {
    var fmt = initialFormat;
    _showSheet<void>(context, (ctx, setSheet) {
      Widget option(String value, IconData icon, String title, String sub) {
        final selected = fmt == value;
        return Expanded(
          child: Material(
            color: selected ? _op(_brandBlue, 0.10) : _p.surfaceAlt,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_kRadiusInner),
              side: BorderSide(
                color: selected ? _brandBlue : _p.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => setSheet(() => fmt = value),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 22, color: selected ? _brandBlue : _p.muted),
                    const SizedBox(height: 10),
                    Text(title, style: _ts(14, FontWeight.w700, _p.text)),
                    const SizedBox(height: 2),
                    Text(sub, style: _ts(12, FontWeight.w500, _p.muted)),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      Widget row(String label, String value, {bool bold = false}) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: _ts(13.5, bold ? FontWeight.w700 : FontWeight.w500, _p.text)),
              Text(value, style: _ts(13.5, bold ? FontWeight.w800 : FontWeight.w600, _p.text)),
            ],
          ),
        );
      }

      return _SheetFrame(
        p: _p,
        title: 'Ekspor Laporan',
        subtitle: _fmtRange(_range),
        footer: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _brandBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 50),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: Icon(
              fmt == 'CSV' ? Icons.copy_rounded : Icons.picture_as_pdf_outlined,
              size: 18,
              color: Colors.white,
            ),
            label: Text(
              fmt == 'CSV'
                  ? (widget.onExportCsv != null ? 'Simpan CSV' : 'Salin CSV')
                  : 'Buat PDF',
              style: _ts(14, FontWeight.w700, Colors.white),
            ),
            onPressed: () => _runExport(fmt, ctx),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                option('PDF', Icons.picture_as_pdf_outlined, 'PDF', 'Siap dicetak'),
                const SizedBox(width: 12),
                option('CSV', Icons.table_chart_outlined, 'CSV', 'Untuk spreadsheet'),
              ],
            ),
            const SizedBox(height: 22),
            Text('Isi laporan', style: _ts(13, FontWeight.w700, _p.muted, ls: 0.2)),
            const SizedBox(height: 8),
            row('Pemasukan', _rp(_kIncome)),
            row('Pengeluaran', _rp(_kExpense)),
            row('Arus kas bersih', _rp(_kIncome - _kExpense), bold: true),
            Divider(height: 20, color: _p.border),
            ..._kExpenseCats.map((c) => row(c.name, _rp(c.amount))),
          ],
        ),
      );
    });
  }
}

// =============================================================================
// SUBPAGE: RINCIAN PENGELUARAN
// =============================================================================
class _ExpensePage extends StatelessWidget {
  final bool hide;
  final DateTimeRange range;

  const _ExpensePage({required this.hide, required this.range});

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    final top = _kExpenseCats.reduce((a, b) => a.amount >= b.amount ? a : b);

    return _PageShell(
      title: 'Pengeluaran',
      subtitle: _fmtRange(range),
      children: [
        Center(
          child: Column(
            children: [
              Text('Total pengeluaran', style: _ts(13, FontWeight.w500, p.muted)),
              const SizedBox(height: 4),
              Text(
                _mask(hide, _kExpense),
                style: _ts(32, FontWeight.w800, p.text, ls: -1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: _DonutView(
            size: 168,
            stroke: 16,
            sections: _kExpenseCats
                .map((c) => DonutSection(value: c.amount.toDouble(), color: c.color))
                .toList(),
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(top.name, style: _ts(12, FontWeight.w500, p.muted)),
                Text(
                  '${(top.amount / _kExpense * 100).round()}%',
                  style: _ts(26, FontWeight.w800, p.text, ls: -0.6),
                ),
                Text('terbesar', style: _ts(11, FontWeight.w500, p.muted)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        const _SectionTitle('Kategori'),
        _Card(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 2),
          child: Column(
            children: _kExpenseCats.map((c) {
              final pct = c.amount / _kExpense;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Bubble(c.icon, c.color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(c.name, style: _ts(14, FontWeight.w600, p.text)),
                              Text(_mask(hide, c.amount),
                                  style: _ts(14, FontWeight.w700, p.text)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _Progress(pct, c.color, height: 6),
                          const SizedBox(height: 6),
                          Text(
                            '${(pct * 100).round()}% dari total pengeluaran',
                            style: _ts(12, FontWeight.w500, p.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 28),
        const _SectionTitle('Transaksi Terbesar'),
        _Card(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: [
              for (var i = 0; i < _kTxns.length; i++) ...[
                if (i > 0) Divider(height: 1, color: p.border),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      _Bubble(_kTxns[i].icon, _kTxns[i].color, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_kTxns[i].title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _ts(14, FontWeight.w600, p.text)),
                            const SizedBox(height: 2),
                            Text('${_kTxns[i].category} · ${_kTxns[i].date}',
                                style: _ts(12, FontWeight.w500, p.muted)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('- ${_mask(hide, _kTxns[i].amount)}',
                          style: _ts(14, FontWeight.w700, p.text)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// SUBPAGE: RINCIAN ANGGARAN
// =============================================================================
class _BudgetPage extends StatelessWidget {
  final bool hide;

  const _BudgetPage({required this.hide});

  Widget _stat(_Palette p, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: _ts(12, FontWeight.w500, p.muted)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: _ts(15, FontWeight.w800, p.text)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    final ratio = _kBudgetUsed / _kBudgetLimit;
    final percent = (ratio * 100).round();
    final left = _kBudgetLimit - _kBudgetUsed;

    final now = DateTime.now();
    final daysLeft = DateTime(now.year, now.month + 1, 0).day - now.day + 1;
    final perDay = left > 0 ? (left / daysLeft).floor() : 0;

    return _PageShell(
      title: 'Anggaran',
      subtitle: '${_months[now.month - 1]} ${now.year}',
      children: [
        Center(
          child: _DonutView(
            size: 168,
            stroke: 16,
            total: 100,
            sections: [DonutSection(value: percent.toDouble(), color: _ratioColor(ratio))],
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$percent%', style: _ts(30, FontWeight.w800, p.text, ls: -1)),
                Text('terpakai', style: _ts(12, FontWeight.w500, p.muted)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Center(child: _StatusChip(_ratioLabel(ratio), _ratioStatusColor(ratio))),
        const SizedBox(height: 24),
        _Card(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Row(
            children: [
              _stat(p, 'Terpakai', _maskJt(hide, _kBudgetUsed)),
              Container(width: 1, height: 32, color: p.border),
              _stat(p, 'Sisa', _maskJt(hide, left)),
              Container(width: 1, height: 32, color: p.border),
              _stat(p, 'Batas', _maskJt(hide, _kBudgetLimit)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Card(
          color: p.isDark ? _op(_brandBlue, 0.12) : const Color(0xFFEFF6FF),
          borderColor: _op(_brandBlue, 0.22),
          child: Row(
            children: [
              const _Bubble(Icons.tips_and_updates_outlined, _brandBlue, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: left > 0
                    ? Text.rich(
                        TextSpan(
                          style: _ts(13, FontWeight.w500, p.text, height: 1.45),
                          children: [
                            const TextSpan(text: 'Agar tetap aman, belanjakan maksimal '),
                            TextSpan(
                              text: '${_mask(hide, perDay)}/hari',
                              style: _ts(13, FontWeight.w800, p.text, height: 1.45),
                            ),
                            TextSpan(text: ' selama $daysLeft hari ke depan.'),
                          ],
                        ),
                      )
                    : Text(
                        'Anggaran sudah habis. Tahan pengeluaran sampai periode berikutnya.',
                        style: _ts(13, FontWeight.w500, p.text, height: 1.45),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const _SectionTitle('Per Kategori'),
        _Card(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 2),
          child: Column(
            children: _kBudgetItems.map((b) {
              final r = b.used / b.limit;
              final color = _ratioColor(r);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Bubble(b.icon, color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(b.name, style: _ts(14, FontWeight.w600, p.text)),
                              Text('${(r * 100).round()}%',
                                  style: _ts(14, FontWeight.w700, p.text)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _Progress(r, color, height: 6),
                          const SizedBox(height: 6),
                          Text(
                            '${_mask(hide, b.used)} dari ${_mask(hide, b.limit)}',
                            style: _ts(12, FontWeight.w500, p.muted),
                          ),
                        ],
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
}

// =============================================================================
// SUBPAGE: TUJUAN KEUANGAN (setoran lewat bottom sheet)
// =============================================================================
class _GoalPage extends StatefulWidget {
  final bool hide;
  final int saved;
  final ValueChanged<int> onChanged;

  const _GoalPage({
    required this.hide,
    required this.saved,
    required this.onChanged,
  });

  @override
  State<_GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<_GoalPage> {
  late int _saved = widget.saved;

  final List<_Contribution> _history = [
    _Contribution('Setoran bulanan', DateTime(2026, 10, 5), 2000000),
    _Contribution('Setoran bulanan', DateTime(2026, 9, 10), 2000000),
    _Contribution('Setoran awal', DateTime(2026, 8, 15), 2000000),
  ];

  Future<void> _addSavings() async {
    final remaining = _kGoalTarget - _saved;
    if (remaining <= 0) return;

    final amount = await _showSheet<int>(
      context,
      (ctx, _) => _AmountSheet(maxAmount: remaining),
    );

    if (amount != null && amount > 0 && mounted) {
      setState(() {
        _saved = min(_kGoalTarget, _saved + amount);
        _history.insert(0, _Contribution('Setoran tabungan', DateTime.now(), amount));
      });
      widget.onChanged(_saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    final hide = widget.hide;
    final ratio = _saved / _kGoalTarget;
    final done = _saved >= _kGoalTarget;

    return _PageShell(
      title: 'Dana Liburan',
      subtitle: 'Target ${_mask(hide, _kGoalTarget)}',
      bottom: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: _brandBlue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: p.track,
            minimumSize: const Size(0, 52),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          icon: Icon(done ? Icons.check_rounded : Icons.add_rounded, size: 20),
          label: Text(
            done ? 'Tujuan tercapai' : 'Tambah Tabungan',
            style: _ts(14.5, FontWeight.w700, done ? p.muted : Colors.white),
          ),
          onPressed: done ? null : _addSavings,
        ),
      ),
      children: [
        Row(
          children: [
            const _Bubble(Icons.flight_takeoff_rounded, _honeyGold, size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Terkumpul', style: _ts(13, FontWeight.w500, p.muted)),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _mask(hide, _saved),
                      style: _ts(28, FontWeight.w800, p.text, ls: -0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _Progress(ratio, _honeyGold, height: 12),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${(ratio * 100).round()}% dari target',
                style: _ts(13, FontWeight.w600, p.text)),
            Text(
              done ? 'Selesai' : 'Kurang ${_mask(hide, _kGoalTarget - _saved)}',
              style: _ts(13, FontWeight.w500, p.muted),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const _SectionTitle('Riwayat Setoran'),
        _Card(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: [
              for (var i = 0; i < _history.length; i++) ...[
                if (i > 0) Divider(height: 1, color: p.border),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      const _Bubble(Icons.south_west_rounded, _incomeGreen, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_history[i].title,
                                style: _ts(14, FontWeight.w600, p.text)),
                            const SizedBox(height: 2),
                            Text(_fmtDate(_history[i].date),
                                style: _ts(12, FontWeight.w500, p.muted)),
                          ],
                        ),
                      ),
                      Text(
                        '+ ${_mask(hide, _history[i].amount)}',
                        style: _ts(
                          14,
                          FontWeight.w700,
                          p.isDark ? _incomeGreen : const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AmountSheet extends StatefulWidget {
  final int maxAmount;

  const _AmountSheet({required this.maxAmount});

  @override
  State<_AmountSheet> createState() => _AmountSheetState();
}

class _AmountSheetState extends State<_AmountSheet> {
  final TextEditingController _c = TextEditingController();

  int get _value => int.tryParse(_c.text) ?? 0;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _setAmount(int v) {
    setState(() {
      _c.text = '$v';
      _c.selection = TextSelection.collapsed(offset: _c.text.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    final over = _value > widget.maxAmount;
    final canSave = _value > 0 && !over;

    Widget chip(String label, int amount) {
      return Material(
        color: _op(_honeyGold, 0.14),
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () => _setAmount(amount),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              label,
              style: _ts(
                13,
                FontWeight.w700,
                p.isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
              ),
            ),
          ),
        ),
      );
    }

    return _SheetFrame(
      p: p,
      title: 'Tambah Tabungan',
      subtitle: 'Maksimal ${_rp(widget.maxAmount)}',
      footer: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _brandBlue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: p.track,
            minimumSize: const Size(0, 50),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: canSave ? () => Navigator.of(context).pop(_value) : null,
          child: Text(
            'Simpan',
            style: _ts(14, FontWeight.w700, canSave ? Colors.white : p.muted),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _c,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            style: _ts(24, FontWeight.w800, p.text, ls: -0.4),
            decoration: InputDecoration(
              prefixText: 'Rp ',
              prefixStyle: _ts(24, FontWeight.w800, p.muted, ls: -0.4),
              hintText: '0',
              hintStyle: _ts(24, FontWeight.w800, _op(p.muted, 0.5), ls: -0.4),
              errorText: over ? 'Melebihi sisa target' : null,
              filled: true,
              fillColor: p.surfaceAlt,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (widget.maxAmount >= 100000) chip('Rp 100 rb', 100000),
              if (widget.maxAmount >= 500000) chip('Rp 500 rb', 500000),
              if (widget.maxAmount >= 1000000) chip('Rp 1 jt', 1000000),
              chip('Lunasi', widget.maxAmount),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SHEET FRAME (kerangka seragam untuk semua bottom sheet)
// =============================================================================
class _SheetFrame extends StatelessWidget {
  final _Palette p;
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? footer;

  const _SheetFrame({
    required this.p,
    required this.title,
    required this.child,
    this.subtitle,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Material(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: p.track,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 8, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: _ts(18, FontWeight.w700, p.text, ls: -0.3)),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(subtitle!, style: _ts(13, FontWeight.w500, p.muted)),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Tutup',
                      icon: Icon(Icons.close_rounded, color: p.muted),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: child,
                ),
              ),
              if (footer != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: footer,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// RANGE SHEET: pilih periode dengan preset + kalender
// =============================================================================
class _RangeSheet extends StatefulWidget {
  final _Palette p;
  final DateTimeRange initial;
  final DateTime firstDate;
  final DateTime lastDate;

  const _RangeSheet({
    required this.p,
    required this.initial,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_RangeSheet> createState() => _RangeSheetState();
}

class _RangeSheetState extends State<_RangeSheet> {
  DateTime? _start;
  DateTime? _end;
  late DateTime _month;

  _Palette get p => widget.p;

  @override
  void initState() {
    super.initState();
    _start = _dateOnly(widget.initial.start);
    _end = _dateOnly(widget.initial.end);
    _month = DateTime(_start!.year, _start!.month);
  }

  List<MapEntry<String, DateTimeRange>> _presets() {
    final now = _dateOnly(DateTime.now());
    return [
      MapEntry(
        '7 Hari Terakhir',
        DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now),
      ),
      MapEntry(
        'Bulan Ini',
        DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0),
        ),
      ),
      MapEntry(
        'Bulan Lalu',
        DateTimeRange(
          start: DateTime(now.year, now.month - 1, 1),
          end: DateTime(now.year, now.month, 0),
        ),
      ),
      MapEntry(
        '3 Bulan',
        DateTimeRange(
          start: DateTime(now.year, now.month - 2, 1),
          end: DateTime(now.year, now.month + 1, 0),
        ),
      ),
      MapEntry(
        'Tahun Ini',
        DateTimeRange(start: DateTime(now.year, 1, 1), end: DateTime(now.year, 12, 31)),
      ),
    ];
  }

  bool _isPreset(DateTimeRange r) =>
      _start != null &&
      _end != null &&
      _sameDay(r.start, _start!) &&
      _sameDay(r.end, _end!);

  void _applyPreset(DateTimeRange r) {
    setState(() {
      _start = r.start;
      _end = r.end;
      _month = DateTime(r.start.year, r.start.month);
    });
  }

  void _onDayTap(DateTime d) {
    setState(() {
      if (_start == null || _end != null) {
        _start = d;
        _end = null;
      } else if (d.isBefore(_start!)) {
        _end = _start;
        _start = d;
      } else {
        _end = d;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = _start;
    final e = _end ?? _start;
    final hasStart = s != null;
    final days = hasStart ? e!.difference(s).inDays + 1 : 0;
    final presets = _presets();

    final first = DateTime(widget.firstDate.year, widget.firstDate.month);
    final last = DateTime(widget.lastDate.year, widget.lastDate.month);
    final canPrev = !DateTime(_month.year, _month.month - 1).isBefore(first);
    final canNext = !DateTime(_month.year, _month.month + 1).isAfter(last);

    return _SheetFrame(
      p: p,
      title: 'Pilih Periode',
      subtitle: 'Pilih cepat atau ketuk tanggal mulai dan akhir',
      footer: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasStart
                      ? _fmtRange(DateTimeRange(start: s, end: e!))
                      : 'Pilih tanggal mulai',
                  maxLines: 2,
                  style: _ts(14, FontWeight.w700, p.text),
                ),
                const SizedBox(height: 2),
                Text(
                  hasStart ? '$days hari' : ' ',
                  style: _ts(12.5, FontWeight.w500, p.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _brandBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(120, 48),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: hasStart
                ? () => Navigator.of(context).pop(DateTimeRange(start: s, end: e!))
                : null,
            child: Text('Terapkan', style: _ts(14, FontWeight.w700, Colors.white)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: presets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final preset = presets[i];
                final selected = _isPreset(preset.value);
                return GestureDetector(
                  onTap: () => _applyPreset(preset.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? _brandBlue : p.surfaceAlt,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? _brandBlue : p.border),
                    ),
                    child: Text(
                      preset.key,
                      style: _ts(
                        13,
                        selected ? FontWeight.w700 : FontWeight.w600,
                        selected ? Colors.white : p.text,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                tooltip: 'Bulan sebelumnya',
                onPressed: canPrev
                    ? () => setState(
                          () => _month = DateTime(_month.year, _month.month - 1),
                        )
                    : null,
                icon: const Icon(Icons.chevron_left_rounded),
                color: p.text,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${_months[_month.month - 1]} ${_month.year}',
                    style: _ts(15, FontWeight.w700, p.text),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Bulan berikutnya',
                onPressed: canNext
                    ? () => setState(
                          () => _month = DateTime(_month.year, _month.month + 1),
                        )
                    : null,
                icon: const Icon(Icons.chevron_right_rounded),
                color: p.text,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: const ['S', 'S', 'R', 'K', 'J', 'S', 'M'].map((d) {
              return Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(d, style: _ts(12, FontWeight.w600, p.muted)),
                  ),
                ),
              );
            }).toList(),
          ),
          _buildGrid(),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final firstOfMonth = DateTime(_month.year, _month.month, 1);
    final lead = firstOfMonth.weekday - 1;
    final dim = DateTime(_month.year, _month.month + 1, 0).day;
    final weeks = (lead + dim + 6) ~/ 7;

    return Column(
      children: List.generate(weeks, (r) {
        return Row(
          children: List.generate(7, (c) {
            final dayNum = r * 7 + c - lead + 1;
            if (dayNum < 1 || dayNum > dim) {
              return const Expanded(child: SizedBox(height: 44));
            }
            return Expanded(
              child: _dayCell(DateTime(_month.year, _month.month, dayNum), c),
            );
          }),
        );
      }),
    );
  }

  Widget _dayCell(DateTime day, int col) {
    final disabled = day.isBefore(_dateOnly(widget.firstDate)) ||
        day.isAfter(_dateOnly(widget.lastDate));
    final s = _start;
    final e = _end;
    final isStart = s != null && _sameDay(day, s);
    final isEnd = e != null && _sameDay(day, e);
    final hasRange = s != null && e != null && !_sameDay(s, e);
    final inRange = hasRange && day.isAfter(s) && day.isBefore(e);
    final selected = isStart || isEnd;
    final today = _sameDay(day, DateTime.now());
    final band = _op(_brandBlue, p.isDark ? 0.22 : 0.12);

    final leftBand = hasRange && (inRange || isEnd);
    final rightBand = hasRange && (inRange || isStart);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled ? null : () => _onDayTap(day),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: leftBand ? band : null,
                      borderRadius: (inRange && col == 0)
                          ? const BorderRadius.horizontal(left: Radius.circular(18))
                          : null,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: rightBand ? band : null,
                      borderRadius: (inRange && col == 6)
                          ? const BorderRadius.horizontal(right: Radius.circular(18))
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? _brandBlue : null,
                border: (!selected && today)
                    ? Border.all(color: _brandBlue, width: 1.4)
                    : null,
              ),
              child: Text(
                '${day.day}',
                style: _ts(
                  13.5,
                  selected ? FontWeight.w700 : FontWeight.w500,
                  selected
                      ? Colors.white
                      : (disabled ? _op(p.muted, 0.4) : p.text),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SPARKLINE
// =============================================================================
class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;

  _SparklinePainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final minV = values.reduce(min);
    final maxV = values.reduce(max);
    final range = (maxV - minV) == 0 ? 1.0 : (maxV - minV);
    const pad = 4.0;

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final y = size.height - pad - ((values[i] - minV) / range) * (size.height - pad * 2);
      points.add(Offset(x, y));
    }

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final cur = points[i];
      final midX = (prev.dx + cur.dx) / 2;
      line.cubicTo(midX, prev.dy, midX, cur.dy, cur.dx, cur.dy);
    }

    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.30), color.withOpacity(0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(points.last, 3.2, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.values != values || old.color != color;
}

// =============================================================================
// REUSABLE DONUT CHART PAINTER
// =============================================================================
class DonutSection {
  final double value;
  final Color color;
  const DonutSection({required this.value, required this.color});
}

class DonutChartPainter extends CustomPainter {
  final List<DonutSection> sections;
  final Color backgroundColor;

  /// Nilai penuh lingkaran. Bila null, memakai jumlah seluruh section.
  /// Isi 100 untuk satu section persentase (mis. anggaran 70%).
  final double? total;

  /// 0..1, untuk animasi saat pertama tampil.
  final double progress;
  final double strokeWidth;

  DonutChartPainter({
    required this.sections,
    required this.backgroundColor,
    this.total,
    this.progress = 1,
    this.strokeWidth = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    final sum = sections.fold<double>(0, (s, e) => s + e.value);
    final denom = total ?? sum;
    if (denom <= 0) return;

    // Ujung bulat memanjang setengah stroke; inset agar antar-segmen tidak menempel.
    final cap = (strokeWidth / 2) / radius;
    final inset = cap + (sections.length > 1 ? 0.05 : 0.0);

    var start = -pi / 2;
    for (final section in sections) {
      final sweep = (section.value / denom) * 2 * pi * progress;
      final drawSweep = sweep - 2 * inset;
      if (drawSweep > 0) {
        canvas.drawArc(
          rect,
          start + inset,
          drawSweep,
          false,
          Paint()
            ..color = section.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round,
        );
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter old) {
    return old.progress != progress ||
        old.total != total ||
        old.strokeWidth != strokeWidth ||
        old.backgroundColor != backgroundColor ||
        old.sections != sections;
  }
}
