from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import joblib
import numpy as np
import os
from pathlib import Path

app = FastAPI(title="African Inflation Prediction API")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load model and scaler with flexible path handling
BASE_DIR = Path(__file__).resolve().parent
MODEL_PATH = BASE_DIR / 'best_inflation_model.pkl'
SCALER_PATH = BASE_DIR / 'inflation_scaler.pkl'

# Fallback to relative path if files not in same directory
if not MODEL_PATH.exists():
    MODEL_PATH = BASE_DIR / '../linear_regression/best_inflation_model.pkl'
    SCALER_PATH = BASE_DIR / '../linear_regression/inflation_scaler.pkl'

model = joblib.load(MODEL_PATH)
scaler = joblib.load(SCALER_PATH)

class PredictionInput(BaseModel):
    year: int = Field(..., ge=1860, le=2030, description="Year (1860-2030, dataset trained on 1860-2014)")
    systemic_crisis: int = Field(..., ge=0, le=1, description="Systemic crisis (0 or 1)")
    exch_usd: float = Field(..., ge=0, le=1000, description="Exchange rate to USD (0-1000)")
    domestic_debt_in_default: int = Field(..., ge=0, le=1, description="Domestic debt default (0 or 1)")
    sovereign_external_debt_default: int = Field(..., ge=0, le=1, description="External debt default (0 or 1)")
    gdp_weighted_default: float = Field(..., ge=0, le=1, description="GDP weighted default (0-1)")
    inflation_crises: int = Field(..., ge=0, le=1, description="Inflation crisis (0 or 1)")
    banking_crisis: int = Field(..., ge=0, le=1, description="Banking crisis (0 or 1)")
    country_Algeria: int = Field(0, ge=0, le=1)
    country_Angola: int = Field(0, ge=0, le=1)
    country_Central_African_Republic: int = Field(0, ge=0, le=1)
    country_Cote_dIvoire: int = Field(0, ge=0, le=1)
    country_Egypt: int = Field(0, ge=0, le=1)
    country_Kenya: int = Field(0, ge=0, le=1)
    country_Mauritius: int = Field(0, ge=0, le=1)
    country_Morocco: int = Field(0, ge=0, le=1)
    country_Nigeria: int = Field(0, ge=0, le=1)
    country_South_Africa: int = Field(0, ge=0, le=1)
    country_Tunisia: int = Field(0, ge=0, le=1)
    country_Zambia: int = Field(0, ge=0, le=1)
    country_Zimbabwe: int = Field(0, ge=0, le=1)

@app.get("/")
def root():
    return {
        "message": "African Inflation Prediction API",
        "docs": "/docs",
        "note": "Model trained on data from 1860-2014. Predictions beyond 2014 are extrapolations."
    }

@app.post("/predict")
def predict(data: PredictionInput):
    try:
        features = np.array([[
            data.year, data.systemic_crisis, data.exch_usd,
            data.domestic_debt_in_default, data.sovereign_external_debt_default,
            data.gdp_weighted_default, data.inflation_crises, data.banking_crisis,
            data.country_Algeria, data.country_Angola, data.country_Central_African_Republic,
            data.country_Cote_dIvoire, data.country_Egypt, data.country_Kenya,
            data.country_Mauritius, data.country_Morocco, data.country_Nigeria,
            data.country_South_Africa, data.country_Tunisia, data.country_Zambia,
            data.country_Zimbabwe
        ]])
        
        features_scaled = scaler.transform(features)
        prediction = model.predict(features_scaled)[0]
        
        return {
            "prediction": float(prediction),
            "unit": "Annual CPI Inflation Rate (%)"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
