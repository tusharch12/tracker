import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../models/borrower.dart';

class BorrowerCard extends StatelessWidget {
  final Borrower borrower;
  final VoidCallback onTap;

  const BorrowerCard({
    super.key,
    required this.borrower,
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
          child: Row(
            children: [
              // Avatar
              Container(
                width: AppDimensions.avatarMedium,
                height: AppDimensions.avatarMedium,
                decoration: BoxDecoration(
                  color: AppColors.pureBlack,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
                ),
                child: Center(
                  child: Text(
                    _getInitials(borrower.name),
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.pureWhite,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.md),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      borrower.name,
                      style: AppTextStyles.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (borrower.phone != null) ...[
                      const SizedBox(height: AppDimensions.xs),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: AppDimensions.iconSmall,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppDimensions.xs),
                          Text(
                            borrower.phone!,
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (borrower.email != null) ...[
                      const SizedBox(height: AppDimensions.xs),
                      Row(
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            size: AppDimensions.iconSmall,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppDimensions.xs),
                          Expanded(
                            child: Text(
                              borrower.email!,
                              style: AppTextStyles.small.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
