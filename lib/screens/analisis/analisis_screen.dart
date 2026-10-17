import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_icons.dart';

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
  String _selectedRentang = 'Bulan Ini';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = theme.scaffoldBackgroundColor;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = theme.colorScheme.outline.withOpacity(isDark ? 0.3 : 0.12);
    final textColor = theme.colorScheme.onSurface;
    final textMuted = theme.colorScheme.onSurfaceVariant;

    const brandBlue = Color(0xFF2563EB);
    const honeyGold = Color(0xFFF59E0B);
    const incomeGreen = Color(0xFF10B981);
    const expenseRed = Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isDesktop ? 1000 : 520),
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 28.0 : 18.0,
                    vertical: 20.0,
                  ),
                  physics: const ClampingScrollPhysics(),
                  children: [
                    // =========================================================
                    // 1. HEADER & DROPDOWN ACCENT
                    // =========================================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Analisis Kas',
                              style: GoogleFonts.inter(
                                fontSize: isDesktop ? 28 : 22,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Kesehatan finansial & alokasi kas',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: brandBlue.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: brandBlue.withOpacity(0.3)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedRentang,
                              dropdownColor: cardBg,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: brandBlue,
                              ),
                              icon: const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(AppIcons.chevronRight, size: 14, color: brandBlue),
                              ),
                              items: ['Minggu Ini', 'Bulan Ini', 'Tahun Ini']
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedRentang = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // =========================================================
                    // 2. BENTO CARD 1: HERO CASHFLOW HIGHLIGHT
                    // =========================================================
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildHeroMetric(
                                  label: 'Pemasukan',
                                  value: 'Rp 8.500.000',
                                  icon: AppIcons.arrowUpRight,
                                  color: incomeGreen,
                                  textColor: textColor,
                                  textMuted: textMuted,
                                ),
                              ),
                              Container(height: 40, width: 1, color: borderColor),
                              Expanded(
                                child: _buildHeroMetric(
                                  label: 'Pengeluaran',
                                  value: 'Rp 2.804.178',
                                  icon: AppIcons.arrowDownLeft,
                                  color: expenseRed,
                                  textColor: textColor,
                                  textMuted: textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: honeyGold.withOpacity(isDark ? 0.12 : 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: honeyGold.withOpacity(0.25)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: honeyGold,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(AppIcons.sparkles, color: Colors.black, size: 13),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Kondisi Kas Safe Zone',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? textColor : const Color(0xFF92400E),
                                        ),
                                      ),
                                      Text(
                                        'Pengeluaran harian Rp 93.472 (Turun 12% dari minggu lalu).',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: isDark ? textMuted : const Color(0xFFB45309),
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
                    const SizedBox(height: 16),

                    // =========================================================
                    // 3. BENTO CARD 2: DONUT CHART + CATEGORY PROGRESS
                    // =========================================================
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Porsi Pengeluaran Kas',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              // Interactive Ring Visual
                              SizedBox(
                                width: 105,
                                height: 105,
                                child: CustomPaint(
                                  painter: DonutChartPainter(
                                    sections: [
                                      const DonutSection(value: 44.5, color: Color(0xFFF97316)),
                                      const DonutSection(value: 30.3, color: Color(0xFF8B5CF6)),
                                      const DonutSection(value: 13.7, color: Color(0xFF00AED6)),
                                      const DonutSection(value: 11.5, color: Color(0xFFEAB308)),
                                    ],
                                    backgroundColor: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Total Porsi',
                                          style: GoogleFonts.inter(fontSize: 9.5, color: textMuted),
                                        ),
                                        Text(
                                          '100%',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Interactive Category List
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildCategoryProgressItem('Kuliner & Makanan', '44.5%', 'Rp 1.250.000', const Color(0xFFF97316), textColor, textMuted, isDark),
                                    const SizedBox(height: 10),
                                    _buildCategoryProgressItem('Kebutuhan Harian', '30.3%', 'Rp 850.000', const Color(0xFF8B5CF6), textColor, textMuted, isDark),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(color: borderColor, height: 1),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildCategoryProgressItem('Layanan Antar', '13.7%', 'Rp 384.178', const Color(0xFF00AED6), textColor, textMuted, isDark)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildCategoryProgressItem('Utilitas & Tagihan', '11.5%', 'Rp 320.000', const Color(0xFFEAB308), textColor, textMuted, isDark)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // =========================================================
                    // 4. BENTO GRID 2 KOLOM BERDAMPINGAN: BUDGET & CHART
                    // =========================================================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Budget Bento Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
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
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ),
                                    Text(
                                      '62%',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: brandBlue,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 6,
                                        width: double.infinity,
                                        color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                                      ),
                                      FractionallySizedBox(
                                        widthFactor: 0.62,
                                        child: Container(
                                          height: 6,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color: brandBlue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Sisa Rp 1.695.822\ndari Rp 4.500.000',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    color: textMuted,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Trend Chart Bento Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tren Pekanan',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildSlimBarChart(isDark, textMuted, brandBlue),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // =========================================================
                    // 5. BENTO CARD 4: TAGIHAN RUTIN (HORIZONTAL CHIPS)
                    // =========================================================
                    Container(
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
                              Text(
                                'Tagihan Rutin Mendatang',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                '2 Tagihan',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: honeyGold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildBentoBillChip('Spotify Family', 'Rp 86.900', '3 hari lagi', brandBlue, isDark, textColor, textMuted),
                                const SizedBox(width: 10),
                                _buildBentoBillChip('Indihome 30Mbps', 'Rp 340.000', '8 hari lagi', honeyGold, isDark, textColor, textMuted),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER BENTO WIDGETS
  // ---------------------------------------------------------------------------

  Widget _buildHeroMetric({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color textColor,
    required Color textMuted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 12, color: color),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryProgressItem(
    String category,
    String percentage,
    String amount,
    Color color,
    Color textColor,
    Color textMuted,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  category,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
            Text(
              amount,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Container(
            height: 3,
            width: double.infinity,
            color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: double.parse(percentage.replaceAll('%', '')) / 100,
              child: Container(color: color),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlimBarChart(bool isDark, Color textMuted, Color brandBlue) {
    final weeks = [
      {'label': 'M1', 'value': 0.4},
      {'label': 'M2', 'value': 0.85},
      {'label': 'M3', 'value': 0.55},
      {'label': 'M4', 'value': 0.3},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weeks.map((w) {
        final double heightFactor = w['value'] as double;
        return Column(
          children: [
            Container(
              height: 42,
              width: 14,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: heightFactor,
                child: Container(
                  decoration: BoxDecoration(
                    color: heightFactor > 0.75 ? const Color(0xFFEF4444) : brandBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              w['label'] as String,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: textMuted,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildBentoBillChip(
    String title,
    String amount,
    String dueDate,
    Color accentColor,
    bool isDark,
    Color textColor,
    Color textMuted,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 28,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$dueDate • $amount',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  color: textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// DONUT CHART PAINTER
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
    final double strokeWidth = 10.0;
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

      final double gap = 0.06;
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
