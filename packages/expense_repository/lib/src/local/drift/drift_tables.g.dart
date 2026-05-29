// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_tables.dart';

// ignore_for_file: type=lint
class $ExpensesTable extends Expenses
    with TableInfo<$ExpensesTable, DriftExpense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _expenseIdMeta = const VerificationMeta(
    'expenseId',
  );
  @override
  late final GeneratedColumn<String> expenseId = GeneratedColumn<String>(
    'expense_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryNameMeta = const VerificationMeta(
    'categoryName',
  );
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
    'category_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIconMeta = const VerificationMeta(
    'categoryIcon',
  );
  @override
  late final GeneratedColumn<String> categoryIcon = GeneratedColumn<String>(
    'category_icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryColorMeta = const VerificationMeta(
    'categoryColor',
  );
  @override
  late final GeneratedColumn<int> categoryColor = GeneratedColumn<int>(
    'category_color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>(
        'tags',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($ExpensesTable.$convertertags);
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _walletAccountIdMeta = const VerificationMeta(
    'walletAccountId',
  );
  @override
  late final GeneratedColumn<String> walletAccountId = GeneratedColumn<String>(
    'wallet_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _walletAccountNameMeta = const VerificationMeta(
    'walletAccountName',
  );
  @override
  late final GeneratedColumn<String> walletAccountName =
      GeneratedColumn<String>(
        'wallet_account_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recurringExpenseIdMeta =
      const VerificationMeta('recurringExpenseId');
  @override
  late final GeneratedColumn<String> recurringExpenseId =
      GeneratedColumn<String>(
        'recurring_expense_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _aiActionIdMeta = const VerificationMeta(
    'aiActionId',
  );
  @override
  late final GeneratedColumn<String> aiActionId = GeneratedColumn<String>(
    'ai_action_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MoneySnapshot?, String>
  moneySnapshot = GeneratedColumn<String>(
    'money_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<MoneySnapshot?>($ExpensesTable.$convertermoneySnapshot);
  @override
  List<GeneratedColumn> get $columns => [
    expenseId,
    userId,
    categoryId,
    categoryName,
    categoryIcon,
    categoryColor,
    date,
    amount,
    description,
    merchant,
    tags,
    paymentMethod,
    currency,
    createdAt,
    updatedAt,
    source,
    walletAccountId,
    walletAccountName,
    recurringExpenseId,
    aiActionId,
    moneySnapshot,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<DriftExpense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('expense_id')) {
      context.handle(
        _expenseIdMeta,
        expenseId.isAcceptableOrUnknown(data['expense_id']!, _expenseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_expenseIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('category_name')) {
      context.handle(
        _categoryNameMeta,
        categoryName.isAcceptableOrUnknown(
          data['category_name']!,
          _categoryNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryNameMeta);
    }
    if (data.containsKey('category_icon')) {
      context.handle(
        _categoryIconMeta,
        categoryIcon.isAcceptableOrUnknown(
          data['category_icon']!,
          _categoryIconMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryIconMeta);
    }
    if (data.containsKey('category_color')) {
      context.handle(
        _categoryColorMeta,
        categoryColor.isAcceptableOrUnknown(
          data['category_color']!,
          _categoryColorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryColorMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('wallet_account_id')) {
      context.handle(
        _walletAccountIdMeta,
        walletAccountId.isAcceptableOrUnknown(
          data['wallet_account_id']!,
          _walletAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('wallet_account_name')) {
      context.handle(
        _walletAccountNameMeta,
        walletAccountName.isAcceptableOrUnknown(
          data['wallet_account_name']!,
          _walletAccountNameMeta,
        ),
      );
    }
    if (data.containsKey('recurring_expense_id')) {
      context.handle(
        _recurringExpenseIdMeta,
        recurringExpenseId.isAcceptableOrUnknown(
          data['recurring_expense_id']!,
          _recurringExpenseIdMeta,
        ),
      );
    }
    if (data.containsKey('ai_action_id')) {
      context.handle(
        _aiActionIdMeta,
        aiActionId.isAcceptableOrUnknown(
          data['ai_action_id']!,
          _aiActionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {expenseId};
  @override
  DriftExpense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftExpense(
      expenseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expense_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      categoryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_name'],
      )!,
      categoryIcon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_icon'],
      )!,
      categoryColor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_color'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      ),
      tags: $ExpensesTable.$convertertags.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tags'],
        )!,
      ),
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      walletAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wallet_account_id'],
      ),
      walletAccountName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wallet_account_name'],
      ),
      recurringExpenseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurring_expense_id'],
      ),
      aiActionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ai_action_id'],
      ),
      moneySnapshot: $ExpensesTable.$convertermoneySnapshot.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}money_snapshot'],
        ),
      ),
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertertags =
      const StringListConverter();
  static TypeConverter<MoneySnapshot?, String?> $convertermoneySnapshot =
      const MoneySnapshotConverter();
}

class DriftExpense extends DataClass implements Insertable<DriftExpense> {
  final String expenseId;
  final String userId;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final int categoryColor;
  final DateTime date;
  final double amount;
  final String description;
  final String? merchant;
  final List<String> tags;
  final String paymentMethod;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String source;
  final String? walletAccountId;
  final String? walletAccountName;
  final String? recurringExpenseId;
  final String? aiActionId;
  final MoneySnapshot? moneySnapshot;
  const DriftExpense({
    required this.expenseId,
    required this.userId,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.date,
    required this.amount,
    required this.description,
    this.merchant,
    required this.tags,
    required this.paymentMethod,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
    required this.source,
    this.walletAccountId,
    this.walletAccountName,
    this.recurringExpenseId,
    this.aiActionId,
    this.moneySnapshot,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['expense_id'] = Variable<String>(expenseId);
    map['user_id'] = Variable<String>(userId);
    map['category_id'] = Variable<String>(categoryId);
    map['category_name'] = Variable<String>(categoryName);
    map['category_icon'] = Variable<String>(categoryIcon);
    map['category_color'] = Variable<int>(categoryColor);
    map['date'] = Variable<DateTime>(date);
    map['amount'] = Variable<double>(amount);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || merchant != null) {
      map['merchant'] = Variable<String>(merchant);
    }
    {
      map['tags'] = Variable<String>($ExpensesTable.$convertertags.toSql(tags));
    }
    map['payment_method'] = Variable<String>(paymentMethod);
    map['currency'] = Variable<String>(currency);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || walletAccountId != null) {
      map['wallet_account_id'] = Variable<String>(walletAccountId);
    }
    if (!nullToAbsent || walletAccountName != null) {
      map['wallet_account_name'] = Variable<String>(walletAccountName);
    }
    if (!nullToAbsent || recurringExpenseId != null) {
      map['recurring_expense_id'] = Variable<String>(recurringExpenseId);
    }
    if (!nullToAbsent || aiActionId != null) {
      map['ai_action_id'] = Variable<String>(aiActionId);
    }
    if (!nullToAbsent || moneySnapshot != null) {
      map['money_snapshot'] = Variable<String>(
        $ExpensesTable.$convertermoneySnapshot.toSql(moneySnapshot),
      );
    }
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      expenseId: Value(expenseId),
      userId: Value(userId),
      categoryId: Value(categoryId),
      categoryName: Value(categoryName),
      categoryIcon: Value(categoryIcon),
      categoryColor: Value(categoryColor),
      date: Value(date),
      amount: Value(amount),
      description: Value(description),
      merchant: merchant == null && nullToAbsent
          ? const Value.absent()
          : Value(merchant),
      tags: Value(tags),
      paymentMethod: Value(paymentMethod),
      currency: Value(currency),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      source: Value(source),
      walletAccountId: walletAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(walletAccountId),
      walletAccountName: walletAccountName == null && nullToAbsent
          ? const Value.absent()
          : Value(walletAccountName),
      recurringExpenseId: recurringExpenseId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringExpenseId),
      aiActionId: aiActionId == null && nullToAbsent
          ? const Value.absent()
          : Value(aiActionId),
      moneySnapshot: moneySnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(moneySnapshot),
    );
  }

  factory DriftExpense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftExpense(
      expenseId: serializer.fromJson<String>(json['expenseId']),
      userId: serializer.fromJson<String>(json['userId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      categoryName: serializer.fromJson<String>(json['categoryName']),
      categoryIcon: serializer.fromJson<String>(json['categoryIcon']),
      categoryColor: serializer.fromJson<int>(json['categoryColor']),
      date: serializer.fromJson<DateTime>(json['date']),
      amount: serializer.fromJson<double>(json['amount']),
      description: serializer.fromJson<String>(json['description']),
      merchant: serializer.fromJson<String?>(json['merchant']),
      tags: serializer.fromJson<List<String>>(json['tags']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      currency: serializer.fromJson<String>(json['currency']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      source: serializer.fromJson<String>(json['source']),
      walletAccountId: serializer.fromJson<String?>(json['walletAccountId']),
      walletAccountName: serializer.fromJson<String?>(
        json['walletAccountName'],
      ),
      recurringExpenseId: serializer.fromJson<String?>(
        json['recurringExpenseId'],
      ),
      aiActionId: serializer.fromJson<String?>(json['aiActionId']),
      moneySnapshot: serializer.fromJson<MoneySnapshot?>(json['moneySnapshot']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'expenseId': serializer.toJson<String>(expenseId),
      'userId': serializer.toJson<String>(userId),
      'categoryId': serializer.toJson<String>(categoryId),
      'categoryName': serializer.toJson<String>(categoryName),
      'categoryIcon': serializer.toJson<String>(categoryIcon),
      'categoryColor': serializer.toJson<int>(categoryColor),
      'date': serializer.toJson<DateTime>(date),
      'amount': serializer.toJson<double>(amount),
      'description': serializer.toJson<String>(description),
      'merchant': serializer.toJson<String?>(merchant),
      'tags': serializer.toJson<List<String>>(tags),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'currency': serializer.toJson<String>(currency),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'source': serializer.toJson<String>(source),
      'walletAccountId': serializer.toJson<String?>(walletAccountId),
      'walletAccountName': serializer.toJson<String?>(walletAccountName),
      'recurringExpenseId': serializer.toJson<String?>(recurringExpenseId),
      'aiActionId': serializer.toJson<String?>(aiActionId),
      'moneySnapshot': serializer.toJson<MoneySnapshot?>(moneySnapshot),
    };
  }

  DriftExpense copyWith({
    String? expenseId,
    String? userId,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    int? categoryColor,
    DateTime? date,
    double? amount,
    String? description,
    Value<String?> merchant = const Value.absent(),
    List<String>? tags,
    String? paymentMethod,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? source,
    Value<String?> walletAccountId = const Value.absent(),
    Value<String?> walletAccountName = const Value.absent(),
    Value<String?> recurringExpenseId = const Value.absent(),
    Value<String?> aiActionId = const Value.absent(),
    Value<MoneySnapshot?> moneySnapshot = const Value.absent(),
  }) => DriftExpense(
    expenseId: expenseId ?? this.expenseId,
    userId: userId ?? this.userId,
    categoryId: categoryId ?? this.categoryId,
    categoryName: categoryName ?? this.categoryName,
    categoryIcon: categoryIcon ?? this.categoryIcon,
    categoryColor: categoryColor ?? this.categoryColor,
    date: date ?? this.date,
    amount: amount ?? this.amount,
    description: description ?? this.description,
    merchant: merchant.present ? merchant.value : this.merchant,
    tags: tags ?? this.tags,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    currency: currency ?? this.currency,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    source: source ?? this.source,
    walletAccountId: walletAccountId.present
        ? walletAccountId.value
        : this.walletAccountId,
    walletAccountName: walletAccountName.present
        ? walletAccountName.value
        : this.walletAccountName,
    recurringExpenseId: recurringExpenseId.present
        ? recurringExpenseId.value
        : this.recurringExpenseId,
    aiActionId: aiActionId.present ? aiActionId.value : this.aiActionId,
    moneySnapshot: moneySnapshot.present
        ? moneySnapshot.value
        : this.moneySnapshot,
  );
  DriftExpense copyWithCompanion(ExpensesCompanion data) {
    return DriftExpense(
      expenseId: data.expenseId.present ? data.expenseId.value : this.expenseId,
      userId: data.userId.present ? data.userId.value : this.userId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
      categoryIcon: data.categoryIcon.present
          ? data.categoryIcon.value
          : this.categoryIcon,
      categoryColor: data.categoryColor.present
          ? data.categoryColor.value
          : this.categoryColor,
      date: data.date.present ? data.date.value : this.date,
      amount: data.amount.present ? data.amount.value : this.amount,
      description: data.description.present
          ? data.description.value
          : this.description,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      tags: data.tags.present ? data.tags.value : this.tags,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      currency: data.currency.present ? data.currency.value : this.currency,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      source: data.source.present ? data.source.value : this.source,
      walletAccountId: data.walletAccountId.present
          ? data.walletAccountId.value
          : this.walletAccountId,
      walletAccountName: data.walletAccountName.present
          ? data.walletAccountName.value
          : this.walletAccountName,
      recurringExpenseId: data.recurringExpenseId.present
          ? data.recurringExpenseId.value
          : this.recurringExpenseId,
      aiActionId: data.aiActionId.present
          ? data.aiActionId.value
          : this.aiActionId,
      moneySnapshot: data.moneySnapshot.present
          ? data.moneySnapshot.value
          : this.moneySnapshot,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftExpense(')
          ..write('expenseId: $expenseId, ')
          ..write('userId: $userId, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryName: $categoryName, ')
          ..write('categoryIcon: $categoryIcon, ')
          ..write('categoryColor: $categoryColor, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('merchant: $merchant, ')
          ..write('tags: $tags, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('currency: $currency, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('source: $source, ')
          ..write('walletAccountId: $walletAccountId, ')
          ..write('walletAccountName: $walletAccountName, ')
          ..write('recurringExpenseId: $recurringExpenseId, ')
          ..write('aiActionId: $aiActionId, ')
          ..write('moneySnapshot: $moneySnapshot')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    expenseId,
    userId,
    categoryId,
    categoryName,
    categoryIcon,
    categoryColor,
    date,
    amount,
    description,
    merchant,
    tags,
    paymentMethod,
    currency,
    createdAt,
    updatedAt,
    source,
    walletAccountId,
    walletAccountName,
    recurringExpenseId,
    aiActionId,
    moneySnapshot,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftExpense &&
          other.expenseId == this.expenseId &&
          other.userId == this.userId &&
          other.categoryId == this.categoryId &&
          other.categoryName == this.categoryName &&
          other.categoryIcon == this.categoryIcon &&
          other.categoryColor == this.categoryColor &&
          other.date == this.date &&
          other.amount == this.amount &&
          other.description == this.description &&
          other.merchant == this.merchant &&
          other.tags == this.tags &&
          other.paymentMethod == this.paymentMethod &&
          other.currency == this.currency &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.source == this.source &&
          other.walletAccountId == this.walletAccountId &&
          other.walletAccountName == this.walletAccountName &&
          other.recurringExpenseId == this.recurringExpenseId &&
          other.aiActionId == this.aiActionId &&
          other.moneySnapshot == this.moneySnapshot);
}

class ExpensesCompanion extends UpdateCompanion<DriftExpense> {
  final Value<String> expenseId;
  final Value<String> userId;
  final Value<String> categoryId;
  final Value<String> categoryName;
  final Value<String> categoryIcon;
  final Value<int> categoryColor;
  final Value<DateTime> date;
  final Value<double> amount;
  final Value<String> description;
  final Value<String?> merchant;
  final Value<List<String>> tags;
  final Value<String> paymentMethod;
  final Value<String> currency;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> source;
  final Value<String?> walletAccountId;
  final Value<String?> walletAccountName;
  final Value<String?> recurringExpenseId;
  final Value<String?> aiActionId;
  final Value<MoneySnapshot?> moneySnapshot;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.expenseId = const Value.absent(),
    this.userId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.categoryIcon = const Value.absent(),
    this.categoryColor = const Value.absent(),
    this.date = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.merchant = const Value.absent(),
    this.tags = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.currency = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.source = const Value.absent(),
    this.walletAccountId = const Value.absent(),
    this.walletAccountName = const Value.absent(),
    this.recurringExpenseId = const Value.absent(),
    this.aiActionId = const Value.absent(),
    this.moneySnapshot = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String expenseId,
    required String userId,
    required String categoryId,
    required String categoryName,
    required String categoryIcon,
    required int categoryColor,
    required DateTime date,
    required double amount,
    required String description,
    this.merchant = const Value.absent(),
    required List<String> tags,
    required String paymentMethod,
    required String currency,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String source,
    this.walletAccountId = const Value.absent(),
    this.walletAccountName = const Value.absent(),
    this.recurringExpenseId = const Value.absent(),
    this.aiActionId = const Value.absent(),
    this.moneySnapshot = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : expenseId = Value(expenseId),
       userId = Value(userId),
       categoryId = Value(categoryId),
       categoryName = Value(categoryName),
       categoryIcon = Value(categoryIcon),
       categoryColor = Value(categoryColor),
       date = Value(date),
       amount = Value(amount),
       description = Value(description),
       tags = Value(tags),
       paymentMethod = Value(paymentMethod),
       currency = Value(currency),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       source = Value(source);
  static Insertable<DriftExpense> custom({
    Expression<String>? expenseId,
    Expression<String>? userId,
    Expression<String>? categoryId,
    Expression<String>? categoryName,
    Expression<String>? categoryIcon,
    Expression<int>? categoryColor,
    Expression<DateTime>? date,
    Expression<double>? amount,
    Expression<String>? description,
    Expression<String>? merchant,
    Expression<String>? tags,
    Expression<String>? paymentMethod,
    Expression<String>? currency,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? source,
    Expression<String>? walletAccountId,
    Expression<String>? walletAccountName,
    Expression<String>? recurringExpenseId,
    Expression<String>? aiActionId,
    Expression<String>? moneySnapshot,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (expenseId != null) 'expense_id': expenseId,
      if (userId != null) 'user_id': userId,
      if (categoryId != null) 'category_id': categoryId,
      if (categoryName != null) 'category_name': categoryName,
      if (categoryIcon != null) 'category_icon': categoryIcon,
      if (categoryColor != null) 'category_color': categoryColor,
      if (date != null) 'date': date,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (merchant != null) 'merchant': merchant,
      if (tags != null) 'tags': tags,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (currency != null) 'currency': currency,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (source != null) 'source': source,
      if (walletAccountId != null) 'wallet_account_id': walletAccountId,
      if (walletAccountName != null) 'wallet_account_name': walletAccountName,
      if (recurringExpenseId != null)
        'recurring_expense_id': recurringExpenseId,
      if (aiActionId != null) 'ai_action_id': aiActionId,
      if (moneySnapshot != null) 'money_snapshot': moneySnapshot,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith({
    Value<String>? expenseId,
    Value<String>? userId,
    Value<String>? categoryId,
    Value<String>? categoryName,
    Value<String>? categoryIcon,
    Value<int>? categoryColor,
    Value<DateTime>? date,
    Value<double>? amount,
    Value<String>? description,
    Value<String?>? merchant,
    Value<List<String>>? tags,
    Value<String>? paymentMethod,
    Value<String>? currency,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? source,
    Value<String?>? walletAccountId,
    Value<String?>? walletAccountName,
    Value<String?>? recurringExpenseId,
    Value<String?>? aiActionId,
    Value<MoneySnapshot?>? moneySnapshot,
    Value<int>? rowid,
  }) {
    return ExpensesCompanion(
      expenseId: expenseId ?? this.expenseId,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      merchant: merchant ?? this.merchant,
      tags: tags ?? this.tags,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source ?? this.source,
      walletAccountId: walletAccountId ?? this.walletAccountId,
      walletAccountName: walletAccountName ?? this.walletAccountName,
      recurringExpenseId: recurringExpenseId ?? this.recurringExpenseId,
      aiActionId: aiActionId ?? this.aiActionId,
      moneySnapshot: moneySnapshot ?? this.moneySnapshot,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (expenseId.present) {
      map['expense_id'] = Variable<String>(expenseId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    if (categoryIcon.present) {
      map['category_icon'] = Variable<String>(categoryIcon.value);
    }
    if (categoryColor.present) {
      map['category_color'] = Variable<int>(categoryColor.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(
        $ExpensesTable.$convertertags.toSql(tags.value),
      );
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (walletAccountId.present) {
      map['wallet_account_id'] = Variable<String>(walletAccountId.value);
    }
    if (walletAccountName.present) {
      map['wallet_account_name'] = Variable<String>(walletAccountName.value);
    }
    if (recurringExpenseId.present) {
      map['recurring_expense_id'] = Variable<String>(recurringExpenseId.value);
    }
    if (aiActionId.present) {
      map['ai_action_id'] = Variable<String>(aiActionId.value);
    }
    if (moneySnapshot.present) {
      map['money_snapshot'] = Variable<String>(
        $ExpensesTable.$convertermoneySnapshot.toSql(moneySnapshot.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('expenseId: $expenseId, ')
          ..write('userId: $userId, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryName: $categoryName, ')
          ..write('categoryIcon: $categoryIcon, ')
          ..write('categoryColor: $categoryColor, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('merchant: $merchant, ')
          ..write('tags: $tags, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('currency: $currency, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('source: $source, ')
          ..write('walletAccountId: $walletAccountId, ')
          ..write('walletAccountName: $walletAccountName, ')
          ..write('recurringExpenseId: $recurringExpenseId, ')
          ..write('aiActionId: $aiActionId, ')
          ..write('moneySnapshot: $moneySnapshot, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, DriftCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalExpensesMeta = const VerificationMeta(
    'totalExpenses',
  );
  @override
  late final GeneratedColumn<int> totalExpenses = GeneratedColumn<int>(
    'total_expenses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    categoryId,
    userId,
    name,
    totalExpenses,
    icon,
    color,
    isArchived,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<DriftCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('total_expenses')) {
      context.handle(
        _totalExpensesMeta,
        totalExpenses.isAcceptableOrUnknown(
          data['total_expenses']!,
          _totalExpensesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalExpensesMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    } else if (isInserting) {
      context.missing(_isArchivedMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {categoryId};
  @override
  DriftCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftCategory(
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      totalExpenses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_expenses'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class DriftCategory extends DataClass implements Insertable<DriftCategory> {
  final String categoryId;
  final String userId;
  final String name;
  final int totalExpenses;
  final String icon;
  final int color;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DriftCategory({
    required this.categoryId,
    required this.userId,
    required this.name,
    required this.totalExpenses,
    required this.icon,
    required this.color,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['category_id'] = Variable<String>(categoryId);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['total_expenses'] = Variable<int>(totalExpenses);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<int>(color);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      categoryId: Value(categoryId),
      userId: Value(userId),
      name: Value(name),
      totalExpenses: Value(totalExpenses),
      icon: Value(icon),
      color: Value(color),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DriftCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftCategory(
      categoryId: serializer.fromJson<String>(json['categoryId']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      totalExpenses: serializer.fromJson<int>(json['totalExpenses']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<int>(json['color']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'categoryId': serializer.toJson<String>(categoryId),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'totalExpenses': serializer.toJson<int>(totalExpenses),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<int>(color),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DriftCategory copyWith({
    String? categoryId,
    String? userId,
    String? name,
    int? totalExpenses,
    String? icon,
    int? color,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DriftCategory(
    categoryId: categoryId ?? this.categoryId,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    totalExpenses: totalExpenses ?? this.totalExpenses,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DriftCategory copyWithCompanion(CategoriesCompanion data) {
    return DriftCategory(
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      totalExpenses: data.totalExpenses.present
          ? data.totalExpenses.value
          : this.totalExpenses,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftCategory(')
          ..write('categoryId: $categoryId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('totalExpenses: $totalExpenses, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    categoryId,
    userId,
    name,
    totalExpenses,
    icon,
    color,
    isArchived,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftCategory &&
          other.categoryId == this.categoryId &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.totalExpenses == this.totalExpenses &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CategoriesCompanion extends UpdateCompanion<DriftCategory> {
  final Value<String> categoryId;
  final Value<String> userId;
  final Value<String> name;
  final Value<int> totalExpenses;
  final Value<String> icon;
  final Value<int> color;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.categoryId = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.totalExpenses = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String categoryId,
    required String userId,
    required String name,
    required int totalExpenses,
    required String icon,
    required int color,
    required bool isArchived,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : categoryId = Value(categoryId),
       userId = Value(userId),
       name = Value(name),
       totalExpenses = Value(totalExpenses),
       icon = Value(icon),
       color = Value(color),
       isArchived = Value(isArchived),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DriftCategory> custom({
    Expression<String>? categoryId,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<int>? totalExpenses,
    Expression<String>? icon,
    Expression<int>? color,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (categoryId != null) 'category_id': categoryId,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (totalExpenses != null) 'total_expenses': totalExpenses,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? categoryId,
    Value<String>? userId,
    Value<String>? name,
    Value<int>? totalExpenses,
    Value<String>? icon,
    Value<int>? color,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      categoryId: categoryId ?? this.categoryId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (totalExpenses.present) {
      map['total_expenses'] = Variable<int>(totalExpenses.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('categoryId: $categoryId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('totalExpenses: $totalExpenses, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, DriftBudget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _budgetIdMeta = const VerificationMeta(
    'budgetId',
  );
  @override
  late final GeneratedColumn<String> budgetId = GeneratedColumn<String>(
    'budget_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _warningThresholdPercentMeta =
      const VerificationMeta('warningThresholdPercent');
  @override
  late final GeneratedColumn<int> warningThresholdPercent =
      GeneratedColumn<int>(
        'warning_threshold_percent',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    budgetId,
    userId,
    month,
    year,
    amount,
    currency,
    warningThresholdPercent,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<DriftBudget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('budget_id')) {
      context.handle(
        _budgetIdMeta,
        budgetId.isAcceptableOrUnknown(data['budget_id']!, _budgetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_budgetIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('warning_threshold_percent')) {
      context.handle(
        _warningThresholdPercentMeta,
        warningThresholdPercent.isAcceptableOrUnknown(
          data['warning_threshold_percent']!,
          _warningThresholdPercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_warningThresholdPercentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {budgetId};
  @override
  DriftBudget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftBudget(
      budgetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}budget_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      warningThresholdPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warning_threshold_percent'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class DriftBudget extends DataClass implements Insertable<DriftBudget> {
  final String budgetId;
  final String userId;
  final int month;
  final int year;
  final double amount;
  final String currency;
  final int warningThresholdPercent;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DriftBudget({
    required this.budgetId,
    required this.userId,
    required this.month,
    required this.year,
    required this.amount,
    required this.currency,
    required this.warningThresholdPercent,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['budget_id'] = Variable<String>(budgetId);
    map['user_id'] = Variable<String>(userId);
    map['month'] = Variable<int>(month);
    map['year'] = Variable<int>(year);
    map['amount'] = Variable<double>(amount);
    map['currency'] = Variable<String>(currency);
    map['warning_threshold_percent'] = Variable<int>(warningThresholdPercent);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      budgetId: Value(budgetId),
      userId: Value(userId),
      month: Value(month),
      year: Value(year),
      amount: Value(amount),
      currency: Value(currency),
      warningThresholdPercent: Value(warningThresholdPercent),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DriftBudget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftBudget(
      budgetId: serializer.fromJson<String>(json['budgetId']),
      userId: serializer.fromJson<String>(json['userId']),
      month: serializer.fromJson<int>(json['month']),
      year: serializer.fromJson<int>(json['year']),
      amount: serializer.fromJson<double>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      warningThresholdPercent: serializer.fromJson<int>(
        json['warningThresholdPercent'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'budgetId': serializer.toJson<String>(budgetId),
      'userId': serializer.toJson<String>(userId),
      'month': serializer.toJson<int>(month),
      'year': serializer.toJson<int>(year),
      'amount': serializer.toJson<double>(amount),
      'currency': serializer.toJson<String>(currency),
      'warningThresholdPercent': serializer.toJson<int>(
        warningThresholdPercent,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DriftBudget copyWith({
    String? budgetId,
    String? userId,
    int? month,
    int? year,
    double? amount,
    String? currency,
    int? warningThresholdPercent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DriftBudget(
    budgetId: budgetId ?? this.budgetId,
    userId: userId ?? this.userId,
    month: month ?? this.month,
    year: year ?? this.year,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    warningThresholdPercent:
        warningThresholdPercent ?? this.warningThresholdPercent,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DriftBudget copyWithCompanion(BudgetsCompanion data) {
    return DriftBudget(
      budgetId: data.budgetId.present ? data.budgetId.value : this.budgetId,
      userId: data.userId.present ? data.userId.value : this.userId,
      month: data.month.present ? data.month.value : this.month,
      year: data.year.present ? data.year.value : this.year,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      warningThresholdPercent: data.warningThresholdPercent.present
          ? data.warningThresholdPercent.value
          : this.warningThresholdPercent,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftBudget(')
          ..write('budgetId: $budgetId, ')
          ..write('userId: $userId, ')
          ..write('month: $month, ')
          ..write('year: $year, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('warningThresholdPercent: $warningThresholdPercent, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    budgetId,
    userId,
    month,
    year,
    amount,
    currency,
    warningThresholdPercent,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftBudget &&
          other.budgetId == this.budgetId &&
          other.userId == this.userId &&
          other.month == this.month &&
          other.year == this.year &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.warningThresholdPercent == this.warningThresholdPercent &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BudgetsCompanion extends UpdateCompanion<DriftBudget> {
  final Value<String> budgetId;
  final Value<String> userId;
  final Value<int> month;
  final Value<int> year;
  final Value<double> amount;
  final Value<String> currency;
  final Value<int> warningThresholdPercent;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.budgetId = const Value.absent(),
    this.userId = const Value.absent(),
    this.month = const Value.absent(),
    this.year = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.warningThresholdPercent = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String budgetId,
    required String userId,
    required int month,
    required int year,
    required double amount,
    required String currency,
    required int warningThresholdPercent,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : budgetId = Value(budgetId),
       userId = Value(userId),
       month = Value(month),
       year = Value(year),
       amount = Value(amount),
       currency = Value(currency),
       warningThresholdPercent = Value(warningThresholdPercent),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DriftBudget> custom({
    Expression<String>? budgetId,
    Expression<String>? userId,
    Expression<int>? month,
    Expression<int>? year,
    Expression<double>? amount,
    Expression<String>? currency,
    Expression<int>? warningThresholdPercent,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (budgetId != null) 'budget_id': budgetId,
      if (userId != null) 'user_id': userId,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (warningThresholdPercent != null)
        'warning_threshold_percent': warningThresholdPercent,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith({
    Value<String>? budgetId,
    Value<String>? userId,
    Value<int>? month,
    Value<int>? year,
    Value<double>? amount,
    Value<String>? currency,
    Value<int>? warningThresholdPercent,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return BudgetsCompanion(
      budgetId: budgetId ?? this.budgetId,
      userId: userId ?? this.userId,
      month: month ?? this.month,
      year: year ?? this.year,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      warningThresholdPercent:
          warningThresholdPercent ?? this.warningThresholdPercent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (budgetId.present) {
      map['budget_id'] = Variable<String>(budgetId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (warningThresholdPercent.present) {
      map['warning_threshold_percent'] = Variable<int>(
        warningThresholdPercent.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('budgetId: $budgetId, ')
          ..write('userId: $userId, ')
          ..write('month: $month, ')
          ..write('year: $year, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('warningThresholdPercent: $warningThresholdPercent, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, DriftSettings> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appDisplayNameMeta = const VerificationMeta(
    'appDisplayName',
  );
  @override
  late final GeneratedColumn<String> appDisplayName = GeneratedColumn<String>(
    'app_display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languagePreferenceMeta =
      const VerificationMeta('languagePreference');
  @override
  late final GeneratedColumn<String> languagePreference =
      GeneratedColumn<String>(
        'language_preference',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _baseCurrencyMeta = const VerificationMeta(
    'baseCurrency',
  );
  @override
  late final GeneratedColumn<String> baseCurrency = GeneratedColumn<String>(
    'base_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  supportedCurrencies = GeneratedColumn<String>(
    'supported_currencies',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($SettingsTable.$convertersupportedCurrencies);
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, double>, String>
  conversionRates =
      GeneratedColumn<String>(
        'conversion_rates',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Map<String, double>>(
        $SettingsTable.$converterconversionRates,
      );
  static const VerificationMeta _defaultPaymentMethodMeta =
      const VerificationMeta('defaultPaymentMethod');
  @override
  late final GeneratedColumn<String> defaultPaymentMethod =
      GeneratedColumn<String>(
        'default_payment_method',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  notificationSettings =
      GeneratedColumn<String>(
        'notification_settings',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Map<String, dynamic>>(
        $SettingsTable.$converternotificationSettings,
      );
  static const VerificationMeta _onboardingCompletedMeta =
      const VerificationMeta('onboardingCompleted');
  @override
  late final GeneratedColumn<bool> onboardingCompleted = GeneratedColumn<bool>(
    'onboarding_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_completed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _onboardingVersionMeta = const VerificationMeta(
    'onboardingVersion',
  );
  @override
  late final GeneratedColumn<int> onboardingVersion = GeneratedColumn<int>(
    'onboarding_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _guidedTourCompletedVersionMeta =
      const VerificationMeta('guidedTourCompletedVersion');
  @override
  late final GeneratedColumn<int> guidedTourCompletedVersion =
      GeneratedColumn<int>(
        'guided_tour_completed_version',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _guidedTourSkippedVersionMeta =
      const VerificationMeta('guidedTourSkippedVersion');
  @override
  late final GeneratedColumn<int> guidedTourSkippedVersion =
      GeneratedColumn<int>(
        'guided_tour_skipped_version',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _guidedTourLastStepIdMeta =
      const VerificationMeta('guidedTourLastStepId');
  @override
  late final GeneratedColumn<String> guidedTourLastStepId =
      GeneratedColumn<String>(
        'guided_tour_last_step_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _exchangeRatesUpdatedAtMeta =
      const VerificationMeta('exchangeRatesUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> exchangeRatesUpdatedAt =
      GeneratedColumn<DateTime>(
        'exchange_rates_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    appDisplayName,
    languagePreference,
    baseCurrency,
    supportedCurrencies,
    conversionRates,
    defaultPaymentMethod,
    notificationSettings,
    onboardingCompleted,
    onboardingVersion,
    guidedTourCompletedVersion,
    guidedTourSkippedVersion,
    guidedTourLastStepId,
    exchangeRatesUpdatedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<DriftSettings> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('app_display_name')) {
      context.handle(
        _appDisplayNameMeta,
        appDisplayName.isAcceptableOrUnknown(
          data['app_display_name']!,
          _appDisplayNameMeta,
        ),
      );
    }
    if (data.containsKey('language_preference')) {
      context.handle(
        _languagePreferenceMeta,
        languagePreference.isAcceptableOrUnknown(
          data['language_preference']!,
          _languagePreferenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_languagePreferenceMeta);
    }
    if (data.containsKey('base_currency')) {
      context.handle(
        _baseCurrencyMeta,
        baseCurrency.isAcceptableOrUnknown(
          data['base_currency']!,
          _baseCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseCurrencyMeta);
    }
    if (data.containsKey('default_payment_method')) {
      context.handle(
        _defaultPaymentMethodMeta,
        defaultPaymentMethod.isAcceptableOrUnknown(
          data['default_payment_method']!,
          _defaultPaymentMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultPaymentMethodMeta);
    }
    if (data.containsKey('onboarding_completed')) {
      context.handle(
        _onboardingCompletedMeta,
        onboardingCompleted.isAcceptableOrUnknown(
          data['onboarding_completed']!,
          _onboardingCompletedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_onboardingCompletedMeta);
    }
    if (data.containsKey('onboarding_version')) {
      context.handle(
        _onboardingVersionMeta,
        onboardingVersion.isAcceptableOrUnknown(
          data['onboarding_version']!,
          _onboardingVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_onboardingVersionMeta);
    }
    if (data.containsKey('guided_tour_completed_version')) {
      context.handle(
        _guidedTourCompletedVersionMeta,
        guidedTourCompletedVersion.isAcceptableOrUnknown(
          data['guided_tour_completed_version']!,
          _guidedTourCompletedVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_guidedTourCompletedVersionMeta);
    }
    if (data.containsKey('guided_tour_skipped_version')) {
      context.handle(
        _guidedTourSkippedVersionMeta,
        guidedTourSkippedVersion.isAcceptableOrUnknown(
          data['guided_tour_skipped_version']!,
          _guidedTourSkippedVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_guidedTourSkippedVersionMeta);
    }
    if (data.containsKey('guided_tour_last_step_id')) {
      context.handle(
        _guidedTourLastStepIdMeta,
        guidedTourLastStepId.isAcceptableOrUnknown(
          data['guided_tour_last_step_id']!,
          _guidedTourLastStepIdMeta,
        ),
      );
    }
    if (data.containsKey('exchange_rates_updated_at')) {
      context.handle(
        _exchangeRatesUpdatedAtMeta,
        exchangeRatesUpdatedAt.isAcceptableOrUnknown(
          data['exchange_rates_updated_at']!,
          _exchangeRatesUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  DriftSettings map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftSettings(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      appDisplayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_display_name'],
      ),
      languagePreference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_preference'],
      )!,
      baseCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_currency'],
      )!,
      supportedCurrencies: $SettingsTable.$convertersupportedCurrencies.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}supported_currencies'],
        )!,
      ),
      conversionRates: $SettingsTable.$converterconversionRates.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}conversion_rates'],
        )!,
      ),
      defaultPaymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_payment_method'],
      )!,
      notificationSettings: $SettingsTable.$converternotificationSettings
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}notification_settings'],
            )!,
          ),
      onboardingCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_completed'],
      )!,
      onboardingVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}onboarding_version'],
      )!,
      guidedTourCompletedVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}guided_tour_completed_version'],
      )!,
      guidedTourSkippedVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}guided_tour_skipped_version'],
      )!,
      guidedTourLastStepId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guided_tour_last_step_id'],
      ),
      exchangeRatesUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}exchange_rates_updated_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertersupportedCurrencies =
      const StringListConverter();
  static TypeConverter<Map<String, double>, String> $converterconversionRates =
      const StringDoubleMapConverter();
  static TypeConverter<Map<String, dynamic>, String>
  $converternotificationSettings = const JsonMapConverter();
}

class DriftSettings extends DataClass implements Insertable<DriftSettings> {
  final String userId;
  final String? appDisplayName;
  final String languagePreference;
  final String baseCurrency;
  final List<String> supportedCurrencies;
  final Map<String, double> conversionRates;
  final String defaultPaymentMethod;
  final Map<String, dynamic> notificationSettings;
  final bool onboardingCompleted;
  final int onboardingVersion;
  final int guidedTourCompletedVersion;
  final int guidedTourSkippedVersion;
  final String? guidedTourLastStepId;
  final DateTime? exchangeRatesUpdatedAt;
  final DateTime updatedAt;
  const DriftSettings({
    required this.userId,
    this.appDisplayName,
    required this.languagePreference,
    required this.baseCurrency,
    required this.supportedCurrencies,
    required this.conversionRates,
    required this.defaultPaymentMethod,
    required this.notificationSettings,
    required this.onboardingCompleted,
    required this.onboardingVersion,
    required this.guidedTourCompletedVersion,
    required this.guidedTourSkippedVersion,
    this.guidedTourLastStepId,
    this.exchangeRatesUpdatedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || appDisplayName != null) {
      map['app_display_name'] = Variable<String>(appDisplayName);
    }
    map['language_preference'] = Variable<String>(languagePreference);
    map['base_currency'] = Variable<String>(baseCurrency);
    {
      map['supported_currencies'] = Variable<String>(
        $SettingsTable.$convertersupportedCurrencies.toSql(supportedCurrencies),
      );
    }
    {
      map['conversion_rates'] = Variable<String>(
        $SettingsTable.$converterconversionRates.toSql(conversionRates),
      );
    }
    map['default_payment_method'] = Variable<String>(defaultPaymentMethod);
    {
      map['notification_settings'] = Variable<String>(
        $SettingsTable.$converternotificationSettings.toSql(
          notificationSettings,
        ),
      );
    }
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    map['onboarding_version'] = Variable<int>(onboardingVersion);
    map['guided_tour_completed_version'] = Variable<int>(
      guidedTourCompletedVersion,
    );
    map['guided_tour_skipped_version'] = Variable<int>(
      guidedTourSkippedVersion,
    );
    if (!nullToAbsent || guidedTourLastStepId != null) {
      map['guided_tour_last_step_id'] = Variable<String>(guidedTourLastStepId);
    }
    if (!nullToAbsent || exchangeRatesUpdatedAt != null) {
      map['exchange_rates_updated_at'] = Variable<DateTime>(
        exchangeRatesUpdatedAt,
      );
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      userId: Value(userId),
      appDisplayName: appDisplayName == null && nullToAbsent
          ? const Value.absent()
          : Value(appDisplayName),
      languagePreference: Value(languagePreference),
      baseCurrency: Value(baseCurrency),
      supportedCurrencies: Value(supportedCurrencies),
      conversionRates: Value(conversionRates),
      defaultPaymentMethod: Value(defaultPaymentMethod),
      notificationSettings: Value(notificationSettings),
      onboardingCompleted: Value(onboardingCompleted),
      onboardingVersion: Value(onboardingVersion),
      guidedTourCompletedVersion: Value(guidedTourCompletedVersion),
      guidedTourSkippedVersion: Value(guidedTourSkippedVersion),
      guidedTourLastStepId: guidedTourLastStepId == null && nullToAbsent
          ? const Value.absent()
          : Value(guidedTourLastStepId),
      exchangeRatesUpdatedAt: exchangeRatesUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(exchangeRatesUpdatedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DriftSettings.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftSettings(
      userId: serializer.fromJson<String>(json['userId']),
      appDisplayName: serializer.fromJson<String?>(json['appDisplayName']),
      languagePreference: serializer.fromJson<String>(
        json['languagePreference'],
      ),
      baseCurrency: serializer.fromJson<String>(json['baseCurrency']),
      supportedCurrencies: serializer.fromJson<List<String>>(
        json['supportedCurrencies'],
      ),
      conversionRates: serializer.fromJson<Map<String, double>>(
        json['conversionRates'],
      ),
      defaultPaymentMethod: serializer.fromJson<String>(
        json['defaultPaymentMethod'],
      ),
      notificationSettings: serializer.fromJson<Map<String, dynamic>>(
        json['notificationSettings'],
      ),
      onboardingCompleted: serializer.fromJson<bool>(
        json['onboardingCompleted'],
      ),
      onboardingVersion: serializer.fromJson<int>(json['onboardingVersion']),
      guidedTourCompletedVersion: serializer.fromJson<int>(
        json['guidedTourCompletedVersion'],
      ),
      guidedTourSkippedVersion: serializer.fromJson<int>(
        json['guidedTourSkippedVersion'],
      ),
      guidedTourLastStepId: serializer.fromJson<String?>(
        json['guidedTourLastStepId'],
      ),
      exchangeRatesUpdatedAt: serializer.fromJson<DateTime?>(
        json['exchangeRatesUpdatedAt'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'appDisplayName': serializer.toJson<String?>(appDisplayName),
      'languagePreference': serializer.toJson<String>(languagePreference),
      'baseCurrency': serializer.toJson<String>(baseCurrency),
      'supportedCurrencies': serializer.toJson<List<String>>(
        supportedCurrencies,
      ),
      'conversionRates': serializer.toJson<Map<String, double>>(
        conversionRates,
      ),
      'defaultPaymentMethod': serializer.toJson<String>(defaultPaymentMethod),
      'notificationSettings': serializer.toJson<Map<String, dynamic>>(
        notificationSettings,
      ),
      'onboardingCompleted': serializer.toJson<bool>(onboardingCompleted),
      'onboardingVersion': serializer.toJson<int>(onboardingVersion),
      'guidedTourCompletedVersion': serializer.toJson<int>(
        guidedTourCompletedVersion,
      ),
      'guidedTourSkippedVersion': serializer.toJson<int>(
        guidedTourSkippedVersion,
      ),
      'guidedTourLastStepId': serializer.toJson<String?>(guidedTourLastStepId),
      'exchangeRatesUpdatedAt': serializer.toJson<DateTime?>(
        exchangeRatesUpdatedAt,
      ),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DriftSettings copyWith({
    String? userId,
    Value<String?> appDisplayName = const Value.absent(),
    String? languagePreference,
    String? baseCurrency,
    List<String>? supportedCurrencies,
    Map<String, double>? conversionRates,
    String? defaultPaymentMethod,
    Map<String, dynamic>? notificationSettings,
    bool? onboardingCompleted,
    int? onboardingVersion,
    int? guidedTourCompletedVersion,
    int? guidedTourSkippedVersion,
    Value<String?> guidedTourLastStepId = const Value.absent(),
    Value<DateTime?> exchangeRatesUpdatedAt = const Value.absent(),
    DateTime? updatedAt,
  }) => DriftSettings(
    userId: userId ?? this.userId,
    appDisplayName: appDisplayName.present
        ? appDisplayName.value
        : this.appDisplayName,
    languagePreference: languagePreference ?? this.languagePreference,
    baseCurrency: baseCurrency ?? this.baseCurrency,
    supportedCurrencies: supportedCurrencies ?? this.supportedCurrencies,
    conversionRates: conversionRates ?? this.conversionRates,
    defaultPaymentMethod: defaultPaymentMethod ?? this.defaultPaymentMethod,
    notificationSettings: notificationSettings ?? this.notificationSettings,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    onboardingVersion: onboardingVersion ?? this.onboardingVersion,
    guidedTourCompletedVersion:
        guidedTourCompletedVersion ?? this.guidedTourCompletedVersion,
    guidedTourSkippedVersion:
        guidedTourSkippedVersion ?? this.guidedTourSkippedVersion,
    guidedTourLastStepId: guidedTourLastStepId.present
        ? guidedTourLastStepId.value
        : this.guidedTourLastStepId,
    exchangeRatesUpdatedAt: exchangeRatesUpdatedAt.present
        ? exchangeRatesUpdatedAt.value
        : this.exchangeRatesUpdatedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DriftSettings copyWithCompanion(SettingsCompanion data) {
    return DriftSettings(
      userId: data.userId.present ? data.userId.value : this.userId,
      appDisplayName: data.appDisplayName.present
          ? data.appDisplayName.value
          : this.appDisplayName,
      languagePreference: data.languagePreference.present
          ? data.languagePreference.value
          : this.languagePreference,
      baseCurrency: data.baseCurrency.present
          ? data.baseCurrency.value
          : this.baseCurrency,
      supportedCurrencies: data.supportedCurrencies.present
          ? data.supportedCurrencies.value
          : this.supportedCurrencies,
      conversionRates: data.conversionRates.present
          ? data.conversionRates.value
          : this.conversionRates,
      defaultPaymentMethod: data.defaultPaymentMethod.present
          ? data.defaultPaymentMethod.value
          : this.defaultPaymentMethod,
      notificationSettings: data.notificationSettings.present
          ? data.notificationSettings.value
          : this.notificationSettings,
      onboardingCompleted: data.onboardingCompleted.present
          ? data.onboardingCompleted.value
          : this.onboardingCompleted,
      onboardingVersion: data.onboardingVersion.present
          ? data.onboardingVersion.value
          : this.onboardingVersion,
      guidedTourCompletedVersion: data.guidedTourCompletedVersion.present
          ? data.guidedTourCompletedVersion.value
          : this.guidedTourCompletedVersion,
      guidedTourSkippedVersion: data.guidedTourSkippedVersion.present
          ? data.guidedTourSkippedVersion.value
          : this.guidedTourSkippedVersion,
      guidedTourLastStepId: data.guidedTourLastStepId.present
          ? data.guidedTourLastStepId.value
          : this.guidedTourLastStepId,
      exchangeRatesUpdatedAt: data.exchangeRatesUpdatedAt.present
          ? data.exchangeRatesUpdatedAt.value
          : this.exchangeRatesUpdatedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftSettings(')
          ..write('userId: $userId, ')
          ..write('appDisplayName: $appDisplayName, ')
          ..write('languagePreference: $languagePreference, ')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('supportedCurrencies: $supportedCurrencies, ')
          ..write('conversionRates: $conversionRates, ')
          ..write('defaultPaymentMethod: $defaultPaymentMethod, ')
          ..write('notificationSettings: $notificationSettings, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('onboardingVersion: $onboardingVersion, ')
          ..write('guidedTourCompletedVersion: $guidedTourCompletedVersion, ')
          ..write('guidedTourSkippedVersion: $guidedTourSkippedVersion, ')
          ..write('guidedTourLastStepId: $guidedTourLastStepId, ')
          ..write('exchangeRatesUpdatedAt: $exchangeRatesUpdatedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    appDisplayName,
    languagePreference,
    baseCurrency,
    supportedCurrencies,
    conversionRates,
    defaultPaymentMethod,
    notificationSettings,
    onboardingCompleted,
    onboardingVersion,
    guidedTourCompletedVersion,
    guidedTourSkippedVersion,
    guidedTourLastStepId,
    exchangeRatesUpdatedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftSettings &&
          other.userId == this.userId &&
          other.appDisplayName == this.appDisplayName &&
          other.languagePreference == this.languagePreference &&
          other.baseCurrency == this.baseCurrency &&
          other.supportedCurrencies == this.supportedCurrencies &&
          other.conversionRates == this.conversionRates &&
          other.defaultPaymentMethod == this.defaultPaymentMethod &&
          other.notificationSettings == this.notificationSettings &&
          other.onboardingCompleted == this.onboardingCompleted &&
          other.onboardingVersion == this.onboardingVersion &&
          other.guidedTourCompletedVersion == this.guidedTourCompletedVersion &&
          other.guidedTourSkippedVersion == this.guidedTourSkippedVersion &&
          other.guidedTourLastStepId == this.guidedTourLastStepId &&
          other.exchangeRatesUpdatedAt == this.exchangeRatesUpdatedAt &&
          other.updatedAt == this.updatedAt);
}

class SettingsCompanion extends UpdateCompanion<DriftSettings> {
  final Value<String> userId;
  final Value<String?> appDisplayName;
  final Value<String> languagePreference;
  final Value<String> baseCurrency;
  final Value<List<String>> supportedCurrencies;
  final Value<Map<String, double>> conversionRates;
  final Value<String> defaultPaymentMethod;
  final Value<Map<String, dynamic>> notificationSettings;
  final Value<bool> onboardingCompleted;
  final Value<int> onboardingVersion;
  final Value<int> guidedTourCompletedVersion;
  final Value<int> guidedTourSkippedVersion;
  final Value<String?> guidedTourLastStepId;
  final Value<DateTime?> exchangeRatesUpdatedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SettingsCompanion({
    this.userId = const Value.absent(),
    this.appDisplayName = const Value.absent(),
    this.languagePreference = const Value.absent(),
    this.baseCurrency = const Value.absent(),
    this.supportedCurrencies = const Value.absent(),
    this.conversionRates = const Value.absent(),
    this.defaultPaymentMethod = const Value.absent(),
    this.notificationSettings = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.onboardingVersion = const Value.absent(),
    this.guidedTourCompletedVersion = const Value.absent(),
    this.guidedTourSkippedVersion = const Value.absent(),
    this.guidedTourLastStepId = const Value.absent(),
    this.exchangeRatesUpdatedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String userId,
    this.appDisplayName = const Value.absent(),
    required String languagePreference,
    required String baseCurrency,
    required List<String> supportedCurrencies,
    required Map<String, double> conversionRates,
    required String defaultPaymentMethod,
    required Map<String, dynamic> notificationSettings,
    required bool onboardingCompleted,
    required int onboardingVersion,
    required int guidedTourCompletedVersion,
    required int guidedTourSkippedVersion,
    this.guidedTourLastStepId = const Value.absent(),
    this.exchangeRatesUpdatedAt = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       languagePreference = Value(languagePreference),
       baseCurrency = Value(baseCurrency),
       supportedCurrencies = Value(supportedCurrencies),
       conversionRates = Value(conversionRates),
       defaultPaymentMethod = Value(defaultPaymentMethod),
       notificationSettings = Value(notificationSettings),
       onboardingCompleted = Value(onboardingCompleted),
       onboardingVersion = Value(onboardingVersion),
       guidedTourCompletedVersion = Value(guidedTourCompletedVersion),
       guidedTourSkippedVersion = Value(guidedTourSkippedVersion),
       updatedAt = Value(updatedAt);
  static Insertable<DriftSettings> custom({
    Expression<String>? userId,
    Expression<String>? appDisplayName,
    Expression<String>? languagePreference,
    Expression<String>? baseCurrency,
    Expression<String>? supportedCurrencies,
    Expression<String>? conversionRates,
    Expression<String>? defaultPaymentMethod,
    Expression<String>? notificationSettings,
    Expression<bool>? onboardingCompleted,
    Expression<int>? onboardingVersion,
    Expression<int>? guidedTourCompletedVersion,
    Expression<int>? guidedTourSkippedVersion,
    Expression<String>? guidedTourLastStepId,
    Expression<DateTime>? exchangeRatesUpdatedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (appDisplayName != null) 'app_display_name': appDisplayName,
      if (languagePreference != null) 'language_preference': languagePreference,
      if (baseCurrency != null) 'base_currency': baseCurrency,
      if (supportedCurrencies != null)
        'supported_currencies': supportedCurrencies,
      if (conversionRates != null) 'conversion_rates': conversionRates,
      if (defaultPaymentMethod != null)
        'default_payment_method': defaultPaymentMethod,
      if (notificationSettings != null)
        'notification_settings': notificationSettings,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
      if (onboardingVersion != null) 'onboarding_version': onboardingVersion,
      if (guidedTourCompletedVersion != null)
        'guided_tour_completed_version': guidedTourCompletedVersion,
      if (guidedTourSkippedVersion != null)
        'guided_tour_skipped_version': guidedTourSkippedVersion,
      if (guidedTourLastStepId != null)
        'guided_tour_last_step_id': guidedTourLastStepId,
      if (exchangeRatesUpdatedAt != null)
        'exchange_rates_updated_at': exchangeRatesUpdatedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? userId,
    Value<String?>? appDisplayName,
    Value<String>? languagePreference,
    Value<String>? baseCurrency,
    Value<List<String>>? supportedCurrencies,
    Value<Map<String, double>>? conversionRates,
    Value<String>? defaultPaymentMethod,
    Value<Map<String, dynamic>>? notificationSettings,
    Value<bool>? onboardingCompleted,
    Value<int>? onboardingVersion,
    Value<int>? guidedTourCompletedVersion,
    Value<int>? guidedTourSkippedVersion,
    Value<String?>? guidedTourLastStepId,
    Value<DateTime?>? exchangeRatesUpdatedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      userId: userId ?? this.userId,
      appDisplayName: appDisplayName ?? this.appDisplayName,
      languagePreference: languagePreference ?? this.languagePreference,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      supportedCurrencies: supportedCurrencies ?? this.supportedCurrencies,
      conversionRates: conversionRates ?? this.conversionRates,
      defaultPaymentMethod: defaultPaymentMethod ?? this.defaultPaymentMethod,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      onboardingVersion: onboardingVersion ?? this.onboardingVersion,
      guidedTourCompletedVersion:
          guidedTourCompletedVersion ?? this.guidedTourCompletedVersion,
      guidedTourSkippedVersion:
          guidedTourSkippedVersion ?? this.guidedTourSkippedVersion,
      guidedTourLastStepId: guidedTourLastStepId ?? this.guidedTourLastStepId,
      exchangeRatesUpdatedAt:
          exchangeRatesUpdatedAt ?? this.exchangeRatesUpdatedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (appDisplayName.present) {
      map['app_display_name'] = Variable<String>(appDisplayName.value);
    }
    if (languagePreference.present) {
      map['language_preference'] = Variable<String>(languagePreference.value);
    }
    if (baseCurrency.present) {
      map['base_currency'] = Variable<String>(baseCurrency.value);
    }
    if (supportedCurrencies.present) {
      map['supported_currencies'] = Variable<String>(
        $SettingsTable.$convertersupportedCurrencies.toSql(
          supportedCurrencies.value,
        ),
      );
    }
    if (conversionRates.present) {
      map['conversion_rates'] = Variable<String>(
        $SettingsTable.$converterconversionRates.toSql(conversionRates.value),
      );
    }
    if (defaultPaymentMethod.present) {
      map['default_payment_method'] = Variable<String>(
        defaultPaymentMethod.value,
      );
    }
    if (notificationSettings.present) {
      map['notification_settings'] = Variable<String>(
        $SettingsTable.$converternotificationSettings.toSql(
          notificationSettings.value,
        ),
      );
    }
    if (onboardingCompleted.present) {
      map['onboarding_completed'] = Variable<bool>(onboardingCompleted.value);
    }
    if (onboardingVersion.present) {
      map['onboarding_version'] = Variable<int>(onboardingVersion.value);
    }
    if (guidedTourCompletedVersion.present) {
      map['guided_tour_completed_version'] = Variable<int>(
        guidedTourCompletedVersion.value,
      );
    }
    if (guidedTourSkippedVersion.present) {
      map['guided_tour_skipped_version'] = Variable<int>(
        guidedTourSkippedVersion.value,
      );
    }
    if (guidedTourLastStepId.present) {
      map['guided_tour_last_step_id'] = Variable<String>(
        guidedTourLastStepId.value,
      );
    }
    if (exchangeRatesUpdatedAt.present) {
      map['exchange_rates_updated_at'] = Variable<DateTime>(
        exchangeRatesUpdatedAt.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('userId: $userId, ')
          ..write('appDisplayName: $appDisplayName, ')
          ..write('languagePreference: $languagePreference, ')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('supportedCurrencies: $supportedCurrencies, ')
          ..write('conversionRates: $conversionRates, ')
          ..write('defaultPaymentMethod: $defaultPaymentMethod, ')
          ..write('notificationSettings: $notificationSettings, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('onboardingVersion: $onboardingVersion, ')
          ..write('guidedTourCompletedVersion: $guidedTourCompletedVersion, ')
          ..write('guidedTourSkippedVersion: $guidedTourSkippedVersion, ')
          ..write('guidedTourLastStepId: $guidedTourLastStepId, ')
          ..write('exchangeRatesUpdatedAt: $exchangeRatesUpdatedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, DriftSavingGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<String> goalId = GeneratedColumn<String>(
    'goal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetAmountMeta = const VerificationMeta(
    'targetAmount',
  );
  @override
  late final GeneratedColumn<double> targetAmount = GeneratedColumn<double>(
    'target_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentAmountMeta = const VerificationMeta(
    'currentAmount',
  );
  @override
  late final GeneratedColumn<double> currentAmount = GeneratedColumn<double>(
    'current_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
    'deadline',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    goalId,
    userId,
    name,
    targetAmount,
    currentAmount,
    currency,
    deadline,
    color,
    isArchived,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<DriftSavingGoal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('goal_id')) {
      context.handle(
        _goalIdMeta,
        goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_amount')) {
      context.handle(
        _targetAmountMeta,
        targetAmount.isAcceptableOrUnknown(
          data['target_amount']!,
          _targetAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('current_amount')) {
      context.handle(
        _currentAmountMeta,
        currentAmount.isAcceptableOrUnknown(
          data['current_amount']!,
          _currentAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentAmountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    } else if (isInserting) {
      context.missing(_isArchivedMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {goalId};
  @override
  DriftSavingGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftSavingGoal(
      goalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      targetAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_amount'],
      )!,
      currentAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_amount'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class DriftSavingGoal extends DataClass implements Insertable<DriftSavingGoal> {
  final String goalId;
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String currency;
  final DateTime? deadline;
  final int color;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DriftSavingGoal({
    required this.goalId,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.currency,
    this.deadline,
    required this.color,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['goal_id'] = Variable<String>(goalId);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['target_amount'] = Variable<double>(targetAmount);
    map['current_amount'] = Variable<double>(currentAmount);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    map['color'] = Variable<int>(color);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      goalId: Value(goalId),
      userId: Value(userId),
      name: Value(name),
      targetAmount: Value(targetAmount),
      currentAmount: Value(currentAmount),
      currency: Value(currency),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      color: Value(color),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DriftSavingGoal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftSavingGoal(
      goalId: serializer.fromJson<String>(json['goalId']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      targetAmount: serializer.fromJson<double>(json['targetAmount']),
      currentAmount: serializer.fromJson<double>(json['currentAmount']),
      currency: serializer.fromJson<String>(json['currency']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      color: serializer.fromJson<int>(json['color']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'goalId': serializer.toJson<String>(goalId),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'targetAmount': serializer.toJson<double>(targetAmount),
      'currentAmount': serializer.toJson<double>(currentAmount),
      'currency': serializer.toJson<String>(currency),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'color': serializer.toJson<int>(color),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DriftSavingGoal copyWith({
    String? goalId,
    String? userId,
    String? name,
    double? targetAmount,
    double? currentAmount,
    String? currency,
    Value<DateTime?> deadline = const Value.absent(),
    int? color,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DriftSavingGoal(
    goalId: goalId ?? this.goalId,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    targetAmount: targetAmount ?? this.targetAmount,
    currentAmount: currentAmount ?? this.currentAmount,
    currency: currency ?? this.currency,
    deadline: deadline.present ? deadline.value : this.deadline,
    color: color ?? this.color,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DriftSavingGoal copyWithCompanion(GoalsCompanion data) {
    return DriftSavingGoal(
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      currentAmount: data.currentAmount.present
          ? data.currentAmount.value
          : this.currentAmount,
      currency: data.currency.present ? data.currency.value : this.currency,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      color: data.color.present ? data.color.value : this.color,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftSavingGoal(')
          ..write('goalId: $goalId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('currency: $currency, ')
          ..write('deadline: $deadline, ')
          ..write('color: $color, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    goalId,
    userId,
    name,
    targetAmount,
    currentAmount,
    currency,
    deadline,
    color,
    isArchived,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftSavingGoal &&
          other.goalId == this.goalId &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.targetAmount == this.targetAmount &&
          other.currentAmount == this.currentAmount &&
          other.currency == this.currency &&
          other.deadline == this.deadline &&
          other.color == this.color &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GoalsCompanion extends UpdateCompanion<DriftSavingGoal> {
  final Value<String> goalId;
  final Value<String> userId;
  final Value<String> name;
  final Value<double> targetAmount;
  final Value<double> currentAmount;
  final Value<String> currency;
  final Value<DateTime?> deadline;
  final Value<int> color;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const GoalsCompanion({
    this.goalId = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.currentAmount = const Value.absent(),
    this.currency = const Value.absent(),
    this.deadline = const Value.absent(),
    this.color = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalsCompanion.insert({
    required String goalId,
    required String userId,
    required String name,
    required double targetAmount,
    required double currentAmount,
    required String currency,
    this.deadline = const Value.absent(),
    required int color,
    required bool isArchived,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : goalId = Value(goalId),
       userId = Value(userId),
       name = Value(name),
       targetAmount = Value(targetAmount),
       currentAmount = Value(currentAmount),
       currency = Value(currency),
       color = Value(color),
       isArchived = Value(isArchived),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DriftSavingGoal> custom({
    Expression<String>? goalId,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<double>? targetAmount,
    Expression<double>? currentAmount,
    Expression<String>? currency,
    Expression<DateTime>? deadline,
    Expression<int>? color,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (goalId != null) 'goal_id': goalId,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (currentAmount != null) 'current_amount': currentAmount,
      if (currency != null) 'currency': currency,
      if (deadline != null) 'deadline': deadline,
      if (color != null) 'color': color,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalsCompanion copyWith({
    Value<String>? goalId,
    Value<String>? userId,
    Value<String>? name,
    Value<double>? targetAmount,
    Value<double>? currentAmount,
    Value<String>? currency,
    Value<DateTime?>? deadline,
    Value<int>? color,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return GoalsCompanion(
      goalId: goalId ?? this.goalId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      currency: currency ?? this.currency,
      deadline: deadline ?? this.deadline,
      color: color ?? this.color,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (goalId.present) {
      map['goal_id'] = Variable<String>(goalId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<double>(targetAmount.value);
    }
    if (currentAmount.present) {
      map['current_amount'] = Variable<double>(currentAmount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('goalId: $goalId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('currency: $currency, ')
          ..write('deadline: $deadline, ')
          ..write('color: $color, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WalletsTable extends Wallets with TableInfo<$WalletsTable, DriftWallet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _walletIdMeta = const VerificationMeta(
    'walletId',
  );
  @override
  late final GeneratedColumn<String> walletId = GeneratedColumn<String>(
    'wallet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    walletId,
    userId,
    name,
    type,
    balance,
    currency,
    icon,
    color,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallets';
  @override
  VerificationContext validateIntegrity(
    Insertable<DriftWallet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('wallet_id')) {
      context.handle(
        _walletIdMeta,
        walletId.isAcceptableOrUnknown(data['wallet_id']!, _walletIdMeta),
      );
    } else if (isInserting) {
      context.missing(_walletIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    } else if (isInserting) {
      context.missing(_balanceMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {walletId};
  @override
  DriftWallet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftWallet(
      walletId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wallet_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WalletsTable createAlias(String alias) {
    return $WalletsTable(attachedDatabase, alias);
  }
}

class DriftWallet extends DataClass implements Insertable<DriftWallet> {
  final String walletId;
  final String userId;
  final String name;
  final String type;
  final double balance;
  final String currency;
  final String icon;
  final int color;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DriftWallet({
    required this.walletId,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    required this.icon,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['wallet_id'] = Variable<String>(walletId);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['balance'] = Variable<double>(balance);
    map['currency'] = Variable<String>(currency);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<int>(color);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WalletsCompanion toCompanion(bool nullToAbsent) {
    return WalletsCompanion(
      walletId: Value(walletId),
      userId: Value(userId),
      name: Value(name),
      type: Value(type),
      balance: Value(balance),
      currency: Value(currency),
      icon: Value(icon),
      color: Value(color),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DriftWallet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftWallet(
      walletId: serializer.fromJson<String>(json['walletId']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      balance: serializer.fromJson<double>(json['balance']),
      currency: serializer.fromJson<String>(json['currency']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<int>(json['color']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'walletId': serializer.toJson<String>(walletId),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'balance': serializer.toJson<double>(balance),
      'currency': serializer.toJson<String>(currency),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<int>(color),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DriftWallet copyWith({
    String? walletId,
    String? userId,
    String? name,
    String? type,
    double? balance,
    String? currency,
    String? icon,
    int? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DriftWallet(
    walletId: walletId ?? this.walletId,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    type: type ?? this.type,
    balance: balance ?? this.balance,
    currency: currency ?? this.currency,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DriftWallet copyWithCompanion(WalletsCompanion data) {
    return DriftWallet(
      walletId: data.walletId.present ? data.walletId.value : this.walletId,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      balance: data.balance.present ? data.balance.value : this.balance,
      currency: data.currency.present ? data.currency.value : this.currency,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftWallet(')
          ..write('walletId: $walletId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('balance: $balance, ')
          ..write('currency: $currency, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    walletId,
    userId,
    name,
    type,
    balance,
    currency,
    icon,
    color,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftWallet &&
          other.walletId == this.walletId &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.type == this.type &&
          other.balance == this.balance &&
          other.currency == this.currency &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WalletsCompanion extends UpdateCompanion<DriftWallet> {
  final Value<String> walletId;
  final Value<String> userId;
  final Value<String> name;
  final Value<String> type;
  final Value<double> balance;
  final Value<String> currency;
  final Value<String> icon;
  final Value<int> color;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WalletsCompanion({
    this.walletId = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.balance = const Value.absent(),
    this.currency = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletsCompanion.insert({
    required String walletId,
    required String userId,
    required String name,
    required String type,
    required double balance,
    required String currency,
    required String icon,
    required int color,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : walletId = Value(walletId),
       userId = Value(userId),
       name = Value(name),
       type = Value(type),
       balance = Value(balance),
       currency = Value(currency),
       icon = Value(icon),
       color = Value(color),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DriftWallet> custom({
    Expression<String>? walletId,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<double>? balance,
    Expression<String>? currency,
    Expression<String>? icon,
    Expression<int>? color,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (walletId != null) 'wallet_id': walletId,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (balance != null) 'balance': balance,
      if (currency != null) 'currency': currency,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletsCompanion copyWith({
    Value<String>? walletId,
    Value<String>? userId,
    Value<String>? name,
    Value<String>? type,
    Value<double>? balance,
    Value<String>? currency,
    Value<String>? icon,
    Value<int>? color,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WalletsCompanion(
      walletId: walletId ?? this.walletId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (walletId.present) {
      map['wallet_id'] = Variable<String>(walletId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletsCompanion(')
          ..write('walletId: $walletId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('balance: $balance, ')
          ..write('currency: $currency, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransfersTable extends Transfers
    with TableInfo<$TransfersTable, DriftTransfer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransfersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _transferIdMeta = const VerificationMeta(
    'transferId',
  );
  @override
  late final GeneratedColumn<String> transferId = GeneratedColumn<String>(
    'transfer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromWalletIdMeta = const VerificationMeta(
    'fromWalletId',
  );
  @override
  late final GeneratedColumn<String> fromWalletId = GeneratedColumn<String>(
    'from_wallet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toWalletIdMeta = const VerificationMeta(
    'toWalletId',
  );
  @override
  late final GeneratedColumn<String> toWalletId = GeneratedColumn<String>(
    'to_wallet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    transferId,
    userId,
    fromWalletId,
    toWalletId,
    amount,
    note,
    date,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transfers';
  @override
  VerificationContext validateIntegrity(
    Insertable<DriftTransfer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('transfer_id')) {
      context.handle(
        _transferIdMeta,
        transferId.isAcceptableOrUnknown(data['transfer_id']!, _transferIdMeta),
      );
    } else if (isInserting) {
      context.missing(_transferIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('from_wallet_id')) {
      context.handle(
        _fromWalletIdMeta,
        fromWalletId.isAcceptableOrUnknown(
          data['from_wallet_id']!,
          _fromWalletIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromWalletIdMeta);
    }
    if (data.containsKey('to_wallet_id')) {
      context.handle(
        _toWalletIdMeta,
        toWalletId.isAcceptableOrUnknown(
          data['to_wallet_id']!,
          _toWalletIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_toWalletIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {transferId};
  @override
  DriftTransfer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftTransfer(
      transferId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transfer_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      fromWalletId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_wallet_id'],
      )!,
      toWalletId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_wallet_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TransfersTable createAlias(String alias) {
    return $TransfersTable(attachedDatabase, alias);
  }
}

class DriftTransfer extends DataClass implements Insertable<DriftTransfer> {
  final String transferId;
  final String userId;
  final String fromWalletId;
  final String toWalletId;
  final double amount;
  final String? note;
  final DateTime date;
  final DateTime createdAt;
  const DriftTransfer({
    required this.transferId,
    required this.userId,
    required this.fromWalletId,
    required this.toWalletId,
    required this.amount,
    this.note,
    required this.date,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['transfer_id'] = Variable<String>(transferId);
    map['user_id'] = Variable<String>(userId);
    map['from_wallet_id'] = Variable<String>(fromWalletId);
    map['to_wallet_id'] = Variable<String>(toWalletId);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['date'] = Variable<DateTime>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TransfersCompanion toCompanion(bool nullToAbsent) {
    return TransfersCompanion(
      transferId: Value(transferId),
      userId: Value(userId),
      fromWalletId: Value(fromWalletId),
      toWalletId: Value(toWalletId),
      amount: Value(amount),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      date: Value(date),
      createdAt: Value(createdAt),
    );
  }

  factory DriftTransfer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftTransfer(
      transferId: serializer.fromJson<String>(json['transferId']),
      userId: serializer.fromJson<String>(json['userId']),
      fromWalletId: serializer.fromJson<String>(json['fromWalletId']),
      toWalletId: serializer.fromJson<String>(json['toWalletId']),
      amount: serializer.fromJson<double>(json['amount']),
      note: serializer.fromJson<String?>(json['note']),
      date: serializer.fromJson<DateTime>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'transferId': serializer.toJson<String>(transferId),
      'userId': serializer.toJson<String>(userId),
      'fromWalletId': serializer.toJson<String>(fromWalletId),
      'toWalletId': serializer.toJson<String>(toWalletId),
      'amount': serializer.toJson<double>(amount),
      'note': serializer.toJson<String?>(note),
      'date': serializer.toJson<DateTime>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DriftTransfer copyWith({
    String? transferId,
    String? userId,
    String? fromWalletId,
    String? toWalletId,
    double? amount,
    Value<String?> note = const Value.absent(),
    DateTime? date,
    DateTime? createdAt,
  }) => DriftTransfer(
    transferId: transferId ?? this.transferId,
    userId: userId ?? this.userId,
    fromWalletId: fromWalletId ?? this.fromWalletId,
    toWalletId: toWalletId ?? this.toWalletId,
    amount: amount ?? this.amount,
    note: note.present ? note.value : this.note,
    date: date ?? this.date,
    createdAt: createdAt ?? this.createdAt,
  );
  DriftTransfer copyWithCompanion(TransfersCompanion data) {
    return DriftTransfer(
      transferId: data.transferId.present
          ? data.transferId.value
          : this.transferId,
      userId: data.userId.present ? data.userId.value : this.userId,
      fromWalletId: data.fromWalletId.present
          ? data.fromWalletId.value
          : this.fromWalletId,
      toWalletId: data.toWalletId.present
          ? data.toWalletId.value
          : this.toWalletId,
      amount: data.amount.present ? data.amount.value : this.amount,
      note: data.note.present ? data.note.value : this.note,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftTransfer(')
          ..write('transferId: $transferId, ')
          ..write('userId: $userId, ')
          ..write('fromWalletId: $fromWalletId, ')
          ..write('toWalletId: $toWalletId, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    transferId,
    userId,
    fromWalletId,
    toWalletId,
    amount,
    note,
    date,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftTransfer &&
          other.transferId == this.transferId &&
          other.userId == this.userId &&
          other.fromWalletId == this.fromWalletId &&
          other.toWalletId == this.toWalletId &&
          other.amount == this.amount &&
          other.note == this.note &&
          other.date == this.date &&
          other.createdAt == this.createdAt);
}

class TransfersCompanion extends UpdateCompanion<DriftTransfer> {
  final Value<String> transferId;
  final Value<String> userId;
  final Value<String> fromWalletId;
  final Value<String> toWalletId;
  final Value<double> amount;
  final Value<String?> note;
  final Value<DateTime> date;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TransfersCompanion({
    this.transferId = const Value.absent(),
    this.userId = const Value.absent(),
    this.fromWalletId = const Value.absent(),
    this.toWalletId = const Value.absent(),
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransfersCompanion.insert({
    required String transferId,
    required String userId,
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    this.note = const Value.absent(),
    required DateTime date,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : transferId = Value(transferId),
       userId = Value(userId),
       fromWalletId = Value(fromWalletId),
       toWalletId = Value(toWalletId),
       amount = Value(amount),
       date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<DriftTransfer> custom({
    Expression<String>? transferId,
    Expression<String>? userId,
    Expression<String>? fromWalletId,
    Expression<String>? toWalletId,
    Expression<double>? amount,
    Expression<String>? note,
    Expression<DateTime>? date,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (transferId != null) 'transfer_id': transferId,
      if (userId != null) 'user_id': userId,
      if (fromWalletId != null) 'from_wallet_id': fromWalletId,
      if (toWalletId != null) 'to_wallet_id': toWalletId,
      if (amount != null) 'amount': amount,
      if (note != null) 'note': note,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransfersCompanion copyWith({
    Value<String>? transferId,
    Value<String>? userId,
    Value<String>? fromWalletId,
    Value<String>? toWalletId,
    Value<double>? amount,
    Value<String?>? note,
    Value<DateTime>? date,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TransfersCompanion(
      transferId: transferId ?? this.transferId,
      userId: userId ?? this.userId,
      fromWalletId: fromWalletId ?? this.fromWalletId,
      toWalletId: toWalletId ?? this.toWalletId,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (transferId.present) {
      map['transfer_id'] = Variable<String>(transferId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (fromWalletId.present) {
      map['from_wallet_id'] = Variable<String>(fromWalletId.value);
    }
    if (toWalletId.present) {
      map['to_wallet_id'] = Variable<String>(toWalletId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransfersCompanion(')
          ..write('transferId: $transferId, ')
          ..write('userId: $userId, ')
          ..write('fromWalletId: $fromWalletId, ')
          ..write('toWalletId: $toWalletId, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoryBudgetsTable extends CategoryBudgets
    with TableInfo<$CategoryBudgetsTable, DriftCategoryBudget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryBudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _budgetIdMeta = const VerificationMeta(
    'budgetId',
  );
  @override
  late final GeneratedColumn<String> budgetId = GeneratedColumn<String>(
    'budget_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    budgetId,
    userId,
    categoryId,
    amount,
    month,
    year,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<DriftCategoryBudget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('budget_id')) {
      context.handle(
        _budgetIdMeta,
        budgetId.isAcceptableOrUnknown(data['budget_id']!, _budgetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_budgetIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {budgetId};
  @override
  DriftCategoryBudget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftCategoryBudget(
      budgetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}budget_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CategoryBudgetsTable createAlias(String alias) {
    return $CategoryBudgetsTable(attachedDatabase, alias);
  }
}

class DriftCategoryBudget extends DataClass
    implements Insertable<DriftCategoryBudget> {
  final String budgetId;
  final String userId;
  final String categoryId;
  final double amount;
  final int month;
  final int year;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DriftCategoryBudget({
    required this.budgetId,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.month,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['budget_id'] = Variable<String>(budgetId);
    map['user_id'] = Variable<String>(userId);
    map['category_id'] = Variable<String>(categoryId);
    map['amount'] = Variable<double>(amount);
    map['month'] = Variable<int>(month);
    map['year'] = Variable<int>(year);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CategoryBudgetsCompanion toCompanion(bool nullToAbsent) {
    return CategoryBudgetsCompanion(
      budgetId: Value(budgetId),
      userId: Value(userId),
      categoryId: Value(categoryId),
      amount: Value(amount),
      month: Value(month),
      year: Value(year),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DriftCategoryBudget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftCategoryBudget(
      budgetId: serializer.fromJson<String>(json['budgetId']),
      userId: serializer.fromJson<String>(json['userId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      amount: serializer.fromJson<double>(json['amount']),
      month: serializer.fromJson<int>(json['month']),
      year: serializer.fromJson<int>(json['year']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'budgetId': serializer.toJson<String>(budgetId),
      'userId': serializer.toJson<String>(userId),
      'categoryId': serializer.toJson<String>(categoryId),
      'amount': serializer.toJson<double>(amount),
      'month': serializer.toJson<int>(month),
      'year': serializer.toJson<int>(year),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DriftCategoryBudget copyWith({
    String? budgetId,
    String? userId,
    String? categoryId,
    double? amount,
    int? month,
    int? year,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DriftCategoryBudget(
    budgetId: budgetId ?? this.budgetId,
    userId: userId ?? this.userId,
    categoryId: categoryId ?? this.categoryId,
    amount: amount ?? this.amount,
    month: month ?? this.month,
    year: year ?? this.year,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DriftCategoryBudget copyWithCompanion(CategoryBudgetsCompanion data) {
    return DriftCategoryBudget(
      budgetId: data.budgetId.present ? data.budgetId.value : this.budgetId,
      userId: data.userId.present ? data.userId.value : this.userId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      amount: data.amount.present ? data.amount.value : this.amount,
      month: data.month.present ? data.month.value : this.month,
      year: data.year.present ? data.year.value : this.year,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftCategoryBudget(')
          ..write('budgetId: $budgetId, ')
          ..write('userId: $userId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('month: $month, ')
          ..write('year: $year, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    budgetId,
    userId,
    categoryId,
    amount,
    month,
    year,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftCategoryBudget &&
          other.budgetId == this.budgetId &&
          other.userId == this.userId &&
          other.categoryId == this.categoryId &&
          other.amount == this.amount &&
          other.month == this.month &&
          other.year == this.year &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CategoryBudgetsCompanion extends UpdateCompanion<DriftCategoryBudget> {
  final Value<String> budgetId;
  final Value<String> userId;
  final Value<String> categoryId;
  final Value<double> amount;
  final Value<int> month;
  final Value<int> year;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CategoryBudgetsCompanion({
    this.budgetId = const Value.absent(),
    this.userId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amount = const Value.absent(),
    this.month = const Value.absent(),
    this.year = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryBudgetsCompanion.insert({
    required String budgetId,
    required String userId,
    required String categoryId,
    required double amount,
    required int month,
    required int year,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : budgetId = Value(budgetId),
       userId = Value(userId),
       categoryId = Value(categoryId),
       amount = Value(amount),
       month = Value(month),
       year = Value(year),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DriftCategoryBudget> custom({
    Expression<String>? budgetId,
    Expression<String>? userId,
    Expression<String>? categoryId,
    Expression<double>? amount,
    Expression<int>? month,
    Expression<int>? year,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (budgetId != null) 'budget_id': budgetId,
      if (userId != null) 'user_id': userId,
      if (categoryId != null) 'category_id': categoryId,
      if (amount != null) 'amount': amount,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryBudgetsCompanion copyWith({
    Value<String>? budgetId,
    Value<String>? userId,
    Value<String>? categoryId,
    Value<double>? amount,
    Value<int>? month,
    Value<int>? year,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CategoryBudgetsCompanion(
      budgetId: budgetId ?? this.budgetId,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (budgetId.present) {
      map['budget_id'] = Variable<String>(budgetId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryBudgetsCompanion(')
          ..write('budgetId: $budgetId, ')
          ..write('userId: $userId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('month: $month, ')
          ..write('year: $year, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoryAliasesTable extends CategoryAliases
    with TableInfo<$CategoryAliasesTable, DriftCategoryAlias> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryAliasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _aliasIdMeta = const VerificationMeta(
    'aliasId',
  );
  @override
  late final GeneratedColumn<String> aliasId = GeneratedColumn<String>(
    'alias_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    aliasId,
    userId,
    name,
    categoryId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_aliases';
  @override
  VerificationContext validateIntegrity(
    Insertable<DriftCategoryAlias> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('alias_id')) {
      context.handle(
        _aliasIdMeta,
        aliasId.isAcceptableOrUnknown(data['alias_id']!, _aliasIdMeta),
      );
    } else if (isInserting) {
      context.missing(_aliasIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {aliasId};
  @override
  DriftCategoryAlias map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftCategoryAlias(
      aliasId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CategoryAliasesTable createAlias(String alias) {
    return $CategoryAliasesTable(attachedDatabase, alias);
  }
}

class DriftCategoryAlias extends DataClass
    implements Insertable<DriftCategoryAlias> {
  final String aliasId;
  final String userId;
  final String name;
  final String categoryId;
  final DateTime createdAt;
  const DriftCategoryAlias({
    required this.aliasId,
    required this.userId,
    required this.name,
    required this.categoryId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['alias_id'] = Variable<String>(aliasId);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['category_id'] = Variable<String>(categoryId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CategoryAliasesCompanion toCompanion(bool nullToAbsent) {
    return CategoryAliasesCompanion(
      aliasId: Value(aliasId),
      userId: Value(userId),
      name: Value(name),
      categoryId: Value(categoryId),
      createdAt: Value(createdAt),
    );
  }

  factory DriftCategoryAlias.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftCategoryAlias(
      aliasId: serializer.fromJson<String>(json['aliasId']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'aliasId': serializer.toJson<String>(aliasId),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'categoryId': serializer.toJson<String>(categoryId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DriftCategoryAlias copyWith({
    String? aliasId,
    String? userId,
    String? name,
    String? categoryId,
    DateTime? createdAt,
  }) => DriftCategoryAlias(
    aliasId: aliasId ?? this.aliasId,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    categoryId: categoryId ?? this.categoryId,
    createdAt: createdAt ?? this.createdAt,
  );
  DriftCategoryAlias copyWithCompanion(CategoryAliasesCompanion data) {
    return DriftCategoryAlias(
      aliasId: data.aliasId.present ? data.aliasId.value : this.aliasId,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftCategoryAlias(')
          ..write('aliasId: $aliasId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(aliasId, userId, name, categoryId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftCategoryAlias &&
          other.aliasId == this.aliasId &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.categoryId == this.categoryId &&
          other.createdAt == this.createdAt);
}

class CategoryAliasesCompanion extends UpdateCompanion<DriftCategoryAlias> {
  final Value<String> aliasId;
  final Value<String> userId;
  final Value<String> name;
  final Value<String> categoryId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CategoryAliasesCompanion({
    this.aliasId = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryAliasesCompanion.insert({
    required String aliasId,
    required String userId,
    required String name,
    required String categoryId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : aliasId = Value(aliasId),
       userId = Value(userId),
       name = Value(name),
       categoryId = Value(categoryId),
       createdAt = Value(createdAt);
  static Insertable<DriftCategoryAlias> custom({
    Expression<String>? aliasId,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? categoryId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (aliasId != null) 'alias_id': aliasId,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (categoryId != null) 'category_id': categoryId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryAliasesCompanion copyWith({
    Value<String>? aliasId,
    Value<String>? userId,
    Value<String>? name,
    Value<String>? categoryId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CategoryAliasesCompanion(
      aliasId: aliasId ?? this.aliasId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (aliasId.present) {
      map['alias_id'] = Variable<String>(aliasId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryAliasesCompanion(')
          ..write('aliasId: $aliasId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringExpensesTable extends RecurringExpenses
    with TableInfo<$RecurringExpensesTable, DriftRecurringExpense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _recurringExpenseIdMeta =
      const VerificationMeta('recurringExpenseId');
  @override
  late final GeneratedColumn<String> recurringExpenseId =
      GeneratedColumn<String>(
        'recurring_expense_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastGeneratedDateMeta = const VerificationMeta(
    'lastGeneratedDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastGeneratedDate =
      GeneratedColumn<DateTime>(
        'last_generated_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    recurringExpenseId,
    userId,
    name,
    amount,
    currency,
    categoryId,
    frequency,
    startDate,
    endDate,
    lastGeneratedDate,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<DriftRecurringExpense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('recurring_expense_id')) {
      context.handle(
        _recurringExpenseIdMeta,
        recurringExpenseId.isAcceptableOrUnknown(
          data['recurring_expense_id']!,
          _recurringExpenseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recurringExpenseIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('last_generated_date')) {
      context.handle(
        _lastGeneratedDateMeta,
        lastGeneratedDate.isAcceptableOrUnknown(
          data['last_generated_date']!,
          _lastGeneratedDateMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {recurringExpenseId};
  @override
  DriftRecurringExpense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftRecurringExpense(
      recurringExpenseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurring_expense_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      lastGeneratedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_generated_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RecurringExpensesTable createAlias(String alias) {
    return $RecurringExpensesTable(attachedDatabase, alias);
  }
}

class DriftRecurringExpense extends DataClass
    implements Insertable<DriftRecurringExpense> {
  final String recurringExpenseId;
  final String userId;
  final String name;
  final double amount;
  final String currency;
  final String categoryId;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? lastGeneratedDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DriftRecurringExpense({
    required this.recurringExpenseId,
    required this.userId,
    required this.name,
    required this.amount,
    required this.currency,
    required this.categoryId,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.lastGeneratedDate,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['recurring_expense_id'] = Variable<String>(recurringExpenseId);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<double>(amount);
    map['currency'] = Variable<String>(currency);
    map['category_id'] = Variable<String>(categoryId);
    map['frequency'] = Variable<String>(frequency);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || lastGeneratedDate != null) {
      map['last_generated_date'] = Variable<DateTime>(lastGeneratedDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RecurringExpensesCompanion toCompanion(bool nullToAbsent) {
    return RecurringExpensesCompanion(
      recurringExpenseId: Value(recurringExpenseId),
      userId: Value(userId),
      name: Value(name),
      amount: Value(amount),
      currency: Value(currency),
      categoryId: Value(categoryId),
      frequency: Value(frequency),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      lastGeneratedDate: lastGeneratedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastGeneratedDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DriftRecurringExpense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftRecurringExpense(
      recurringExpenseId: serializer.fromJson<String>(
        json['recurringExpenseId'],
      ),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      frequency: serializer.fromJson<String>(json['frequency']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      lastGeneratedDate: serializer.fromJson<DateTime?>(
        json['lastGeneratedDate'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'recurringExpenseId': serializer.toJson<String>(recurringExpenseId),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<double>(amount),
      'currency': serializer.toJson<String>(currency),
      'categoryId': serializer.toJson<String>(categoryId),
      'frequency': serializer.toJson<String>(frequency),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'lastGeneratedDate': serializer.toJson<DateTime?>(lastGeneratedDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DriftRecurringExpense copyWith({
    String? recurringExpenseId,
    String? userId,
    String? name,
    double? amount,
    String? currency,
    String? categoryId,
    String? frequency,
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
    Value<DateTime?> lastGeneratedDate = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DriftRecurringExpense(
    recurringExpenseId: recurringExpenseId ?? this.recurringExpenseId,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    categoryId: categoryId ?? this.categoryId,
    frequency: frequency ?? this.frequency,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    lastGeneratedDate: lastGeneratedDate.present
        ? lastGeneratedDate.value
        : this.lastGeneratedDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DriftRecurringExpense copyWithCompanion(RecurringExpensesCompanion data) {
    return DriftRecurringExpense(
      recurringExpenseId: data.recurringExpenseId.present
          ? data.recurringExpenseId.value
          : this.recurringExpenseId,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      lastGeneratedDate: data.lastGeneratedDate.present
          ? data.lastGeneratedDate.value
          : this.lastGeneratedDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftRecurringExpense(')
          ..write('recurringExpenseId: $recurringExpenseId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('categoryId: $categoryId, ')
          ..write('frequency: $frequency, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('lastGeneratedDate: $lastGeneratedDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    recurringExpenseId,
    userId,
    name,
    amount,
    currency,
    categoryId,
    frequency,
    startDate,
    endDate,
    lastGeneratedDate,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftRecurringExpense &&
          other.recurringExpenseId == this.recurringExpenseId &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.categoryId == this.categoryId &&
          other.frequency == this.frequency &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.lastGeneratedDate == this.lastGeneratedDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RecurringExpensesCompanion
    extends UpdateCompanion<DriftRecurringExpense> {
  final Value<String> recurringExpenseId;
  final Value<String> userId;
  final Value<String> name;
  final Value<double> amount;
  final Value<String> currency;
  final Value<String> categoryId;
  final Value<String> frequency;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<DateTime?> lastGeneratedDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RecurringExpensesCompanion({
    this.recurringExpenseId = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.frequency = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.lastGeneratedDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringExpensesCompanion.insert({
    required String recurringExpenseId,
    required String userId,
    required String name,
    required double amount,
    required String currency,
    required String categoryId,
    required String frequency,
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.lastGeneratedDate = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : recurringExpenseId = Value(recurringExpenseId),
       userId = Value(userId),
       name = Value(name),
       amount = Value(amount),
       currency = Value(currency),
       categoryId = Value(categoryId),
       frequency = Value(frequency),
       startDate = Value(startDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DriftRecurringExpense> custom({
    Expression<String>? recurringExpenseId,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<double>? amount,
    Expression<String>? currency,
    Expression<String>? categoryId,
    Expression<String>? frequency,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<DateTime>? lastGeneratedDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (recurringExpenseId != null)
        'recurring_expense_id': recurringExpenseId,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (categoryId != null) 'category_id': categoryId,
      if (frequency != null) 'frequency': frequency,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (lastGeneratedDate != null) 'last_generated_date': lastGeneratedDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringExpensesCompanion copyWith({
    Value<String>? recurringExpenseId,
    Value<String>? userId,
    Value<String>? name,
    Value<double>? amount,
    Value<String>? currency,
    Value<String>? categoryId,
    Value<String>? frequency,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<DateTime?>? lastGeneratedDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RecurringExpensesCompanion(
      recurringExpenseId: recurringExpenseId ?? this.recurringExpenseId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      lastGeneratedDate: lastGeneratedDate ?? this.lastGeneratedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (recurringExpenseId.present) {
      map['recurring_expense_id'] = Variable<String>(recurringExpenseId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (lastGeneratedDate.present) {
      map['last_generated_date'] = Variable<DateTime>(lastGeneratedDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringExpensesCompanion(')
          ..write('recurringExpenseId: $recurringExpenseId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('categoryId: $categoryId, ')
          ..write('frequency: $frequency, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('lastGeneratedDate: $lastGeneratedDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiActionLogsTable extends AiActionLogs
    with TableInfo<$AiActionLogsTable, DriftAiActionLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiActionLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _actionIdMeta = const VerificationMeta(
    'actionId',
  );
  @override
  late final GeneratedColumn<String> actionId = GeneratedColumn<String>(
    'action_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionTypeMeta = const VerificationMeta(
    'actionType',
  );
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
    'action_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inputMeta = const VerificationMeta('input');
  @override
  late final GeneratedColumn<String> input = GeneratedColumn<String>(
    'input',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outputMeta = const VerificationMeta('output');
  @override
  late final GeneratedColumn<String> output = GeneratedColumn<String>(
    'output',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String>
  structuredJson =
      GeneratedColumn<String>(
        'structured_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Map<String, dynamic>?>(
        $AiActionLogsTable.$converterstructuredJsonn,
      );
  static const VerificationMeta _successMeta = const VerificationMeta(
    'success',
  );
  @override
  late final GeneratedColumn<bool> success = GeneratedColumn<bool>(
    'success',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("success" IN (0, 1))',
    ),
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quotaUsedMeta = const VerificationMeta(
    'quotaUsed',
  );
  @override
  late final GeneratedColumn<int> quotaUsed = GeneratedColumn<int>(
    'quota_used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    actionId,
    userId,
    actionType,
    input,
    output,
    structuredJson,
    success,
    error,
    quotaUsed,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_action_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DriftAiActionLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('action_id')) {
      context.handle(
        _actionIdMeta,
        actionId.isAcceptableOrUnknown(data['action_id']!, _actionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_actionIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('action_type')) {
      context.handle(
        _actionTypeMeta,
        actionType.isAcceptableOrUnknown(data['action_type']!, _actionTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('input')) {
      context.handle(
        _inputMeta,
        input.isAcceptableOrUnknown(data['input']!, _inputMeta),
      );
    } else if (isInserting) {
      context.missing(_inputMeta);
    }
    if (data.containsKey('output')) {
      context.handle(
        _outputMeta,
        output.isAcceptableOrUnknown(data['output']!, _outputMeta),
      );
    }
    if (data.containsKey('success')) {
      context.handle(
        _successMeta,
        success.isAcceptableOrUnknown(data['success']!, _successMeta),
      );
    } else if (isInserting) {
      context.missing(_successMeta);
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('quota_used')) {
      context.handle(
        _quotaUsedMeta,
        quotaUsed.isAcceptableOrUnknown(data['quota_used']!, _quotaUsedMeta),
      );
    } else if (isInserting) {
      context.missing(_quotaUsedMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {actionId};
  @override
  DriftAiActionLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftAiActionLog(
      actionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      actionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_type'],
      )!,
      input: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}input'],
      )!,
      output: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}output'],
      ),
      structuredJson: $AiActionLogsTable.$converterstructuredJsonn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}structured_json'],
        ),
      ),
      success: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}success'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      quotaUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quota_used'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AiActionLogsTable createAlias(String alias) {
    return $AiActionLogsTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>, String> $converterstructuredJson =
      const JsonMapConverter();
  static TypeConverter<Map<String, dynamic>?, String?>
  $converterstructuredJsonn = NullAwareTypeConverter.wrap(
    $converterstructuredJson,
  );
}

class DriftAiActionLog extends DataClass
    implements Insertable<DriftAiActionLog> {
  final String actionId;
  final String userId;
  final String actionType;
  final String input;
  final String? output;
  final Map<String, dynamic>? structuredJson;
  final bool success;
  final String? error;
  final int quotaUsed;
  final DateTime createdAt;
  const DriftAiActionLog({
    required this.actionId,
    required this.userId,
    required this.actionType,
    required this.input,
    this.output,
    this.structuredJson,
    required this.success,
    this.error,
    required this.quotaUsed,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['action_id'] = Variable<String>(actionId);
    map['user_id'] = Variable<String>(userId);
    map['action_type'] = Variable<String>(actionType);
    map['input'] = Variable<String>(input);
    if (!nullToAbsent || output != null) {
      map['output'] = Variable<String>(output);
    }
    if (!nullToAbsent || structuredJson != null) {
      map['structured_json'] = Variable<String>(
        $AiActionLogsTable.$converterstructuredJsonn.toSql(structuredJson),
      );
    }
    map['success'] = Variable<bool>(success);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['quota_used'] = Variable<int>(quotaUsed);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AiActionLogsCompanion toCompanion(bool nullToAbsent) {
    return AiActionLogsCompanion(
      actionId: Value(actionId),
      userId: Value(userId),
      actionType: Value(actionType),
      input: Value(input),
      output: output == null && nullToAbsent
          ? const Value.absent()
          : Value(output),
      structuredJson: structuredJson == null && nullToAbsent
          ? const Value.absent()
          : Value(structuredJson),
      success: Value(success),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      quotaUsed: Value(quotaUsed),
      createdAt: Value(createdAt),
    );
  }

  factory DriftAiActionLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftAiActionLog(
      actionId: serializer.fromJson<String>(json['actionId']),
      userId: serializer.fromJson<String>(json['userId']),
      actionType: serializer.fromJson<String>(json['actionType']),
      input: serializer.fromJson<String>(json['input']),
      output: serializer.fromJson<String?>(json['output']),
      structuredJson: serializer.fromJson<Map<String, dynamic>?>(
        json['structuredJson'],
      ),
      success: serializer.fromJson<bool>(json['success']),
      error: serializer.fromJson<String?>(json['error']),
      quotaUsed: serializer.fromJson<int>(json['quotaUsed']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'actionId': serializer.toJson<String>(actionId),
      'userId': serializer.toJson<String>(userId),
      'actionType': serializer.toJson<String>(actionType),
      'input': serializer.toJson<String>(input),
      'output': serializer.toJson<String?>(output),
      'structuredJson': serializer.toJson<Map<String, dynamic>?>(
        structuredJson,
      ),
      'success': serializer.toJson<bool>(success),
      'error': serializer.toJson<String?>(error),
      'quotaUsed': serializer.toJson<int>(quotaUsed),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DriftAiActionLog copyWith({
    String? actionId,
    String? userId,
    String? actionType,
    String? input,
    Value<String?> output = const Value.absent(),
    Value<Map<String, dynamic>?> structuredJson = const Value.absent(),
    bool? success,
    Value<String?> error = const Value.absent(),
    int? quotaUsed,
    DateTime? createdAt,
  }) => DriftAiActionLog(
    actionId: actionId ?? this.actionId,
    userId: userId ?? this.userId,
    actionType: actionType ?? this.actionType,
    input: input ?? this.input,
    output: output.present ? output.value : this.output,
    structuredJson: structuredJson.present
        ? structuredJson.value
        : this.structuredJson,
    success: success ?? this.success,
    error: error.present ? error.value : this.error,
    quotaUsed: quotaUsed ?? this.quotaUsed,
    createdAt: createdAt ?? this.createdAt,
  );
  DriftAiActionLog copyWithCompanion(AiActionLogsCompanion data) {
    return DriftAiActionLog(
      actionId: data.actionId.present ? data.actionId.value : this.actionId,
      userId: data.userId.present ? data.userId.value : this.userId,
      actionType: data.actionType.present
          ? data.actionType.value
          : this.actionType,
      input: data.input.present ? data.input.value : this.input,
      output: data.output.present ? data.output.value : this.output,
      structuredJson: data.structuredJson.present
          ? data.structuredJson.value
          : this.structuredJson,
      success: data.success.present ? data.success.value : this.success,
      error: data.error.present ? data.error.value : this.error,
      quotaUsed: data.quotaUsed.present ? data.quotaUsed.value : this.quotaUsed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftAiActionLog(')
          ..write('actionId: $actionId, ')
          ..write('userId: $userId, ')
          ..write('actionType: $actionType, ')
          ..write('input: $input, ')
          ..write('output: $output, ')
          ..write('structuredJson: $structuredJson, ')
          ..write('success: $success, ')
          ..write('error: $error, ')
          ..write('quotaUsed: $quotaUsed, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    actionId,
    userId,
    actionType,
    input,
    output,
    structuredJson,
    success,
    error,
    quotaUsed,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftAiActionLog &&
          other.actionId == this.actionId &&
          other.userId == this.userId &&
          other.actionType == this.actionType &&
          other.input == this.input &&
          other.output == this.output &&
          other.structuredJson == this.structuredJson &&
          other.success == this.success &&
          other.error == this.error &&
          other.quotaUsed == this.quotaUsed &&
          other.createdAt == this.createdAt);
}

class AiActionLogsCompanion extends UpdateCompanion<DriftAiActionLog> {
  final Value<String> actionId;
  final Value<String> userId;
  final Value<String> actionType;
  final Value<String> input;
  final Value<String?> output;
  final Value<Map<String, dynamic>?> structuredJson;
  final Value<bool> success;
  final Value<String?> error;
  final Value<int> quotaUsed;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AiActionLogsCompanion({
    this.actionId = const Value.absent(),
    this.userId = const Value.absent(),
    this.actionType = const Value.absent(),
    this.input = const Value.absent(),
    this.output = const Value.absent(),
    this.structuredJson = const Value.absent(),
    this.success = const Value.absent(),
    this.error = const Value.absent(),
    this.quotaUsed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiActionLogsCompanion.insert({
    required String actionId,
    required String userId,
    required String actionType,
    required String input,
    this.output = const Value.absent(),
    this.structuredJson = const Value.absent(),
    required bool success,
    this.error = const Value.absent(),
    required int quotaUsed,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : actionId = Value(actionId),
       userId = Value(userId),
       actionType = Value(actionType),
       input = Value(input),
       success = Value(success),
       quotaUsed = Value(quotaUsed),
       createdAt = Value(createdAt);
  static Insertable<DriftAiActionLog> custom({
    Expression<String>? actionId,
    Expression<String>? userId,
    Expression<String>? actionType,
    Expression<String>? input,
    Expression<String>? output,
    Expression<String>? structuredJson,
    Expression<bool>? success,
    Expression<String>? error,
    Expression<int>? quotaUsed,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (actionId != null) 'action_id': actionId,
      if (userId != null) 'user_id': userId,
      if (actionType != null) 'action_type': actionType,
      if (input != null) 'input': input,
      if (output != null) 'output': output,
      if (structuredJson != null) 'structured_json': structuredJson,
      if (success != null) 'success': success,
      if (error != null) 'error': error,
      if (quotaUsed != null) 'quota_used': quotaUsed,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiActionLogsCompanion copyWith({
    Value<String>? actionId,
    Value<String>? userId,
    Value<String>? actionType,
    Value<String>? input,
    Value<String?>? output,
    Value<Map<String, dynamic>?>? structuredJson,
    Value<bool>? success,
    Value<String?>? error,
    Value<int>? quotaUsed,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AiActionLogsCompanion(
      actionId: actionId ?? this.actionId,
      userId: userId ?? this.userId,
      actionType: actionType ?? this.actionType,
      input: input ?? this.input,
      output: output ?? this.output,
      structuredJson: structuredJson ?? this.structuredJson,
      success: success ?? this.success,
      error: error ?? this.error,
      quotaUsed: quotaUsed ?? this.quotaUsed,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (actionId.present) {
      map['action_id'] = Variable<String>(actionId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (input.present) {
      map['input'] = Variable<String>(input.value);
    }
    if (output.present) {
      map['output'] = Variable<String>(output.value);
    }
    if (structuredJson.present) {
      map['structured_json'] = Variable<String>(
        $AiActionLogsTable.$converterstructuredJsonn.toSql(
          structuredJson.value,
        ),
      );
    }
    if (success.present) {
      map['success'] = Variable<bool>(success.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (quotaUsed.present) {
      map['quota_used'] = Variable<int>(quotaUsed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiActionLogsCompanion(')
          ..write('actionId: $actionId, ')
          ..write('userId: $userId, ')
          ..write('actionType: $actionType, ')
          ..write('input: $input, ')
          ..write('output: $output, ')
          ..write('structuredJson: $structuredJson, ')
          ..write('success: $success, ')
          ..write('error: $error, ')
          ..write('quotaUsed: $quotaUsed, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $WalletsTable wallets = $WalletsTable(this);
  late final $TransfersTable transfers = $TransfersTable(this);
  late final $CategoryBudgetsTable categoryBudgets = $CategoryBudgetsTable(
    this,
  );
  late final $CategoryAliasesTable categoryAliases = $CategoryAliasesTable(
    this,
  );
  late final $RecurringExpensesTable recurringExpenses =
      $RecurringExpensesTable(this);
  late final $AiActionLogsTable aiActionLogs = $AiActionLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    expenses,
    categories,
    budgets,
    settings,
    goals,
    wallets,
    transfers,
    categoryBudgets,
    categoryAliases,
    recurringExpenses,
    aiActionLogs,
  ];
}

typedef $$ExpensesTableCreateCompanionBuilder =
    ExpensesCompanion Function({
      required String expenseId,
      required String userId,
      required String categoryId,
      required String categoryName,
      required String categoryIcon,
      required int categoryColor,
      required DateTime date,
      required double amount,
      required String description,
      Value<String?> merchant,
      required List<String> tags,
      required String paymentMethod,
      required String currency,
      required DateTime createdAt,
      required DateTime updatedAt,
      required String source,
      Value<String?> walletAccountId,
      Value<String?> walletAccountName,
      Value<String?> recurringExpenseId,
      Value<String?> aiActionId,
      Value<MoneySnapshot?> moneySnapshot,
      Value<int> rowid,
    });
typedef $$ExpensesTableUpdateCompanionBuilder =
    ExpensesCompanion Function({
      Value<String> expenseId,
      Value<String> userId,
      Value<String> categoryId,
      Value<String> categoryName,
      Value<String> categoryIcon,
      Value<int> categoryColor,
      Value<DateTime> date,
      Value<double> amount,
      Value<String> description,
      Value<String?> merchant,
      Value<List<String>> tags,
      Value<String> paymentMethod,
      Value<String> currency,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> source,
      Value<String?> walletAccountId,
      Value<String?> walletAccountName,
      Value<String?> recurringExpenseId,
      Value<String?> aiActionId,
      Value<MoneySnapshot?> moneySnapshot,
      Value<int> rowid,
    });

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get expenseId => $composableBuilder(
    column: $table.expenseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryIcon => $composableBuilder(
    column: $table.categoryIcon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryColor => $composableBuilder(
    column: $table.categoryColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tags =>
      $composableBuilder(
        column: $table.tags,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get walletAccountId => $composableBuilder(
    column: $table.walletAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get walletAccountName => $composableBuilder(
    column: $table.walletAccountName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurringExpenseId => $composableBuilder(
    column: $table.recurringExpenseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aiActionId => $composableBuilder(
    column: $table.aiActionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MoneySnapshot?, MoneySnapshot, String>
  get moneySnapshot => $composableBuilder(
    column: $table.moneySnapshot,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get expenseId => $composableBuilder(
    column: $table.expenseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryIcon => $composableBuilder(
    column: $table.categoryIcon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryColor => $composableBuilder(
    column: $table.categoryColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get walletAccountId => $composableBuilder(
    column: $table.walletAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get walletAccountName => $composableBuilder(
    column: $table.walletAccountName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurringExpenseId => $composableBuilder(
    column: $table.recurringExpenseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aiActionId => $composableBuilder(
    column: $table.aiActionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moneySnapshot => $composableBuilder(
    column: $table.moneySnapshot,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get expenseId =>
      $composableBuilder(column: $table.expenseId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryIcon => $composableBuilder(
    column: $table.categoryIcon,
    builder: (column) => column,
  );

  GeneratedColumn<int> get categoryColor => $composableBuilder(
    column: $table.categoryColor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get walletAccountId => $composableBuilder(
    column: $table.walletAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get walletAccountName => $composableBuilder(
    column: $table.walletAccountName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurringExpenseId => $composableBuilder(
    column: $table.recurringExpenseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aiActionId => $composableBuilder(
    column: $table.aiActionId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MoneySnapshot?, String> get moneySnapshot =>
      $composableBuilder(
        column: $table.moneySnapshot,
        builder: (column) => column,
      );
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          DriftExpense,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (
            DriftExpense,
            BaseReferences<_$AppDatabase, $ExpensesTable, DriftExpense>,
          ),
          DriftExpense,
          PrefetchHooks Function()
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> expenseId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> categoryName = const Value.absent(),
                Value<String> categoryIcon = const Value.absent(),
                Value<int> categoryColor = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> merchant = const Value.absent(),
                Value<List<String>> tags = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> walletAccountId = const Value.absent(),
                Value<String?> walletAccountName = const Value.absent(),
                Value<String?> recurringExpenseId = const Value.absent(),
                Value<String?> aiActionId = const Value.absent(),
                Value<MoneySnapshot?> moneySnapshot = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion(
                expenseId: expenseId,
                userId: userId,
                categoryId: categoryId,
                categoryName: categoryName,
                categoryIcon: categoryIcon,
                categoryColor: categoryColor,
                date: date,
                amount: amount,
                description: description,
                merchant: merchant,
                tags: tags,
                paymentMethod: paymentMethod,
                currency: currency,
                createdAt: createdAt,
                updatedAt: updatedAt,
                source: source,
                walletAccountId: walletAccountId,
                walletAccountName: walletAccountName,
                recurringExpenseId: recurringExpenseId,
                aiActionId: aiActionId,
                moneySnapshot: moneySnapshot,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String expenseId,
                required String userId,
                required String categoryId,
                required String categoryName,
                required String categoryIcon,
                required int categoryColor,
                required DateTime date,
                required double amount,
                required String description,
                Value<String?> merchant = const Value.absent(),
                required List<String> tags,
                required String paymentMethod,
                required String currency,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String source,
                Value<String?> walletAccountId = const Value.absent(),
                Value<String?> walletAccountName = const Value.absent(),
                Value<String?> recurringExpenseId = const Value.absent(),
                Value<String?> aiActionId = const Value.absent(),
                Value<MoneySnapshot?> moneySnapshot = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion.insert(
                expenseId: expenseId,
                userId: userId,
                categoryId: categoryId,
                categoryName: categoryName,
                categoryIcon: categoryIcon,
                categoryColor: categoryColor,
                date: date,
                amount: amount,
                description: description,
                merchant: merchant,
                tags: tags,
                paymentMethod: paymentMethod,
                currency: currency,
                createdAt: createdAt,
                updatedAt: updatedAt,
                source: source,
                walletAccountId: walletAccountId,
                walletAccountName: walletAccountName,
                recurringExpenseId: recurringExpenseId,
                aiActionId: aiActionId,
                moneySnapshot: moneySnapshot,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      DriftExpense,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (
        DriftExpense,
        BaseReferences<_$AppDatabase, $ExpensesTable, DriftExpense>,
      ),
      DriftExpense,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String categoryId,
      required String userId,
      required String name,
      required int totalExpenses,
      required String icon,
      required int color,
      required bool isArchived,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> categoryId,
      Value<String> userId,
      Value<String> name,
      Value<int> totalExpenses,
      Value<String> icon,
      Value<int> color,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalExpenses => $composableBuilder(
    column: $table.totalExpenses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalExpenses => $composableBuilder(
    column: $table.totalExpenses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get totalExpenses => $composableBuilder(
    column: $table.totalExpenses,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          DriftCategory,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (
            DriftCategory,
            BaseReferences<_$AppDatabase, $CategoriesTable, DriftCategory>,
          ),
          DriftCategory,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> categoryId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> totalExpenses = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                categoryId: categoryId,
                userId: userId,
                name: name,
                totalExpenses: totalExpenses,
                icon: icon,
                color: color,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String categoryId,
                required String userId,
                required String name,
                required int totalExpenses,
                required String icon,
                required int color,
                required bool isArchived,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                categoryId: categoryId,
                userId: userId,
                name: name,
                totalExpenses: totalExpenses,
                icon: icon,
                color: color,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      DriftCategory,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (
        DriftCategory,
        BaseReferences<_$AppDatabase, $CategoriesTable, DriftCategory>,
      ),
      DriftCategory,
      PrefetchHooks Function()
    >;
typedef $$BudgetsTableCreateCompanionBuilder =
    BudgetsCompanion Function({
      required String budgetId,
      required String userId,
      required int month,
      required int year,
      required double amount,
      required String currency,
      required int warningThresholdPercent,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$BudgetsTableUpdateCompanionBuilder =
    BudgetsCompanion Function({
      Value<String> budgetId,
      Value<String> userId,
      Value<int> month,
      Value<int> year,
      Value<double> amount,
      Value<String> currency,
      Value<int> warningThresholdPercent,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get budgetId => $composableBuilder(
    column: $table.budgetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warningThresholdPercent => $composableBuilder(
    column: $table.warningThresholdPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get budgetId => $composableBuilder(
    column: $table.budgetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warningThresholdPercent => $composableBuilder(
    column: $table.warningThresholdPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get budgetId =>
      $composableBuilder(column: $table.budgetId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get warningThresholdPercent => $composableBuilder(
    column: $table.warningThresholdPercent,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetsTable,
          DriftBudget,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (
            DriftBudget,
            BaseReferences<_$AppDatabase, $BudgetsTable, DriftBudget>,
          ),
          DriftBudget,
          PrefetchHooks Function()
        > {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> budgetId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> month = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> warningThresholdPercent = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion(
                budgetId: budgetId,
                userId: userId,
                month: month,
                year: year,
                amount: amount,
                currency: currency,
                warningThresholdPercent: warningThresholdPercent,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String budgetId,
                required String userId,
                required int month,
                required int year,
                required double amount,
                required String currency,
                required int warningThresholdPercent,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion.insert(
                budgetId: budgetId,
                userId: userId,
                month: month,
                year: year,
                amount: amount,
                currency: currency,
                warningThresholdPercent: warningThresholdPercent,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetsTable,
      DriftBudget,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (DriftBudget, BaseReferences<_$AppDatabase, $BudgetsTable, DriftBudget>),
      DriftBudget,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String userId,
      Value<String?> appDisplayName,
      required String languagePreference,
      required String baseCurrency,
      required List<String> supportedCurrencies,
      required Map<String, double> conversionRates,
      required String defaultPaymentMethod,
      required Map<String, dynamic> notificationSettings,
      required bool onboardingCompleted,
      required int onboardingVersion,
      required int guidedTourCompletedVersion,
      required int guidedTourSkippedVersion,
      Value<String?> guidedTourLastStepId,
      Value<DateTime?> exchangeRatesUpdatedAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> userId,
      Value<String?> appDisplayName,
      Value<String> languagePreference,
      Value<String> baseCurrency,
      Value<List<String>> supportedCurrencies,
      Value<Map<String, double>> conversionRates,
      Value<String> defaultPaymentMethod,
      Value<Map<String, dynamic>> notificationSettings,
      Value<bool> onboardingCompleted,
      Value<int> onboardingVersion,
      Value<int> guidedTourCompletedVersion,
      Value<int> guidedTourSkippedVersion,
      Value<String?> guidedTourLastStepId,
      Value<DateTime?> exchangeRatesUpdatedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appDisplayName => $composableBuilder(
    column: $table.appDisplayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languagePreference => $composableBuilder(
    column: $table.languagePreference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get supportedCurrencies => $composableBuilder(
    column: $table.supportedCurrencies,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, double>,
    Map<String, double>,
    String
  >
  get conversionRates => $composableBuilder(
    column: $table.conversionRates,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get defaultPaymentMethod => $composableBuilder(
    column: $table.defaultPaymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>,
    Map<String, dynamic>,
    String
  >
  get notificationSettings => $composableBuilder(
    column: $table.notificationSettings,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get onboardingVersion => $composableBuilder(
    column: $table.onboardingVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get guidedTourCompletedVersion => $composableBuilder(
    column: $table.guidedTourCompletedVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get guidedTourSkippedVersion => $composableBuilder(
    column: $table.guidedTourSkippedVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guidedTourLastStepId => $composableBuilder(
    column: $table.guidedTourLastStepId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get exchangeRatesUpdatedAt => $composableBuilder(
    column: $table.exchangeRatesUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appDisplayName => $composableBuilder(
    column: $table.appDisplayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languagePreference => $composableBuilder(
    column: $table.languagePreference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supportedCurrencies => $composableBuilder(
    column: $table.supportedCurrencies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conversionRates => $composableBuilder(
    column: $table.conversionRates,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultPaymentMethod => $composableBuilder(
    column: $table.defaultPaymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notificationSettings => $composableBuilder(
    column: $table.notificationSettings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get onboardingVersion => $composableBuilder(
    column: $table.onboardingVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get guidedTourCompletedVersion => $composableBuilder(
    column: $table.guidedTourCompletedVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get guidedTourSkippedVersion => $composableBuilder(
    column: $table.guidedTourSkippedVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guidedTourLastStepId => $composableBuilder(
    column: $table.guidedTourLastStepId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get exchangeRatesUpdatedAt => $composableBuilder(
    column: $table.exchangeRatesUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get appDisplayName => $composableBuilder(
    column: $table.appDisplayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get languagePreference => $composableBuilder(
    column: $table.languagePreference,
    builder: (column) => column,
  );

  GeneratedColumn<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String>
  get supportedCurrencies => $composableBuilder(
    column: $table.supportedCurrencies,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Map<String, double>, String>
  get conversionRates => $composableBuilder(
    column: $table.conversionRates,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultPaymentMethod => $composableBuilder(
    column: $table.defaultPaymentMethod,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  get notificationSettings => $composableBuilder(
    column: $table.notificationSettings,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get onboardingVersion => $composableBuilder(
    column: $table.onboardingVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get guidedTourCompletedVersion => $composableBuilder(
    column: $table.guidedTourCompletedVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get guidedTourSkippedVersion => $composableBuilder(
    column: $table.guidedTourSkippedVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get guidedTourLastStepId => $composableBuilder(
    column: $table.guidedTourLastStepId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get exchangeRatesUpdatedAt => $composableBuilder(
    column: $table.exchangeRatesUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          DriftSettings,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            DriftSettings,
            BaseReferences<_$AppDatabase, $SettingsTable, DriftSettings>,
          ),
          DriftSettings,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String?> appDisplayName = const Value.absent(),
                Value<String> languagePreference = const Value.absent(),
                Value<String> baseCurrency = const Value.absent(),
                Value<List<String>> supportedCurrencies = const Value.absent(),
                Value<Map<String, double>> conversionRates =
                    const Value.absent(),
                Value<String> defaultPaymentMethod = const Value.absent(),
                Value<Map<String, dynamic>> notificationSettings =
                    const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<int> onboardingVersion = const Value.absent(),
                Value<int> guidedTourCompletedVersion = const Value.absent(),
                Value<int> guidedTourSkippedVersion = const Value.absent(),
                Value<String?> guidedTourLastStepId = const Value.absent(),
                Value<DateTime?> exchangeRatesUpdatedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(
                userId: userId,
                appDisplayName: appDisplayName,
                languagePreference: languagePreference,
                baseCurrency: baseCurrency,
                supportedCurrencies: supportedCurrencies,
                conversionRates: conversionRates,
                defaultPaymentMethod: defaultPaymentMethod,
                notificationSettings: notificationSettings,
                onboardingCompleted: onboardingCompleted,
                onboardingVersion: onboardingVersion,
                guidedTourCompletedVersion: guidedTourCompletedVersion,
                guidedTourSkippedVersion: guidedTourSkippedVersion,
                guidedTourLastStepId: guidedTourLastStepId,
                exchangeRatesUpdatedAt: exchangeRatesUpdatedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                Value<String?> appDisplayName = const Value.absent(),
                required String languagePreference,
                required String baseCurrency,
                required List<String> supportedCurrencies,
                required Map<String, double> conversionRates,
                required String defaultPaymentMethod,
                required Map<String, dynamic> notificationSettings,
                required bool onboardingCompleted,
                required int onboardingVersion,
                required int guidedTourCompletedVersion,
                required int guidedTourSkippedVersion,
                Value<String?> guidedTourLastStepId = const Value.absent(),
                Value<DateTime?> exchangeRatesUpdatedAt = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                userId: userId,
                appDisplayName: appDisplayName,
                languagePreference: languagePreference,
                baseCurrency: baseCurrency,
                supportedCurrencies: supportedCurrencies,
                conversionRates: conversionRates,
                defaultPaymentMethod: defaultPaymentMethod,
                notificationSettings: notificationSettings,
                onboardingCompleted: onboardingCompleted,
                onboardingVersion: onboardingVersion,
                guidedTourCompletedVersion: guidedTourCompletedVersion,
                guidedTourSkippedVersion: guidedTourSkippedVersion,
                guidedTourLastStepId: guidedTourLastStepId,
                exchangeRatesUpdatedAt: exchangeRatesUpdatedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      DriftSettings,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (
        DriftSettings,
        BaseReferences<_$AppDatabase, $SettingsTable, DriftSettings>,
      ),
      DriftSettings,
      PrefetchHooks Function()
    >;
typedef $$GoalsTableCreateCompanionBuilder =
    GoalsCompanion Function({
      required String goalId,
      required String userId,
      required String name,
      required double targetAmount,
      required double currentAmount,
      required String currency,
      Value<DateTime?> deadline,
      required int color,
      required bool isArchived,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$GoalsTableUpdateCompanionBuilder =
    GoalsCompanion Function({
      Value<String> goalId,
      Value<String> userId,
      Value<String> name,
      Value<double> targetAmount,
      Value<double> currentAmount,
      Value<String> currency,
      Value<DateTime?> deadline,
      Value<int> color,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get goalId => $composableBuilder(
    column: $table.goalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentAmount => $composableBuilder(
    column: $table.currentAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get goalId => $composableBuilder(
    column: $table.goalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentAmount => $composableBuilder(
    column: $table.currentAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get goalId =>
      $composableBuilder(column: $table.goalId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentAmount => $composableBuilder(
    column: $table.currentAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalsTable,
          DriftSavingGoal,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (
            DriftSavingGoal,
            BaseReferences<_$AppDatabase, $GoalsTable, DriftSavingGoal>,
          ),
          DriftSavingGoal,
          PrefetchHooks Function()
        > {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> goalId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> targetAmount = const Value.absent(),
                Value<double> currentAmount = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion(
                goalId: goalId,
                userId: userId,
                name: name,
                targetAmount: targetAmount,
                currentAmount: currentAmount,
                currency: currency,
                deadline: deadline,
                color: color,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String goalId,
                required String userId,
                required String name,
                required double targetAmount,
                required double currentAmount,
                required String currency,
                Value<DateTime?> deadline = const Value.absent(),
                required int color,
                required bool isArchived,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion.insert(
                goalId: goalId,
                userId: userId,
                name: name,
                targetAmount: targetAmount,
                currentAmount: currentAmount,
                currency: currency,
                deadline: deadline,
                color: color,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalsTable,
      DriftSavingGoal,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (
        DriftSavingGoal,
        BaseReferences<_$AppDatabase, $GoalsTable, DriftSavingGoal>,
      ),
      DriftSavingGoal,
      PrefetchHooks Function()
    >;
typedef $$WalletsTableCreateCompanionBuilder =
    WalletsCompanion Function({
      required String walletId,
      required String userId,
      required String name,
      required String type,
      required double balance,
      required String currency,
      required String icon,
      required int color,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$WalletsTableUpdateCompanionBuilder =
    WalletsCompanion Function({
      Value<String> walletId,
      Value<String> userId,
      Value<String> name,
      Value<String> type,
      Value<double> balance,
      Value<String> currency,
      Value<String> icon,
      Value<int> color,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$WalletsTableFilterComposer
    extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get walletId => $composableBuilder(
    column: $table.walletId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WalletsTableOrderingComposer
    extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get walletId => $composableBuilder(
    column: $table.walletId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalletsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get walletId =>
      $composableBuilder(column: $table.walletId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WalletsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalletsTable,
          DriftWallet,
          $$WalletsTableFilterComposer,
          $$WalletsTableOrderingComposer,
          $$WalletsTableAnnotationComposer,
          $$WalletsTableCreateCompanionBuilder,
          $$WalletsTableUpdateCompanionBuilder,
          (
            DriftWallet,
            BaseReferences<_$AppDatabase, $WalletsTable, DriftWallet>,
          ),
          DriftWallet,
          PrefetchHooks Function()
        > {
  $$WalletsTableTableManager(_$AppDatabase db, $WalletsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalletsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalletsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> walletId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> balance = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalletsCompanion(
                walletId: walletId,
                userId: userId,
                name: name,
                type: type,
                balance: balance,
                currency: currency,
                icon: icon,
                color: color,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String walletId,
                required String userId,
                required String name,
                required String type,
                required double balance,
                required String currency,
                required String icon,
                required int color,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WalletsCompanion.insert(
                walletId: walletId,
                userId: userId,
                name: name,
                type: type,
                balance: balance,
                currency: currency,
                icon: icon,
                color: color,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WalletsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalletsTable,
      DriftWallet,
      $$WalletsTableFilterComposer,
      $$WalletsTableOrderingComposer,
      $$WalletsTableAnnotationComposer,
      $$WalletsTableCreateCompanionBuilder,
      $$WalletsTableUpdateCompanionBuilder,
      (DriftWallet, BaseReferences<_$AppDatabase, $WalletsTable, DriftWallet>),
      DriftWallet,
      PrefetchHooks Function()
    >;
typedef $$TransfersTableCreateCompanionBuilder =
    TransfersCompanion Function({
      required String transferId,
      required String userId,
      required String fromWalletId,
      required String toWalletId,
      required double amount,
      Value<String?> note,
      required DateTime date,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$TransfersTableUpdateCompanionBuilder =
    TransfersCompanion Function({
      Value<String> transferId,
      Value<String> userId,
      Value<String> fromWalletId,
      Value<String> toWalletId,
      Value<double> amount,
      Value<String?> note,
      Value<DateTime> date,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$TransfersTableFilterComposer
    extends Composer<_$AppDatabase, $TransfersTable> {
  $$TransfersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get transferId => $composableBuilder(
    column: $table.transferId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromWalletId => $composableBuilder(
    column: $table.fromWalletId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toWalletId => $composableBuilder(
    column: $table.toWalletId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransfersTableOrderingComposer
    extends Composer<_$AppDatabase, $TransfersTable> {
  $$TransfersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get transferId => $composableBuilder(
    column: $table.transferId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromWalletId => $composableBuilder(
    column: $table.fromWalletId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toWalletId => $composableBuilder(
    column: $table.toWalletId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransfersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransfersTable> {
  $$TransfersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get transferId => $composableBuilder(
    column: $table.transferId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get fromWalletId => $composableBuilder(
    column: $table.fromWalletId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toWalletId => $composableBuilder(
    column: $table.toWalletId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TransfersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransfersTable,
          DriftTransfer,
          $$TransfersTableFilterComposer,
          $$TransfersTableOrderingComposer,
          $$TransfersTableAnnotationComposer,
          $$TransfersTableCreateCompanionBuilder,
          $$TransfersTableUpdateCompanionBuilder,
          (
            DriftTransfer,
            BaseReferences<_$AppDatabase, $TransfersTable, DriftTransfer>,
          ),
          DriftTransfer,
          PrefetchHooks Function()
        > {
  $$TransfersTableTableManager(_$AppDatabase db, $TransfersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransfersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransfersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransfersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> transferId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> fromWalletId = const Value.absent(),
                Value<String> toWalletId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransfersCompanion(
                transferId: transferId,
                userId: userId,
                fromWalletId: fromWalletId,
                toWalletId: toWalletId,
                amount: amount,
                note: note,
                date: date,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String transferId,
                required String userId,
                required String fromWalletId,
                required String toWalletId,
                required double amount,
                Value<String?> note = const Value.absent(),
                required DateTime date,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TransfersCompanion.insert(
                transferId: transferId,
                userId: userId,
                fromWalletId: fromWalletId,
                toWalletId: toWalletId,
                amount: amount,
                note: note,
                date: date,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransfersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransfersTable,
      DriftTransfer,
      $$TransfersTableFilterComposer,
      $$TransfersTableOrderingComposer,
      $$TransfersTableAnnotationComposer,
      $$TransfersTableCreateCompanionBuilder,
      $$TransfersTableUpdateCompanionBuilder,
      (
        DriftTransfer,
        BaseReferences<_$AppDatabase, $TransfersTable, DriftTransfer>,
      ),
      DriftTransfer,
      PrefetchHooks Function()
    >;
typedef $$CategoryBudgetsTableCreateCompanionBuilder =
    CategoryBudgetsCompanion Function({
      required String budgetId,
      required String userId,
      required String categoryId,
      required double amount,
      required int month,
      required int year,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CategoryBudgetsTableUpdateCompanionBuilder =
    CategoryBudgetsCompanion Function({
      Value<String> budgetId,
      Value<String> userId,
      Value<String> categoryId,
      Value<double> amount,
      Value<int> month,
      Value<int> year,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CategoryBudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryBudgetsTable> {
  $$CategoryBudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get budgetId => $composableBuilder(
    column: $table.budgetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoryBudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryBudgetsTable> {
  $$CategoryBudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get budgetId => $composableBuilder(
    column: $table.budgetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoryBudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryBudgetsTable> {
  $$CategoryBudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get budgetId =>
      $composableBuilder(column: $table.budgetId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CategoryBudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryBudgetsTable,
          DriftCategoryBudget,
          $$CategoryBudgetsTableFilterComposer,
          $$CategoryBudgetsTableOrderingComposer,
          $$CategoryBudgetsTableAnnotationComposer,
          $$CategoryBudgetsTableCreateCompanionBuilder,
          $$CategoryBudgetsTableUpdateCompanionBuilder,
          (
            DriftCategoryBudget,
            BaseReferences<
              _$AppDatabase,
              $CategoryBudgetsTable,
              DriftCategoryBudget
            >,
          ),
          DriftCategoryBudget,
          PrefetchHooks Function()
        > {
  $$CategoryBudgetsTableTableManager(
    _$AppDatabase db,
    $CategoryBudgetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryBudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryBudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryBudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> budgetId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<int> month = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryBudgetsCompanion(
                budgetId: budgetId,
                userId: userId,
                categoryId: categoryId,
                amount: amount,
                month: month,
                year: year,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String budgetId,
                required String userId,
                required String categoryId,
                required double amount,
                required int month,
                required int year,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CategoryBudgetsCompanion.insert(
                budgetId: budgetId,
                userId: userId,
                categoryId: categoryId,
                amount: amount,
                month: month,
                year: year,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoryBudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryBudgetsTable,
      DriftCategoryBudget,
      $$CategoryBudgetsTableFilterComposer,
      $$CategoryBudgetsTableOrderingComposer,
      $$CategoryBudgetsTableAnnotationComposer,
      $$CategoryBudgetsTableCreateCompanionBuilder,
      $$CategoryBudgetsTableUpdateCompanionBuilder,
      (
        DriftCategoryBudget,
        BaseReferences<
          _$AppDatabase,
          $CategoryBudgetsTable,
          DriftCategoryBudget
        >,
      ),
      DriftCategoryBudget,
      PrefetchHooks Function()
    >;
typedef $$CategoryAliasesTableCreateCompanionBuilder =
    CategoryAliasesCompanion Function({
      required String aliasId,
      required String userId,
      required String name,
      required String categoryId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CategoryAliasesTableUpdateCompanionBuilder =
    CategoryAliasesCompanion Function({
      Value<String> aliasId,
      Value<String> userId,
      Value<String> name,
      Value<String> categoryId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CategoryAliasesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryAliasesTable> {
  $$CategoryAliasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get aliasId => $composableBuilder(
    column: $table.aliasId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoryAliasesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryAliasesTable> {
  $$CategoryAliasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get aliasId => $composableBuilder(
    column: $table.aliasId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoryAliasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryAliasesTable> {
  $$CategoryAliasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get aliasId =>
      $composableBuilder(column: $table.aliasId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CategoryAliasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryAliasesTable,
          DriftCategoryAlias,
          $$CategoryAliasesTableFilterComposer,
          $$CategoryAliasesTableOrderingComposer,
          $$CategoryAliasesTableAnnotationComposer,
          $$CategoryAliasesTableCreateCompanionBuilder,
          $$CategoryAliasesTableUpdateCompanionBuilder,
          (
            DriftCategoryAlias,
            BaseReferences<
              _$AppDatabase,
              $CategoryAliasesTable,
              DriftCategoryAlias
            >,
          ),
          DriftCategoryAlias,
          PrefetchHooks Function()
        > {
  $$CategoryAliasesTableTableManager(
    _$AppDatabase db,
    $CategoryAliasesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryAliasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryAliasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryAliasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> aliasId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryAliasesCompanion(
                aliasId: aliasId,
                userId: userId,
                name: name,
                categoryId: categoryId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String aliasId,
                required String userId,
                required String name,
                required String categoryId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CategoryAliasesCompanion.insert(
                aliasId: aliasId,
                userId: userId,
                name: name,
                categoryId: categoryId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoryAliasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryAliasesTable,
      DriftCategoryAlias,
      $$CategoryAliasesTableFilterComposer,
      $$CategoryAliasesTableOrderingComposer,
      $$CategoryAliasesTableAnnotationComposer,
      $$CategoryAliasesTableCreateCompanionBuilder,
      $$CategoryAliasesTableUpdateCompanionBuilder,
      (
        DriftCategoryAlias,
        BaseReferences<
          _$AppDatabase,
          $CategoryAliasesTable,
          DriftCategoryAlias
        >,
      ),
      DriftCategoryAlias,
      PrefetchHooks Function()
    >;
typedef $$RecurringExpensesTableCreateCompanionBuilder =
    RecurringExpensesCompanion Function({
      required String recurringExpenseId,
      required String userId,
      required String name,
      required double amount,
      required String currency,
      required String categoryId,
      required String frequency,
      required DateTime startDate,
      Value<DateTime?> endDate,
      Value<DateTime?> lastGeneratedDate,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$RecurringExpensesTableUpdateCompanionBuilder =
    RecurringExpensesCompanion Function({
      Value<String> recurringExpenseId,
      Value<String> userId,
      Value<String> name,
      Value<double> amount,
      Value<String> currency,
      Value<String> categoryId,
      Value<String> frequency,
      Value<DateTime> startDate,
      Value<DateTime?> endDate,
      Value<DateTime?> lastGeneratedDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$RecurringExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringExpensesTable> {
  $$RecurringExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get recurringExpenseId => $composableBuilder(
    column: $table.recurringExpenseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastGeneratedDate => $composableBuilder(
    column: $table.lastGeneratedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecurringExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringExpensesTable> {
  $$RecurringExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get recurringExpenseId => $composableBuilder(
    column: $table.recurringExpenseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastGeneratedDate => $composableBuilder(
    column: $table.lastGeneratedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurringExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringExpensesTable> {
  $$RecurringExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get recurringExpenseId => $composableBuilder(
    column: $table.recurringExpenseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<DateTime> get lastGeneratedDate => $composableBuilder(
    column: $table.lastGeneratedDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RecurringExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringExpensesTable,
          DriftRecurringExpense,
          $$RecurringExpensesTableFilterComposer,
          $$RecurringExpensesTableOrderingComposer,
          $$RecurringExpensesTableAnnotationComposer,
          $$RecurringExpensesTableCreateCompanionBuilder,
          $$RecurringExpensesTableUpdateCompanionBuilder,
          (
            DriftRecurringExpense,
            BaseReferences<
              _$AppDatabase,
              $RecurringExpensesTable,
              DriftRecurringExpense
            >,
          ),
          DriftRecurringExpense,
          PrefetchHooks Function()
        > {
  $$RecurringExpensesTableTableManager(
    _$AppDatabase db,
    $RecurringExpensesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringExpensesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> recurringExpenseId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<DateTime?> lastGeneratedDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringExpensesCompanion(
                recurringExpenseId: recurringExpenseId,
                userId: userId,
                name: name,
                amount: amount,
                currency: currency,
                categoryId: categoryId,
                frequency: frequency,
                startDate: startDate,
                endDate: endDate,
                lastGeneratedDate: lastGeneratedDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String recurringExpenseId,
                required String userId,
                required String name,
                required double amount,
                required String currency,
                required String categoryId,
                required String frequency,
                required DateTime startDate,
                Value<DateTime?> endDate = const Value.absent(),
                Value<DateTime?> lastGeneratedDate = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RecurringExpensesCompanion.insert(
                recurringExpenseId: recurringExpenseId,
                userId: userId,
                name: name,
                amount: amount,
                currency: currency,
                categoryId: categoryId,
                frequency: frequency,
                startDate: startDate,
                endDate: endDate,
                lastGeneratedDate: lastGeneratedDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecurringExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringExpensesTable,
      DriftRecurringExpense,
      $$RecurringExpensesTableFilterComposer,
      $$RecurringExpensesTableOrderingComposer,
      $$RecurringExpensesTableAnnotationComposer,
      $$RecurringExpensesTableCreateCompanionBuilder,
      $$RecurringExpensesTableUpdateCompanionBuilder,
      (
        DriftRecurringExpense,
        BaseReferences<
          _$AppDatabase,
          $RecurringExpensesTable,
          DriftRecurringExpense
        >,
      ),
      DriftRecurringExpense,
      PrefetchHooks Function()
    >;
typedef $$AiActionLogsTableCreateCompanionBuilder =
    AiActionLogsCompanion Function({
      required String actionId,
      required String userId,
      required String actionType,
      required String input,
      Value<String?> output,
      Value<Map<String, dynamic>?> structuredJson,
      required bool success,
      Value<String?> error,
      required int quotaUsed,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AiActionLogsTableUpdateCompanionBuilder =
    AiActionLogsCompanion Function({
      Value<String> actionId,
      Value<String> userId,
      Value<String> actionType,
      Value<String> input,
      Value<String?> output,
      Value<Map<String, dynamic>?> structuredJson,
      Value<bool> success,
      Value<String?> error,
      Value<int> quotaUsed,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AiActionLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AiActionLogsTable> {
  $$AiActionLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get actionId => $composableBuilder(
    column: $table.actionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get input => $composableBuilder(
    column: $table.input,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get output => $composableBuilder(
    column: $table.output,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>?,
    Map<String, dynamic>,
    String
  >
  get structuredJson => $composableBuilder(
    column: $table.structuredJson,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quotaUsed => $composableBuilder(
    column: $table.quotaUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiActionLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiActionLogsTable> {
  $$AiActionLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get actionId => $composableBuilder(
    column: $table.actionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get input => $composableBuilder(
    column: $table.input,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get output => $composableBuilder(
    column: $table.output,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get structuredJson => $composableBuilder(
    column: $table.structuredJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quotaUsed => $composableBuilder(
    column: $table.quotaUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiActionLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiActionLogsTable> {
  $$AiActionLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get actionId =>
      $composableBuilder(column: $table.actionId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get input =>
      $composableBuilder(column: $table.input, builder: (column) => column);

  GeneratedColumn<String> get output =>
      $composableBuilder(column: $table.output, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String>
  get structuredJson => $composableBuilder(
    column: $table.structuredJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get success =>
      $composableBuilder(column: $table.success, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<int> get quotaUsed =>
      $composableBuilder(column: $table.quotaUsed, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AiActionLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiActionLogsTable,
          DriftAiActionLog,
          $$AiActionLogsTableFilterComposer,
          $$AiActionLogsTableOrderingComposer,
          $$AiActionLogsTableAnnotationComposer,
          $$AiActionLogsTableCreateCompanionBuilder,
          $$AiActionLogsTableUpdateCompanionBuilder,
          (
            DriftAiActionLog,
            BaseReferences<_$AppDatabase, $AiActionLogsTable, DriftAiActionLog>,
          ),
          DriftAiActionLog,
          PrefetchHooks Function()
        > {
  $$AiActionLogsTableTableManager(_$AppDatabase db, $AiActionLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiActionLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiActionLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiActionLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> actionId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> actionType = const Value.absent(),
                Value<String> input = const Value.absent(),
                Value<String?> output = const Value.absent(),
                Value<Map<String, dynamic>?> structuredJson =
                    const Value.absent(),
                Value<bool> success = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<int> quotaUsed = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiActionLogsCompanion(
                actionId: actionId,
                userId: userId,
                actionType: actionType,
                input: input,
                output: output,
                structuredJson: structuredJson,
                success: success,
                error: error,
                quotaUsed: quotaUsed,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String actionId,
                required String userId,
                required String actionType,
                required String input,
                Value<String?> output = const Value.absent(),
                Value<Map<String, dynamic>?> structuredJson =
                    const Value.absent(),
                required bool success,
                Value<String?> error = const Value.absent(),
                required int quotaUsed,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AiActionLogsCompanion.insert(
                actionId: actionId,
                userId: userId,
                actionType: actionType,
                input: input,
                output: output,
                structuredJson: structuredJson,
                success: success,
                error: error,
                quotaUsed: quotaUsed,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiActionLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiActionLogsTable,
      DriftAiActionLog,
      $$AiActionLogsTableFilterComposer,
      $$AiActionLogsTableOrderingComposer,
      $$AiActionLogsTableAnnotationComposer,
      $$AiActionLogsTableCreateCompanionBuilder,
      $$AiActionLogsTableUpdateCompanionBuilder,
      (
        DriftAiActionLog,
        BaseReferences<_$AppDatabase, $AiActionLogsTable, DriftAiActionLog>,
      ),
      DriftAiActionLog,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$WalletsTableTableManager get wallets =>
      $$WalletsTableTableManager(_db, _db.wallets);
  $$TransfersTableTableManager get transfers =>
      $$TransfersTableTableManager(_db, _db.transfers);
  $$CategoryBudgetsTableTableManager get categoryBudgets =>
      $$CategoryBudgetsTableTableManager(_db, _db.categoryBudgets);
  $$CategoryAliasesTableTableManager get categoryAliases =>
      $$CategoryAliasesTableTableManager(_db, _db.categoryAliases);
  $$RecurringExpensesTableTableManager get recurringExpenses =>
      $$RecurringExpensesTableTableManager(_db, _db.recurringExpenses);
  $$AiActionLogsTableTableManager get aiActionLogs =>
      $$AiActionLogsTableTableManager(_db, _db.aiActionLogs);
}
