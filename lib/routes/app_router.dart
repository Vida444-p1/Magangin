import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/supabase_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_student_screen.dart';
import '../screens/auth/register_company_screen.dart';
import '../screens/home/student_main_screen.dart';
import '../screens/internship/search_screen.dart';
import '../screens/internship/internship_detail_screen.dart';
import '../screens/application/my_applications_screen.dart';
import '../screens/company/company_main_screen.dart';
import '../screens/company/create_internship_screen.dart';
import '../screens/company/company_applicants_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = SupabaseService.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register-student' ||
          state.matchedLocation == '/register-company';

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && (state.matchedLocation == '/' || isAuthRoute)) {
        return '/student';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, _) => '/student',
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register-student',
        builder: (context, state) => const RegisterStudentScreen(),
      ),
      GoRoute(
        path: '/register-company',
        builder: (context, state) => const RegisterCompanyScreen(),
      ),
      // Student Shell
      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentMainScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/internship/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return InternshipDetailScreen(internshipId: id);
        },
      ),
      GoRoute(
        path: '/my-applications',
        builder: (context, state) => const MyApplicationsScreen(),
      ),
      // Company Shell
      GoRoute(
        path: '/company',
        builder: (context, state) => const CompanyMainScreen(),
      ),
      GoRoute(
        path: '/create-internship',
        builder: (context, state) => const CreateInternshipScreen(),
      ),
      GoRoute(
        path: '/company-applicants',
        builder: (context, state) {
          final internshipId = state.uri.queryParameters['internshipId'];
          return CompanyApplicantsScreen(internshipId: internshipId);
        },
      ),
    ],
  );
}
