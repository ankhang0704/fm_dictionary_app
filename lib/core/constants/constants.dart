import 'package:flutter/material.dart';
// Note: Ensure you have the 'google_fonts' package in your pubspec.yaml

/// Centralized Design System Constants for the English Learning App
class AppStyles {
  // Prevent instantiation
  AppStyles._();

  static const String appName = 'FM Dictionary';
}
/// 4. Animations
class AppAnimations {
  AppAnimations._();

  // Standard Durations
  static const Duration short = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 400);

  // Standard Curves
  /// Recommended curve for smooth, natural glass interactions and Bento card scaling
  static const Curve glassInteractionCurve = Curves.easeInOutCubic;
}

class AppConstants {
 // Topic Icons Mapping - Extended for FM & Sustainability
  static const Map<String, IconData> topicIcons = {
    // --- General & Building Services ---
    "General Facilities Management": Icons.business_center,
    "Project & Financial Management": Icons.assignment,
    "Building Operations": Icons.apartment,
    "Emergency ": Icons.emergency, // Giữ nguyên dấu cách cuối nếu có
    "Space Management": Icons.square_foot,
    "General Maintenance": Icons.build,
    "Electrical ": Icons.electrical_services,
    "Mechanical": Icons.settings,
    "HVAC": Icons.ac_unit,
    "Life Safety Systems": Icons.security,
    "Building Automation Systems": Icons.settings_input_component,
    "AV and Communication Systems": Icons.settings_voice,
    "Plumbing & Drainage": Icons.plumbing,
    "Lifts and Elevators": Icons.elevator,
    "Building Fabric": Icons.foundation,
    "AV & Communication Systems": Icons.connected_tv,
    "Pest Control ": Icons.bug_report,
    "Landscaping": Icons.park,
    "Cleaning Services": Icons.cleaning_services,
    "Indoor Plant": Icons.eco,
    "Transport Services ": Icons.local_shipping,
    "Mailroom & Courier Services": Icons.mail,
    "Reception & Guest Services": Icons.support_agent,
    "Luggage Storage": Icons.luggage,
    "Lost & Found": Icons.find_in_page,
    "Meeting Room Booking": Icons.meeting_room,
    "Events": Icons.event,
    "Employee Relations": Icons.people_alt,
    "Pantry & Office Supply": Icons.kitchen,

    // Nhóm 2: Sustainability
    "Sustainability & Energy": Icons.energy_savings_leaf,
    "Sustainability Principles": Icons.psychology,
    "Sustainable Facility Practices": Icons.home_repair_service,
    "Energy & Lighting Efficiency": Icons.lightbulb,
    "Water Efficiency": Icons.opacity,
    "Sustainable Materials & Equipment": Icons.inventory_2,
    "Campaigns & Engagement": Icons.campaign,
    "Compliance & Reporting": Icons.assessment,
    "Strategy & Innovation": Icons.lightbulb_outline,
    "Decarbonization Strategy": Icons.co2,
    "Sustainability Strategy": Icons.trending_up,
    "Sustainability Program Management": Icons.manage_accounts,
    "Building Optimization (Energy Assessments)": Icons.analytics,
    "EV Charging Solution": Icons.ev_station,
    "Renewable Energy": Icons.solar_power,
    "Carbon Disclosure Reporting": Icons.description,
    "Net Zero Design & Construction": Icons.architecture,
    "Resiliency (Microgrid/Storage)": Icons.battery_charging_full,

    // Nhóm 3: Finance
    "Financial Management": Icons.account_balance,
    "Revenue & Accounts Receivable": Icons.add_chart,
    "Accounts Payable": Icons.payments,
    "T&E – Expenses": Icons.receipt_long,
    "Labour Allocation": Icons.groups,
    "Commissions": Icons.monetization_on,
    "Fixed Assets & Capital Expenditure": Icons.domain,
    "Tax": Icons.request_quote,
    "Audit": Icons.fact_check,
    "Budgeting": Icons.savings,
    "Forecasting": Icons.timeline,

    // Nhóm 4: Technology & Security
    "Technology & Systems": Icons.memory,
    "Security & Access Control": Icons.lock,
    "Robotics": Icons.smart_toy,
    "AI & Smart Systems": Icons.auto_awesome,
    "General": Icons.category,

    // Nhóm 5: Health & Safety
    "Health, Safety, Compliance": Icons.health_and_safety,
    "Flood Response": Icons.flood,
    "Spill Response": Icons.format_color_fill,
    "Safety & Equipment": Icons.construction,
    "Post-Incident": Icons.history_edu,
    "Safety": Icons.shield,
    "Health": Icons.medical_services,
    "Environment": Icons.terrain,
    "Security": Icons.verified_user,

    // Nhóm 6: Procurement & Strategy
    "Advanced Concepts": Icons.tips_and_updates,
    "Contracting and Compliance": Icons.gavel,
    "Digital Procurement": Icons.shopping_cart_checkout,
    "International Trade": Icons.public,
    "Inventory Management": Icons.warehouse,
    "Procurement Basics": Icons.shopping_bag,
    "Sourcing Process": Icons.search,
    "Strategic Procurement": Icons.ads_click,
    "Supplier Management": Icons.handshake,
    "Technology and Systems": Icons.computer,
    "Vendor Management": Icons.supervisor_account,

    // Nhóm 7: HR & Risk
    "Human Resources": Icons.badge,
    "Laws, Ethics & Compliance": Icons.policy,
    "Business Continuity & Risk": Icons.warning,
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
