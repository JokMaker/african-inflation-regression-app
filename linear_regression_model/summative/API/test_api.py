#!/usr/bin/env python3
"""
Test script for the African Inflation Prediction API
"""

import requests
import json

def test_api():
    base_url = "http://localhost:8000"
    
    # Test data
    test_data = {
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
    
    print("🧪 Testing African Inflation Prediction API")
    print("=" * 50)
    
    try:
        # Test root endpoint
        print("1. Testing root endpoint...")
        response = requests.get(f"{base_url}/")
        if response.status_code == 200:
            print("✓ Root endpoint working")
        else:
            print(f"✗ Root endpoint failed: {response.status_code}")
        
        # Test health endpoint
        print("2. Testing health endpoint...")
        response = requests.get(f"{base_url}/health")
        if response.status_code == 200:
            health_data = response.json()
            print(f"✓ Health check: {health_data['status']}")
            print(f"✓ Model loaded: {health_data['model_loaded']}")
        else:
            print(f"✗ Health endpoint failed: {response.status_code}")
        
        # Test countries endpoint
        print("3. Testing countries endpoint...")
        response = requests.get(f"{base_url}/countries")
        if response.status_code == 200:
            countries = response.json()['countries']
            print(f"✓ Countries endpoint working ({len(countries)} countries)")
        else:
            print(f"✗ Countries endpoint failed: {response.status_code}")
        
        # Test prediction endpoint
        print("4. Testing prediction endpoint...")
        response = requests.post(f"{base_url}/predict", json=test_data)
        if response.status_code == 200:
            prediction = response.json()
            print(f"✓ Prediction successful: {prediction['prediction']}%")
            print(f"✓ Country: {prediction['country']}")
            print(f"✓ Confidence: {prediction['confidence']}")
        else:
            print(f"✗ Prediction failed: {response.status_code}")
            print(f"Error: {response.text}")
        
        print("\n🎉 API testing completed successfully!")
        
    except requests.exceptions.ConnectionError:
        print("⚠️  API server not running. To test:")
        print("1. Run: python3 prediction.py")
        print("2. In another terminal, run: python3 test_api.py")
    except Exception as e:
        print(f"✗ Test error: {e}")

if __name__ == "__main__":
    test_api()