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
    final borderColor = theme.colorScheme.outline.withOpacity(isDark ? 0.35 : 0.2);
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
                  padding: EdgeInsets.all(isDesktop ? 28.0 : 16.0),
                  physics: const ClampingScrollPhysics(),
                  children: [
                    // ==========================================
                    // 1. HEADER & FILTER RENTANG WAKTU
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
                                'Analisis Keuangan',
                                style: GoogleFonts.urbanist(
                                  fontSize: isDesktop ? 26 : 20,
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Rincian alokasi & kesehatan kas',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: borderColor),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedRentang,
                              dropdownColor: cardBg,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: brandBlue,
                              ),
                              icon: const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(AppIcons.chevronRight, size: 13, color: brandBlue),
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
                    const SizedBox(height: 16),

                    // ==========================================
                    // 2. METRIK UTAMA 2 KOLOM
                    // ==========================================
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            title: 'Pemasukan',
                            amount: 'Rp 8.500.000',
                            icon: AppIcons.arrowUpRight,
                            iconColor: incomeGreen,
                            cardBg: cardBg,
                            borderColor: borderColor,
                            textColor: textColor,
                            textMuted: textMuted,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricCard(
                            title: 'Pengeluaran',
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
                    const SizedBox(height: 12),

                    // ==========================================
                    // 3. BUDGET & INSIGHT 2 KOLOM BERDAMPINGAN
                    // ==========================================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildBudgetCard(cardBg, borderColor, textColor, textMuted, isDark, brandBlue),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildInsightCard(cardBg, borderColor, textColor, textMuted, isDark, honeyGold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ==========================================
                    // 4. BREAKDOWN KATEGORI PENGELUARAN
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
  // WIDGET CARD: METRIK UTAMA
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
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
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 12, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: GoogleFonts.urbanist(
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET CARD: PENGGUNAAN BUDGET
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
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
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: brandBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '62%',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: brandBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
            'Sisa Rp 1.695.822 dari Rp 4.500.000',
            style: TextStyle(
              fontSize: 9.5,
              color: textMuted,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET CARD: SMART INSIGHT
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: honeyGold.withOpacity(isDark ? 0.35 : 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: honeyGold.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(AppIcons.sparkles, color: honeyGold, size: 12),
              ),
              const SizedBox(width: 6),
              Text(
                'Status Kas',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? textColor : const Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Pengeluaran hemat 12% dibanding minggu lalu. Kondisi aman!',
            style: TextStyle(
              fontSize: 9.5,
              color: isDark ? textMuted : const Color(0xFFB45309),
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET CARD: BREAKDOWN KATEGORI PENGELUARAN
  // ==========================================
  Widget _buildCategoryCard(
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color textMuted,
    bool isDark,
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
          Text(
            'Kategori Pengeluaran Terbesar',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 14),
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
          Divider(color: borderColor, height: 18),
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
          Divider(color: borderColor, height: 18),
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
          Divider(color: borderColor, height: 18),
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
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: iconBg.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 15, color: iconBg),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Porsi $percentage',
                    style: TextStyle(fontSize: 10, color: textMuted),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: GoogleFonts.urbanist(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Stack(
            children: [
              Container(
                height: 4,
                width: double.infinity,
                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(3),
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
