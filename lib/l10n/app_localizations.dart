import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ar'), Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Expenses Tracker'**
  String get appTitle;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get splashLoading;

  /// No description provided for @onboardingLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get onboardingLanguageTitle;

  /// No description provided for @onboardingLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get onboardingLanguageEnglish;

  /// No description provided for @onboardingLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get onboardingLanguageArabic;

  /// No description provided for @onboardingCurrencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Base Currency'**
  String get onboardingCurrencyTitle;

  /// No description provided for @onboardingNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay Informed'**
  String get onboardingNotificationsTitle;

  /// No description provided for @onboardingNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications for budget alerts, reminders, and insights'**
  String get onboardingNotificationsSubtitle;

  /// No description provided for @onboardingEnableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get onboardingEnableNotifications;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @skipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipButton;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// No description provided for @loginGoogleButton.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginGoogleButton;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get loginNoAccount;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signUpTitle;

  /// No description provided for @signUpName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get signUpName;

  /// No description provided for @signUpEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signUpEmail;

  /// No description provided for @signUpPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signUpPassword;

  /// No description provided for @signUpConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get signUpConfirmPassword;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButton;

  /// No description provided for @signUpHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get signUpHaveAccount;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect'**
  String get authErrorWrongPassword;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account already exists for this email'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection'**
  String get authErrorNetwork;

  /// No description provided for @authErrorGeneral.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get authErrorGeneral;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get homeTitle;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGreeting;

  /// No description provided for @homeTotalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get homeTotalSpent;

  /// No description provided for @homeMonthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget'**
  String get homeMonthlyBudget;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navBudgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get navBudgets;

  /// No description provided for @navWallets.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get navWallets;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @expensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesTitle;

  /// No description provided for @expensesSearch.
  ///
  /// In en, this message translates to:
  /// **'Search expenses...'**
  String get expensesSearch;

  /// No description provided for @expensesFilter.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get expensesFilter;

  /// No description provided for @expensesClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get expensesClearFilters;

  /// No description provided for @expensesApplyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get expensesApplyFilters;

  /// No description provided for @expensesNoResults.
  ///
  /// In en, this message translates to:
  /// **'No expenses found'**
  String get expensesNoResults;

  /// No description provided for @addExpenseQuick.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpenseQuick;

  /// No description provided for @addExpenseAiText.
  ///
  /// In en, this message translates to:
  /// **'AI Text'**
  String get addExpenseAiText;

  /// No description provided for @addExpenseReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get addExpenseReceipt;

  /// No description provided for @addExpenseAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get addExpenseAmount;

  /// No description provided for @addExpenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get addExpenseCategory;

  /// No description provided for @addExpenseDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get addExpenseDate;

  /// No description provided for @addExpenseNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get addExpenseNotes;

  /// No description provided for @addExpensePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get addExpensePaymentMethod;

  /// No description provided for @addExpenseSave.
  ///
  /// In en, this message translates to:
  /// **'Save Expense'**
  String get addExpenseSave;

  /// No description provided for @editExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpenseTitle;

  /// No description provided for @editExpenseSave.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get editExpenseSave;

  /// No description provided for @deleteExpenseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this expense?'**
  String get deleteExpenseConfirm;

  /// No description provided for @deleteExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get deleteExpenseTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @reportsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get reportsThisMonth;

  /// No description provided for @reportsByCategory.
  ///
  /// In en, this message translates to:
  /// **'By Category'**
  String get reportsByCategory;

  /// No description provided for @reportsTrends.
  ///
  /// In en, this message translates to:
  /// **'Spending Trends'**
  String get reportsTrends;

  /// No description provided for @reportsDrilldown.
  ///
  /// In en, this message translates to:
  /// **'Category Details'**
  String get reportsDrilldown;

  /// No description provided for @reportsMonthlyStory.
  ///
  /// In en, this message translates to:
  /// **'Monthly Story'**
  String get reportsMonthlyStory;

  /// No description provided for @budgetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgetsTitle;

  /// No description provided for @budgetsMonthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget'**
  String get budgetsMonthlyBudget;

  /// No description provided for @budgetsCategoryBudgets.
  ///
  /// In en, this message translates to:
  /// **'Category Budgets'**
  String get budgetsCategoryBudgets;

  /// No description provided for @budgetsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get budgetsEdit;

  /// No description provided for @budgetsSetAmount.
  ///
  /// In en, this message translates to:
  /// **'Set Budget Amount'**
  String get budgetsSetAmount;

  /// No description provided for @budgetsRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get budgetsRemaining;

  /// No description provided for @budgetsOverBudget.
  ///
  /// In en, this message translates to:
  /// **'Over Budget'**
  String get budgetsOverBudget;

  /// No description provided for @goalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Saving Goals'**
  String get goalsTitle;

  /// No description provided for @goalsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Goal'**
  String get goalsAdd;

  /// No description provided for @goalsTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get goalsTarget;

  /// No description provided for @goalsCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get goalsCurrent;

  /// No description provided for @goalsProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get goalsProgress;

  /// No description provided for @walletsTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallets & Accounts'**
  String get walletsTitle;

  /// No description provided for @walletsBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get walletsBalance;

  /// No description provided for @walletsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Wallet'**
  String get walletsAdd;

  /// No description provided for @subscriptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptionsTitle;

  /// No description provided for @subscriptionsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Subscription'**
  String get subscriptionsAdd;

  /// No description provided for @subscriptionsNextRenewal.
  ///
  /// In en, this message translates to:
  /// **'Next Renewal'**
  String get subscriptionsNextRenewal;

  /// No description provided for @subscriptionsMonthlyImpact.
  ///
  /// In en, this message translates to:
  /// **'Monthly Impact'**
  String get subscriptionsMonthlyImpact;

  /// No description provided for @aiAdviceTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Advice'**
  String get aiAdviceTitle;

  /// No description provided for @aiAdviceRequest.
  ///
  /// In en, this message translates to:
  /// **'Get Spending Advice'**
  String get aiAdviceRequest;

  /// No description provided for @aiAdviceLoading.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your spending...'**
  String get aiAdviceLoading;

  /// No description provided for @aiHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'AI History'**
  String get aiHistoryTitle;

  /// No description provided for @aiAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistantTitle;

  /// No description provided for @aiAssistantPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Ask about your expenses...'**
  String get aiAssistantPlaceholder;

  /// No description provided for @aiAssistantSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get aiAssistantSend;

  /// No description provided for @aiQuotaRemaining.
  ///
  /// In en, this message translates to:
  /// **'AI requests remaining today'**
  String get aiQuotaRemaining;

  /// No description provided for @aiQuotaExceeded.
  ///
  /// In en, this message translates to:
  /// **'AI quota exceeded. Try again tomorrow or upgrade to Premium.'**
  String get aiQuotaExceeded;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfile;

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrency;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurity;

  /// No description provided for @settingsAiQuota.
  ///
  /// In en, this message translates to:
  /// **'AI Usage'**
  String get settingsAiQuota;

  /// No description provided for @settingsMonetization.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get settingsMonetization;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSupport;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get settingsExport;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settingsLogout;

  /// No description provided for @profileEditName.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get profileEditName;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteAccount;

  /// No description provided for @premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get premiumTitle;

  /// No description provided for @premiumFeature1.
  ///
  /// In en, this message translates to:
  /// **'Higher AI quotas'**
  String get premiumFeature1;

  /// No description provided for @premiumFeature2.
  ///
  /// In en, this message translates to:
  /// **'Remove ads'**
  String get premiumFeature2;

  /// No description provided for @premiumFeature3.
  ///
  /// In en, this message translates to:
  /// **'Advanced reports'**
  String get premiumFeature3;

  /// No description provided for @premiumPurchase.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get premiumPurchase;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @exportExcel.
  ///
  /// In en, this message translates to:
  /// **'Export Excel'**
  String get exportExcel;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get notFound;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
