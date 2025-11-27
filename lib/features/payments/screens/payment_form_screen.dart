import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../providers/providers.dart';
import '../../../providers/loan_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../models/loan.dart';

class PaymentFormScreen extends ConsumerStatefulWidget {
  final String loanId;
  final String? paymentId; // null for create, id for edit

  const PaymentFormScreen({super.key, required this.loanId, this.paymentId});

  @override
  ConsumerState<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends ConsumerState<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _paymentDate = DateTime.now();
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.paymentId != null;
    if (_isEditMode) {
      // TODO: load existing payment data if needed
    }
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(paymentRepositoryProvider);
      final amount = double.parse(_amountController.text);

      if (_isEditMode) {
        // Update existing payment
        final existing = await repo.getById(widget.paymentId!);
        if (existing != null) {
          final updated = existing.copyWith(
            amount: amount,
            paymentDate: _paymentDate,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );
          await repo.update(updated);
        }
      } else {
        // Create new payment
        await repo.create(
          loanId: widget.loanId,
          amount: amount,
          paymentDate: _paymentDate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
      }

      // Check for auto-completion
      final loanRepo = ref.read(loanRepositoryProvider);
      final calcService = ref.read(calculationServiceProvider);

      final loan = await loanRepo.getById(widget.loanId);
      if (loan != null) {
        final payments = await repo.getByLoanId(widget.loanId);
        final remaining = calcService.calculateRemaining(loan, payments);

        if (remaining <= 0 && loan.status == LoanStatus.active) {
          await loanRepo.updateStatus(loan.id, LoanStatus.completed);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Loan fully paid! Marked as completed.'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        }
      }

      // Refresh data
      ref.invalidate(paymentsForLoanProvider(widget.loanId));
      ref.invalidate(loanWithCalculationsProvider(widget.loanId));
      ref.invalidate(dashboardSummaryProvider);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Payment updated successfully'
                  : 'Payment added successfully',
            ),
            backgroundColor: AppColors.pureBlack,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.overdue,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Payment' : 'Add Payment',
          style: AppTextStyles.h1,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.lg),
          children: [
            // Amount
            Text('AMOUNT *', style: AppTextStyles.label),
            const SizedBox(height: AppDimensions.sm),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                hintText: 'Enter payment amount',
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
              validator: Validators.validateAmount,
              autofocus: true,
            ),
            const SizedBox(height: AppDimensions.lg),

            // Payment Date
            Text('PAYMENT DATE *', style: AppTextStyles.label),
            const SizedBox(height: AppDimensions.sm),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _paymentDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _paymentDate = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _paymentDate.toFormattedDate(),
                      style: AppTextStyles.body,
                    ),
                    const Icon(Icons.calendar_today_outlined),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // Notes
            Text('NOTES', style: AppTextStyles.label),
            const SizedBox(height: AppDimensions.sm),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Add any additional notes',
              ),
              maxLines: 3,
              validator: Validators.validateNotes,
            ),
            const SizedBox(height: AppDimensions.xl),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _savePayment,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.pureWhite,
                      ),
                    )
                  : Text(_isEditMode ? 'Update Payment' : 'Add Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
