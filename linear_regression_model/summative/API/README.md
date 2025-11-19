# African Inflation Prediction API

FastAPI-based REST API for predicting African inflation rates using machine learning.

## Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

## Running the API

Start the server:
```bash
uvicorn prediction:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at:
- **API**: http://localhost:8000
- **Swagger Docs**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## API Endpoints

### GET /
Health check endpoint
```bash
curl http://localhost:8000/
```

### POST /predict
Predict inflation rate

**Request Body:**
```json
{
  "year": 2010,
  "systemic_crisis": 0,
  "exch_usd": 0.5,
  "domestic_debt_in_default": 0,
  "sovereign_external_debt_default": 0,
  "gdp_weighted_default": 0.0,
  "inflation_crises": 0,
  "banking_crisis": 0,
  "country_Nigeria": 1
}
```

**Response:**
```json
{
  "prediction": 12.34,
  "unit": "Annual CPI Inflation Rate (%)"
}
```

## Testing

Run the test script:
```bash
python test_prediction.py
```

Or use curl:
```bash
curl -X POST "http://localhost:8000/predict" \
  -H "Content-Type: application/json" \
  -d '{
    "year": 2010,
    "systemic_crisis": 0,
    "exch_usd": 0.5,
    "domestic_debt_in_default": 0,
    "sovereign_external_debt_default": 0,
    "gdp_weighted_default": 0.0,
    "inflation_crises": 0,
    "banking_crisis": 0,
    "country_Nigeria": 1
  }'
```

## Input Parameters

| Parameter | Type | Range | Description |
|-----------|------|-------|-------------|
| year | int | 1860-2100 | Year |
| systemic_crisis | int | 0-1 | Systemic crisis indicator |
| exch_usd | float | 0-1000 | Exchange rate to USD |
| domestic_debt_in_default | int | 0-1 | Domestic debt default |
| sovereign_external_debt_default | int | 0-1 | External debt default |
| gdp_weighted_default | float | 0-1 | GDP weighted default |
| inflation_crises | int | 0-1 | Inflation crisis indicator |
| banking_crisis | int | 0-1 | Banking crisis indicator |
| country_* | int | 0-1 | Country one-hot encoding (set 1 for target country) |

## Deployment

For production deployment, use:
```bash
uvicorn prediction:app --host 0.0.0.0 --port 8000 --workers 4
```
