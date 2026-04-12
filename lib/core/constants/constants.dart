// file: lib/utils/constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'FM Dictionary';

  // Colors
  static const Color primaryColor = Color(0xFF1A1A1A);
  static const Color accentColor = Color(0xFFF27D26);
  static const Color backgroundColor = Color(0xFFFDFCF9);
  static const Color darkBgColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Colors.grey;
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);

  // Fonts
  static const String bodyFont = 'Inter';
  static const String displayFont = 'Playfair Display';

  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    fontFamily: displayFont,
    fontStyle: FontStyle.normal,
  );

  static const TextStyle subHeadingStyle = TextStyle(
    fontSize: 12,
    letterSpacing: 2,
    color: textSecondary,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle wordStyle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    fontFamily: displayFont,
    letterSpacing: -0.5,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    fontFamily: bodyFont,
    color: textPrimary,
  );

  // Layout
  static const double defaultPadding = 24.0;
  static const double cardRadius = 32.0;
  static const double buttonRadius = 20.0;
  static const double inputRadius = 16.0;

  // Animations
  static const Duration flipDuration = Duration(milliseconds: 400);
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

 // Topic Icons Mapping - Extended for FM & Sustainability
  static const Map<String, IconData> topicIcons = {
    // --- General & Building Services ---
    'General Facilities Management': Icons.business_rounded,
    'Project & Project Management': Icons.assignment_rounded,
    'Building Control': Icons.settings_remote_rounded,
    'Emergency': Icons.emergency_rounded,
    'Space Management': Icons.aspect_ratio_rounded,
    'General Maintenance': Icons.build_circle_rounded,
    'Electrical': Icons.electrical_services_rounded,
    'Mechanical': Icons.engineering_rounded,
    'HVAC': Icons.ac_unit_rounded,
    'Life Safety': Icons.health_and_safety_rounded,
    'Building Automation': Icons.smart_toy_rounded,
    'AV and Comms': Icons.settings_input_component_rounded,
    'Plumbing': Icons.plumbing_rounded,
    'Lifts and Escalators': Icons.elevator_rounded,
    'Building Fabric': Icons.foundation_rounded,

    // --- Soft Services & Workplace ---
    'Pest Control': Icons.pest_control_rounded,
    'Landscaping': Icons.park_rounded,
    'Cleaning Services': Icons.cleaning_services_rounded,
    'Indoor Plants': Icons.local_florist_rounded,
    'Transportation': Icons.directions_bus_rounded,
    'Mailroom': Icons.mail_rounded,
    'Reception': Icons.room_service_rounded,
    'Luggage Storage': Icons.luggage_rounded,
    'Lost & Found': Icons.find_in_page_rounded,
    'Meeting Rooms': Icons.meeting_room_rounded,
    'Events': Icons.event_available_rounded,
    'Employee': Icons.person_pin_rounded,
    'Pantry & Catering': Icons.restaurant_rounded,

    // --- Sustainability & Environment ---
    'Sustainability': Icons.eco_rounded,
    'Energy & Lighting': Icons.bolt_rounded,
    'Water Efficiency': Icons.water_drop_rounded,
    'Sustainability Campaign': Icons.campaign_rounded,
    'Compliance': Icons.fact_check_rounded,
    'Strategy & Decarbonization': Icons.co2_rounded,
    'Building Certification': Icons.verified_rounded,
    'EV Charging': Icons.ev_station_rounded,
    'Renewable Energy': Icons.solar_power_rounded,
    'Carbon Disclosure': Icons.cloud_done_rounded,
    'Net Zero Development': Icons.location_city_rounded,
    'Resiliency': Icons.shield_moon_rounded,

    // --- Finance & Procurement ---
    'Financial Management': Icons.account_balance_rounded,
    'Revenue & Accounts': Icons.monetization_on_rounded,
    'Accounts Payable': Icons.receipt_long_rounded,
    'T&E – Expense': Icons.wallet_rounded,
    'Labour Allocation': Icons.work_history_rounded,
    'Commissioning': Icons.playlist_add_check_rounded,
    'Fixed Assets': Icons.apartment_rounded,
    'Tax': Icons.request_quote_rounded,
    'Audit': Icons.troubleshoot_rounded,
    'Budgeting': Icons.savings_rounded,
    'Forecasting': Icons.query_stats_rounded,
    'Procurement': Icons.shopping_cart_rounded,
    'Sourcing Strategy': Icons.manage_search_rounded,
    'Supplier Management': Icons.handshake_rounded,
    'Vendor Management': Icons.contact_page_rounded,

    // --- Technology & Safety ---
    'Technology': Icons.memory_rounded,
    'Security & Robotics': Icons.smart_button_rounded,
    'AI & Smart': Icons.psychology_rounded,
    'Health': Icons.medical_services_rounded,
    'Safety': Icons.security_rounded,
    'Environment': Icons.public_rounded,
    'Flood Response': Icons.flood_rounded,
    'Spill Response': Icons.opacity_rounded,
    'Safety Equipment': Icons.construction_rounded,
    'Post-Incident': Icons.history_edu_rounded,
    'Human Resources': Icons.groups_rounded,
    'Laws, Ethics': Icons.gavel_rounded,
    'Business Continuity': Icons.loop_rounded,

    // --- Default / Others ---
    'General': Icons.more_horiz_rounded,
  };
  // Thêm vào class AppConstants trong lib/core/constants/constants.dart
  static const List<String> motivationalSlogans = [
    "Học một ngoại ngữ, sống thêm một cuộc đời.",
    "Mỗi từ mới là một cánh cửa mới mở ra.",
    "Chỉ cần 5 phút mỗi ngày, bạn sẽ thấy sự khác biệt.",
    "Thất bại là khi bạn ngừng cố gắng. Đừng dừng lại!",
    "Kiến thức là sức mạnh, hãy tích lũy nó ngay hôm nay.",
    "Học tập là hạt giống của hạnh phúc.",
    "Đừng đợi cơ hội, hãy tự tạo ra nó bằng việc học.",
    "Success is the sum of small efforts, repeated day in and day out.",
    "Your future self will thank you for studying today.",
    "Language is the road map of a culture.",
  ];
}
