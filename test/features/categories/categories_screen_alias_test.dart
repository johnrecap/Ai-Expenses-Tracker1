import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/features/categories/category_bloc/category_bloc.dart';
import 'package:expenses_tracker/features/categories/presentation/categories_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoriesScreen aliases', () {
    testWidgets('shows aliases, adds a new alias, and deletes an alias', (
      tester,
    ) async {
      final aliasRepository = _FakeCategoryAliasRepository([
        _alias(id: 'alias-1', name: 'Koshary El Tahrir'),
      ]);

      await _pumpCategories(
        tester,
        categories: [_category()],
        aliasRepository: aliasRepository,
      );

      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      expect(find.text('Koshary El Tahrir'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('category_alias_input')), 'Starbucks');
      await tester.tap(find.byKey(const Key('add_category_alias_button')));
      await tester.pumpAndSettle();

      expect(aliasRepository.created.map((alias) => alias.name), contains('Starbucks'));
      expect(find.text('Starbucks'), findsOneWidget);

      await tester.tap(find.byKey(const Key('delete_category_alias_alias-1')));
      await tester.pumpAndSettle();

      expect(aliasRepository.deleted, contains('alias-1'));
      expect(find.text('Koshary El Tahrir'), findsNothing);
    });

    testWidgets('validates empty and duplicate alias values', (tester) async {
      final aliasRepository = _FakeCategoryAliasRepository([
        _alias(id: 'alias-1', name: 'KFC'),
        _alias(id: 'alias-2', name: 'Metro Market', categoryId: 'shopping'),
      ]);

      await _pumpCategories(
        tester,
        categories: [_category()],
        aliasRepository: aliasRepository,
      );

      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add_category_alias_button')));
      await tester.pump();

      expect(find.text('Alias cannot be empty.'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('category_alias_input')), ' kfc ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('This alias already exists.'), findsOneWidget);
      expect(aliasRepository.created, isEmpty);

      await tester.enterText(
        find.byKey(const Key('category_alias_input')),
        'metro market',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('This alias already exists.'), findsOneWidget);
      expect(aliasRepository.created, isEmpty);
    });

    testWidgets('does not allow adding aliases to archived categories', (tester) async {
      final aliasRepository = _FakeCategoryAliasRepository([
        _alias(id: 'alias-1', name: 'Old merchant'),
      ]);

      await _pumpCategories(
        tester,
        categories: [_category(isArchived: true)],
        aliasRepository: aliasRepository,
      );

      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      expect(find.text('Old merchant'), findsOneWidget);
      expect(
        find.text('Archived categories cannot receive new aliases.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('category_alias_input')), findsNothing);
    });
  });
}

Future<void> _pumpCategories(
  WidgetTester tester, {
  required List<Category> categories,
  required CategoryAliasRepository aliasRepository,
}) async {
  await tester.pumpWidget(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CategoryAliasRepository>.value(value: aliasRepository),
      ],
      child: BlocProvider<CategoryBloc>(
        create: (_) => _LoadedCategoryBloc(categories),
        child: MaterialApp(
          theme: AppTheme.light,
          home: const CategoriesScreen(),
        ),
      ),
    ),
  );
  await tester.pump();
}

Category _category({bool isArchived = false}) {
  return Category(
    categoryId: 'food',
    userId: 'user-1',
    name: 'Food',
    totalExpenses: 0,
    icon: 'restaurant',
    color: 0xFFFF7043,
    isArchived: isArchived,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
}

CategoryAlias _alias({
  required String id,
  required String name,
  String categoryId = 'food',
}) {
  return CategoryAlias(
    aliasId: id,
    userId: 'user-1',
    name: name,
    categoryId: categoryId,
    createdAt: DateTime.utc(2026),
  );
}

class _LoadedCategoryBloc extends CategoryBloc {
  _LoadedCategoryBloc(List<Category> categories) : super(_FakeCategoryRepository(), 'user-1') {
    emit(CategoryLoaded(categories));
  }
}

class _FakeCategoryRepository implements CategoryRepository {
  @override
  Future<void> archiveCategory(Category category) async {}

  @override
  Future<void> createCategory(Category category) async {}

  @override
  Future<List<Category>> getCategories({bool includeArchived = false}) async => const [];

  @override
  Future<void> updateCategory(Category category) async {}

  @override
  Stream<List<Category>> watchCategories({bool includeArchived = false}) => const Stream.empty();
}

class _FakeCategoryAliasRepository implements CategoryAliasRepository {
  _FakeCategoryAliasRepository(List<CategoryAlias> aliases) : _aliases = [...aliases];

  final List<CategoryAlias> _aliases;
  final List<CategoryAlias> created = [];
  final List<String> deleted = [];

  @override
  Future<void> createAlias(CategoryAlias alias) async {
    created.add(alias);
    _aliases.add(alias);
  }

  @override
  Future<void> deleteAlias(String aliasId) async {
    deleted.add(aliasId);
    _aliases.removeWhere((alias) => alias.aliasId == aliasId);
  }

  @override
  Future<List<CategoryAlias>> getAliases() async => [..._aliases];

  @override
  Stream<List<CategoryAlias>> watchAliases() => Stream.value([..._aliases]);
}
