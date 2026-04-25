import 'package:clubship/onboarding/onboarding_view_model.dart';
import 'package:clubship/router.dart';
import 'package:clubship/widgets/nomu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final onboardingProvider = ChangeNotifierProvider<OnBoardingProvider>((ref) {
  final provider = OnBoardingProvider();
  provider.initialize();
  return provider;
});

class OnBoardingPage extends ConsumerStatefulWidget {
  const OnBoardingPage({super.key});

  @override
  ConsumerState<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends ConsumerState<OnBoardingPage> {
  OnBoardingProvider get _onboardingProvider => ref.read(onboardingProvider);
  int currentPage = 0;
  PageController pageController = PageController();

  List<Map<String, String>> onboardingData = [
    {
      'title': 'Welcome to Clubship',
      'subtitle':
          'Discover Exclusive Events Near You – Your Ticket to the Best Clubbing Experiences Awaits!',
      'image': 'assets/images/logo.png',
    },
    {
      'title': 'Explore Exciting Features',
      'subtitle':
          'Skip the Lines, Secure Your Spot – Book Tickets Instantly for the Hottest Parties!.',
      'image': 'assets/images/logo.png',
    },
    {
      'title': 'Get Started Now',
      'subtitle': 'Track, Share, Party – All Your Clubbing Plans in One Place!',
      'image': 'assets/images/logo.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount: onboardingData.length,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return buildOnboardingItem(index);
              },
            ),
          ),
          const SizedBox(height: 24.0),
          buildIndicatorDots(),
          const SizedBox(height: 24.0),
          buildActionButton(),
        ],
      ),
    );
  }

  Widget buildOnboardingItem(int index) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            onboardingData[index]['image']!,
            height: 200.0,
            width: 200.0,
          ),
          const SizedBox(height: 32.0),
          Text(
            onboardingData[index]['title']!,
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            onboardingData[index]['subtitle']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIndicatorDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        onboardingData.length,
        (index) => buildDot(index),
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 6.0),
      height: 8.0,
      width: currentPage == index ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: currentPage == index ? Colors.purpleAccent : Colors.grey,
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }

  Widget buildActionButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: NomuButton.primary(
        onPressed: () async {
          if (currentPage == onboardingData.length - 1) {
            await _onboardingProvider.setOnboardingShown().whenComplete(() {
              if (mounted) {
                context.push(Routes.loginSelection);
              }
            });
          } else {
            pageController.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease,
            );
          }
        },
        text: 'Next',
      ),
    );
  }
}
