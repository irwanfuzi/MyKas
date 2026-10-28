import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =============================================================================
// DESIGN CONSTANTS & PALETTE (FLAT & DEPTH CONSIDERED)
// =============================================================================
const String kAppVersion = '1.0.0';
const String kDefaultName = 'Irwan Fuzi Saputra';

class MkColors {
  final bool dark;
  MkColors(this.dark);

  // Tanpa hitam murni (pure black): menggunakan abu-abu gelap kaya nuansa biru/slate
  Color get bg => dark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC);
  Color get card => dark ? const Color(0xFF161B22) : Colors.white;
  Color get border => dark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);
  
  // Teks menggunakan pure white (#FFFFFF) pada dark mode dengan opasitas
  Color get text => dark ? const Color(0xFFFFFFFF) : const Color(0xFF0F172A);
  Color get textHigh => dark ? const Color(0xFFFFFFFF).withOpacity(0.87) : const Color(0xFF0F172A);
  Color get textMedium => dark ? const Color(0xFFFFFFFF).withOpacity(0.65) : const Color(0xFF64748B);
  Color get textLow => dark ? const Color(0xFFFFFFFF).withOpacity(0.30) : const Color(0xFF94A3B8);
  
  Color get inputFill => dark ? const Color(0xFF21262D) : const Color(0xFFF1F5F9);
}

class MkT {
  static const primary = Color(0xFF2563EB);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
}

class _Item {
  final Widget leading;
  final String title;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _Item({
    required this.leading,
    required this.title,
    this.value,
    this.trailing,
    this.onTap,
  });
}

// =============================================================================
// MAIN PROFIL SCREEN
// =============================================================================
class ProfilScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final VoidCallback? onLogout;
  final Function(bool enabled, String newPin)? onPinStateChanged;

  final Future<void> Function()? onDeleteAccount;
  final Future<void> Function(String kategori, String pesan)? onSendFeedback;
  final Future<void> Function(String deviceId)? onRevokeSession;

  const ProfilScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
    this.onLogout,
    this.onPinStateChanged,
    this.onDeleteAccount,
    this.onSendFeedback,
    this.onRevokeSession,
  });

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  static const _userEmail = 'irwan.fuzi@mykas.app';

  String _name = kDefaultName;
  int _avatar = 0;

  bool _bioEnabled = false;
  bool _pinEnabled = false;
  String _savedPin = '';

  String _language = 'Bahasa Indonesia';
  String _currency = 'Rupiah (IDR)';

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _name = p.getString('user_name') ?? kDefaultName;
      _avatar = p.getInt('avatar_color') ?? 0;
      _bioEnabled = p.getBool('fingerprint_enabled') ?? false;
      _pinEnabled = p.getBool('pin_enabled') ?? false;
      _savedPin = p.getString('user_pin') ?? '';
      _language = p.getString('app_language') ?? _language;
      _currency = p.getString('app_currency') ?? _currency;
    });
  }

  Future<void> _push(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) _loadAll();
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
    mkToast(context, 'PIN berhasil disimpan');
  }

  Future<void> _removePin() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('pin_enabled', false);
    await p.remove('user_pin');
    if (!mounted) return;
    setState(() {
      _pinEnabled = false;
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
          if (mounted) mkToast(context, 'Perangkat tidak mendukung biometrik', error: true);
          return;
        }
        final ok = await auth.authenticate(
          localizedReason: 'Verifikasi sidik jari/Face ID untuk mengaktifkan biometrik',
          options: const AuthenticationOptions(stickyAuth: true, biometricOnly: false),
        );
        if (!ok) {
          if (mounted) mkToast(context, 'Verifikasi biometrik dibatalkan', error: true);
          return;
        }
      } catch (_) {
        if (mounted) mkToast(context, 'Biometrik gagal diverifikasi', error: true);
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

  @override
  Widget build(BuildContext context) {
    final c = MkColors(_isDark);
    return ColoredBox(
      color: c.bg,
      child: Scaffold(
        backgroundColor: c.bg,
        body: LayoutBuilder(builder: (context, box) {
          final wide = box.maxWidth >= 768;
          final pad = wide ? 28.0 : 16.0;
          return ListView(
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            children: [
              _header(c),
              Transform.translate(
                offset: const Offset(0, -28),
                child: Container(
                  decoration: BoxDecoration(
                    color: c.bg,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: wide ? 640 : 540),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(pad, 12, pad, 0),
                        child: _content(c),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _header(MkColors c) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.card,
        border: Border(bottom: BorderSide(color: c.border, width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: MkT.primary, width: 1.5),
                    ),
                    child: MkAvatar(name: _name, colorIndex: _avatar, radius: 34),
                  ),
                  GestureDetector(
                    onTap: () => showAvatarSheet(context,
                        name: _name,
                        current: _avatar,
                        onPick: (i) => setState(() => _avatar = i)),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: c.card,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.border, width: 1),
                      ),
                      child: Icon(Icons.palette_rounded, size: 11, color: c.textHigh),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat datang,',
                      style: GoogleFonts.inter(
                        color: c.textMedium,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _name,
                      style: GoogleFonts.inter(
                        color: c.textHigh,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Akun terverifikasi',
                      style: GoogleFonts.inter(
                        color: c.textLow,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(MkColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // GRUP 1: AKUN (Kapital hanya huruf pertama)
        _section(c, 'Akun', [
          _Item(
            leading: mkIconBox(Icons.person_rounded, MkT.primary, c),
            title: 'Informasi profil',
            onTap: () => _push(AkunInfoPage(email: _userEmail, name: _name)),
          ),
          _Item(
            leading: mkIconBox(Icons.devices_rounded, MkT.success, c),
            title: 'Perangkat terhubung',
            onTap: () => _push(PerangkatPage(onRevoke: widget.onRevokeSession)),
          ),
        ]),

        // GRUP 2: KEAMANAN
        _section(c, 'Keamanan', [
          _Item(
            leading: mkIconBox(Icons.fingerprint_rounded, MkT.success, c),
            title: 'Biometrik',
            trailing: mkSwitch(_bioEnabled, (v) => _toggleBio(v), c),
          ),
          _Item(
            leading: mkIconBox(Icons.lock_rounded, MkT.warning, c),
            title: 'Pin',
            trailing: mkSwitch(_pinEnabled, (v) {
              v ? _pinCreateSheet(c) : _pinVerifySheet(c);
            }, c),
          ),
        ]),

        // GRUP 3: GENERAL
        _section(c, 'General', [
          _Item(
            leading: mkIconBox(Icons.paid_rounded, MkT.success, c),
            title: 'Mata uang',
            value: _currency.contains('Rupiah') ? 'IDR (Rp)' : 'USD (\$)',
            onTap: () => _optionSheet<String>(
              c,
              title: 'Pilih mata uang',
              selected: _currency,
              options: [
                ('Rupiah (IDR)', 'Rupiah (IDR)', const CurrencyIdr()),
                ('Dolar AS (USD)', 'Dolar AS (USD)', const CurrencyUsd()),
              ],
              onSelect: (v) async {
                final p = await SharedPreferences.getInstance();
                await p.setString('app_currency', v);
                if (mounted) setState(() => _currency = v);
              },
            ),
          ),
          _Item(
            leading: mkIconBox(
              _isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              MkT.warning,
              c,
            ),
            title: 'Mode tampilan',
            value: _isDark ? 'Gelap' : 'Terang',
            trailing: Switch.adaptive(
              value: _isDark,
              activeColor: MkT.primary,
              onChanged: (v) {
                widget.onThemeModeChanged(v ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ),
          _Item(
            leading: mkIconBox(Icons.language_rounded, MkT.primary, c),
            title: 'Bahasa',
            value: _language.contains('Indonesia') ? 'Indonesia' : 'English',
            onTap: () => _optionSheet<String>(
              c,
              title: 'Pilih bahasa',
              selected: _language,
              options: [
                ('Bahasa Indonesia', 'Bahasa Indonesia', const FlagId()),
                ('English (US)', 'English (US)', const FlagUs()),
              ],
              onSelect: (v) async {
                final p = await SharedPreferences.getInstance();
                await p.setString('app_language', v);
                if (mounted) setState(() => _language = v);
              },
            ),
          ),
        ]),

        // GRUP 4: HELP AND SUPPORT
        _section(c, 'Help and support', [
          _Item(
            leading: mkIconBox(Icons.help_rounded, MkT.primary, c),
            title: 'Pusat bantuan',
            onTap: () => _push(BantuanPage(onSendFeedback: widget.onSendFeedback)),
          ),
          _Item(
            leading: mkIconBox(Icons.headset_mic_rounded, MkT.warning, c),
            title: 'Hubungi kami',
            onTap: () => _push(KontakPage(onSend: widget.onSendFeedback)),
          ),
        ]),

        // GRUP 5: TENTANG
        _section(c, 'Tentang', [
          _Item(
            leading: mkIconBox(Icons.verified_user_rounded, MkT.success, c),
            title: 'Kebijakan privasi',
            onTap: () => _push(const PrivasiPage()),
          ),
        ]),

        // TOMBOL AKSI AKUN (FLAT DESIGN & DEPTH)
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MkT.danger,
                    side: BorderSide(color: MkT.danger.withOpacity(0.4), width: 1),
                    backgroundColor: c.card,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: Text(
                    'Keluar akun',
                    style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: c.textMedium,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _openDeleteAccount,
                  icon: const Icon(Icons.delete_forever_rounded, size: 18, color: MkT.danger),
                  label: Text(
                    'Hapus akun permanen',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: MkT.danger),
                  ),
                ),
              ),
            ],
          ),
        ),

        Center(
          child: Text(
            'MyKas v$kAppVersion • Own Your Money',
            style: GoogleFonts.inter(
              color: c.textLow,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _logout() async {
    final ok = await mkConfirm(context,
        title: 'Keluar dari MyKas?',
        message: 'Sesi Anda akan diakhiri. Masuk kembali untuk mengakses akun.',
        confirm: 'Ya, keluar',
        danger: true);
    if (!ok || !mounted) return;
    if (widget.onLogout != null) {
      widget.onLogout!();
    } else {
      mkToast(context, 'Berhasil keluar aplikasi');
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

  Widget _section(MkColors c, String title, List<_Item> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mkLabel(c, title),
          mkGroup(c, [
            for (final it in items)
              mkRow(
                c,
                leading: it.leading,
                title: it.title,
                trailing: it.trailing ?? (it.onTap == null ? null : mkChevron(c, value: it.value)),
                onTap: it.onTap,
              ),
          ]),
        ],
      ),
    );
  }

  void _optionSheet<T>(
    MkColors c, {
    required String title,
    required T selected,
    required List<(T, String, Widget)> options,
    required ValueChanged<T> onSelect,
  }) {
    mkSheet(
      context,
      title,
      (ctx) => Column(
        children: [
          for (final o in options) ...[
            mkSelectCard(c,
                leading: o.$3,
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

  Widget _pinField(MkColors c, TextEditingController ctrl, String label) => TextField(
        controller: ctrl,
        obscureText: true,
        keyboardType: TextInputType.number,
        maxLength: 6,
        style: TextStyle(color: c.textHigh, letterSpacing: 8, fontSize: 18),
        decoration: mkInput(c, label).copyWith(counterText: ''),
      );

  Widget _err(MkColors c, String? e) => e == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(e, style: mkText(c, size: 11, color: MkT.danger)),
        );

  void _pinCreateSheet(MkColors c) {
    final a = TextEditingController();
    final b = TextEditingController();
    String? err;
    mkSheet(
      context,
      'Atur pin',
      (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buat PIN 6-digit sebagai opsi cadangan jika biometrik gagal.',
                style: mkText(c, size: 11.5, color: c.textMedium)),
            const SizedBox(height: 14),
            _pinField(c, a, 'PIN baru'),
            const SizedBox(height: 10),
            _pinField(c, b, 'Konfirmasi PIN'),
            _err(c, err),
            const SizedBox(height: 16),
            MkButton(
              label: 'Simpan PIN',
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
      'Hapus pin',
      (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Masukkan PIN saat ini untuk menonaktifkan PIN.',
                style: mkText(c, size: 11.5, color: c.textMedium)),
            const SizedBox(height: 14),
            _pinField(c, ctrl, 'PIN saat ini'),
            _err(c, err),
            const SizedBox(height: 16),
            MkButton(
              label: 'Konfirmasi',
              onPressed: () async {
                if (ctrl.text != _savedPin) {
                  setS(() => err = 'PIN salah');
                  return;
                }
                await _removePin();
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) mkToast(context, 'PIN dinonaktifkan');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// CUSTOM FLAG & CURRENCY WIDGETS
// =============================================================================
class FlagId extends StatelessWidget {
  const FlagId({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black.withOpacity(0.12), width: 0.8),
      ),
      child: Column(
        children: [
          Expanded(child: Container(color: const Color(0xFFE11D48))),
          Expanded(child: Container(color: Colors.white)),
        ],
      ),
    );
  }
}

class FlagUs extends StatelessWidget {
  const FlagUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black.withOpacity(0.12), width: 0.8),
        color: const Color(0xFFB91C1C),
      ),
      child: Stack(
        children: [
          Column(
            children: List.generate(
              5,
              (i) => Expanded(
                child: Container(color: i.isEven ? const Color(0xFFB91C1C) : Colors.white),
              ),
            ),
          ),
          Container(
            width: 11,
            height: 8,
            color: const Color(0xFF1E3A8A),
          ),
        ],
      ),
    );
  }
}

class CurrencyIdr extends StatelessWidget {
  const CurrencyIdr({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MkT.success.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('Rp', style: TextStyle(color: MkT.success, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

class CurrencyUsd extends StatelessWidget {
  const CurrencyUsd({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MkT.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('\$', style: TextStyle(color: MkT.primary, fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }
}

// =============================================================================
// SUB-PAGE VIEWS
// =============================================================================
class AkunInfoPage extends StatefulWidget {
  final String email;
  final String name;
  const AkunInfoPage({super.key, required this.email, required this.name});

  @override
  State<AkunInfoPage> createState() => _AkunInfoPageState();
}

class _AkunInfoPageState extends State<AkunInfoPage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.name);
    _phoneCtrl = TextEditingController(text: '+62 812-3456-7890');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informasi profil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Nama lengkap', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: widget.email),
            readOnly: true,
            decoration: const InputDecoration(labelText: 'Alamat email', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneCtrl,
            decoration: const InputDecoration(labelText: 'Nomor telepon / WhatsApp', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: MkT.primary, minimumSize: const Size.fromHeight(48), elevation: 0),
            onPressed: () {
              mkToast(context, 'Perubahan profil berhasil disimpan');
              Navigator.pop(context);
            },
            child: const Text('Simpan perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class PerangkatPage extends StatelessWidget {
  final Future<void> Function(String deviceId)? onRevoke;
  const PerangkatPage({super.key, this.onRevoke});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perangkat terhubung')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            leading: const Icon(Icons.phone_android_rounded, color: MkT.primary),
            title: const Text('Google Chrome • Windows'),
            subtitle: const Text('Sesi aktif saat ini • Jakarta, ID'),
            trailing: TextButton(onPressed: () {}, child: const Text('Keluar', style: TextStyle(color: MkT.danger))),
          ),
        ],
      ),
    );
  }
}

class HapusAkunPage extends StatelessWidget {
  final Future<void> Function()? onDelete;
  const HapusAkunPage({super.key, this.onDelete});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hapus akun permanen')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Peringatan: Seluruh data transaksi, rekening, dan akun Anda akan dihapus permanen.',
              style: TextStyle(color: MkT.danger, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: MkT.danger, minimumSize: const Size.fromHeight(48), elevation: 0),
              onPressed: () async {
                if (onDelete != null) await onDelete!();
                if (context.mounted) Navigator.pop(context, true);
              },
              child: const Text('Ya, hapus akun saya', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class BantuanPage extends StatelessWidget {
  final Future<void> Function(String kategori, String pesan)? onSendFeedback;
  const BantuanPage({super.key, this.onSendFeedback});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Pusat bantuan')), body: const Center(child: Text('FAQ dan panduan aplikasi')));
}

class KontakPage extends StatelessWidget {
  final Future<void> Function(String kategori, String pesan)? onSend;
  const KontakPage({super.key, this.onSend});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Hubungi kami')), body: const Center(child: Text('Layanan support MyKas')));
}

class PrivasiPage extends StatelessWidget {
  const PrivasiPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Kebijakan privasi')), body: const Center(child: Text('Informasi keamanan dan privasi data')));
}

// =============================================================================
// HELPER UTILITIES & UI WIDGETS (FLAT & DEPTH)
// =============================================================================
TextStyle mkText(MkColors c, {double size = 13, FontWeight w = FontWeight.w400, Color? color, bool tnum = false}) {
  return GoogleFonts.inter(
    fontSize: size,
    fontWeight: w,
    color: color ?? c.textHigh,
    letterSpacing: -0.1,
    fontFeatures: tnum ? const [FontFeature.tabularFigures()] : null,
  );
}

BoxDecoration mkCardDeco(MkColors c) {
  return BoxDecoration(
    color: c.card,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: c.border, width: 1), // Depth & Flat border separation
  );
}

InputDecoration mkInput(MkColors c, String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: c.textMedium, fontSize: 12.5),
    filled: true,
    fillColor: c.inputFill,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
  );
}

Widget mkLabel(MkColors c, String text) {
  return Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 6),
    child: Text(
      text, // Kapital hanya huruf pertama
      style: GoogleFonts.inter(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: c.textMedium,
        letterSpacing: 0.2,
      ),
    ),
  );
}

Widget mkGroup(MkColors c, List<Widget> children) {
  return Container(
    decoration: mkCardDeco(c),
    child: Column(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) Divider(height: 1, color: c.border),
        ],
      ],
    ),
  );
}

Widget mkRow(
  MkColors c, {
  required Widget leading,
  required String title,
  Widget? trailing,
  VoidCallback? onTap,
}) {
  return ListTile(
    onTap: onTap,
    leading: leading,
    title: Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: c.textHigh,
        letterSpacing: -0.2,
      ),
    ),
    trailing: trailing,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
    minLeadingWidth: 0,
  );
}

Widget mkIconBox(IconData icon, Color color, MkColors c) {
  return Container(
    width: 34,
    height: 34,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(icon, size: 17, color: color),
  );
}

Widget mkChevron(MkColors c, {String? value}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (value != null) ...[
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: c.textMedium,
          ),
        ),
        const SizedBox(width: 4),
      ],
      Icon(Icons.chevron_right_rounded, size: 18, color: c.textLow),
    ],
  );
}

Widget mkSwitch(bool value, ValueChanged<bool>? onChanged, MkColors c) {
  return Switch.adaptive(value: value, onChanged: onChanged, activeColor: MkT.primary);
}

void mkToast(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white)),
      backgroundColor: error ? MkT.danger : MkT.success,
      duration: const Duration(seconds: 2),
    ),
  );
}

Future<bool> mkConfirm(BuildContext context, {required String title, required String message, required String confirm, bool danger = false}) async {
  final res = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      content: Text(message, style: const TextStyle(fontSize: 12.5)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: danger ? MkT.danger : MkT.primary, elevation: 0),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirm, style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
  return res ?? false;
}

void mkSheet(BuildContext context, String title, WidgetBuilder builder) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      final c = MkColors(isDark);

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: c.card, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 32, height: 3.5, decoration: BoxDecoration(color: c.textLow, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: c.textHigh)),
            const SizedBox(height: 14),
            builder(ctx),
          ],
        ),
      );
    },
  );
}

Widget mkSelectCard(MkColors c, {required Widget leading, required String title, required bool selected, required VoidCallback onTap}) {
  return ListTile(
    onTap: onTap,
    leading: leading,
    title: Text(title, style: mkText(c, size: 13, color: c.textHigh, w: selected ? FontWeight.bold : FontWeight.normal)),
    trailing: selected ? const Icon(Icons.check_circle_rounded, size: 18, color: MkT.primary) : null,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: selected ? MkT.primary : c.border)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
    dense: true,
  );
}

class MkAvatar extends StatelessWidget {
  final String name;
  final int colorIndex;
  final double radius;
  const MkAvatar({super.key, required this.name, required this.colorIndex, required this.radius});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
