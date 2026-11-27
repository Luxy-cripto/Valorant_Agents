import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/agent_list_screen.dart';
import '../screens/agent_pool_form_screen.dart';
import '../screens/profile_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String agentList = '/agent-list';
  static const String agentPoolForm = '/agent-pool-form';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      home: (context) => const HomeScreen(),
      agentList: (context) => const AgentListScreen(),
      agentPoolForm: (context) => const AgentPoolFormScreen(),
      profile: (context) => const ProfileScreen(),
    };
  }
}