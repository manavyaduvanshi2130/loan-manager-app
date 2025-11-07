# TODO: Fix EMI Calculation in Create Loan Screen

## Task: EMI is not calculated correctly in the preview section of create_loan_screen.dart

### Steps to Complete:
- [x] Import LoanCalculator in create_loan_screen.dart
- [x] Replace the incorrect manual EMI calculation in the EMI Preview Builder with LoanCalculator.calculateEMI(principal, rate, tenure)
- [x] Test the fix by running the app and verifying the EMI preview matches the correct calculation

### Notes:
- The current manual calculation uses annual rate directly and misses the power function for compound interest.
- LoanCalculator.calculateEMI already implements the correct formula.
