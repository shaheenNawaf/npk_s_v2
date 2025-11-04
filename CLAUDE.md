# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AGRI-SENSE is a Flutter-based soil analysis and crop recommendation application. The app collects comprehensive soil data through multiple methods (file upload, manual entry, or sensor connection), performs analysis using a custom ML model via backend API, and provides AI-driven agricultural advice using Google's Gemini API.

## Key Commands

### Development
```bash
# Install dependencies
flutter pub get

# Run the app (after starting backend server)
flutter run --dart-define-from-file=config.json

# Run on specific platform
flutter run -d chrome --dart-define-from-file=config.json
flutter run -d windows --dart-define-from-file=config.json

# Build for production
flutter build apk --dart-define-from-file=config.json
flutter build windows --dart-define-from-file=config.json

# Analyze code
flutter analyze

# Format code
flutter format lib/
```

## Architecture Overview

### 3-Step Data Collection Flow
The app guides users through three sequential screens to gather comprehensive soil data:

1. **Soil Chemistry Screen** ([lib/pages/soil_chemistry_screen.dart](lib/pages/soil_chemistry_screen.dart))
   - Collects NPK values (nitrogen, phosphorus, potassium)
   - pH, moisture, temperature, conductivity
   - Micronutrients (calcium, magnesium, sodium, zinc, copper, iron, manganese, boron)
   - Sulfur, organic matter, exchangeable K

2. **Soil Properties Screen** ([lib/pages/soil_properties_screen.dart](lib/pages/soil_properties_screen.dart))
   - Soil type selection (13 types including loam, clay, sandy varieties)
   - Texture group (coarse, medium, moderately fine, fine)
   - Sand/silt/clay content percentages
   - Existing crops and primary crop (optional)

3. **Location & Climate Screen** ([lib/pages/location_climate_screen.dart](lib/pages/location_climate_screen.dart))
   - Auto-fetches location using Geolocator
   - Retrieves climate data from NASA POWER API (temperature, humidity, precipitation)
   - All fields editable for manual entry if auto-fetch fails

**Mock Data Support**: All three screens include a "Fill with Mock Data" button for rapid testing. The mock data is centralized in [lib/services/mock_data_service.dart](lib/services/mock_data_service.dart).

### Data Models

**SoilData** ([lib/models/soil_data.dart](lib/models/soil_data.dart)): Central data model containing all collected soil parameters. Includes:
- `fromMap()`: Parses Excel/CSV data with robust type handling
- `toJson()`: Converts to format expected by prediction service
- Contains 30+ soil-related properties spanning chemistry, physical properties, location, and climate data

**CropPrediction** ([lib/models/crop_prediction.dart](lib/models/crop_prediction.dart)): Represents ML model output with crop family, confidence scores, and top specific crop recommendations

**AiAdvice** ([lib/models/ai_advice.dart](lib/models/ai_advice.dart)): Structured AI advice from Gemini including title, summary, actionable steps, and things to avoid

### Services Layer

**PredictionService** ([lib/services/prediction_service.dart](lib/services/prediction_service.dart))
- Communicates with backend ML model at `http://192.168.1.10:8000/predict`
- IMPORTANT: Update `_baseUrl` for your environment:
  - Android emulator: `http://10.0.2.2:8000/predict`
  - Physical device/web: Use your computer's local IP address
- Sends soil NPK, pH, and location data; receives crop predictions

**GeminiService** ([lib/services/gemini_service.dart](lib/services/gemini_service.dart))
- Uses Google Gemini Flash model for AI-powered soil care advice
- Prompts model to return structured JSON with actionable recommendations
- Requires API key from `config.json` passed via `--dart-define-from-file`

**ClimateService** ([lib/services/climate_service.dart](lib/services/climate_service.dart))
- Uses Geolocator for device location
- Fetches annual climate averages from NASA POWER API
- Returns temperature (°C), relative humidity (%), and precipitation (mm/year)

**FileProcessingService** ([lib/services/file_processing_service.dart](lib/services/file_processing_service.dart))
- Processes uploaded XLSX and CSV files
- Extracts soil data from first valid row
- Maps column headers to SoilData properties

**MockDataService** ([lib/services/mock_data_service.dart](lib/services/mock_data_service.dart))
- Provides realistic sample data for all soil parameters
- Used by "Fill with Mock Data" buttons on all three input screens
- Includes realistic values: pH 6.5, NPK values, Manila coordinates, etc.

### Results Screen

**ResultsScreen** ([lib/pages/results_screen.dart](lib/pages/results_screen.dart))
- Displays 6-card grid showing key soil metrics with optimal ranges
- Color-coded indicators (green/yellow/red) for parameter health via StatCard widget
- Two action buttons:
  1. "Predict Best Crop": Calls backend ML model
  2. "Get General AI Advice": Calls Gemini for soil improvement tips
- Displays results as expandable cards with detailed recommendations

## Configuration

### API Keys
The app requires a Gemini API key in [config.json](config.json):
```json
{
  "GEMINI_API_KEY": "your-api-key-here"
}
```

IMPORTANT: Never commit real API keys. The current key in config.json should be replaced with your own.

### Backend Integration
The prediction service expects a backend server (not in this repo) that:
- Accepts POST requests at `/predict` endpoint
- Expects JSON: `{"pH": float, "N": float, "P": float, "K": float, "lat": float, "lon": float}`
- Returns JSON: `{"predictions": [{"crop_family": str, "family_confidence": float, "top_crops": [{"specific_crop": str, "confidence": float}]}]}`

## Project Structure Patterns

- **Models** (`lib/models/`): Data classes with JSON serialization
- **Services** (`lib/services/`): Business logic and external API integration
- **Pages** (`lib/pages/`): Full-screen views with their own state management
- **Widgets** (`lib/pages/widgets/`): Reusable UI components (CustomAppBar, StatCard)

## Common Development Workflows

### Adding New Soil Parameters
1. Update `SoilData` model with new property
2. Add parsing logic in `fromMap()` for file import support
3. Add field to `toJson()` if needed by backend
4. Add TextFormField in appropriate screen (usually SoilChemistryScreen)
5. Update controller initialization and disposal in screen's State class
6. Update `MockDataService` with sample value for the new parameter

### Modifying Prediction Logic
1. Update `PredictionService` to send additional parameters
2. Ensure backend API accepts new fields
3. Update `CropPrediction` model if response structure changes
4. Adjust result display in `ResultsScreen._buildPredictionResultCard()`

### Changing AI Prompts
1. Modify `GeminiService._buildSoilCarePrompt()` to adjust instructions
2. If JSON structure changes, update `AiAdvice` model accordingly
3. Update `ResultsScreen._buildAiAdviceCard()` to display new fields

### Adding Mock Data Features
When adding "Fill with Mock Data" functionality to new screens:
1. Import `MockDataService` in the screen file
2. Create a `_fillMockData()` method that calls `MockDataService.getMockSoilData()`
3. Use `setState()` to populate controllers/state variables with mock values
4. Add an `OutlinedButton.icon` with `Icons.auto_fix_high` icon
5. Position button before the primary action button (Next/Submit)

## Testing Notes

- No test files currently exist in the project
- The app is designed for manual/integration testing with real soil data
- Mock data functionality available via "Fill with Mock Data" buttons on all three input screens
- Mock data in `PredictionService` is commented out but can be re-enabled for UI testing without backend

## Platform Support

The app targets multiple platforms (Android, iOS, Windows, Linux, macOS, Web) but has specific considerations:
- Geolocator requires platform-specific permissions configuration
- File picker behavior differs between web (uses bytes) and native (uses file paths)
- Backend connectivity requires network configuration per platform (especially Android emulator)

## Git Branch Structure

- Current branch: `updated_flutter`
- Main branch: `master`
- Recent commits show UI development for 3-step input format and refactoring
