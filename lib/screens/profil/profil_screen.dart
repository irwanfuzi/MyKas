import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profil_common.dart';
import 'profil_pages_akun.dart';
import 'profil_pages_keuangan.dart';

class _Item {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _Item({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
  });
}

class ProfilScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final VoidCallback? onLogout;
  final Function(bool enabled, String newPin)? onPinStateChanged;

  // ── Hook ke backend / layanan Anda (semua opsional) ──
  /// Hapus akun di server. Data lokal otomatis dibersihkan setelahnya.
  final Future<void> Function()? onDeleteAccount;

  /// Unggah JSON cadangan ke cloud. Jika null, cadangan disalin ke clipboard.
  final Future<void> Function(String json)? onCloudBackup;

  /// Buat berkas laporan (pdf / xlsx / csv) dari data transaksi.
  final Future<void> Function(DateTimeRange range, String format)? onExport;

  /// Terima baris hasil impor CSV.
  final Future<void> Function(List<Map<String, dynamic>> rows)? onImport;

  /// Kirim masukan ke helpdesk/backend.
  final Future<void> Function(String kategori, String pesan)? onSendFeedback;

  /// Tautkan / putuskan penyedia login: 'google' | 'apple' | 'facebook'.
  final Future<bool> Function(String provider, bool connect)? onToggleProvider;

  /// Cabut sesi perangkat lain di server.
  final Future<void> Function(String deviceId)? onRevokeSession;

  const ProfilScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
    this.onLogout,
    this.onPinStateChanged,
    this.onDeleteAccount,
    this.onCloudBackup,
    this.onExport,
    this.onImport,
    this.onSendFeedback,
    this.onToggleProvider,
    this.onRevokeSession,
  });

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  static const _userEmail = 'irwan.fuzi@mykas.app';
  static const _userRole = 'Karyawan Lapangan / Field Worker';

  String _name = kDefaultName;
  int _avatar = 0;

  // Ringkasan
  int _jumlahRekening = 0;
  int _jumlahTarget = 0;
  int _budgetPct = 0;
  String? _lastBackup;

  // Keamanan
  bool _pinEnabled = false;
  String _savedPin = '';
  bool _bioEnabled = false;

  // Preferensi
  String _language = 'Bahasa Indonesia';
  String _currency = 'Rupiah (IDR)';
  final Map<String, bool> _notif = {
    'notif_reminder': true,
    'notif_budget': true,
    'notif_weekly': true,
    'notif_insight': false,
  };

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final p = await SharedPreferences.getInstance();
    final rek =
        await MkStore.load('mk_rekening', seedRekening(), Rekening.fromJson);
    final tar = await MkStore.load('mk_target', seedTarget(), Target.fromJson);
    final pct = await MkStore.budgetPercent();
    if (!mounted) return;
    setState(() {
      _name = p.getString('user_name') ?? kDefaultName;
      _avatar = p.getInt('avatar_color') ?? 0;
      _jumlahRekening = rek.length;
      _jumlahTarget = tar.length;
      _budgetPct = pct;
      _lastBackup = p.getString('last_backup');
      _pinEnabled = p.getBool('pin_enabled') ?? false;
      _savedPin = p.getString('user_pin') ?? '';
      _bioEnabled = _pinEnabled && (p.getBool('fingerprint_enabled') ?? false);
      _language = p.getString('app_language') ?? _language;
      _currency = p.getString('app_currency') ?? _currency;
      for (final k in _notif.keys.toList()) {
        _notif[k] = p.getBool(k) ?? _notif[k]!;
      }
    });
  }

  Future<void> _push(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) _loadAll();
  }

  // ── PIN ──
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
      _bioEnabled = false;
      _savedPin = '';
    });
    widget.onPinStateChanged?.call(false, '');
  }

  Future<void> _toggleBio(bool v) async {
    final p = await SharedPreferences.getInstance();
    if (v && !kIsWeb) {
      try {
        final auth = LocalAuthentication();
        final can = await auth.canCheckBiometrics || await auth.isDeviceSupported();
        if (!can) {
          if (mounted) {
            mkToast(context, 'Perangkat tidak mendukung biometrik', error: true);
          }
          return;
        }
        final ok = await auth.authenticate(
          localizedReason: 'Konfirmasi identitas Anda untuk mengaktifkan biometrik',
          options: const AuthenticationOptions(
              stickyAuth: true, biometricOnly: false),
        );
        if (!ok) {
          if (mounted) mkToast(context, 'Verifikasi dibatalkan', error: true);
          return;
        }
      } catch (_) {
        if (mounted) {
          mkToast(context, 'Biometrik tidak dapat digunakan saat ini',
              error: true);
        }
        return;
      }
    }
    await p.setBool('fingerprint_enabled', v);
    if (!mounted) return;
    setState(() => _bioEnabled = v);
    mkToast(context, v ? 'Biometrik diaktifkan' : 'Biometrik dinonaktifkan');
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

  String get _themeLabel {
    switch (widget.currentThemeMode) {
      case ThemeMode.dark:
        return 'Gelap';
      case ThemeMode.light:
        return 'Terang';
      case ThemeMode.system:
        return 'Sistem';
    }
  }

  // ───────────────────────── BUILD ─────────────────────────
  @override
  Widget build(BuildContext context) {
    final c = MkColors(_isDark);
    return Scaffold(
      backgroundColor: c.bg,
      body: LayoutBuilder(builder: (context, box) {
        final wide = box.maxWidth >= 768;
        final pad = wide ? 32.0 : 20.0;
        return ListView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          children: [
            _header(c),
            Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                decoration: BoxDecoration(
                  color: c.bg,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: wide ? 640 : 540),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(pad, 20, pad, 0),
                      child: _content(c),
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
  Widget _header(MkColors c) {
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
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    child: MkAvatar(name: _name, colorIndex: _avatar, radius: 38),
                  ),
                  GestureDetector(
                    onTap: () => showAvatarSheet(context,
                        name: _name,
                        current: _avatar,
                        onPick: (i) => setState(() => _avatar = i)),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: MkT.primary, width: 1.5),
                      ),
                      child: const Icon(Icons.palette_outlined,
                          size: 13, color: MkT.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(_name,
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

  // ───────────────────────── KONTEN ─────────────────────────
  Widget _content(MkColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _statsCard(c),
        const SizedBox(height: 28),

        _section(c, 'AKUN', [
          _Item(
            icon: Icons.person_outline_rounded,
            color: MkT.primary,
            title: 'Informasi Akun',
            subtitle: 'Nama, email, dan nomor HP',
            onTap: () => _push(const AkunInfoPage(
                email: _userEmail, role: _userRole)),
          ),
          _Item(
            icon: Icons.account_balance_wallet_outlined,
            color: MkT.indigo,
            title: 'Rekening & Dompet',
            subtitle: 'Kelola portofolio kas Anda',
            value: '$_jumlahRekening rekening',
            onTap: () => _push(const RekeningPage()),
          ),
          _Item(
            icon: Icons.link_rounded,
            color: MkT.sky,
            title: 'Akun Terhubung',
            subtitle: 'Google, Apple ID, Facebook',
            onTap: () => _push(TerhubungPage(onToggle: widget.onToggleProvider)),
          ),
        ]),

        _section(c, 'PENGELOLAAN KEUANGAN', [
          _Item(
            icon: Icons.category_outlined,
            color: MkT.warning,
            title: 'Kategori Transaksi',
            subtitle: 'Atur kategori pemasukan & pengeluaran',
            onTap: () => _push(const KategoriPage()),
          ),
          _Item(
            icon: Icons.speed_rounded,
            color: MkT.danger,
            title: 'Anggaran & Limit',
            subtitle: 'Batas pengeluaran bulanan',
            value: '$_budgetPct% terpakai',
            onTap: () => _push(const AnggaranPage()),
          ),
          _Item(
            icon: Icons.flag_outlined,
            color: MkT.success,
            title: 'Target Finansial',
            subtitle: 'Pantau progres tabungan & tujuan',
            value: '$_jumlahTarget target',
            onTap: () => _push(const TargetPage()),
          ),
          _Item(
            icon: Icons.event_repeat_rounded,
            color: MkT.primarySoft,
            title: 'Transaksi Berulang',
            subtitle: 'Gaji, cicilan, dan tagihan rutin',
            onTap: () => _push(const BerulangPage()),
          ),
        ]),

        _section(c, 'KEAMANAN', [
          _Item(
            icon: Icons.lock_outline_rounded,
            color: MkT.indigo,
            title: 'Kunci PIN Aplikasi',
            subtitle: _pinEnabled
                ? 'PIN 6-digit aktif'
                : 'Minta PIN saat aplikasi dibuka',
            trailing: mkSwitch(_pinEnabled, (v) {
              v ? _pinCreateSheet(c) : _pinVerifySheet(c);
            }),
          ),
          _Item(
            icon: Icons.fingerprint_rounded,
            color: MkT.success,
            title: 'Biometrik',
            subtitle: _pinEnabled
                ? 'Buka aplikasi dengan sidik jari / wajah'
                : 'Aktifkan Kunci PIN terlebih dahulu',
            trailing: mkSwitch(_bioEnabled, _pinEnabled ? _toggleBio : null),
          ),
          if (_pinEnabled)
            _Item(
              icon: Icons.pin_outlined,
              color: MkT.sky,
              title: 'Ubah PIN',
              subtitle: 'Perbarui kode keamanan 6-digit',
              onTap: () => _pinChangeSheet(c),
            ),
          _Item(
            icon: Icons.devices_rounded,
            color: MkT.primary,
            title: 'Perangkat & Sesi Aktif',
            subtitle: 'Lihat perangkat yang masuk ke akun',
            onTap: () => _push(PerangkatPage(onRevoke: widget.onRevokeSession)),
          ),
        ]),

        _section(c, 'PREFERENSI', [
          _Item(
            icon: _isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: MkT.warning,
            title: 'Tema Aplikasi',
            value: _themeLabel,
            onTap: () => _optionSheet<ThemeMode>(
              c,
              title: 'Tema Aplikasi',
              selected: widget.currentThemeMode,
              options: const [
                (ThemeMode.light, 'Terang', Icons.light_mode_rounded),
                (ThemeMode.dark, 'Gelap', Icons.dark_mode_rounded),
                (ThemeMode.system, 'Ikuti Sistem', Icons.settings_suggest_rounded),
              ],
              onSelect: widget.onThemeModeChanged,
            ),
          ),
          _Item(
            icon: Icons.language_rounded,
            color: MkT.primary,
            title: 'Bahasa',
            value: _language == 'Bahasa Indonesia' ? 'Indonesia' : 'English',
            onTap: () => _optionSheet<String>(
              c,
              title: 'Bahasa Aplikasi',
              selected: _language,
              options: const [
                ('Bahasa Indonesia', 'Bahasa Indonesia', Icons.translate_rounded),
                ('English (US)', 'English (US)', Icons.translate_rounded),
              ],
              onSelect: (v) async {
                final p = await SharedPreferences.getInstance();
                await p.setString('app_language', v);
                if (mounted) setState(() => _language = v);
              },
            ),
          ),
          _Item(
            icon: Icons.payments_outlined,
            color: MkT.success,
            title: 'Mata Uang',
            value: _currency.startsWith('Rupiah') ? 'IDR' : 'USD',
            onTap: () => _optionSheet<String>(
              c,
              title: 'Mata Uang Utama',
              selected: _currency,
              options: const [
                ('Rupiah (IDR)', 'Rupiah (IDR)', Icons.payments_outlined),
                ('Dolar AS (USD)', 'Dolar AS (USD)', Icons.attach_money_rounded),
              ],
              onSelect: (v) async {
                final p = await SharedPreferences.getInstance();
                await p.setString('app_currency', v);
                if (mounted) setState(() => _currency = v);
              },
            ),
          ),
          _Item(
            icon: Icons.notifications_none_rounded,
            color: MkT.indigo,
            title: 'Notifikasi',
            subtitle: 'Pengingat, peringatan budget, laporan',
            onTap: () => _notifSheet(c),
          ),
        ]),

        _section(c, 'DATA & SINKRONISASI', [
          _Item(
            icon: Icons.cloud_done_outlined,
            color: MkT.sky,
            title: 'Pencadangan Awan (Cloud Backup)',
            subtitle: lastBackupLabel(_lastBackup),
            onTap: () => _push(BackupPage(onUpload: widget.onCloudBackup)),
          ),
          _Item(
            icon: Icons.file_download_outlined,
            color: MkT.success,
            title: 'Ekspor Laporan',
            subtitle: 'Unduh rekap dalam format PDF / Excel / CSV',
            onTap: () => _push(ExportPage(onExport: widget.onExport)),
          ),
          _Item(
            icon: Icons.file_upload_outlined,
            color: MkT.warning,
            title: 'Impor Data',
            subtitle: 'Masukkan transaksi dari file CSV',
            onTap: () => _push(ImporPage(onImport: widget.onImport)),
          ),
        ]),

        _section(c, 'BANTUAN & INFORMASI', [
          _Item(
            icon: Icons.help_outline_rounded,
            color: MkT.primary,
            title: 'Pusat Bantuan',
            subtitle: 'Panduan dan pertanyaan umum',
            onTap: () =>
                _push(BantuanPage(onSendFeedback: widget.onSendFeedback)),
          ),
          _Item(
            icon: Icons.support_agent_rounded,
            color: MkT.indigo,
            title: 'Hubungi Kami',
            subtitle: 'Laporkan kendala atau beri masukan',
            onTap: () => _push(KontakPage(onSend: widget.onSendFeedback)),
          ),
          _Item(
            icon: Icons.shield_outlined,
            color: MkT.success,
            title: 'Syarat & Kebijakan Privasi',
            onTap: () => _push(const PrivasiPage()),
          ),
          _Item(
            icon: Icons.info_outline_rounded,
            color: MkT.sky,
            title: 'Tentang MyKas',
            value: 'v$kAppVersion',
            onTap: () => _push(const TentangPage()),
          ),
        ]),

        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: MkT.danger,
              side: const BorderSide(color: MkT.danger, width: 1.2),
              backgroundColor: c.dark ? Colors.transparent : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: Text('Keluar Akun',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: _openDeleteAccount,
            child: Text('Hapus Akun Permanen',
                style: GoogleFonts.inter(
                    color: c.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline)),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text('MyKas v$kAppVersion • Own Your Money',
              style: GoogleFonts.inter(
                  color: c.muted, fontSize: 11, fontWeight: FontWeight.w500)),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  // ───────────────────────── AKSI ─────────────────────────
  Future<void> _logout() async {
    final ok = await mkConfirm(context,
        title: 'Keluar dari MyKas?',
        message:
            'Data kas Anda tersimpan aman. Anda perlu masuk kembali untuk mengakses akun.',
        confirm: 'Ya, Keluar',
        danger: true);
    if (!ok || !mounted) return;
    if (widget.onLogout != null) {
      widget.onLogout!();
    } else {
      mkToast(context, 'Anda telah keluar dari sesi MyKas');
    }
  }

  Future<void> _openDeleteAccount() async {
    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => HapusAkunPage(onDelete: () async {
          if (widget.onDeleteAccount != null) await widget.onDeleteAccount!();
          final p = await SharedPreferences.getInstance();
          await p.clear();
        }),
      ),
    );
    if (deleted == true && mounted) widget.onLogout?.call();
  }

  // ───────────────────────── KOMPONEN ─────────────────────────
  Widget _statsCard(MkColors c) {
    Widget stat(String value, String label, Color color) => Expanded(
          child: Column(
            children: [
              Text(value,
                  style: mkText(c,
                      size: 20, w: FontWeight.w700, color: color, tnum: true)),
              const SizedBox(height: 2),
              Text(label, style: mkText(c, size: 11.5, color: c.muted)),
            ],
          ),
        );
    Widget vline() => Container(width: 1, height: 32, color: c.border);
    final budgetColor = _budgetPct >= 90
        ? MkT.danger
        : _budgetPct >= 70
            ? MkT.warning
            : MkT.success;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: mkCardDeco(c),
      child: Row(
        children: [
          stat('$_jumlahRekening', 'Rekening', MkT.primary),
          vline(),
          stat('$_jumlahTarget', 'Target', MkT.success),
          vline(),
          stat('$_budgetPct%', 'Budget', budgetColor),
        ],
      ),
    );
  }

  Widget _section(MkColors c, String title, List<_Item> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mkLabel(c, title),
          mkGroup(c, [
            for (final it in items)
              mkRow(
                c,
                leading: mkIconBox(it.icon, it.color),
                title: it.title,
                subtitle: it.subtitle,
                trailing: it.trailing ??
                    (it.onTap == null ? null : mkChevron(c, value: it.value)),
                onTap: it.onTap,
              ),
          ]),
        ],
      ),
    );
  }

  // ───────────────────────── SHEET ─────────────────────────
  void _optionSheet<T>(
    MkColors c, {
    required String title,
    required T selected,
    required List<(T, String, IconData)> options,
    required ValueChanged<T> onSelect,
  }) {
    mkSheet(
      context,
      title,
      (ctx) => Column(
        children: [
          for (final o in options) ...[
            mkSelectCard(c,
                icon: o.$3,
                title: o.$2,
                selected: o.$1 == selected,
                onTap: () {
                  onSelect(o.$1);
                  Navigator.pop(ctx);
                }),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  void _notifSheet(MkColors c) {
    const rows = [
      ('notif_reminder', 'Pengingat catat harian', 'Ingatkan saya mencatat transaksi'),
      ('notif_budget', 'Peringatan limit budget', 'Saat pengeluaran mendekati batas'),
      ('notif_weekly', 'Laporan mingguan', 'Ringkasan arus kas tiap pekan'),
      ('notif_insight', 'My Insight', 'Tips dan analisis keuangan'),
    ];
    mkSheet(
      context,
      'Notifikasi',
      (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Column(
          children: [
            for (final r in rows)
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                activeColor: MkT.primary,
                title: Text(r.$2, style: mkText(c, w: FontWeight.w600)),
                subtitle: Text(r.$3, style: mkText(c, size: 12, color: c.muted)),
                value: _notif[r.$1]!,
                onChanged: (v) async {
                  final p = await SharedPreferences.getInstance();
                  await p.setBool(r.$1, v);
                  setModal(() => _notif[r.$1] = v);
                  if (mounted) setState(() {});
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _pinField(MkColors c, TextEditingController ctrl, String label) =>
      TextField(
        controller: ctrl,
        obscureText: true,
        keyboardType: TextInputType.number,
        maxLength: 6,
        style: TextStyle(color: c.text, letterSpacing: 8, fontSize: 18),
        decoration: mkInput(c, label).copyWith(counterText: ''),
      );

  Widget _err(MkColors c, String? e) => e == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(e, style: mkText(c, size: 12, color: MkT.danger)),
        );

  void _pinCreateSheet(MkColors c) {
    final a = TextEditingController();
    final b = TextEditingController();
    String? err;
    mkSheet(
      context,
      'Aktivasi Kunci PIN',
      (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buat PIN 6-digit untuk mengamankan data transaksi Anda.',
                style: mkText(c, size: 12.5, color: c.muted)),
            const SizedBox(height: 16),
            _pinField(c, a, 'PIN Baru'),
            const SizedBox(height: 12),
            _pinField(c, b, 'Konfirmasi PIN'),
            _err(c, err),
            const SizedBox(height: 20),
            MkButton(
              label: 'Simpan & Aktifkan',
              onPressed: () async {
                if (a.text.length != 6) {
                  setS(() => err = 'PIN harus 6 digit angka');
                  return;
                }
                if (a.text != b.text) {
                  setS(() => err = 'Konfirmasi PIN tidak cocok');
                  return;
                }
                await _savePin(a.text);
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) mkToast(context, 'Kunci PIN berhasil diaktifkan');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pinVerifySheet(MkColors c) {
    final ctrl = TextEditingController();
    String? err;
    mkSheet(
      context,
      'Matikan Kunci PIN',
      (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Masukkan PIN saat ini untuk mematikan penguncian.',
                style: mkText(c, size: 12.5, color: c.muted)),
            const SizedBox(height: 16),
            _pinField(c, ctrl, 'PIN Saat Ini'),
            _err(c, err),
            const SizedBox(height: 20),
            MkButton(
              label: 'Matikan PIN',
              danger: true,
              onPressed: () async {
                if (ctrl.text != _savedPin) {
                  setS(() => err = 'PIN yang dimasukkan salah');
                  return;
                }
                await _removePin();
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) mkToast(context, 'Kunci PIN dinonaktifkan');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pinChangeSheet(MkColors c) {
    final oldC = TextEditingController();
    final newC = TextEditingController();
    String? err;
    mkSheet(
      context,
      'Ubah PIN',
      (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _pinField(c, oldC, 'PIN Lama'),
            const SizedBox(height: 12),
            _pinField(c, newC, 'PIN Baru (6 digit)'),
            _err(c, err),
            const SizedBox(height: 20),
            MkButton(
              label: 'Simpan PIN Baru',
              onPressed: () async {
                if (oldC.text != _savedPin) {
                  setS(() => err = 'PIN lama tidak sesuai');
                  return;
                }
                if (newC.text.length != 6) {
                  setS(() => err = 'PIN baru harus 6 digit angka');
                  return;
                }
                await _savePin(newC.text);
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) mkToast(context, 'PIN berhasil diperbarui');
              },
            ),
          ],
        ),
      ),
    );
  }
}
