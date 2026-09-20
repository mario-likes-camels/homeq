import 'package:flutter/material.dart';
import '../widgets/calendar_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  double _leftPaneWidth = 320;
  double _rightPaneWidth = 320;
  String _currentUser = 'Patrick';
  DateTime _selectedDate = DateTime.now();

  // Item inspection mode for center view ('calendar', 'recipe_detail', 'chore_detail')
  String _centerMode = 'calendar';
  Map<String, dynamic>? _selectedDetailItem;

  // Master Data Structures with Assignment & Details
  final Map<String, Map<String, dynamic>> _choresData = {
    'Vacuum House': {'completed': false, 'assignee': 'Patrick', 'dueDate': '2026-09-20', 'priority': 'High', 'instructions': 'Use HEPA filter attachment. Clear living room and hallway.'},
    'Pool Clean': {'completed': false, 'assignee': 'Sarah', 'dueDate': '2026-09-21', 'priority': 'Medium', 'instructions': 'Skim surface leaves, empty pump basket, test chlorine levels.'},
    'Shopping Run': {'completed': true, 'assignee': 'Patrick', 'dueDate': '2026-09-20', 'priority': 'High', 'instructions': 'Get organic milk, eggs, and fresh vegetables from local grocer.'},
    'Cook Lasagne': {'completed': false, 'assignee': 'Shared', 'dueDate': '2026-09-20', 'priority': 'High', 'instructions': 'Bake at 180°C for 45 mins. Let rest for 10 minutes before serving.'},
    'Bathroom Clean': {'completed': false, 'assignee': 'Sarah', 'dueDate': '2026-09-25', 'priority': 'Medium', 'instructions': 'Scrub tiles, sanitize shower glass and floor.'},
  };

  final Map<String, Map<String, dynamic>> _shoppingData = {
    'Milk & Eggs': {'completed': false, 'assignee': 'Patrick', 'dueDate': '2026-09-20'},
    'Chicken Breast': {'completed': false, 'assignee': 'Sarah', 'dueDate': '2026-09-22'},
    'Olive Oil': {'completed': true, 'assignee': 'Patrick', 'dueDate': '2026-09-20'},
    'Coffee Beans': {'completed': false, 'assignee': 'Shared', 'dueDate': '2026-09-23'},
  };

  final Map<String, Map<String, dynamic>> _recipesData = {
    'Homemade Lasagne': {
      'completed': false,
      'assignee': 'Patrick',
      'prepTime': '45 mins',
      'ingredients': ['Pasta sheets', 'Ground beef', 'Tomato passata', 'Mozzarella', 'Ricotta'],
      'instructions': '1. Brown the beef with onions and garlic.\n2. Layer pasta, meat sauce, and cheese in baking tray.\n3. Bake at 180°C for 45 minutes until golden brown.'
    },
    'Garlic Chicken & Salad': {
      'completed': true,
      'assignee': 'Sarah',
      'prepTime': '25 mins',
      'ingredients': ['Chicken breasts', 'Minced garlic', 'Olive oil', 'Mixed salad greens'],
      'instructions': '1. Marinate chicken in garlic and oil.\n2. Pan-sear for 6 mins per side.\n3. Serve alongside fresh salad greens.'
    },
  };

  // Dynamic HomeQ Score Calculation based on completed vs remaining items
  int _calculateScore() {
    int total = _choresData.length + _shoppingData.length;
    int completed = _choresData.values.where((e) => e['completed'] == true).length +
                    _shoppingData.values.where((e) => e['completed'] == true).length;
    
    if (total == 0) return 50;
    // Base score formula: percentage of completed tasks, with penalties for remaining items
    double baseScore = (completed / total) * 100;
    int uncompletedCount = total - completed;
    int penalty = uncompletedCount * 3; // Decay penalty for chores left hanging
    
    int finalScore = (baseScore + 40 - penalty).round();
    if (finalScore > 100) return 100;
    if (finalScore < 10) return 10;
    return finalScore;
  }

  // Get items for the selected calendar date
  List<MapEntry<String, Map<String, dynamic>>> _getItemsForSelectedDate() {
    String dateKey = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
    
    List<MapEntry<String, Map<String, dynamic>>> matches = [];
    _choresData.forEach((key, value) {
      if (value['dueDate'] == dateKey) {
        matches.add(MapEntry(key, value));
      }
    });
    _shoppingData.forEach((key, value) {
      if (value['dueDate'] == dateKey) {
        matches.add(MapEntry(key, value));
      }
    });
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    int currentScore = _calculateScore();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('HomeQ Command Center', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          // User Switcher
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.account_circle, color: Colors.teal),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _currentUser,
                  underline: const SizedBox(),
                  items: <String>['Patrick', 'Sarah', 'Household Shared'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) setState(() => _currentUser = newValue);
                  },
                ),
                const SizedBox(width: 24),
                Stack(
                  alignment: Alignment.topRight,
                  children: const [
                    Icon(Icons.notifications_none, size: 28, color: Colors.black87),
                    CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text('3', style: TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // ================= LEFT PANE: TABS (Chores, Shopping, Recipes) =================
          SizedBox(
            width: _leftPaneWidth,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    const TabBar(
                      labelColor: Colors.teal,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.teal,
                      tabs: [
                        Tab(text: 'Chores', icon: Icon(Icons.task, size: 16)),
                        Tab(text: 'Shopping', icon: Icon(Icons.shopping_cart, size: 16)),
                        Tab(text: 'Recipes', icon: Icon(Icons.restaurant_menu, size: 16)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildChoreListPane(),
                          _buildShoppingListPane(),
                          _buildRecipeListPane(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Dynamic HomeQ Score Card (Updates instantly on tick)
                    Card(
                      elevation: 2,
                      color: currentScore > 75 ? Colors.teal.shade50 : Colors.orange.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("HOMEQ SCORE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal)),
                            Text("$currentScore / 100", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: currentScore > 75 ? Colors.teal : Colors.orange.shade800)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Resize Handle 1
          MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanUpdate: (details) {
                setState(() {
                  _leftPaneWidth += details.delta.dx;
                  if (_leftPaneWidth < 250) _leftPaneWidth = 250;
                  if (_leftPaneWidth > 500) _leftPaneWidth = 500;
                });
              },
              child: Container(width: 8, color: Colors.transparent, child: const Center(child: VerticalDivider(thickness: 2)))),
          ),

          // ================= CENTER COLUMN: CALENDAR OR ITEM INSPECTION VIEW =================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: _centerMode == 'calendar'
                  ? CalendarWidget(
                      onDaySelectedCallback: (date) {
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                    )
                  : _buildCenterDetailCard(),
            ),
          ),

          // Resize Handle 2
          MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanUpdate: (details) {
                setState(() {
                  _rightPaneWidth -= details.delta.dx;
                  if (_rightPaneWidth < 250) _rightPaneWidth = 250;
                  if (_rightPaneWidth > 500) _rightPaneWidth = 500;
                });
              },
              child: Container(width: 8, color: Colors.transparent, child: const Center(child: VerticalDivider(thickness: 2)))),
          ),

          // ================= RIGHT PANE: DAY INSPECTOR & ALERTS =================
          SizedBox(
            width: _rightPaneWidth,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "INSPECTOR: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                      if (_centerMode != 'calendar')
                        TextButton(
                          onPressed: () => setState(() => _centerMode = 'calendar'),
                          child: const Text("Back to Calendar", style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 2,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildDayInspectorContent(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "UPCOMING ALERTS",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 1,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        children: const [
                          ListTile(
                            leading: Icon(Icons.water_drop, color: Colors.red),
                            title: Text("Pool Clean", style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Tomorrow (Sarah)"),
                          ),
                          Divider(height: 1),
                          ListTile(
                            leading: Icon(Icons.warning_amber_rounded, color: Colors.orange),
                            title: Text("Chicken Expiry", style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("2 Days Remaining"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // List Builders for Tabs
  Widget _buildChoreListPane() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: _choresData.keys.map((String key) {
          final item = _choresData[key]!;
          return CheckboxListTile(
            value: item['completed'],
            onChanged: (bool? value) {
              setState(() => item['completed'] = value ?? false);
            },
            title: InkWell(
              onTap: () {
                setState(() {
                  _centerMode = 'chore_detail';
                  _selectedDetailItem = {'name': key, ...item};
                });
              },
              child: Text(
                key,
                style: TextStyle(
                  decoration: item['completed'] ? TextDecoration.lineThrough : TextDecoration.none,
                  color: item['completed'] ? Colors.grey : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            subtitle: Text("Assigned: ${item['assignee']} • Due: ${item['dueDate']}", style: const TextStyle(fontSize: 11)),
            secondary: IconButton(
              icon: const Icon(Icons.info_outline, size: 18),
              onPressed: () {
                setState(() {
                  _centerMode = 'chore_detail';
                  _selectedDetailItem = {'name': key, ...item};
                });
              },
            ),
            dense: true,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildShoppingListPane() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: _shoppingData.keys.map((String key) {
          final item = _shoppingData[key]!;
          return CheckboxListTile(
            value: item['completed'],
            onChanged: (bool? value) {
              setState(() => item['completed'] = value ?? false);
            },
            title: Text(
              key,
              style: TextStyle(
                decoration: item['completed'] ? TextDecoration.lineThrough : TextDecoration.none,
                color: item['completed'] ? Colors.grey : Colors.black87,
              ),
            ),
            subtitle: Text("Assignee: ${item['assignee']}", style: const TextStyle(fontSize: 11)),
            dense: true,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecipeListPane() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: _recipesData.keys.map((String key) {
          final recipe = _recipesData[key]!;
          return ListTile(
            leading: const Icon(Icons.restaurant_menu, color: Colors.teal),
            title: Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Prep: ${recipe['prepTime']} • ${recipe['assignee']}", style: const TextStyle(fontSize: 11)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              setState(() {
                _centerMode = 'recipe_detail';
                _selectedDetailItem = {'name': key, ...recipe};
              });
            },
          );
        }).toList(),
      ),
    );
  }

  // Day Inspector List Content based on selected date
  Widget _buildDayInspectorContent() {
    final items = _getItemsForSelectedDate();

    if (items.isEmpty) {
      return const Center(
        child: Text(
          "No tasks or items scheduled for this date.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView(
      children: [
        const Text("Scheduled for Date:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        ...items.map((entry) {
          final name = entry.key;
          final data = entry.value;
          return CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: data['completed'],
            onChanged: (val) {
              setState(() => data['completed'] = val ?? false);
            },
            title: Text(name, style: TextStyle(fontWeight: FontWeight.w600, decoration: data['completed'] ? TextDecoration.lineThrough : null)),
            subtitle: Text("Assignee: ${data['assignee']}", style: const TextStyle(fontSize: 11)),
          );
        }),
      ],
    );
  }

  // Center Pane Operational Card for Recipes & Chores
  Widget _buildCenterDetailCard() {
    if (_selectedDetailItem == null) return const SizedBox();

    bool isRecipe = _centerMode == 'recipe_detail';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(isRecipe ? Icons.restaurant_menu : Icons.task_alt, color: Colors.teal, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDetailItem!['name'],
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _centerMode = 'calendar'),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Chip(label: Text("Assigned: ${_selectedDetailItem!['assignee']}")),
                const SizedBox(width: 12),
                if (isRecipe) Chip(label: Text("Prep Time: ${_selectedDetailItem!['prepTime']}")),
                if (!isRecipe) Chip(label: Text("Priority: ${_selectedDetailItem!['priority']}")),
              ],
            ),
            const SizedBox(height: 16),
            if (isRecipe) ...[
              const Text("Ingredients:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ...((_selectedDetailItem!['ingredients'] as List<String>).map((ing) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(children: [const Icon(Icons.fiber_manual_record, size: 8, color: Colors.teal), const SizedBox(width: 8), Text(ing)]),
                  ))),
              const SizedBox(height: 16),
            ],
            const Text("Instructions / Details:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(_selectedDetailItem!['instructions'] ?? 'No extra instructions provided.', style: const TextStyle(fontSize: 15, height: 1.4)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  onPressed: () => setState(() => _centerMode = 'calendar'),
                  icon: const Icon(Icons.check),
                  label: const Text("Done / Return to Calendar"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}