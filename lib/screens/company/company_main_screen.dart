import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'company_dashboard_screen.dart';
import 'create_internship_screen.dart';
import 'company_applicants_screen.dart';
import 'company_profile_screen.dart';

class CompanyMainScreen extends StatefulWidget {
  const CompanyMainScreen({super.key});

  @override
  State<CompanyMainScreen> createState() => _CompanyMainScreenState();
}

class _CompanyMainScreenState extends State<CompanyMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CompanyDashboardScreen(),
    CreateInternshipScreen(),
    CompanyApplicantsScreen(),
    CompanyProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: AppConstants.secondaryColor,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add_outlined),
            activeIcon: Icon(Icons.post_add_rounded),
            label: 'Lowongan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            activeIcon: Icon(Icons.people_alt_rounded),
            label: 'Pelamar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined),
            activeIcon: Icon(Icons.business_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
