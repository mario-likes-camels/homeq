import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  final Function(DateTime) onDaySelectedCallback;

  const CalendarWidget({super.key, required this.onDaySelectedCallback});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Mock data mapping dates to activities
  final Map<String, List<Map<String, dynamic>>> _dailyEvents = {
    '2026-09-20': [
      {'title': 'Vacuum', 'icon': Icons.cleaning_services, 'color': Colors.red},
      {'title': 'Pool', 'icon': Icons.pool, 'color': Colors.orange},
      {'title': 'Lasagne', 'icon': Icons.restaurant, 'color': Colors.purple},
    ],
    '2026-09-21': [
      {'title': 'Shopping', 'icon': Icons.shopping_cart, 'color': Colors.blue},
    ],
    '2026-09-25': [
      {'title': 'Bathroom', 'icon': Icons.bathtub, 'color': Colors.red},
    ],
  };

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final key = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    return _dailyEvents[key] ?? [];
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TableCalendar(
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2035, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            widget.onDaySelectedCallback(selectedDay);
          },
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) => _buildDayBox(day, isSelected: false, isToday: false),
            todayBuilder: (context, day, focusedDay) => _buildDayBox(day, isSelected: false, isToday: true),
            selectedBuilder: (context, day, focusedDay) => _buildDayBox(day, isSelected: true, isToday: false),
          ),
        ),
      ),
    );
  }

  Widget _buildDayBox(DateTime day, {required bool isSelected, required bool isToday}) {
    final events = _getEventsForDay(day);

    BoxDecoration decoration = BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(8),
    );

    if (isSelected) {
      decoration = BoxDecoration(
        color: Colors.teal.shade100,
        border: Border.all(color: Colors.teal, width: 2),
        borderRadius: BorderRadius.circular(8),
      );
    } else if (isToday) {
      decoration = BoxDecoration(
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.blueAccent, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      );
    }

    return Container(
      margin: const EdgeInsets.all(3),
      padding: const EdgeInsets.all(4),
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isSelected ? Colors.teal.shade900 : Colors.black87,
            ),
          ),
          const Spacer(),
          // Compact symbol/icon indicators to prevent text overflow
          if (events.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: events.take(3).map((e) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: (e['color'] as Color).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(e['icon'] as IconData, size: 8, color: e['color'] as Color),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}