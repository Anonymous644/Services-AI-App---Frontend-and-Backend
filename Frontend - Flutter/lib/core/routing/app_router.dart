import 'package:flutter/material.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/customer/presentation/customer_main_screen.dart';
import '../../features/provider/presentation/provider_main_screen.dart';
import '../../features/bookings/presentation/booking_details_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String customerMain = '/customer-main';
  static const String providerMain = '/provider-main';
  static const String bookingDetails = '/booking-details';
  static const String editProfile = '/edit-profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case customerMain:
        return MaterialPageRoute(builder: (_) => const CustomerMainScreen());
      case providerMain:
        return MaterialPageRoute(builder: (_) => const ProviderMainScreen());
      case bookingDetails:
        final id = settings.arguments as String?;
        if (id == null)
          return MaterialPageRoute(
            builder: (_) =>
                const Scaffold(body: Center(child: Text('Error: No ID'))),
          );
        return MaterialPageRoute(
          builder: (_) => BookingDetailsScreen(bookingId: id),
        );
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
