import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _yearController = TextEditingController();
  final _systemicCrisisController = TextEditingController();
  final _exchUsdController = TextEditingController();
  final _domesticDebtController = TextEditingController();
  final _sovereignDebtController = TextEditingController();
  final _gdpWeightedController = TextEditingController();
  final _inflationCrisesController = TextEditingController();
  final _bankingCrisisController = TextEditingController();

  String _predictionResult = '';
  bool _isLoading = false;
  String? _selectedCountry;

  final List<String> _countries = [
    'Algeria', 'Angola', 'Central African Republic', 'Ivory Coast', 'Egypt',
    'Kenya', 'Mauritius', 'Morocco', 'Nigeria', 'South Africa', 'Tunisia', 
    'Zambia', 'Zimbabwe'
  ];

  // Local API URL - Android emulator uses 10.0.2.2 to access host machine's localhost
  final String apiUrl = 'http://10.0.2.2:8000/predict';

  Future<void> _makePrediction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _predictionResult = '';
    });

    try {
      // Build country one-hot encoding
      Map<String, int> countryEncoding = {
        'country_Algeria': 0,
        'country_Angola': 0,
        'country_Central_African_Republic': 0,
        'country_Cote_dIvoire': 0,
        'country_Egypt': 0,
        'country_Kenya': 0,
        'country_Mauritius': 0,
        'country_Morocco': 0,
        'country_Nigeria': 0,
        'country_South_Africa': 0,
        'country_Tunisia': 0,
        'country_Zambia': 0,
        'country_Zimbabwe': 0,
      };
      
      // Map display names to API field names
      Map<String, String> countryMapping = {
        'Algeria': 'country_Algeria',
        'Angola': 'country_Angola',
        'Central African Republic': 'country_Central_African_Republic',
        'Ivory Coast': 'country_Cote_dIvoire',
        'Egypt': 'country_Egypt',
        'Kenya': 'country_Kenya',
        'Mauritius': 'country_Mauritius',
        'Morocco': 'country_Morocco',
        'Nigeria': 'country_Nigeria',
        'South Africa': 'country_South_Africa',
        'Tunisia': 'country_Tunisia',
        'Zambia': 'country_Zambia',
        'Zimbabwe': 'country_Zimbabwe',
      };
      
      if (countryMapping.containsKey(_selectedCountry)) {
        countryEncoding[countryMapping[_selectedCountry]!] = 1;
      }

      final requestData = {
        'year': int.parse(_yearController.text),
        'systemic_crisis': int.parse(_systemicCrisisController.text),
        'exch_usd': double.parse(_exchUsdController.text),
        'domestic_debt_in_default': int.parse(_domesticDebtController.text),
        'sovereign_external_debt_default': int.parse(_sovereignDebtController.text),
        'gdp_weighted_default': double.parse(_gdpWeightedController.text),
        'inflation_crises': int.parse(_inflationCrisesController.text),
        'banking_crisis': int.parse(_bankingCrisisController.text),
        ...countryEncoding,
      };
      
      print('Sending request: ${jsonEncode(requestData)}');
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _predictionResult = 'Predicted Inflation Rate: ${data['prediction']}%';
        });
      } else {
        print('Error response: ${response.body}');
        final errorData = jsonDecode(response.body);
        setState(() {
          _predictionResult = 'Error ${response.statusCode}: ${errorData['detail'] ?? 'Unknown error'}';
        });
      }
    } catch (e) {
      setState(() {
        _predictionResult = 'Network Error: $e\n\nMake sure API is running on http://127.0.0.1:8000';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isInteger = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isInteger ? TextInputType.number : TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (isInteger) {
            if (int.tryParse(value) == null) {
              return 'Please enter a valid integer';
            }
          } else {
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inflation Prediction'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enter Economic Indicators',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _yearController,
                  label: 'Year',
                  hint: 'e.g., 2020',
                  isInteger: true,
                ),
                _buildTextField(
                  controller: _systemicCrisisController,
                  label: 'Systemic Crisis',
                  hint: '0 (No) or 1 (Yes)',
                  isInteger: true,
                ),
                _buildTextField(
                  controller: _exchUsdController,
                  label: 'Exchange Rate to USD',
                  hint: 'e.g., 1.5',
                ),
                _buildTextField(
                  controller: _domesticDebtController,
                  label: 'Domestic Debt in Default',
                  hint: '0 (No) or 1 (Yes)',
                  isInteger: true,
                ),
                _buildTextField(
                  controller: _sovereignDebtController,
                  label: 'Sovereign External Debt Default',
                  hint: '0 (No) or 1 (Yes)',
                  isInteger: true,
                ),
                _buildTextField(
                  controller: _gdpWeightedController,
                  label: 'GDP Weighted Default',
                  hint: 'Value between 0 and 1',
                ),
                _buildTextField(
                  controller: _inflationCrisesController,
                  label: 'Inflation Crises',
                  hint: '0 (No) or 1 (Yes)',
                  isInteger: true,
                ),
                _buildTextField(
                  controller: _bankingCrisisController,
                  label: 'Banking Crisis',
                  hint: '0 (No) or 1 (Yes)',
                  isInteger: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCountry,
                    decoration: InputDecoration(
                      labelText: 'Country',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: _countries.map((String country) {
                      return DropdownMenuItem<String>(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCountry = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a country';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: (_isLoading || _selectedCountry == null) ? null : _makePrediction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Predict',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
                const SizedBox(height: 20),
                if (_predictionResult.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _predictionResult.startsWith('Error')
                          ? Colors.red.shade50
                          : Colors.green.shade50,
                      border: Border.all(
                        color: _predictionResult.startsWith('Error')
                            ? Colors.red
                            : Colors.green,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _predictionResult,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _predictionResult.startsWith('Error')
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _yearController.dispose();
    _systemicCrisisController.dispose();
    _exchUsdController.dispose();
    _domesticDebtController.dispose();
    _sovereignDebtController.dispose();
    _gdpWeightedController.dispose();
    _inflationCrisesController.dispose();
    _bankingCrisisController.dispose();
    super.dispose();
  }
}