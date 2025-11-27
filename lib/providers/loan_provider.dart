import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/loan.dart';
import '../models/payment.dart';
import 'providers.dart';

// Loans by borrower provider
final loansByBorrowerProvider = FutureProvider.family<List<Loan>, String>((ref, borrowerId) async {
  final repo = ref.watch(loanRepositoryProvider);
  return await repo.getByBorrowerId(borrowerId);
});

// All loans provider
final allLoansProvider = FutureProvider<List<Loan>>((ref) async {
  final repo = ref.watch(loanRepositoryProvider);
  return await repo.getAll();
});

// Single loan provider
final loanProvider = FutureProvider.family<Loan?, String>((ref, loanId) async {
  final repo = ref.watch(loanRepositoryProvider);
  return await repo.getById(loanId);
});

// Payments for loan provider
final paymentsForLoanProvider = FutureProvider.family<List<Payment>, String>((ref, loanId) async {
  final repo = ref.watch(paymentRepositoryProvider);
  return await repo.getByLoanId(loanId);
});

// Loan with calculations provider
final loanWithCalculationsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, loanId) async {
  final loanRepo = ref.watch(loanRepositoryProvider);
  final paymentRepo = ref.watch(paymentRepositoryProvider);
  final calcService = ref.watch(calculationServiceProvider);
  
  final loan = await loanRepo.getById(loanId);
  if (loan == null) return {};
  
  final payments = await paymentRepo.getByLoanId(loanId);
  
  return {
    'loan': loan,
    'payments': payments,
    'totalPaid': calcService.calculateTotalPaid(payments),
    'remaining': calcService.calculateRemaining(loan, payments),
    'installmentsRemaining': calcService.calculateInstallmentsRemaining(loan, payments),
    'nextDueDate': calcService.calculateNextDueDate(loan, payments),
    'isOverdue': calcService.isOverdue(loan, payments),
    'overdueAmount': calcService.calculateOverdueAmount(loan, payments),
    'progress': calcService.calculateProgress(loan, payments),
    'expectedEndDate': calcService.calculateExpectedEndDate(loan, payments),
  };
});

// Refresh loans
final refreshLoansProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(allLoansProvider);
  };
});
