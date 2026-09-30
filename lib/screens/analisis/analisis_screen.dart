import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
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
                  padding: EdgeInsets.all(isDesktop ? 28.0 : 18.0),
                  physics: const ClampingScrollPhysics(),
                  children: [
                    // ==========================================
                    // HEADER & FILTER
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
                                  fontSize: isDesktop ? 26 : 22,
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Rincian dan tren alokasi kas bulanan',
                                style: TextStyle(fontSize: 12, color: textMuted),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
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

                    // ==========================================
                    // BODY CONTENT (RESPONSIVE GRID)
                    // ==========================================
                    if (isDesktop) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: _buildBudgetCard(cardBg, borderColor, textColor, textMuted, isDark),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 7,
                            child: _buildCategoryCard(cardBg, borderColor, textColor, textMuted, isDark),
                          ),
                        ],
                      ),
                    ] else ...[
                      _buildBudgetCard(cardBg, borderColor, textColor, textMuted, isDark),
                      const SizedBox(height: 16),
                      _buildCategoryCard(cardBg, borderColor, textColor, textMuted, isDark),
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

  // ==========================================
  // WIDGET CARD: PENGGUNAAN BUDGET
  // ==========================================
  Widget _buildBudgetCard(
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color textMuted,
    bool isDark,
  ) {
    const brandBlue = Color(0xFF2563EB);

    return Container(
      padding: const EdgeInsets.all(20),
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
                'Penggunaan Budget',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: brandBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '62%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: brandBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(
                  height: 10,
                  width: double.infinity,
                  color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                ),
                FractionallySizedBox(
                  widthFactor: 0.62,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        colors: [brandBlue, Color(0xFF3B82F6)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Terpakai Rp 2.804.178 dari batas budget bulanan Rp 4.500.000',
            style: TextStyle(
              fontSize: 11.5,
              color: textMuted,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET CARD: KATEGORI PENGELUARAN
  // ==========================================
  Widget _buildCategoryCard(
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color textMuted,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori Pengeluaran Terbesar',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 18),
          _buildCategoryRow(
            'Kuliner & Makanan',
            'Rp 1.250.000',
            '44.5%',
            AppIcons.utensils,
            const Color(0xFFF97316),
            textColor,
            textMuted,
          ),
          Divider(color: borderColor, height: 24),
          _buildCategoryRow(
            'Kebutuhan Harian',
            'Rp 850.000',
            '30.3%',
            AppIcons.shoppingCart,
            const Color(0xFF8B5CF6),
            textColor,
            textMuted,
          ),
          Divider(color: borderColor, height: 24),
          _buildCategoryRow(
            'Layanan Antar / GoFood',
            'Rp 384.178',
            '13.7%',
            AppIcons.shoppingBag,
            const Color(0xFF00AED6),
            textColor,
            textMuted,
          ),
          Divider(color: borderColor, height: 24),
          _buildCategoryRow(
            'Utilitas & Tagihan',
            'Rp 320.000',
            '11.5%',
            AppIcons.zap,
            const Color(0xFFEAB308),
            textColor,
            textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(
    String category,
    String amount,
    String percentage,
    IconData icon,
    Color iconBg,
    Color textColor,
    Color textMuted,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBg.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: iconBg),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 2),
              Text(
                'Porsi $percentage dari pengeluaran',
                style: TextStyle(fontSize: 11, color: textMuted),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w900, color: textColor),
        ),
      ],
    );
  }
}
