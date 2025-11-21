import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

// --- 1. Constants and Validation Data ---

// NOTE: Replace this with your actual API URL after deployment!
const String apiUrl = "https://african-inflation-api.onrender.com/predict";

const Map<String, String> kCountriesWithFlags = {
  "Algeria": "🇩🇿",
  "Angola": "🇦🇴",
  "Central African Republic": "🇨🇫",
  "Egypt": "🇪🇬",
  "Ivory Coast": "🇨🇮",
  "Kenya": "🇰🇪",
  "Mauritius": "🇲🇺",
  "Morocco": "🇲🇦",
  "Nigeria": "🇳🇬",
  "South Africa": "🇿🇦",
  "Tunisia": "🇹🇳",
  "Zambia": "🇿🇲",
  "Zimbabwe": "🇿🇼"
};

// Exchange rates against USD (approximate values)
const Map<String, double> kCountryExchangeRates = {
  "Algeria": 134.5,
  "Angola": 825.0,
  "Central African Republic": 602.0,
  "Egypt": 30.9,
  "Ivory Coast": 602.0,
  "Kenya": 150.2,
  "Mauritius": 45.8,
  "Morocco": 10.1,
  "Nigeria": 461.0,
  "South Africa": 18.7,
  "Tunisia": 3.1,
  "Zambia": 24.3,
  "Zimbabwe": 322.0
};

// For the UI context box (a simplified historical average for context)
const double kHistoricalAverageInflation = 24.5; 

// --- 2. Prediction Page State Management ---

class InflationPredictionPage extends StatefulWidget {
  const InflationPredictionPage({super.key});

  @override
  State<InflationPredictionPage> createState() => _InflationPredictionPageState();
}

class _InflationPredictionPageState extends State<InflationPredictionPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Text Controllers for numerical inputs (simplified to match API)
  final TextEditingController _yearController = TextEditingController(text: '2020');
  final TextEditingController _exchUsdController = TextEditingController(text: '15.5');
  final TextEditingController _gdpDefaultController = TextEditingController(text: '0.0');
  final TextEditingController _sysCrisisController = TextEditingController(text: '0');
  final TextEditingController _domesticDebtController = TextEditingController(text: '0');
  final TextEditingController _sovereignDebtController = TextEditingController(text: '0');
  final TextEditingController _currCrisesController = TextEditingController(text: '0');
  final TextEditingController _infCrisesController = TextEditingController(text: '0');
  final TextEditingController _bankingCrisisController = TextEditingController(text: '0');

  // Dropdown values for categorical inputs
  String? _selectedCountry = 'Nigeria';

  // State variables for prediction result
  String _predictionResult = "Enter values and tap 'Predict'";
  double? _predictedValue;
  bool _isLoading = false;
  Color _resultColor = Colors.grey.shade600;
  
  // Historical data for visualization
  final List<double> _recentTrends = [18.2, 22.1, 19.8, 25.3, 21.7];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _yearController.dispose();
    _exchUsdController.dispose();
    _gdpDefaultController.dispose();
    _sysCrisisController.dispose();
    _domesticDebtController.dispose();
    _sovereignDebtController.dispose();
    _currCrisesController.dispose();
    _infCrisesController.dispose();
    _bankingCrisisController.dispose();
    super.dispose();
  }

  // --- 3. API Call Function ---

  Future<void> _makePrediction() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCountry == null) {
      setState(() {
        _predictionResult = "Please select a country";
        _resultColor = Colors.red;
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _predictionResult = "Analyzing economic indicators...";
      _resultColor = Colors.teal;
      _predictedValue = null;
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
      
      if (_selectedCountry != null && countryMapping.containsKey(_selectedCountry)) {
        countryEncoding[countryMapping[_selectedCountry]!] = 1;
      }

      final requestData = {
        'year': int.tryParse(_yearController.text) ?? 2020,
        'systemic_crisis': int.tryParse(_sysCrisisController.text) ?? 0,
        'exch_usd': double.tryParse(_exchUsdController.text) ?? 0.0,
        'domestic_debt_in_default': int.tryParse(_domesticDebtController.text) ?? 0,
        'sovereign_external_debt_default': int.tryParse(_sovereignDebtController.text) ?? 0,
        'gdp_weighted_default': double.tryParse(_gdpDefaultController.text) ?? 0.0,
        'inflation_crises': int.tryParse(_infCrisesController.text) ?? 0,
        'banking_crisis': int.tryParse(_bankingCrisisController.text) ?? 0,
        ...countryEncoding,
      };
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prediction = data['prediction'];
        setState(() {
          _predictedValue = prediction.toDouble();
          _predictionResult = "Prediction Successful!";
          _resultColor = Colors.green.shade700;
        });
      } else {
        final errorDetail = json.decode(response.body)['detail'] ?? 'Unknown Error';
        setState(() {
          _predictedValue = null;
          _predictionResult = "API Error: ${errorDetail.toString().split(':')[0]}";
          _resultColor = Colors.red.shade700;
        });
      }
    } catch (e) {
      setState(() {
        _predictedValue = null;
        _predictionResult = "Network Error: ${e.toString()}";
        _resultColor = Colors.red.shade700;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- 4. UI Builder Method ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inflation Insight Africa', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Colors.teal.shade500, Colors.blue.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.white, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                // --- Introductory Card ---
                Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Colors.indigo.shade100, Colors.purple.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(Icons.trending_up, size: 40, color: Colors.indigo.shade600),
                        const SizedBox(height: 12),
                        const Text(
                          'Predict Annual CPI Inflation Rate based on economic crisis indicators in African nations.',
                          style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                // --- Input Section 1: Core Economic Indicators ---
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Card(
                    elevation: 8,
                    shadowColor: Colors.teal.withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.teal.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.analytics_outlined, color: Colors.teal.shade700, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text('Core Economic Indicators', 
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Column(
                              children: [
                                Container(
                                  height: 3,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.teal.shade300, Colors.teal.shade100],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                _buildTextField(_yearController, 'Year', 'Enter year (e.g., 2020)', isInteger: true, minVal: 1860, maxVal: 2030, icon: Icons.calendar_today),
                                _buildTextField(_exchUsdController, 'Exchange Rate (USD)', 'Enter exchange rate to USD (e.g., 15.5)', isDecimal: true, minVal: 0.01, icon: Icons.currency_exchange),
                                _buildTextField(_gdpDefaultController, 'GDP Weighted Default', 'Value between 0.0 and 1.0', isDecimal: true, minVal: 0.0, maxVal: 1.0, icon: Icons.show_chart),
                                _buildTextField(_sysCrisisController, 'Systemic Crisis', '1 for Yes, 0 for No', isInteger: true, maxVal: 1, icon: Icons.warning),
                                _buildTextField(_domesticDebtController, 'Domestic Debt Default', '1 for Yes, 0 for No', isInteger: true, maxVal: 1, icon: Icons.home),
                                _buildTextField(_sovereignDebtController, 'Sovereign Debt Default', '1 for Yes, 0 for No', isInteger: true, maxVal: 1, icon: Icons.public),
                                _buildTextField(_currCrisesController, 'Currency Crises', '1 for Yes, 0 for No', isInteger: true, maxVal: 1, icon: Icons.monetization_on),
                                _buildTextField(_infCrisesController, 'Inflation Crises', '1 for Yes, 0 for No', isInteger: true, maxVal: 1, icon: Icons.trending_up),
                                _buildTextField(_bankingCrisisController, 'Banking Crisis', '1 for Yes, 0 for No', isInteger: true, maxVal: 1, icon: Icons.account_balance),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // --- Input Section 2: Country Selection ---
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Card(
                    elevation: 8,
                    shadowColor: Colors.blue.withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.blue.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ExpansionTile(
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.public, color: Colors.blue.shade700, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text('Country Selection', 
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Column(
                              children: [
                                Container(
                                  height: 3,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.blue.shade300, Colors.blue.shade100],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                _buildCountryDropdown(),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // --- Prediction Button ---
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isLoading 
                          ? [Colors.grey.shade400, Colors.grey.shade600]
                          : [Colors.green.shade400, Colors.green.shade700, Colors.teal.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _makePrediction,
                      icon: _isLoading 
                        ? const SizedBox(width: 24, height: 24, 
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                        : const Icon(Icons.rocket_launch, size: 24),
                      label: Text(_isLoading ? 'Analyzing Data...' : 'Predict Inflation Rate', 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // --- Result Display Area with Visualizations ---
                if (_predictionResult.isNotEmpty)
                  _buildResultSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 5. Helper Widgets ---

  Widget _buildTextField(TextEditingController controller, String label, String hint, {bool isDecimal = false, bool isInteger = false, double? minVal, double? maxVal, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isDecimal || isInteger ? const TextInputType.numberWithOptions(decimal: true, signed: true) : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon ?? Icons.edit, color: Colors.teal.shade600, size: 18),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Field is mandatory';
          final numVal = isInteger ? int.tryParse(value) : double.tryParse(value);

          if (numVal == null) return 'Invalid number format';
          if (minVal != null && numVal < minVal) return 'Value must be at least $minVal';
          if (maxVal != null && numVal > maxVal) return 'Value cannot exceed $maxVal';
          return null;
        },
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Select African Country',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.flag, color: Colors.blue.shade600, size: 18),
          ),
        ),
        initialValue: _selectedCountry,
        items: kCountriesWithFlags.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Row(
              children: [
                Text(entry.value, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Text(entry.key, style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500)),
              ],
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedCountry = newValue;
            // Auto-fill exchange rate when country is selected
            if (newValue != null && kCountryExchangeRates.containsKey(newValue)) {
              _exchUsdController.text = kCountryExchangeRates[newValue]!.toString();
            }
          });
        },
        validator: (value) => value == null ? 'Please select a country' : null,
      ),
    );
  }

  Widget _buildResultSection() {
    return Column(
      children: [
        // Main Result Card
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          child: Card(
            elevation: 15,
            shadowColor: _resultColor.withOpacity(0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    _resultColor.withOpacity(0.05),
                    Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _predictionResult,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _resultColor,
                      ),
                    ),
                    const Divider(height: 25),
                    if (_predictedValue != null) 
                      _buildPredictionDetails(_predictedValue!),
                    if (_predictedValue == null && !_isLoading)
                      const Text(
                        "Predicted value will appear here after analysis",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Visualization Cards
        if (_predictedValue != null) ...[
          const SizedBox(height: 20),
          _buildVisualizationCards(_predictedValue!),
        ],
      ],
    );
  }

  Widget _buildPredictionDetails(double predictedValue) {
    bool isHigh = predictedValue > kHistoricalAverageInflation;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isHigh ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            isHigh ? Icons.trending_up : Icons.trending_down,
            size: 48,
            color: isHigh ? Colors.red.shade600 : Colors.green.shade600,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'ANNUAL CPI INFLATION PREDICTED',
          style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          '${predictedValue.toStringAsFixed(2)} %',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: isHigh ? Colors.red.shade700 : Colors.green.shade700,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, _resultColor.withOpacity(0.3), Colors.transparent],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          isHigh 
              ? 'This is higher than the historical average (${kHistoricalAverageInflation.toStringAsFixed(1)}%)'
              : 'This is lower than the historical average (${kHistoricalAverageInflation.toStringAsFixed(1)}%)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildVisualizationCards(double predictedValue) {
    return Column(
      children: [
        // Gauge Chart Card
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.purple.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Inflation Risk Gauge',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple.shade700),
                ),
                const SizedBox(height: 20),
                _buildGaugeChart(predictedValue),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        
        // Comparison Chart Card
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.orange.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Historical Comparison',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                ),
                const SizedBox(height: 20),
                _buildComparisonChart(predictedValue),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGaugeChart(double value) {
    double normalizedValue = (value / 50).clamp(0.0, 1.0); // Normalize to 0-1 for 0-50% range
    
    return SizedBox(
      height: 150,
      child: CustomPaint(
        painter: GaugePainter(normalizedValue),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                '${value.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                _getRiskLevel(value),
                style: TextStyle(
                  fontSize: 12,
                  color: _getRiskColor(value),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonChart(double predictedValue) {
    List<double> allValues = [..._recentTrends, predictedValue];
    double maxValue = allValues.reduce(math.max);
    
    return SizedBox(
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ..._recentTrends.asMap().entries.map((entry) {
            int index = entry.key;
            double value = entry.value;
            return _buildBar(value, maxValue, Colors.blue.shade300, '${2019 + index}');
          }),
          _buildBar(predictedValue, maxValue, Colors.red.shade400, 'Predicted', isHighlighted: true),
        ],
      ),
    );
  }

  Widget _buildBar(double value, double maxValue, Color color, String label, {bool isHighlighted = false}) {
    double height = (value / maxValue) * 80;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${value.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 10,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: isHighlighted ? 25 : 20,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: isHighlighted ? Border.all(color: Colors.red.shade700, width: 2) : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  String _getRiskLevel(double value) {
    if (value < 10) return 'LOW RISK';
    if (value < 25) return 'MODERATE RISK';
    if (value < 40) return 'HIGH RISK';
    return 'CRITICAL RISK';
  }

  Color _getRiskColor(double value) {
    if (value < 10) return Colors.green;
    if (value < 25) return Colors.orange;
    if (value < 40) return Colors.red;
    return Colors.red.shade900;
  }
}

// Custom Painter for Gauge Chart
class GaugePainter extends CustomPainter {
  final double value;
  
  GaugePainter(this.value);
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    
    // Background arc
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      backgroundPaint,
    );
    
    // Value arc
    final valuePaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.green, Colors.yellow, Colors.red],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * value,
      false,
      valuePaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}