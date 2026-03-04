import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const ExpenseTrackerApp(),
    ),
  );
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF00695c),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00695c),
          brightness: Brightness.dark,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF004d40),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF004d40),
          brightness: Brightness.dark,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00695c),
              Color(0xFF004d40),
              Color(0xFF00251a),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _rotationController,
              child: Hero(
                tag: 'expense_tracker_logo',
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Expense Tracker',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your Financial Companion',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= MODELS ================= */

class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});
}

class Category {
  final String id;
  final String name;
  final String type;
  final Color color;
  final IconData icon;

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    required this.icon,
  });
}

class TransactionModel {
  final String id;
  final String type;
  final double amount;
  final String categoryId;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.date,
  });
}

class BillReminder {
  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;

  BillReminder({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
  });
}

class DebtEntry {
  final String id;
  final String personName;
  final double amount;
  final bool isOwedByMe;
  final DateTime date;

  DebtEntry({
    required this.id,
    required this.personName,
    required this.amount,
    required this.isOwedByMe,
    required this.date,
  });
}

class WishlistItem {
  final String id;
  final String title;
  final double targetAmount;
  double savedAmount;

  WishlistItem({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.savedAmount = 0,
  });

  double get progress {
    if (targetAmount <= 0) return 0;
    return (savedAmount / targetAmount).clamp(0, 1);
  }
}

/* ================= APP STATE ================= */

class AppState extends ChangeNotifier {
  User? _user;
  final List<Category> _categories = [];
  final List<TransactionModel> _transactions = [];
  final List<BillReminder> _billReminders = [];
  final List<DebtEntry> _debtEntries = [];
  final List<WishlistItem> _wishlistItems = [];

  String _currency = "PKR";
  String _savingsGoalTitle = "";
  double _savingsGoalTarget = 0;
  double _savingsCurrentAmount = 0;

  User? get user => _user;
  List<Category> get categories => _categories;
  List<TransactionModel> get transactions => _transactions;
  List<BillReminder> get billReminders => _billReminders;
  List<DebtEntry> get debtEntries => _debtEntries;
  List<WishlistItem> get wishlistItems => _wishlistItems;
  String get currency => _currency;
  String get savingsGoalTitle => _savingsGoalTitle;
  double get savingsGoalTarget => _savingsGoalTarget;
  double get savingsCurrentAmount => _savingsCurrentAmount;
  double get savingsProgress {
    if (_savingsGoalTarget <= 0) return 0;
    final progress = _savingsCurrentAmount / _savingsGoalTarget;
    return progress.clamp(0, 1);
  }

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  void updateProfile({required String name, required String email}) {
    if (_user == null) {
      _user = User(id: "1", name: name, email: email);
    } else {
      _user = User(id: _user!.id, name: name, email: email);
    }
    notifyListeners();
  }

  void setCurrency(String value) {
    _currency = value;
    notifyListeners();
  }

  void addCategory(Category category) {
    _categories.add(category);
    notifyListeners();
  }

  void addTransaction(TransactionModel t) {
    _transactions.add(t);
    notifyListeners();
  }

  void addCustomCategory(String name) {
    if (name.trim().isEmpty) return;
    final normalized = name.trim().toLowerCase();
    if (_categories.any((c) => c.name.toLowerCase() == normalized)) return;

    final defaultColors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFF45B7D1),
      const Color(0xFF96CEB4),
      const Color(0xFFFECA57),
      const Color(0xFF00bfa5),
    ];

    final selectedColor = defaultColors[_categories.length % defaultColors.length];

    _categories.add(
      Category(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        type: 'expense',
        color: selectedColor,
        icon: Icons.category,
      ),
    );
    notifyListeners();
  }

  void addBillReminder(BillReminder billReminder) {
    _billReminders.add(billReminder);
    _billReminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    notifyListeners();
  }

  void addDebtEntry(DebtEntry debtEntry) {
    _debtEntries.add(debtEntry);
    _debtEntries.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  void addWishlistItem(WishlistItem item) {
    _wishlistItems.add(item);
    notifyListeners();
  }

  void saveToWishlistItem({required String itemId, required double amount}) {
    if (amount <= 0 || _savingsCurrentAmount <= 0) return;
    final index = _wishlistItems.indexWhere((e) => e.id == itemId);
    if (index == -1) return;

    final item = _wishlistItems[index];
    final remainingForItem = item.targetAmount - item.savedAmount;
    if (remainingForItem <= 0) return;

    final transferable = [amount, _savingsCurrentAmount, remainingForItem].reduce((a, b) => a < b ? a : b);
    if (transferable <= 0) return;

    item.savedAmount += transferable;
    _savingsCurrentAmount -= transferable;
    notifyListeners();
  }

  void setSavingsGoal({
    required String title,
    required double target,
    double? currentAmount,
  }) {
    _savingsGoalTitle = title.trim();
    _savingsGoalTarget = target;
    if (currentAmount != null) {
      _savingsCurrentAmount = currentAmount;
    }
    notifyListeners();
  }

  void addSavings(double amount) {
    if (amount <= 0) return;
    _savingsCurrentAmount += amount;
    notifyListeners();
  }

  double getMonthlyIncome(DateTime date) {
    return _transactions
        .where((t) =>
            t.type == "income" &&
            t.date.month == date.month &&
            t.date.year == date.year)
        .fold(0.0, (a, b) => a + b.amount);
  }

  double getMonthlyExpense(DateTime date) {
    return _transactions
        .where((t) =>
            t.type == "expense" &&
            t.date.month == date.month &&
            t.date.year == date.year)
        .fold(0.0, (a, b) => a + b.amount);
  }

  List<FlSpot> getExpenseChartData(DateTime month) {
    // Generate sample data for the chart
    final spots = <FlSpot>[];
    
    for (int i = 1; i <= 30; i++) {
      final dayExpense = Random().nextDouble() * 500 + 100;
      spots.add(FlSpot(i.toDouble(), dayExpense));
    }
    
    return spots;
  }
}

/* ================= AUTH PAGE ================= */

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF004d40), // Dark teal
              Color(0xFF00251a), // Darker green
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background elements
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  // color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(150),
                ),
              ),
            ),
            
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF00bfa5),
                          Color(0xFF00796b),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // App Title
                  Text(
                    'Expense Tracker',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: .3),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Text(
                    'Track your finances with style',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Enter Button
                  GlassmorphismButton(
                    onPressed: () {
                      context.read<AppState>().setUser(
                            User(id: "1", name: "Demo User", email: "demo@mail.com"),
                          );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    },
                    child: const Text(
                      'Enter App',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004d40),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Glassmorphism Button Widget
class GlassmorphismButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const GlassmorphismButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha:0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha:0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            child: child,
          ),
        ),
      ),
    );
  }
}

/* ================= HOME ================= */

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  final pages = const [
    DashboardPage(),
    AddTransactionPage(),
    TransactionsPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();

    if (appState.categories.isEmpty) {
      // Initialize with premium categories
      appState.addCategory(Category(
        id: "food",
        name: "Food",
        type: "expense",
        color: const Color(0xFFFF6B6B),
        icon: Icons.fastfood,
      ));
      appState.addCategory(Category(
        id: "transport",
        name: "Transport",
        type: "expense",
        color: const Color(0xFF4ECDC4),
        icon: Icons.directions_car,
      ));
      appState.addCategory(Category(
        id: "shopping",
        name: "Shopping",
        type: "expense",
        color: const Color(0xFF45B7D1),
        icon: Icons.shopping_bag,
      ));
      appState.addCategory(Category(
        id: "entertainment",
        name: "Entertainment",
        type: "expense",
        color: const Color(0xFF96CEB4),
        icon: Icons.movie,
      ));
      appState.addCategory(Category(
        id: "health",
        name: "Health",
        type: "expense",
        color: const Color(0xFFFECA57),
        icon: Icons.local_hospital,
      ));
      appState.addCategory(Category(
        id: "salary",
        name: "Salary",
        type: "income",
        color: const Color(0xFF00bfa5),
        icon: Icons.work,
      ));
      appState.addCategory(Category(
        id: "freelance",
        name: "Freelance",
        type: "income",
        color: const Color(0xFF00796b),
        icon: Icons.computer,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF004d40), // Dark teal
                  Color(0xFF00251a), // Darker green
                ],
              ),
            ),
          ),

          SafeArea(child: pages[index]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF004D40),
        selectedItemColor: Colors.tealAccent,
        unselectedItemColor: Colors.white70,
        currentIndex: index,
        onTap: (i) {
          setState(() => index = i);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Premium Bottom Navigation Bar
class GlassmorphismBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const GlassmorphismBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha:0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.dashboard, "Home", 0),
          _buildNavItem(Icons.list, "Transactions", 2),
          const SizedBox(width: 40), // Space for floating button
          _buildNavItem(Icons.bar_chart, "Reports", 2),
          _buildNavItem(Icons.settings, "Settings", 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: currentIndex == index ? const Color(0xFF00bfa5) : Colors.white70,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: currentIndex == index ? const Color(0xFF00bfa5) : Colors.white70,
              fontSize: 10,
              fontWeight: currentIndex == index ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= DASHBOARD ================= */

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final now = DateTime.now();
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 360 ? 14.0 : 20.0;
    final userName = appState.user?.name ?? 'User';

    final income = appState.getMonthlyIncome(now);
    final expense = appState.getMonthlyExpense(now);
    final balance = income - expense;
    final todaysSpending = appState.transactions
        .where((t) =>
            t.type == "expense" &&
            t.date.year == now.year &&
            t.date.month == now.month &&
            t.date.day == now.day)
        .fold(0.0, (sum, t) => sum + t.amount);
    const double monthlyBudget = 100000;
    final double budgetProgress = (expense / monthlyBudget).clamp(0.0, 1.0);
    final Color budgetColor = budgetProgress > 0.9
        ? Colors.red
        : (budgetProgress < 0.8 ? Colors.tealAccent : Colors.orangeAccent);

    return SingleChildScrollView(
      padding: EdgeInsets.all(horizontalPadding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Welcome Header
          Text(
            'Welcome back',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            userName,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Total Balance Card (Large)
          GlassmorphismCard(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total Balance',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${appState.currency} ${balance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'This month',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Income & Expense Cards
          Row(
            children: [
              Expanded(
                child: GlassmorphismCard(
                  height: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        color: const Color(0xFF00bfa5),
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Income',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${appState.currency} ${income.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: GlassmorphismCard(
                  height: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_downward,
                        color: const Color(0xFFFF6B6B),
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Expense',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${appState.currency} ${expense.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          GlassmorphismCard(
            height: 100,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Today's Spending",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${appState.currency} ${todaysSpending.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Monthly Budget',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          GlassmorphismCard(
            height: 120,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Spent: ${appState.currency} ${expense.toStringAsFixed(0)} / ${monthlyBudget.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: budgetProgress,
                    minHeight: 12,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(budgetColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(budgetProgress * 100).toStringAsFixed(0)}% used',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Expense Dynamics Chart
          Text(
            'Expense Dynamics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          
          GlassmorphismCard(
            height: 200,
            child: ExpenseChart(
              spots: appState.getExpenseChartData(now),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Spending Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          GlassmorphismCard(
            height: 220,
            child: const SpendingCategoriesChart(),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: GlassmorphismButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExportReportPage()),
                );
              },
              child: const Text(
                'Export Reports',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004d40),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Quick Actions
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: appState.categories.take(6).map((category) {
              return GlassmorphismCard(
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: category.color.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

// Glassmorphism Card Widget
class GlassmorphismCard extends StatelessWidget {
  final double height;
  final Widget child;

  const GlassmorphismCard({
    super.key,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha:0.1),
            Colors.white.withValues(alpha:0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha:0.2),
        ),
      ),
      child: child,
    );
  }
}

// Expense Chart Widget
class ExpenseChart extends StatelessWidget {
  final List<FlSpot> spots;

  const ExpenseChart({super.key, required this.spots});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 100,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withValues(alpha: 0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 200,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        minX: 1,
        maxX: 30,
        minY: 0,
        maxY: 600,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF00bfa5),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Color(0xFF00bfa5).withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class SpendingCategoriesChart extends StatelessWidget {
  const SpendingCategoriesChart({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = const [
      ('Food', 0.30, Color(0xFFFF6B6B)),
      ('Rent', 0.50, Color(0xFF4ECDC4)),
      ('Others', 0.20, Color(0xFFFECA57)),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...categories.map((c) {
            final label = c.$1;
            final value = c.$2;
            final color = c.$3;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    child: Text(
                      label,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 12,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${(value * 100).toInt()}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/* ================= ADD TRANSACTION ================= */

class AddTransactionPage extends StatefulWidget {
  final VoidCallback? onSaved;
  const AddTransactionPage({super.key, this.onSaved});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final TextEditingController amountController = TextEditingController();
  String type = "expense";
  String selectedCategoryId = "";
  DateTime selectedDate = DateTime.now();

  void _updateTransactionType(String newType) {
    final appState = context.read<AppState>();
    final filtered = appState.categories.where((c) => c.type == newType).toList();
    setState(() {
      type = newType;
      selectedCategoryId = filtered.isNotEmpty ? filtered.first.id : '';
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    if (appState.categories.isNotEmpty) {
      selectedCategoryId = appState.categories.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 360 ? 14.0 : 20.0;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom + 20;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        20,
        horizontalPadding,
        bottomInset,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Header
          Text(
            'Add Transaction',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Track your income and expenses',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Amount Input
          GlassmorphismCard(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    type == "income" ? Icons.attach_money : Icons.money_off,
                    color: type == "income" ? const Color(0xFF00bfa5) : const Color(0xFFFF6B6B),
                    size: 24,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: amountController,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter amount',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        prefixText: '${appState.currency} ',
                        prefixStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Transaction Type
          Text(
            'Transaction Type',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GlassmorphismCard(
                  height: 50,
                  child: InkWell(
                    onTap: () => _updateTransactionType("income"),
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_upward,
                          color: type == "income" ? const Color(0xFF00bfa5) : Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Income',
                          style: TextStyle(
                            color: type == "income" ? const Color(0xFF00bfa5) : Colors.white70,
                            fontWeight: type == "income" ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: GlassmorphismCard(
                  height: 50,
                  child: InkWell(
                    onTap: () => _updateTransactionType("expense"),
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_downward,
                          color: type == "expense" ? const Color(0xFFFF6B6B) : Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Expense',
                          style: TextStyle(
                            color: type == "expense" ? const Color(0xFFFF6B6B) : Colors.white70,
                            fontWeight: type == "expense" ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Category Selection
          Text(
            'Category',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: appState.categories
                .where((c) => c.type == type)
                .map((category) {
              final isSelected = selectedCategoryId == category.id;
              return InkWell(
                onTap: () => setState(() => selectedCategoryId = category.id),
                child: GlassmorphismCard(
                  height: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: category.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? category.color : category.color.withValues(alpha: 0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          category.icon,
                          color: category.color,
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? category.color : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 20),
          
          // Date Selection
          Text(
            'Date',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          GlassmorphismCard(
            height: 50,
            child: InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 15),
                    Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Save Button
          GlassmorphismButton(
            onPressed: _saveTransaction,
            child: const Text(
              'Save Transaction',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004d40),
              ),
            ),
          ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00bfa5),
              onPrimary: Colors.white,
              surface: Color(0xFF004d40),
              onSurface: Colors.white,
            ), dialogTheme: DialogThemeData(backgroundColor: const Color(0xFF004d40)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _saveTransaction() {
    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    if (selectedCategoryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final transaction = TransactionModel(
      id: DateTime.now().toString(),
      type: type,
      amount: amount,
      categoryId: selectedCategoryId,
      date: selectedDate,
    );

    context.read<AppState>().addTransaction(transaction);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction saved successfully!')),
    );
    
    amountController.clear();
    setState(() {
      selectedDate = DateTime.now();
      final matchingCategories = context
          .read<AppState>()
          .categories
          .where((c) => c.type == type)
          .toList();
      if (matchingCategories.isNotEmpty) {
        selectedCategoryId = matchingCategories.first.id;
      }
    });
  }
}

/* ================= TRANSACTIONS ================= */

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<AppState>().transactions;
    final appState = context.watch<AppState>();

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.white30,
            ),
            const SizedBox(height: 20),
            Text(
              'No Transactions Yet',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Add your first transaction to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      itemCount: transactions.length,
      itemBuilder: (_, i) {
        final t = transactions[i];
        final category = appState.categories.firstWhere(
          (c) => c.id == t.categoryId,
          orElse: () => Category(
            id: "unknown",
            name: "Unknown",
            type: t.type,
            color: Colors.white70,
            icon: Icons.category,
          ),
        );

        return GlassmorphismCard(
          height: 80,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha:0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: category.color.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 15),
                
                // Transaction Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${t.date.day}/${t.date.month}/${t.date.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${t.type == "income" ? "+" : "-"} ${appState.currency} ${t.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: t.type == "income" ? const Color(0xFF00bfa5) : const Color(0xFFFF6B6B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        color: t.type == "income" ? const Color(0xFF00bfa5) : const Color(0xFFFF6B6B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/* ================= SETTINGS ================= */

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Header
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Manage your preferences',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Profile Section
          Text(
            'Profile',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 15),
          
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFF00bfa5).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Color(0xFF00bfa5).withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF00bfa5),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appState.user?.name ?? 'User',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              appState.user?.email ?? 'user@example.com',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      SizedBox(
                        width: 150,
                        child: GlassmorphismButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EditProfilePage()),
                            );
                          },
                          child: const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF004d40),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 25),
          
          // App Settings
          Text(
            'App Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 15),
          
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSettingItem(
                    Icons.language,
                    'Currency',
                    appState.currency,
                    () => _showCurrencyDialog(context, appState),
                  ),
                  const Divider(color: Colors.white24),
                  _buildSettingItem(
                    Icons.track_changes,
                    'Monthly Budget',
                    'Track budget usage and alerts',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MonthlyBudgetPage()),
                      );
                    },
                  ),
                  const Divider(color: Colors.white24),
                  _buildSettingItem(
                    Icons.notifications,
                    'Notifications',
                    'Enabled',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationPage()),
                      );
                    },
                  ),
                  const Divider(color: Colors.white24),
                  _buildSettingItem(
                    Icons.security,
                    'Security',
                    '2FA & biometric settings',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SecurityPage()),
                      );
                    },
                  ),
                  const Divider(color: Colors.white24),
                  _buildSettingItem(
                    Icons.backup,
                    'Backup & Sync',
                    'Last backup: Today',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BackupPage()),
                      );
                    },
                  ),
                  const Divider(color: Colors.white24),
                  _buildSettingItem(
                    Icons.category,
                    'Manage Categories',
                    'Manage your own expense categories',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CustomCategoriesPage()),
                      );
                    },
                  ),
                  const Divider(color: Colors.white24),
                  _buildSettingItem(
                    Icons.receipt_long,
                    'Upcoming Bills',
                    'Track due dates and amounts',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const UpcomingBillsPage()),
                      );
                    },
                  ),
                  const Divider(color: Colors.white24),
                  _buildSettingItem(
                    Icons.savings,
                    'Savings Goal',
                    'Set and track your target',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SavingsGoalPage()),
                      );
                    },
                  ),
                  const Divider(color: Colors.white24),
                  _buildSettingItem(
                    Icons.favorite,
                    'Savings Wishlist',
                    'Plan and fund your wishlist items',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SavingsWishlistPage()),
                      );
                    },
                  ),
                  const Divider(color: Colors.white24),
                  _buildSettingItem(
                    Icons.account_balance_wallet,
                    'Debt & Credits',
                    'Track udhaar and receivables',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DebtCreditsPage()),
                      );
                    },
                  ),
                  const Divider(color: Colors.white24),
                  _buildSettingItem(
                    Icons.groups,
                    'Split with Friends',
                    'Calculate per-person share',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SplitBillPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 25),
          
          // Danger Zone
          Text(
            'Danger Zone',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 15),
          
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDangerItem(
                    Icons.delete,
                    'Delete Account',
                    'Permanently delete all data',
                    Colors.red,
                    () => _showDeleteAccountDialog(context),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 10),
                  _buildDangerItem(
                    Icons.logout,
                    'Sign Out',
                    'Log out from all devices',
                    Colors.orange,
                    () => _showSignOutDialog(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerItem(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, AppState appState) {
    String selectedCurrency = appState.currency;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF004d40),
        title: Text(
          'Select Currency',
          style: TextStyle(color: Colors.white),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('PKR - Pakistani Rupee', style: TextStyle(color: Colors.white)),
                  trailing: selectedCurrency == 'PKR' ? Icon(Icons.check, color: const Color(0xFF00bfa5)) : null,
                  onTap: () => setState(() => selectedCurrency = 'PKR'),
                ),
                ListTile(
                  title: Text('USD - US Dollar', style: TextStyle(color: Colors.white)),
                  trailing: selectedCurrency == 'USD' ? Icon(Icons.check, color: const Color(0xFF00bfa5)) : null,
                  onTap: () => setState(() => selectedCurrency = 'USD'),
                ),
                ListTile(
                  title: Text('EUR - Euro', style: TextStyle(color: Colors.white)),
                  trailing: selectedCurrency == 'EUR' ? Icon(Icons.check, color: const Color(0xFF00bfa5)) : null,
                  onTap: () => setState(() => selectedCurrency = 'EUR'),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              appState.setCurrency(selectedCurrency);
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: const Color(0xFF00bfa5))),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF004d40),
        title: Text(
          'Delete Account',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'This will permanently delete all your data. This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              // Clear all data
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion would happen here')),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF004d40),
        title: Text(
          'Sign Out',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Confirm Logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              try {
                context.read<AppState>().setUser(null);
              } catch (_) {}
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthPage()),
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed out successfully')),
              );
            },
            child: Text('Logout', style: TextStyle(color: const Color(0xFF00bfa5))),
          ),
        ],
      ),
    );
  }
}

/* ================= PLACEHOLDER PAGES ================= */

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool pushNotifications = true;
  bool emailAlerts = true;
  bool appUpdates = true;
  bool dailyReminder = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive instant alerts on your device'),
            value: pushNotifications,
            onChanged: (value) => setState(() => pushNotifications = value),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Email Alerts'),
            subtitle: const Text('Get important account updates by email'),
            value: emailAlerts,
            onChanged: (value) => setState(() => emailAlerts = value),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('App Updates'),
            subtitle: const Text('Notify me about new app versions'),
            value: appUpdates,
            onChanged: (value) => setState(() => appUpdates = value),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Daily Reminder'),
            subtitle: const Text('Remind me to log expenses every evening'),
            value: dailyReminder,
            onChanged: (value) {
              setState(() => dailyReminder = value);
              if (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'We will remind you to log expenses every evening!',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _isTwoFactor = false;
  bool _isBiometric = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Two-Factor Authentication'),
              subtitle: const Text('Extra security with verification code'),
              value: _isTwoFactor,
              onChanged: (value) {
                setState(() {
                  _isTwoFactor = value;
                });
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Biometric Lock'),
              subtitle: const Text('Unlock app using fingerprint/face'),
              value: _isBiometric,
              onChanged: (value) {
                setState(() {
                  _isBiometric = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CustomCategoriesPage extends StatefulWidget {
  const CustomCategoriesPage({super.key});

  @override
  State<CustomCategoriesPage> createState() => _CustomCategoriesPageState();
}

class MonthlyBudgetPage extends StatefulWidget {
  const MonthlyBudgetPage({super.key});

  @override
  State<MonthlyBudgetPage> createState() => _MonthlyBudgetPageState();
}

class _MonthlyBudgetPageState extends State<MonthlyBudgetPage> {
  double monthlyBudget = 50000.0;

  void _showSetBudgetDialog() {
    final controller = TextEditingController(text: monthlyBudget.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF004d40),
        title: const Text('Set Monthly Budget', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter budget amount',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim()) ?? 0;
              if (value <= 0) return;
              setState(() => monthlyBudget = value);
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Color(0xFF00bfa5))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final now = DateTime.now();
    final expense = appState.getMonthlyExpense(now);
    final progress = (expense / monthlyBudget).clamp(0.0, 1.0);
    final progressColor = progress > 0.9
        ? Colors.red
        : (progress < 0.8 ? Colors.tealAccent : Colors.orangeAccent);

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Budget')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _showSetBudgetDialog,
                icon: const Icon(Icons.edit),
                label: const Text('Set Budget'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Spent: ${appState.currency} ${expense.toStringAsFixed(0)} / ${monthlyBudget.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 14,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toStringAsFixed(0)}% budget used',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class DebtCreditsPage extends StatefulWidget {
  const DebtCreditsPage({super.key});

  @override
  State<DebtCreditsPage> createState() => _DebtCreditsPageState();
}

class _DebtCreditsPageState extends State<DebtCreditsPage> {
  final TextEditingController _personController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isOwedByMe = true;

  @override
  void dispose() {
    _personController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _showAddDebtDialog() {
    _personController.clear();
    _amountController.clear();
    _isOwedByMe = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF004d40),
          title: const Text('Add Debt/Credit', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _personController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Person Name',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('I owe this money', style: TextStyle(color: Colors.white)),
                  value: _isOwedByMe,
                  onChanged: (value) => setDialogState(() => _isOwedByMe = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                final person = _personController.text.trim();
                final amount = double.tryParse(_amountController.text.trim()) ?? 0;
                if (person.isEmpty || amount <= 0) return;

                context.read<AppState>().addDebtEntry(
                      DebtEntry(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        personName: person,
                        amount: amount,
                        isOwedByMe: _isOwedByMe,
                        date: DateTime.now(),
                      ),
                    );
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: Color(0xFF00bfa5))),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final debts = appState.debtEntries;

    return Scaffold(
      appBar: AppBar(title: const Text('Debt & Credits')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDebtDialog,
        backgroundColor: const Color(0xFF00bfa5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: debts.isEmpty
            ? const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(
                  child: Text(
                    'No debt/credit entries yet. Tap + to add.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: debts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final entry = debts[index];
                  final title = entry.isOwedByMe ? 'You owe' : 'You will receive';
                  final color = entry.isOwedByMe ? const Color(0xFFFF6B6B) : const Color(0xFF00bfa5);

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.20),
                        child: Icon(
                          entry.isOwedByMe ? Icons.call_made : Icons.call_received,
                          color: color,
                        ),
                      ),
                      title: Text(entry.personName, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        '$title • ${entry.date.day}/${entry.date.month}/${entry.date.year}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Text(
                        '${appState.currency} ${entry.amount.toStringAsFixed(0)}',
                        style: TextStyle(color: color, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _CustomCategoriesPageState extends State<CustomCategoriesPage> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog() {
    _nameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF004d40),
        title: const Text('Add New Category', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Category name',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              final name = _nameController.text.trim();
              if (name.isNotEmpty) {
                context.read<AppState>().addCustomCategory(name);
              }
              Navigator.pop(context);
            },
            child: const Text('Add', style: TextStyle(color: Color(0xFF00bfa5))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<AppState>().categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Custom Categories')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (categories.isEmpty)
              const Text('No categories available yet.')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final c = categories[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: c.color.withValues(alpha: 0.25),
                      child: Icon(c.icon, color: c.color),
                    ),
                    title: Text(c.name),
                    subtitle: Text(c.type.toUpperCase()),
                  );
                },
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showAddCategoryDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add New'),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class UpcomingBillsPage extends StatefulWidget {
  const UpcomingBillsPage({super.key});

  @override
  State<UpcomingBillsPage> createState() => _UpcomingBillsPageState();
}

class _UpcomingBillsPageState extends State<UpcomingBillsPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _showAddBillDialog() {
    _titleController.clear();
    _amountController.clear();
    _selectedDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF004d40),
          title: const Text('Add Bill Reminder', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Bill Name',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today, color: Colors.white70),
                  title: const Text('Due Date', style: TextStyle(color: Colors.white70)),
                  subtitle: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      setDialogState(() => _selectedDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                final title = _titleController.text.trim();
                final amount = double.tryParse(_amountController.text.trim()) ?? 0;
                if (title.isEmpty || amount <= 0) return;

                context.read<AppState>().addBillReminder(
                      BillReminder(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: title,
                        amount: amount,
                        dueDate: _selectedDate,
                      ),
                    );
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: Color(0xFF00bfa5))),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final bills = appState.billReminders;

    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Bills')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBillDialog,
        backgroundColor: const Color(0xFF00bfa5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: bills.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Text('No bill reminders yet. Tap + to add one.'),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bills.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final bill = bills[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text(bill.title),
                      subtitle: Text(
                        'Due Date: ${bill.dueDate.day}/${bill.dueDate.month}/${bill.dueDate.year}',
                      ),
                      trailing: Text(
                        '${appState.currency} ${bill.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class SavingsGoalPage extends StatefulWidget {
  const SavingsGoalPage({super.key});

  @override
  State<SavingsGoalPage> createState() => _SavingsGoalPageState();
}

class _SavingsGoalPageState extends State<SavingsGoalPage> {
  final TextEditingController _goalTitleController = TextEditingController();
  final TextEditingController _goalTargetController = TextEditingController();
  final TextEditingController _saveAmountController = TextEditingController();

  @override
  void dispose() {
    _goalTitleController.dispose();
    _goalTargetController.dispose();
    _saveAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final goalTitle = appState.savingsGoalTitle;
    final target = appState.savingsGoalTarget;
    final current = appState.savingsCurrentAmount;
    final progress = appState.savingsProgress;

    return Scaffold(
      appBar: AppBar(title: const Text('Savings Goal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _goalTitleController,
              decoration: const InputDecoration(
                labelText: 'Goal Title (e.g. New Phone)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _goalTargetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Target Amount',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final title = _goalTitleController.text.trim();
                  final targetAmount =
                      double.tryParse(_goalTargetController.text.trim()) ?? 0;
                  if (title.isEmpty || targetAmount <= 0) return;

                  context.read<AppState>().setSavingsGoal(
                        title: title,
                        target: targetAmount,
                      );
                },
                child: const Text('Set Savings Goal'),
              ),
            ),
            const SizedBox(height: 24),
            if (goalTitle.isNotEmpty && target > 0) ...[
              Text(
                goalTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Saved: ${appState.currency} ${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)}',
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: progress,
                minHeight: 14,
                backgroundColor: Colors.white24,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF00bfa5)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _saveAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Add Saved Amount',
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final amount =
                        double.tryParse(_saveAmountController.text.trim()) ?? 0;
                    if (amount <= 0) return;
                    context.read<AppState>().addSavings(amount);
                    _saveAmountController.clear();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add to Savings Progress'),
                ),
              ),
            ] else
              const Text('Set a goal to start tracking your progress.'),
          ],
        ),
      ),
    );
  }
}

class BackupPage extends StatelessWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Sync'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              leading: Icon(Icons.cloud_done),
              title: Text('Last Backup'),
              subtitle: Text('Today, 10:30 AM'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup started...')),
                  );
                },
                icon: const Icon(Icons.sync),
                label: const Text('Backup Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppState>().user;
    nameController = TextEditingController(text: user?.name ?? 'User');
    emailController = TextEditingController(text: user?.email ?? 'user@example.com');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const CircleAvatar(
              radius: 44,
              child: Icon(Icons.person, size: 44),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final email = emailController.text.trim();
                  if (name.isEmpty || email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter name and email')),
                    );
                    return;
                  }

                  context.read<AppState>().updateProfile(name: name, email: email);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Update'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class SplitBillPage extends StatefulWidget {
  const SplitBillPage({super.key});

  @override
  State<SplitBillPage> createState() => _SplitBillPageState();
}

class _SplitBillPageState extends State<SplitBillPage> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController peopleController = TextEditingController(text: '2');

  @override
  void dispose() {
    amountController.dispose();
    peopleController.dispose();
    super.dispose();
  }

  double get perPersonShare {
    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    final people = int.tryParse(peopleController.text.trim()) ?? 0;
    if (amount <= 0 || people <= 0) return 0;
    return amount / people;
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<AppState>().currency;
    return Scaffold(
      appBar: AppBar(title: const Text('Split with Friends')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: peopleController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Number of People',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Text(
                'Per Person: $currency ${perPersonShare.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SavingsWishlistPage extends StatefulWidget {
  const SavingsWishlistPage({super.key});

  @override
  State<SavingsWishlistPage> createState() => _SavingsWishlistPageState();
}

class _SavingsWishlistPageState extends State<SavingsWishlistPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _showAddItemDialog() {
    _titleController.clear();
    _targetController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF004d40),
        title: const Text('Add Wishlist Item', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Item Name', labelStyle: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _targetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Target Amount', labelStyle: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final title = _titleController.text.trim();
              final target = double.tryParse(_targetController.text.trim()) ?? 0;
              if (title.isEmpty || target <= 0) return;
              context.read<AppState>().addWishlistItem(
                    WishlistItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: title,
                      targetAmount: target,
                    ),
                  );
              Navigator.pop(context);
            },
            child: const Text('Add', style: TextStyle(color: Color(0xFF00bfa5))),
          ),
        ],
      ),
    );
  }

  void _showSaveDialog(WishlistItem item) {
    final controller = TextEditingController(text: '500');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF004d40),
        title: Text('Save to ${item.title}', style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'Amount', hintStyle: TextStyle(color: Colors.white54)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text.trim()) ?? 0;
              if (amount <= 0) return;
              context.read<AppState>().saveToWishlistItem(itemId: item.id, amount: amount);
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Color(0xFF00bfa5))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Savings Wishlist')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        backgroundColor: const Color(0xFF00bfa5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Savings: ${appState.currency} ${appState.savingsCurrentAmount.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (appState.wishlistItems.isEmpty)
              const Text('No wishlist items yet. Tap + to add one.')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: appState.wishlistItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = appState.wishlistItems[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 6),
                        Text(
                          'Saved ${appState.currency} ${item.savedAmount.toStringAsFixed(0)} / ${item.targetAmount.toStringAsFixed(0)}',
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: item.progress, minHeight: 10),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () => _showSaveDialog(item),
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class ExportReportPage extends StatefulWidget {
  const ExportReportPage({super.key});

  @override
  State<ExportReportPage> createState() => _ExportReportPageState();
}

class _ExportReportPageState extends State<ExportReportPage> {
  bool isProcessing = false;
  final double reportBudget = 50000;

  Future<void> _exportReport(String type) async {
    setState(() => isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report downloaded successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sections = [
      ('Food', 18000.0, const Color(0xFFFF6B6B)),
      ('Bills', 12000.0, const Color(0xFF4ECDC4)),
      ('Shopping', 9000.0, const Color(0xFF45B7D1)),
    ];
    final total = sections.fold<double>(0, (s, e) => s + e.$2);

    return Scaffold(
      appBar: AppBar(title: const Text('Export Reports')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Category-wise Spending',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: sections
                      .map(
                        (e) => PieChartSectionData(
                          value: e.$2,
                          color: e.$3,
                          title: '${((e.$2 / total) * 100).toStringAsFixed(0)}%',
                          radius: 72,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...sections.map(
              (e) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(backgroundColor: e.$3, radius: 8),
                title: Text(e.$1),
                subtitle: Text('Used ${((e.$2 / reportBudget) * 100).toStringAsFixed(0)}% of budget'),
                trailing: Text('PKR ${e.$2.toStringAsFixed(0)}'),
              ),
            ),
            const Divider(),
            if (isProcessing) ...[
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              const Text('Preparing your report...'),
              const SizedBox(height: 24),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isProcessing ? null : () => _exportReport('pdf'),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Export as PDF'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isProcessing ? null : () => _exportReport('excel'),
                icon: const Icon(Icons.table_chart),
                label: const Text('Export as Excel'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
