import 'package:flutter/material.dart';
import '../services/progress_service.dart';
import '../data/progress_data.dart';

class ProgressPlaceholderScreen extends StatefulWidget {
  const ProgressPlaceholderScreen({super.key});

  @override
  State<ProgressPlaceholderScreen> createState() =>
      _ProgressPlaceholderScreenState();
}

class _ProgressPlaceholderScreenState extends State<ProgressPlaceholderScreen>
    with SingleTickerProviderStateMixin {
  final ProgressService service = ProgressService();

  bool showAll = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // For date navigation in All Data view
  DateTime _selectedMonth = DateTime.now();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  DateTime normalize(DateTime d) {
    return DateTime(d.year, d.month, d.day);
  }

  // 🔥 Convert seconds → whole minutes (no decimals)
  int toMinutes(int seconds) {
    return (seconds / 60).floor();
  }

  // Navigate to previous month
  void _goToPreviousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  // Navigate to next month
  void _goToNextMonth() {
    DateTime nextMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    if (nextMonth.isBefore(DateTime.now().add(const Duration(days: 1)))) {
      setState(() {
        _selectedMonth = nextMonth;
      });
    }
  }

  // Reset to current month
  void _resetToCurrentMonth() {
    setState(() {
      _selectedMonth = DateTime.now();
    });
  }

  // Show month picker
  Future<void> _selectMonth() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.grey.shade800,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedMonth = DateTime(pickedDate.year, pickedDate.month);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Progress',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: _buildSegmentedButton(),
          ),
        ],
      ),
      body: StreamBuilder<List<ProgressData>>(
        stream: service.getProgress(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            );
          }

          final data = snapshot.data!;

          // 🔹 Group by date
          Map<DateTime, List<ProgressData>> grouped = {};
          for (var item in data) {
            DateTime key = normalize(item.date);
            grouped.putIfAbsent(key, () => []).add(item);
          }

          DateTime today = normalize(DateTime.now());

          // 🔥 CURRENT STREAK
          int currentStreak = 0;
          for (int i = 0; i < 365; i++) {
            DateTime check = today.subtract(Duration(days: i));
            if (grouped.containsKey(check)) {
              currentStreak++;
            } else {
              break;
            }
          }

          // 🏆 LONGEST STREAK
          int longestStreak = 0, temp = 0;
          for (int i = 0; i < 365; i++) {
            DateTime check = today.subtract(Duration(days: i));
            if (grouped.containsKey(check)) {
              temp++;
              if (temp > longestStreak) longestStreak = temp;
            } else {
              temp = 0;
            }
          }

          // 📅 WEEKLY STATS (whole minutes)
          int weeklyDuration = 0;
          int weeklyCalories = 0;
          int weeklyXP = 0;

          for (int i = 0; i < 7; i++) {
            DateTime check = today.subtract(Duration(days: i));
            if (grouped.containsKey(check)) {
              final entries = grouped[check]!;

              weeklyDuration +=
                  entries.fold(0, (s, e) => s + toMinutes(e.duration));

              weeklyCalories += entries.fold(0, (s, e) => s + e.calories);

              weeklyXP += entries.fold(0, (s, e) => s + e.xp);
            }
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.shade300,
                                Colors.orange.shade600
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.auto_awesome,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Your Progress",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              "Keep up the great work!",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 🔥 STREAK CARD
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade50,
                            Colors.orange.shade100
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.orange.shade200.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStreakStat(
                              icon: Icons.local_fire_department,
                              iconColor: Colors.orange.shade700,
                              label: "Current Streak",
                              value: "$currentStreak",
                              subtitle: "days",
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.orange.shade200,
                          ),
                          Expanded(
                            child: _buildStreakStat(
                              icon: Icons.emoji_events,
                              iconColor: Colors.amber.shade700,
                              label: "Longest Streak",
                              value: "$longestStreak",
                              subtitle: "days",
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 📊 STATS CARD
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              icon: Icons.timer_outlined,
                              iconColor: Colors.blue.shade600,
                              label: "Duration",
                              value: "$weeklyDuration",
                              unit: "min",
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey.shade200,
                          ),
                          Expanded(
                            child: _buildStatItem(
                              icon: Icons.local_fire_department,
                              iconColor: Colors.red.shade500,
                              label: "Calories",
                              value: "$weeklyCalories",
                              unit: "",
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey.shade200,
                          ),
                          Expanded(
                            child: _buildStatItem(
                              icon: Icons.star_outline,
                              iconColor: Colors.amber.shade600,
                              label: "XP Earned",
                              value: "$weeklyXP",
                              unit: "xp",
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section Header with Navigation Controls
                    if (!showAll) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "This Week's Activity",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "📆 Last 7 Days",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _buildWeeklyGrid(grouped, today),
                      ),
                    ],

                    if (showAll) ...[
                      // Month Navigation Bar
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: _goToPreviousMonth,
                              icon: Icon(Icons.chevron_left,
                                  color: Colors.orange.shade700),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.orange.shade50,
                              ),
                            ),
                            InkWell(
                              onTap: _selectMonth,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 18,
                                        color: Colors.orange.shade700),
                                    const SizedBox(width: 8),
                                    Text(
                                      _getMonthYearString(_selectedMonth),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.arrow_drop_down,
                                        color: Colors.orange.shade700),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: _resetToCurrentMonth,
                                  icon: Icon(Icons.today,
                                      color: Colors.orange.shade700, size: 20),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.orange.shade50,
                                  ),
                                ),
                                IconButton(
                                  onPressed: _goToNextMonth,
                                  icon: Icon(Icons.chevron_right,
                                      color: Colors.orange.shade700),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.orange.shade50,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Month Calendar View
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _buildMonthCalendar(grouped, _selectedMonth),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Tip Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.tips_and_updates,
                              size: 18, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              showAll
                                  ? "Tap on any date to see workout details • Use arrows to change months"
                                  : "Tap on any day with activity to see detailed stats",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildSegmentedButton() {
    return SegmentedButton<bool>(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white.withOpacity(0.2);
            }
            return Colors.transparent;
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return Colors.white70;
          },
        ),
        elevation: WidgetStateProperty.all(0),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 8),
        ),
        side: WidgetStateProperty.all(BorderSide.none),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      segments: const [
        ButtonSegment<bool>(
          value: false,
          label: Text('Weekly'),
          icon: Icon(Icons.calendar_view_week, size: 16),
        ),
        ButtonSegment<bool>(
          value: true,
          label: Text('All Data'),
          icon: Icon(Icons.calendar_today, size: 16),
        ),
      ],
      selected: {showAll},
      onSelectionChanged: (Set<bool> newSelection) {
        setState(() {
          showAll = newSelection.first;
          _fadeController.reset();
          _fadeController.forward();
        });
      },
    );
  }

  // 🟩 WEEKLY GRID
  Widget _buildWeeklyGrid(
      Map<DateTime, List<ProgressData>> grouped, DateTime today) {
    DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _WeekDayLabel(day: 'Mon'),
            _WeekDayLabel(day: 'Tue'),
            _WeekDayLabel(day: 'Wed'),
            _WeekDayLabel(day: 'Thu'),
            _WeekDayLabel(day: 'Fri'),
            _WeekDayLabel(day: 'Sat'),
            _WeekDayLabel(day: 'Sun'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            DateTime day = startOfWeek.add(Duration(days: index));
            return _buildDayCard(day, grouped);
          }),
        ),
      ],
    );
  }

  // 📅 MONTH CALENDAR VIEW (More reliable for past data)
  Widget _buildMonthCalendar(
      Map<DateTime, List<ProgressData>> grouped, DateTime month) {
    // Get first day of month
    DateTime firstDayOfMonth = DateTime(month.year, month.month, 1);
    // Get last day of month
    DateTime lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    // Get the day of week for first day (Monday = 1, Sunday = 7)
    int firstWeekday = firstDayOfMonth.weekday;
    // Adjust to Monday as first day (1 = Monday, 7 = Sunday)
    int startingOffset = firstWeekday - 1;

    // Calculate total days to show (including previous month's days)
    int totalDaysToShow = startingOffset + lastDayOfMonth.day;
    int numberOfWeeks = (totalDaysToShow / 7).ceil();

    List<DateTime> calendarDays = [];

    // Add days from previous month
    DateTime prevMonth = DateTime(month.year, month.month, 0);
    for (int i = startingOffset - 1; i >= 0; i--) {
      calendarDays
          .add(DateTime(prevMonth.year, prevMonth.month, prevMonth.day - i));
    }

    // Add days of current month
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      calendarDays.add(DateTime(month.year, month.month, i));
    }

    // Add days from next month to complete the grid
    int remainingDays = numberOfWeeks * 7 - calendarDays.length;
    for (int i = 1; i <= remainingDays; i++) {
      calendarDays.add(DateTime(month.year, month.month + 1, i));
    }

    const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        // Week day headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: weekDays.map((day) {
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // Calendar grid
        ...List.generate(numberOfWeeks, (weekIndex) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (dayIndex) {
              int index = weekIndex * 7 + dayIndex;
              if (index < calendarDays.length) {
                DateTime date = calendarDays[index];
                bool isCurrentMonth = date.month == month.month;
                return Expanded(
                  child: _buildCalendarDay(date, grouped, isCurrentMonth),
                );
              } else {
                return const Expanded(child: SizedBox.shrink());
              }
            }),
          );
        }),
      ],
    );
  }

  // Calendar day cell
  Widget _buildCalendarDay(DateTime date,
      Map<DateTime, List<ProgressData>> grouped, bool isCurrentMonth) {
    List<ProgressData>? dayData = grouped[normalize(date)];
    int workoutCount = dayData?.length ?? 0;

    Color backgroundColor;
    if (workoutCount == 0) {
      backgroundColor = Colors.grey.shade100;
    } else if (workoutCount == 1) {
      backgroundColor = Colors.green.shade100;
    } else if (workoutCount == 2) {
      backgroundColor = Colors.green.shade300;
    } else {
      backgroundColor = Colors.green.shade500;
    }

    return GestureDetector(
      onTap: () {
        if (workoutCount > 0) {
          final entries = dayData!;
          int totalDuration =
              entries.fold(0, (s, e) => s + toMinutes(e.duration));
          int totalCalories = entries.fold(0, (s, e) => s + e.calories);
          int totalXP = entries.fold(0, (s, e) => s + e.xp);

          _showDayDetailsDialog(context, date, workoutCount, totalDuration,
              totalCalories, totalXP);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No workouts on ${_formatDate(date)}'),
              duration: const Duration(seconds: 1),
              backgroundColor: Colors.grey.shade700,
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: workoutCount > 0
                ? Colors.green.shade600.withOpacity(0.5)
                : Colors.grey.shade300,
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isCurrentMonth
                    ? (workoutCount > 0
                        ? Colors.green.shade900
                        : Colors.grey.shade800)
                    : Colors.grey.shade400,
              ),
            ),
            if (workoutCount > 0)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$workoutCount',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Day card for weekly view
  Widget _buildDayCard(
      DateTime day, Map<DateTime, List<ProgressData>> grouped) {
    int count = grouped[day]?.length ?? 0;

    return GestureDetector(
      onTap: () {
        if (count > 0) {
          final entries = grouped[day]!;
          int totalDuration =
              entries.fold(0, (s, e) => s + toMinutes(e.duration));
          int totalCalories = entries.fold(0, (s, e) => s + e.calories);
          int totalXP = entries.fold(0, (s, e) => s + e.xp);

          _showDayDetailsDialog(
              context, day, count, totalDuration, totalCalories, totalXP);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No activity on ${_formatDate(day)}'),
              duration: const Duration(seconds: 1),
              backgroundColor: Colors.grey.shade700,
            ),
          );
        }
      },
      child: Column(
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: count > 0 ? Colors.green.shade400 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                count > 0 ? count.toString() : '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDayDetailsDialog(BuildContext context, DateTime day, int count,
      int duration, int calories, int xp) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.fitness_center,
                    color: Colors.orange.shade700, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                _formatDate(day),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDetailStat(
                        Icons.sports_gymnastics, "$count", "Workouts"),
                    _buildDetailStat(Icons.timer, "$duration", "mins"),
                    _buildDetailStat(
                        Icons.local_fire_department, "$calories", "cal"),
                    _buildDetailStat(Icons.star, "$xp", "XP"),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(_),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Close',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _buildStreakStat({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String unit,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit.isNotEmpty ? "$label ($unit)" : label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _WeekDayLabel extends StatelessWidget {
  final String day;
  const _WeekDayLabel({required this.day});

  @override
  Widget build(BuildContext context) {
    return Text(
      day,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade600,
      ),
    );
  }
}
