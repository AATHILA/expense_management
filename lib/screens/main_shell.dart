import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'credit_screen.dart';
import 'expense_form_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  Widget _navIcon(IconData icon, int i) {
    final active = _index == i;
    return IconButton(
      onPressed: () => setState(() => _index = i),
      icon: Icon(icon,
          size: 26,
          color: active ? Colors.white : Colors.white.withValues(alpha: 0.55)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onSeeAll: () => setState(() => _index = 1)),
      const HistoryScreen(),
      const CreditScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          backgroundColor: kTeal,
          elevation: 0,
          shape: const CircleBorder(
              side: BorderSide(color: Color(0xFFCFE3E0), width: 4)),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExpenseFormScreen())),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: kTeal,
        height: 64,
        padding: EdgeInsets.zero,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navIcon(Icons.home_outlined, 0),
            _navIcon(Icons.history, 1),
            const SizedBox(width: 56),
            _navIcon(Icons.account_balance_wallet_outlined, 2),
            _navIcon(Icons.person_outline, 3),
          ],
        ),
      ),
    );
  }
}
