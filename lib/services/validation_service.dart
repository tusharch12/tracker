import '../models/loan.dart';
import '../repositories/loan_repository.dart';
import '../repositories/payment_repository.dart';
import 'calculation_service.dart';

/// Service for business validation rules
class ValidationService {
  final LoanRepository _loanRepository;
  final PaymentRepository _paymentRepository;
  final CalculationService _calculationService;

  ValidationService({
    required LoanRepository loanRepository,
    required PaymentRepository paymentRepository,
    required CalculationService calculationService,
  })  : _loanRepository = loanRepository,
        _paymentRepository = paymentRepository,
        _calculationService = calculationService;

  /// Validate if a borrower can be deleted
  Future<ValidationResult> canDeleteBorrower(String borrowerId) async {
    final loans = await _loanRepository.getByBorrowerId(borrowerId);
    final activeLoans = loans.where((loan) => loan.status == LoanStatus.active).toList();

    if (activeLoans.isNotEmpty) {
      return ValidationResult.error(
        'Cannot delete borrower with ${activeLoans.length} active loan(s). '
        'Please complete or cancel all loans first.',
      );
    }

    return ValidationResult.success();
  }

  /// Validate if a loan can be deleted
  Future<ValidationResult> canDeleteLoan(String loanId) async {
    final payments = await _paymentRepository.getByLoanId(loanId);

    if (payments.isNotEmpty) {
      return ValidationResult.error(
        'Cannot delete loan with ${payments.length} payment(s). '
        'Please delete all payments first.',
      );
    }

    return ValidationResult.success();
  }

  /// Validate if a loan can be marked as completed
  Future<ValidationResult> canCompleteLoan(String loanId) async {
    final loan = await _loanRepository.getById(loanId);
    if (loan == null) {
      return ValidationResult.error('Loan not found');
    }

    final payments = await _paymentRepository.getByLoanId(loanId);
    final remaining = _calculationService.calculateRemaining(loan, payments);

    if (remaining > 0) {
      return ValidationResult.error(
        'Cannot complete loan with remaining balance. '
        'Remaining amount: ${remaining.toStringAsFixed(2)}',
      );
    }

    return ValidationResult.success();
  }

  /// Validate payment amount
  Future<ValidationResult> validatePaymentAmount(
    String loanId,
    double amount, {
    bool allowOverpayment = true,
  }) async {
    if (amount <= 0) {
      return ValidationResult.error('Payment amount must be greater than zero');
    }

    final loan = await _loanRepository.getById(loanId);
    if (loan == null) {
      return ValidationResult.error('Loan not found');
    }

    final payments = await _paymentRepository.getByLoanId(loanId);
    final remaining = _calculationService.calculateRemaining(loan, payments);

    if (remaining <= 0) {
      return ValidationResult.error('Loan is already fully paid');
    }

    if (!allowOverpayment && amount > remaining) {
      return ValidationResult.error(
        'Payment amount exceeds remaining balance. '
        'Remaining: ${remaining.toStringAsFixed(2)}',
      );
    }

    // Warning for overpayment
    if (amount > remaining) {
      return ValidationResult.warning(
        'Payment amount exceeds remaining balance by ${(amount - remaining).toStringAsFixed(2)}. '
        'This will be treated as overpayment.',
      );
    }

    return ValidationResult.success();
  }

  /// Validate if installment amount is reasonable
  ValidationResult validateInstallmentAmount(double principal, double installment) {
    if (installment <= 0) {
      return ValidationResult.error('Installment amount must be greater than zero');
    }

    if (installment > principal) {
      return ValidationResult.error(
        'Installment amount cannot exceed principal amount',
      );
    }

    // Warning if installment is very small (would take more than 10 years)
    final estimatedMonths = (principal / installment).ceil();
    if (estimatedMonths > 120) {
      return ValidationResult.warning(
        'This installment amount would take approximately ${(estimatedMonths / 12).ceil()} years to complete',
      );
    }

    return ValidationResult.success();
  }

  /// Validate loan modification
  Future<ValidationResult> validateLoanModification(
    Loan originalLoan,
    double newInstallmentAmount,
  ) async {
    final payments = await _paymentRepository.getByLoanId(originalLoan.id);
    
    if (payments.isNotEmpty) {
      return ValidationResult.warning(
        'Modifying installment amount will only affect future payments. '
        '${payments.length} payment(s) already recorded.',
      );
    }

    return validateInstallmentAmount(originalLoan.principalAmount, newInstallmentAmount);
  }

  /// Validate backdated payment
  ValidationResult validateBackdatedPayment(DateTime paymentDate, DateTime loanStartDate) {
    if (paymentDate.isBefore(loanStartDate)) {
      return ValidationResult.error(
        'Payment date cannot be before loan start date',
      );
    }

    final now = DateTime.now();
    final daysDifference = now.difference(paymentDate).inDays;

    if (daysDifference > 365) {
      return ValidationResult.warning(
        'Payment is backdated by more than a year ($daysDifference days)',
      );
    }

    return ValidationResult.success();
  }

  /// Check if loan should be auto-completed
  Future<bool> shouldAutoCompleteLoan(String loanId) async {
    final loan = await _loanRepository.getById(loanId);
    if (loan == null || loan.status != LoanStatus.active) {
      return false;
    }

    final payments = await _paymentRepository.getByLoanId(loanId);
    final remaining = _calculationService.calculateRemaining(loan, payments);

    return remaining <= 0;
  }
}

/// Result of a validation check
class ValidationResult {
  final bool isValid;
  final String? message;
  final ValidationLevel level;

  ValidationResult._({
    required this.isValid,
    this.message,
    required this.level,
  });

  factory ValidationResult.success() {
    return ValidationResult._(
      isValid: true,
      level: ValidationLevel.success,
    );
  }

  factory ValidationResult.error(String message) {
    return ValidationResult._(
      isValid: false,
      message: message,
      level: ValidationLevel.error,
    );
  }

  factory ValidationResult.warning(String message) {
    return ValidationResult._(
      isValid: true,
      message: message,
      level: ValidationLevel.warning,
    );
  }

  bool get isSuccess => level == ValidationLevel.success;
  bool get isError => level == ValidationLevel.error;
  bool get isWarning => level == ValidationLevel.warning;
}

enum ValidationLevel {
  success,
  warning,
  error,
}
