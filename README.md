# African Inflation Regression App

## Mission Description
Predicting African inflation rates to help policymakers and economists understand economic stability patterns across African countries. This solution analyzes historical economic crises data to forecast inflation trends, enabling better financial planning and policy decisions.

## Dataset Information
**Source**: African Economic, Banking and Systemic Crises Data from Kaggle
**Description**: Contains 1059 records of African countries' economic indicators from 1860-2014, including inflation rates, banking crises, currency crises, and sovereign debt defaults across 13 African countries.

## Project Structure

```
linear_regression_model/
│
├── summative/
│   ├── linear_regression/
│   │   ├── multivariate.ipynb                  # Model building/EDA notebook (Task 1)
│   │   ├── african_crises (1).csv              # Raw input dataset
│   │   ├── best_inflation_model.pkl            # Saved Decision Tree model
│   │   ├── inflation_scaler.pkl                # Saved StandardScaler
│   │   ├── inflation_correlation_heatmap.png   # Visualization files
│   │   ├── inflation_gd_loss_curve.png         
│   │   └── inflation_true_vs_predicted_scatter.png
│   ├── API/
│   │   ├── prediction.py                       # FastAPI code (Task 2)
│   │   └── requirements.txt                    # Python dependencies
│   └── inflation_app/
│       └── (Flutter source code files)         # Mobile application (Task 3)
│
└── README.md                                   # This file
```

## Tasks Overview

### Task 1: Machine Learning Model
- Data exploration and analysis
- Feature engineering and preprocessing
- Model training and evaluation
- Model persistence and visualization

### Task 2: API Development
- FastAPI implementation for model predictions
- RESTful endpoints for inflation prediction
- Model loading and inference pipeline

### Task 3: Mobile Application
- Flutter-based mobile interface
- Integration with prediction API
- User-friendly inflation prediction interface

## API Endpoint

**Live API URL**: https://african-inflation-api.onrender.com/predict
**Swagger Documentation**: https://african-inflation-api.onrender.com/docs

## Video Demo

**YouTube Demo Link**: https://youtu.be/your-video-id

## Mobile App Instructions

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Android Studio or VS Code with Flutter extension
- Android device/emulator or iOS device/simulator

### Running the Mobile App

1. Navigate to the Flutter app directory:
   ```bash
   cd linear_regression_model/summative/inflation_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. The API URL is already configured in `lib/prediction_page.dart`:
   - Current API: `https://african-inflation-api.onrender.com/predict`

4. Run the app:
   ```bash
   flutter run
   ```

### App Features
- Home screen with navigation to prediction
- Input form with 8 economic indicators
- Real-time API integration for predictions
- Error handling and validation
- Clean, organized UI layout

## Getting Started

1. Navigate to the appropriate task folder
2. Follow the specific instructions in each component
3. Ensure all dependencies are installed as specified in requirements.txt

## Dependencies

See `linear_regression_model/summative/API/requirements.txt` for Python dependencies.