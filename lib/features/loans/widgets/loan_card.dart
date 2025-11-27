import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../models/loan.dart';

class LoanCard extends StatelessWidget {
  final Loan loan;
  final VoidCallback onTap;

  const LoanCard({
    super.key,
    required this.loan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          CurrencyFormatter.format(loan.principalAmount),
                          style: AppTextStyles.h2,
                        ),
                        const SizedBox(height: AppDimensions.xs),
                        Text(
                          'Started ${loan.startDate.toFormattedDate()}',
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),
              const SizedBox(height: AppDimensions.md),

              // Details
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Installment',
                      CurrencyFormatter.format(loan.installmentAmount),
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Frequency',
                      _getFrequencyText(),
                    ),
                  ),
                ],
              ),

              if (loan.notes != null) ...[
                const SizedBox(height: AppDimensions.sm),
                Text(
                  loan.notes!,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;

    switch (loan.status) {
      case LoanStatus.active:
        color = AppColors.pureBlack;
        text = 'ACTIVE';
        break;
      case LoanStatus.completed:
        color = AppColors.mediumGray;
        text = 'COMPLETED';
        break;
      case LoanStatus.cancelled:
        color = AppColors.overdue;
        text = 'CANCELLED';
        break;
      case LoanStatus.defaulted:
        throw UnimplementedError();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Text(
        text,
        style: AppTextStyles.small.copyWith(
          color: AppColors.pureWhite,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.small.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        Text(
          value,
          style: AppTextStyles.body,
        ),
      ],
    );
  }

  String _getFrequencyText() {
    switch (loan.installmentFrequency) {
      case 1:
        return 'Monthly';
      case 3:
        return 'Quarterly';
      case 6:
        return 'Half-yearly';
      case 12:
        return 'Yearly';
      default:
        return '${loan.installmentFrequency} months';
    }
  }
}
