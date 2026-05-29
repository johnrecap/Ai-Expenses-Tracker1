class NotificationSettings {
  final bool budgetAlerts;
  final bool recurringReminders;
  final bool subscriptionRenewals;
  final bool weeklyDigest;
  final bool aiQuotaWarnings;

  const NotificationSettings({
    this.budgetAlerts = true,
    this.recurringReminders = true,
    this.subscriptionRenewals = true,
    this.weeklyDigest = false,
    this.aiQuotaWarnings = true,
  });

  const NotificationSettings.defaults()
      : budgetAlerts = true,
        recurringReminders = true,
        subscriptionRenewals = true,
        weeklyDigest = false,
        aiQuotaWarnings = true;
}
