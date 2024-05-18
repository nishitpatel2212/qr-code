import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(QRCodeGeneratorApp());
}

class QRCodeGeneratorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR Code Generator',
      home: QRCodeGeneratorScreen(),
    );
  }
}

class QRCodeGeneratorScreen extends StatefulWidget {
  @override
  _QRCodeGeneratorScreenState createState() => _QRCodeGeneratorScreenState();
}

class _QRCodeGeneratorScreenState extends State<QRCodeGeneratorScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _qrData = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Generator'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTextField(_nameController, 'Name'),
                _buildTextField(_emailController, 'Email'),
                _buildTextField(_mobileController, 'Mobile'),
                _buildTextField(_areaController, 'Area'),
                _buildTextField(_ageController, 'Age'),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    String qrData = _generateQRData();
                    setState(() {
                      _qrData = qrData;
                    });
                    await _storeDataInFirestore(qrData);
                  },
                  child: Text('Generate QR Code'),
                ),
                SizedBox(height: 20.0),
                RepaintBoundary(
                  child: BarcodeWidget(
                    barcode: Barcode.qrCode(),
                    data: _qrData.isNotEmpty ? _qrData : 'No data',
                    width: 200.0,
                    height: 200.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
      ),
    );
  }

  String _generateQRData() {
    String name = _nameController.text;
    String email = _emailController.text;
    String mobile = _mobileController.text;
    String area = _areaController.text;
    String age = _ageController.text;

    // Format the data as needed
    Map<String, dynamic> qrData = {
      'name': name,
      'email': email,
      'mobile': mobile,
      'area': area,
      'age': age,
    };

    // Convert the map to a string
    String qrString = qrData.entries.map((e) => '${e.key}: ${e.value}').join('\n');

    return qrString;
  }

  Future<void> _storeDataInFirestore(String qrData) async {
    CollectionReference qrCodes = FirebaseFirestore.instance.collection('qr_codes');

    await qrCodes.add({
      'name': _nameController.text,
      'email': _emailController.text,
      'mobile': _mobileController.text,
      'area': _areaController.text,
      'age': _ageController.text,
      'qr_data': qrData,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
