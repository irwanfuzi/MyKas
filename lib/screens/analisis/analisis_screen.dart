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

const Color _brandBlue = Color(0xFF2563EB); // Soft Royal Blue MyKas
const Color _incomeGreen = Color(0xFF10B981);
const Color _expenseRed = Color(0xFFEF4444);
const Color _honeyGold = Color(0xFFF59E0B);
const Color _darkSlate = Color(0xFF1E293B);
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
// MAIN ANALISIS SCREEN
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
  String _selectedPeriod = 'Bulan Ini';

  final List<Map<String, dynamic>> _goalsList = [
    {'name': 'Dana Darurat & Liburan', 'saved': 15500000, 'target': 25000000, 'deadline': 'Des 2026', 'icon': Icons.flight_takeoff_rounded},
    {'name': 'Renovasi Rumah', 'saved': 8000000, 'target': 20000000, 'deadline': 'Jun 2027', 'icon': Icons.home_rounded},
  ];

  final List<Map<String, dynamic>> _budgetList = [
    {'name': 'Budget Makanan & Belanja', 'used': 3200000, 'limit': 4000000, 'icon': Icons.restaurant_rounded},
    {'name': 'Transportasi & Bensin', 'used': 750000, 'limit': 1000000, 'icon': Icons.directions_car_rounded},
  ];

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

  void _navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _openAddGoalModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddGoalSheet(
        onAdd: (newGoal) {
          setState(() {
            _goalsList.add(newGoal);
          });
          _showNotification('Tujuan finansial berhasil ditambahkan!');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: _brandBlue,
      body: Column(
        children: [
          // ===================================================================
          // HEADER CANVAS & TOP BAR (Judul: Analisis)
          // ===================================================================
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Analisis',
                      style: _ts(20, FontWeight.w700, Colors.white, ls: -0.4),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      setState(() {
                        _selectedPeriod = value;
                      });
                      _showNotification('Data diperbarui untuk: $value');
                    },
                    color: _darkSlate,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'Minggu Ini',
                        child: Text('Minggu Ini', style: _ts(12, FontWeight.w500, Colors.white)),
                      ),
                      PopupMenuItem(
                        value: 'Bulan Ini',
                        child: Text('Bulan Ini', style: _ts(12, FontWeight.w500, Colors.white)),
                      ),
                      PopupMenuItem(
                        value: 'Tahun Ini',
                        child: Text('Tahun Ini', style: _ts(12, FontWeight.w500, Colors.white)),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _honeyGold,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_selectedPeriod, style: _ts(12, FontWeight.w700, _darkSlate)),
                          const SizedBox(width: 4),
                          const Icon(Icons.expand_more_rounded, size: 16, color: _darkSlate),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===================================================================
          // BOTTOM SHEET CONTAINER (PANEL KONTEN PUTIH)
          // ===================================================================
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // SECTION 1: Grafik Tren Keuangan
                    _buildTrendSection(),
                    const SizedBox(height: 20),

                    // SECTION 2: Grafik Pengeluaran Berdasarkan Kategori + Donut Chart
                    _buildCategorySpendingSection(),
                    const SizedBox(height: 20),

                    // SECTION 3: List Budget (Active Budget Limits)
                    _buildBudgetSection(),
                    const SizedBox(height: 20),

                    // SECTION 4: List Tujuan Keuangan
                    _buildGoalsSection(),
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
  // SECTION 1: GRAFIK TREN KEUANGAN
  // ===========================================================================
  Widget _buildTrendSection() {
    return GestureDetector(
      onTap: () => _navigateTo(const _CashFlowDetailPage()),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(_kRadiusCard),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tren Arus Kas Bulanan ($_selectedPeriod)',
                  style: _ts(14, FontWeight.w700, _darkSlate),
                ),
                Icon(Icons.chevron_right_rounded, size: 20, color: _slate),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 130,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTrendBarGroup('M1', 4200000, 3100000),
                  _buildTrendBarGroup('M2', 5000000, 3800000),
                  _buildTrendBarGroup('M3', 4800000, 3200000, isHighlighted: true),
                  _buildTrendBarGroup('M4', 6000000, 4100000),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendBarGroup(String weekLabel, int income, int expense, {bool isHighlighted = false}) {
    const double maxVal = 7000000;
    final double incomeHeight = 90 * (income / maxVal);
    final double expenseHeight = 90 * (expense / maxVal);

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
  // SECTION 2: GRAFIK PENGELUARAN BERDASARKAN KATEGORI + DONUT CHART
  // ===========================================================================
  Widget _buildCategorySpendingSection() {
    final List<DonutSection> sections = [
      const DonutSection(value: 45, color: _brandBlue),
      const DonutSection(value: 25, color: _honeyGold),
      const DonutSection(value: 30, color: _incomeGreen),
    ];

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
              Text('Pengeluaran Berdasarkan Kategori', style: _ts(14, FontWeight.w700, _darkSlate)),
              GestureDetector(
                onTap: () => _navigateTo(const _ExpenseDetailPage()),
                child: Text('Detail', style: _ts(12, FontWeight.w700, _brandBlue)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: DonutChartPainter(
                    sections: sections,
                    backgroundColor: const Color(0xFFE2E8F0),
                    strokeWidth: 12,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Total', style: _ts(9, FontWeight.w500, _slate)),
                        Text('100%', style: _ts(11, FontWeight.w800, _darkSlate)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _buildCategoryLegendItem('Kebutuhan Pokok', '45% (Rp 4.5jt)', _brandBlue),
                    const SizedBox(height: 8),
                    _buildCategoryLegendItem('Transportasi', '25% (Rp 2.5jt)', _honeyGold),
                    const SizedBox(height: 8),
                    _buildCategoryLegendItem('Tabungan', '30% (Rp 3.0jt)', _incomeGreen),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryLegendItem(String title, String percentage, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(title, style: _ts(11, FontWeight.w600, _darkSlate)),
          ],
        ),
        Text(percentage, style: _ts(11, FontWeight.w700, _darkSlate)),
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
              Text('Status Budget Bulanan', style: _ts(14, FontWeight.w700, _darkSlate)),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(40, 24),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => _navigateTo(const _BudgetDetailPage()),
                child: Text('Atur', style: _ts(12, FontWeight.w700, _brandBlue)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: _budgetList.map((b) {
              final double ratio = (b['used'] as int) / (b['limit'] as int);
              final int pct = (ratio * 100).round();
              final isOver = ratio >= 0.8;
              final barColor = isOver ? _expenseRed : _brandBlue;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
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
                                color: barColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(b['icon'] as IconData, color: barColor, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text(b['name'] as String, style: _ts(12.5, FontWeight.w700, _darkSlate)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: barColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('$pct% Used', style: _ts(10, FontWeight.w700, barColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: ratio.clamp(0.0, 1.0),
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Terpakai: ${_rp(b['used'])}', style: _ts(11, FontWeight.w500, _slate)),
                        Text('Limit: ${_rp(b['limit'])}', style: _ts(11, FontWeight.w600, _darkSlate)),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SECTION 4: LIST TUJUAN KEUANGAN
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
              Text('Tujuan Finansial Anda', style: _ts(14, FontWeight.w700, _darkSlate)),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(40, 24),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: _openAddGoalModal,
                icon: const Icon(Icons.add_rounded, size: 16, color: _brandBlue),
                label: Text('Tambah', style: _ts(12, FontWeight.w700, _brandBlue)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: _goalsList.map((g) {
              final double ratio = (g['saved'] as int) / (g['target'] as int);
              final int pct = (ratio * 100).round();

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
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
                              child: Icon(g['icon'] as IconData, color: _incomeGreen, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text(g['name'] as String, style: _ts(12.5, FontWeight.w700, _darkSlate)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _honeyGold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(g['deadline'] as String, style: _ts(10, FontWeight.w700, const Color(0xFFB45309))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: ratio.clamp(0.0, 1.0),
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(_incomeGreen),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${_rp(g['saved'])} / ${_rp(g['target'])}', style: _ts(11, FontWeight.w600, _darkSlate)),
                        Text('$pct% Tercapai', style: _ts(11, FontWeight.w700, _incomeGreen)),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUBPAGE 1: RINCIAN PENGELUARAN KATEGORI
// =============================================================================
class _ExpenseDetailPage extends StatelessWidget {
  const _ExpenseDetailPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: _brandBlue,
        title: Text('Rincian Kategori Pengeluaran', style: _ts(16, FontWeight.w700, Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExpenseItem('Kebutuhan Pokok', 'Rp 4.500.000', '45%', Icons.restaurant_rounded, _brandBlue),
          _buildExpenseItem('Transportasi', 'Rp 2.500.000', '25%', Icons.directions_car_rounded, _honeyGold),
          _buildExpenseItem('Tabungan & Investasi', 'Rp 3.000.000', '30%', Icons.savings_rounded, _incomeGreen),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(String title, String amount, String percentage, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _ts(13.5, FontWeight.w700, _darkSlate)),
                const SizedBox(height: 2),
                Text('Porsi: $percentage dari total pengeluaran', style: _ts(11, FontWeight.w500, _slate)),
              ],
            ),
          ),
          Text(amount, style: _ts(13.5, FontWeight.w700, _darkSlate)),
        ],
      ),
    );
  }
}

// =============================================================================
// SUBPAGE 2: KELOLA ANGGARAN BULANAN
// =============================================================================
class _BudgetDetailPage extends StatelessWidget {
  const _BudgetDetailPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: _brandBlue,
        title: Text('Kelola Anggaran Bulanan', style: _ts(16, FontWeight.w700, Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Sesuaikan batas maksimum anggaran setiap kategori untuk kontrol finansial optimal.', style: _ts(12, FontWeight.w500, _slate)),
          const SizedBox(height: 16),
          _buildBudgetConfigCard('Makanan & Belanja', 4000000),
          _buildBudgetConfigCard('Transportasi', 1000000),
          _buildBudgetConfigCard('Hiburan & Rekreasi', 1500000),
        ],
      ),
    );
  }

  Widget _buildBudgetConfigCard(String category, int defaultLimit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category, style: _ts(13.5, FontWeight.w700, _darkSlate)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Batas Limit Saat Ini:', style: _ts(11.5, FontWeight.w500, _slate)),
              Text(_rp(defaultLimit), style: _ts(13, FontWeight.w700, _brandBlue)),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUBPAGE 3: DETAIL TREN ARUS KAS (CASH FLOW)
// =============================================================================
class _CashFlowDetailPage extends StatelessWidget {
  const _CashFlowDetailPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: _brandBlue,
        title: Text('Analisis Tren Arus Kas', style: _ts(16, FontWeight.w700, Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Akumulasi pemasukan dan pengeluaran mingguan Anda.', style: _ts(12, FontWeight.w500, _slate)),
          const SizedBox(height: 16),
          _buildCashFlowRow('Minggu ke-1', 'Rp 4.200.000', 'Rp 3.100.000', '+Rp 1.100.000'),
          _buildCashFlowRow('Minggu ke-2', 'Rp 5.000.000', 'Rp 3.800.000', '+Rp 1.200.000'),
          _buildCashFlowRow('Minggu ke-3', 'Rp 4.800.000', 'Rp 3.200.000', '+Rp 1.600.000'),
          _buildCashFlowRow('Minggu ke-4', 'Rp 6.000.000', 'Rp 4.100.000', '+Rp 1.900.000'),
        ],
      ),
    );
  }

  Widget _buildCashFlowRow(String week, String income, String expense, String net) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
              Text(week, style: _ts(13.5, FontWeight.w700, _darkSlate)),
              Text('Net: $net', style: _ts(12, FontWeight.w700, _incomeGreen)),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pemasukan: $income', style: _ts(11.5, FontWeight.w500, _incomeGreen)),
              Text('Pengeluaran: $expense', style: _ts(11.5, FontWeight.w500, _expenseRed)),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MODAL BOTTOM SHEET: TAMBAH TUJUAN KEUANGAN BARU
// =============================================================================
class _AddGoalSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  const _AddGoalSheet({required this.onAdd});

  @override
  State<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<_AddGoalSheet> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tambah Tujuan Keuangan', style: _ts(16, FontWeight.w700, _darkSlate)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nama Tujuan (Contoh: Beli Laptop)',
              labelStyle: _ts(12, FontWeight.w500, _slate),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _targetController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Target Nominal (Rp)',
              labelStyle: _ts(12, FontWeight.w500, _slate),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () {
                if (_nameController.text.isNotEmpty && _targetController.text.isNotEmpty) {
                  final newGoal = {
                    'name': _nameController.text,
                    'saved': 0,
                    'target': int.tryParse(_targetController.text) ?? 1000000,
                    'deadline': 'Des 2026',
                    'icon': Icons.flag_rounded,
                  };
                  widget.onAdd(newGoal);
                  Navigator.pop(context);
                }
              },
              child: Text('Simpan Tujuan', style: _ts(13.5, FontWeight.w700, Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CUSTOM PAINTERS (DONUT CHART)
// =============================================================================
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
    this.progress = 1.0,
    this.strokeWidth = 12.0,
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
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) => true;
}
