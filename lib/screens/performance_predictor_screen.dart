
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class PerformancePredictorScreen extends StatefulWidget {
  const PerformancePredictorScreen({super.key});

  @override
  State<PerformancePredictorScreen> createState() =>
      _PerformancePredictorScreenState();
}

class _PerformancePredictorScreenState
    extends State<PerformancePredictorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _hoursController = TextEditingController(text: '5');
  final _shootingController = TextEditingController(text: '70');
  final _passingController = TextEditingController(text: '75');
  final _staminaController = TextEditingController(text: '80');

  Interpreter? _interpreter;
  bool _isLoading = true;
  String? _error;
  double? _score;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      final interpreter =
      await Interpreter.fromAsset('assets/football_performance.tflite');

      if (!mounted) {
        interpreter.close();
        return;
      }

      setState(() {
        _interpreter = interpreter;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Model could not be loaded: $e';
        _isLoading = false;
      });
    }
  }

  void _predictPerformance() {
    if (!_formKey.currentState!.validate()) return;

    if (_interpreter == null) {
      setState(() {
        _error = 'The AI model is not loaded. Please restart the app.';
      });
      return;
    }

    try {
      final hours = double.parse(_hoursController.text);
      final shooting = double.parse(_shootingController.text);
      final passing = double.parse(_passingController.text);
      final stamina = double.parse(_staminaController.text);

      final input = [
        [
          hours / 10.0,
          shooting / 100.0,
          passing / 100.0,
          stamina / 100.0,
        ]
      ];

      final output = [
        [0.0]
      ];

      _interpreter!.run(input, output);

      setState(() {
        _score = (output[0][0] * 100).clamp(0.0, 100.0);
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Prediction failed: $e';
      });
    }
  }

  Widget _buildInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    required double min,
    required double max,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF202C26),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              final number = double.tryParse(value ?? '');

              if (number == null || !number.isFinite) {
                return 'Enter a valid number';
              }

              if (number < min || number > max) {
                return 'Enter a value from $min to $max';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _interpreter?.close();
    _hoursController.dispose();
    _shootingController.dispose();
    _passingController.dispose();
    _staminaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101813),
      appBar: AppBar(
        title: const Text(
          'AI Performance Predictor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF101813),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFFB7F34A)),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.sports_soccer,
                color: Color(0xFFB7F34A),
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'Analyze Your Performance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your training details to get an AI-generated '
                    'performance score using an on-device TensorFlow Lite model.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              _buildInput(
                label: 'Training Hours per Week (0–10)',
                hint: 'e.g. 5',
                controller: _hoursController,
                min: 0,
                max: 10,
              ),
              _buildInput(
                label: 'Shooting Accuracy (%)',
                hint: 'e.g. 70',
                controller: _shootingController,
                min: 0,
                max: 100,
              ),
              _buildInput(
                label: 'Passing Accuracy (%)',
                hint: 'e.g. 75',
                controller: _passingController,
                min: 0,
                max: 100,
              ),
              _buildInput(
                label: 'Stamina (%)',
                hint: 'e.g. 80',
                controller: _staminaController,
                min: 0,
                max: 100,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _predictPerformance,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text(
                    'Predict Performance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB7F34A),
                    foregroundColor: const Color(0xFF101813),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              if (_score != null) ...[
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF202C26),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFB7F34A),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Predicted Performance Score',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${_score!.toStringAsFixed(1)} / 100',
                        style: const TextStyle(
                          color: Color(0xFFB7F34A),
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _score! >= 80
                            ? 'Excellent practice profile!'
                            : _score! >= 60
                            ? 'Good progress! Keep training.'
                            : 'Keep practicing to improve.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 18),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ],
              const SizedBox(height: 18),
              const Text(
                'Educational demo: this score comes from a model '
                    'trained on synthetic data and is not a scientifically '
                    'validated assessment of athletic ability.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
