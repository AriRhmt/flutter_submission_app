import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroceryItem {
  GroceryItem({required this.id, required this.name, required this.quantity});
  final String id;
  final String name;
  final int quantity;

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'quantity': quantity};
  factory GroceryItem.fromMap(Map<String, dynamic> map) => GroceryItem(
        id: map['id'] as String,
        name: map['name'] as String,
        quantity: (map['quantity'] as num).toInt(),
      );
}

class GroceryPage extends StatefulWidget {
  const GroceryPage({super.key});

  @override
  State<GroceryPage> createState() => _GroceryPageState();
}

class _GroceryPageState extends State<GroceryPage> {
  static const String _prefsKey = 'grocery_items';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController(text: '1');
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _qtyFocus = FocusNode();

  List<GroceryItem> _items = <GroceryItem>[];
  String _query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _nameFocus.dispose();
    _qtyFocus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_prefsKey) ?? <String>[];
    setState(() {
      _items = raw
          .map((e) => GroceryItem.fromMap(json.decode(e) as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      _loading = false;
    });
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = _items.map((e) => json.encode(e.toMap())).toList();
    await prefs.setStringList(_prefsKey, raw);
  }

  Future<void> _addItem() async {
    if (!_formKey.currentState!.validate()) return;
    final item = GroceryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      quantity: int.parse(_qtyController.text.trim()),
    );
    setState(() => _items = [..._items, item]);
    await _saveItems();
    _nameController.clear();
    _qtyController.text = '1';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to grocery list')));
      _nameFocus.requestFocus();
    }
  }

  Future<void> _removeItem(GroceryItem item) async {
    setState(() => _items = _items.where((e) => e.id != item.id).toList());
    await _saveItems();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removed "${item.name}"')));
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all items?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear')),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _items = <GroceryItem>[]);
    await _saveItems();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Grocery list cleared')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<GroceryItem> filtered = _items
        .where((e) => e.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery List'),
        actions: [
          IconButton(
            tooltip: 'Clear all',
            onPressed: _items.isEmpty ? null : _clearAll,
            icon: const Icon(Icons.delete_sweep_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Form(
                  key: _formKey,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final bool wide = constraints.maxWidth >= 700;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: wide ? 3 : 2,
                            child: TextFormField(
                              controller: _nameController,
                              focusNode: _nameFocus,
                              decoration: const InputDecoration(
                                hintText: 'Add item (e.g., Apples)',
                                prefixIcon: Icon(Icons.shopping_cart_rounded),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Enter item name';
                                if (v.trim().length < 2) return 'Too short';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12, height: 12),
                          SizedBox(
                            width: wide ? 160 : 120,
                            child: TextFormField(
                              controller: _qtyController,
                              focusNode: _qtyFocus,
                              decoration: const InputDecoration(
                                hintText: 'Qty',
                                prefixIcon: Icon(Icons.numbers_rounded),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Required';
                                final n = int.tryParse(v.trim());
                                if (n == null || n <= 0) return 'Invalid';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12, height: 12),
                          SizedBox(
                            height: 56,
                            child: FilledButton.icon(
                              onPressed: _addItem,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Add'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
            ),
            if (_loading) ...[
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
            ] else if (filtered.isEmpty) ...[
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.local_grocery_store_outlined, size: 64),
                      SizedBox(height: 8),
                      Text('No items found'),
                    ],
                  ),
                ),
              ),
            ] else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final double width = constraints.crossAxisExtent;
                    int columns = 1;
                    if (width >= 1200) {
                      columns = 4;
                    } else if (width >= 900) {
                      columns = 3;
                    } else if (width >= 600) {
                      columns = 2;
                    }
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 3.6,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = filtered[index];
                          return _GroceryTile(
                            item: item,
                            onDelete: () => _removeItem(item),
                          );
                        },
                        childCount: filtered.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GroceryTile extends StatefulWidget {
  const _GroceryTile({required this.item, required this.onDelete});
  final GroceryItem item;
  final VoidCallback onDelete;

  @override
  State<_GroceryTile> createState() => _GroceryTileState();
}

class _GroceryTileState extends State<_GroceryTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _pressed ? 0.98 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onHighlightChanged: (v) => setState(() => _pressed = v),
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
            boxShadow: const [BoxShadow(color: Color(0x140B0F1A), blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_rounded, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.name,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text('Qty: ${widget.item.quantity}', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}