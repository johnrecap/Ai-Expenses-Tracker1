import 'package:flutter/material.dart';
import 'mock_models.dart';

abstract class MockData {
  MockData._();

  static const currentUser = MockUser(
    id: 'user-1',
    displayName: 'Ahmed Al-Rashid',
    avatarAsset: null,
    localeCode: 'en',
    baseCurrency: 'KWD',
  );

  static const categories = [
    MockCategory(
      id: 'cat-1',
      label: 'Food & Dining',
      iconName: 'restaurant',
      colorToken: Color(0xFFFF7043),
    ),
    MockCategory(
      id: 'cat-2',
      label: 'Transport',
      iconName: 'local_taxi',
      colorToken: Color(0xFF42A5F5),
    ),
    MockCategory(
      id: 'cat-3',
      label: 'Shopping',
      iconName: 'shopping_bag',
      colorToken: Color(0xFFAB47BC),
    ),
    MockCategory(id: 'cat-4', label: 'Housing', iconName: 'home', colorToken: Color(0xFF66BB6A)),
    MockCategory(
      id: 'cat-5',
      label: 'Entertainment',
      iconName: 'movie',
      colorToken: Color(0xFFFFCA28),
    ),
    MockCategory(
      id: 'cat-6',
      label: 'Healthcare',
      iconName: 'local_hospital',
      colorToken: Color(0xFFEF5350),
    ),
    MockCategory(
      id: 'cat-7',
      label: 'Education',
      iconName: 'school',
      colorToken: Color(0xFF78909C),
    ),
    MockCategory(id: 'cat-8', label: 'Utilities', iconName: 'bolt', colorToken: Color(0xFF8D6E63)),
    MockCategory(id: 'cat-9', label: 'Travel', iconName: 'flight', colorToken: Color(0xFF26C6DA)),
    MockCategory(
      id: 'cat-10',
      label: 'Other',
      iconName: 'more_horiz',
      colorToken: Color(0xFFBDBDBD),
    ),
  ];

  static final expenses = [
    MockExpense(
      id: 'exp-1',
      merchant: 'Talabat Delivery',
      categoryId: 'cat-1',
      amount: 12.500,
      currency: 'KWD',
      date: DateTime(2026, 5, 28),
      walletId: 'wal-1',
      visualStatus: 'cleared',
    ),
    MockExpense(
      id: 'exp-2',
      merchant: 'Careem Ride',
      categoryId: 'cat-2',
      amount: 4.750,
      currency: 'KWD',
      date: DateTime(2026, 5, 27),
      walletId: 'wal-1',
      visualStatus: 'cleared',
    ),
    MockExpense(
      id: 'exp-3',
      merchant: 'The Avenues Mall',
      categoryId: 'cat-3',
      amount: 89.900,
      currency: 'KWD',
      date: DateTime(2026, 5, 26),
      walletId: 'wal-2',
      visualStatus: 'pending',
    ),
    MockExpense(
      id: 'exp-4',
      merchant: 'Starbucks Coffee',
      categoryId: 'cat-1',
      amount: 3.250,
      currency: 'KWD',
      date: DateTime(2026, 5, 25),
      walletId: 'wal-1',
      visualStatus: 'cleared',
    ),
    MockExpense(
      id: 'exp-5',
      merchant: 'Kuwait Airways',
      categoryId: 'cat-9',
      amount: 245.000,
      currency: 'KWD',
      date: DateTime(2026, 5, 20),
      walletId: 'wal-3',
      visualStatus: 'cleared',
    ),
    MockExpense(
      id: 'exp-6',
      merchant: 'Amazon Prime',
      categoryId: 'cat-3',
      amount: 15.000,
      currency: 'KWD',
      date: DateTime(2026, 5, 19),
      walletId: 'wal-1',
      visualStatus: 'cleared',
    ),
    MockExpense(
      id: 'exp-7',
      merchant: 'Vox Cinema',
      categoryId: 'cat-5',
      amount: 8.500,
      currency: 'KWD',
      date: DateTime(2026, 5, 18),
      walletId: 'wal-2',
      visualStatus: 'cleared',
    ),
    MockExpense(
      id: 'exp-8',
      merchant: 'Royal Hayat Hospital',
      categoryId: 'cat-6',
      amount: 45.000,
      currency: 'KWD',
      date: DateTime(2026, 5, 15),
      walletId: 'wal-3',
      visualStatus: 'cleared',
    ),
    MockExpense(
      id: 'exp-9',
      merchant: 'Ministry Electricity',
      categoryId: 'cat-8',
      amount: 32.000,
      currency: 'KWD',
      date: DateTime(2026, 5, 10),
      walletId: 'wal-1',
      visualStatus: 'cleared',
    ),
    MockExpense(
      id: 'exp-10',
      merchant: 'Carrefour Market',
      categoryId: 'cat-1',
      amount: 28.750,
      currency: 'KWD',
      date: DateTime(2026, 5, 8),
      walletId: 'wal-1',
      visualStatus: 'cleared',
    ),
    MockExpense(
      id: 'exp-11',
      merchant: 'Zain Telecom',
      categoryId: 'cat-8',
      amount: 20.000,
      currency: 'KWD',
      date: DateTime(2026, 5, 5),
      walletId: 'wal-1',
      visualStatus: 'cleared',
    ),
    MockExpense(
      id: 'exp-12',
      merchant: 'IKEA Kuwait',
      categoryId: 'cat-4',
      amount: 120.000,
      currency: 'KWD',
      date: DateTime(2026, 5, 1),
      walletId: 'wal-2',
      visualStatus: 'cleared',
    ),
  ];

  static const wallets = [
    MockWallet(
      id: 'wal-1',
      name: 'NBK Current',
      type: 'current',
      balance: 2540.750,
      currency: 'KWD',
      trendLabel: '+3.2% this month',
    ),
    MockWallet(
      id: 'wal-2',
      name: 'KFH Savings',
      type: 'savings',
      balance: 8750.000,
      currency: 'KWD',
      trendLabel: '+0.8% this month',
    ),
    MockWallet(
      id: 'wal-3',
      name: 'Burgan Credit',
      type: 'credit',
      balance: -1250.500,
      currency: 'KWD',
      trendLabel: '-12% vs last month',
    ),
    MockWallet(id: 'wal-4', name: 'Cash Wallet', type: 'cash', balance: 350.000, currency: 'KWD'),
  ];

  static const budgets = [
    MockBudget(
      id: 'bud-1',
      monthLabel: 'May 2026',
      cap: 1200.0,
      spent: 845.5,
      categoryAllocations: {
        'cat-1': 400,
        'cat-2': 150,
        'cat-3': 200,
        'cat-5': 150,
        'cat-6': 100,
        'cat-8': 200,
      },
    ),
    MockBudget(
      id: 'bud-2',
      monthLabel: 'April 2026',
      cap: 1100.0,
      spent: 980.0,
      categoryAllocations: {
        'cat-1': 380,
        'cat-2': 140,
        'cat-3': 180,
        'cat-5': 120,
        'cat-6': 100,
        'cat-8': 180,
      },
    ),
  ];

  static const goals = [
    MockGoal(
      id: 'goal-1',
      title: 'New Car Fund',
      targetAmount: 8000.0,
      savedAmount: 3200.0,
      deadlineLabel: 'Dec 2026',
    ),
    MockGoal(
      id: 'goal-2',
      title: 'Vacation to Dubai',
      targetAmount: 2500.0,
      savedAmount: 1875.0,
      deadlineLabel: 'Aug 2026',
    ),
    MockGoal(
      id: 'goal-3',
      title: 'Emergency Fund',
      targetAmount: 5000.0,
      savedAmount: 5000.0,
      deadlineLabel: 'Completed',
    ),
    MockGoal(
      id: 'goal-4',
      title: 'Home Renovation',
      targetAmount: 15000.0,
      savedAmount: 3500.0,
      deadlineLabel: 'Mar 2027',
    ),
  ];

  static const subscriptions = [
    MockSubscription(
      id: 'sub-1',
      vendor: 'Netflix',
      amount: 4.500,
      currency: 'KWD',
      nextBillingLabel: 'Jun 15',
      status: 'active',
      hasAiWarning: false,
    ),
    MockSubscription(
      id: 'sub-2',
      vendor: 'Spotify',
      amount: 3.500,
      currency: 'KWD',
      nextBillingLabel: 'Jun 10',
      status: 'active',
      hasAiWarning: false,
    ),
    MockSubscription(
      id: 'sub-3',
      vendor: 'YouTube Premium',
      amount: 3.500,
      currency: 'KWD',
      nextBillingLabel: 'Jun 22',
      status: 'active',
      hasAiWarning: true,
    ),
    MockSubscription(
      id: 'sub-4',
      vendor: 'AWS Cloud',
      amount: 15.000,
      currency: 'KWD',
      nextBillingLabel: 'Jun 1',
      status: 'active',
      hasAiWarning: true,
    ),
    MockSubscription(
      id: 'sub-5',
      vendor: 'Adobe Creative',
      amount: 20.000,
      currency: 'KWD',
      nextBillingLabel: 'May 30',
      status: 'expiring',
      hasAiWarning: false,
    ),
  ];

  static const reports = [
    MockReport(
      id: 'rep-1',
      periodLabel: 'May 2026',
      totalSpent: 845.5,
      comparisonLabel: '-12% vs April',
      categoryBreakdown: {
        'cat-1': 245.5,
        'cat-2': 85.0,
        'cat-3': 100.0,
        'cat-4': 120.0,
        'cat-5': 60.0,
        'cat-6': 45.0,
        'cat-8': 52.0,
        'cat-9': 100.0,
        'cat-10': 38.0,
      },
      trendPoints: [980, 920, 1050, 890, 950, 845],
    ),
    MockReport(
      id: 'rep-2',
      periodLabel: 'April 2026',
      totalSpent: 980.0,
      comparisonLabel: '+5% vs March',
      categoryBreakdown: {
        'cat-1': 280.0,
        'cat-2': 110.0,
        'cat-3': 120.0,
        'cat-4': 0,
        'cat-5': 80.0,
        'cat-6': 90.0,
        'cat-8': 55.0,
        'cat-10': 245.0,
      },
      trendPoints: [850, 780, 920, 880, 760, 980],
    ),
  ];

  static const aiInsights = [
    MockAiInsight(
      id: 'ai-1',
      title: 'Subscription Overlap Detected',
      summary:
          'You have both Netflix and YouTube Premium. Consider consolidating to save 3.500 KWD/month.',
      severity: 'warning',
      relatedRoute: '/subscriptions',
    ),
    MockAiInsight(
      id: 'ai-2',
      title: 'Dining Spike This Month',
      summary:
          'Food expenses are 22% higher than last month. The Avenues Mall and Talabat account for most of the increase.',
      severity: 'info',
      relatedRoute: '/expenses',
    ),
    MockAiInsight(
      id: 'ai-3',
      title: 'Goal On Track',
      summary: 'Your Vacation to Dubai goal is 75% complete, 2 months ahead of schedule.',
      severity: 'success',
      relatedRoute: '/goals',
    ),
    MockAiInsight(
      id: 'ai-4',
      title: 'AWS Bill Increase',
      summary:
          'Your AWS subscription has increased 15% this year. Review unused resources to optimize costs.',
      severity: 'warning',
      relatedRoute: '/subscriptions',
    ),
  ];

  static const chatMessages = [
    MockChatMessage(
      id: 'msg-1',
      author: 'AI Assistant',
      text: 'Hello Ahmed! How can I help you with your finances today?',
      timestampLabel: '10:30 AM',
      isUser: false,
    ),
    MockChatMessage(
      id: 'msg-2',
      author: 'Ahmed',
      text: 'Show me my spending breakdown for May',
      timestampLabel: '10:31 AM',
      isUser: true,
    ),
    MockChatMessage(
      id: 'msg-3',
      author: 'AI Assistant',
      text:
          'Here is your May spending: Total is 845.500 KWD. Top categories: Food (245.5 KWD), Transport (85 KWD), Shopping (100 KWD). Would you like to see the full report?',
      timestampLabel: '10:31 AM',
      isUser: false,
    ),
    MockChatMessage(
      id: 'msg-4',
      author: 'Ahmed',
      text: 'How can I reduce my spending?',
      timestampLabel: '10:32 AM',
      isUser: true,
    ),
    MockChatMessage(
      id: 'msg-5',
      author: 'AI Assistant',
      text:
          'I noticed a few opportunities:\n1. Your YouTube Premium and Netflix overlap - saving 3.500 KWD/month\n2. Dining out is 22% above average - consider meal planning\n3. Your AWS bill has unused resources\n\nWould you like me to create a budget plan?',
      timestampLabel: '10:33 AM',
      isUser: false,
    ),
  ];
}
