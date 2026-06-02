import 'package:flutter/material.dart';

class MockUser {
  const MockUser({
    required this.id,
    required this.displayName,
    this.avatarAsset,
    required this.localeCode,
    required this.baseCurrency,
  });

  final String id;
  final String displayName;
  final String? avatarAsset;
  final String localeCode;
  final String baseCurrency;
}

class MockCategory {
  const MockCategory({
    required this.id,
    required this.label,
    required this.iconName,
    this.colorToken,
  });

  final String id;
  final String label;
  final String iconName;
  final Color? colorToken;
}

class MockExpense {
  const MockExpense({
    required this.id,
    required this.merchant,
    required this.categoryId,
    required this.amount,
    required this.currency,
    required this.date,
    required this.walletId,
    this.notes,
    required this.visualStatus,
  });

  final String id;
  final String merchant;
  final String categoryId;
  final double amount;
  final String currency;
  final DateTime date;
  final String walletId;
  final String? notes;
  final String visualStatus;
}

class MockWallet {
  const MockWallet({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    this.trendLabel,
  });

  final String id;
  final String name;
  final String type;
  final double balance;
  final String currency;
  final String? trendLabel;
}

class MockBudget {
  const MockBudget({
    required this.id,
    required this.monthLabel,
    required this.cap,
    required this.spent,
    this.categoryAllocations = const {},
  });

  final String id;
  final String monthLabel;
  final double cap;
  final double spent;
  final Map<String, double> categoryAllocations;

  double get remaining => cap - spent;
  double get progress => cap > 0 ? (spent / cap).clamp(0.0, 1.0) : 0.0;
}

class MockGoal {
  const MockGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
    required this.deadlineLabel,
  });

  final String id;
  final String title;
  final double targetAmount;
  final double savedAmount;
  final String deadlineLabel;

  double get progress => targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
}

class MockSubscription {
  const MockSubscription({
    required this.id,
    required this.vendor,
    required this.amount,
    required this.currency,
    required this.nextBillingLabel,
    required this.status,
    this.hasAiWarning = false,
  });

  final String id;
  final String vendor;
  final double amount;
  final String currency;
  final String nextBillingLabel;
  final String status;
  final bool hasAiWarning;
}

class MockReport {
  const MockReport({
    required this.id,
    required this.periodLabel,
    required this.totalSpent,
    required this.comparisonLabel,
    this.categoryBreakdown = const {},
    this.trendPoints = const [],
  });

  final String id;
  final String periodLabel;
  final double totalSpent;
  final String comparisonLabel;
  final Map<String, double> categoryBreakdown;
  final List<double> trendPoints;
}

class MockAiInsight {
  const MockAiInsight({
    required this.id,
    required this.title,
    required this.summary,
    required this.severity,
    required this.relatedRoute,
  });

  final String id;
  final String title;
  final String summary;
  final String severity;
  final String relatedRoute;
}

class MockChatMessage {
  const MockChatMessage({
    required this.id,
    required this.author,
    required this.text,
    required this.timestampLabel,
    required this.isUser,
  });

  final String id;
  final String author;
  final String text;
  final String timestampLabel;
  final bool isUser;
}
