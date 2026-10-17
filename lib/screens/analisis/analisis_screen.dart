import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  // State Filter Periode
  String _selectedSegment = 'Bulan';
  String _selectedDateRange = '1 – 31 Oktober 2026';
  String _cashFlowFilter = 'Bulan Ini';

  // Toggle Empty State
  final bool _isEmptyState = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = theme.colorScheme.outline.withOpacity(isDark ? 0.35 : 0.12);
    final textColor = theme.colorScheme.onSurface;
    final textMuted = theme.colorScheme.onSurfaceVariant;

    // Warna Aksen Utama MyKas
    const brandBlue = Color(0xFF2563EB); // Soft Royal Blue
    const brandBlueDark = Color(0xFF1D4ED8);
    const incomeGreen = Color(0xFF10B981); // Indicator Pemasukan
    const expenseRed = Color(0xFFEF4444);  // Indicator Pengeluaran
    const honeyGold = Color(0xFFF59E0B);   // Highlight / Goals
    const accentPurple = Color(0xFF8B5CF6);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Analisis',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: textColor, size: 22),
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
                    horizontal: isDesktop ? 28.0 : 18.0,
                    vertical: 12.0,
                  ),
                  physics: const ClampingScrollPhysics(),
                  children: [
                    // =========================================================
                    // 1. FILTER PERIODE (SEGMEN & DATE SELECTOR)
                    // =========================================================
                    _buildSegmentedFilter(cardBg, borderColor, textColor, textMuted, brandBlue, isDark),
                    const SizedBox(height: 12),
                    _buildDateRangeSelector(cardBg, borderColor, textColor, textMuted, isDark),
                    const SizedBox(height: 18),

                    if (_isEmptyState)
                      _buildEmptyState(cardBg, borderColor, textColor, textMuted, brandBlue)
                    else ...[
                      // =========================================================
                      // 2. RINGKASAN KEUANGAN (HERO CARD MYKAS ROYAL BLUE)
                      // =========================================================
                      _buildFinancialSummaryHero(cardBg, borderColor, textColor, textMuted, brandBlue, brandBlueDark, incomeGreen, expenseRed, isDark),
                      const SizedBox(height: 18),

                      // =========================================================
                      // 3. ANALISIS ARUS KAS (CASH FLOW CHART)
                      // =========================================================
                      _buildCashFlowCard(cardBg, borderColor, textColor, textMuted, incomeGreen, expenseRed, brandBlue, isDark),
                      const SizedBox(height: 18),

                      // =========================================================
                      // 4 & 5. BENTO GRID 2 KOLOM: PENGELUARAN & ANGGARAN
                      // =========================================================
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildExpenseAnalysisCard(cardBg, borderColor, textColor, textMuted, accentPurple, isDark),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBudgetAnalysisCard(cardBg, borderColor, textColor, textMuted, brandBlue, isDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // =========================================================
                      // 6. TUJUAN KEUANGAN (FINANCIAL GOALS)
                      // =========================================================
                      _buildFinancialGoalsCard(cardBg, borderColor, textColor, textMuted, brandBlue, honeyGold, isDark),
                      const SizedBox(height: 18),

                      // =========================================================
                      // 7. INSIGHT KEUANGAN (SMART AI ADVICE)
                      // =========================================================
                      _buildFinancialInsightCard(cardBg, borderColor, textColor, textMuted, accentPurple, isDark),
                      const SizedBox(height: 18),

                      // =========================================================
                      // 8. LAPORAN KEUANGAN (EXPORT PDF / CSV)
                      // =========================================================
                      _buildReportExportCard(cardBg, borderColor, textColor, textMuted, brandBlue, isDark),
                      const SizedBox(height: 28),
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
  // INTERACTION HELPERS
  // ===========================================================================
  void _showNotification(BuildContext context, String title) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          title,
          style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _selectDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2027),
      initialDateRange: DateTimeRange(
        start: DateTime(2026, 10, 1),
        end: DateTime(2026, 10, 31),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF2563EB),
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = '${picked.start.day} – ${picked.end.day} Oktober 2026';
      });
    }
  }

  // ===========================================================================
  // 1. FILTER PERIODE WIDGETS
  // ===========================================================================
  Widget _buildSegmentedFilter(Color cardBg, Color borderColor, Color textColor, Color textMuted, Color brandBlue, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 42,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: ['Minggu', 'Bulan', 'Tahun'].map((segment) {
                final isSelected = _selectedSegment == segment;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSegment = segment;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: isSelected ? brandBlue : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        segment,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : textMuted,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: IconButton(
            icon: Icon(Icons.calendar_month_outlined, size: 18, color: textColor),
            onPressed: _selectDateRangePicker,
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeSelector(Color cardBg, Color borderColor, Color textColor, Color textMuted, bool isDark) {
    return GestureDetector(
      onTap: _selectDateRangePicker,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_outlined, size: 14, color: textMuted),
          const SizedBox(width: 6),
          Text(
            _selectedDateRange,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 14, color: textMuted),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. RINGKASAN KEUANGAN (HERO CARD - ROYAL BLUE MYKAS)
  // ===========================================================================
  Widget _buildFinancialSummaryHero(Color cardBg, Color borderColor, Color textColor, Color textMuted, Color brandBlue, Color brandBlueDark, Color incomeGreen, Color expenseRed, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Total Balance Flow Gradient Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E40AF), const Color(0xFF2563EB)]
                    : [const Color(0xFF2563EB), const Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Total Arus Kas Clean',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _showNotification(context, 'Total akumulasi arus kas bersih periode berjalan'),
                          child: Icon(Icons.info_outline, size: 13, color: Colors.white.withOpacity(0.8)),
                        ),
                      ],
                    ),
                    Icon(Icons.account_balance_wallet_outlined, size: 28, color: Colors.white.withOpacity(0.9)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Rp 2.800.000',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_upward, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '12% dibanding bulan lalu',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Inflow & Outflow Metrics Split
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildFlowMetricItem(
                        title: 'Pemasukan',
                        amount: 'Rp 8.000.000',
                        icon: Icons.arrow_upward,
                        iconBg: incomeGreen.withOpacity(0.12),
                        iconColor: incomeGreen,
                        textColor: textColor,
                        textMuted: textMuted,
                      ),
                    ),
                    Expanded(
                      child: _buildFlowMetricItem(
                        title: 'Pengeluaran',
                        amount: 'Rp 5.200.000',
                        icon: Icons.arrow_downward,
                        iconBg: expenseRed.withOpacity(0.12),
                        iconColor: expenseRed,
                        textColor: textColor,
                        textMuted: textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Saving Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: incomeGreen.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: incomeGreen.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.savings_outlined, size: 14, color: incomeGreen),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(fontSize: 11.5, color: textColor),
                            children: [
                              const TextSpan(text: 'Kamu lebih hemat '),
                              TextSpan(
                                text: 'Rp 600.000 ',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: incomeGreen),
                              ),
                              const TextSpan(text: 'dibanding bulan lalu.'),
                            ],
                          ),
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
    );
  }

  Widget _buildFlowMetricItem({
    required String title,
    required String amount,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color textColor,
    required Color textMuted,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(fontSize: 11, color: textMuted, fontWeight: FontWeight.w500)),
            const SizedBox(height: 1),
            Text(amount, style: GoogleFonts.inter(fontSize: 13.5, color: textColor, fontWeight: FontWeight.w800)),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // 3. ANALISIS ARUS KAS (CASH FLOW CHART CARD)
  // ===========================================================================
  Widget _buildCashFlowCard(Color cardBg, Color borderColor, Color textColor, Color textMuted, Color incomeGreen, Color expenseRed, Color brandBlue, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.bar_chart_rounded, size: 16, color: brandBlue),
                  const SizedBox(width: 8),
                  Text(
                    'Cash Flow',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                onSelected: (val) {
                  setState(() {
                    _cashFlowFilter = val;
                  });
                },
                color: cardBg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'Bulan Ini', child: Text('Bulan Ini', style: GoogleFonts.inter(fontSize: 12, color: textColor))),
                  PopupMenuItem(value: '3 Bulan', child: Text('3 Bulan Terakhir', style: GoogleFonts.inter(fontSize: 12, color: textColor))),
                  PopupMenuItem(value: 'Tahun Ini', child: Text('Tahun Ini', style: GoogleFonts.inter(fontSize: 12, color: textColor))),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Text(_cashFlowFilter, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: textColor)),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 12, color: textMuted),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildChartLegend('Pemasukan', incomeGreen, textMuted),
              const SizedBox(width: 12),
              _buildChartLegend('Pengeluaran', expenseRed, textMuted),
            ],
          ),
          const SizedBox(height: 12),
          // Bar Chart Visual
          _buildCashFlowBarVisual(isDark, textMuted, incomeGreen, expenseRed),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color, Color textMuted) {
    return Row(
      children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.inter(fontSize: 10.5, color: textMuted, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildCashFlowBarVisual(bool isDark, Color textMuted, Color inColor, Color outColor) {
    final barsData = [
      {'d': '1', 'in': 0.8, 'out': 0.55},
      {'d': '7', 'in': 0.68, 'out': 0.45},
      {'d': '14', 'in': 0.72, 'out': 0.42},
      {'d': '21', 'in': 0.65, 'out': 0.40},
      {'d': '28', 'in': 0.82, 'out': 0.48},
    ];

    return SizedBox(
      height: 110,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: barsData.map((b) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 75 * (b['in'] as double),
                    width: 7,
                    decoration: BoxDecoration(color: inColor, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    height: 75 * (b['out'] as double),
                    width: 7,
                    decoration: BoxDecoration(color: outColor, borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(b['d'] as String, style: GoogleFonts.inter(fontSize: 10, color: textMuted, fontWeight: FontWeight.w500)),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ===========================================================================
  // 4. ANALISIS PENGELUARAN (BENTO CARD LEFT)
  // ===========================================================================
  Widget _buildExpenseAnalysisCard(Color cardBg, Color borderColor, Color textColor, Color textMuted, Color accentPurple, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_outline, size: 15, color: accentPurple),
              const SizedBox(width: 6),
              Text('Pengeluaran', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: textColor)),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: SizedBox(
              width: 85,
              height: 85,
              child: CustomPaint(
                painter: DonutChartPainter(
                  sections: const [
                    DonutSection(value: 35, color: Color(0xFFF97316)),
                    DonutSection(value: 25, color: Color(0xFF8B5CF6)),
                    DonutSection(value: 20, color: Color(0xFF3B82F6)),
                  ],
                  backgroundColor: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Total', style: GoogleFonts.inter(fontSize: 8.5, color: textMuted)),
                      Text('Rp 5.2m', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w800, color: textColor)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _buildExpenseCategoryRow('Makanan', '35%', 'Rp 1.820.000', const Color(0xFFF97316), textColor),
          const SizedBox(height: 6),
          _buildExpenseCategoryRow('Belanja', '25%', 'Rp 1.300.000', const Color(0xFF8B5CF6), textColor),
          const SizedBox(height: 6),
          _buildExpenseCategoryRow('Tagihan', '20%', 'Rp 1.040.000', const Color(0xFF3B82F6), textColor),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => _showNotification(context, 'Membuka seluruh rincian kategori pengeluaran...'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Lihat semua', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: accentPurple)),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right, size: 12, color: accentPurple),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCategoryRow(String title, String percent, String amount, Color color, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text(title, style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w500, color: textColor)),
          ],
        ),
        Text(percent, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: textColor)),
      ],
    );
  }

  // ===========================================================================
  // 5. ANALISIS ANGGARAN (BENTO CARD RIGHT - SOFT ROYAL BLUE)
  // ===========================================================================
  Widget _buildBudgetAnalysisCard(Color cardBg, Color borderColor, Color textColor, Color textMuted, Color brandBlue, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.track_changes, size: 15, color: brandBlue),
              const SizedBox(width: 6),
              Text('Anggaran', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: textColor)),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: SizedBox(
              width: 85,
              height: 85,
              child: CustomPaint(
                painter: DonutChartPainter(
                  sections: [
                    DonutSection(value: 70, color: brandBlue),
                  ],
                  backgroundColor: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('70%', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: textColor)),
                      Text('terpakai', style: GoogleFonts.inter(fontSize: 8.5, color: textMuted)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Rp 3.5m / Rp 5.0m', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: textColor)),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 5,
              width: double.infinity,
              color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.7,
                child: Container(color: brandBlue),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet, size: 12, color: brandBlue),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sisa anggaran', style: GoogleFonts.inter(fontSize: 8.5, color: textMuted)),
                    Text('Rp 1.500.000', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w800, color: textColor)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: TextButton(
              onPressed: () => _showNotification(context, 'Membuka rincian alokasi anggaran...'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Lihat detail', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: brandBlue)),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right, size: 12, color: brandBlue),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 6. TUJUAN KEUANGAN (FINANCIAL GOALS CARD)
  // ===========================================================================
  Widget _buildFinancialGoalsCard(Color cardBg, Color borderColor, Color textColor, Color textMuted, Color brandBlue, Color honeyGold, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.emoji_events_outlined, size: 16, color: honeyGold),
                  const SizedBox(width: 8),
                  Text('Tujuan Keuangan', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: textColor)),
                ],
              ),
              Text('1 tujuan aktif', style: GoogleFonts.inter(fontSize: 11, color: textMuted, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => _showNotification(context, 'Detail Tujuan: Dana Liburan (60% Terkumpul)'),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: brandBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.flight_takeoff, size: 20, color: Color(0xFF2563EB)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dana Liburan', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: textColor)),
                        const SizedBox(height: 2),
                        Text('Rp 6.000.000 / Rp 10.000.000', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: textMuted)),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Container(
                            height: 4,
                            width: double.infinity,
                            color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 0.6,
                              child: Container(color: brandBlue),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('60%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: textColor)),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 14, color: textMuted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 7. INSIGHT KEUANGAN (SMART AI ADVICE CARD)
  // ===========================================================================
  Widget _buildFinancialInsightCard(Color cardBg, Color borderColor, Color textColor, Color textMuted, Color accentPurple, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentPurple.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, size: 16, color: accentPurple),
                  const SizedBox(width: 8),
                  Text('Insight Keuangan', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w800, color: textColor)),
                ],
              ),
              Icon(Icons.insights, size: 16, color: accentPurple),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Pengeluaran makanan naik 15% dibanding bulan lalu.',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: textColor),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => _showNotification(context, 'Rekomendasi AI: Tekan pengeluaran kuliner minggu ini.'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Lihat detail', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: accentPurple)),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right, size: 12, color: accentPurple),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 8. LAPORAN KEUANGAN (EXPORT PDF / CSV CARD)
  // ===========================================================================
  Widget _buildReportExportCard(Color cardBg, Color borderColor, Color textColor, Color textMuted, Color brandBlue, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_outlined, size: 18, color: textColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Laporan Keuangan', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w800, color: textColor)),
                    Text('Unduh laporan lengkap dalam format PDF atau CSV.', style: GoogleFonts.inter(fontSize: 10.5, color: textMuted)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 16, color: textMuted),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: Icon(Icons.download_outlined, size: 14, color: textColor),
                  label: Text('Export PDF', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: textColor)),
                  onPressed: () => _showNotification(context, 'Memproses unduhan Laporan_Keuangan_MyKas.pdf...'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandBlue,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.download, size: 14, color: Colors.white),
                  label: Text('Export CSV', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white)),
                  onPressed: () => _showNotification(context, 'Memproses unduhan Laporan_Keuangan_MyKas.csv...'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color cardBg, Color borderColor, Color textColor, Color textMuted, Color brandBlue) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: brandBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.analytics_outlined, size: 32, color: brandBlue),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Transaksi Cukup',
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: textColor),
          ),
          const SizedBox(height: 6),
          Text(
            'Lakukan pencatatan pemasukan dan pengeluaran secara rutin untuk melihat analisis grafik lengkap.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 12, color: textMuted, height: 1.4),
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

  DonutChartPainter({required this.sections, required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 8.0;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (min(size.width, size.height) - strokeWidth) / 2;

    final Paint bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    final double total = sections.fold(0, (sum, section) => sum + section.value);
    if (total == 0) return;

    double startAngle = -pi / 2;

    for (var section in sections) {
      final double sweepAngle = (section.value / total) * 2 * pi;
      final Paint sectionPaint = Paint()
        ..color = section.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final double gap = 0.08;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + gap,
        max(0, sweepAngle - gap * 2),
        false,
        sectionPaint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) => true;
}
