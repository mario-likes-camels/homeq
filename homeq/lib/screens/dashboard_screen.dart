



import 'package:flutter/material.dart';
import '../widgets/calendar_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _leftPaneWidth = 330;
  double _rightPaneWidth = 320;
  String _currentUser = 'Patrick';
  DateTime _selectedDate = DateTime.now();

  String _centerMode = 'calendar';
  Map<String, dynamic>? _selectedDetailItem;

  // Master Chores Data
  final List<Map<String, dynamic>> _choresList = [
    {
      'id': 'chore_1',
      'name': 'Vacuum House',
      'completedDates': <String>[], // Tracks specific YYYY-MM-DD completions
      'assignee': 'Patrick',
      'assignedBy': 'Sarah',
      'dueDate': '2026-09-20',
      'recurrence': 'Weekly',
      'priority': 'High',
      'instructions': 'Use HEPA filter attachment. Clear living room and hallway.'
    },
    {
      'id': 'chore_2',
      'name': 'Pool Clean',
      'completedDates': <String>[],
      'assignee': 'Sarah',
      'assignedBy': 'Patrick',
      'dueDate': '2026-09-21',
      'recurrence': 'Weekly',
      'priority': 'Medium',
      'instructions': 'Skim surface leaves, empty pump basket, test chlorine levels.'
    },
    {
      'id': 'chore_3',
      'name': 'Bathroom Sanitize',
      'completedDates': <String>[],
      'assignee': 'Sarah',
      'assignedBy': 'Patrick',
      'dueDate': '2026-09-25',
      'recurrence': 'Weekly',
      'priority': 'Medium',
      'instructions': 'Scrub tiles, sanitize shower glass and floor.'
    },
  ];

  // Shopping List
  final List<Map<String, dynamic>> _shoppingList = [
    {'name': 'Organic Milk', 'completed': false, 'assignee': 'Patrick', 'source': 'Manual'},
    {'name': 'Free Range Eggs', 'completed': false, 'assignee': 'Patrick', 'source': 'Manual'},
    {'name': 'Olive Oil', 'completed': true, 'assignee': 'Patrick', 'source': 'Manual'},
  ];

  // Upcoming Alerts List (Dismissible)
  final List<Map<String, dynamic>> _alertsList = [
    {
      'id': 'alert_1',
      'title': 'Pool Clean',
      'subtitle': 'Tomorrow (Sarah)',
      'icon': Icons.water_drop,
      'color': Colors.red,
    },
    {
      'id': 'alert_2',
      'title': 'Chicken Expiry',
      'subtitle': '2 Days Remaining',
      'icon': Icons.warning_amber_rounded,
      'color': Colors.orange,
    },
  ];

  // Recipes Master List
  final Map<String, Map<String, dynamic>> _recipesData = {
    'Homemade Lasagne': {
      'prepTime': '45 mins',
      'ingredients': ['Pasta sheets', 'Ground beef', 'Tomato passata', 'Mozzarella', 'Ricotta'],
      'instructions': '1. Brown the beef with onions and garlic.\n2. Layer pasta, meat sauce, and cheese in baking tray.\n3. Bake at 180°C for 45 minutes until golden brown.'
    },
    'Garlic Chicken & Salad': {
      'prepTime': '25 mins',
      'ingredients': ['Chicken breasts', 'Minced garlic', 'Olive oil', 'Mixed salad greens'],
      'instructions': '1. Marinate chicken in garlic and oil.\n2. Pan-sear for 6 mins per side.\n3. Serve alongside fresh salad greens.'
    },
    'Vegetarian Curry': {
      'prepTime': '35 mins',
      'ingredients': ['Chickpeas', 'Coconut milk', 'Curry powder', 'Spinach', 'Basmati rice'],
      'instructions': '1. Sauté spices and aromatics.\n2. Simmer chickpeas in coconut milk for 20 mins.\n3. Stir in fresh spinach until wilted and serve over rice.'
    },
  };

  // Scheduled Meals Calendar Mapping
  final List<Map<String, dynamic>> _scheduledMeals = [
    {
      'recipeName': 'Homemade Lasagne',
      'date': '2026-09-20',
      'assignee': 'Patrick',
      'completed': false,
    }
  ];

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _dateToString(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  // Build combined events map with role visibility and dynamic icon removal when completed
  Map<String, List<Map<String, dynamic>>> _getCalendarEvents() {
    Map<String, List<Map<String, dynamic>>> events = {};
    DateTime now = DateTime.now();
    DateTime futureLimit = now.add(const Duration(days: 365));

    // 1. Project recurring chores
    for (var chore in _choresList) {
      if (chore['dueDate'] != null) {
        DateTime initialDate = DateTime.parse(chore['dueDate']);
        DateTime iterationDate = initialDate;

        while (iterationDate.isBefore(futureLimit)) {
          if (iterationDate.isAfter(now.subtract(const Duration(days: 7)))) {
            String dateKey = _dateToString(iterationDate);
            List<String> completedDates = List<String>.from(chore['completedDates'] ?? []);
            bool isCompletedOnThisDate = completedDates.contains(dateKey);

            // Only show if not completed on this specific occurrence, or show greyed out / omit icon if completed
            if (!isCompletedOnThisDate) {
              bool isMine = (_currentUser == 'Household Shared' || chore['assignee'] == _currentUser);
              events.putIfAbsent(dateKey, () => []);
              events[dateKey]!.add({
                'type': 'chore',
                'ref': chore,
                'dateKey': dateKey,
                'title': chore['name'],
                'icon': Icons.task_alt,
                'color': isMine ? Colors.red : Colors.grey.shade400,
              });
            }
          }
          if (chore['recurrence'] == 'Weekly') {
            iterationDate = iterationDate.add(const Duration(days: 7));
          } else if (chore['recurrence'] == 'Monthly') {
            iterationDate = DateTime(iterationDate.year, iterationDate.month + 1, iterationDate.day);
          } else {
            break;
          }
        }
      }
    }

    // 2. Add Scheduled Meals & Smart Pre-Dinner Shopping Trips on ALL days prior until ingredients bought
    for (var meal in _scheduledMeals) {
      String dateStr = meal['date'];
      String recipeName = meal['recipeName'];
      DateTime mealDate = DateTime.parse(dateStr);

      bool hasUncompletedIngredients = _shoppingList.any((item) => 
        (item['source'] == 'Recipe: $recipeName') && (item['completed'] == false)
      );

      if (!(meal['completed'] == true)) {
        events.putIfAbsent(dateStr, () => []);
        events[dateStr]!.add({
          'type': 'meal',
          'ref': meal,
          'title': recipeName,
          'icon': hasUncompletedIngredients ? Icons.warning_amber_rounded : Icons.restaurant,
          'color': hasUncompletedIngredients ? Colors.orange : Colors.purple,
        });
      }

      // If uncompleted ingredients exist, schedule shopping reminders on ALL days leading up to the dinner
      if (hasUncompletedIngredients) {
        DateTime shopDay = mealDate.subtract(const Duration(days: 1));
        while (shopDay.isAfter(now.subtract(const Duration(days: 1))) && shopDay.isBefore(mealDate)) {
          String shopDateKey = _dateToString(shopDay);
          events.putIfAbsent(shopDateKey, () => []);
          events[shopDateKey]!.add({
            'type': 'shopping_trip',
            'ref': meal,
            'title': 'Buy ingredients for $recipeName',
            'icon': Icons.shopping_cart,
            'color': Colors.teal,
          });
          shopDay = shopDay.subtract(const Duration(days: 1));
        }
      }
    }

    return events;
  }

  // Aggregate HomeQ Score (Shopping list counts as 1 single item total)
  int _calculateScore() {
    // Filter chores visible/relevant to current user
    var relevantChores = _currentUser == 'Household Shared' 
        ? _choresList 
        : _choresList.where((c) => c['assignee'] == _currentUser).toList();

    int totalChoresCount = relevantChores.length;
    int completedChoresCount = relevantChores.where((c) {
      // Count as completed if any recent date is done or general
      return (c['completedDates'] as List).isNotEmpty;
    }).length;

    // Shopping list treated as 1 single item aggregate
    bool shoppingAllDone = _shoppingList.isNotEmpty && _shoppingList.every((s) => s['completed'] == true);
    int totalItems = totalChoresCount + 1; 
    int completedItems = completedChoresCount + (shoppingAllDone ? 1 : 0);

    if (totalItems == 0) return 50;
    
    double baseScore = (completedItems / totalItems) * 100;
    int uncompletedCount = totalItems - completedItems;
    int penalty = uncompletedCount * 6;
    
    int finalScore = (baseScore + 30 - penalty).round();
    if (finalScore > 100) return 100;
    if (finalScore < 10) return 10;
    return finalScore;
  }

  // Get items for selected calendar date
  List<Map<String, dynamic>> _getItemsForSelectedDate() {
    List<Map<String, dynamic>> matches = [];
    String selectedDateKey = _dateToString(_selectedDate);

    // Check Chores
    for (var chore in _choresList) {
      if (chore['dueDate'] != null) {
        DateTime initialDate = DateTime.parse(chore['dueDate']);
        DateTime iterationDate = initialDate;
        DateTime futureLimit = DateTime.now().add(const Duration(days: 365));

        while (iterationDate.isBefore(futureLimit)) {
          if (_isSameDay(iterationDate, _selectedDate)) {
            List<String> completedDates = List<String>.from(chore['completedDates'] ?? []);
            bool isDoneOnDate = completedDates.contains(selectedDateKey);

            matches.add({
              'type': 'Chore',
              'object': chore,
              'dateKey': selectedDateKey,
              'name': chore['name'],
              'assignee': chore['assignee'],
              'assignedBy': chore['assignedBy'],
              'completed': isDoneOnDate,
            });
            break;
          }
          if (chore['recurrence'] == 'Weekly') {
            iterationDate = iterationDate.add(const Duration(days: 7));
          } else if (chore['recurrence'] == 'Monthly') {
            iterationDate = DateTime(iterationDate.year, iterationDate.month + 1, iterationDate.day);
          } else {
            break;
          }
        }
      }
    }

    // Check Scheduled Meals
    for (var meal in _scheduledMeals) {
      if (meal['date'] == selectedDateKey) {
        matches.add({
          'type': 'Meal',
          'object': meal,
          'dateKey': selectedDateKey,
          'name': meal['recipeName'],
          'assignee': meal['assignee'],
          'assignedBy': _currentUser,
          'completed': meal['completed'] ?? false,
        });
      }
    }

    return matches;
  }

  void _scheduleRecipe(String recipeName, DateTime date, String assignee) {
    String dateKey = _dateToString(date);
    setState(() {
      _scheduledMeals.add({
        'recipeName': recipeName,
        'date': dateKey,
        'assignee': assignee,
        'completed': false,
      });

      List<String> ingredients = List<String>.from(_recipesData[recipeName]?['ingredients'] ?? []);
      for (var ing in ingredients) {
        _shoppingList.add({
          'name': '$ing (for $recipeName)',
          'completed': false,
          'assignee': assignee,
          'source': 'Recipe: $recipeName',
        });
      }
      _centerMode = 'calendar';
    });
  }

  void _showAddChoreDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    String selectedAssignee = _currentUser == 'Household Shared' ? 'Patrick' : _currentUser;
    String selectedAssignedBy = _currentUser == 'Household Shared' ? 'Patrick' : _currentUser;
    String selectedRecurrence = 'Weekly';
    String selectedPriority = 'Medium';
    String dateStr = _dateToString(_selectedDate);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Chore'),
          content: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Chore Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedAssignee,
                  decoration: const InputDecoration(labelText: 'Assign To', border: OutlineInputBorder()),
                  items: ['Patrick', 'Sarah', 'Shared'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                  onChanged: (val) => selectedAssignee = val ?? 'Patrick',
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedAssignedBy,
                  decoration: const InputDecoration(labelText: 'Assigned By', border: OutlineInputBorder()),
                  items: ['Patrick', 'Sarah', 'Household Shared'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                  onChanged: (val) => selectedAssignedBy = val ?? _currentUser,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedRecurrence,
                  decoration: const InputDecoration(labelText: 'Recurrence', border: OutlineInputBorder()),
                  items: ['One-off', 'Weekly', 'Monthly'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                  onChanged: (val) => selectedRecurrence = val ?? 'Weekly',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(text: dateStr),
                  decoration: const InputDecoration(labelText: 'Due Date (YYYY-MM-DD)', border: OutlineInputBorder()),
                  onChanged: (val) => dateStr = val,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    _choresList.add({
                      'id': 'chore_${DateTime.now().millisecondsSinceEpoch}',
                      'name': nameController.text,
                      'completedDates': <String>[],
                      'assignee': selectedAssignee,
                      'assignedBy': selectedAssignedBy,
                      'dueDate': dateStr,
                      'recurrence': selectedRecurrence,
                      'priority': selectedPriority,
                      'instructions': 'Scheduled via chore creator.'
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add Chore'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int currentScore = _calculateScore();
    bool isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      return _buildMobileScaffold(currentScore);
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('HomeQ Command Center', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
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
                  children: [
                    const Icon(Icons.notifications_none, size: 28, color: Colors.black87),
                    if (_alertsList.isNotEmpty)
                      CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.red,
                        child: Text('${_alertsList.length}', style: const TextStyle(fontSize: 10, color: Colors.white)),
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
          // ================= LEFT PANE =================
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

          MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanUpdate: (details) {
                setState(() {
                  _leftPaneWidth += details.delta.dx;
                  if (_leftPaneWidth < 280) _leftPaneWidth = 280;
                  if (_leftPaneWidth > 500) _leftPaneWidth = 500;
                });
              },
              child: Container(width: 8, color: Colors.transparent, child: const Center(child: VerticalDivider(thickness: 2)))),
          ),

          // ================= CENTER COLUMN =================
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
                      dynamicEvents: _getCalendarEvents(),
                    )
                  : _buildCenterDetailCard(),
            ),
          ),

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

          // ================= RIGHT PANE =================
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
                      child: _alertsList.isEmpty
                          ? const Center(child: Text("No active alerts", style: TextStyle(color: Colors.grey)))
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              itemCount: _alertsList.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final alert = _alertsList[index];
                                return ListTile(
                                  dense: true,
                                  leading: Icon(alert['icon'] as IconData, color: alert['color'] as Color),
                                  title: Text(alert['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  subtitle: Text(alert['subtitle'], style: const TextStyle(fontSize: 11)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close, size: 16),
                                    onPressed: () {
                                      setState(() {
                                        _alertsList.removeAt(index);
                                      });
                                    },
                                  ),
                                );
                              },
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

  int _mobileTabIdx = 0;

  Widget _buildMobileScaffold(int currentScore) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HomeQ ($_currentUser)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.switch_account),
            onPressed: () {
              setState(() {
                _currentUser = _currentUser == 'Patrick' ? 'Sarah' : 'Patrick';
              });
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _mobileTabIdx,
        children: [
          Padding(padding: const EdgeInsets.all(8.0), child: Column(children: [Expanded(child: _buildChoreListPane())])),
          Padding(padding: const EdgeInsets.all(8.0), child: Column(children: [Expanded(child: _buildShoppingListPane())])),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CalendarWidget(
              onDaySelectedCallback: (date) => setState(() => _selectedDate = date),
              dynamicEvents: _getCalendarEvents(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _mobileTabIdx,
        onTap: (idx) => setState(() => _mobileTabIdx = idx),
        selectedItemColor: Colors.teal,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Chores'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Shopping'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
        ],
      ),
    );
  }


  // Chores Tab with role-based filtering (shows your chores brightly, household/others greyed out)
  Widget _buildChoreListPane() {
    var filteredChores = _currentUser == 'Household Shared'
        ? _choresList
        : _choresList; // Keep all in list but visually distinguish or filter

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: filteredChores.map((chore) {
                bool isMine = (_currentUser == 'Household Shared' || chore['assignee'] == _currentUser);
                String todayKey = _dateToString(DateTime.now());
                List<String> completedDates = List<String>.from(chore['completedDates'] ?? []);
                bool isDoneToday = completedDates.contains(todayKey);

                return Opacity(
                  opacity: isMine ? 1.0 : 0.5,
                  child: CheckboxListTile(
                    value: isDoneToday,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          if (!completedDates.contains(todayKey)) completedDates.add(todayKey);
                        } else {
                          completedDates.remove(todayKey);
                        }
                        chore['completedDates'] = completedDates;
                      });
                    },
                    title: Text(
                      chore['name'],
                      style: TextStyle(
                        decoration: isDoneToday ? TextDecoration.lineThrough : TextDecoration.none,
                        color: isDoneToday ? Colors.grey : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text("Due: ${chore['dueDate']} • To: ${chore['assignee']} (By: ${chore['assignedBy']})", style: const TextStyle(fontSize: 10)),
                    secondary: IconButton(
                      icon: const Icon(Icons.info_outline, size: 18),
                      onPressed: () {
                        setState(() {
                          _centerMode = 'chore_detail';
                          _selectedDetailItem = chore;
                        });
                      },
                    ),
                    dense: true,
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade50,
                foregroundColor: Colors.teal,
                elevation: 0,
                minimumSize: const Size.fromHeight(40),
              ),
              onPressed: () => _showAddChoreDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Add New Chore", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingListPane() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: _shoppingList.map((item) {
                return CheckboxListTile(
                  value: item['completed'],
                  onChanged: (bool? value) {
                    setState(() => item['completed'] = value ?? false);
                  },
                  title: Text(
                    item['name'],
                    style: TextStyle(
                      decoration: item['completed'] ? TextDecoration.lineThrough : TextDecoration.none,
                      color: item['completed'] ? Colors.grey : Colors.black87,
                    ),
                  ),
                  subtitle: Text("Source: ${item['source']} • (${item['assignee']})", style: const TextStyle(fontSize: 10)),
                  secondary: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
                        _shoppingList.remove(item);
                      });
                    },
                  ),
                  dense: true,
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _shoppingList.removeWhere((item) => item['completed'] == true);
                });
              },
              icon: const Icon(Icons.clear_all, size: 16),
              label: const Text("Clear Checked Items", style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
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
            subtitle: Text("Prep: ${recipe['prepTime']}", style: const TextStyle(fontSize: 11)),
            trailing: const Icon(Icons.calendar_today, size: 18, color: Colors.teal),
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

  // Day Inspector with isolated weekly chore completion and meal inspection hook
  Widget _buildDayInspectorContent() {
    final items = _getItemsForSelectedDate();

    if (items.isEmpty) {
      return const Center(
        child: Text(
          "No tasks or meals scheduled for this date.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView(
      children: [
        const Text("Scheduled for Date:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        ...items.map((item) {
          bool isChore = item['type'] == 'Chore';
          var obj = item['object'];
          String targetDateKey = item['dateKey'];

          if (isChore) {
            List<String> completedDates = List<String>.from(obj['completedDates'] ?? []);
            bool isDone = completedDates.contains(targetDateKey);

            return CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              value: isDone,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    if (!completedDates.contains(targetDateKey)) completedDates.add(targetDateKey);
                  } else {
                    completedDates.remove(targetDateKey);
                  }
                  obj['completedDates'] = completedDates;
                });
              },
              title: Text("[Chore] ${item['name']}", style: TextStyle(fontWeight: FontWeight.w600, decoration: isDone ? TextDecoration.lineThrough : null)),
              subtitle: Text("To: ${item['assignee']} • By: ${item['assignedBy']}", style: const TextStyle(fontSize: 11)),
            );
          } else {
            // Meal item: clicking opens detail/reschedule card
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.restaurant, color: Colors.purple, size: 20),
              title: Text("[Meal] ${item['name']}", style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text("Assigned to: ${item['assignee']}", style: const TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.edit_calendar, size: 18, color: Colors.teal),
              onTap: () {
                setState(() {
                  _centerMode = 'meal_detail';
                  _selectedDetailItem = obj;
                });
              },
            );
          }
        }),
      ],
    );
  }

  // Center Pane Operational Card for Recipes, Chores, & Meal Rescheduling
  Widget _buildCenterDetailCard() {
    if (_selectedDetailItem == null) return const SizedBox();

    bool isRecipe = _centerMode == 'recipe_detail';
    bool isMealEdit = _centerMode == 'meal_detail';
    String dateStr = isMealEdit ? _selectedDetailItem!['date'] : '2026-09-20';
    String assignee = 'Patrick';

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
                    Icon(isRecipe || isMealEdit ? Icons.restaurant_menu : Icons.task_alt, color: Colors.teal, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      isMealEdit ? 'Reschedule / Change Meal' : (_selectedDetailItem!['name'] ?? 'Details'),
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
            if (isRecipe) ...[
              Chip(label: Text("Prep Time: ${_selectedDetailItem!['prepTime']}")),
              const SizedBox(height: 12),
              const Text("Ingredients (Will sync to shopping list upon scheduling):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 6),
              ...((_selectedDetailItem!['ingredients'] as List<String>).map((ing) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(children: [const Icon(Icons.fiber_manual_record, size: 8, color: Colors.teal), const SizedBox(width: 8), Text(ing)]),
                  ))),
              const SizedBox(height: 16),
              const Text("Instructions:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 6),
              Text(_selectedDetailItem!['instructions'] ?? '', style: const TextStyle(fontSize: 14, height: 1.4)),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: dateStr),
                      decoration: const InputDecoration(labelText: 'Schedule Date (YYYY-MM-DD)', border: OutlineInputBorder(), isDense: true),
                      onChanged: (val) => dateStr = val,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                    onPressed: () {
                      _scheduleRecipe(_selectedDetailItem!['name'], DateTime.parse(dateStr), assignee);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recipe scheduled and ingredients synced!')));
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text("Schedule & Sync"),
                  ),
                ],
              ),
            ] else if (isMealEdit) ...[
              Text("Current Recipe: ${_selectedDetailItem!['recipeName']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: _selectedDetailItem!['date']),
                decoration: const InputDecoration(labelText: 'New Date (YYYY-MM-DD)', border: OutlineInputBorder()),
                onChanged: (val) => _selectedDetailItem!['date'] = val,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDetailItem!['recipeName'],
                decoration: const InputDecoration(labelText: 'Change Recipe', border: OutlineInputBorder()),
                items: _recipesData.keys.map((key) => DropdownMenuItem(value: key, child: Text(key))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedDetailItem!['recipeName'] = val;
                    });
                  }
                },
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () {
                      setState(() {
                        _scheduledMeals.remove(_selectedDetailItem);
                        _centerMode = 'calendar';
                      });
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text("Cancel Scheduled Meal"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                    onPressed: () {
                      setState(() {
                        _centerMode = 'calendar';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meal updated successfully!')));
                    },
                    child: const Text("Save Changes"),
                  ),
                ],
              ),
            ] else ...[
              Chip(label: Text("Assigned to: ${_selectedDetailItem!['assignee']} • By: ${_selectedDetailItem!['assignedBy']}")),
              const SizedBox(height: 12),
              Text("Recurrence: ${_selectedDetailItem!['recurrence']}", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text("Instructions:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 6),
              Text(_selectedDetailItem!['instructions'] ?? '', style: const TextStyle(fontSize: 14, height: 1.4)),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  onPressed: () => setState(() => _centerMode = 'calendar'),
                  icon: const Icon(Icons.check),
                  label: const Text("Done / Return"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}