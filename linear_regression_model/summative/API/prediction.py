from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import joblib
import numpy as np
import pandas as pd
import os
from typing import Optional

app = FastAPI(
    title="African Inflation Prediction API",
    description="Predict African inflation rates using economic indicators from 13 African countries",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load model and scaler
try:
    model = joblib.load('../linear_regression/best_inflation_model.pkl')
    scaler = joblib.load('../linear_regression/inflation_scaler.pkl')
    print("✓ Model and scaler loaded successfully")
except Exception as e:
    print(f"✗ Error loading model: {e}")
    model = None
    scaler = None

# Country list for validation
COUNTRIES = [
    'Algeria', 'Angola', 'Central African Republic', 'Ivory Coast', 'Egypt',
    'Kenya', 'Mauritius', 'Morocco', 'Nigeria', 'South Africa', 'Tunisia', 
    'Zambia', 'Zimbabwe'
]

class PredictionRequest(BaseModel):
    year: int = Field(..., ge=1860, le=2030, description="Year (1860-2030)")
    systemic_crisis: int = Field(..., ge=0, le=1, description="Systemic crisis (0 or 1)")
    exch_usd: float = Field(..., ge=0, le=1000000, description="Exchange rate to USD")
    domestic_debt_in_default: int = Field(..., ge=0, le=1, description="Domestic debt in default (0 or 1)")
    sovereign_external_debt_default: int = Field(..., ge=0, le=1, description="Sovereign external debt default (0 or 1)")
    gdp_weighted_default: float = Field(..., ge=0, le=1, description="GDP weighted default (0-1)")
    inflation_crises: int = Field(..., ge=0, le=1, description="Inflation crises (0 or 1)")
    banking_crisis: int = Field(..., ge=0, le=1, description="Banking crisis (0 or 1)")
    country: str = Field(..., description=f"Country name. Must be one of: {', '.join(COUNTRIES)}")

    class Config:
        schema_extra = {
            "example": {
                "year": 2020,
                "systemic_crisis": 0,
                "exch_usd": 15.5,
                "domestic_debt_in_default": 0,
                "sovereign_external_debt_default": 0,
                "gdp_weighted_default": 0.0,
                "inflation_crises": 0,
                "banking_crisis": 0,
                "country": "Nigeria"
            }
        }

class PredictionResponse(BaseModel):
    prediction: float
    country: str
    year: int
    message: str
    confidence: str

@app.get("/")
def root():
    return {
        "message": "African Inflation Prediction API",
        "description": "Predict inflation rates using African economic crisis data from 13 countries",
        "countries": COUNTRIES,
        "endpoints": {
            "/predict": "POST - Make inflation prediction",
            "/countries": "GET - List supported countries",
            "/health": "GET - Health check",
            "/docs": "GET - API documentation"
        }
    }

@app.get("/countries")
def get_countries():
    return {"countries": COUNTRIES}

@app.post("/predict", response_model=PredictionResponse)
def predict_inflation(request: PredictionRequest):
    if model is None or scaler is None:
        raise HTTPException(status_code=500, detail="Model not loaded. Please check server configuration.")
    
    # Validate country
    if request.country not in COUNTRIES:
        raise HTTPException(
            status_code=400, 
            detail=f"Invalid country. Must be one of: {', '.join(COUNTRIES)}"
        )
    
    try:
        # Create feature vector with all 21 features
        # Base features (8)
        base_features = [
            request.year,
            request.systemic_crisis,
            request.exch_usd,
            request.domestic_debt_in_default,
            request.sovereign_external_debt_default,
            request.gdp_weighted_default,
            request.inflation_crises,
            request.banking_crisis
        ]
        
        # Country dummy variables (13) - one-hot encoding
        country_features = []
        for country in COUNTRIES:
            country_features.append(1 if request.country == country else 0)
        
        # Combine all features
        input_data = np.array([base_features + country_features])
        
        # Validate input shape
        if input_data.shape[1] != 21:
            raise HTTPException(
                status_code=500, 
                detail=f"Feature mismatch. Expected 21 features, got {input_data.shape[1]}"
            )
        
        # Scale input
        input_scaled = scaler.transform(input_data)
        
        # Make prediction
        prediction = model.predict(input_scaled)[0]
        
        # Determine confidence level based on historical data patterns
        confidence = "Medium"
        if abs(prediction) < 10:
            confidence = "High"
        elif abs(prediction) > 50:
            confidence = "Low"
        
        return PredictionResponse(
            prediction=round(float(prediction), 2),
            country=request.country,
            year=request.year,
            message="Prediction successful",
            confidence=confidence
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Prediction error: {str(e)}")

@app.get("/health")
def health_check():
    return {
        "status": "healthy" if model is not None else "unhealthy",
        "model_loaded": model is not None,
        "scaler_loaded": scaler is not None,
        "supported_countries": len(COUNTRIES)
    }

@app.get("/model-info")
def model_info():
    if model is None:
        raise HTTPException(status_code=500, detail="Model not loaded")
    
    return {
        "model_type": str(type(model).__name__),
        "features_count": 21,
        "base_features": [
            "year", "systemic_crisis", "exch_usd", "domestic_debt_in_default",
            "sovereign_external_debt_default", "gdp_weighted_default", 
            "inflation_crises", "banking_crisis"
        ],
        "country_features": [f"country_{country}" for country in COUNTRIES],
        "supported_countries": COUNTRIES
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)