import 'models/category_alias.dart';

abstract class CategoryAliasRepository {
  Future<void> createAlias(CategoryAlias alias);
  Future<void> deleteAlias(String aliasId);
  Future<List<CategoryAlias>> getAliases();
  Stream<List<CategoryAlias>> watchAliases();
}
