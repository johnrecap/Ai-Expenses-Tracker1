// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AI Expenses Tracker';

  @override
  String get splashLoading => 'Loading...';

  @override
  String get onboardingLanguageTitle => 'Select Language';

  @override
  String get onboardingLanguageEnglish => 'English';

  @override
  String get onboardingLanguageArabic => 'العربية';

  @override
  String get onboardingCurrencyTitle => 'Choose Base Currency';

  @override
  String get onboardingNotificationsTitle => 'Stay Informed';

  @override
  String get onboardingNotificationsSubtitle =>
      'Allow notifications for budget alerts, reminders, and insights';

  @override
  String get onboardingEnableNotifications => 'Enable Notifications';

  @override
  String get continueButton => 'Continue';

  @override
  String get skipButton => 'Skip';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginButton => 'Sign In';

  @override
  String get loginGoogleButton => 'Continue with Google';

  @override
  String get loginNoAccount => 'Don\'t have an account? Sign Up';

  @override
  String get signUpTitle => 'Create Account';

  @override
  String get signUpName => 'Name';

  @override
  String get signUpEmail => 'Email';

  @override
  String get signUpPassword => 'Password';

  @override
  String get signUpConfirmPassword => 'Confirm Password';

  @override
  String get signUpButton => 'Sign Up';

  @override
  String get signUpHaveAccount => 'Already have an account? Sign In';

  @override
  String get authErrorInvalidEmail => 'Enter a valid email address';

  @override
  String get authErrorWrongPassword => 'Email or password is incorrect';

  @override
  String get authErrorWeakPassword => 'Password is too weak';

  @override
  String get authErrorEmailInUse => 'An account already exists for this email';

  @override
  String get authErrorNetwork => 'Check your internet connection';

  @override
  String get authErrorGeneral => 'Authentication failed. Please try again.';

  @override
  String get homeTitle => 'Dashboard';

  @override
  String get homeGreeting => 'Good morning';

  @override
  String get homeTotalSpent => 'Total Spent';

  @override
  String get homeMonthlyBudget => 'Monthly Budget';

  @override
  String get navHome => 'Home';

  @override
  String get navReports => 'Reports';

  @override
  String get navBudgets => 'Budgets';

  @override
  String get navWallets => 'Wallets';

  @override
  String get navSettings => 'Settings';

  @override
  String get expensesTitle => 'Expenses';

  @override
  String get expensesSearch => 'Search expenses...';

  @override
  String get expensesFilter => 'Filters';

  @override
  String get expensesClearFilters => 'Clear';

  @override
  String get expensesApplyFilters => 'Apply';

  @override
  String get expensesNoResults => 'No expenses found';

  @override
  String get addExpenseQuick => 'Add Expense';

  @override
  String get addExpenseAiText => 'AI Text';

  @override
  String get addExpenseReceipt => 'Receipt';

  @override
  String get addExpenseAmount => 'Amount';

  @override
  String get addExpenseCategory => 'Category';

  @override
  String get addExpenseDate => 'Date';

  @override
  String get addExpenseNotes => 'Notes';

  @override
  String get addExpensePaymentMethod => 'Payment Method';

  @override
  String get addExpenseSave => 'Save Expense';

  @override
  String get editExpenseTitle => 'Edit Expense';

  @override
  String get editExpenseSave => 'Save Changes';

  @override
  String get deleteExpenseConfirm => 'Are you sure you want to delete this expense?';

  @override
  String get deleteExpenseTitle => 'Delete Expense';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportsThisMonth => 'This Month';

  @override
  String get reportsByCategory => 'By Category';

  @override
  String get reportsTrends => 'Spending Trends';

  @override
  String get reportsDrilldown => 'Category Details';

  @override
  String get reportsMonthlyStory => 'Monthly Story';

  @override
  String get budgetsTitle => 'Budgets';

  @override
  String get budgetsMonthlyBudget => 'Monthly Budget';

  @override
  String get budgetsCategoryBudgets => 'Category Budgets';

  @override
  String get budgetsEdit => 'Edit Budget';

  @override
  String get budgetsSetAmount => 'Set Budget Amount';

  @override
  String get budgetsRemaining => 'Remaining';

  @override
  String get budgetsOverBudget => 'Over Budget';

  @override
  String get goalsTitle => 'Saving Goals';

  @override
  String get goalsAdd => 'Add Goal';

  @override
  String get goalsTarget => 'Target';

  @override
  String get goalsCurrent => 'Current';

  @override
  String get goalsProgress => 'Progress';

  @override
  String get walletsTitle => 'Wallets & Accounts';

  @override
  String get walletsBalance => 'Balance';

  @override
  String get walletsAdd => 'Add Wallet';

  @override
  String get subscriptionsTitle => 'Subscriptions';

  @override
  String get subscriptionsAdd => 'Add Subscription';

  @override
  String get subscriptionsNextRenewal => 'Next Renewal';

  @override
  String get subscriptionsMonthlyImpact => 'Monthly Impact';

  @override
  String get aiAdviceTitle => 'AI Advice';

  @override
  String get aiAdviceRequest => 'Get Spending Advice';

  @override
  String get aiAdviceLoading => 'Analyzing your spending...';

  @override
  String get aiHistoryTitle => 'AI History';

  @override
  String get aiAssistantTitle => 'AI Assistant';

  @override
  String get aiAssistantPlaceholder => 'Ask about your expenses...';

  @override
  String get aiAssistantSend => 'Send';

  @override
  String get aiQuotaRemaining => 'AI requests remaining today';

  @override
  String get aiQuotaExceeded => 'AI quota exceeded. Try again tomorrow or upgrade to Premium.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsAiQuota => 'AI Usage';

  @override
  String get settingsMonetization => 'Premium';

  @override
  String get settingsSupport => 'Support';

  @override
  String get settingsExport => 'Export Data';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsLogout => 'Sign Out';

  @override
  String get profileEditName => 'Edit Name';

  @override
  String get profileDeleteAccount => 'Delete Account';

  @override
  String get premiumTitle => 'Upgrade to Premium';

  @override
  String get premiumFeature1 => 'Higher AI quotas';

  @override
  String get premiumFeature2 => 'Remove ads';

  @override
  String get premiumFeature3 => 'Advanced reports';

  @override
  String get premiumPurchase => 'Upgrade Now';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get exportExcel => 'Export Excel';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get notFound => 'Page not found';

  @override
  String get back => 'Back';

  @override
  String get confirm => 'Confirm';

  @override
  String get done => 'Done';

  @override
  String get save => 'Save';

  @override
  String get loading => 'Loading...';
}
