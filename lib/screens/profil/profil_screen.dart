import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_theme.dart';

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
  // State Data Diri
  String _userName = 'Irwan Fuzi';
  String _userEmail = 'irwan.fuzi@mykas.app';
  String _userPhone = '+62 812-3456-7890';

  // State Keamanan & PIN Persisten
  bool _pinLockEnabled = false;
  String _savedPin = '';
  bool _fingerprintEnabled = false;

  // State Preferensi & Integrasi
  String _currentLanguage = 'Bahasa Indonesia';
  bool _isGoogleConnected = true;
  bool _isAppleConnected = false;
  bool _isFacebookConnected = false;

  @override
  void initState() {
    super.initState();
    _loadPinState();
  }

  Future<void> _loadPinState() async {
    final prefs = await SharedPreferences.getInstance();
    final isPinActive = prefs.getBool('pin_enabled') ?? false;
    final savedPinCode = prefs.getString('user_pin') ?? '';
    final isFingerprintActive = prefs.getBool('fingerprint_enabled') ?? false;

    if (mounted) {
      setState(() {
        _pinLockEnabled = isPinActive;
        _savedPin = savedPinCode;
        _fingerprintEnabled = isPinActive && isFingerprintActive;
      });
    }
  }

  Future<void> _savePinToLocal(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_pin', pin);
    await prefs.setBool('pin_enabled', true);
    if (mounted) {
      setState(() {
        _savedPin = pin;
        _pinLockEnabled = true;
      });
      widget.onPinStateChanged?.call(true, pin);
    }
  }

  Future<void> _removePinFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pin_enabled', false);
    await prefs.remove('user_pin');
    await prefs.setBool('fingerprint_enabled', false);
    if (mounted) {
      setState(() {
        _pinLockEnabled = false;
        _fingerprintEnabled = false;
        _savedPin = '';
      });
      widget.onPinStateChanged?.call(false, '');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.urbanist(fontWeight: FontWeight.bold)),
        backgroundColor: isError ? AppTheme.expenseRed : AppTheme.brandPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bgColor = theme.scaffoldBackgroundColor;
    final cardBg = colorScheme.surface;
    final borderColor = colorScheme.outline;
    final textColor = colorScheme.onSurface;
    final textMuted = colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isDesktop ? 720 : 540),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32.0 : 20.0,
                    vertical: 24.0,
                  ),
                  children: [
                    Text(
                      'Profil & Pengaturan',
                      style: GoogleFonts.urbanist(
                        fontSize: isDesktop ? 28 : 22,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildProfileHeaderCard(cardBg, borderColor, textColor, textMuted),

                    const SizedBox(height: 28),

                    _buildSectionTitle('INTEGRASI AKUN', textMuted),
                    const SizedBox(height: 10),
                    _buildCardGroup(cardBg, borderColor, [
                      _buildListTile(
                        icon: Icons.link_rounded,
                        iconColor: AppTheme.brandPrimary,
                        title: 'Akun Terhubung',
                        subtitle: 'Google, Apple ID, atau Facebook',
                        trailingText: _isGoogleConnected ? 'Google Terhubung' : 'Atur',
                        textColor: textColor,
                        textMuted: textMuted,
                        onTap: () => _showConnectedAccountsBottomSheet(
                          context, cardBg, borderColor, textColor, textMuted,
                        ),
                      ),
                    ]),

                    const SizedBox(height: 28),

                    _buildSectionTitle('KEAMANAN & AKSES', textMuted),
                    const SizedBox(height: 10),
                    _buildCardGroup(cardBg, borderColor, [
                      _buildSwitchTile(
                        icon: Icons.lock_outline_rounded,
                        iconColor: const Color(0xFFA78BFA),
                        title: 'Kunci PIN Aplikasi',
                        subtitle: _pinLockEnabled
                            ? 'PIN 6-digit aktif'
                            : 'Minta PIN 6-digit saat aplikasi dibuka',
                        value: _pinLockEnabled,
                        textColor: textColor,
                        textMuted: textMuted,
                        onChanged: (val) {
                          if (val) {
                            _showBuatPinDialog(context, cardBg, borderColor, textColor, textMuted);
                          } else {
                            _showVerifikasiPinNonaktifkanDialog(context, cardBg, borderColor, textColor, textMuted);
                          }
                        },
                      ),
                      
                      // Biometrik disembunyikan/disesuaikan jika diakses dari Desktop Web Dashboard
                      if (!isDesktop) ...[
                        Divider(height: 1, color: borderColor.withOpacity(0.1)),
                        _buildSwitchTile(
                          icon: Icons.fingerprint_rounded,
                          iconColor: AppTheme.successGreen,
                          title: 'Autentikasi Sidik Jari',
                          subtitle: kIsWeb
                              ? 'Fitur khusus aplikasi HP Native / PWA Mobile'
                              : 'Gunakan biometrik untuk akses cepat',
                          value: _fingerprintEnabled,
                          textColor: textColor,
                          textMuted: textMuted,
                          onChanged: _pinLockEnabled
                              ? (val) async {
                                  final prefs = await SharedPreferences.getInstance();

                                  if (kIsWeb) {
                                    // PWA Mobile Mode
                                    await prefs.setBool('fingerprint_enabled', val);
                                    setState(() => _fingerprintEnabled = val);
                                    _showSnackBar(val
                                        ? 'Biometrik diaktifkan untuk PWA Mobile Anda'
                                        : 'Biometrik dinonaktifkan');
                                    return;
                                  }

                                  // Native Mobile App Mode (Android APK)
                                  final localAuth = LocalAuthentication();
                                  try {
                                    if (val) {
                                      final canCheck = await localAuth.canCheckBiometrics || await localAuth.isDeviceSupported();

                                      if (!canCheck) {
                                        _showSnackBar('Perangkat Anda tidak mendukung pemindai biometrik', isError: true);
                                        return;
                                      }

                                      final authenticated = await localAuth.authenticate(
                                        localizedReason: 'Konfirmasi sidik jari Anda untuk mengaktifkan fitur ini',
                                        options: const AuthenticationOptions(
                                          stickyAuth: true,
                                          biometricOnly: false,
                                        ),
                                      );

                                      if (!authenticated) {
                                        _showSnackBar('Verifikasi sidik jari dibatalkan', isError: true);
                                        return;
                                      }
                                    }

                                    await prefs.setBool('fingerprint_enabled', val);
                                    if (mounted) {
                                      setState(() => _fingerprintEnabled = val);
                                      _showSnackBar(val ? 'Autentikasi Sidik Jari diaktifkan' : 'Autentikasi Sidik Jari dinonaktifkan');
                                    }
                                  } catch (e) {
                                    // Aman dari crash jika ada exception
                                    await prefs.setBool('fingerprint_enabled', val);
                                    if (mounted) {
                                      setState(() => _fingerprintEnabled = val);
                                      _showSnackBar(val ? 'Status biometrik diperbarui' : 'Biometrik dinonaktifkan');
                                    }
                                  }
                                }
                              : null,
                        ),
                      ],

                      if (_pinLockEnabled) ...[
                        Divider(height: 1, color: borderColor.withOpacity(0.1)),
                        _buildListTile(
                          icon: Icons.pin_outlined,
                          iconColor: const Color(0xFF38BDF8),
                          title: 'Ubah PIN Kas',
                          subtitle: 'Perbarui kode keamanan 6-digit Anda',
                          textColor: textColor,
                          textMuted: textMuted,
                          onTap: () => _showUbahPinDialog(context, cardBg, borderColor, textColor, textMuted),
                        ),
                      ],
                    ]),

                    const SizedBox(height: 28),

                    _buildSectionTitle('TAMPILAN & PREFERENSI', textMuted),
                    const SizedBox(height: 10),
                    _buildCardGroup(cardBg, borderColor, [
                      _buildListTile(
                        icon: Icons.dark_mode_outlined,
                        iconColor: const Color(0xFFF59E0B),
                        title: 'Mode Tampilan',
                        subtitle: _getThemeModeSubtitle(widget.currentThemeMode),
                        textColor: textColor,
                        textMuted: textMuted,
                        onTap: () => _showThemeModeBottomSheet(context, cardBg, borderColor, textColor, textMuted),
                      ),
                      Divider(height: 1, color: borderColor.withOpacity(0.1)),
                      _buildListTile(
                        icon: Icons.language_rounded,
                        iconColor: AppTheme.brandPrimary,
                        title: 'Bahasa Aplikasi',
                        subtitle: _currentLanguage,
                        textColor: textColor,
                        textMuted: textMuted,
                        onTap: () => _showLanguageBottomSheet(context, cardBg, borderColor, textColor, textMuted),
                      ),
                    ]),

                    const SizedBox(height: 28),

                    _buildSectionTitle('DATA & LAPORAN', textMuted),
                    const SizedBox(height: 10),
                    _buildCardGroup(cardBg, borderColor, [
                      _buildListTile(
                        icon: Icons.file_download_outlined,
                        iconColor: AppTheme.successGreen,
                        title: 'Ekspor Laporan Kas',
                        subtitle: 'Unduh rekapitulasi format PDF / Excel',
                        textColor: textColor,
                        textMuted: textMuted,
                        onTap: () => _showEksporDialog(context, cardBg, borderColor, textColor, textMuted),
                      ),
                      Divider(height: 1, color: borderColor.withOpacity(0.1)),
                      _buildListTile(
                        icon: Icons.cloud_upload_outlined,
                        iconColor: const Color(0xFF38BDF8),
                        title: 'Cadangkan Data',
                        subtitle: 'Simpan file cadangan transaksi secara lokal',
                        textColor: textColor,
                        textMuted: textMuted,
                        onTap: () => _showSnackBar('Pencadangan data kas berhasil dilakukan!'),
                      ),
                    ]),

                    const SizedBox(height: 36),

                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textColor,
                              side: BorderSide(color: borderColor),
                              backgroundColor: cardBg,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: widget.onLogout ?? () => _showLogoutConfirmationDialog(context, cardBg, borderColor, textColor, textMuted),
                            icon: const Icon(Icons.logout_rounded, size: 18),
                            label: const Text(
                              'Keluar Sesi',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.expenseRed,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => _showDeleteAccountDialog(context, cardBg, borderColor, textColor, textMuted),
                            icon: const Icon(Icons.delete_forever_rounded, size: 18),
                            label: const Text(
                              'Hapus Akun Permanen',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Center(
                      child: Text(
                        'MyKas v2.4.0 • Own Your Money',
                        style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: textColor,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildProfileHeaderCard(Color cardBg, Color borderColor, Color textColor, Color textMuted) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.brandPrimary.withOpacity(0.15),
            child: const Icon(
              Icons.person_rounded,
              color: AppTheme.brandPrimary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _userEmail,
                  style: TextStyle(fontSize: 12, color: textMuted),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.phone_android_rounded, size: 12, color: textMuted),
                    const SizedBox(width: 4),
                    Text(
                      _userPhone,
                      style: TextStyle(fontSize: 12, color: textMuted, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditProfileDialog(context, cardBg, borderColor, textColor, textMuted),
            icon: Icon(Icons.edit_outlined, size: 18, color: textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildCardGroup(Color cardBg, Color borderColor, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? trailingText,
    required Color textColor,
    required Color textMuted,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: textMuted)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(trailingText, style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          Icon(Icons.chevron_right_rounded, color: textMuted, size: 18),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Color textColor,
    required Color textMuted,
    required ValueChanged<bool>? onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (onChanged != null ? iconColor : textMuted).withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: onChanged != null ? iconColor : textMuted, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: onChanged != null ? textColor : textMuted,
        ),
      ),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: textMuted)),
      trailing: Switch.adaptive(
        value: value,
        activeColor: AppTheme.brandPrimary,
        onChanged: onChanged,
      ),
    );
  }

  String _getThemeModeSubtitle(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'Mode Gelap (Aktif)';
      case ThemeMode.light:
        return 'Mode Terang (Aktif)';
      case ThemeMode.system:
        return 'Mengikuti Sistem OS';
    }
  }

  void _showBuatPinDialog(BuildContext context, Color cardBg, Color borderColor, Color textColor, Color textMuted) {
    final pinCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: borderColor)),
        title: Text('Aktivasi Kunci PIN', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buat PIN 6-digit untuk mengamankan data transaksi Anda.', style: TextStyle(color: textMuted, fontSize: 12)),
            const SizedBox(height: 16),
            TextField(
              controller: pinCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: TextStyle(color: textColor, letterSpacing: 8, fontSize: 18),
              decoration: InputDecoration(
                labelText: 'PIN Baru',
                labelStyle: TextStyle(color: textMuted, letterSpacing: 0),
                hintText: '••••••',
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: borderColor)),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: TextStyle(color: textColor, letterSpacing: 8, fontSize: 18),
              decoration: InputDecoration(
                labelText: 'Konfirmasi PIN',
                labelStyle: TextStyle(color: textMuted, letterSpacing: 0),
                hintText: '••••••',
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: borderColor)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: TextStyle(color: textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.brandPrimary, foregroundColor: Colors.white),
            onPressed: () async {
              if (pinCtrl.text.length != 6) {
                _showSnackBar('PIN harus terdiri dari 6 angka digit', isError: true);
                return;
              }
              if (pinCtrl.text != confirmCtrl.text) {
                _showSnackBar('Konfirmasi PIN tidak cocok!', isError: true);
                return;
              }
              await _savePinToLocal(pinCtrl.text);
              if (mounted) {
                Navigator.pop(context);
                _showSnackBar('Kunci PIN 6-digit berhasil diaktifkan!');
              }
            },
            child: const Text('Simpan & Aktifkan'),
          ),
        ],
      ),
    );
  }

  void _showVerifikasiPinNonaktifkanDialog(BuildContext context, Color cardBg, Color borderColor, Color textColor, Color textMuted) {
    final pinCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: borderColor)),
        title: Text('Matikan Kunci PIN', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Masukkan PIN 6-digit saat ini untuk mematikan penguncian.', style: TextStyle(color: textMuted, fontSize: 12)),
            const SizedBox(height: 16),
            TextField(
              controller: pinCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: TextStyle(color: textColor, letterSpacing: 8, fontSize: 18),
              decoration: InputDecoration(
                hintText: '••••••',
                hintStyle: TextStyle(color: textMuted),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: borderColor)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: TextStyle(color: textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.expenseRed, foregroundColor: Colors.white),
            onPressed: () async {
              if (pinCtrl.text != _savedPin) {
                _showSnackBar('PIN yang Anda masukkan salah!', isError: true);
                return;
              }
              await _removePinFromLocal();
              if (mounted) {
                Navigator.pop(context);
                _showSnackBar('Kunci PIN aplikasi telah dinonaktifkan.');
              }
            },
            child: const Text('Matikan PIN'),
          ),
        ],
      ),
    );
  }

  void _showUbahPinDialog(BuildContext context, Color cardBg, Color borderColor, Color textColor, Color textMuted) {
    final oldPinCtrl = TextEditingController();
    final newPinCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: borderColor)),
        title: Text('Ubah PIN Kas', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPinCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: TextStyle(color: textColor, letterSpacing: 8, fontSize: 16),
              decoration: InputDecoration(
                labelText: 'PIN Lama',
                labelStyle: TextStyle(color: textMuted, letterSpacing: 0),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: borderColor)),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: newPinCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: TextStyle(color: textColor, letterSpacing: 8, fontSize: 16),
              decoration: InputDecoration(
                labelText: 'PIN Baru (6 Digit)',
                labelStyle: TextStyle(color: textMuted, letterSpacing: 0),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: borderColor)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: TextStyle(color: textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.brandPrimary, foregroundColor: Colors.white),
            onPressed: () async {
              if (oldPinCtrl.text != _savedPin) {
                _showSnackBar('PIN Lama tidak sesuai!', isError: true);
                return;
              }
              if (newPinCtrl.text.length != 6) {
                _showSnackBar('PIN Baru harus 6 digit angka', isError: true);
                return;
              }
              await _savePinToLocal(newPinCtrl.text);
              if (mounted) {
                Navigator.pop(context);
                _showSnackBar('PIN Kas Anda berhasil diperbarui!');
              }
            },
            child: const Text('Simpan PIN Baru'),
          ),
        ],
      ),
    );
  }

  void _showThemeModeBottomSheet(
    BuildContext context, Color cardBg, Color borderColor, Color textColor, Color textMuted,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: borderColor, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Pilih Mode Tampilan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 16),
            _buildThemeOptionTile('Mode Gelap (Dark)', Icons.dark_mode_rounded, ThemeMode.dark, textColor, borderColor),
            const SizedBox(height: 8),
            _buildThemeOptionTile('Mode Terang (Light)', Icons.light_mode_rounded, ThemeMode.light, textColor, borderColor),
            const SizedBox(height: 8),
            _buildThemeOptionTile('Ikuti Sistem Perangkat', Icons.settings_suggest_rounded, ThemeMode.system, textColor, borderColor),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOptionTile(String title, IconData icon, ThemeMode mode, Color textColor, Color borderColor) {
    final isSelected = widget.currentThemeMode == mode;
    return InkWell(
      onTap: () {
        widget.onThemeModeChanged(mode);
        Navigator.pop(context);
        _showSnackBar('Mode Tampilan diubah ke $title');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.brandPrimary : borderColor, width: isSelected ? 1.5 : 1.0),
          color: isSelected ? AppTheme.brandPrimary.withOpacity(0.08) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.brandPrimary : textColor, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: textColor))),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: AppTheme.brandPrimary, size: 20),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, Color cardBg, Color borderColor, Color textColor, Color textMuted) {
    final nameCtrl = TextEditingController(text: _userName);
    final phoneCtrl = TextEditingController(text: _userPhone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: borderColor)),
        title: Text('Edit Data Diri', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                labelStyle: TextStyle(color: textMuted),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: borderColor)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Nomor HP',
                labelStyle: TextStyle(color: textMuted),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: borderColor)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: TextStyle(color: textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.brandPrimary, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                _userName = nameCtrl.text;
                _userPhone = phoneCtrl.text;
              });
              Navigator.pop(context);
              _showSnackBar('Profil berhasil diperbarui!');
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showConnectedAccountsBottomSheet(
    BuildContext context, Color cardBg, Color borderColor, Color textColor, Color textMuted,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 36, height: 4, decoration: BoxDecoration(color: borderColor, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              Text('Akun Terhubung', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 6),
              Text('Tautkan akun Anda untuk kemudahan akses masuk.', style: TextStyle(color: textMuted, fontSize: 12)),
              const SizedBox(height: 20),

              _buildSocialTile(
                title: 'Google',
                subtitle: _isGoogleConnected ? 'irwan.fuzi@gmail.com' : 'Belum Terhubung',
                isConnected: _isGoogleConnected,
                icon: Icons.g_mobiledata_rounded,
                iconColor: const Color(0xFFEA4335),
                textColor: textColor,
                textMuted: textMuted,
                borderColor: borderColor,
                onToggle: () {
                  setModalState(() => _isGoogleConnected = !_isGoogleConnected);
                  setState(() {});
                  _showSnackBar(_isGoogleConnected ? 'Akun Google terhubung' : 'Akun Google diputuskan');
                },
              ),
              const SizedBox(height: 10),

              _buildSocialTile(
                title: 'Apple ID',
                subtitle: _isAppleConnected ? 'Terhubung' : 'Belum Terhubung',
                isConnected: _isAppleConnected,
                icon: Icons.apple_rounded,
                iconColor: textColor,
                textColor: textColor,
                textMuted: textMuted,
                borderColor: borderColor,
                onToggle: () {
                  setModalState(() => _isAppleConnected = !_isAppleConnected);
                  setState(() {});
                  _showSnackBar(_isAppleConnected ? 'Apple ID terhubung' : 'Apple ID diputuskan');
                },
              ),
              const SizedBox(height: 10),

              _buildSocialTile(
                title: 'Facebook',
                subtitle: _isFacebookConnected ? 'Terhubung' : 'Belum Terhubung',
                isConnected: _isFacebookConnected,
                icon: Icons.facebook_rounded,
                iconColor: const Color(0xFF1877F2),
                textColor: textColor,
                textMuted: textMuted,
                borderColor: borderColor,
                onToggle: () {
                  setModalState(() => _isFacebookConnected = !_isFacebookConnected);
                  setState(() {});
                  _showSnackBar(_isFacebookConnected ? 'Akun Facebook terhubung' : 'Akun Facebook diputuskan');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialTile({
    required String title,
    required String subtitle,
    required bool isConnected,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
    required Color textMuted,
    required Color borderColor,
    required VoidCallback onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                Text(subtitle, style: TextStyle(color: textMuted, fontSize: 11)),
              ],
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: isConnected ? AppTheme.expenseRed : AppTheme.brandPrimary,
              side: BorderSide(color: isConnected ? AppTheme.expenseRed.withOpacity(0.5) : AppTheme.brandPrimary),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: onToggle,
            child: Text(
              isConnected ? 'Putuskan' : 'Tautkan',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageBottomSheet(
    BuildContext context, Color cardBg, Color borderColor, Color textColor, Color textMuted,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: borderColor, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Pilih Bahasa Aplikasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 16),
            _buildLanguageOptionTile('Bahasa Indonesia', 'ID', textColor, borderColor),
            const SizedBox(height: 8),
            _buildLanguageOptionTile('English (US)', 'EN', textColor, borderColor),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOptionTile(String title, String code, Color textColor, Color borderColor) {
    final isSelected = _currentLanguage == title;
    return InkWell(
      onTap: () {
        setState(() => _currentLanguage = title);
        Navigator.pop(context);
        _showSnackBar('Bahasa aplikasi diubah ke $title');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.brandPrimary : borderColor, width: isSelected ? 1.5 : 1.0),
          color: isSelected ? AppTheme.brandPrimary.withOpacity(0.08) : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.brandPrimary.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
              child: Text(code, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.brandPrimary)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: textColor))),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: AppTheme.brandPrimary, size: 20),
          ],
        ),
      ),
    );
  }

  void _showEksporDialog(BuildContext context, Color cardBg, Color borderColor, Color textColor, Color textMuted) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: borderColor)),
        title: Text('Ekspor Laporan Kas', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Pilih format dokumen laporan keuangan yang ingin diunduh.', style: TextStyle(color: textMuted, fontSize: 12)),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Laporan PDF berhasil diunduh ke direktori lokal');
            },
            child: const Text('Format PDF'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.brandPrimary, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Laporan Excel (.xlsx) berhasil diunduh');
            },
            child: const Text('Format Excel'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context, Color cardBg, Color borderColor, Color textColor, Color textMuted) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: borderColor)),
        title: Text('Keluar dari MyKas?', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        content: Text(
          'Data pencatatan kas Anda tersimpan aman di cloud. Anda perlu masuk kembali untuk mengakses akun.',
          style: TextStyle(color: textMuted, fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: TextStyle(color: textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: textColor, foregroundColor: cardBg),
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Anda telah keluar dari sesi MyKas');
            },
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, Color cardBg, Color borderColor, Color textColor, Color textMuted) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.expenseRed),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.expenseRed),
            SizedBox(width: 8),
            Text('Hapus Akun Permanen?', style: TextStyle(color: AppTheme.expenseRed, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text(
          'Tindakan ini tidak dapat dibatalkan. Seluruh data transaksi, pencatatan kas, dan profil Anda akan dihapus secara permanen dari server.',
          style: TextStyle(color: textMuted, fontSize: 12, height: 1.4),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: TextStyle(color: textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.expenseRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Permintaan penghapusan akun telah diproses', isError: true);
            },
            child: const Text('Ya, Hapus Permanen'),
          ),
        ],
      ),
    );
  }
}
