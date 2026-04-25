import 'package:clubship/clubs/club_detail_page.dart';
import 'package:clubship/clubs/guestlist_screen.dart';
import 'package:clubship/clubs/reserve_club_table.dart';
import 'package:clubship/clubs/vip_screen.dart';
import 'package:clubship/data/supabase_models/club.dart';
import 'package:clubship/data/supabase_models/event_ticket.dart';
import 'package:clubship/drink_tickets/drink_tickets_page.dart';
import 'package:clubship/event/category_event_list.dart';
import 'package:clubship/event/event_view_model.dart';
import 'package:clubship/event/events_detail_page.dart';
import 'package:clubship/event_ticket/buy_ticket_state.dart';
import 'package:clubship/event_ticket/event_ticket_detail_page.dart';
import 'package:clubship/event_ticket/payment_page.dart';
import 'package:clubship/event_ticket/ticket_list.dart';
import 'package:clubship/launch_screen.dart';
import 'package:clubship/login/forget_password_screen.dart';
import 'package:clubship/login/login_form.dart';
import 'package:clubship/login/reset_password_screen.dart';
import 'package:clubship/main_screen/main_landing_page.dart';
import 'package:clubship/my_page/order_history/order_history.dart';
import 'package:clubship/notifications/notifications_page.dart';
import 'package:clubship/payment/add_custom_amount_screen.dart';
import 'package:clubship/payment/transaction_history.dart';
import 'package:clubship/payment/user_wallet.dart';
import 'package:clubship/search/search_input_screen.dart';
import 'package:clubship/send_tickets/send_drink_ticket.dart';
import 'package:clubship/send_tickets/send_event_tickets.dart';
import 'package:clubship/sign_up/sign_up.dart';
import 'package:clubship/supabase/supabase_client.dart';
import 'package:clubship/wallet/saved_cards.dart';
import 'package:clubship/widgets/common_web_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract class Routes {
  static const String mainLandingScreen = '/home';
  static const String sendEventTicket = '/send-event-ticket';
  static const String sendDrinkTicket = '/send-drink-ticket';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String editEvent = '/edit-event';
  static const String editClub = '/edit-club';
  static const String addEvent = '/add-club';
  static const String eventDetail = '/edit-detail-screen';
  static const String location = '/location';
  static const String forgetPassword = '/forget-password';
  static const String resetPassword = '/reset-password';
  static const String registerEmailScreen = '/register-email';
  static const String loginSelection = '/login-selection';
  static const String registerOrganiser = '/register-organiser';
  static const String addClubStaff = '/add-club-staff';
  static const String staffList = '/staff-list';
  static const String editOrganiser = '/edit-organiser';
  static const String clubDetailScreen = '/club-detail';
  static const String ticketBuyingScreen = '/ticket-buying';
  static const String addCustomAmount = '/add-custom-amount';
  static const String guestlist = '/guestlist';
  static const String vip = '/vip';
  static const String tickets = '/tickets';
  static const String ticketDetail = '/ticket-detail';

  static String transactionDetail(String id) => '/transaction-detail/$id';
  static const String transactionHistory = '/transaction-history';
  static const String wallet = '/wallet';
  static const String orderSummary = '/order-summary';
  static const String search = '/search';
  static const String categoryDrinkList = '/categoryDrinkList';
  static const String orderHistoryList = '/categoryDrinkList';
  static const String savedCardsPage = '/savedCardsPage';
  static const String reserveClub = '/reserveClub';
  static const commonWebView = '/common_webview';
  static const String notifications = '/notifications';
}

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: Routes.login,
  redirect: _redirectIfSignedIn,
  refreshListenable: AuthStateNotifier(),
  routes: [
    GoRoute(
      path: Routes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: Routes.savedCardsPage,
      builder: (context, state) => const SavedCardsPage(),
    ),

    GoRoute(
      path: Routes.sendDrinkTicket,
      builder: (context, state) => SendDrinkTickets(
        ticketId: state.extra as String,
      ),
    ),
    GoRoute(
      path: Routes.orderHistoryList,
      builder: (context, state) => const OrderHistoryScreen(),
    ),
    GoRoute(
      path: Routes.categoryDrinkList,
      builder: (context, state) => CategoryDrinkList(
        params: state.extra as CategoryEventListParams,
      ),
    ),
    GoRoute(
      path: Routes.forgetPassword,
      builder: (context, state) => const ForgetPasswordScreen(),
    ),
    GoRoute(
      path: Routes.resetPassword,
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: Routes.search,
      builder: (context, state) => const SearchInputScreen(),
    ),
    GoRoute(
      path: Routes.notifications,
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: Routes.registerEmailScreen,
      builder: (context, state) => const RegisterProfileScreen(),
    ),
    GoRoute(
      path: Routes.orderSummary,
      builder: (context, state) => OrderSummaryPage(
        summary: state.extra as BuyTicketState,
      ),
    ),
    GoRoute(
      path: Routes.wallet,
      builder: (context, state) => UserWalletScreen(
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: Routes.transactionHistory,
      builder: (context, state) => TransactionHistoryScreen(
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: Routes.addCustomAmount,
      builder: (context, state) => const AddCustomAmountScreen(),
    ),
    // GoRoute(
    //   path: Routes.transactionDetail(':id'),
    //   builder: (context, state) => OrderHistoryDetailScreen(
    //     key: state.pageKey,
    //     id: state.pathParameters['id'] ?? '',
    //   ),
    // ),

    GoRoute(
      path: Routes.sendEventTicket,
      builder: (context, state) => SendTickets(
        ticketId: state.extra as String,
      ),
    ),
    GoRoute(
      path: Routes.eventDetail,
      pageBuilder: (context, state) {
        final event = state.extra as EventViewModel;
        return CustomTransitionPage(
          key: state.pageKey,
          child: EventDetailPage(eventItem: event),
          transitionDuration: const Duration(milliseconds: 400),
          // 👈 slow down
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (_, animation, __, child) => child, // Allow Hero
        );
      },
    ),

    // GoRoute(
    //   pageBuilder: (context, state) => CustomTransitionPage(
    //     key: state.pageKey,
    //     child: EventDetailPage(eventItem: state.extra as EventViewModel),
    //     transitionDuration: const Duration(milliseconds: 600),
    //     reverseTransitionDuration: const Duration(milliseconds: 600),
    //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
    //       final curved = CurvedAnimation(
    //         parent: animation,
    //         curve: Curves.easeOutQuart,
    //         reverseCurve: Curves.easeInQuart,
    //       );
    //
    //       return SlideTransition(
    //         position: Tween<Offset>(
    //           begin: const Offset(0.0, 1.0), // from bottom
    //           end: Offset.zero,
    //         ).animate(curved),
    //         child: child,
    //       );
    //     },
    //   ),
    //   path: Routes.eventDetail,
    // ),
    GoRoute(
      path: Routes.loginSelection,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: Routes.mainLandingScreen,
      builder: (context, state) => const MainLandingPage(),
    ),
    GoRoute(
      path: Routes.ticketBuyingScreen,
      builder: (context, state) =>
          TicketBuyingScreen(eventItem: state.extra as EventViewModel),
    ),
    GoRoute(
      path: Routes.clubDetailScreen,
      builder: (context, state) => ClubDetailPage(
        club: state.extra as Club,
      ),
    ),
    GoRoute(
      path: Routes.guestlist,
      builder: (context, state) => GuestlistScreen(
        event: state.extra as EventViewModel,
      ),
    ),
    GoRoute(
      path: Routes.vip,
      builder: (context, state) => VipScreen(
        event: state.extra as EventViewModel,
      ),
    ),
    GoRoute(
      path: Routes.tickets,
      builder: (context, state) => const TicketsPage(
      ),
    ),
    GoRoute(
      path: Routes.ticketDetail,
      builder: (context, state) => EventTicketDetailPage(
        ticket: state.extra as EventTicket,
      ),
    ),
    GoRoute(
      path: Routes.reserveClub,
      builder: (context, state) => ReserveClubScreen(
        club: state.extra as Club,
      ),
    ),
    GoRoute(
      path: Routes.commonWebView,
      pageBuilder: (context, state) {
        final Object? extra = state.extra;
        final String url = extra as String;
        return CustomTransitionPage(
          key: state.pageKey,
          child: CommonWebView(
            urlParameter: url,
          ),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) =>
              FadeTransition(
                opacity:
                CurveTween(curve: Curves.easeInOut).animate(animation),
                child: child,
              ),
        );
      },
    ),
  ],
);

// Auth state notifier to control router refresh
class AuthStateNotifier extends ChangeNotifier {
  AuthStateNotifier() {
    // Listen to auth state changes
    supabase.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }
}

String? _redirectIfSignedIn(BuildContext context, GoRouterState state) {
  final session = supabase.auth.currentSession;
  final isLoggedIn = session != null;

  // Only redirect on specific paths to prevent issues on app resume
  if (isLoggedIn) {
    // Never redirect from register screen - user might be completing registration
    if (state.uri.path == Routes.registerEmailScreen) {
      return null;
    }

    // Only redirect from login/forgot password to home
    if (state.uri.path == Routes.login ||
        state.uri.path == Routes.forgetPassword) {
      return Routes.mainLandingScreen;
    }

    // Allow access to reset password screen even when logged in
    if (state.uri.path == Routes.resetPassword) {
      return null;
    }
  } else {
    // Only redirect to login if trying to access protected routes
    if (state.uri.path == Routes.mainLandingScreen ||
        state.uri.path.startsWith('/home') ||
        state.uri.path == Routes.splash) {
      return Routes.login;
    }
  }
  return null;
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
