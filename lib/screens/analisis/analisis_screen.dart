import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// =============================================================================
// DESIGN TOKENS
// =============================================================================
const double _kRadiusCard = 24;
const double _kRadiusInner = 16;
const double _kPadCard = 20;
const double _kGap = 16;

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

Color _ratioColor(double r) {
  if (r >= 0.9) return _expenseRed;
  if (r >= 0.75) return _honeyGold;
  return _brandBlue;
}

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
      border: t.colorScheme.outline.withOpacity(d ? 0.35 : 0.12),
      text: t.colorScheme.onSurface,
      muted: t.colorScheme.onSurfaceVariant,
      track: d ? Colors.white10 : const Color(0xFFE2E8F0),
    );
  }
}

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

  // Toggle empty state
  final bool _isEmptyState = false;

  late _Palette _p;

  // ---- Data contoh (ganti dengan widget.summaryData bila sudah tersedia)
  static const int _income = 8000000;
  static const int _expense = 5200000;
  static const int _budgetLimit = 5000000;
  static const int _budgetUsed = 3500000;
  static const int _goalTarget = 10000000;
  static const int _foodLastMonth = 1580000;
  int _goalSaved = 6000000;

  static const List<_Cat> _expenseCats = [
    _Cat('Makanan', 1820000, Color(0xFFF97316), Icons.restaurant_rounded),
    _Cat('Belanja', 1300000, Color(0xFF8B5CF6), Icons.shopping_bag_outlined),
    _Cat('Tagihan', 1040000, Color(0xFF3B82F6), Icons.receipt_long_outlined),
    _Cat('Lainnya', 1040000, _slate, Icons.more_horiz_rounded),
  ];

  static const List<_BudgetItem> _budgetItems = [
    _BudgetItem('Makanan', 1820000, 2200000, Icons.restaurant_rounded),
    _BudgetItem('Belanja', 1300000, 1800000, Icons.shopping_bag_outlined),
    _BudgetItem('Transportasi', 380000, 1000000, Icons.directions_bus_outlined),
  ];

  static const Map<String, List<_Bar>> _cashFlowData = {
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

  // ---------------------------------------------------------------------------
  // HELPER FORMAT
  // ---------------------------------------------------------------------------
  String _money(int v) => _hideAmounts ? 'Rp ••••••' : _rp(v);
  String _moneyJt(int v) => _hideAmounts ? 'Rp •••' : _rpJt(v);

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
      constraints: const BoxConstraints(maxWidth: 560),
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

  void _showNotification(BuildContext context, String title) {
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

  Future<void> _openSheet(
    Widget Function(BuildContext ctx, StateSetter setSheet) builder,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (ctx) => StatefulBuilder(builder: builder),
    );
  }

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isDesktop ? 960 : 520),
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 28 : 20,
                    vertical: 8,
                  ),
                  physics: const ClampingScrollPhysics(),
                  children: [
                    _buildSegmentedFilter(),
                    const SizedBox(height: 12),
                    _buildDateRangeSelector(),
                    const SizedBox(height: 20),
                    if (_isEmptyState)
                      _buildEmptyState()
                    else ...[
                      _buildFinancialSummaryHero(),
                      const SizedBox(height: _kGap),
                      _buildCashFlowCard(),
                      const SizedBox(height: _kGap),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: _buildExpenseAnalysisCard()),
                            const SizedBox(width: 12),
                            Expanded(child: _buildBudgetAnalysisCard()),
                          ],
                        ),
                      ),
                      const SizedBox(height: _kGap),
                      if (_showGoals) ...[
                        _buildFinancialGoalsCard(),
                        const SizedBox(height: _kGap),
                      ],
                      if (_showInsight) ...[
                        _buildFinancialInsightCard(),
                        const SizedBox(height: _kGap),
                      ],
                      _buildReportExportCard(),
                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // SHARED BUILDING BLOCKS
  // ===========================================================================
  Widget _card({
    required Widget child,
    EdgeInsets? padding,
    Color? color,
    Color? borderColor,
  }) {
    final radius = BorderRadius.circular(_kRadiusCard);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: _p.isDark
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
        color: color ?? _p.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: borderColor ?? _p.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(_kPadCard),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required Color color,
    required String title,
    Widget? trailing,
    bool compact = false,
  }) {
    final box = compact ? 30.0 : 34.0;
    return Row(
      children: [
        Container(
          width: box,
          height: box,
          decoration: BoxDecoration(
            color: _op(color, 0.12),
            borderRadius: BorderRadius.circular(compact ? 10 : 11),
          ),
          child: Icon(icon, size: compact ? 16 : 18, color: color),
        ),
        SizedBox(width: compact ? 8 : 10),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _ts(compact ? 14 : 15, FontWeight.w700, _p.text),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _linkButton(String label, Color color, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: _ts(13, FontWeight.w600, color)),
            const SizedBox(width: 2),
            Icon(Icons.chevron_right_rounded, size: 18, color: color),
          ],
        ),
      ),
    );
  }

  Widget _progressBar(double value, Color color, {double height = 8}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: Container(
            height: height,
            color: _p.track,
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

  Widget _donut({
    required List<DonutSection> sections,
    required Widget center,
    double? total,
  }) {
    return SizedBox(
      width: 96,
      height: 96,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) {
          return CustomPaint(
            painter: DonutChartPainter(
              sections: sections,
              backgroundColor: _p.track,
              total: total,
              progress: t,
              strokeWidth: 10,
            ),
            child: child,
          );
        },
        child: Center(child: center),
      ),
    );
  }

  Widget _iconBubble(IconData icon, Color color, {double size = 40}) {
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

  // ===========================================================================
  // 1. FILTER PERIODE
  // ===========================================================================
  Widget _buildSegmentedFilter() {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _p.isDark ? _p.surface : const Color(0xFFE9EEF6),
        borderRadius: BorderRadius.circular(16),
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
                  borderRadius: BorderRadius.circular(12),
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
      child: Material(
        color: _p.surface,
        shape: StadiumBorder(side: BorderSide(color: _p.border)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: _selectDateRangePicker,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_rounded, size: 15, color: _brandBlue),
                const SizedBox(width: 8),
                Text(_fmtRange(_range), style: _ts(13, FontWeight.w600, _p.text)),
                const SizedBox(width: 4),
                Icon(Icons.expand_more_rounded, size: 18, color: _p.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. RINGKASAN KEUANGAN (HERO) - datar, tanpa kontainer bersarang
  // ===========================================================================
  Widget _buildFinancialSummaryHero() {
    final net = _income - _expense;
    final divider = Colors.white.withOpacity(0.18);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_kRadiusCard),
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
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _money(net),
              style: _ts(28, FontWeight.w800, Colors.white, ls: -0.8),
            ),
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
                  amount: _income,
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
                    amount: _expense,
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
  // 3. ARUS KAS
  // ===========================================================================
  Widget _buildCashFlowCard() {
    final data = _cashFlowData[_cashFlowFilter] ?? _cashFlowData['Bulan Ini']!;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.bar_chart_rounded,
            color: _brandBlue,
            title: 'Cash Flow',
            trailing: PopupMenuButton<String>(
              tooltip: 'Pilih rentang',
              onSelected: (val) => setState(() {
                _cashFlowFilter = val;
                _selectedBar = null;
              }),
              color: _p.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'Bulan Ini',
                  child: Text('Bulan Ini', style: _ts(13, FontWeight.w500, _p.text)),
                ),
                PopupMenuItem(
                  value: '3 Bulan',
                  child: Text('3 Bulan Terakhir', style: _ts(13, FontWeight.w500, _p.text)),
                ),
                PopupMenuItem(
                  value: 'Tahun Ini',
                  child: Text('Tahun Ini', style: _ts(13, FontWeight.w500, _p.text)),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 7, 8, 7),
                decoration: BoxDecoration(
                  color: _p.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _p.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_cashFlowFilter, style: _ts(12, FontWeight.w600, _p.text)),
                    const SizedBox(width: 2),
                    Icon(Icons.expand_more_rounded, size: 16, color: _p.muted),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildChartReadout(data),
          const SizedBox(height: 16),
          _buildCashFlowBarVisual(data),
          const SizedBox(height: 14),
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

  Widget _buildChartReadout(List<_Bar> data) {
    final idx = _selectedBar;
    final b = (idx != null && idx < data.length) ? data[idx] : null;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: _p.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: b == null
          ? Row(
              children: [
                Icon(Icons.touch_app_outlined, size: 16, color: _p.muted),
                const SizedBox(width: 8),
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
    const chartHeight = 150.0;
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
                        onTap: () => setState(
                          () => _selectedBar = selected ? null : i,
                        ),
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
  // 4. PENGELUARAN
  // ===========================================================================
  Widget _buildExpenseAnalysisCard() {
    return _card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.pie_chart_outline_rounded,
            color: _accentPurple,
            title: 'Pengeluaran',
            compact: true,
          ),
          const SizedBox(height: 18),
          Center(
            child: _donut(
              sections: _expenseCats
                  .map((c) => DonutSection(value: c.amount.toDouble(), color: c.color))
                  .toList(),
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total', style: _ts(11, FontWeight.w500, _p.muted)),
                  Text(
                    _moneyJt(_expense),
                    style: _ts(13, FontWeight.w800, _p.text),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._expenseCats.map(_buildExpenseCategoryRow),
          const Spacer(),
          const SizedBox(height: 4),
          _linkButton(
            'Lihat detail',
            _p.isDark ? _accentPurple : const Color(0xFF7C3AED),
            _showExpenseSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCategoryRow(_Cat c) {
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
              style: _ts(12.5, FontWeight.w500, _p.text),
            ),
          ),
          Text(
            '${(c.amount / _expense * 100).round()}%',
            style: _ts(12.5, FontWeight.w700, _p.text),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. ANGGARAN
  // ===========================================================================
  Widget _buildBudgetAnalysisCard() {
    final ratio = _budgetUsed / _budgetLimit;
    final percent = (ratio * 100).round();
    final left = _budgetLimit - _budgetUsed;

    final String statusLabel;
    final Color statusColor;
    if (ratio >= 0.9) {
      statusLabel = 'Kritis';
      statusColor = _expenseRed;
    } else if (ratio >= 0.75) {
      statusLabel = 'Waspada';
      statusColor = _honeyGold;
    } else {
      statusLabel = 'Aman';
      statusColor = _incomeGreen;
    }

    return _card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.track_changes_rounded,
            color: _brandBlue,
            title: 'Anggaran',
            compact: true,
          ),
          const SizedBox(height: 18),
          Center(
            child: _donut(
              total: 100,
              sections: [DonutSection(value: percent.toDouble(), color: _ratioColor(ratio))],
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$percent%', style: _ts(18, FontWeight.w800, _p.text, ls: -0.4)),
                  Text('terpakai', style: _ts(11, FontWeight.w500, _p.muted)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _op(statusColor, 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusLabel,
                style: _ts(
                  12,
                  FontWeight.w700,
                  statusColor == _honeyGold ? const Color(0xFFB45309) : statusColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _budgetStat('Terpakai', _moneyJt(_budgetUsed)),
          const SizedBox(height: 8),
          _budgetStat('Sisa', _moneyJt(left)),
          const Spacer(),
          const SizedBox(height: 4),
          _linkButton('Lihat detail', _brandBlue, _showBudgetSheet),
        ],
      ),
    );
  }

  Widget _budgetStat(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: _ts(12.5, FontWeight.w500, _p.muted)),
        Text(value, style: _ts(13, FontWeight.w700, _p.text)),
      ],
    );
  }

  // ===========================================================================
  // 6. TUJUAN KEUANGAN (datar, seluruh baris bisa diketuk)
  // ===========================================================================
  Widget _buildFinancialGoalsCard() {
    final ratio = _goalSaved / _goalTarget;
    final percent = (ratio * 100).round();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.emoji_events_outlined,
            color: _honeyGold,
            title: 'Tujuan Keuangan',
            trailing: Text('1 tujuan aktif', style: _ts(12, FontWeight.w500, _p.muted)),
          ),
          const SizedBox(height: 14),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _showGoalSheet,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _iconBubble(Icons.flight_takeoff_rounded, _honeyGold, size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dana Liburan', style: _ts(14, FontWeight.w700, _p.text)),
                            const SizedBox(height: 2),
                            Text(
                              'Target ${_money(_goalTarget)}',
                              style: _ts(12, FontWeight.w500, _p.muted),
                            ),
                          ],
                        ),
                      ),
                      Text('$percent%', style: _ts(18, FontWeight.w800, _p.text, ls: -0.4)),
                      const SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded, size: 20, color: _p.muted),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _progressBar(ratio, _honeyGold),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Terkumpul ${_money(_goalSaved)}',
                        style: _ts(12, FontWeight.w600, _p.text),
                      ),
                      Text(
                        'Kurang ${_money(_goalTarget - _goalSaved)}',
                        style: _ts(12, FontWeight.w500, _p.muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 7. INSIGHT KEUANGAN
  // ===========================================================================
  Widget _buildFinancialInsightCard() {
    final purpleText = _p.isDark ? const Color(0xFFC4B5FD) : const Color(0xFF7C3AED);

    return _card(
      color: _p.isDark ? const Color(0xFF1E1B4B) : const Color(0xFFF5F3FF),
      borderColor: _op(_accentPurple, 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.lightbulb_outline_rounded,
            color: _accentPurple,
            title: 'Insight Keuangan',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _op(_expenseRed, 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.trending_up_rounded, size: 14, color: _expenseRed),
                const SizedBox(width: 6),
                Text(
                  'Makanan +15%',
                  style: _ts(
                    12,
                    FontWeight.w700,
                    _p.isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Pengeluaran makanan naik 15% dibanding bulan lalu.',
            style: _ts(15, FontWeight.w700, _p.text, height: 1.4),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba tekan pengeluaran kuliner minggu ini.',
            style: _ts(13, FontWeight.w500, _p.muted, height: 1.4),
          ),
          const SizedBox(height: 8),
          _linkButton('Lihat detail', purpleText, _showInsightSheet),
        ],
      ),
    );
  }

  // ===========================================================================
  // 8. LAPORAN KEUANGAN
  // ===========================================================================
  Widget _buildReportExportCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.receipt_long_outlined,
            color: _brandBlue,
            title: 'Laporan Keuangan',
          ),
          const SizedBox(height: 10),
          Text(
            'Unduh laporan lengkap dalam format PDF atau CSV.',
            style: _ts(12.5, FontWeight.w500, _p.muted, height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 46),
                    side: BorderSide(color: _p.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: Icon(Icons.picture_as_pdf_outlined, size: 18, color: _p.text),
                  label: Text('Export PDF', style: _ts(13, FontWeight.w700, _p.text)),
                  onPressed: () => _showExportSheet('PDF'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 46),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.table_chart_outlined, size: 18, color: Colors.white),
                  label: Text('Export CSV', style: _ts(13, FontWeight.w700, Colors.white)),
                  onPressed: () => _showExportSheet('CSV'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // EMPTY STATE
  // ===========================================================================
  Widget _buildEmptyState() {
    return _card(
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
                _showNotification(context, 'Halaman pencatatan belum tersambung');
              }
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BOTTOM SHEETS
  // ===========================================================================

  // ---- Pengaturan
  void _showSettingsSheet() {
    _openSheet((ctx, setSheet) {
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
    final net = _income - _expense;
    _openSheet((ctx, setSheet) {
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
            line('Pemasukan', _money(_income), color: _incomeGreen),
            line('Pengeluaran', '- ${_money(_expense)}', color: _expenseRed),
            Divider(height: 16, color: _p.border),
            line('Arus kas bersih', _money(net), bold: true),
          ],
        ),
      );
    });
  }

  // ---- Rincian pengeluaran
  void _showExpenseSheet() {
    _openSheet((ctx, setSheet) {
      return _SheetFrame(
        p: _p,
        title: 'Rincian Pengeluaran',
        subtitle: '${_fmtRange(_range)} · Total ${_money(_expense)}',
        child: Column(
          children: _expenseCats.map((c) {
            final pct = c.amount / _expense;
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _iconBubble(c.icon, c.color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(c.name, style: _ts(14, FontWeight.w600, _p.text)),
                            Text(_money(c.amount), style: _ts(14, FontWeight.w700, _p.text)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _progressBar(pct, c.color, height: 6),
                        const SizedBox(height: 6),
                        Text(
                          '${(pct * 100).round()}% dari total pengeluaran',
                          style: _ts(12, FontWeight.w500, _p.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  // ---- Rincian anggaran
  void _showBudgetSheet() {
    final ratio = _budgetUsed / _budgetLimit;
    _openSheet((ctx, setSheet) {
      return _SheetFrame(
        p: _p,
        title: 'Rincian Anggaran',
        subtitle: _fmtRange(_range),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _money(_budgetUsed),
                  style: _ts(24, FontWeight.w800, _p.text, ls: -0.6),
                ),
                Text(
                  'dari ${_money(_budgetLimit)}',
                  style: _ts(13, FontWeight.w500, _p.muted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _progressBar(ratio, _ratioColor(ratio), height: 10),
            const SizedBox(height: 8),
            Text(
              'Sisa ${_money(_budgetLimit - _budgetUsed)} (${((1 - ratio) * 100).round()}%)',
              style: _ts(12.5, FontWeight.w500, _p.muted),
            ),
            const SizedBox(height: 22),
            Text('Per kategori', style: _ts(13, FontWeight.w700, _p.muted, ls: 0.2)),
            const SizedBox(height: 14),
            ..._budgetItems.map((b) {
              final r = b.used / b.limit;
              final color = _ratioColor(r);
              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _iconBubble(b.icon, color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(b.name, style: _ts(14, FontWeight.w600, _p.text)),
                              Text('${(r * 100).round()}%',
                                  style: _ts(14, FontWeight.w700, _p.text)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _progressBar(r, color, height: 6),
                          const SizedBox(height: 6),
                          Text(
                            '${_money(b.used)} dari ${_money(b.limit)}',
                            style: _ts(12, FontWeight.w500, _p.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  // ---- Tujuan keuangan (bisa tambah tabungan)
  void _showGoalSheet() {
    _openSheet((ctx, setSheet) {
      final ratio = _goalSaved / _goalTarget;
      final done = _goalSaved >= _goalTarget;

      void add(int amount) {
        final next = min(_goalTarget, _goalSaved + amount);
        setState(() => _goalSaved = next);
        setSheet(() {});
      }

      Widget chip(String label, int amount) {
        return Material(
          color: done ? _p.surfaceAlt : _op(_honeyGold, 0.14),
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: done ? null : () => add(amount),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              child: Text(
                label,
                style: _ts(
                  13,
                  FontWeight.w700,
                  done
                      ? _p.muted
                      : (_p.isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309)),
                ),
              ),
            ),
          ),
        );
      }

      return _SheetFrame(
        p: _p,
        title: 'Dana Liburan',
        subtitle: 'Target ${_money(_goalTarget)}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _money(_goalSaved),
                  style: _ts(24, FontWeight.w800, _p.text, ls: -0.6),
                ),
                Text('${(ratio * 100).round()}%',
                    style: _ts(16, FontWeight.w800, _p.text)),
              ],
            ),
            const SizedBox(height: 10),
            _progressBar(ratio, _honeyGold, height: 10),
            const SizedBox(height: 8),
            Text(
              done
                  ? 'Tujuan tercapai. Selamat!'
                  : 'Kurang ${_money(_goalTarget - _goalSaved)} lagi',
              style: _ts(12.5, FontWeight.w500, _p.muted),
            ),
            const SizedBox(height: 22),
            Text('Tambah tabungan', style: _ts(13, FontWeight.w700, _p.muted, ls: 0.2)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                chip('+ Rp 100 rb', 100000),
                chip('+ Rp 500 rb', 500000),
                chip('+ Rp 1 jt', 1000000),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ---- Insight
  void _showInsightSheet() {
    final food = _expenseCats.first.amount;
    final diff = food - _foodLastMonth;
    final pct = (diff / _foodLastMonth * 100).round();

    _openSheet((ctx, setSheet) {
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
              _progressBar(ratio, color, height: 8),
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
            compare('Bulan lalu', _foodLastMonth, _foodLastMonth / food, _slate),
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
      ..writeln('Pemasukan,$_income')
      ..writeln('Pengeluaran,$_expense')
      ..writeln('Arus Kas Bersih,${_income - _expense}')
      ..writeln()
      ..writeln('Kategori,Jumlah,Persentase');
    for (final c in _expenseCats) {
      b.writeln('${c.name},${c.amount},${(c.amount / _expense * 100).round()}%');
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
        if (mounted) _showNotification(context, 'CSV disalin ke clipboard');
      }
    } else if (widget.onExportPdf != null) {
      Navigator.of(sheetCtx).pop();
      await widget.onExportPdf!(_range);
    } else {
      _showNotification(context, 'Ekspor PDF belum tersambung di aplikasi ini');
    }
  }

  void _showExportSheet(String initialFormat) {
    var fmt = initialFormat;
    _openSheet((ctx, setSheet) {
      Widget option(String value, IconData icon, String title, String sub) {
        final selected = fmt == value;
        return Expanded(
          child: Material(
            color: selected ? _op(_brandBlue, 0.10) : _p.surfaceAlt,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_kRadiusInner),
              side: BorderSide(color: selected ? _brandBlue : _p.border, width: selected ? 1.5 : 1),
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
            row('Pemasukan', _rp(_income)),
            row('Pengeluaran', _rp(_expense)),
            row('Arus kas bersih', _rp(_income - _expense), bold: true),
            Divider(height: 20, color: _p.border),
            ..._expenseCats.map((c) => row(c.name, _rp(c.amount))),
          ],
        ),
      );
    });
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
