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
    final cardBg = theme.colorScheme.surface;
    final borderColor = theme.colorScheme.outline.withOpacity(isDark ? 0.25 : 0.12);
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
                    horizontal: isDesktop ? 32.0 : 20.0,
                    vertical: 24.0,
                  ),
                  physics: const ClampingScrollPhysics(),
                  children: [
                    // =========================================================
                    // 1. HEADER (UNBOXED)
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
                              'Ringkasan kesehatan finansial & alokasi',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor),
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
                    const SizedBox(height: 28),

                    // =========================================================
                    // 2. RINGKASAN ARUS KAS (BORDERLESS SPLIT METRICS)
                    // =========================================================
                    Row(
                      children: [
                        Expanded(
                          child: _buildBorderlessMetric(
                            title: 'Pemasukan',
                            amount: 'Rp 8.500.000',
                            icon: AppIcons.arrowUpRight,
                            iconColor: incomeGreen,
                            textColor: textColor,
                            textMuted: textMuted,
                          ),
                        ),
                        Container(
                          height: 38,
                          width: 1,
                          color: borderColor,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        Expanded(
                          child: _buildBorderlessMetric(
                            title: 'Pengeluaran',
                            amount: 'Rp 2.804.178',
                            icon: AppIcons.arrowDownLeft,
                            iconColor: expenseRed,
                            textColor: textColor,
                            textMuted: textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // =========================================================
                    // 3. INSIGHT BANNER (ACCENTED BANNER)
                    // =========================================================
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: honeyGold.withOpacity(isDark ? 0.35 : 0.25)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: honeyGold.withOpacity(0.18),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(AppIcons.sparkles, color: honeyGold, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kondisi Kas Safe Zone',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? textColor : const Color(0xFF92400E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Pengeluaran harian rata-rata Rp 93.472 (Turun 12% dari minggu lalu).',
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
                    const SizedBox(height: 32),

                    // =========================================================
                    // 4. BENTUK VARIASI 1: DONUT RING CHART (KATEGORI PENGELUARAN)
                    // =========================================================
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Porsi Pengeluaran',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            // Ring Chart Visual
                            SizedBox(
                              width: 110,
                              height: 110,
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
                                        'Total',
                                        style: GoogleFonts.inter(fontSize: 10, color: textMuted),
                                      ),
                                      Text(
                                        '100%',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Legenda Kategori
                            Expanded(
                              child: Column(
                                children: [
                                  _buildDonutLegend('Kuliner & Makanan', '44.5%', 'Rp 1.250.000', const Color(0xFFF97316), textColor, textMuted),
                                  const SizedBox(height: 8),
                                  _buildDonutLegend('Kebutuhan Harian', '30.3%', 'Rp 850.000', const Color(0xFF8B5CF6), textColor, textMuted),
                                  const SizedBox(height: 8),
                                  _buildDonutLegend('Layanan Antar', '13.7%', 'Rp 384.178', const Color(0xFF00AED6), textColor, textMuted),
                                  const SizedBox(height: 8),
                                  _buildDonutLegend('Utilitas & Tagihan', '11.5%', 'Rp 320.000', const Color(0xFFEAB308), textColor, textMuted),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),

                    // =========================================================
                    // 5. BENTUK VARIASI 2: PROGRESS GAUGE (BUDGET USAGE)
                    // =========================================================
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Penggunaan Budget Bulan Ini',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            Text(
                              '62% Terpakai',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: brandBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Stack(
                            children: [
                              Container(
                                height: 8,
                                width: double.infinity,
                                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                              ),
                              FractionallySizedBox(
                                widthFactor: 0.62,
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    gradient: const LinearGradient(
                                      colors: [brandBlue, Color(0xFF3B82F6)],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sisa batas budget aman: Rp 1.695.822 dari Rp 4.500.000',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),

                    // =========================================================
                    // 6. BENTUK VARIASI 3: ROUNDED BAR CHART (TREN PEKANAN)
                    // =========================================================
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tren Pengeluaran Pekanan',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildWeeklyInlineChart(isDark, textMuted, brandBlue),
                      ],
                    ),
                    const SizedBox(height: 36),

                    // =========================================================
                    // 7. BENTUK VARIASI 4: HORIZONTAL CHIP LIST (TAGIHAN RUTIN)
                    // =========================================================
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tagihan Mendatang',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildBillChip('Spotify Family', 'Rp 86.900', '3 hari lagi', isDark, borderColor, textColor, textMuted),
                              const SizedBox(width: 10),
                              _buildBillChip('Indihome 30Mbps', 'Rp 340.000', '8 hari lagi', isDark, borderColor, textColor, textMuted),
                            ],
                          ),
                        ),
                      ],
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
  // HELPER WIDGETS
  // ---------------------------------------------------------------------------

  Widget _buildBorderlessMetric({
    required String title,
    required String amount,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
    required Color textMuted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          amount,
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDonutLegend(
    String category,
    String percentage,
    String amount,
    Color color,
    Color textColor,
    Color textMuted,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              category,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
        Text(
          amount,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyInlineChart(bool isDark, Color textMuted, Color brandBlue) {
    final weeks = [
      {'label': 'Minggu 1', 'value': 0.4},
      {'label': 'Minggu 2', 'value': 0.85},
      {'label': 'Minggu 3', 'value': 0.55},
      {'label': 'Minggu 4', 'value': 0.3},
    ];

    return Row(
      children: weeks.map((w) {
        final double heightFactor = w['value'] as double;
        return Expanded(
          child: Column(
            children: [
              Container(
                height: 65,
                width: 26,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(13),
                ),
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: heightFactor,
                  child: Container(
                    decoration: BoxDecoration(
                      color: heightFactor > 0.75 ? const Color(0xFFEF4444) : brandBlue,
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                w['label'] as String,
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: textMuted,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBillChip(
    String title,
    String amount,
    String dueDate,
    bool isDark,
    Color borderColor,
    Color textColor,
    Color textMuted,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
// CUSTOM PAINTER UNTUK DONUT RING CHART
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
    final double strokeWidth = 12.0;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (min(size.width, size.height) - strokeWidth) / 2;

    // Gambar Ring Background
    final Paint bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    // Hitung Total Nilai
    final double total = sections.fold(0, (sum, section) => sum + section.value);
    if (total == 0) return;

    double startAngle = -pi / 2; // Mulai dari atas jam 12

    for (var section in sections) {
      final double sweepAngle = (section.value / total) * 2 * pi;

      final Paint sectionPaint = Paint()
        ..color = section.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Beri sedikit gap kecil antar segmen
      final double gap = 0.05;
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
