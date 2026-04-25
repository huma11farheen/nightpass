import 'package:clubship/colors.dart';
import 'package:clubship/data/supabase_models/gender.dart';
import 'package:clubship/domain/bottom_navigator_provider.dart';
import 'package:clubship/event/event_view_model.dart';
import 'package:clubship/my_page/providers/get_user_detail_provider.dart';
import 'package:clubship/router.dart';
import 'package:clubship/utils/extensions.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/utils/typography.dart';
import 'package:clubship/widgets/app_button.dart';
import 'package:clubship/widgets/app_icon.dart';
import 'package:clubship/widgets/app_text_styles.dart';
import 'package:clubship/widgets/clubship_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../data/providers/ticket_repository_provider.dart';
import '../repository/ticket_repository.dart';

class GuestlistScreen extends ConsumerStatefulWidget {
  const GuestlistScreen({
    super.key,
    required this.event,
  });

  final EventViewModel event;

  @override
  ConsumerState<GuestlistScreen> createState() => _GuestListScreenState();
}

class _GuestListScreenState extends ConsumerState<GuestlistScreen> {
  bool loading = false;
  final _scrollController = ScrollController();
  final _contactFocusNode = FocusNode();
  final _guestCountFocusNode = FocusNode();

  @override
  void dispose() {
    _scrollController.dispose();
    _contactFocusNode.dispose();
    _guestCountFocusNode.dispose();
    super.dispose();
  }

  void _scrollToFocusedField(FocusNode node) {
    // Give a tiny delay for keyboard animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!_scrollController.hasClients) return;
      final object = node.context;
      if (object != null) {
        Scrollable.ensureVisible(
          object,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.3,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final clubModel = widget.event;
    final userDetails = ref.watch(getUserDetailProvider);
    List<String> images = List.from(clubModel.subImages);

    images.insert(0, clubModel.image);

    return userDetails.when(data: (user) {
      return Stack(children: [
        Scaffold(
          resizeToAvoidBottomInset: true,
          bottomNavigationBar: SafeArea(
              child: AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.only(
              top: 16,
              left: 8,
              right: 8,
              bottom: 16,
            ),
            child: AppButton.primary(
              onPressed: widget.event.registeredGuestlist >=
                      widget.event.gustlist
                  ? () {}
                  : () async {
                      setState(() {
                        loading = true;
                      });
                      final result = await ref
                          .read(ticketRepositoryProvider)
                          .addToGuestlist(
                            eventId: widget.event.id,
                            femaleCount: user?.gender == Gender.female ? 1 : 0,
                            maleCount: user?.gender == Gender.male ? 1 : 0,
                            isGuestlist: true,
                            femaleList: user?.gender == Gender.female ? [user?.name ?? ''] : [],
                            maleList: user?.gender == Gender.male ? [user?.name ?? ''] : [],
                          );

                      if (result == ApiResult.success) {
                        if (context.mounted) {
                          context.showSnackbar(message: 'Added to Guestlist');
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final rootContext = rootNavigatorKey.currentContext;
                            if (rootContext != null) {
                              GoRouter.of(rootContext)
                                  .go(Routes.mainLandingScreen);
                              ref
                                  .read(bottomTabIndex.notifier)
                                  .setSelectedIndex(3);
                            } else {
                              debugPrint(
                                  "❗ rootNavigatorKey.currentContext is null");
                            }
                          });
                        }
                      } else {
                        if (context.mounted) {
                          context.showSnackbar(message: 'Failed to purchase');
                        }
                      }
                      setState(() {
                        loading = false;
                      });
                    },
              text: widget.event.registeredGuestlist >= widget.event.gustlist
                  ? 'Sold out'
                  : 'Generate QR code',
            ).pad.left.p8.pad.right.p8.pad.bottom.p16,
          )),
          appBar: AppBar(
            title: Text(clubModel.name),
          ),
          backgroundColor: Colors.black.withValues(alpha: 0.9),
          body: SingleChildScrollView(
            controller: _scrollController,
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildCard(
                      image: NetworkImage(clubModel.image),
                      title: clubModel.name,
                      description: clubModel.description ?? '',
                      event: clubModel,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Guest Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.9),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 12, top: 8, bottom: 4),
                      child: Text(
                        'Name',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    ClubTextField(
                      initialText: user?.name ?? '',
                      hintText: 'Your name',
                      onChanged: (String) {},
                    ).pad.vertical.p4.pad.horizontal.p8,
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 12, top: 8, bottom: 4),
                      child: Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    ClubTextField(
                      onTap: () => _scrollToFocusedField(_contactFocusNode),
                      initialText: user?.contactEmail ?? '',
                      hintText: 'Email address',
                      onChanged: (String) {},
                    ).pad.vertical.p4.pad.horizontal.p8,
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 12, top: 8, bottom: 4),
                      child: Text(
                        'Event Date',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    ClubTextField(
                      onTap: () => _scrollToFocusedField(_guestCountFocusNode),
                      initialText: widget.event.startDate.substring(0, 10),
                      hintText: 'Event date',
                      onChanged: (String) {},
                    ).pad.vertical.p4.pad.horizontal.p8,
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✓ You\'ll be added to the Guest list',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Once you generate your QR code, it will be saved in your Bookings menu and must be shown at the door for entry.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.6),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (loading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ]);
    }, error: (s, v) {
      return const SizedBox();
    }, loading: () {
      return _buildLoadingSkeleton();
    });
  }

  Widget _buildLoadingSkeleton() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading...'),
      ),
      backgroundColor: Colors.black.withValues(alpha: 0.9),
      body: Skeletonizer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppIcons.purpleLocation().pad.right.p4,
                        const Expanded(
                          child: Text('123 Shibuya Street, Tokyo, Japan'),
                        ),
                      ],
                    ).pad.bottom.p8,
                    const Text('22:00 PM'),
                    Row(
                      children: [
                        AppIcons.calender().pad.right.p4,
                        const Text('2025-01-15'),
                      ],
                    ).pad.bottom.p8,
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Guest Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8, bottom: 4),
                child: Text(
                  'Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
              ClubTextField(
                initialText: 'John Doe',
                hintText: 'Your name',
                onChanged: (_) {},
              ).pad.vertical.p4.pad.horizontal.p8,
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8, bottom: 4),
                child: Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
              ClubTextField(
                initialText: 'john.doe@example.com',
                hintText: 'Email address',
                onChanged: (_) {},
              ).pad.vertical.p4.pad.horizontal.p8,
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8, bottom: 4),
                child: Text(
                  'Event Date',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
              ClubTextField(
                initialText: '2025-01-15',
                hintText: 'Event date',
                onChanged: (_) {},
              ).pad.vertical.p4.pad.horizontal.p8,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required NetworkImage image,
    required String title,
    required String description,
    EventViewModel? event,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppIcons.purpleLocation().pad.right.p4,
                Expanded(child: Text(event?.club.locationAddress ?? '')),
              ],
            ).pad.bottom.p8,
            Text(event?.startDate.toTimeString() ?? ''),
            Row(
              children: [
                AppIcons.calender().pad.right.p4,
                Text(event?.startDate.substring(0, 10) ?? ''),
              ],
            ).pad.bottom.p8,
          ],
        ),
      ),
    );
  }
}

class PriceTag extends StatelessWidget {
  final String price;

  const PriceTag({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: const BoxDecoration(
              color: ColorPallete.brightPink,
              borderRadius: BorderRadius.all(Radius.circular(16))),
          height: 34,
          width: 100,
          child: const Center(child: Text('NIGHT CLUB')),
        ),
        Row(
          children: [
            const SizedBox(width: 9),
            const Text(
              'Starts from : ¥ ',
              textAlign: TextAlign.left,
              style: AppTextStyles.titleSmall,
            ),
            Text(
              price,
              textAlign: TextAlign.left,
              style: const TextStyle(
                height: 1.6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
