# Money Tracker - Personal Lending Manager

Money Tracker is a comprehensive Flutter application designed to simplify the management of personal loans and informal lending. It replaces traditional paper notebooks with a secure, cloud-synced digital ledger.

## 🚀 The Problem
Managing personal loans, friendly lending, or small-scale financing can be chaotic.
- **Lost Data**: Paper notebooks get lost or damaged.
- **Complex Math**: Calculating remaining balances, interest, and "extra EMI" profit manually is error-prone.
- **Forgetfulness**: It's easy to lose track of due dates and who owes what.
- **Lack of Insight**: Hard to see the "big picture"—how much total money is out there? How much profit has been made?

## 💡 The Solution
Money Tracker provides a clean, modern interface to track every penny. It handles the math, organizes the data, and keeps everything synced to the cloud, so you never lose your records.

## ✨ Key Features

### 👥 Borrower Management
- **Centralized Database**: Store all borrower details (Name, Phone, Email, Notes) in one place.
- **Search & Filter**: Quickly find borrowers by name or contact info.
- **Borrower History**: View a complete history of all loans and payments for each person.

### 💰 Loan Tracking
- **Flexible Loan Creation**: Set Principal Amount, Installment Frequency, and Start Dates.
- **Profit & Interest**: Support for "Extra Installments" or fixed Profit Amounts (Extra EMI) to track earnings.
- **Status Tracking**: Automatically tracks if a loan is Active, Completed, or Overdue.

### 💸 Payment Management
- **Easy Recording**: Log payments quickly with date and method.
- **Smart Calculations**: The app automatically updates:
  - Remaining Balance
  - Progress Percentage
  - Installments Remaining
  - Next Due Date
- **Payment History**: View a transparent log of every transaction for every loan.

### 📊 Dashboard & Insights
- **Financial Overview**: See Total Principal Lent, Total Active Principal, and Total Profit at a glance.
- **Active Loan Count**: Know exactly how many loans are currently open.
- **Visual Progress**: Progress bars and color-coded statuses (e.g., Overdue in red) for better visibility.

### ☁️ Cloud & Offline
- **Firebase Integration**: All data is securely stored in Google Firestore.
- **Authentication**: Secure login via Email/Password or Google Sign-In.
- **Offline Support**: Works offline and syncs automatically when the internet returns.

## 🛠️ Tech Stack
- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **Backend**: Firebase (Firestore, Auth)
- **Architecture**: Repository Pattern with Service Layer

## 📱 Getting Started
1.  Install dependencies: `flutter pub get`
2.  Configure Firebase: Ensure `firebase_options.dart` is set up for your project.
3.  Run the app: `flutter run`
