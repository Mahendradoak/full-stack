import 'package:flutter/material.dart';

class ApiConstants {
  // IMPORTANT: Change this based on your setup
  // For web: use 'http://localhost:5000/api'
  // For Android emulator: use 'http://10.0.2.2:5000/api'
  // For iOS simulator: use 'http://localhost:5000/api'
  // For physical device: use 'http://YOUR_COMPUTER_IP:5000/api'
  
  static const String baseUrl = 'http://localhost:5000/api';
  
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String getMe = '/auth/me';
  
  static const String jobs = '/jobs';
  static const String featuredJobs = '/jobs/featured';
  
  static const String updateProfile = '/users/profile';
  static const String savedJobs = '/users/saved-jobs';
  static String saveJob(String jobId) => '/users/save-job/$jobId';
}

class AppColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color secondary = Color(0xFFEC4899);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color backgroundDark = Color(0xFF111827);
}

class AppStrings {
  static const String appName = 'Job Seeker';
  static const String tagline = 'Find your dream job today';
  
  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String name = 'Full Name';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = 'Already have an account?';
  
  static const String featuredJobs = 'Featured Jobs';
  static const String allJobs = 'All Jobs';
  static const String searchJobs = 'Search jobs...';
  static const String applyNow = 'Apply Now';
  static const String saveJob = 'Save Job';
  static const String savedJobs = 'Saved Jobs';
  
  static const String profile = 'Profile';
  static const String editProfile = 'Edit Profile';
  static const String settings = 'Settings';
  
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String apply = 'Apply';
  static const String reset = 'Reset';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String noDataFound = 'No data found';
  static const String somethingWentWrong = 'Something went wrong';
}

class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;
  
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
}

class StorageKeys {
  static const String token = 'auth_token';
  static const String user = 'user_data';
  static const String theme = 'theme_mode';
  static const String onboarding = 'onboarding_completed';
}