import 'package:flutter/material.dart';

class TopUpStepper extends StatelessWidget {
  final int currentStep;
  
  const TopUpStepper({Key? key, required this.currentStep}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepCircle(1, 'QR Code'),
        _buildLine(1),
        _buildStepCircle(2, 'Upload'),
        _buildLine(2),
        _buildStepCircle(3, 'Selesai'),
      ],
    );
  }

  Widget _buildStepCircle(int step, String label) {
    bool isActive = currentStep >= step;
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.blue[800] : Colors.grey[300],
          ),
          child: Center(
            child: isActive && currentStep > step
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '$step',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.blue[800] : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildLine(int step) {
    bool isActive = currentStep > step;
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20), // Offset agar sejajar dengan lingkaran
      color: isActive ? Colors.blue[800] : Colors.grey[300],
    );
  }
}