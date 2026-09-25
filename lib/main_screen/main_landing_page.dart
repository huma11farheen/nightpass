import 'package:clubship/clubs/club_list_page.dart';
import 'package:clubship/design/brutal.dart';
import 'package:clubship/domain/bottom_navigator_provider.dart';
import 'package:clubship/drink_tickets/drink_tickets_page.dart';
import 'package:clubship/event/event_list/event_list_page.dart';
import 'package:clubship/main_page.dart';
import 'package:clubship/whats_happening/whats_happening_page.dart';
import 'package:clubship/widgets/app_icon.dart';
import 'package:clubship/widgets/modern_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainLandingPage extends ConsumerStatefulWidget {
  const MainLandingPage({super.key});

  @override
  ConsumerState<MainLandingPage> createState() => _MainLandingPageState();
}

class _MainLandingPageState extends ConsumerState<MainLandingPage>
    with SingleTickerProviderStateMixin {
  static const _pages = [
    HomePage(),
    EventList(),
    ClubList(),
    WhatsHappeningPage(),
    TicketsPage(),
  ];

  static const _navItems = [
    BottomNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    BottomNavItem(
      icon: Icons.local_fire_department_outlined,
      selectedIcon: Icons.local_fire_department_rounded,
      label: 'Events',
    ),
    BottomNavItem(
      icon: Icons.nightlife_outlined,
      selectedIcon: Icons.nightlife_rounded,
      label: 'Clubs',
    ),
    BottomNavItem(
      icon: Icons.bolt_outlined,
      selectedIcon: Icons.bolt_rounded,
      label: 'Tonight',
    ),
  ];

  late final AnimationController _loaderCtrl;
  late final Animation<double> _loaderOpacity;
  bool _loaderVisible = true;

  @override
  void initState() {
    super.initState();
    _loaderCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _loaderOpacity = CurvedAnimation(parent: _loaderCtrl, curve: Curves.easeOut);

    // Show loader for ~1.2s then fade it out.
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      _loaderCtrl.forward().then((_) {
        if (mounted) setState(() => _loaderVisible = false);
      });
    });
  }

  @override
  void dispose() {
    _loaderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomTabIndex);

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
            children: _pages,
          ),
          if (_loaderVisible)
            FadeTransition(
              opacity: ReverseAnimation(_loaderOpacity),
              child: const _AppLoader(),
            ),
        ],
      ),
      bottomNavigationBar: ModernBottomNav(
        currentIndex: currentIndex,
        items: _navItems,
        onTap: (i) => ref.read(bottomTabIndex.notifier).setSelectedIndex(i),
        isCenterSelected: currentIndex == 4,
        onCenterTap: () => ref.read(bottomTabIndex.notifier).setSelectedIndex(4),
      ),
    );
  }
}

class _AppLoader extends StatefulWidget {
  const _AppLoader();

  @override
  State<_AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<_AppLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.2, end: 0.7).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0A0F),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _glow,
              builder: (_, child) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Brutal.magenta.withValues(alpha: _glow.value * 0.4),
                      blurRadius: 48,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: child,
              ),
              child: AppIcons.logo(size: 52, color: Brutal.paper),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                backgroundColor: Brutal.elevated,
                valueColor: AlwaysStoppedAnimation<Color>(Brutal.magenta),
                minHeight: 2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'LOADING',
              style: Brutal.label(size: 11, color: Brutal.mute),
            ),
          ],
        ),
      ),
    );
  }
}
