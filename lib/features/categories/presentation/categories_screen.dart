import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/core/widgets/empty_state.dart';
import 'package:expenses_tracker/core/widgets/gradient_button.dart';
import 'package:expenses_tracker/features/categories/category_bloc/category_bloc.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              return Column(
                children: [
                  AppTopBar(
                    title: 'Categories',
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: 'Add Category',
                      onPressed: () => _showCategoryForm(context),
                    ),
                  ),
                  Expanded(
                    child: _buildBody(context, state),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryForm(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CategoryState state) {
    if (state is CategoryLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is CategoryError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text(
                state.message,
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (state is CategoryLoaded) {
      final categories = state.categories;
      if (categories.isEmpty) {
        return const EmptyState(
          icon: Icons.category_outlined,
          title: 'No categories yet',
          subtitle: 'Tap the + button to add your first category',
        );
      }

      return ListView.builder(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.containerPadding,
          AppSpacing.sm,
          AppSpacing.containerPadding,
          80, // space for FAB
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _CategoryCard(
            category: category,
            onTap: () => _showCategoryForm(context, existingCategory: category),
            onArchive: () => _confirmArchive(context, category),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _showCategoryForm(BuildContext context, {Category? existingCategory}) async {
    final result = await showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CategoryFormDialog(existingCategory: existingCategory),
    );

    if (result != null && context.mounted) {
      final bloc = context.read<CategoryBloc>();
      if (existingCategory != null) {
        bloc.add(UpdateCategory(result));
      } else {
        bloc.add(CreateCategory(result));
      }
    }
  }

  void _confirmArchive(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archive Category'),
        content: Text('Archive "${category.name}"? It will be hidden from new expenses.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<CategoryBloc>().add(ArchiveCategory(category.categoryId));
            },
            child: const Text('Archive', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final VoidCallback onArchive;

  const _CategoryCard({
    required this.category,
    required this.onTap,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(category.color);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.cardGutter),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _iconFromName(category.icon),
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface),
                  ),
                  if (category.isArchived) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.archive, size: 14, color: AppColors.outline),
                        const SizedBox(width: 4),
                        Text(
                          'Archived',
                          style: AppTextStyles.labelCaps.copyWith(color: AppColors.outline),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: Icon(
                isRtl ? Icons.archive : Icons.archive_outlined,
                size: 20,
                color: AppColors.outline,
              ),
              tooltip: 'Archive',
              onPressed: onArchive,
            ),
            Icon(
              isRtl ? Icons.chevron_left : Icons.chevron_right,
              size: 20,
              color: AppColors.outlineVariant,
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFromName(String name) {
    // Try to resolve the icon string to an actual IconData.
    // We look up the icon by its string name.
    // The repository stores icon names like 'restaurant', 'home', etc.
    // The safest approach: use a switch or map.
    try {
      return _iconMap[name] ?? Icons.more_horiz;
    } catch (_) {
      return Icons.more_horiz;
    }
  }

  static const _iconMap = <String, IconData>{
    'restaurant': Icons.restaurant,
    'local_taxi': Icons.local_taxi,
    'shopping_bag': Icons.shopping_bag,
    'home': Icons.home,
    'movie': Icons.movie,
    'local_hospital': Icons.local_hospital,
    'school': Icons.school,
    'bolt': Icons.bolt,
    'face': Icons.face,
    'more_horiz': Icons.more_horiz,
    'flight': Icons.flight,
    'beach_access': Icons.beach_access,
    'pets': Icons.pets,
    'fitness_center': Icons.fitness_center,
    'work': Icons.work,
    'favorite': Icons.favorite,
    'music_note': Icons.music_note,
    'book': Icons.book,
    'shopping_cart': Icons.shopping_cart,
    'directions_car': Icons.directions_car,
    'directions_bus': Icons.directions_bus,
    'local_gas_station': Icons.local_gas_station,
    'local_pharmacy': Icons.local_pharmacy,
    'local_grocery_store': Icons.local_grocery_store,
    'coffee': Icons.coffee,
    'fastfood': Icons.fastfood,
    'cake': Icons.cake,
    'sports_esports': Icons.sports_esports,
    'computer': Icons.computer,
    'smartphone': Icons.smartphone,
    'checkroom': Icons.checkroom,
    'child_care': Icons.child_care,
    'cleaning_services': Icons.cleaning_services,
    'savings': Icons.savings,
    'account_balance': Icons.account_balance,
    'credit_card': Icons.credit_card,
    'card_giftcard': Icons.card_giftcard,
  };
}

class _CategoryFormDialog extends StatefulWidget {
  const _CategoryFormDialog({this.existingCategory});
  final Category? existingCategory;

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _nameCtrl = TextEditingController();
  String _icon = 'restaurant';
  int _color = 0xFFFF7043;

  static const _icons = ['restaurant', 'local_taxi', 'shopping_bag', 'home', 'movie', 'local_hospital', 'school', 'bolt', 'flight', 'more_horiz'];
  static const _colors = [0xFFFF7043, 0xFF42A5F5, 0xFFAB47BC, 0xFF66BB6A, 0xFFFFCA28, 0xFFEF5350, 0xFF78909C, 0xFF8D6E63, 0xFF26C6DA, 0xFFBDBDBD];

  @override
  void initState() {
    super.initState();
    if (widget.existingCategory != null) {
      _nameCtrl.text = widget.existingCategory!.name;
      _icon = widget.existingCategory!.icon;
      _color = widget.existingCategory!.color;
    }
  }

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.containerPadding),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: AppSpacing.lg),
          Text(widget.existingCategory != null ? 'Edit Category' : 'New Category', style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface)),
          const SizedBox(height: AppSpacing.md),
          TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'Name', filled: true, fillColor: AppColors.surfaceContainerLow, border: const OutlineInputBorder(borderSide: BorderSide.none))),
          const SizedBox(height: AppSpacing.md),
          Text('Icon', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(spacing: 8, runSpacing: 8, children: _icons.map((i) => GestureDetector(
            onTap: () => setState(() => _icon = i),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _icon == i ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(CategoriesScreen._iconMap[i] ?? Icons.circle, size: 20, color: _icon == i ? AppColors.primary : AppColors.onSurfaceVariant),
            ),
          )).toList()),
          const SizedBox(height: AppSpacing.md),
          Text('Color', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(spacing: 8, runSpacing: 8, children: _colors.map((c) => GestureDetector(
            onTap: () => setState(() => _color = c),
            child: Container(
              width: 32, height: 32, decoration: BoxDecoration(color: Color(c), shape: BoxShape.circle),
              foregroundDecoration: _color == c ? BoxDecoration(border: Border.all(color: AppColors.onSurface, width: 2), shape: BoxShape.circle) : null,
            ),
          )).toList()),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: Text(widget.existingCategory != null ? 'Update' : 'Create'),
          ),
          const SizedBox(height: AppSpacing.sm),
        ]),
      ),
    );
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final category = Category(
      categoryId: widget.existingCategory?.categoryId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name, icon: _icon, color: _color,
      totalExpenses: widget.existingCategory?.totalExpenses ?? 0,
      isArchived: widget.existingCategory?.isArchived ?? false,
    );
    Navigator.pop(context, category);
  }
}
