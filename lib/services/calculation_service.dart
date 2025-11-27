import 'dart:math';
import '../models/loan.dart';
import '../models/payment.dart';
import '../core/extensions/date_extensions.dart';

/// Service for calculating loan-related metrics and status
class CalculationService {
  /// Calculate total amount paid for a loan
  double calculateTotalPaid(List<Payment> payments) {
    if (payments.isEmpty) return 0.0;
    return payments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Calculate remaining balance for a loan
  double calculateRemaining(Loan loan, List<Payment> payments) {
    final totalPaid = calculateTotalPaid(payments);
    final totalRepayment = loan.principalAmount + loan.profitAmount;
    final remaining = totalRepayment - totalPaid;
    return max(0.0, remaining); // Never negative
  }

  /// Calculate number of installments remaining
  int calculateInstallmentsRemaining(Loan loan, List<Payment> payments) {
    final remaining = calculateRemaining(loan, payments);
    if (remaining <= 0) return 0;

    return (remaining / loan.installmentAmount).ceil();
  }

  /// Calculate next due date based on loan start date and payment history
  DateTime? calculateNextDueDate(Loan loan, List<Payment> payments) {
    // If loan is not active, no due date
    if (loan.status != LoanStatus.active) return null;

    final remaining = calculateRemaining(loan, payments);
    if (remaining <= 0) return null; // Loan fully paid

    // Next due is based on number of installments paid + 1
    final installmentsPaid = payments.length;
    final nextInstallmentNumber = installmentsPaid + 1;

    // Calculate next due date from start date
    return loan.startDate.addMonthsSafe(nextInstallmentNumber);
  }

  /// Check if a loan is overdue
  bool isOverdue(Loan loan, List<Payment> payments) {
    final nextDue = calculateNextDueDate(loan, payments);
    if (nextDue == null) return false;

    final now = DateTime.now();
    return nextDue.isBefore(now);
  }

  /// Calculate overdue amount
  double calculateOverdueAmount(Loan loan, List<Payment> payments) {
    if (!isOverdue(loan, payments)) return 0.0;

    final monthsSinceStart = _monthsBetween(loan.startDate, DateTime.now());
    final totalPaid = calculateTotalPaid(payments);

    final totalRepayment = loan.principalAmount + loan.profitAmount;

    // Expected amount to be paid by now
    final expectedPaid = min(
      loan.installmentAmount * (monthsSinceStart + 1),
      totalRepayment,
    );

    final overdue = expectedPaid - totalPaid;
    return max(0.0, overdue);
  }

  /// Calculate expected monthly payment amount
  double? calculateExpectedMonthlyPayment(Loan loan, List<Payment> payments) {
    final remaining = calculateRemaining(loan, payments);
    if (remaining <= 0) return 0.0;

    // If total installments specified, use that
    if (loan.totalInstallments != null) {
      final installmentsRemaining = calculateInstallmentsRemaining(
        loan,
        payments,
      );
      if (installmentsRemaining > 0) {
        return remaining / installmentsRemaining;
      }
    }

    if (remaining <= 0) return null;

    final installmentsRemaining = calculateInstallmentsRemaining(
      loan,
      payments,
    );
    if (installmentsRemaining == 0) return null;

    final lastDueDate = calculateNextDueDate(loan, payments);
    if (lastDueDate == null) return null;

    // Return the installment amount as the expected monthly payment
    return loan.installmentAmount;
  }

  /// Check if payment is partial (less than expected installment)
  bool isPartialPayment(Loan loan, Payment payment) {
    return payment.amount < loan.installmentAmount;
  }

  /// Check if payment is overpayment (more than remaining balance)
  bool isOverpayment(
    Loan loan,
    List<Payment> existingPayments,
    double newPaymentAmount,
  ) {
    final remaining = calculateRemaining(loan, existingPayments);
    return newPaymentAmount > remaining;
  }

  /// Calculate how much of an overpayment goes to reducing principal
  double calculateOverpaymentCredit(
    Loan loan,
    List<Payment> existingPayments,
    double newPaymentAmount,
  ) {
    final remaining = calculateRemaining(loan, existingPayments);
    if (newPaymentAmount <= remaining) return 0.0;

    return newPaymentAmount - remaining;
  }

  /// Get loans due this month
  List<Loan> getLoansDueThisMonth(
    List<Loan> loans,
    Map<String, List<Payment>> paymentsMap,
  ) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return loans.where((loan) {
      if (loan.status != LoanStatus.active) return false;

      final payments = paymentsMap[loan.id] ?? [];
      final nextDue = calculateNextDueDate(loan, payments);

      if (nextDue == null) return false;

      return nextDue.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          nextDue.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get overdue loans
  List<Loan> getOverdueLoans(
    List<Loan> loans,
    Map<String, List<Payment>> paymentsMap,
  ) {
    return loans.where((loan) {
      if (loan.status != LoanStatus.active) return false;

      final payments = paymentsMap[loan.id] ?? [];
      return isOverdue(loan, payments);
    }).toList();
  }

  /// Calculate total amount lent across all loans
  double calculateTotalLent(List<Loan> loans) {
    return loans.fold(0.0, (sum, loan) => sum + loan.principalAmount);
  }

  /// Calculate total amount received across all payments
  double calculateTotalReceived(List<Payment> payments) {
    return payments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Calculate total remaining across all active loans
  double calculateTotalRemaining(
    List<Loan> loans,
    Map<String, List<Payment>> paymentsMap,
  ) {
    return loans.where((loan) => loan.status == LoanStatus.active).fold(0.0, (
      sum,
      loan,
    ) {
      final payments = paymentsMap[loan.id] ?? [];
      return sum + calculateRemaining(loan, payments);
    });
  }

  /// Calculate total due this month across all loans
  double calculateTotalDueThisMonth(
    List<Loan> loans,
    Map<String, List<Payment>> paymentsMap,
  ) {
    final loansDue = getLoansDueThisMonth(loans, paymentsMap);
    return loansDue.fold(0.0, (sum, loan) {
      final payments = paymentsMap[loan.id] ?? [];
      return sum + (calculateExpectedMonthlyPayment(loan, payments) ?? 0.0);
    });
  }

  // Helper: Calculate months between two dates
  int _monthsBetween(DateTime start, DateTime end) {
    return ((end.year - start.year) * 12) + (end.month - start.month);
  }

  /// Calculate progress percentage (0-100)
  double calculateProgress(Loan loan, List<Payment> payments) {
    final totalRepayment = loan.principalAmount + loan.profitAmount;
    if (totalRepayment <= 0) return 0.0;

    final totalPaid = calculateTotalPaid(payments);
    final progress = (totalPaid / totalRepayment) * 100;

    return min(100.0, max(0.0, progress));
  }

  /// Calculate expected end date based on remaining installments
  DateTime? calculateExpectedEndDate(Loan loan, List<Payment> payments) {
    if (loan.status != LoanStatus.active) return null;

    final remaining = calculateRemaining(loan, payments);
    if (remaining <= 0) return null; // Already finished

    final nextDue = calculateNextDueDate(loan, payments);
    if (nextDue == null) return null;

    final installmentsRemaining = calculateInstallmentsRemaining(
      loan,
      payments,
    );
    if (installmentsRemaining <= 1) return nextDue;

    // Add remaining months to next due date
    // We subtract 1 because nextDue counts as the first remaining installment
    return nextDue.addMonthsSafe(installmentsRemaining - 1);
  }
}
