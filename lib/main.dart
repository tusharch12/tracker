import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/route_constants.dart';
import 'features/home/screens/main_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/borrowers/screens/borrower_list_screen.dart';
import 'features/borrowers/screens/borrower_detail_screen.dart';
import 'features/borrowers/screens/borrower_form_screen.dart';
import 'features/loans/screens/loan_list_screen.dart';
import 'features/loans/screens/loan_form_screen.dart';
import 'features/loans/screens/loan_detail_screen.dart';
import 'features/payments/screens/payment_form_screen.dart';
import 'features/auth/widgets/auth_wrapper.dart';
import 'features/auth/screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: TrackerApp()));
}

class TrackerApp extends StatelessWidget {
  const TrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());

          case RouteConstants.dashboard:
            return MaterialPageRoute(builder: (_) => const DashboardScreen());

          case RouteConstants.borrowerList:
            return MaterialPageRoute(
              builder: (_) => const BorrowerListScreen(),
            );

          case RouteConstants.borrowerDetail:
            final borrowerId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => BorrowerDetailScreen(borrowerId: borrowerId),
            );

          case RouteConstants.borrowerForm:
            final borrowerId = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => BorrowerFormScreen(borrowerId: borrowerId),
            );

          // Loan routes
          case '/loans':
            final borrowerId = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => LoanListScreen(borrowerId: borrowerId),
            );

          case '/loans/detail':
            final loanId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => LoanDetailScreen(loanId: loanId),
            );

          case '/loans/form':
            if (settings.arguments is Map) {
              final args = settings.arguments as Map;
              return MaterialPageRoute(
                builder: (_) => LoanFormScreen(
                  borrowerId: args['borrowerId'] as String,
                  loanId: args['loanId'] as String?,
                ),
              );
            } else {
              final borrowerId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => LoanFormScreen(borrowerId: borrowerId),
              );
            }

          // Payment routes
          case '/payments/form':
            final loanId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => PaymentFormScreen(loanId: loanId),
            );

          default:
            return MaterialPageRoute(builder: (_) => const MainScreen());
        }
      },
    );
  }
}
