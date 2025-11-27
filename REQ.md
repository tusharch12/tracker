# 1. Project Summary

A system to track money lent to multiple people. Each person may have one or more loans and repays monthly. The system must track payments, remaining balance, overdue amounts, and history.

---

# 2. Goals

## Primary

- Track money given to each person.
- Track monthly payments.
- Maintain balance (paid vs remaining).
- Identify overdue or upcoming payments.
- Provide clear summary/dashboard.

## Future (Phase 2)

- Notifications/reminders.
- Data export.
- Multi-user system.
- Interest support.

---

# 3. User Types

- **Lender (App User)** → manages all data.
- **Borrower** → only tracked, no login required.

---

# 4. Modules & Features

## 4.1 Borrower / Person Management

- Add borrower (name required, optional phone/email/notes).
- Edit borrower details.
- List borrowers with total borrowed, paid, and remaining.
- Search borrower by name.
- Cannot delete borrower with active loan → allow soft delete.

## 4.2 Loan Management

- Each borrower can have multiple loans.

**Loan fields:**

- Principal amount  
- Start date  
- Monthly installment amount  
- Total installments (or auto-calculated)  
- Expected end date (optional)  
- Status: Active / Completed / Cancelled / Defaulted  
- Notes (optional)

**Loan actions:**

- Create loan  
- Edit loan (installment changes only affect future)  
- Mark loan as completed  
- Cancel loan  
- View complete loan history  

## 4.3 Payment Management

**Payment fields:**

- Amount  
- Date  
- Payment method (optional)  
- Notes (optional)  

**Payment actions:**

- Add payment  
- Edit payment  
- Delete payment  
- View full payment history  

**Payment logic:**

- Partial payment allowed.  
- Overpayment allowed → reduce future dues or principal.  
- Backdated payments allowed → must recalculate overdue status.

---

# 5. Calculations & Logic

System must calculate:

- **Total Paid** = sum(payments)  
- **Remaining** = principal - total paid  
- **Installments remaining** = `ceil(remaining / installmentAmount)`  
- **Next due date** = repeating monthly cycle from start date  
- **Overdue** = if expected monthly installment not paid by due date  

**Edge date logic:**

- If due date is 31st and month has fewer days → move to last day of month.

---

# 6. Dashboard Requirements

Dashboard must show:

| Metric                        | Description                         |
|------------------------------|-------------------------------------|
| Total Lent                   | All loan principals                 |
| Total Received               | All payments                        |
| Total Remaining              | Outstanding across all loans        |
| Due This Month               | Loans with due payment              |
| Overdue Loans                | List of loans past due              |
| Active vs Completed loans    | Count / overview                    |

**Borrower-level view:**

- Borrowed total  
- Paid total  
- Remaining  
- Due next date  
- Overdue status  

---

# 7. Edge Cases

| Case                      | Expected Behavior                                 |
|---------------------------|---------------------------------------------------|
| Partial Payments          | Remaining monthly due should update               |
| Overpayment               | Apply to future or reduce principal               |
| Edited payment amount     | Recalculate overdue + remaining                   |
| Deleted payment           | Recalculate loan balance                          |
| Mid-loan installment update | Only future schedule changes                   |
| Future payment date       | Allowed but flagged                               |
| Duplicate borrower names  | Allowed, identified by ID internally             |

---

# 8. Non-Functional Requirements

- Should support **500+ borrowers** and **10,000+ records**.
- Must open fast and respond quickly.
- Local PIN lock recommended.
- Data should not be lost on app reinstall (cloud/backup phase 2).
- UI should require minimum taps for daily use.

---

# 9. MVP Deliverables Checklist

- [x] Borrower CRUD  
- [x] Loan CRUD  
- [x] Payment CRUD  
- [x] Dashboard  
- [x] Automatic overdue calculation  
- [x] Payment history  
- [x] Search + Filters  
- [x] Soft delete support  

---

# 10. Future Enhancements (Phase 2+)

- Interest calculation model.  
- Cloud sync and multi-device access.  
- Export PDF/CSV reports.  
- Borrower login portal.  
- Calendar view of payments.  
- WhatsApp auto reminders.
