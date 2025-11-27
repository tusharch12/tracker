import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/providers/auth_provider.dart';
import '../repositories/borrower_repository.dart';
import '../repositories/loan_repository.dart';
import '../repositories/payment_repository.dart';
import '../repositories/firestore_borrower_repository.dart';
import '../repositories/firestore_loan_repository.dart';
import '../repositories/firestore_payment_repository.dart';
import '../services/calculation_service.dart';
import '../services/validation_service.dart';

// Repository Providers
final borrowerRepositoryProvider = Provider<BorrowerRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('User not authenticated');
  return FirestoreBorrowerRepository(user.uid);
});

final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('User not authenticated');
  return FirestoreLoanRepository(user.uid);
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('User not authenticated');
  return FirestorePaymentRepository(user.uid);
});

// Service Providers
final calculationServiceProvider = Provider<CalculationService>((ref) {
  return CalculationService();
});

final validationServiceProvider = Provider<ValidationService>((ref) {
  return ValidationService(
    loanRepository: ref.watch(loanRepositoryProvider),
    paymentRepository: ref.watch(paymentRepositoryProvider),
    calculationService: ref.watch(calculationServiceProvider),
  );
});
