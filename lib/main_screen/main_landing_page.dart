import 'package:clubship/clubs/club_list_page.dart';
import 'package:clubship/domain/bottom_navigator_provider.dart';
import 'package:clubship/event/event_list/event_list_page.dart';
import 'package:clubship/main_page.dart';
import 'package:clubship/my_page/my_page.dart';
import 'package:clubship/router.dart';
import 'package:clubship/widgets/app_icon.dart';
import 'package:clubship/widgets/modern_bottom_nav.dart';
import 'package:clubship/widgets/modern_nav_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MainLandingPage extends ConsumerStatefulWidget {
  const MainLandingPage({super.key});

  @override
  ConsumerState<MainLandingPage> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends ConsumerState<MainLandingPage> {
  Widget buildNavigationItemIcon(AppIconType appIconType,
      {required bool isSelected}) {
    switch (appIconType) {
      case AppIconType.homeLine:
        return ModernNavIcons.homeAnimated(isSelected: isSelected);
      case AppIconType.eventsLine:
        return ModernNavIcons.eventsAnimated(isSelected: isSelected);
      case AppIconType.clubsLine:
        return ModernNavIcons.clubsAnimated(isSelected: isSelected);
      case AppIconType.profileLine:
        return ModernNavIcons.profileAnimated(isSelected: isSelected);
      default:
        return appIcon(appIconType: appIconType, context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = ref.watch(bottomTabIndex);

    final navItems = [
      BottomNavItem(
        icon: buildNavigationItemIcon(AppIconType.homeLine,
            isSelected: currentIndex == 0),
        label: 'Home',
      ),
      BottomNavItem(
        icon: buildNavigationItemIcon(AppIconType.eventsLine,
            isSelected: currentIndex == 1),
        label: 'Events',
      ),
      BottomNavItem(
        icon: buildNavigationItemIcon(AppIconType.clubsLine,
            isSelected: currentIndex == 2),
        label: 'Clubs',
      ),
      BottomNavItem(
        icon: buildNavigationItemIcon(AppIconType.profileLine,
            isSelected: currentIndex == 3),
        label: 'Profile',
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: _getPageForIndex(currentIndex),
      bottomNavigationBar: ModernBottomNav(
        currentIndex: currentIndex,
        items: navItems,
        isVisible: true,
        // Always visible - no more hide/show animation
        onTap: (index) {
          ref.read(bottomTabIndex.notifier).setSelectedIndex(index);
        },
        onCenterTap: () {
          context.push(Routes.tickets);
        },
      ),
    );
  }


  Widget _getPageForIndex(int index) {
    switch (index) {
      case 0:
        return const HomePage(); // Your first page
      case 1:
        return const EventList(); // Your second page
      case 2:
        return const ClubList(); // Your third page
      case 3:
        return const MyPage(); // Your fourth page
      default:
        return const MyPage();
    }
  }
}
