// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'متتبع المصروفات الذكي';

  @override
  String get splashLoading => 'جار التحميل...';

  @override
  String get onboardingLanguageTitle => 'اختر اللغة';

  @override
  String get onboardingLanguageEnglish => 'English';

  @override
  String get onboardingLanguageArabic => 'العربية';

  @override
  String get onboardingCurrencyTitle => 'اختر العملة الأساسية';

  @override
  String get onboardingNotificationsTitle => 'ابق على اطلاع';

  @override
  String get onboardingNotificationsSubtitle =>
      'اسمح بالإشعارات لتنبيهات الميزانية والتذكيرات والرؤى';

  @override
  String get onboardingEnableNotifications => 'تفعيل الإشعارات';

  @override
  String get continueButton => 'متابعة';

  @override
  String get skipButton => 'تخطي';

  @override
  String get loginTitle => 'مرحبًا بعودتك';

  @override
  String get loginEmail => 'البريد الإلكتروني';

  @override
  String get loginPassword => 'كلمة المرور';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get loginGoogleButton => 'المتابعة باستخدام Google';

  @override
  String get loginNoAccount => 'ليس لديك حساب؟ سجل الآن';

  @override
  String get signUpTitle => 'إنشاء حساب';

  @override
  String get signUpName => 'الاسم';

  @override
  String get signUpEmail => 'البريد الإلكتروني';

  @override
  String get signUpPassword => 'كلمة المرور';

  @override
  String get signUpConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get signUpButton => 'إنشاء حساب';

  @override
  String get signUpHaveAccount => 'لديك حساب بالفعل؟ تسجيل الدخول';

  @override
  String get authErrorInvalidEmail => 'أدخل بريدًا إلكترونيًا صالحًا';

  @override
  String get authErrorWrongPassword => 'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get authErrorWeakPassword => 'كلمة المرور ضعيفة جدًا';

  @override
  String get authErrorEmailInUse => 'يوجد حساب بالفعل لهذا البريد الإلكتروني';

  @override
  String get authErrorNetwork => 'تحقق من اتصالك بالإنترنت';

  @override
  String get authErrorGeneral => 'فشلت المصادقة. حاول مرة أخرى.';

  @override
  String get homeTitle => 'لوحة التحكم';

  @override
  String get homeGreeting => 'صباح الخير';

  @override
  String get homeTotalSpent => 'إجمالي المصروفات';

  @override
  String get homeMonthlyBudget => 'الميزانية الشهرية';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navReports => 'التقارير';

  @override
  String get navBudgets => 'الميزانيات';

  @override
  String get navWallets => 'المحافظ';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get expensesTitle => 'المصروفات';

  @override
  String get expensesSearch => 'البحث عن مصروفات...';

  @override
  String get expensesFilter => 'تصفية';

  @override
  String get expensesClearFilters => 'مسح';

  @override
  String get expensesApplyFilters => 'تطبيق';

  @override
  String get expensesNoResults => 'لا توجد مصروفات';

  @override
  String get addExpenseQuick => 'إضافة مصروف';

  @override
  String get addExpenseAiText => 'نص ذكي';

  @override
  String get addExpenseReceipt => 'إيصال';

  @override
  String get addExpenseAmount => 'المبلغ';

  @override
  String get addExpenseCategory => 'الفئة';

  @override
  String get addExpenseDate => 'التاريخ';

  @override
  String get addExpenseNotes => 'ملاحظات';

  @override
  String get addExpensePaymentMethod => 'طريقة الدفع';

  @override
  String get addExpenseSave => 'حفظ المصروف';

  @override
  String get editExpenseTitle => 'تعديل المصروف';

  @override
  String get editExpenseSave => 'حفظ التغييرات';

  @override
  String get deleteExpenseConfirm => 'هل أنت متأكد من حذف هذا المصروف؟';

  @override
  String get deleteExpenseTitle => 'حذف المصروف';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get reportsTitle => 'التقارير';

  @override
  String get reportsThisMonth => 'هذا الشهر';

  @override
  String get reportsByCategory => 'حسب الفئة';

  @override
  String get reportsTrends => 'اتجاهات الإنفاق';

  @override
  String get reportsDrilldown => 'تفاصيل الفئة';

  @override
  String get reportsMonthlyStory => 'القصة الشهرية';

  @override
  String get budgetsTitle => 'الميزانيات';

  @override
  String get budgetsMonthlyBudget => 'الميزانية الشهرية';

  @override
  String get budgetsCategoryBudgets => 'ميزانيات الفئات';

  @override
  String get budgetsEdit => 'تعديل الميزانية';

  @override
  String get budgetsSetAmount => 'تحديد مبلغ الميزانية';

  @override
  String get budgetsRemaining => 'المتبقي';

  @override
  String get budgetsOverBudget => 'تجاوز الميزانية';

  @override
  String get goalsTitle => 'أهداف الادخار';

  @override
  String get goalsAdd => 'إضافة هدف';

  @override
  String get goalsTarget => 'الهدف';

  @override
  String get goalsCurrent => 'الحالي';

  @override
  String get goalsProgress => 'التقدم';

  @override
  String get walletsTitle => 'المحافظ والحسابات';

  @override
  String get walletsBalance => 'الرصيد';

  @override
  String get walletsAdd => 'إضافة محفظة';

  @override
  String get subscriptionsTitle => 'الاشتراكات';

  @override
  String get subscriptionsAdd => 'إضافة اشتراك';

  @override
  String get subscriptionsNextRenewal => 'التجديد القادم';

  @override
  String get subscriptionsMonthlyImpact => 'التأثير الشهري';

  @override
  String get aiAdviceTitle => 'نصائح الذكاء الاصطناعي';

  @override
  String get aiAdviceRequest => 'احصل على نصائح الإنفاق';

  @override
  String get aiAdviceLoading => 'جار تحليل إنفاقك...';

  @override
  String get aiHistoryTitle => 'سجل الذكاء الاصطناعي';

  @override
  String get aiAssistantTitle => 'المساعد الذكي';

  @override
  String get aiAssistantPlaceholder => 'اسأل عن مصروفاتك...';

  @override
  String get aiAssistantSend => 'إرسال';

  @override
  String get aiQuotaRemaining => 'طلبات الذكاء الاصطناعي المتبقية اليوم';

  @override
  String get aiQuotaExceeded => 'تم تجاوز الحد اليومي. حاول غدًا أو قم بالترقية إلى Premium.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsProfile => 'الملف الشخصي';

  @override
  String get settingsCurrency => 'العملة';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get settingsSecurity => 'الأمان';

  @override
  String get settingsAiQuota => 'استخدام الذكاء الاصطناعي';

  @override
  String get settingsMonetization => 'النسخة المميزة';

  @override
  String get settingsSupport => 'الدعم';

  @override
  String get settingsExport => 'تصدير البيانات';

  @override
  String get settingsAbout => 'حول';

  @override
  String get settingsLogout => 'تسجيل الخروج';

  @override
  String get profileEditName => 'تعديل الاسم';

  @override
  String get profileDeleteAccount => 'حذف الحساب';

  @override
  String get premiumTitle => 'الترقية إلى النسخة المميزة';

  @override
  String get premiumFeature1 => 'حدود أعلى للذكاء الاصطناعي';

  @override
  String get premiumFeature2 => 'إزالة الإعلانات';

  @override
  String get premiumFeature3 => 'تقارير متقدمة';

  @override
  String get premiumPurchase => 'ترقية الآن';

  @override
  String get exportCsv => 'تصدير CSV';

  @override
  String get exportExcel => 'تصدير Excel';

  @override
  String get exportPdf => 'تصدير PDF';

  @override
  String get notFound => 'الصفحة غير موجودة';

  @override
  String get back => 'رجوع';

  @override
  String get confirm => 'تأكيد';

  @override
  String get done => 'تم';

  @override
  String get save => 'حفظ';

  @override
  String get loading => 'جار التحميل...';
}
