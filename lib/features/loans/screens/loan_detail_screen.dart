import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../models/loan.dart';
import '../../../models/payment.dart';
import '../../../providers/loan_provider.dart';
import '../../payments/widgets/payment_item.dart';

class LoanDetailScreen extends ConsumerWidget {
  final String loanId;

  const LoanDetailScreen({super.key, required this.loanId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loanDataAsync = ref.watch(loanWithCalculationsProvider(loanId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Loan Details', style: AppTextStyles.h1),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final loanData = loanDataAsync.value;
              if (loanData != null && loanData['loan'] != null) {
                final loan = loanData['loan'] as Loan;
                final result = await Navigator.pushNamed(
                  context,
                  '/loans/form',
                  arguments: {'borrowerId': loan.borrowerId, 'loanId': loan.id},
                );
                if (result == true) {
                  ref.invalidate(loanWithCalculationsProvider(loanId));
                }
              }
            },
          ),
        ],
      ),
      body: loanDataAsync.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(child: Text('Loan not found'));
          }

          final loan = data['loan'] as Loan;
          final payments = data['payments'] as List<Payment>;
          final totalPaid = data['totalPaid'] as double;
          final remaining = data['remaining'] as double;
          final installmentsRemaining = data['installmentsRemaining'] as int;
          final nextDueDate = data['nextDueDate'] as DateTime?;
          final isOverdue = data['isOverdue'] as bool;
          final overdueAmount = data['overdueAmount'] as double;
          final progress = data['progress'] as double;

          return ListView(
            padding: const EdgeInsets.all(AppDimensions.lg),
            children: [
              // Status and Amount
              _buildStatusCard(loan, progress),
              const SizedBox(height: AppDimensions.lg),

              // Financial Summary
              _buildFinancialSummary(
                loan,
                totalPaid,
                remaining,
                installmentsRemaining,
              ),
              const SizedBox(height: AppDimensions.lg),

              // Next Due Date
              if (nextDueDate != null && loan.status == LoanStatus.active) ...[
                _buildDueDateCard(nextDueDate, isOverdue, overdueAmount),
                const SizedBox(height: AppDimensions.lg),
              ],

              // Payment History
              if (payments.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppDimensions.xl),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusLarge,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'No payments yet',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                ...payments.map(
                  (payment) => PaymentItem(
                    payment: payment,
                    onTap: () {
                      // Show payment details
                    },
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: loanDataAsync.whenOrNull(
        data: (data) {
          if (data.isEmpty) return null;
          final loan = data['loan'] as Loan;
          final progress = data['progress'] as double;

          if (loan.status == LoanStatus.active && progress < 100) {
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/payments/form',
                  arguments: loanId,
                );
              },
              backgroundColor: AppColors.pureBlack,
              foregroundColor: AppColors.pureWhite,
              icon: const Icon(Icons.add),
              label: const Text('Add Payment'),
            );
          }
          return null;
        },
      ),
    );
  }

  Widget _buildStatusCard(Loan loan, double progress) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.pureBlack,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Column(
        children: [
          Text(
            CurrencyFormatter.format(
              loan.principalAmount + (loan.profitAmount ),
            ),
            style: AppTextStyles.display.copyWith(color: AppColors.pureWhite),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            _getStatusText(loan.status),
            style: AppTextStyles.body.copyWith(color: AppColors.pureWhite),
          ),
          const SizedBox(height: AppDimensions.md),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: AppColors.mediumGray,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.pureWhite,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            '${progress.toStringAsFixed(1)}% paid',
            style: AppTextStyles.small.copyWith(color: AppColors.pureWhite),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary(
    Loan loan,
    double totalPaid,
    double remaining,
    int installmentsRemaining,
  ) {
    final totalRepayment = loan.principalAmount + (loan.profitAmount ?? 0.0);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Financial Summary', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.md),
          _buildSummaryRow(
            'Principal',
            CurrencyFormatter.format(loan.principalAmount),
          ),
          if (loan.profitAmount > 0)
            _buildSummaryRow(
              'Profit (Extra EMI)',
              CurrencyFormatter.format(loan.profitAmount),
              color: AppColors.primary,
              isBold: true,
            ),
          _buildSummaryRow(
            'Total Repayment',
            CurrencyFormatter.format(totalRepayment),
          ),
          const Divider(),
          _buildSummaryRow('Total Paid', CurrencyFormatter.format(totalPaid)),
          _buildSummaryRow('Remaining', CurrencyFormatter.format(remaining)),
          const Divider(),
          _buildSummaryRow(
            'Installment Amount',
            CurrencyFormatter.format(loan.installmentAmount),
          ),
          if (loan.totalInstallments != null)
            _buildSummaryRow('Total Installments', '${loan.totalInstallments}'),
          if (loan.extraInstallments > 0)
            _buildSummaryRow('Extra Installments', '${loan.extraInstallments}'),
          _buildSummaryRow('Installments Remaining', '$installmentsRemaining'),
          _buildSummaryRow('Start Date', loan.startDate.toFormattedDate()),
        ],
      ),
    );
  }

  Widget _buildDueDateCard(
    DateTime dueDate,
    bool isOverdue,
    double overdueAmount,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: isOverdue ? AppColors.overdue : AppColors.pureWhite,
        border: Border.all(
          color: isOverdue ? AppColors.overdue : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Row(
        children: [
          Icon(
            isOverdue ? Icons.warning : Icons.calendar_today_outlined,
            color: isOverdue ? AppColors.pureWhite : AppColors.pureBlack,
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOverdue ? 'OVERDUE' : 'Next Due Date',
                  style: AppTextStyles.label.copyWith(
                    color: isOverdue
                        ? AppColors.pureWhite
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  dueDate.toFormattedDate(),
                  style: AppTextStyles.h3.copyWith(
                    color: isOverdue
                        ? AppColors.pureWhite
                        : AppColors.pureBlack,
                  ),
                ),
                if (isOverdue && overdueAmount > 0) ...[
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    'Amount: ${CurrencyFormatter.format(overdueAmount)}',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.pureWhite,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: color ?? AppColors.pureBlack,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(LoanStatus status) {
    switch (status) {
      case LoanStatus.active:
        return 'ACTIVE LOAN';
      case LoanStatus.completed:
        return 'COMPLETED';
      case LoanStatus.cancelled:
        return 'CANCELLED';
      case LoanStatus.defaulted:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
