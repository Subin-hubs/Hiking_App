import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hiking/auth/auth_screen.dart';
import '../services/auth_service.dart';

// ── Shared design tokens ─────────────────────────────────────────────────────
const _kDeep    = Color(0xFF1A3C2E);
const _kMid     = Color(0xFF2D6A4F);
const _kAccent  = Color(0xFF52B788);
const _kSurface = Color(0xFFF7F9F8);
const _kCard    = Color(0xFFFFFFFF);
const _kBorder  = Color(0xFFE8EDEA);
const _kText1   = Color(0xFF0D1F17);
const _kText2   = Color(0xFF6B7F74);

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: _kSurface,
            body: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2, color: _kAccent),
              ),
            ),
          );
        }
        if (snapshot.data == null) return const _GuestProfile();
        return _UserProfile(user: snapshot.data!);
      },
    );
  }
}

// ── Guest ────────────────────────────────────────────────────────────────────

class _GuestProfile extends StatelessWidget {
  const _GuestProfile();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: _kSurface,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _GuestHeader(),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _SignInCard(
                      onSignIn: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SettingsCard(),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuestHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, top + 28, 24, 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F2D20), Color(0xFF1A4A32), Color(0xFF2D6A4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
            ),
            child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'Guest',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sign in to unlock your full experience',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignInCard extends StatelessWidget {
  final VoidCallback onSignIn;
  const _SignInCard({required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _kAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.lock_open_rounded, color: _kAccent, size: 26),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sign in to continue',
            style: TextStyle(
              color: _kText1,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Save trails, track your gear, and sync your progress across devices.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _kText2,
              fontSize: 13,
              height: 1.55,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                onSignIn();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _kDeep,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Sign in or create account',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Authenticated user ───────────────────────────────────────────────────────

class _UserProfile extends StatelessWidget {
  final User user;
  const _UserProfile({required this.user});

  String get _initials {
    final name = user.displayName ?? user.email ?? 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign out?',
          style: TextStyle(color: _kText1, fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: const Text(
          'You will need to sign in again to access your saved trails.',
          style: TextStyle(color: _kText2, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: _kText2, fontWeight: FontWeight.w500)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out', style: TextStyle(color: Color(0xFFB71C1C), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed == true) await AuthService().signOut();
  }

  Future<void> _sendVerification(BuildContext context) async {
    try {
      await user.sendEmailVerification();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Verification email sent'),
            backgroundColor: _kMid,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _updateDisplayName(BuildContext context) async {
    final controller = TextEditingController(text: user.displayName ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit name', style: TextStyle(color: _kText1, fontWeight: FontWeight.w700, fontSize: 17)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: _kText1),
          decoration: InputDecoration(
            hintText: 'Your name',
            hintStyle: const TextStyle(color: _kText2),
            filled: true,
            fillColor: _kSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kAccent, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: _kText2)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save', style: TextStyle(color: _kMid, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      try {
        await user.updateDisplayName(result);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Name updated'),
              backgroundColor: _kMid,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: _kSurface,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _UserHeader(
                user: user,
                initials: _initials,
                onSignOut: () => _signOut(context),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    if (!user.emailVerified)
                      _VerificationBanner(onResend: () => _sendVerification(context)),

                    if (!user.emailVerified) const SizedBox(height: 16),

                    _StatsRow(),

                    const SizedBox(height: 16),

                    _MenuCard(
                      children: [
                        _MenuItem(
                          icon: Icons.bookmark_outline_rounded,
                          iconColor: _kMid,
                          title: 'Saved trails',
                          subtitle: 'Your favourite treks',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.check_circle_outline_rounded,
                          iconColor: const Color(0xFF2196F3),
                          title: 'Trek history',
                          subtitle: 'Trails you have completed',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.star_outline_rounded,
                          iconColor: const Color(0xFFF9A825),
                          title: 'My reviews',
                          subtitle: 'Ratings you have left',
                          onTap: () {},
                          isLast: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _MenuCard(
                      children: [
                        _MenuItem(
                          icon: Icons.person_outline_rounded,
                          iconColor: const Color(0xFF7B1FA2),
                          title: 'Edit profile',
                          subtitle: 'Update your name and photo',
                          onTap: () => _updateDisplayName(context),
                        ),
                        _MenuItem(
                          icon: Icons.notifications_outlined,
                          iconColor: const Color(0xFFE53935),
                          title: 'Notifications',
                          subtitle: 'Alerts and reminders',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.language_rounded,
                          iconColor: const Color(0xFF00796B),
                          title: 'Language',
                          subtitle: 'English',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.info_outline_rounded,
                          iconColor: _kText2,
                          title: 'About',
                          subtitle: 'NepalHike v1.0.0',
                          onTap: () {},
                          isLast: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _SignOutButton(onTap: () => _signOut(context)),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ── User header ──────────────────────────────────────────────────────────────

class _UserHeader extends StatelessWidget {
  final User user;
  final String initials;
  final VoidCallback onSignOut;

  const _UserHeader({
    required this.user,
    required this.initials,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, top + 20, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F2D20), Color(0xFF1A4A32), Color(0xFF2D6A4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              GestureDetector(
                onTap: onSignOut,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.white.withOpacity(0.8), size: 13),
                      const SizedBox(width: 5),
                      Text(
                        'Sign out',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          user.photoURL != null
              ? CircleAvatar(
            radius: 42,
            backgroundImage: NetworkImage(user.photoURL!),
          )
              : Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: _kAccent.withOpacity(0.22),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            user.displayName ?? 'Trekker',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            user.email ?? '',
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: user.emailVerified
                  ? _kAccent.withOpacity(0.18)
                  : Colors.orange.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: user.emailVerified
                    ? _kAccent.withOpacity(0.35)
                    : Colors.orange.withOpacity(0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  user.emailVerified
                      ? Icons.verified_rounded
                      : Icons.warning_amber_rounded,
                  color: user.emailVerified ? _kAccent : Colors.orange,
                  size: 13,
                ),
                const SizedBox(width: 5),
                Text(
                  user.emailVerified ? 'Verified account' : 'Email not verified',
                  style: TextStyle(
                    color: user.emailVerified ? _kAccent : Colors.orange,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Verification banner ──────────────────────────────────────────────────────

class _VerificationBanner extends StatelessWidget {
  final VoidCallback onResend;
  const _VerificationBanner({required this.onResend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.mail_outline_rounded, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verify your email',
                  style: TextStyle(
                    color: _kText1,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Check your inbox for a verification link.',
                  style: TextStyle(color: _kText2, fontSize: 11.5, height: 1.4),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onResend,
            child: Text(
              'Resend',
              style: TextStyle(
                color: Colors.orange[700],
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatTile(value: '0', label: 'Saved', icon: Icons.bookmark_rounded),
        const SizedBox(width: 10),
        _StatTile(value: '0', label: 'Done', icon: Icons.check_circle_rounded),
        const SizedBox(width: 10),
        _StatTile(value: '0', label: 'Reviews', icon: Icons.star_rounded),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatTile({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: _kAccent, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: _kText1,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: _kText2,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Menu card & items ────────────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLast;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: isLast
              ? const BorderRadius.vertical(bottom: Radius.circular(18))
              : BorderRadius.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: iconColor, size: 19),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: _kText1,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: _kText2,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: _kText2.withOpacity(0.4), size: 20),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(height: 1, indent: 68, endIndent: 16, color: _kBorder),
      ],
    );
  }
}

// ── Settings card (guest) ────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _MenuCard(
      children: [
        _MenuItem(
          icon: Icons.notifications_outlined,
          iconColor: const Color(0xFFE53935),
          title: 'Notifications',
          subtitle: 'Alerts and reminders',
          onTap: () {},
        ),
        _MenuItem(
          icon: Icons.language_rounded,
          iconColor: const Color(0xFF00796B),
          title: 'Language',
          subtitle: 'English',
          onTap: () {},
        ),
        _MenuItem(
          icon: Icons.info_outline_rounded,
          iconColor: _kText2,
          title: 'About',
          subtitle: 'NepalHike v1.0.0',
          onTap: () {},
          isLast: true,
        ),
      ],
    );
  }
}

// ── Sign-out button ──────────────────────────────────────────────────────────

class _SignOutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SignOutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFFBEBEB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFB71C1C).withOpacity(0.15)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFB71C1C), size: 18),
            SizedBox(width: 8),
            Text(
              'Sign out',
              style: TextStyle(
                color: Color(0xFFB71C1C),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}