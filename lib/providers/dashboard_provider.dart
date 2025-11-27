import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_summary.dart';
import '../models/loan.dart';
import '../models/payment.dart';
import 'providers.dart';

// Dashboard summary provider
final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final borrowerRepo = ref.watch(borrowerRepositoryProvider);
  final loanRepo = ref.watch(loanRepositoryProvider);
  final paymentRepo = ref.watch(paymentRepositoryProvider);
  final calcService = ref.watch(calculationServiceProvider);

  // Fetch all data
  final borrowers = await borrowerRepo.getAll();
  final loans = await loanRepo.getAll();
  final payments = await paymentRepo.getAll();

  // Create payments map for calculations
  final paymentsMap = <String, List<Payment>>{};
  for (final payment in payments) {
    paymentsMap.putIfAbsent(payment.loanId, () => <Payment>[]).add(payment);
  }

  // Calculate metrics
  final totalLent = calcService.calculateTotalLent(loans);
  final totalReceived = calcService.calculateTotalReceived(payments);
  final totalRemaining = calcService.calculateTotalRemaining(loans, paymentsMap);
  final dueThisMonth = calcService.calculateTotalDueThisMonth(loans, paymentsMap);
  
  final activeLoans = await loanRepo.getCountByStatus(LoanStatus.active);
  final completedLoans = await loanRepo.getCountByStatus(LoanStatus.completed);
  final overdueLoans = calcService.getOverdueLoans(loans, paymentsMap);

  return DashboardSummary(
    totalLent: totalLent,
    totalReceived: totalReceived,
    totalRemaining: totalRemaining,
    dueThisMonth: dueThisMonth,
    overdueLoansCount: overdueLoans.length,
    activeLoansCount: activeLoans,
    completedLoansCount: completedLoans,
    totalBorrowersCount: borrowers.length,
  );
});

// Refresh dashboard
final refreshDashboardProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(dashboardSummaryProvider);
  };
});
