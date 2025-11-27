import 'package:flutter/material.dart';
import 'package:tracker/core/extensions/date_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/currency_formatter.dart';

import '../../../models/payment.dart';

class PaymentItem extends StatelessWidget {
  final Payment payment;
  final VoidCallback onTap;

  const PaymentItem({
    super.key,
    required this.payment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Row(
            children: [
              // Date Circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
                ),
                child: Center(
                  child: Text(
                    payment.paymentDate.day.toString(),
                    style: AppTextStyles.h3,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.md),

              // Payment Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CurrencyFormatter.format(payment.amount),
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      payment.paymentDate.toFormattedDate(),
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (payment.notes != null) ...[
                      const SizedBox(height: AppDimensions.xs),
                      Text(
                        payment.notes!,
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
