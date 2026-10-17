import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// =============================================================================
// DESIGN TOKENS (MYKAS FINTECH FLAT)
// =============================================================================
const double _kMaxWidth = 520;
const double _kRadiusCard = 22;
const double _kRadiusInner = 14;
const double _kPadCard = 16;

const Color _brandBlue = Color(0xFF2563EB); // Soft Royal Blue MyKas
const Color _incomeGreen = Color(0xFF10B981);
const Color _expenseRed = Color(0xFFEF4444);
const Color _honeyGold = Color(0xFFF59E0B);
const Color _accentPurple = Color(0xFF8B5CF6);
const Color _slate = Color(0xFF94A3B8);

const List<String> _months = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

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
      bg: d ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      surface: d ? const Color(0xFF1E293B) : Colors.white,
      surfaceAlt: d ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      border: t.colorScheme.outline.withOpacity(d ? 0.30 : 0.12),
      text: t.colorScheme.onSurface,
      muted: t.colorScheme.onSurfaceVariant,
      track: d ? Colors.white10 : const Color(0xFFE2E8F0),
    );
  }
}

// =============================================================================
// DATA MOCK
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
    _Bar('M1', 2400000, 1400000),
    _Bar('M2', 1500000, 1000000),
    _Bar('M3', 1700000, 900000),
    _Bar('M4', 1100000, 800000),
    _Bar('M5', 1300000, 1100000),
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
// KOMPONEN BASE
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
                  color: Color(0x0A0F172A),
                  blurRadius: 18,
                  offset: Offset(0, 6),
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

class _Progress extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const _Progress(this.value, this.color, {this.height = 7});

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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: _op(color, 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: _ts(
          11,
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
    this.size = 84,
    this.stroke = 9,
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

class _Bubble extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _Bubble(this.icon, this.color, {this.size = 38});

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
// MAIN ANALISIS SCREEN
// =============================================================================
class AnalisisScreen extends StatefulWidget {
  final Map<String, dynamic>? summaryData;
  final Future<void> Function(DateTimeRange range)? onExportPdf;
  final Future<void> Function(String csv, DateTimeRange range)? onExportCsv;
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
  String? _selectedSegment = 'Bulan';
  late DateTimeRange _range = _rangeFor('Bulan');

  String _cashFlowFilter = 'Bulan Ini';
  int? _selectedBar;

  bool _hideAmounts = false;
  bool _showInsight = true;
  bool _showGoals = true;

  int _goalSaved = 6000000;
  final bool _isEmptyState = false;

  late _Palette _p;

  String _money(int v) => _mask(_hideAmounts, v);
  String _moneyJt(int v) => _maskJt(_hideAmounts, v);

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
        _selectedSegment = null;
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
        title: Text('Analisis', style: _ts(22, FontWeight.w800, _p.text, ls: -0.5)),
        actions: [
          IconButton(
            tooltip: 'Pengaturan',
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
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
              physics: const ClampingScrollPhysics(),
              children: [
                _buildSegmentedFilter(),
                const SizedBox(height: 10),
                _buildDateRangeSelector(),
                const SizedBox(height: 16),
                if (_isEmptyState)
                  _buildEmptyState()
                else ...[
                  // 1. HERO BALANCE CARD
                  _buildFinancialSummaryHero(),
                  const SizedBox(height: 16),

                  // 2. BENTO ROW 1: CASH FLOW & PENGELUARAN
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: _buildCashFlowCompactCard()),
                      const SizedBox(width: 12),
                      Expanded(flex: 5, child: _buildExpenseCompactCard()),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 3. INSIGHT SMART AI BANNER
                  if (_showInsight) ...[
                    _buildInsightCompactBanner(),
                    const SizedBox(height: 12),
                  ],

                  // 4. BENTO ROW 2: ANGGARAN & TUJUAN KEUANGAN
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildBudgetCompactCard()),
                      if (_showGoals) ...[
                        const SizedBox(width: 12),
                        Expanded(child: _buildGoalCompactCard()),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 5. LAPORAN & EKSPOR
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
      height: 42,
      padding: const EdgeInsets.all(3),
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
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? _brandBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  segment,
                  style: _ts(
                    12.5,
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
    return GestureDetector(
      onTap: _selectDateRangePicker,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_rounded, size: 13, color: _p.muted),
          const SizedBox(width: 6),
          Text(_fmtRange(_range), style: _ts(12, FontWeight.w600, _p.text)),
          const SizedBox(width: 2),
          Icon(Icons.expand_more_rounded, size: 16, color: _p.muted),
        ],
      ),
    );
  }

  // ===========================================================================
  // HERO CARD (ROYAL BLUE MYKAS WITH SPARKLINE)
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_kRadiusCard),
        gradient: LinearGradient(
          colors: _p.isDark
              ? const [Color(0xFF1E40AF), Color(0xFF2563EB)]
              : const [Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Total Arus Kas Bersih',
                style: _ts(12, FontWeight.w500, Colors.white.withOpacity(0.85)),
              ),
              const SizedBox(width: 4),
              InkResponse(
                onTap: _showNetInfoSheet,
                child: Icon(Icons.info_outline_rounded, size: 14, color: Colors.white.withOpacity(0.8)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_upward, size: 11, color: Colors.white),
                    const SizedBox(width: 3),
                    Text('12%', style: _ts(11, FontWeight.w700, Colors.white)),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => setState(() => _hideAmounts = !_hideAmounts),
                icon: Icon(
                  _hideAmounts ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _money(net),
                    style: _ts(26, FontWeight.w900, Colors.white, ls: -0.8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 76,
                height: 28,
                child: CustomPaint(
                  painter: _SparklinePainter(values: _netTrend(), color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: divider),
          const SizedBox(height: 10),
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
              Container(width: 1, height: 28, color: divider),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 14),
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
            Icon(icon, size: 12, color: iconColor),
            const SizedBox(width: 4),
            Text(title, style: _ts(11, FontWeight.w500, Colors.white.withOpacity(0.8))),
          ],
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            _money(amount),
            style: _ts(14.5, FontWeight.w800, Colors.white, ls: -0.2),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // BENTO 1: CASH FLOW COMPACT CARD
  // ===========================================================================
  Widget _buildCashFlowCompactCard() {
    final data = _kCashFlowData[_cashFlowFilter] ?? _kCashFlowData['Bulan Ini']!;
    final maxV = data.fold<int>(0, (m, b) => max(m, max(b.income, b.expense)));

    return _Card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.bar_chart_rounded, size: 15, color: _brandBlue),
                  const SizedBox(width: 6),
                  Text('Cash Flow', style: _ts(13, FontWeight.w800, _p.text)),
                ],
              ),
              PopupMenuButton<String>(
                onSelected: (v) => setState(() => _cashFlowFilter = v),
                color: _p.surface,
                itemBuilder: (ctx) => ['Bulan Ini', '3 Bulan', 'Tahun Ini']
                    .map((k) => PopupMenuItem(
                          value: k,
                          child: Text(k, style: _ts(11.5, FontWeight.w500, _p.text)),
                        ))
                    .toList(),
                child: Row(
                  children: [
                    Text(_cashFlowFilter, style: _ts(10.5, FontWeight.w600, _p.muted)),
                    Icon(Icons.expand_more_rounded, size: 14, color: _p.muted),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(data.length, (i) {
                final b = data[i];
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 52 * (b.income / maxV),
                            width: 4.5,
                            decoration: BoxDecoration(
                              color: _incomeGreen,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Container(
                            height: 52 * (b.expense / maxV),
                            width: 4.5,
                            decoration: BoxDecoration(
                              color: _expenseRed,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(b.label, style: _ts(9.5, FontWeight.w500, _p.muted)),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BENTO 2: EXPENSE DONUT COMPACT CARD
  // ===========================================================================
  Widget _buildExpenseCompactCard() {
    final top = _kExpenseCats.first;

    return _Card(
      onTap: _openExpense,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.pie_chart_outline_rounded, size: 15, color: _accentPurple),
                  const SizedBox(width: 6),
                  Text('Pengeluaran', style: _ts(13, FontWeight.w800, _p.text)),
                ],
              ),
              Icon(Icons.chevron_right_rounded, size: 16, color: _p.muted),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _DonutView(
                size: 64,
                stroke: 7,
                sections: _kExpenseCats
                    .map((c) => DonutSection(value: c.amount.toDouble(), color: c.color))
                    .toList(),
                center: Text(
                  '35%',
                  style: _ts(11, FontWeight.w800, _p.text),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dominan:', style: _ts(10, FontWeight.w500, _p.muted)),
                    Text(top.name, style: _ts(12, FontWeight.w700, _p.text)),
                    Text(_moneyJt(top.amount), style: _ts(11, FontWeight.w600, top.color)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BENTO 3: ANGGARAN COMPACT CARD
  // ===========================================================================
  Widget _buildBudgetCompactCard() {
    final ratio = _kBudgetUsed / _kBudgetLimit;
    final left = _kBudgetLimit - _kBudgetUsed;

    return _Card(
      onTap: _openBudget,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.track_changes_rounded, size: 15, color: _brandBlue),
                  const SizedBox(width: 6),
                  Text('Anggaran', style: _ts(13, FontWeight.w800, _p.text)),
                ],
              ),
              _StatusChip(_ratioLabel(ratio), _ratioStatusColor(ratio)),
            ],
          ),
          const SizedBox(height: 12),
          Text(_moneyJt(_kBudgetUsed), style: _ts(16, FontWeight.w800, _p.text)),
          Text('dari ${_moneyJt(_kBudgetLimit)}', style: _ts(10.5, FontWeight.w500, _p.muted)),
          const SizedBox(height: 8),
          _Progress(ratio, _ratioColor(ratio), height: 5),
          const SizedBox(height: 6),
          Text('Sisa ${_moneyJt(left)}', style: _ts(10.5, FontWeight.w600, _p.text)),
        ],
      ),
    );
  }

  // ===========================================================================
  // BENTO 4: TUJUAN COMPACT CARD
  // ===========================================================================
  Widget _buildGoalCompactCard() {
    final ratio = _goalSaved / _kGoalTarget;
    final pct = (ratio * 100).round();

    return _Card(
      onTap: _openGoal,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.emoji_events_outlined, size: 15, color: _honeyGold),
                  const SizedBox(width: 6),
                  Text('Tujuan', style: _ts(13, FontWeight.w800, _p.text)),
                ],
              ),
              Icon(Icons.chevron_right_rounded, size: 16, color: _p.muted),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _DonutView(
                size: 58,
                stroke: 6,
                total: 100,
                sections: [DonutSection(value: pct.toDouble(), color: _honeyGold)],
                center: Text('$pct%', style: _ts(11, FontWeight.w800, _p.text)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dana Liburan', style: _ts(12, FontWeight.w700, _p.text)),
                    const SizedBox(height: 2),
                    Text(_moneyJt(_goalSaved), style: _ts(11, FontWeight.w600, _honeyGold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // AI INSIGHT COMPACT BANNER
  // ===========================================================================
  Widget _buildInsightCompactBanner() {
    return _Card(
      color: _p.isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
      borderColor: _op(_accentPurple, 0.25),
      onTap: _showInsightSheet,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _Bubble(Icons.lightbulb_outline_rounded, _accentPurple, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengeluaran makanan naik 15%',
                  style: _ts(12.5, FontWeight.w700, _p.text),
                ),
                Text(
                  'Coba tekan pengeluaran kuliner minggu ini.',
                  style: _ts(11, FontWeight.w500, _p.muted),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: 18, color: _accentPurple),
        ],
      ),
    );
  }

  // ===========================================================================
  // LAPORAN TILE
  // ===========================================================================
  Widget _buildReportTile() {
    return _Card(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => _showExportSheet('PDF'),
      child: Row(
        children: [
          _Bubble(Icons.receipt_long_outlined, _brandBlue, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Laporan Keuangan', style: _ts(13, FontWeight.w700, _p.text)),
                Text('Unduh laporan PDF atau CSV', style: _ts(11, FontWeight.w500, _p.muted)),
              ],
            ),
          ),
          Icon(Icons.download_rounded, size: 18, color: _brandBlue),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return _Card(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _op(_brandBlue, 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.analytics_outlined, size: 30, color: _brandBlue),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Transaksi Cukup',
            textAlign: TextAlign.center,
            style: _ts(16, FontWeight.w700, _p.text),
          ),
          const SizedBox(height: 6),
          Text(
            'Catat pemasukan dan pengeluaran rutin untuk membuka analisis grafik.',
            textAlign: TextAlign.center,
            style: _ts(12, FontWeight.w500, _p.muted, height: 1.4),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _brandBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 42),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
            label: Text('Catat Transaksi', style: _ts(12.5, FontWeight.w700, Colors.white)),
            onPressed: widget.onAddTransaction ?? () => _showNotification('Halaman pencatatan belum tersambung'),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BOTTOM SHEETS
  // ===========================================================================
  void _showSettingsSheet() {
    _showSheet<void>(context, (ctx, setSheet) {
      Widget row(String title, String sub, bool value, ValueChanged<bool> onChanged) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: _ts(14, FontWeight.w600, _p.text)),
                    Text(sub, style: _ts(12, FontWeight.w500, _p.muted)),
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
        subtitle: 'Kustomisasi Tampilan Dashboard',
        child: Column(
          children: [
            row('Sembunyikan nominal', 'Samarkan angka saldo', _hideAmounts, (v) => _hideAmounts = v),
            Divider(height: 1, color: _p.border),
            row('Tampilkan tujuan', 'Progres target tabungan', _showGoals, (v) => _showGoals = v),
            Divider(height: 1, color: _p.border),
            row('Tampilkan insight AI', 'Rekomendasi keuangan pintar', _showInsight, (v) => _showInsight = v),
          ],
        ),
      );
    });
  }

  void _showNetInfoSheet() {
    final net = _kIncome - _kExpense;
    _showSheet<void>(context, (ctx, setSheet) {
      Widget line(String label, String value, {bool bold = false, Color? color}) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: _ts(13.5, bold ? FontWeight.w700 : FontWeight.w500, _p.text)),
              Text(value, style: _ts(13.5, bold ? FontWeight.w800 : FontWeight.w600, color ?? _p.text)),
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
              'Selisih total uang masuk dan keluar pada periode aktif. Nilai positif menunjukkan surplus saldo.',
              style: _ts(12.5, FontWeight.w500, _p.muted, height: 1.4),
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

  void _showInsightSheet() {
    final food = _kExpenseCats.first.amount;
    final diff = food - _kFoodLastMonth;
    final pct = (diff / _kFoodLastMonth * 100).round();

    _showSheet<void>(context, (ctx, setSheet) {
      return _SheetFrame(
        p: _p,
        title: 'Insight Kuliner',
        subtitle: 'Naik $pct% (${_money(diff)}) dibanding bulan lalu',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saran Penghematan:', style: _ts(13, FontWeight.w700, _p.text)),
            const SizedBox(height: 10),
            Text('• Batasi pesanan makanan via e-wallet minggu ini.', style: _ts(12.5, FontWeight.w500, _p.muted, height: 1.4)),
            const SizedBox(height: 6),
            Text('• Siapkan bekal harian untuk menekan variabel pengeluaran.', style: _ts(12.5, FontWeight.w500, _p.muted, height: 1.4)),
          ],
        ),
      );
    });
  }

  String _buildCsv() {
    final b = StringBuffer()
      ..writeln('Laporan Keuangan MyKas')
      ..writeln('Periode,"${_fmtRange(_range)}"')
      ..writeln()
      ..writeln('Ringkasan,Jumlah')
      ..writeln('Pemasukan,$_kIncome')
      ..writeln('Pengeluaran,$_kExpense')
      ..writeln('Arus Kas Bersih,${_kIncome - _kExpense}');
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
      _showNotification('Fitur Ekspor PDF aktif');
    }
  }

  void _showExportSheet(String initialFormat) {
    var fmt = initialFormat;
    _showSheet<void>(context, (ctx, setSheet) {
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
              minimumSize: const Size(0, 48),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: Icon(fmt == 'CSV' ? Icons.copy_rounded : Icons.picture_as_pdf_outlined, size: 18),
            label: Text(fmt == 'CSV' ? 'Salin CSV' : 'Unduh PDF', style: _ts(13.5, FontWeight.w700, Colors.white)),
            onPressed: () => _runExport(fmt, ctx),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setSheet(() => fmt = 'PDF'),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: fmt == 'PDF' ? _op(_brandBlue, 0.1) : _p.surfaceAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: fmt == 'PDF' ? _brandBlue : _p.border),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.picture_as_pdf_outlined, color: fmt == 'PDF' ? _brandBlue : _p.muted),
                          const SizedBox(height: 4),
                          Text('PDF Document', style: _ts(12, FontWeight.w700, _p.text)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setSheet(() => fmt = 'CSV'),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: fmt == 'CSV' ? _op(_brandBlue, 0.1) : _p.surfaceAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: fmt == 'CSV' ? _brandBlue : _p.border),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.table_chart_outlined, color: fmt == 'CSV' ? _brandBlue : _p.muted),
                          const SizedBox(height: 4),
                          Text('CSV Data', style: _ts(12, FontWeight.w700, _p.text)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// =============================================================================
// SUBPAGE DETAILS (EXPENSE, BUDGET, GOALS)
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
      title: 'Rincian Pengeluaran',
      subtitle: _fmtRange(range),
      children: [
        Center(
          child: Column(
            children: [
              Text('Total pengeluaran', style: _ts(12.5, FontWeight.w500, p.muted)),
              const SizedBox(height: 2),
              Text(_mask(hide, _kExpense), style: _ts(28, FontWeight.w800, p.text, ls: -0.8)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: _DonutView(
            size: 150,
            stroke: 14,
            sections: _kExpenseCats
                .map((c) => DonutSection(value: c.amount.toDouble(), color: c.color))
                .toList(),
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(top.name, style: _ts(11, FontWeight.w500, p.muted)),
                Text('${(top.amount / _kExpense * 100).round()}%', style: _ts(22, FontWeight.w800, p.text)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Kategori', style: _ts(14, FontWeight.w700, p.text)),
        const SizedBox(height: 10),
        _Card(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 2),
          child: Column(
            children: _kExpenseCats.map((c) {
              final pct = c.amount / _kExpense;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    _Bubble(c.icon, c.color, size: 36),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(c.name, style: _ts(13, FontWeight.w600, p.text)),
                              Text(_mask(hide, c.amount), style: _ts(13, FontWeight.w700, p.text)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          _Progress(pct, c.color, height: 5),
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

class _BudgetPage extends StatelessWidget {
  final bool hide;

  const _BudgetPage({required this.hide});

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    final ratio = _kBudgetUsed / _kBudgetLimit;
    final percent = (ratio * 100).round();

    return _PageShell(
      title: 'Status Anggaran',
      subtitle: 'Bulan Ini',
      children: [
        Center(
          child: _DonutView(
            size: 150,
            stroke: 14,
            total: 100,
            sections: [DonutSection(value: percent.toDouble(), color: _ratioColor(ratio))],
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$percent%', style: _ts(26, FontWeight.w800, p.text)),
                Text('terpakai', style: _ts(11, FontWeight.w500, p.muted)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Batas Kategori', style: _ts(14, FontWeight.w700, p.text)),
        const SizedBox(height: 10),
        _Card(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 2),
          child: Column(
            children: _kBudgetItems.map((b) {
              final r = b.used / b.limit;
              final color = _ratioColor(r);
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    _Bubble(b.icon, color, size: 36),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(b.name, style: _ts(13, FontWeight.w600, p.text)),
                              Text('${(r * 100).round()}%', style: _ts(13, FontWeight.w700, p.text)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          _Progress(r, color, height: 5),
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

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    final ratio = _saved / _kGoalTarget;

    return _PageShell(
      title: 'Target Tabungan',
      subtitle: 'Dana Liburan',
      children: [
        Row(
          children: [
            _Bubble(Icons.flight_takeoff_rounded, _honeyGold, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Terkumpul', style: _ts(12, FontWeight.w500, p.muted)),
                  Text(_mask(widget.hide, _saved), style: _ts(24, FontWeight.w800, p.text)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Progress(ratio, _honeyGold, height: 10),
      ],
    );
  }
}

// =============================================================================
// SHEETS & PAINTERS
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
    return Material(
      color: p.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 36, height: 4, decoration: BoxDecoration(color: p.track, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: _ts(17, FontWeight.w700, p.text)),
                        if (subtitle != null) Text(subtitle!, style: _ts(12, FontWeight.w500, p.muted)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: p.muted),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            Flexible(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(18, 4, 18, 16), child: child)),
            if (footer != null) Padding(padding: const EdgeInsets.fromLTRB(18, 4, 18, 16), child: footer),
          ],
        ),
      ),
    );
  }
}

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

  @override
  void initState() {
    super.initState();
    _start = widget.initial.start;
    _end = widget.initial.end;
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      p: widget.p,
      title: 'Pilih Periode',
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _brandBlue, minimumSize: const Size(double.infinity, 44)),
            onPressed: () => Navigator.of(context).pop(DateTimeRange(start: _start!, end: _end!)),
            child: Text('Gunakan Periode Ini', style: _ts(13, FontWeight.w700, Colors.white)),
          ),
        ],
      ),
    );
  }
}

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

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final y = size.height - ((values[i] - minV) / range) * size.height;
      points.add(Offset(x, y));
    }

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      line.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) => true;
}

class DonutSection {
  final double value;
  final Color color;
  const DonutSection({required this.value, required this.color});
}

class DonutChartPainter extends CustomPainter {
  final List<DonutSection> sections;
  final Color backgroundColor;
  final double? total;
  final double progress;
  final double strokeWidth;

  DonutChartPainter({
    required this.sections,
    required this.backgroundColor,
    this.total,
    this.progress = 1,
    this.strokeWidth = 9,
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

    var start = -pi / 2;
    for (final section in sections) {
      final sweep = (section.value / denom) * 2 * pi * progress;
      if (sweep > 0) {
        canvas.drawArc(
          rect,
          start,
          sweep,
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
  bool shouldRepaint(covariant DonutChartPainter old) => true;
}
