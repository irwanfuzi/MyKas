import 'dart:math';
import 'package:flutter/material.dart';
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
  final double income;
  final double expense;
  const _Bar(this.label, this.income, this.expense);
}

class _Cat {
  final String name;
  final double pct;
  final Color color;
  const _Cat(this.name, this.pct, this.color);
}

// =============================================================================
// SCREEN
// =============================================================================
class AnalisisScreen extends StatefulWidget {
  final Map<String, dynamic>? summaryData;

  const AnalisisScreen({
    super.key,
    this.summaryData,
  });

  @override
  State<AnalisisScreen> createState() => _AnalisisScreenState();
}

class _AnalisisScreenState extends State<AnalisisScreen> {
  // ---- State filter periode
  String _selectedSegment = 'Bulan';
  String _cashFlowFilter = 'Bulan Ini';
  late DateTimeRange _range = _rangeFor('Bulan');

  // Toggle empty state
  final bool _isEmptyState = false;

  late _Palette _p;

  // ---- Data (ganti dengan widget.summaryData bila sudah tersedia)
  static const int _income = 8000000;
  static const int _expense = 5200000;
  static const int _budgetLimit = 5000000;
  static const int _budgetUsed = 3500000;
  static const int _goalSaved = 6000000;
  static const int _goalTarget = 10000000;

  static const List<_Cat> _expenseCats = [
    _Cat('Makanan', 35, Color(0xFFF97316)),
    _Cat('Belanja', 25, Color(0xFF8B5CF6)),
    _Cat('Tagihan', 20, Color(0xFF3B82F6)),
    _Cat('Lainnya', 20, _slate),
  ];

  static const Map<String, List<_Bar>> _cashFlowData = {
    'Bulan Ini': [
      _Bar('Mgg 1', 0.80, 0.55),
      _Bar('Mgg 2', 0.68, 0.45),
      _Bar('Mgg 3', 0.72, 0.42),
      _Bar('Mgg 4', 0.65, 0.40),
      _Bar('Mgg 5', 0.82, 0.48),
    ],
    '3 Bulan': [
      _Bar('Agu', 0.70, 0.50),
      _Bar('Sep', 0.78, 0.58),
      _Bar('Okt', 0.90, 0.58),
    ],
    'Tahun Ini': [
      _Bar('Jan', 0.60, 0.48),
      _Bar('Feb', 0.64, 0.50),
      _Bar('Mar', 0.70, 0.52),
      _Bar('Apr', 0.66, 0.55),
      _Bar('Mei', 0.72, 0.50),
      _Bar('Jun', 0.75, 0.56),
      _Bar('Jul', 0.78, 0.54),
      _Bar('Agu', 0.70, 0.50),
      _Bar('Sep', 0.78, 0.58),
      _Bar('Okt', 0.90, 0.58),
    ],
  };

  static const List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

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

  String get _rangeLabel {
    final s = _range.start;
    final e = _range.end;
    if (s.year == e.year && s.month == e.month) {
      return '${s.day} – ${e.day} ${_months[s.month - 1]} ${e.year}';
    }
    if (s.year == e.year) {
      return '${s.day} ${_months[s.month - 1]} – ${e.day} ${_months[e.month - 1]} ${e.year}';
    }
    return '${s.day} ${_months[s.month - 1]} ${s.year} – ${e.day} ${_months[e.month - 1]} ${e.year}';
  }

  void _onSegmentChanged(String segment) {
    setState(() {
      _selectedSegment = segment;
      _range = _rangeFor(segment);
    });
  }

  Future<void> _selectDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 1, 12, 31),
      initialDateRange: _range,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: _brandBlue),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _range = picked);
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
            icon: Icon(Icons.settings_outlined, color: _p.text, size: 22),
            onPressed: () => _showNotification(context, 'Pengaturan Analisis'),
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
                      const SizedBox(height: 12),
                      _buildSavingsBanner(),
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
                      _buildFinancialGoalsCard(),
                      const SizedBox(height: _kGap),
                      _buildFinancialInsightCard(),
                      const SizedBox(height: _kGap),
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
                Text(_rangeLabel, style: _ts(13, FontWeight.w600, _p.text)),
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
  // 2. RINGKASAN KEUANGAN (HERO)
  // ===========================================================================
  Widget _glow(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }

  Widget _buildFinancialSummaryHero() {
    final net = _income - _expense;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _op(_brandBlue, _p.isDark ? 0.25 : 0.30),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _p.isDark
                  ? const [Color(0xFF1E3A8A), Color(0xFF2563EB)]
                  : const [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(right: -50, top: -50, child: _glow(170, 0.10)),
              Positioned(left: -40, bottom: -70, child: _glow(150, 0.07)),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                'Arus Kas Bersih',
                                style: _ts(13, FontWeight.w500, Colors.white.withOpacity(0.85)),
                              ),
                              const SizedBox(width: 6),
                              InkResponse(
                                radius: 16,
                                onTap: () => _showNotification(
                                  context,
                                  'Selisih pemasukan dan pengeluaran pada periode ini',
                                ),
                                child: Icon(
                                  Icons.info_outline_rounded,
                                  size: 16,
                                  color: Colors.white.withOpacity(0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.16),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 19,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _rp(net),
                        style: _ts(34, FontWeight.w800, Colors.white, ls: -1),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.trending_up_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            '12% dibanding bulan lalu',
                            style: _ts(12, FontWeight.w600, Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: _heroMetric(
                            title: 'Pengeluaran',
                            amount: _expense,
                            icon: Icons.arrow_downward_rounded,
                            iconColor: const Color(0xFFFCA5A5),
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
    );
  }

  Widget _heroMetric({
    required String title,
    required int amount,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(_kRadiusInner),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.16),
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _ts(12, FontWeight.w500, Colors.white.withOpacity(0.85)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _rp(amount),
              style: _ts(16, FontWeight.w700, Colors.white, ls: -0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsBanner() {
    final green = _p.isDark ? _incomeGreen : const Color(0xFF059669);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _p.isDark ? _op(_incomeGreen, 0.10) : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _op(_incomeGreen, 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _op(_incomeGreen, 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.savings_outlined, size: 18, color: green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: _ts(13, FontWeight.w500, _p.text, height: 1.4),
                children: [
                  const TextSpan(text: 'Kamu lebih hemat '),
                  TextSpan(
                    text: 'Rp 600.000 ',
                    style: _ts(13, FontWeight.w800, green, height: 1.4),
                  ),
                  const TextSpan(text: 'dibanding bulan lalu.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. ARUS KAS
  // ===========================================================================
  Widget _buildCashFlowCard() {
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
              onSelected: (val) => setState(() => _cashFlowFilter = val),
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
          Row(
            children: [
              _buildChartLegend('Pemasukan', _incomeGreen),
              const SizedBox(width: 16),
              _buildChartLegend('Pengeluaran', _expenseRed),
            ],
          ),
          const SizedBox(height: 16),
          _buildCashFlowBarVisual(),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: _ts(12, FontWeight.w500, _p.muted)),
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

  Widget _buildCashFlowBarVisual() {
    final data = _cashFlowData[_cashFlowFilter] ?? _cashFlowData['Bulan Ini']!;
    const chartHeight = 150.0;
    const labelArea = 26.0;
    const barMax = chartHeight - labelArea - 4;
    final barW = data.length > 6 ? 6.0 : 10.0;

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
                  children: data.map((b) {
                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _chartBar(barMax * b.income * t, _incomeGreen, barW),
                              const SizedBox(width: 3),
                              _chartBar(barMax * b.expense * t, _expenseRed, barW),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 16,
                            child: Text(
                              b.label,
                              maxLines: 1,
                              style: _ts(11, FontWeight.w500, _p.muted),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
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
                  .map((c) => DonutSection(value: c.pct, color: c.color))
                  .toList(),
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total', style: _ts(11, FontWeight.w500, _p.muted)),
                  Text(
                    _rpJt(_expense),
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
            () => _showNotification(context, 'Membuka rincian kategori pengeluaran...'),
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
          Text('${c.pct.toInt()}%', style: _ts(12.5, FontWeight.w700, _p.text)),
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

    late final String statusLabel;
    late final Color statusColor;
    late final Color donutColor;
    if (ratio >= 0.9) {
      statusLabel = 'Kritis';
      statusColor = _expenseRed;
      donutColor = _expenseRed;
    } else if (ratio >= 0.75) {
      statusLabel = 'Waspada';
      statusColor = _honeyGold;
      donutColor = _honeyGold;
    } else {
      statusLabel = 'Aman';
      statusColor = _incomeGreen;
      donutColor = _brandBlue;
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
              sections: [DonutSection(value: percent.toDouble(), color: donutColor)],
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
          _budgetStat('Terpakai', _rpJt(_budgetUsed)),
          const SizedBox(height: 8),
          _budgetStat('Sisa', _rpJt(left)),
          const Spacer(),
          const SizedBox(height: 4),
          _linkButton(
            'Lihat detail',
            _brandBlue,
            () => _showNotification(context, 'Membuka rincian alokasi anggaran...'),
          ),
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
  // 6. TUJUAN KEUANGAN
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
          const SizedBox(height: 16),
          Material(
            color: _p.surfaceAlt,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_kRadiusInner),
              side: BorderSide(color: _p.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _showNotification(
                context,
                'Detail Tujuan: Dana Liburan ($percent% terkumpul)',
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _op(_honeyGold, 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.flight_takeoff_rounded, size: 22, color: _honeyGold),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dana Liburan', style: _ts(14, FontWeight.w700, _p.text)),
                              const SizedBox(height: 2),
                              Text(
                                'Target ${_rp(_goalTarget)}',
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
                          'Terkumpul ${_rp(_goalSaved)}',
                          style: _ts(12, FontWeight.w600, _p.text),
                        ),
                        Text(
                          'Kurang ${_rp(_goalTarget - _goalSaved)}',
                          style: _ts(12, FontWeight.w500, _p.muted),
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
          _linkButton(
            'Lihat detail',
            purpleText,
            () => _showNotification(context, 'Rekomendasi: tekan pengeluaran kuliner minggu ini.'),
          ),
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
                  onPressed: () => _showNotification(
                    context,
                    'Memproses unduhan Laporan_Keuangan_MyKas.pdf...',
                  ),
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
                  onPressed: () => _showNotification(
                    context,
                    'Memproses unduhan Laporan_Keuangan_MyKas.csv...',
                  ),
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
            onPressed: () => _showNotification(context, 'Membuka pencatatan transaksi...'),
          ),
        ],
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
