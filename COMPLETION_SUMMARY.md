# African Inflation Regression App - Completion Summary

## ✅ Task 1: Machine Learning Model (COMPLETED)

### Files Generated:
- ✅ `multivariate.ipynb` - Complete Jupyter notebook with EDA and model training
- ✅ `inflation_correlation_heatmap.png` - Correlation heatmap visualization
- ✅ `inflation_gd_loss_curve.png` - Gradient descent loss curve
- ✅ `inflation_true_vs_predicted_scatter.png` - Actual vs Predicted scatter plot
- ✅ `best_inflation_model.pkl` - Trained Decision Tree model
- ✅ `inflation_scaler.pkl` - StandardScaler for feature preprocessing

### Model Performance:
- **Best Model**: Decision Tree Regressor
- **MSE**: 2,267,151,609,235.59
- **R²**: 0.0013
- **Features**: 21 total (8 base features + 13 country dummy variables)

### Key Features:
- Data exploration and analysis of 1,059 records from 13 African countries (1860-2014)
- Feature engineering with categorical to numeric conversion
- Model comparison: Linear Regression, Decision Tree, Random Forest
- Comprehensive visualizations and model persistence

## ✅ Task 2: FastAPI Implementation (COMPLETED)

### Files Generated:
- ✅ `prediction.py` - Complete FastAPI application
- ✅ `requirements.txt` - Python dependencies
- ✅ `test_api.py` - API testing script

### API Features:
- **RESTful Endpoints**:
  - `GET /` - API information and endpoints
  - `POST /predict` - Inflation prediction
  - `GET /countries` - List of supported countries
  - `GET /health` - Health check
  - `GET /model-info` - Model information
  - `GET /docs` - Swagger documentation

### Supported Countries (13):
Algeria, Angola, Central African Republic, Ivory Coast, Egypt, Kenya, Mauritius, Morocco, Nigeria, South Africa, Tunisia, Zambia, Zimbabwe

### Input Parameters:
1. **year** (1860-2030)
2. **systemic_crisis** (0 or 1)
3. **exch_usd** (Exchange rate to USD)
4. **domestic_debt_in_default** (0 or 1)
5. **sovereign_external_debt_default** (0 or 1)
6. **gdp_weighted_default** (0-1)
7. **inflation_crises** (0 or 1)
8. **banking_crisis** (0 or 1)
9. **country** (One of the 13 supported countries)

### API Response:
```json
{
  "prediction": 12.34,
  "country": "Nigeria",
  "year": 2020,
  "message": "Prediction successful",
  "confidence": "Medium"
}
```

## 🚀 How to Run the API:

1. **Navigate to API directory**:
   ```bash
   cd linear_regression_model/summative/API
   ```

2. **Install dependencies** (if needed):
   ```bash
   pip install -r requirements.txt
   ```

3. **Start the API server**:
   ```bash
   python3 prediction.py
   ```

4. **Access the API**:
   - API: http://localhost:8000
   - Documentation: http://localhost:8000/docs
   - Health Check: http://localhost:8000/health

5. **Test the API**:
   ```bash
   python3 test_api.py
   ```

## 📊 Model Details:

### Dataset Information:
- **Source**: African Economic, Banking and Systemic Crises Data
- **Records**: 1,059 entries
- **Time Period**: 1860-2014
- **Countries**: 13 African nations
- **Target Variable**: Annual CPI Inflation Rate

### Feature Engineering:
- Converted categorical variables to numeric (country → dummy variables)
- Handled missing values with median imputation
- Standardized features using StandardScaler
- Total features: 21 (8 base + 13 country dummies)

### Model Selection:
- Compared 3 algorithms: Linear Regression, Decision Tree, Random Forest
- Selected Decision Tree based on lowest MSE
- Model saved as pickle file for API deployment

## 🎯 Next Steps (Task 3 - Flutter App):

The mobile application should:
1. Connect to the FastAPI endpoint
2. Provide user-friendly input forms for all 9 parameters
3. Display prediction results with country and confidence information
4. Handle API errors gracefully
5. Support all 13 African countries

## 📁 Project Structure:

```
linear_regression_model/
├── summative/
│   ├── linear_regression/
│   │   ├── multivariate.ipynb ✅
│   │   ├── african_crises (1).csv ✅
│   │   ├── best_inflation_model.pkl ✅
│   │   ├── inflation_scaler.pkl ✅
│   │   ├── inflation_correlation_heatmap.png ✅
│   │   ├── inflation_gd_loss_curve.png ✅
│   │   └── inflation_true_vs_predicted_scatter.png ✅
│   ├── API/
│   │   ├── prediction.py ✅
│   │   ├── requirements.txt ✅
│   │   └── test_api.py ✅
│   └── FlutterApp/ (Task 3 - To be implemented)
└── README.md ✅
```

## ✅ Completion Status:

- **Task 1 (ML Model)**: ✅ COMPLETED
- **Task 2 (API)**: ✅ COMPLETED  
- **Task 3 (Flutter App)**: ⏳ PENDING

Both Task 1 and Task 2 have been successfully completed with all required files generated and tested. The machine learning model is trained and saved, all visualizations are created, and the FastAPI is fully functional with comprehensive endpoints and documentation.