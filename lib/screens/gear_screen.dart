import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GearItem {
  final String id;
  String name;
  double weightKg;
  bool isChecked;
  bool isCustom;
  final String category;

  GearItem({
    required this.id,
    required this.name,
    required this.weightKg,
    required this.category,
    this.isChecked = false,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'weightKg': weightKg,
    'isChecked': isChecked,
    'isCustom': isCustom,
    'category': category,
  };

  factory GearItem.fromJson(Map<String, dynamic> json) => GearItem(
    id: json['id'],
    name: json['name'],
    weightKg: (json['weightKg'] as num).toDouble(),
    isChecked: json['isChecked'] ?? false,
    isCustom: json['isCustom'] ?? false,
    category: json['category'],
  );
}

class GearScreen extends StatefulWidget {
  const GearScreen({super.key});

  @override
  State<GearScreen> createState() => _GearScreenState();
}

class _GearScreenState extends State<GearScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTrek = 'General';
  List<GearItem> _items = [];
  bool _isLoading = true;

  final List<String> _treks = [
    'General',
    'Everest Base Camp',
    'Annapurna Circuit',
    'Langtang Valley',
    'Poon Hill',
    'Manaslu Circuit',
  ];

  final Map<String, List<Map<String, dynamic>>> _defaultGear = {
    'General': [
      // Clothing
      {'name': 'Moisture-wicking base layer', 'weight': 0.3, 'category': 'Clothing'},
      {'name': 'Fleece jacket', 'weight': 0.5, 'category': 'Clothing'},
      {'name': 'Waterproof jacket', 'weight': 0.6, 'category': 'Clothing'},
      {'name': 'Hiking pants', 'weight': 0.4, 'category': 'Clothing'},
      {'name': 'Thermal underwear', 'weight': 0.3, 'category': 'Clothing'},
      {'name': 'Wool socks (3 pairs)', 'weight': 0.3, 'category': 'Clothing'},
      {'name': 'Sun hat', 'weight': 0.1, 'category': 'Clothing'},
      {'name': 'Warm beanie', 'weight': 0.1, 'category': 'Clothing'},
      {'name': 'Gloves', 'weight': 0.2, 'category': 'Clothing'},
      // Footwear
      {'name': 'Hiking boots', 'weight': 1.2, 'category': 'Footwear'},
      {'name': 'Camp sandals', 'weight': 0.3, 'category': 'Footwear'},
      {'name': 'Gaiters', 'weight': 0.2, 'category': 'Footwear'},
      // Navigation
      {'name': 'Trail map', 'weight': 0.1, 'category': 'Navigation'},
      {'name': 'Compass', 'weight': 0.1, 'category': 'Navigation'},
      {'name': 'Headlamp + batteries', 'weight': 0.2, 'category': 'Navigation'},
      // Safety
      {'name': 'First aid kit', 'weight': 0.5, 'category': 'Safety'},
      {'name': 'Altitude sickness pills', 'weight': 0.1, 'category': 'Safety'},
      {'name': 'Whistle', 'weight': 0.05, 'category': 'Safety'},
      {'name': 'Emergency blanket', 'weight': 0.1, 'category': 'Safety'},
      {'name': 'Sunscreen SPF 50+', 'weight': 0.2, 'category': 'Safety'},
      // Shelter
      {'name': 'Sleeping bag (-10°C)', 'weight': 1.5, 'category': 'Shelter'},
      {'name': 'Sleeping bag liner', 'weight': 0.3, 'category': 'Shelter'},
      // Food & Water
      {'name': 'Water bottles (2x1L)', 'weight': 0.3, 'category': 'Food & Water'},
      {'name': 'Water purification tablets', 'weight': 0.05, 'category': 'Food & Water'},
      {'name': 'Energy bars (5)', 'weight': 0.3, 'category': 'Food & Water'},
      // Tech
      {'name': 'Phone + charger', 'weight': 0.3, 'category': 'Tech'},
      {'name': 'Power bank', 'weight': 0.3, 'category': 'Tech'},
      {'name': 'Camera', 'weight': 0.5, 'category': 'Tech'},
      // Documents
      {'name': 'Passport', 'weight': 0.05, 'category': 'Documents'},
      {'name': 'TIMS card', 'weight': 0.01, 'category': 'Documents'},
      {'name': 'Travel insurance', 'weight': 0.01, 'category': 'Documents'},
      {'name': 'Emergency contacts card', 'weight': 0.01, 'category': 'Documents'},
    ],
    'Everest Base Camp': [
      {'name': 'Down jacket (-20°C rated)', 'weight': 1.0, 'category': 'Clothing'},
      {'name': 'Thermal base layers (2 sets)', 'weight': 0.6, 'category': 'Clothing'},
      {'name': 'Waterproof pants', 'weight': 0.4, 'category': 'Clothing'},
      {'name': 'Heavy duty gloves', 'weight': 0.3, 'category': 'Clothing'},
      {'name': 'Balaclava', 'weight': 0.1, 'category': 'Clothing'},
      {'name': 'Mountaineering boots', 'weight': 1.8, 'category': 'Footwear'},
      {'name': 'Crampons', 'weight': 1.0, 'category': 'Footwear'},
      {'name': 'Trekking poles', 'weight': 0.6, 'category': 'Equipment'},
      {'name': 'Sleeping bag (-20°C)', 'weight': 2.0, 'category': 'Shelter'},
      {'name': 'Diamox (acetazolamide)', 'weight': 0.05, 'category': 'Safety'},
      {'name': 'Pulse oximeter', 'weight': 0.05, 'category': 'Safety'},
      {'name': 'Dexamethasone (emergency)', 'weight': 0.05, 'category': 'Safety'},
      {'name': 'EBC permit', 'weight': 0.01, 'category': 'Documents'},
      {'name': 'Sagarmatha National Park permit', 'weight': 0.01, 'category': 'Documents'},
      {'name': 'UV protection goggles', 'weight': 0.1, 'category': 'Safety'},
      {'name': 'Lip balm SPF', 'weight': 0.05, 'category': 'Safety'},
      {'name': 'Satellite communicator', 'weight': 0.2, 'category': 'Tech'},
    ],
    'Annapurna Circuit': [
      {'name': 'Down jacket', 'weight': 0.8, 'category': 'Clothing'},
      {'name': 'Wind stopper jacket', 'weight': 0.5, 'category': 'Clothing'},
      {'name': 'Convertible pants', 'weight': 0.4, 'category': 'Clothing'},
      {'name': 'Trekking poles', 'weight': 0.6, 'category': 'Equipment'},
      {'name': 'Sleeping bag (-15°C)', 'weight': 1.8, 'category': 'Shelter'},
      {'name': 'Thorong La pass gear', 'weight': 0.3, 'category': 'Equipment'},
      {'name': 'Annapurna Conservation permit', 'weight': 0.01, 'category': 'Documents'},
      {'name': 'TIMS card', 'weight': 0.01, 'category': 'Documents'},
      {'name': 'Altitude sickness pills', 'weight': 0.1, 'category': 'Safety'},
      {'name': 'Hand warmers (5 pairs)', 'weight': 0.2, 'category': 'Safety'},
    ],
    'Langtang Valley': [
      {'name': 'Fleece jacket', 'weight': 0.5, 'category': 'Clothing'},
      {'name': 'Waterproof jacket', 'weight': 0.6, 'category': 'Clothing'},
      {'name': 'Trekking poles', 'weight': 0.6, 'category': 'Equipment'},
      {'name': 'Sleeping bag (-10°C)', 'weight': 1.5, 'category': 'Shelter'},
      {'name': 'Langtang National Park permit', 'weight': 0.01, 'category': 'Documents'},
      {'name': 'TIMS card', 'weight': 0.01, 'category': 'Documents'},
      {'name': 'Altitude medicine', 'weight': 0.1, 'category': 'Safety'},
    ],
    'Poon Hill': [
      {'name': 'Warm jacket', 'weight': 0.6, 'category': 'Clothing'},
      {'name': 'Light rain jacket', 'weight': 0.4, 'category': 'Clothing'},
      {'name': 'Light sleeping bag', 'weight': 1.0, 'category': 'Shelter'},
      {'name': 'Annapurna Conservation permit', 'weight': 0.01, 'category': 'Documents'},
      {'name': 'TIMS card', 'weight': 0.01, 'category': 'Documents'},
      {'name': 'Sunrise alarm', 'weight': 0.0, 'category': 'Tech'},
    ],
    'Manaslu Circuit': [
      {'name': 'Down jacket (-15°C)', 'weight': 0.9, 'category': 'Clothing'},
      {'name': 'Trekking poles', 'weight': 0.6, 'category': 'Equipment'},
      {'name': 'Sleeping bag (-15°C)', 'weight': 1.8, 'category': 'Shelter'},
      {'name': 'Manaslu restricted area permit', 'weight': 0.01, 'category': 'Documents'},
      {'name': 'Manaslu Conservation permit', 'weight': 0.01, 'category': 'Documents'},
      {'name': 'TIMS card', 'weight': 0.01, 'category': 'Documents'},
      {'name': 'Altitude medicine', 'weight': 0.1, 'category': 'Safety'},
      {'name': 'Larkya La pass crampons', 'weight': 1.0, 'category': 'Equipment'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadItems();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _cacheKey => 'gear_${_selectedTrek.replaceAll(' ', '_')}';

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_cacheKey);

    if (saved != null) {
      final list = jsonDecode(saved) as List;
      setState(() {
        _items = list.map((e) => GearItem.fromJson(e)).toList();
        _isLoading = false;
      });
    } else {
      final defaults = _defaultGear[_selectedTrek] ?? _defaultGear['General']!;
      setState(() {
        _items = defaults.map((g) => GearItem(
          id: '${_selectedTrek}_${g['name']}',
          name: g['name'] as String,
          weightKg: (g['weight'] as num).toDouble(),
          category: g['category'] as String,
        )).toList();
        _isLoading = false;
      });
      await _saveItems();
    }
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  void _toggleItem(GearItem item) {
    setState(() => item.isChecked = !item.isChecked);
    _saveItems();
  }

  void _deleteItem(GearItem item) {
    setState(() => _items.remove(item));
    _saveItems();
  }

  void _resetChecklist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await _loadItems();
  }

  void _showAddItemSheet() {
    final nameController = TextEditingController();
    final weightController = TextEditingController();
    String selectedCategory = 'Equipment';
    final categories = ['Clothing', 'Footwear', 'Equipment', 'Safety', 'Shelter', 'Food & Water', 'Tech', 'Documents'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Add Custom Item', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Item name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green[700]!),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green[700]!),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setSheet(() => selectedCategory = v!),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (nameController.text.isEmpty) return;
                    final item = GearItem(
                      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                      name: nameController.text,
                      weightKg: double.tryParse(weightController.text) ?? 0.0,
                      category: selectedCategory,
                      isCustom: true,
                    );
                    setState(() => _items.add(item));
                    _saveItems();
                    Navigator.pop(context);
                  },
                  child: const Text('Add Item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, List<GearItem>> get _groupedItems {
    final Map<String, List<GearItem>> grouped = {};
    for (final item in _items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    return grouped;
  }

  double get _totalWeight => _items.fold(0, (sum, item) => sum + item.weightKg);
  double get _checkedWeight => _items.where((i) => i.isChecked).fold(0, (sum, item) => sum + item.weightKg);
  int get _checkedCount => _items.where((i) => i.isChecked).length;
  double get _progress => _items.isEmpty ? 0 : _checkedCount / _items.length;

  Color _categoryColor(String category) {
    switch (category) {
      case 'Clothing': return Colors.blue[600]!;
      case 'Footwear': return Colors.brown[600]!;
      case 'Equipment': return Colors.orange[600]!;
      case 'Safety': return Colors.red[600]!;
      case 'Shelter': return Colors.purple[600]!;
      case 'Food & Water': return Colors.teal[600]!;
      case 'Tech': return Colors.indigo[600]!;
      case 'Documents': return Colors.green[600]!;
      default: return Colors.grey[600]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F3),
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        title: const Text('Gear Checklist', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Reset Checklist'),
                content: const Text('This will uncheck all items and remove custom items. Continue?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () { Navigator.pop(context); _resetChecklist(); },
                    child: Text('Reset', style: TextStyle(color: Colors.red[700])),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        onPressed: _showAddItemSheet,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Column(
        children: [
          // ── Trek Selector ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _treks.map((trek) {
                  final selected = _selectedTrek == trek;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedTrek = trek);
                      _loadItems();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? Colors.green[700] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        trek,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.grey[700],
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Progress + Weight ──
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_checkedCount / ${_items.length} items packed',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.038),
                        ),
                        Text(
                          '${(_progress * 100).toStringAsFixed(0)}% ready',
                          style: TextStyle(color: Colors.grey[500], fontSize: screenWidth * 0.03),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_checkedWeight.toStringAsFixed(1)} kg packed',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                        Text(
                          'Total: ${_totalWeight.toStringAsFixed(1)} kg',
                          style: TextStyle(color: Colors.grey[500], fontSize: screenWidth * 0.028),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey[200],
                    color: _progress == 1 ? Colors.green[700] : Colors.green[400],
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          // ── Items List ──
          Expanded(
            child: _items.isEmpty
                ? Center(
              child: Text('No items. Tap + to add.', style: TextStyle(color: Colors.grey[500])),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemCount: _groupedItems.keys.length,
              itemBuilder: (context, index) {
                final category = _groupedItems.keys.elementAt(index);
                final items = _groupedItems[category]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _categoryColor(category),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.038,
                              color: _categoryColor(category),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${items.where((i) => i.isChecked).length}/${items.length}',
                            style: TextStyle(color: Colors.grey[500], fontSize: screenWidth * 0.03),
                          ),
                        ],
                      ),
                    ),
                    ...items.map((item) => _gearItemCard(item, screenWidth)),
                    const SizedBox(height: 4),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _gearItemCard(GearItem item, double screenWidth) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteItem(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: item.isChecked ? Colors.green[50] : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isChecked ? Colors.green[200]! : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: GestureDetector(
            onTap: () => _toggleItem(item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: item.isChecked ? Colors.green[700] : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.isChecked ? Colors.green[700]! : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: item.isChecked
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          title: Text(
            item.name,
            style: TextStyle(
              fontSize: screenWidth * 0.036,
              fontWeight: FontWeight.w500,
              decoration: item.isChecked ? TextDecoration.lineThrough : null,
              color: item.isChecked ? Colors.grey[400] : Colors.black87,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.isCustom)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Custom', style: TextStyle(color: Colors.blue[700], fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              Text(
                '${item.weightKg.toStringAsFixed(2)} kg',
                style: TextStyle(color: Colors.grey[500], fontSize: screenWidth * 0.028),
              ),
            ],
          ),
          onTap: () => _toggleItem(item),
        ),
      ),
    );
  }
}