import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Token warna "Royal Precision" (DESIGN.md)
class _T {
  static const primary = Color(0xFF1D4ED8);
  static const primarySoft = Color(0xFF2563EB);
  static const indigo = Color(0xFF6366F1);
  static const sky = Color(0xFF38BDF8);
  static const success = Color(0xFF059669);
  static const danger = Color(0xFFDC2626);
  static const warning = Color(0xFFD97706);

  static const bgLight = Color(0xFFF8FAFC);
  static const bgDark = Color(0xFF0B1220);
  static const cardDark = Color(0xFF131C2E);
  static const borderLight = Color(0xFFE2E8F0);
  static const borderDark = Color(0xFF243049);
  static const textLight = Color(0xFF0F172A);
  static const mutedLight = Color(0xFF64748B);
}

class ProfilScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final VoidCallback? onLogout;
  final Function(bool enabled, String newPin)? onPinStateChanged;

  const ProfilScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
    this.onLogout,
    this.onPinStateChanged,
  });

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final String _userName = 'Irwan Fuzi Saputra';
  final String _userEmail = 'irwan.fuzi@mykas.app';
  final String _userRole = 'Karyawan Lapangan / Field Worker';

  bool _pinEnabled = false;
  String _savedPin = '';
  bool _pushEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _pinEnabled = p.getBool('pin_enabled') ?? false;
      _savedPin = p.getString('user_pin') ?? '';
      _pushEnabled = p.getBool('push_enabled') ?? true;
    });
  }

  Future<void> _savePin(String pin) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('user_pin', pin);
    await p.setBool('pin_enabled', true);
    if (!mounted) return;
    setState(() {
      _savedPin = pin;
      _pinEnabled = true;
    });
    widget.onPinStateChanged?.call(true, pin);
  }

  Future<void> _removePin() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('pin_enabled', false);
    await p.remove('user_pin');
    await p.setBool('fingerprint_enabled', false);
    if (!mounted) return;
    setState(() {
      _pinEnabled = false;
      _savedPin = '';
    });
    widget.onPinStateChanged?.call(false, '');
  }

  void _toast(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      backgroundColor: error ? _T.danger : _T.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  bool get _isDark {
    switch (widget.currentThemeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = _isDark;
    final bg = dark ? _T.bgDark : _T.bgLight;
    final card = dark ? _T.cardDark : Colors.white;
    final border = dark ? _T.borderDark : _T.borderLight;
    final text = dark ? const Color(0xFFE2E8F0) : _T.textLight;
    final muted = dark ? const Color(0xFF94A3B8) : _T.mutedLight;

    return Scaffold(
      backgroundColor: bg,
      body: LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth >= 768;
        return ListView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          children: [
            _header(wide),
            Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: wide ? 640 : 540),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          wide ? 32 : 20, 12, wide ? 32 : 20, 24),
                      child: _body(card, border, text, muted, dark),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ───────────────────────── HEADER ─────────────────────────
  Widget _header(bool wide) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 56),
          child: Column(
            children: [
              Text('Profil',
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2)),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.25),
                    ),
                    child: const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person_rounded,
                          size: 44, color: _T.primary),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _toast('Ubah foto profil segera hadir'),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: _T.primary, width: 1.5),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          size: 14, color: _T.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(_userName,
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4)),
              const SizedBox(height: 2),
              Text(_userEmail,
                  style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.8), fontSize: 13)),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.badge_outlined,
                        size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(_userRole,
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── BODY ─────────────────────────
  Widget _body(Color card, Color border, Color text, Color muted, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('AKUN & KEAMANAN', muted),
        _group(card, border, [
          _tile(
            icon: Icons.person_outline_rounded,
            color: _T.primary,
            title: 'Informasi Akun',
            subtitle: 'Nama, email, dan nomor HP',
            text: text,
            muted: muted,
            onTap: () => _toast('Membuka Informasi Akun'),
          ),
          _divider(border),
          _tile(
            icon: Icons.fingerprint_rounded,
            color: _T.indigo,
            title: 'Keamanan PIN & Biometrik',
            subtitle: _pinEnabled ? 'PIN 6-digit aktif' : 'Belum diaktifkan',
            text: text,
            muted: muted,
            trailing: _switch(_pinEnabled, (v) {
              if (v) {
                _pinCreateDialog(card, border, text, muted);
              } else {
                _pinVerifyDialog(card, border, text, muted);
              }
            }),
          ),
        ]),
        const SizedBox(height: 24),
        _sectionTitle('PREFERENSI TAMPILAN', muted),
        _group(card, border, [
          _tile(
            icon: dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: _T.warning,
            title: 'Tema Aplikasi',
            subtitle: dark ? 'Mode Gelap' : 'Mode Terang',
            text: text,
            muted: muted,
            trailing: Switch(
              value: dark,
              onChanged: (v) =>
                  widget.onThemeModeChanged(v ? ThemeMode.dark : ThemeMode.light),
              activeColor: Colors.white,
              activeTrackColor: _T.primary,
              thumbIcon: WidgetStateProperty.resolveWith((s) => Icon(
                    s.contains(WidgetState.selected)
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    size: 14,
                    color: s.contains(WidgetState.selected)
                        ? _T.primary
                        : _T.warning,
                  )),
            ),
          ),
        ]),
        const SizedBox(height: 24),
        _sectionTitle('DATA & SINKRONISASI', muted),
        _group(card, border, [
          _tile(
            icon: Icons.cloud_done_outlined,
            color: _T.sky,
            title: 'Pencadangan Awan (Cloud Backup)',
            subtitle: 'Terakhir dicadangkan: Hari ini 09:30',
            text: text,
            muted: muted,
            onTap: () => _toast('Pencadangan data berhasil'),
          ),
        ]),
        const SizedBox(height: 24),
        _sectionTitle('NOTIFIKASI', muted),
        _group(card, border, [
          _tile(
            icon: Icons.notifications_none_rounded,
            color: _T.success,
            title: 'Preferensi Notifikasi Push',
            subtitle: _pushEnabled ? 'Aktif' : 'Nonaktif',
            text: text,
            muted: muted,
            onTap: () async {
              final p = await SharedPreferences.getInstance();
              final v = !_pushEnabled;
              await p.setBool('push_enabled', v);
              if (!mounted) return;
              setState(() => _pushEnabled = v);
              _toast(v ? 'Notifikasi push diaktifkan' : 'Notifikasi push dimatikan');
            },
          ),
        ]),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: _T.danger,
              side: const BorderSide(color: _T.danger, width: 1.2),
              backgroundColor: dark ? Colors.transparent : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: widget.onLogout ?? () => _logoutDialog(card, border, text, muted),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: Text('Keluar Akun',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text('MyKas v2.4.0 • Own Your Money',
              style: GoogleFonts.inter(
                  color: muted, fontSize: 11, fontWeight: FontWeight.w500)),
        ),
        const SizedBox(height: 90), // ruang untuk bottom nav + FAB
      ],
    );
  }

  // ───────────────────────── KOMPONEN ─────────────────────────
  Widget _sectionTitle(String t, Color muted) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(t,
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: muted,
                letterSpacing: 1.0)),
      );

  Widget _group(Color card, Color border, List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.03),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
            BoxShadow(
              color: _T.primarySoft.withOpacity(0.04),
              blurRadius: 16,
              spreadRadius: -4,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      );

  Widget _divider(Color border) =>
      Divider(height: 1, indent: 68, color: border.withOpacity(0.7));

  Widget _switch(bool v, ValueChanged<bool> onChanged) => Switch(
        value: v,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: _T.primary,
      );

  Widget _tile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Color text,
    required Color muted,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: text)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: GoogleFonts.inter(fontSize: 12, color: muted)),
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right_rounded, color: muted, size: 20),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── DIALOG ─────────────────────────
  AlertDialog _dialog({
    required Color card,
    required Color border,
    required Color text,
    required String title,
    required List<Widget> content,
    required List<Widget> actions,
  }) =>
      AlertDialog(
        backgroundColor: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: border),
        ),
        title: Text(title,
            style: GoogleFonts.inter(
                color: text, fontWeight: FontWeight.w700, fontSize: 17)),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: content),
        actions: actions,
      );

  Widget _pinField(TextEditingController c, String label, Color text,
          Color muted, Color border) =>
      TextField(
        controller: c,
        obscureText: true,
        keyboardType: TextInputType.number,
        maxLength: 6,
        style: TextStyle(color: text, letterSpacing: 8, fontSize: 18),
        decoration: InputDecoration(
          labelText: label,
          counterText: '',
          labelStyle: TextStyle(color: muted, letterSpacing: 0, fontSize: 13),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: border)),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: _T.primary, width: 1.5)),
        ),
      );

  void _pinCreateDialog(Color card, Color border, Color text, Color muted) {
    final a = TextEditingController();
    final b = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => _dialog(
        card: card,
        border: border,
        text: text,
        title: 'Aktivasi Kunci PIN',
        content: [
          Text('Buat PIN 6-digit untuk mengamankan data transaksi Anda.',
              style: TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 12),
          _pinField(a, 'PIN Baru', text, muted, border),
          _pinField(b, 'Konfirmasi PIN', text, muted, border),
        ],
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: TextStyle(color: muted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _T.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              if (a.text.length != 6) {
                _toast('PIN harus 6 digit angka', error: true);
                return;
              }
              if (a.text != b.text) {
                _toast('Konfirmasi PIN tidak cocok', error: true);
                return;
              }
              await _savePin(a.text);
              if (ctx.mounted) Navigator.pop(ctx);
              _toast('Kunci PIN berhasil diaktifkan');
            },
            child: const Text('Simpan & Aktifkan'),
          ),
        ],
      ),
    );
  }

  void _pinVerifyDialog(Color card, Color border, Color text, Color muted) {
    final c = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => _dialog(
        card: card,
        border: border,
        text: text,
        title: 'Matikan Kunci PIN',
        content: [
          Text('Masukkan PIN saat ini untuk mematikan penguncian.',
              style: TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 12),
          _pinField(c, 'PIN Saat Ini', text, muted, border),
        ],
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: TextStyle(color: muted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _T.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              if (c.text != _savedPin) {
                _toast('PIN yang dimasukkan salah', error: true);
                return;
              }
              await _removePin();
              if (ctx.mounted) Navigator.pop(ctx);
              _toast('Kunci PIN dinonaktifkan');
            },
            child: const Text('Matikan PIN'),
          ),
        ],
      ),
    );
  }

  void _logoutDialog(Color card, Color border, Color text, Color muted) {
    showDialog(
      context: context,
      builder: (ctx) => _dialog(
        card: card,
        border: border,
        text: text,
        title: 'Keluar dari MyKas?',
        content: [
          Text(
              'Data kas Anda tersimpan aman di cloud. Anda perlu masuk kembali untuk mengakses akun.',
              style: TextStyle(color: muted, fontSize: 13, height: 1.4)),
        ],
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: TextStyle(color: muted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _T.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              Navigator.pop(ctx);
              _toast('Anda telah keluar dari sesi MyKas');
            },
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }
}
