import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../models/loan.dart';
import '../../../providers/providers.dart';
import '../../../providers/loan_provider.dart';
import '../../../providers/dashboard_provider.dart';

class LoanFormScreen extends ConsumerStatefulWidget {
  final String borrowerId;
  final String? loanId; // null for create, id for edit

  const LoanFormScreen({super.key, required this.borrowerId, this.loanId});

  @override
  ConsumerState<LoanFormScreen> createState() => _LoanFormScreenState();
}

class _LoanFormScreenState extends ConsumerState<LoanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _principalController = TextEditingController();
  final _installmentController = TextEditingController();
  final _extraInstallmentsController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  DateTime _startDate = DateTime.now();
  int _installmentFrequency = 1; // Monthly by default
  bool _isLoading = false;
  bool _isEditMode = false;

  // Calculated values
  int _normalInstallments = 0;
  int _totalInstallments = 0;
  double _totalRepayment = 0;
  double _profitAmount = 0;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.loanId != null;
    if (_isEditMode) {
      _loadLoan();
    }

    _principalController.addListener(_updateCalculations);
    _installmentController.addListener(_updateCalculations);
    _extraInstallmentsController.addListener(_updateCalculations);
  }

  void _updateCalculations() {
    final principal = double.tryParse(_principalController.text) ?? 0;
    final installment = double.tryParse(_installmentController.text) ?? 0;
    final extra = int.tryParse(_extraInstallmentsController.text) ?? 0;

    if (principal > 0 && installment > 0) {
      setState(() {
        _normalInstallments = (principal / installment).ceil();
        _totalInstallments = _normalInstallments + extra;
        _totalRepayment = _totalInstallments * installment;
        _profitAmount = _totalRepayment - principal;
      });
    } else {
      setState(() {
        _normalInstallments = 0;
        _totalInstallments = 0;
        _totalRepayment = 0;
        _profitAmount = 0;
      });
    }
  }

  Future<void> _loadLoan() async {
    final repo = ref.read(loanRepositoryProvider);
    final loan = await repo.getById(widget.loanId!);

    if (loan != null && mounted) {
      _principalController.text = loan.principalAmount.toStringAsFixed(0);
      _installmentController.text = loan.installmentAmount.toStringAsFixed(0);
      _extraInstallmentsController.text = loan.extraInstallments.toString();
      _notesController.text = loan.notes ?? '';
      setState(() {
        _startDate = loan.startDate;
        _installmentFrequency = loan.installmentFrequency;
      });
      _updateCalculations();
    }
  }

  @override
  void dispose() {
    _principalController.dispose();
    _installmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveLoan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(loanRepositoryProvider);
      final principal = double.parse(_principalController.text);
      final installment = double.parse(_installmentController.text);
      final extraInstallments = int.parse(_extraInstallmentsController.text);

      // Calculate profit
      final normalInstallments = (principal / installment).ceil();
      final totalInstallments = normalInstallments + extraInstallments;
      final totalRepayment = totalInstallments * installment;
      final profitAmount = totalRepayment - principal;

      print("principal: $principal");
      print("installment: $installment");
      print("extraInstallments: $extraInstallments");
      print("normalInstallments: $normalInstallments");
      print("totalInstallments: $totalInstallments");
      print("totalRepayment: $totalRepayment");
      print("profitAmount: $profitAmount");

      if (_isEditMode) {
        // Update existing loan
        final existing = await repo.getById(widget.loanId!);
        if (existing != null) {
          final updated = existing.copyWith(
            principalAmount: principal,
            installmentAmount: installment,
            installmentFrequency: _installmentFrequency,
            startDate: _startDate,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            extraInstallments: extraInstallments,
            profitAmount: profitAmount,
            totalInstallments: totalInstallments,
          );
          await repo.update(updated);
        }
      } else {
 
        await repo.create(
          borrowerId: widget.borrowerId,
          principalAmount: principal,
          installmentAmount: installment,
          installmentFrequency: _installmentFrequency,
          startDate: _startDate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          extraInstallments: extraInstallments,
          profitAmount: profitAmount,
          totalInstallments: totalInstallments,
        );
      }

      // Refresh loan list
      ref.invalidate(loansByBorrowerProvider(widget.borrowerId));
      ref.invalidate(allLoansProvider);
      ref.invalidate(dashboardSummaryProvider);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Loan updated successfully'
                  : 'Loan added successfully',
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
          _isEditMode ? 'Edit Loan' : 'Add Loan',
          style: AppTextStyles.h1,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.lg),
          children: [
            // Principal Amount
            Text('PRINCIPAL AMOUNT *', style: AppTextStyles.label),
            const SizedBox(height: AppDimensions.sm),
            TextFormField(
              controller: _principalController,
              decoration: const InputDecoration(
                hintText: 'Enter principal amount',
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
              validator: Validators.validateAmount,
            ),
            const SizedBox(height: AppDimensions.lg),

            // Installment Amount
            Text('INSTALLMENT AMOUNT *', style: AppTextStyles.label),
            const SizedBox(height: AppDimensions.sm),
            TextFormField(
              controller: _installmentController,
              decoration: const InputDecoration(
                hintText: 'Enter installment amount',
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
              validator: Validators.validateAmount,
            ),
            const SizedBox(height: AppDimensions.lg),

            // Installment Frequency
            Text('INSTALLMENT FREQUENCY *', style: AppTextStyles.label),
            const SizedBox(height: AppDimensions.sm),
            DropdownButtonFormField<int>(
              value: _installmentFrequency,
              decoration: const InputDecoration(hintText: 'Select frequency'),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Monthly')),
                DropdownMenuItem(value: 3, child: Text('Quarterly')),
                DropdownMenuItem(value: 6, child: Text('Half-yearly')),
                DropdownMenuItem(value: 12, child: Text('Yearly')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _installmentFrequency = value);
                }
              },
            ),
            const SizedBox(height: AppDimensions.lg),

            // Extra Installments (Profit)
            Text('EXTRA INSTALLMENTS (PROFIT)', style: AppTextStyles.label),
            const SizedBox(height: AppDimensions.sm),
            TextFormField(
              controller: _extraInstallmentsController,
              decoration: const InputDecoration(
                hintText: 'Enter extra installments (e.g. 2)',
                helperText:
                    'These are added on top of normal installments as profit',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                final n = int.tryParse(value);
                if (n == null || n < 0) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.lg),

            // Calculation Summary Card
            if (_principalController.text.isNotEmpty &&
                _installmentController.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Loan Summary', style: AppTextStyles.h3),
                    const SizedBox(height: AppDimensions.md),
                    _buildSummaryRow(
                      'Normal Installments',
                      '$_normalInstallments',
                    ),
                    _buildSummaryRow(
                      'Extra Installments',
                      '+ ${_extraInstallmentsController.text}',
                    ),
                    const Divider(),
                    _buildSummaryRow(
                      'Total Installments',
                      '$_totalInstallments',
                      isBold: true,
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    _buildSummaryRow(
                      'Total Repayment',
                      CurrencyFormatter.format(_totalRepayment),
                    ),
                    _buildSummaryRow(
                      'Projected Profit',
                      CurrencyFormatter.format(_profitAmount),
                      color: AppColors.primary,
                      isBold: true,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppDimensions.lg),

            // Start Date
            Text('START DATE *', style: AppTextStyles.label),
            const SizedBox(height: AppDimensions.sm),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _startDate = date);
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
                      _startDate.toFormattedDate(),
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
              onPressed: _isLoading ? null : _saveLoan,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.pureWhite,
                      ),
                    )
                  : Text(_isEditMode ? 'Update Loan' : 'Add Loan'),
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 2),
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
}
