import 'package:flutter/material.dart';

class ResponsiveDashboard extends StatefulWidget {
  const ResponsiveDashboard({super.key});

  @override
  State<ResponsiveDashboard> createState() => _ResponsiveDashboardState();
}

class _ResponsiveDashboardState extends State<ResponsiveDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Patokan batas lebar layar untuk mode Desktop (misal: >= 768px atau >= 900px)
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 850) {
          // ==================== TAMPILAN DESKTOP SITE / DASHBOARD ====================
          return Scaffold(
            backgroundColor: const Color(0xFF0F172A), // Slate 900
            body: Row(
              children: [
                // 1. Sidebar Navigasi Kiri (Khas Web Dashboard)
                _buildSidebar(),

                // 2. Area Konten Utama Dashboard (Tengah & Kanan)
                Expanded(
                  child: Column(
                    children: [
                      // Header Dashboard Top Bar
                      _buildTopHeader(),

                      // Isi Grid Dashboard
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Kolom Utama (Ringkasan Saldo, Grafik & Transaksi)
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    _buildBalanceCards(),
                                    const SizedBox(height: 24),
                                    _buildRecentTransactionsCard(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),

                              // Kolom Kanan (Quick Action, Analytics / Target)
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    _buildQuickActionsCard(),
                                    const SizedBox(height: 24),
                                    _buildBudgetSummaryCard(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // ==================== TAMPILAN MOBILE BIASA ====================
          return Scaffold(
            backgroundColor: const Color(0xFF0F172A),
            appBar: AppBar(
              backgroundColor: const Color(0xFF1E293B),
              title: const Text('MyKas', style: TextStyle(color: Colors.white)),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildBalanceCards(),
                  const SizedBox(height: 16),
                  _buildQuickActionsCard(),
                  const SizedBox(height: 16),
                  _buildRecentTransactionsCard(),
                ],
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              backgroundColor: const Color(0xFF1E293B),
              selectedItemColor: const Color(0xFF3B82F6),
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Beranda'),
                BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Dompet'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
              ],
            ),
          );
        }
      },
    );
  }

  // WIDGET SIDEBAR KIRI (DESKTOP)
  Widget _buildSidebar() {
    return Container(
      width: 240,
      color: const Color(0xFF1E293B), // Slate 800
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Logo & Title MyKas
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset('assets/images/logo_mykas.png', width: 36, height: 36),
              ),
              const SizedBox(width: 12),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(text: 'My', style: TextStyle(color: Colors.white)),
                    TextSpan(text: 'Kas', style: TextStyle(color: Color(0xFF3B82F6))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Menu Items Sidebar
          _buildSidebarItem(0, Icons.dashboard_rounded, 'Dashboard'),
          _buildSidebarItem(1, Icons.swap_horiz_rounded, 'Transaksi'),
          _buildSidebarItem(2, Icons.account_balance_wallet_rounded, 'Dompet & Kartu'),
          _buildSidebarItem(3, Icons.pie_chart_rounded, 'Laporan / Analistik'),
          _buildSidebarItem(4, Icons.settings_rounded, 'Pengaturan'),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2563EB).withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? const Color(0xFF3B82F6) : Colors.grey),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => setState(() => _selectedIndex = index),
      ),
    );
  }

  // WIDGET HEADER ATAS (DESKTOP)
  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: const Color(0xFF1E293B),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Ringkasan Keuangan',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const CircleAvatar(
                backgroundColor: Color(0xFF2563EB),
                child: Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // WIDGET CARD RINGKASAN SALDO
  Widget _buildBalanceCards() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Total Saldo Tersedia', style: TextStyle(color: Colors.white70, fontSize: 14)),
          SizedBox(height: 8),
          Text('Rp 24.500.000', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // WIDGET TRANSAKSI TERAKHIR
  Widget _buildRecentTransactionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Transaksi Terakhir', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          ListTile(
            leading: CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.arrow_downward, color: Colors.white)),
            title: Text('Gaji Bulanan', style: TextStyle(color: Colors.white)),
            subtitle: Text('28 Sep 2026', style: TextStyle(color: Colors.grey)),
            trailing: Text('+Rp 15.000.000', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // WIDGET QUICK ACTIONS
  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Aksi Cepat', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Catat'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text('Transfer', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // WIDGET TARGET / BUDGET
  Widget _buildBudgetSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Target Tabungan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          LinearProgressIndicator(value: 0.65, backgroundColor: Colors.grey, color: Color(0xFF3B82F6)),
          SizedBox(height: 8),
          Text('65% Terkumpul dari Rp 50.000.000', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
