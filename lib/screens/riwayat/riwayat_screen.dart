import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../utils/app_icons.dart';

// =============================================================================
// DESIGN TOKENS (MYKAS FINTECH PREMIUM)
// =============================================================================
const Color _brandBlue = Color(0xFF2563EB); // Soft Royal Blue Header
const Color _honeyGold = Color(0xFFF59E0B); // Active Filter Accent
const Color _incomeGreen = Color(0xFF059669); // Emerald Green Text
const Color _incomeGreenBg = Color(0xFFECFDF5); // Emerald Green Pill Bg
const Color _expenseRed = Color(0xFFDC2626); // Red Text
const Color _expenseRedBg = Color(0xFFFEF2F2); // Red Pill Bg
const Color _transferBlueBg = Color(0xFFEFF6FF); // Soft Blue Pill Bg
const Color _textDark = Color(0xFF1E293B); // Dark Slate Primary Text
const Color _textGrey = Color(0xFF64748B); // Grey Secondary/Muted Text

TextStyle _tsUI(double size, FontWeight w, Color c, {double? height, double? ls}) {
  return GoogleFonts.inter(
    fontSize: size,
    fontWeight: w,
    color: c,
    height: height,
    letterSpacing: ls,
  );
}

TextStyle _tsNum(double size, FontWeight w, Color c, {double? height, double? ls}) {
  return GoogleFonts.inter(
    fontSize: size,
    fontWeight: w,
    color: c,
    height: height,
    letterSpacing: ls,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}

class RiwayatScreen extends StatefulWidget {
  final Map<String, dynamic>? summaryData;

  const RiwayatScreen({
    super.key,
    this.summaryData,
  });

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  String _selectedFilter = 'Semua';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Dataset Default dengan Struktur Pengelompokan Tanggal Modern
  final List<Map<String, dynamic>> _defaultTransactions = [
    {
      'dateGroup': 'Hari Ini, 28 Oktober 2026',
      'items': [
        {
          'judul': 'Gaji Bulanan Utama',
          'kategori': 'Payroll Inflow',
          'waktu': '09:30 WIB',
          'nominal': 12500000,
          'jenis': 'pemasukan',
          'kantong': 'Bank BCA',
          'icon': AppIcons.wallet,
          'iconBg': _incomeGreenBg,
          'iconColor': _incomeGreen,
        },
        {
          'judul': 'Belanja Bulanan Supermarket',
          'kategori': 'Kebutuhan Rumah',
          'waktu': '14:15 WIB',
          'nominal': 850000,
          'jenis': 'pengeluaran',
          'kantong': 'GoPay',
          'icon': AppIcons.shoppingCart,
          'iconBg': _expenseRedBg,
          'iconColor': _expenseRed,
        },
      ],
    },
    {
      'dateGroup': 'Kemarin, 27 Oktober 2026',
      'items': [
        {
          'judul': 'Tabungan Investasi',
          'kategori': 'Portofolio / Reksadana',
          'waktu': '19:20 WIB',
          'nominal': 1500000,
          'jenis': 'transfer',
          'kantong': 'Mandiri ke Reksadana',
          'icon': AppIcons.arrowUpRight,
          'iconBg': _transferBlueBg,
          'iconColor': _brandBlue,
        },
        {
          'judul': 'Gudeg Bu Dani Solo',
          'kategori': 'Kuliner & Makanan',
          'waktu': '12:45 WIB',
          'nominal': 45000,
          'jenis': 'pengeluaran',
          'kantong': 'BSI Hasanah',
          'icon': AppIcons.utensils,
          'iconBg': _expenseRedBg,
          'iconColor': _expenseRed,
        },
      ],
    },
    {
      'dateGroup': '25 Oktober 2026',
      'items': [
        {
          'judul': 'Tagihan Listrik PLN',
          'kategori': 'Utilitas & Tagihan',
          'waktu': '08:10 WIB',
          'nominal': 320000,
          'jenis': 'pengeluaran',
          'kantong': 'Mandiri Utama',
          'icon': AppIcons.zap,
          'iconBg': _expenseRedBg,
          'iconColor': _expenseRed,
        },
      ],
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatCurrency(dynamic rawNominal) {
    if (rawNominal == null) return 'Rp 0';
    num val = 0;
    if (rawNominal is num) {
      val = rawNominal;
    } else {
      String strVal = rawNominal.toString().replaceAll(RegExp(r'[^0-9]'), '');
      val = num.tryParse(strVal) ?? 0;
    }

    final buffer = StringBuffer();
    final numStr = val.toInt().toString();

    for (int i = 0; i < numStr.length; i++) {
      if (i > 0 && (numStr.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(numStr[i]);
    }
    return 'Rp $buffer';
  }

  // Filter & Search Logic
  List<Map<String, dynamic>> _getProcessedGroupedData() {
    List<Map<String, dynamic>> result = [];

    for (var group in _defaultTransactions) {
      final String dateGroup = group['dateGroup'];
      final List items = group['items'] as List;

      final filteredItems = items.where((tx) {
        final jenis = (tx['jenis'] ?? '').toString().toLowerCase();

        // Apply Filter Pill
        if (_selectedFilter == 'Pemasukan' && jenis != 'pemasukan') return false;
        if (_selectedFilter == 'Pengeluaran' && jenis != 'pengeluaran') return false;
        if (_selectedFilter == 'Transfer' && jenis != 'transfer') return false;
        if (_selectedFilter == 'Tabungan' && !jenis.contains('tabung')) return false;

        // Apply Search Query
        if (_searchQuery.isNotEmpty) {
          final judul = (tx['judul'] ?? '').toString().toLowerCase();
          final kategori = (tx['kategori'] ?? '').toString().toLowerCase();
          final kantong = (tx['kantong'] ?? '').toString().toLowerCase();
          final q = _searchQuery.toLowerCase();
          return judul.contains(q) || kategori.contains(q) || kantong.contains(q);
        }
        return true;
      }).toList();

      if (filteredItems.isNotEmpty) {
        result.add({
          'dateGroup': dateGroup,
          'items': filteredItems,
        });
      }
    }

    return result;
  }

  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: _textGrey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter Transaksi Lanjutan', style: _tsUI(16, FontWeight.w800, _textDark)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(AppIcons.x, size: 18, color: _textDark),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Rentang Tanggal', style: _tsUI(13, FontWeight.w700, _textDark)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildDateInputBox('Dari Tanggal', '01/10/2026')),
                const SizedBox(width: 10),
                Expanded(child: _buildDateInputBox('Sampai Tanggal', '28/10/2026')),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Terapkan Filter', style: _tsUI(13, FontWeight.w700, Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInputBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _tsUI(10, FontWeight.w500, _textGrey)),
          const SizedBox(height: 2),
          Text(value, style: _tsUI(12, FontWeight.w700, _textDark)),
        ],
      ),
    );
  }

  void _openReceiptModal(Map item) {
    final isPemasukan = item['jenis'] == 'pemasukan';
    final isTransfer = item['jenis'] == 'transfer';
    final color = isPemasukan ? _incomeGreen : (isTransfer ? _textDark : _expenseRed);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: _textGrey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: item['iconBg'] ?? _transferBlueBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item['icon'] ?? AppIcons.receipt, color: item['iconColor'] ?? _brandBlue, size: 28),
                  ),
                  const SizedBox(height: 10),
                  Text(item['judul'] ?? 'Transaksi', style: _tsUI(16, FontWeight.w800, _textDark)),
                  const SizedBox(height: 4),
                  Text(
                    '${isPemasukan ? '+' : (isTransfer ? '' : '-')}${_formatCurrency(item['nominal'])}',
                    style: _tsNum(22, FontWeight.w900, color, ls: -0.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFFE2E8F0)),
            const SizedBox(height: 12),
            _buildReceiptRow('Kategori', item['kategori'] ?? '-'),
            _buildReceiptRow('Waktu Transaksi', item['waktu'] ?? '-'),
            _buildReceiptRow('Sumber Dana / Kantong', item['kantong'] ?? '-'),
            _buildReceiptRow('Status Transaksi', 'Berhasil (Enkripsi End-to-End)'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Tutup Struk Digital', style: _tsUI(13, FontWeight.w700, _textDark)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: _tsUI(12, FontWeight.w500, _textGrey)),
          Text(val, style: _tsUI(12, FontWeight.w700, _textDark)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedData = _getProcessedGroupedData();

    return Container(
      color: _brandBlue,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: _brandBlue,
          body: Column(
            children: [
              // ===============================================================
              // HEADER CANVAS & TOP BAR (Soft Royal Blue #2563EB)
              // ===============================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                child: Column(
                  children: [
                    // Header Title & Action Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 32), // Balancing spacing
                        Text(
                          'Riwayat Transaksi',
                          style: _tsUI(18, FontWeight.w700, Colors.white, ls: -0.3),
                        ),
                        InkWell(
                          onTap: _openFilterBottomSheet,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(AppIcons.sliders, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Search Bar Integrated in Blue Canvas
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9999), // Rounded Pill
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: _tsUI(12.5, FontWeight.w500, _textDark),
                        decoration: InputDecoration(
                          hintText: 'Cari transaksi, kategori, atau catatan...',
                          hintStyle: _tsUI(12, FontWeight.w400, _textGrey),
                          prefixIcon: const Icon(AppIcons.search, size: 18, color: _textGrey),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(AppIcons.x, size: 16, color: _textGrey),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Filter Chips Bar (Horizontal Scroll)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: ['Semua', 'Pemasukan', 'Pengeluaran', 'Transfer', 'Tabungan'].map((filter) {
                          final isSelected = _selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                              borderRadius: BorderRadius.circular(9999),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                                decoration: BoxDecoration(
                                  color: isSelected ? _honeyGold : Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: Text(
                                  filter,
                                  style: _tsUI(
                                    11.5,
                                    isSelected ? FontWeight.w800 : FontWeight.w600,
                                    isSelected ? _textDark : Colors.white,
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

              // ===============================================================
              // BOTTOM SHEET CONTAINER (WHITE PANEL WITH ROUNDED CORNERS)
              // ===============================================================
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: groupedData.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                          itemCount: groupedData.length,
                          itemBuilder: (context, groupIndex) {
                            final group = groupedData[groupIndex];
                            final String dateGroup = group['dateGroup'];
                            final List items = group['items'];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date Group Header
                                Padding(
                                  padding: const EdgeInsets.only(top: 12, bottom: 10),
                                  child: Text(
                                    dateGroup,
                                    style: _tsUI(13, FontWeight.w800, _textDark),
                                  ),
                                ),

                                // List Transaksi dalam Tanggal Tersebut
                                ...items.map((item) {
                                  final isPemasukan = item['jenis'] == 'pemasukan';
                                  final isTransfer = item['jenis'] == 'transfer';
                                  final amountColor = isPemasukan
                                      ? _incomeGreen
                                      : (isTransfer ? _textDark : _expenseRed);
                                  final amountPrefix = isPemasukan ? '+' : (isTransfer ? '' : '-');

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => _openReceiptModal(item),
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF8FAFC),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: const Color(0xFFF1F5F9)),
                                          ),
                                          child: Row(
                                            children: [
                                              // Left Icon Badge
                                              Container(
                                                width: 42,
                                                height: 42,
                                                decoration: BoxDecoration(
                                                  color: item['iconBg'] ?? _transferBlueBg,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  item['icon'] ?? AppIcons.receipt,
                                                  color: item['iconColor'] ?? _brandBlue,
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),

                                              // Middle Details
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item['judul'] ?? 'Transaksi',
                                                      style: _tsUI(13, FontWeight.w700, _textDark),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      '${item['kantong'] ?? 'BCA'} • ${item['waktu'] ?? '09:00 WIB'}',
                                                      style: _tsUI(11, FontWeight.w500, _textGrey),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Right Nominal Amount
                                              Text(
                                                '$amountPrefix${_formatCurrency(item['nominal'])}',
                                                style: _tsNum(13.5, FontWeight.w800, amountColor, ls: -0.3),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(AppIcons.history, size: 36, color: _textGrey),
          ),
          const SizedBox(height: 14),
          Text(
            'Tidak Ada Transaksi Ditemukan',
            style: _tsUI(14, FontWeight.w700, _textDark),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba ubah kata kunci pencarian atau filter Anda.',
            style: _tsUI(12, FontWeight.w400, _textGrey),
          ),
        ],
      ),
    );
  }
}
