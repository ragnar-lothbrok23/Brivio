import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart';
import 'builder/builder_dashboard_screen.dart';
import 'contractor/contractor_dashboard_screen.dart';
import 'pm/pm_dashboard_screen.dart';
import 'site_engineer/site_engineer_dashboard_screen.dart';
import 'supervisor/supervisor_dashboard_screen.dart';
import 'vendor/vendor_dashboard_screen.dart';

class AuthGate extends StatelessWidget {
  AuthGate({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final user = authSnapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        return StreamBuilder(
          stream: _authService.streamUserProfile(user.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            final profile = profileSnapshot.data;
            if (profile == null) {
              // Auth account exists but its Firestore profile doc is missing
              // (e.g. signup was interrupted after auth succeeded). Sign out
              // so the user lands back on the login screen instead of a
              // dashboard that can't determine their role.
              _authService.logOut();
              return const _LoadingScreen();
            }

            BrivioApp.of(context).syncLocaleWithUser(profile.languageCode);

            if (profile.isBuilder) return BuilderDashboardScreen(user: profile);
            if (profile.isPm) return PmDashboardScreen(user: profile);
            if (profile.isSiteEngineer) return SiteEngineerDashboardScreen(user: profile);
            if (profile.isSupervisor) return SupervisorDashboardScreen(user: profile);
            if (profile.isVendor) return VendorDashboardScreen(user: profile);
            return ContractorDashboardScreen(user: profile);
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
