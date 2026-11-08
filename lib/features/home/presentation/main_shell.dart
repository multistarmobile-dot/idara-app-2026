import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation: ہوم | قرآن | نماز | تسبیح | مزید
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'ہوم',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'قرآن',
          ),
          NavigationDestination(
            icon: Icon(Icons.mosque_outlined),
            selectedIcon: Icon(Icons.mosque),
            label: 'نماز',
          ),
          NavigationDestination(
            icon: Icon(Icons.radio_button_checked_outlined),
            selectedIcon: Icon(Icons.radio_button_checked),
            label: 'تسبیح',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'مزید',
          ),
        ],
      ),
    );
  }
}
