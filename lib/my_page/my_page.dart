import 'package:clubship/data/providers/auth_repository_provider.dart';
import 'package:clubship/design/brutal.dart';
import 'package:clubship/event/event_list/event_list_page.dart';
import 'package:clubship/event/providers/get_events_provider.dart';
import 'package:clubship/my_page/my_page_state.dart';
import 'package:clubship/my_page/my_page_view_model.dart';
import 'package:clubship/my_page/providers/get_user_detail_provider.dart';
import 'package:clubship/my_page/update_account_details.dart';
import 'package:clubship/notifications/providers/get_notifications_provider.dart';
import 'package:clubship/router.dart';
import 'package:clubship/sign_up/sign_up.dart';
import 'package:clubship/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

final myPageProvider = StateNotifierProvider<MyPageViewModel, MyPageState>(
  (ref) => MyPageViewModel(
    userRepository: ref.read(authRepositoryProvider),
  ),
);

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      backgroundColor: Brutal.bg,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: topPadding + 16, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (canPop) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    const AppBackButton(),
                    const SizedBox(width: 14),
                    Text('Profile', style: Brutal.display(size: 22, color: Brutal.paper)),
                  ],
                ),
              ),
              Container(height: 1, color: Brutal.hairlineColor),
              const SizedBox(height: 24),
            ],
            const ProfileHeader(),
            const SizedBox(height: 32),
            const MenuSection(),
            const SizedBox(height: 32),
            const AccountActionsSection(),
          ],
        ),
      ),
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────────────────────

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(getUserDetailProvider);

    return userState.when(
      data: (user) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Square avatar with neon border
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Brutal.elevated,
                  border: Brutal.neon(),
                  image: user?.image != null
                      ? DecorationImage(
                          image: NetworkImage(user!.image!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: user?.image == null
                    ? const Icon(
                        Icons.person,
                        size: 36,
                        color: Brutal.mute,
                      )
                    : null,
              ),
              const SizedBox(width: 20),

              // Name / username / email stack
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Guest User',
                      style: Brutal.display(size: 24, color: Brutal.paper),
                    ),
                    const SizedBox(height: 6),
                    if (user?.username != null) ...[
                      Row(
                        children: [
                          Text(
                            '@',
                            style: Brutal.label(size: 11, color: Brutal.magenta),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            user!.username!,
                            style: Brutal.label(size: 11, color: Brutal.magenta),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (user?.contactEmail != null)
                      Text(
                        user!.contactEmail!,
                        style: Brutal.body(size: 14, color: Brutal.mute),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      error: (_, __) => const SizedBox(),
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Skeletonizer(
          effect: const ShimmerEffect(
            baseColor: Brutal.elevated,
            highlightColor: Brutal.hover,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                color: Brutal.elevated,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 160,
                      height: 22,
                      color: Brutal.elevated,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 12,
                      color: Brutal.elevated,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 140,
                      height: 12,
                      color: Brutal.elevated,
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
}

// ─── Section Header helper ────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 2,
          height: 12,
          color: Brutal.magenta,
        ),
        const SizedBox(width: 10),
        Text(
          label.toUpperCase(),
          style: Brutal.label(size: 11, color: Brutal.dim),
        ),
      ],
    );
  }
}

// ─── Menu Section ─────────────────────────────────────────────────────────────

class MenuSection extends ConsumerWidget {
  const MenuSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(getUserDetailProvider);

    return userState.when(
      data: (user) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader('Account'),
              const SizedBox(height: 14),
              MenuTileItem(
                icon: Icons.person_outline,
                iconColor: Brutal.magenta,
                title: 'Account Settings',
                subtitle: 'Edit your profile',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccountUpdatePage(user: user),
                    ),
                  );
                },
              ),
              const SizedBox(height: 1),
              MenuTileItem(
                icon: Icons.confirmation_number_outlined,
                iconColor: Brutal.cyan,
                title: 'My Bookings',
                subtitle: 'View your event tickets',
                onTap: () => context.push(Routes.orderHistoryList),
              ),
              const SizedBox(height: 1),
              MenuTileItem(
                icon: Icons.account_balance_wallet_outlined,
                iconColor: Brutal.cyan,
                title: 'Wallet & Cards',
                subtitle: 'Manage payment methods',
                onTap: () => context.push(Routes.savedCardsPage),
              ),
              const SizedBox(height: 1),
              MenuTileItem(
                icon: Icons.help_outline,
                iconColor: Brutal.dim,
                title: 'Support & Help',
                subtitle: 'Get help and contact us',
                onTap: () => context.push(
                  Routes.commonWebView,
                  extra: 'https://nightpass.jp/pages/contact',
                ),
              ),
            ],
          ),
        );
      },
      error: (_, __) => const SizedBox(),
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Skeletonizer(
          effect: const ShimmerEffect(
            baseColor: Brutal.elevated,
            highlightColor: Brutal.hover,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader('Account'),
              const SizedBox(height: 14),
              MenuTileItem(
                icon: Icons.person_outline,
                iconColor: Brutal.magenta,
                title: 'Account Settings',
                subtitle: 'Edit your profile',
                onTap: () {},
              ),
              const SizedBox(height: 1),
              MenuTileItem(
                icon: Icons.confirmation_number_outlined,
                iconColor: Brutal.cyan,
                title: 'My Bookings',
                subtitle: 'View your event tickets',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Account Actions Section ──────────────────────────────────────────────────

class AccountActionsSection extends ConsumerWidget {
  const AccountActionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(myPageProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader('Account Actions'),
          const SizedBox(height: 14),

          // Logout button
          GestureDetector(
            onTap: () async {
              await viewModel.logout();
              // Invalidate all user-specific cached providers so the next
              // account doesn't see stale data from the previous session.
              ref.invalidate(getUserDetailProvider);
              ref.invalidate(getEventsProvider);
              ref.invalidate(eventListProvider);
              ref.invalidate(getNotificationsProvider);
              ref.invalidate(signUpProviderNotifier);
              if (context.mounted) {
                context.go(Routes.login);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Brutal.elevated,
                border: Border.all(color: Brutal.hairlineColor),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    color: Brutal.card,
                    child: const Icon(
                      Icons.logout,
                      color: Brutal.paper,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Logout',
                          style: Brutal.body(size: 17, color: Brutal.paper),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Sign out of your account',
                          style: Brutal.label(size: 10, color: Brutal.mute),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Brutal.mute,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 1),

          // Delete Account button
          GestureDetector(
            onTap: () async {
              // Show confirmation dialog before deletion
              // await viewModel.deleteUserAccount();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Brutal.elevated,
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.5),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    color: Colors.red.withValues(alpha: 0.12),
                    child: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delete Account',
                          style: Brutal.body(size: 17, color: Colors.red),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Permanently remove your account',
                          style: Brutal.label(size: 10, color: Brutal.mute),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.red.withValues(alpha: 0.6),
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Menu Tile Item ───────────────────────────────────────────────────────────

class MenuTileItem extends StatelessWidget {
  const MenuTileItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Brutal.elevated,
          border: Border.all(color: Brutal.hairlineColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            // Square icon container — no border radius
            Container(
              width: 36,
              height: 36,
              color: Brutal.card,
              child: Icon(
                icon,
                color: iconColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Brutal.body(size: 17, color: Brutal.paper),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Brutal.label(size: 10, color: Brutal.mute),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Brutal.mute,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
