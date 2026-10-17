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
    final borderColor = theme.colorScheme.outline.withOpacity(isDark ? 0.35 : 0.12);
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
                constraints: BoxConstraints(maxWidth: isDesktop ? 1100 : 540),
                child: ListView(
                  padding: EdgeInsets.all(isDesktop ? 32.0 : 20.0),
                  physics: const ClampingScrollPhysics(),
                  children: [
                    // ==========================================
                    // 1. HEADER & PREMIUM FILTER SELECTOR (SIMPLICITY)
                    // ==========================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Analisis Kas',
                                style: GoogleFonts.urbanist(
                                  fontSize: isDesktop ? 28 : 22,
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ringkasan kesehatan finansial & alokasi',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textMuted,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: borderColor),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedRentang,
                              dropdownColor: cardBg,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: brandBlue,
                              ),
                              icon: const Padding(
                                padding: EdgeInsets.only(left: 6),
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
                    const SizedBox(height: 24),

                    // ==========================================
                    // 2. CASHFLOW METRICS (VISUAL HIERARCHY - LEVEL 1)
                    // ==========================================
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            title: 'Total Pemasukan',
                            amount: 'Rp 8.500.000',
                            icon: AppIcons.arrowUpRight,
                            iconColor: incomeGreen,
                            cardBg: cardBg,
                            borderColor: borderColor,
                            textColor: textColor,
                            textMuted: textMuted,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildMetricCard(
                            title: 'Total Keluar',
                            amount: 'Rp 2.804.178',
                            icon: AppIcons.arrowDownLeft,
                            iconColor: expenseRed,
                            cardBg: cardBg,
                            borderColor: borderColor,
                            textColor: textColor,
                            textMuted: textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ==========================================
                    // 3. BUDGET STATUS & SMART INSIGHT (LEVEL 2)
                    // ==========================================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildBudgetCard(cardBg, borderColor, textColor, textMuted, isDark, brandBlue),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildInsightCard(cardBg, borderColor, textColor, textMuted, isDark, honeyGold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ==========================================
                    // 4. BREAKDOWN KATEGORI PENGELUARAN (LEVEL 3)
                    // ==========================================
                    _buildCategoryCard(cardBg, borderColor, textColor, textMuted, isDark),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // METRIC CARD WIDGET (FLAT & CLEAN)
  // ==========================================
  Widget _buildMetricCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color iconColor,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color textMuted,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: textMuted,
                  letterSpacing: -0.1,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: GoogleFonts.urbanist(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BUDGET USAGE CARD WIDGET
  // ==========================================
  Widget _buildBudgetCard(
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color textMuted,
    bool isDark,
    Color brandBlue,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Porsi Budget',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: BoxDecoration(
                  color: brandBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '62%',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: brandBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
                      gradient: LinearGradient(
                        colors: [brandBlue, const Color(0xFF3B82F6)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Sisa Rp 1.695.822',
            style: TextStyle(
              fontSize: 11,
              color: textMuted,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SMART INSIGHT CARD WIDGET
  // ==========================================
  Widget _buildInsightCard(
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color textMuted,
    bool isDark,
    Color honeyGold,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: honeyGold.withOpacity(isDark ? 0.35 : 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: honeyGold.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(AppIcons.sparkles, color: honeyGold, size: 13),
              ),
              const SizedBox(width: 8),
              Text(
                'Financial Insight',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? textColor : const Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Pengeluaran turun 12% dari minggu lalu. Pertahankan!',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? textMuted : const Color(0xFFB45309),
              height: 1.35,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CATEGORY BREAKDOWN CARD WIDGET
  // ==========================================
  Widget _buildCategoryCard(
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color textMuted,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
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
                'Pengeluaran Berdasarkan Porsi',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                'Top 4',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildCategoryRow(
            'Kuliner & Makanan',
            'Rp 1.250.000',
            '44.5%',
            0.445,
            AppIcons.utensils,
            const Color(0xFFF97316),
            textColor,
            textMuted,
            isDark,
          ),
          Divider(color: borderColor, height: 24),
          _buildCategoryRow(
            'Kebutuhan Harian',
            'Rp 850.000',
            '30.3%',
            0.303,
            AppIcons.shoppingCart,
            const Color(0xFF8B5CF6),
            textColor,
            textMuted,
            isDark,
          ),
          Divider(color: borderColor, height: 24),
          _buildCategoryRow(
            'Layanan Antar / GoFood',
            'Rp 384.178',
            '13.7%',
            0.137,
            AppIcons.shoppingBag,
            const Color(0xFF00AED6),
            textColor,
            textMuted,
            isDark,
          ),
          Divider(color: borderColor, height: 24),
          _buildCategoryRow(
            'Utilitas & Tagihan',
            'Rp 320.000',
            '11.5%',
            0.115,
            AppIcons.zap,
            const Color(0xFFEAB308),
            textColor,
            textMuted,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(
    String category,
    String amount,
    String percentage,
    double progress,
    IconData icon,
    Color iconBg,
    Color textColor,
    Color textMuted,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: iconBg.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 17, color: iconBg),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Porsi $percentage',
                    style: TextStyle(fontSize: 11, color: textMuted),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: GoogleFonts.urbanist(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: -0.3,
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
                height: 5.5,
                width: double.infinity,
                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 5.5,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
