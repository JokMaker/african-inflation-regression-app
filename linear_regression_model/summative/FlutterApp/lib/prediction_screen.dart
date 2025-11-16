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

  // Replace with your deployed API URL
  final String apiUrl = 'https://your-api-url.com/predict';

  Future<void> _makePrediction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _predictionResult = '';
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'year': int.parse(_yearController.text),
          'systemic_crisis': int.parse(_systemicCrisisController.text),
          'exch_usd': double.parse(_exchUsdController.text),
          'domestic_debt_in_default': int.parse(_domesticDebtController.text),
          'sovereign_external_debt_default': int.parse(_sovereignDebtController.text),
          'gdp_weighted_default': double.parse(_gdpWeightedController.text),
          'inflation_crises': int.parse(_inflationCrisesController.text),
          'banking_crisis': int.parse(_bankingCrisisController.text),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _predictionResult = 'Predicted Inflation Rate: ${data['prediction']}%';
        });
      } else {
        setState(() {
          _predictionResult = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _predictionResult = 'Error: $e';
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
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _makePrediction,
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