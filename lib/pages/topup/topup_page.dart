import 'dart:io';
import 'package:flutter/material.dart';
import '../../widgets/topup/topup_stepper.dart';
import '../../widgets/topup/topup_step1.dart';
import '../../widgets/topup/topup_step2.dart';
import '../../widgets/topup/topup_step3.dart';

class TopUpPage extends StatefulWidget {
  const TopUpPage({Key? key}) : super(key: key);

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  int _currentStep = 1;

  // Form State
  File? _buktiTransfer;
  String _nominal = '';
  String _keterangan = '';

  void _nextStep() {
    setState(() {
      if (_currentStep < 3) _currentStep++;
    });
  }

  void _prevStep() {
    setState(() {
      if (_currentStep > 1) _currentStep--;
    });
  }

  void _submitData() {
    // TODO: Panggil API/backend untuk upload bukti transfer di sini
    print('Mengirim data: Nominal $_nominal, Keterangan $_keterangan');
    _nextStep(); // Lanjut ke step 3 (Berhasil)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _currentStep < 3 
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.blue),
                onPressed: () {
                  if (_currentStep == 1) {
                    Navigator.pop(context);
                  } else {
                    _prevStep();
                  }
                },
              )
            : null,
        title: const Text('Top Up Saldo', style: TextStyle(color: Colors.blue)),
      ),
      body: Column(
        children: [
          // Tampilkan Stepper hanya di step 1 dan 2
          if (_currentStep < 3)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: TopUpStepper(currentStep: _currentStep),
            ),
            
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildCurrentStepWidget(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepWidget(BuildContext context) {
    if (_currentStep == 1) {
      return TopUpStep1(
        onNext: _nextStep,
        onBack: () => Navigator.pop(context),
      );
    } else if (_currentStep == 2) {
      return TopUpStep2(
        nominal: _nominal,
        keterangan: _keterangan,
        buktiTransfer: _buktiTransfer,
        onNominalChanged: (val) => setState(() => _nominal = val),
        onKeteranganChanged: (val) => setState(() => _keterangan = val),
        onBuktiSelected: (file) => setState(() => _buktiTransfer = file),
        onSubmit: _submitData,
      );
    } else {
      return const TopUpStep3();
    }
  }
}