/// Centralized API Configuration
///
/// IMPORTANT: Update the baseUrl for your environment:
/// - Android Emulator: Use "http://10.0.2.2:8000" to connect to your computer's localhost
/// - Physical Device/Web: Use your computer's IP address (e.g., "http://192.168.1.10:8000")
/// - Production: Use your production server URL
class ApiConfig {
  // --- CHANGE THIS URL FOR YOUR ENVIRONMENT ---
  static const String baseUrl = "http://192.168.56.1:8000";

  // API Endpoints
  static const String healthEndpoint = "/health";
  static const String predictDetailedEndpoint = "/predict/detailed";

  // Full URLs (computed from base + endpoint)
  static String get healthUrl => "$baseUrl$healthEndpoint";
  static String get predictDetailedUrl => "$baseUrl$predictDetailedEndpoint";

  // Timeout configurations
  static const Duration healthCheckTimeout = Duration(seconds: 5);
  static const Duration predictionTimeout = Duration(seconds: 30);
}
