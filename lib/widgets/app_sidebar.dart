import 'package:flutter/material.dart';

import '../screens/dashboard_page.dart';
import '../screens/werkbonnen_page.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFF1E293B),

      child: Column(
        children: [

          const SizedBox(height: 20),

          Image.asset(
            "assets/langman_logo.png",
            height: 80,
          ),

          const SizedBox(height: 10),

          const Text(
            "Langman App",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 30),

          _menu(
            context,
            Icons.dashboard,
            "Dashboard",
            const DashboardPage(),
          ),

          _menu(
            context,
            Icons.assignment,
            "Werkbonnen",
            const WerkbonnenPage(),
          ),

          _menu(
            context,
            Icons.precision_manufacturing,
            "Machines",
            const Scaffold(
              body: Center(
                child: Text("Machines"),
              ),
            ),
          ),

          _menu(
            context,
            Icons.settings_applications,
            "Instellingen",
            const Scaffold(
              body: Center(
                child: Text("Instellingen"),
              ),
            ),
          ),

          _menu(
            context,
            Icons.menu_book,
            "Handleidingen",
            const Scaffold(
              body: Center(
                child: Text("Handleidingen"),
              ),
            ),
          ),

          _menu(
            context,
            Icons.inventory_2,
            "Producten",
            const Scaffold(
              body: Center(
                child: Text("Producten"),
              ),
            ),
          ),

          _menu(
            context,
            Icons.people,
            "Gebruikers",
            const Scaffold(
              body: Center(
                child: Text("Gebruikers"),
              ),
            ),
          ),

          const Spacer(),

          _menu(
            context,
            Icons.logout,
            "Uitloggen",
            const DashboardPage(),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _menu(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),

      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => page,
          ),
        );
      },
    );
  }
}