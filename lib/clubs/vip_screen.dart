import 'package:carousel_slider/carousel_slider.dart';
import 'package:clubship/colors.dart';
import 'package:clubship/event/event_view_model.dart';
import 'package:clubship/event/events_detail_page.dart';
import 'package:clubship/my_page/providers/get_user_detail_provider.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/widgets/app_button.dart';
import 'package:clubship/widgets/app_icon.dart';
import 'package:clubship/widgets/app_text_styles.dart';
import 'package:clubship/widgets/carousal_slider_images.dart';
import 'package:clubship/widgets/clubship_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

class VipScreen extends ConsumerStatefulWidget {
  const VipScreen({
    super.key,
    required this.event,
  });

  final EventViewModel event;

  @override
  ConsumerState<VipScreen> createState() => _GuestListScreenState();
}

class _GuestListScreenState extends ConsumerState<VipScreen> {
  int _currentIndex = 0;

  final _scrollController = ScrollController();
  final _contactFocusNode = FocusNode();
  final _guestFocusNode = FocusNode();

  @override
  void dispose() {
    _scrollController.dispose();
    _contactFocusNode.dispose();
    _guestFocusNode.dispose();
    super.dispose();
  }

  void _scrollToField(FocusNode node) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (node.context != null) {
        Scrollable.ensureVisible(
          node.context!,
          duration: const Duration(milliseconds: 250),
          alignment: 0.1,
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
      return Scaffold(
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: ColorPallete.cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: AnimatedPadding(
            // 🏗 moves with keyboard
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: SizedBox(
              width: double.infinity, // makes it full-width
              child: AppButton.primary(
                onPressed: () async {},
                text: 'Contact',
              ),
            ),
          ),
        ),
        appBar: AppBar(
          title: Text(clubModel.name),
          backgroundColor: ColorPallete.cardColor,
          elevation: 0,
        ),
        backgroundColor: ColorPallete.backgroundcolor,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ColorPallete.backgroundcolor,
                ColorPallete.cardColor.withValues(alpha: 0.3),
              ],
            ),
          ),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              SizedBox(
                height: 400,
                child: images.length == 1
                    ? SingleImageCard(event: widget.event)

                    : Column(





                        children: [


                          // 🔑 Wrap the PageView in PageStorage so it works inside Hero
                          CarouselSlider(
                            key: const PageStorageKey('event-carousel'),
                            options: CarouselOptions(
                              autoPlay: false,
                              aspectRatio: 17 / 16,
                              viewportFraction: 2,
                              enlargeCenterPage: true,
                              onPageChanged: (index, reason) {
                                setState(() => _currentIndex = index);
                              },
                            ),
                            items: images
                                .map(
                                  (url) => ImageCard(imageUrl: url),
                                )
                                .toList(),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          DotsIndicator(
                            dotCount: images.length,
                            currentIndex: _currentIndex,
                          ),
                        ],
                      ),
              ),
              _buildCard(
                image: NetworkImage(clubModel.image),
                title: clubModel.name,
                description: clubModel.description ?? '',
                event: clubModel,
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
                      'VIP Guest Information',
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
                initialText: user?.name ?? '',
                hintText: 'Your name',
                onChanged: (String) {},
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
                initialText: user?.contactEmail ?? '',
                hintText: 'Email address',
                onChanged: (String) {},
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
                initialText: widget.event.startDate.substring(0, 10),
                hintText: 'Event date',
                onChanged: (String) {},
              ).pad.vertical.p4.pad.horizontal.p8,
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8, bottom: 4),
                child: Text(
                  'Contact Number',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
              ClubTextField(
                focusNode: _contactFocusNode,
                hintText: 'Phone number',
                onTap: () => _scrollToField(_contactFocusNode),
                onChanged: (String) {},
              ).pad.vertical.p4.pad.horizontal.p8,
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8, bottom: 4),
                child: Text(
                  'Number of Guests',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
              ClubTextField(
                focusNode: _guestFocusNode,
                hintText: 'Total guests',
                onTap: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToField(_guestFocusNode);
                  });
                },
                onChanged: (String) {},
              ).pad.vertical.p4.pad.horizontal.p8,
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorPallete.cardColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ColorPallete.brightPink.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: ColorPallete.brightPink.withValues(alpha: 0.7),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Once we receive your request, we will contact you through email/phone mentioned above. Please check your email.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.7),
                          height: 1.5,
                        ),
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
        backgroundColor: ColorPallete.cardColor,
        elevation: 0,
      ),
      backgroundColor: ColorPallete.backgroundcolor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorPallete.backgroundcolor,
              ColorPallete.cardColor.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: Skeletonizer(
          effect: ShimmerEffect(
            baseColor: Colors.grey[800]!,
            highlightColor: Colors.grey[700]!,
            duration: const Duration(milliseconds: 1000),
          ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 400,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppIcons.location(size: 20).pad.right.p4,
                        const Expanded(
                          child: Text('123 Roppongi Street, Tokyo, Japan'),
                        ),
                      ],
                    ).pad.bottom.p8,
                    Row(
                      children: [
                        AppIcons.whiteClock().pad.right.p4,
                        const Text('22:00 PM'),
                      ],
                    ).pad.bottom.p8,
                    Row(
                      children: [
                        AppIcons.whiteCalender().pad.right.p4,
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
                      'VIP Guest Information',
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
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8, bottom: 4),
                child: Text(
                  'Contact Number',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
              ClubTextField(
                initialText: '+81 90 1234 5678',
                hintText: 'Phone number',
                onChanged: (_) {},
              ).pad.vertical.p4.pad.horizontal.p8,
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8, bottom: 4),
                child: Text(
                  'Number of Guests',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
              ClubTextField(
                initialText: '4',
                hintText: 'Total guests',
                onChanged: (_) {},
                ).pad.vertical.p4.pad.horizontal.p8,
              ],
            ),
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
    final images = [widget.event.image, ...widget.event.subImages];

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
                AppIcons.location(size: 20).pad.right.p4,
                Expanded(child: Text(event?.club.locationAddress ?? '')),
              ],
            ).pad.bottom.p8,
            Row(
              children: [
                AppIcons.whiteClock().pad.right.p4,
                Text(event?.startDate.toTimeString() ?? ''),
              ],
            ).pad.bottom.p8,
            Row(
              children: [
                AppIcons.whiteCalender().pad.right.p4,
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
