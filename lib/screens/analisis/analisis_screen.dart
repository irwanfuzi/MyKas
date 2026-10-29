import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// =============================================================================
// DESIGN TOKENS (MYKAS FINTECH FLAT PREMIUM)
// =============================================================================
const double _kMaxWidth = 520;
const double _kRadiusCard = 22;
const double _kPadCard = 16;

const Color _brandBlue = Color(0xFF2563EB); // Soft Royal Blue MyKas[cite: 2]
const Color _incomeGreen = Color(0xFF10B981);
const Color _expenseRed = Color(0xFFEF4444);
const Color _honeyGold = Color(0xFFF59E0B); // Honey Gold accent[cite: 2]
const Color _darkSlate = Color(0xFF1E293B); // Dark slate text[cite: 2]
const Color _slate = Color(0xFF94A3B8);

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

// =============================================================================
// MAIN ANALISIS & PERENCANAAN SCREEN
// =============================================================================
class AnalisisScreen extends StatefulWidget {
  final VoidCallback? onAddTransaction;

  const AnalisisScreen({
    super.key,
    this.onAddTransaction,
  });

  @override
  State<AnalisisScreen> createState() => _AnalisisScreenState();
}

class _AnalisisScreenState extends State<AnalisisScreen> {
  // Active Period Selector Pill ('Mingguan', 'Bulanan', 'Tahanan')
  String _activePeriod = 'Bulanan';
  int _currentIndex = 1; // Tab Analisis active in bottom navigation

  void _onPeriodChanged(String period) {
    setState(() {
      _activePeriod = period;
    });
  }

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: _ts(13, FontWeight.w600, Colors.white)),
        backgroundColor: _brandBlue,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Set transparent status bar blending into the blue header canvas[cite: 2]
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: _brandBlue, // Header canvas background Soft Royal Blue[cite: 2]
      body: Column(
        children: [
          // ===================================================================
          // HEADER CANVAS & TOP BAR
          // ===================================================================
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  // Header Title: "Analisis & Perencanaan" in Inter Semi-Bold white typography[cite: 2]
                  Text(
                    'Analisis & Perencanaan',
                    style: _ts(18, FontWeight.w600, Colors.white, ls: -0.3),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),

                  // Interactive Period Selector Pill Buttons (Horizontal Layout)[cite: 2]
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: ['Mingguan', 'Bulanan', 'Tahanan'].map((period) {
                        final isActive = _activePeriod == period;
                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _onPeriodChanged(period),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                // Active pill in Honey Gold (#F59E0B), others transparent[cite: 2]
                                color: isActive ? _honeyGold : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                period,
                                style: _ts(
                                  12,
                                  isActive ? FontWeight.w700 : FontWeight.w500,
                                  // Active pill text dark slate (#1E293B), others white[cite: 2]
                                  isActive ? _darkSlate : Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===================================================================
          // BOTTOM SHEET CONTAINER (WHITE COMPREHENSIVE ANALYTICS PANEL)
          // ===================================================================
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white, // Clean white card background[cite: 2]
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // SECTION 1: Grafik Tren Keuangan (Financial Trend Chart)[cite: 2]
                    _buildTrendSection(),
                    const SizedBox(height: 20),

                    // SECTION 2: Grafik Pengeluaran Berdasarkan Kategori[cite: 2]
                    _buildCategorySpendingSection(),
                    const SizedBox(height: 20),

                    // SECTION 3: List Budget (Active Budget Limits)[cite: 2]
                    _buildBudgetSection(),
                    const SizedBox(height: 20),

                    // SECTION 4: List Tujuan Keuangan (Financial Goals List)[cite: 2]
                    _buildGoalsSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // =======================================================================
      // BOTTOM NAVIGATION BAR (FIXED FOOTER WITH INTERACTIVE BUTTONS)[cite: 2]
      // =======================================================================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_rounded, 'Beranda', 0),
                _buildNavItem(Icons.bar_chart_rounded, 'Analisis', 1),
                // Docked Floating Action Button (+) with Honey Gold ring[cite: 2]
                Transform.translate(
                  offset: const Offset(0, -10),
                  child: GestureDetector(
                    onTap: widget.onAddTransaction ?? () => _showNotification('Tambah Transaksi'),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _brandBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: _honeyGold, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: _brandBlue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                    ),
                  ),
                ),
                _buildNavItem(Icons.receipt_long_rounded, 'Riwayat', 2),
                _buildNavItem(Icons.person_outline_rounded, 'Profil', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    // Index 1 is Analisis (Active highlighted tab in Soft Royal Blue #2563EB)[cite: 2]
    final isSelected = _currentIndex == index;
    final color = isSelected ? _brandBlue : _slate;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        if (index != 1) {
          _showNotification('Navigasi ke $label');
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 3),
          Text(
            label,
            style: _ts(10.5, isSelected ? FontWeight.w700 : FontWeight.w500, color),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SECTION 1: GRAFIK TREN KEUANGAN
  // ===========================================================================
  Widget _buildTrendSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(_kRadiusCard),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: "Tren Arus Kas Bulanan" in Inter Bold, dark slate typography (#1E293B)[cite: 2]
          Text(
            'Tren Arus Kas Bulanan',
            style: _ts(14, FontWeight.w700, _darkSlate),
          ),
          const SizedBox(height: 16),
          // Interactive line/bar chart visualization with income vs expense across weeks[cite: 2]
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTrendBarGroup('M1', 4200000, 3100000),
                _buildTrendBarGroup('M2', 5000000, 3800000),
                _buildTrendBarGroup('M3', 4800000, 3200000), // Active tooltip badge highlight
                _buildTrendBarGroup('M4', 6000000, 4100000),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendBarGroup(String weekLabel, int income, int expense) {
    const double maxVal = 7000000;
    final double incomeHeight = 90 * (income / maxVal);
    final double expenseHeight = 90 * (expense / maxVal);
    final isHighlighted = weekLabel == 'M3';

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isHighlighted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: _darkSlate,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('Rp 1.6jt', style: _ts(9, FontWeight.w700, Colors.white)),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 8,
              height: incomeHeight,
              decoration: BoxDecoration(
                color: _incomeGreen,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 8,
              height: expenseHeight,
              decoration: BoxDecoration(
                color: _expenseRed,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(weekLabel, style: _ts(11, FontWeight.w600, _slate)),
      ],
    );
  }

  // ===========================================================================
  // SECTION 2: GRAFIK PENGELUARAN BERDASARKAN KATEGORI
  // ===========================================================================
  Widget _buildCategorySpendingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(_kRadiusCard),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header: "Pengeluaran Berdasarkan Kategori" in Inter Bold (#1E293B)[cite: 2]
              Text('Pengeluaran Berdasarkan Kategori', style: _ts(14, FontWeight.w700, _darkSlate)),
              // "Detail" action link[cite: 2]
              GestureDetector(
                onTap: () => _showNotification('Buka rincian kategori lengkap'),
                child: Text('Detail', style: _ts(12, FontWeight.w700, _brandBlue)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 3 Category Progress Bars with percentage tags: Kebutuhan Pokok (45%), Transportasi (25%), Tabungan (20%)[cite: 2]
          _buildCategoryProgressItem('Kebutuhan Pokok', 0.45, '45%', _brandBlue),
          const SizedBox(height: 10),
          _buildCategoryProgressItem('Transportasi', 0.25, '25%', _honeyGold),
          const SizedBox(height: 10),
          _buildCategoryProgressItem('Tabungan', 0.20, '20%', _incomeGreen),
        ],
      ),
    );
  }

  Widget _buildCategoryProgressItem(String title, double progress, String percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: _ts(12, FontWeight.w600, _darkSlate)),
            Text(percentage, style: _ts(12, FontWeight.w700, _darkSlate)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SECTION 3: LIST BUDGET (ACTIVE BUDGET LIMITS)
  // ===========================================================================
  Widget _buildBudgetSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(_kRadiusCard),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header Row: "Status Budget Bulanan" in Inter Bold (#1E293B)[cite: 2]
              Text('Status Budget Bulanan', style: _ts(14, FontWeight.w700, _darkSlate)),
              // "Atur" action button in primary blue[cite: 2]
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(40, 24),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => _showNotification('Atur anggaran bulanan'),
                child: Text('Atur', style: _ts(12, FontWeight.w700, _brandBlue)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Budget Card Item: "Budget Makanan & Belanja" showing spent "Rp 3.200.000 / Rp 4.000.000" with active red/amber progress bar (80% used) and warning badge[cite: 2]
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _expenseRed.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.restaurant_rounded, color: _expenseRed, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text('Budget Makanan & Belanja', style: _ts(12.5, FontWeight.w700, _darkSlate)),
                      ],
                    ),
                    // Warning badge[cite: 2]
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _expenseRed.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('80% Used', style: _ts(10, FontWeight.w700, _expenseRed)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: 0.80,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(_expenseRed),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Terpakai: Rp 3.200.000', style: _ts(11, FontWeight.w500, _slate)),
                    Text('Limit: Rp 4.000.000', style: _ts(11, FontWeight.w600, _darkSlate)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SECTION 4: LIST TUJUAN KEUANGAN (FINANCIAL GOALS LIST)
  // ===========================================================================
  Widget _buildGoalsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(_kRadiusCard),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header Row: "Tujuan Finansial Anda" in Inter Bold (#1E293B)[cite: 2]
              Text('Tujuan Finansial Anda', style: _ts(14, FontWeight.w700, _darkSlate)),
              // "+ Tambah" button[cite: 2]
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(40, 24),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => _showNotification('Tambah tujuan finansial baru'),
                icon: const Icon(Icons.add_rounded, size: 16, color: _brandBlue),
                label: Text('Tambah', style: _ts(12, FontWeight.w700, _brandBlue)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Goal Card Item: "Dana Darurat & Liburan" showing collected "Rp 15.500.000 / Rp 25.000.000" with emerald green progress bar (62% achieved) and target deadline badge[cite: 2]
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _incomeGreen.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.flight_takeoff_rounded, color: _incomeGreen, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text('Dana Darurat & Liburan', style: _ts(12.5, FontWeight.w700, _darkSlate)),
                      ],
                    ),
                    // Target deadline badge[cite: 2]
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _honeyGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Des 2026', style: _ts(10, FontWeight.w700, const Color(0xFFB45309))),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: 0.62,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(_incomeGreen),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Rp 15.500.000 / Rp 25.000.000', style: _ts(11, FontWeight.w600, _darkSlate)),
                    Text('62% Tercapai', style: _ts(11, FontWeight.w700, _incomeGreen)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
