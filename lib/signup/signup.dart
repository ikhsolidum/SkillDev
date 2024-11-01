import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:regexpattern/regexpattern.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/io_client.dart';
import 'dart:io';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _errorMessage;
  String? _selectedId;
  String? _selectedClearance;
  
  XFile? _profileImage;
  XFile? _idImage;
  XFile? _clearanceImage;
  
  String? _profileImageName;
  String? _idImageName;
  String? _clearanceImageName;

  final List<String> validIdOptions = ['Passport', 'Voters ID', 'Postal ID', 'Drivers License'];
  final List<String> clearanceOptions = ['Police Clearance', 'Barangay Clearance'];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/loginbackground_nologo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.black),
                              onPressed: () => Navigator.of(context).pop(),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              style: ButtonStyle(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Sign Up',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(width: 24),
                          ],
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: _profileImage != null
                                    ? ClipOval(
                                        child: kIsWeb
                                            ? Image.network(_profileImage!.path, fit: BoxFit.cover)
                                            : Image.file(File(_profileImage!.path), fit: BoxFit.cover))
                                    : Icon(Icons.person, size: 80, color: Colors.grey[400]),
                              ),
                              if (_profileImage != null)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _profileImage = null;
                                        _profileImageName = null;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.close, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => _pickImage('Profile'),
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_profileImageName != null)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(_profileImageName!,
                                  style: TextStyle(color: Colors.grey[600])),
                            ),
                          ),
                        SizedBox(height: 16),
                        _buildTextField('Username', Icons.account_circle, _usernameController),
                        SizedBox(height: 16),
                        _buildTextField('Email', Icons.email, _emailController),
                        SizedBox(height: 16),
                        _buildTextField('Password', Icons.lock, _passwordController, isPassword: true),
                        SizedBox(height: 16),
                        _buildTextField('Confirm Password', Icons.lock, _confirmPasswordController, isPassword: true),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        SizedBox(height: 16),
                        _buildDropdownField('Submit Valid ID', validIdOptions, _selectedId, (newValue) {
                          setState(() {
                            _selectedId = newValue;
                          });
                        }),
                        SizedBox(height: 8),
                        _buildImageUploadField('ID', _idImage, _idImageName),
                        SizedBox(height: 16),
                        _buildDropdownField('Proof of Clearance', clearanceOptions, _selectedClearance, (newValue) {
                          setState(() {
                            _selectedClearance = newValue;
                          });
                        }),
                        SizedBox(height: 8),
                        _buildImageUploadField('Clearance', _clearanceImage, _clearanceImageName),
                        SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {
                            if (_validateInputs()) {
                              _registerUser();
                            } else {
                              // Scroll to the error message
                              Future.delayed(Duration(milliseconds: 100), () {
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              });
                            }
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 110, 227, 192),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        prefixIcon: Icon(icon),
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options, String? selectedValue, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          onChanged: onChanged,
          icon: Icon(Icons.arrow_drop_down),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            fillColor: Colors.white,
            filled: true,
          ),
          items: options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImageUploadField(String type, XFile? image, String? imageName) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _pickImage(type),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                imageName ?? 'Add Image',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
        if (image != null)
          IconButton(
            icon: Icon(Icons.close, color: Colors.red, size: 20),
            onPressed: () {
              setState(() {
                switch (type) {
                  case 'ID':
                    _idImage = null;
                    _idImageName = null;
                    break;
                  case 'Clearance':
                    _clearanceImage = null;
                    _clearanceImageName = null;
                    break;
                }
              });
            },
          ),
      ],
    );
  }

  Future<void> _pickImage(String type) async {
    final picker = ImagePicker();
    XFile? pickedFile;

    if (kIsWeb) {
      pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );
    } else {
      final status = await Permission.photos.request();
      if (status.isGranted) {
        pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission to access photos is denied.')),
        );
      }
    }

    if (pickedFile != null) {
      if (!kIsWeb && !['jpg', 'jpeg', 'png'].contains(pickedFile.path.split('.').last.toLowerCase())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a JPG or PNG image.')),
        );
        return;
      }

      setState(() {
        switch (type) {
          case 'Profile':
            _profileImage = pickedFile;
            _profileImageName = pickedFile?.path.split('/').last;
            break;
          case 'ID':
            _idImage = pickedFile;
            _idImageName = pickedFile?.path.split('/').last;
            break;
          case 'Clearance':
            _clearanceImage = pickedFile;
            _clearanceImageName = pickedFile?.path.split('/').last;
            break;
        }
      });
    }
  }

  Future<void> _registerUser() async {
    try {
      var uri = Uri.parse('http://bunn.helioho.st/register.php');

      if (kIsWeb) {
        // Web platform implementation
        String? profileBase64;
        String? idBase64;
        String? clearanceBase64;

        if (_profileImage != null) {
          List<int> bytes = await _profileImage!.readAsBytes();
          profileBase64 = base64Encode(bytes);
        }

        if (_idImage != null) {
          List<int> bytes = await _idImage!.readAsBytes();
          idBase64 = base64Encode(bytes);
        }

        if (_clearanceImage != null) {
          List<int> bytes = await _clearanceImage!.readAsBytes();
          clearanceBase64 = base64Encode(bytes);
        }

        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': _usernameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
            'id_proof': _selectedId,
            'proof_clearance': _selectedClearance,
            'profileImage': profileBase64,
            'profileImageName': _profileImageName,
            'id_proof_file': idBase64,
            'id_proof_filename': _idImageName,
            'proof_clearance_file': clearanceBase64,
            'proof_clearance_filename': _clearanceImageName,
            'isWeb': true
          }),
        );

        _handleRegistrationResponse(response);

      } else {
        // Mobile platform implementation
        var request = http.MultipartRequest('POST', uri);

        request.fields['username'] = _usernameController.text;
        request.fields['email'] = _emailController.text;
        request.fields['password'] = _passwordController.text;
        request.fields['id_proof'] = _selectedId ?? '';
        request.fields['proof_clearance'] = _selectedClearance ?? '';
        request.fields['isWeb'] = 'false';

        if (_profileImage != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'profileImage',
            _profileImage!.path,
            filename: _profileImageName,
          ));
        }

        if (_idImage != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'id_proof_file',
            _idImage!.path,
            filename: _idImageName,
          ));
        }

        if (_clearanceImage != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'proof_clearance_file',
            _clearanceImage!.path,
            filename: _clearanceImageName,
          ));
        }

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        
        _handleRegistrationResponse(response);
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again later.';
      });
      print('Error during registration: $error');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleRegistrationResponse(http.Response response) {
    var jsonResponse = jsonDecode(response.body);
    
    if (response.statusCode == 201 && jsonResponse['success']) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration successful! Please login to continue.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Wait for the snackbar to be visible before navigating
      Future.delayed(Duration(seconds: 2), () {
        // Navigate to login page and remove all previous routes
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login/loginpage', // Replace with your login route name
          (Route<dynamic> route) => false,
        );
      });
    } else if (response.statusCode == 409) {
      setState(() {
        _errorMessage = 'Email already registered. Please use a different email.';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email already registered'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      setState(() {
        _errorMessage = jsonResponse['message'] ?? 'Registration failed. Please try again.';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

   bool _validateInputs() {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    setState(() {
      _errorMessage = null;
    });

    if (_profileImage == null) {
      _errorMessage = 'Please select a profile image.';
      return false;
    }

    if (_selectedId == null || _selectedClearance == null) {
      _errorMessage = 'Please pick a Valid ID and Proof of Clearance.';
      return false;
    }

    if (_idImage == null || _clearanceImage == null) {
      _errorMessage = 'Please upload both ID and clearance images.';
      return false;
    }

    final emailRegEx = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegEx.hasMatch(email)) {
      _errorMessage = 'Please enter a valid email address.';
      return false;
    }

    if (username.length < 3) {
      _errorMessage = 'Username must be at least 3 characters long.';
      return false;
    }

    if (password != confirmPassword) {
      _errorMessage = 'Password and Confirm Password do not match.';
      return false;
    }

    final passwordRegEx = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );

    if (!passwordRegEx.hasMatch(password)) {
      _errorMessage = 'Password must be at least 8 characters long, containing an uppercase letter, a lowercase letter, a number, and a special character.';
      return false;
    }

    return true;
  }
}