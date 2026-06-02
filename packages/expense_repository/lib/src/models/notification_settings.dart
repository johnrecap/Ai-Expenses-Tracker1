class NotificationSettings {
  final bool budgetAlerts;
  final bool recurringReminders;
  final bool subscriptionRenewals;
  final bool weeklyDigest;
  final bool aiQuotaWarnings;
  final bool dailyReminder;
  final String? dailyReminderTime;

  const NotificationSettings({
    this.budgetAlerts = true,
    this.recurringReminders = true,
    this.subscriptionRenewals = true,
    this.weeklyDigest = false,
    this.aiQuotaWarnings = true,
    this.dailyReminder = false,
    this.dailyReminderTime,
  });

  const NotificationSettings.defaults()
    : budgetAlerts = true,
      recurringReminders = true,
      subscriptionRenewals = true,
      weeklyDigest = false,
      aiQuotaWarnings = true,
      dailyReminder = false,
      dailyReminderTime = null;

  const NotificationSettings.disabled()
    : budgetAlerts = false,
      recurringReminders = false,
      subscriptionRenewals = false,
      weeklyDigest = false,
      aiQuotaWarnings = false,
      dailyReminder = false,
      dailyReminderTime = null;

  NotificationSettings copyWith({
    bool? budgetAlerts,
    bool? recurringReminders,
    bool? subscriptionRenewals,
    bool? weeklyDigest,
    bool? aiQuotaWarnings,
    bool? dailyReminder,
    String? dailyReminderTime,
    bool clearDailyReminderTime = false,
  }) {
    return NotificationSettings(
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      recurringReminders: recurringReminders ?? this.recurringReminders,
      subscriptionRenewals: subscriptionRenewals ?? this.subscriptionRenewals,
      weeklyDigest: weeklyDigest ?? this.weeklyDigest,
      aiQuotaWarnings: aiQuotaWarnings ?? this.aiQuotaWarnings,
      dailyReminder: dailyReminder ?? this.dailyReminder,
      dailyReminderTime: clearDailyReminderTime
          ? null
          : dailyReminderTime ?? this.dailyReminderTime,
    );
  }
}
