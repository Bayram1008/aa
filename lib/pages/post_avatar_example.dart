import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';

class AvatarUploadScreen extends StatefulWidget {
  const AvatarUploadScreen({super.key});

  @override
  _AvatarUploadScreenState createState() => _AvatarUploadScreenState();
}

class _AvatarUploadScreenState extends State<AvatarUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  final Dio _dio = Dio();

  Future<void> _selectImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    try {
      // Get the file extension to determine MIME type
      final fileExtension = _selectedImage!.path.split('.').last.toLowerCase();
      String mimeType = 'application/octet-stream'; 

      switch (fileExtension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'bmp':
          mimeType = 'image/bmp';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        default:
          mimeType = 'application/octet-stream'; // For unsupported file types
          break;
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: _selectedImage!.path.split('/').last,
          contentType: MediaType.parse(mimeType), // Set the MIME type here
        ),
      });

      final response = await _dio.post(
        'http://172.16.18.78:3009/check', // Replace with your backend URL
        data: formData,
      );

      if (response.statusCode == 200) {
        print('Image uploaded successfully: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image uploaded successfully')),
        );
      } else {
        print('Failed to upload image: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image')),
        );
      }
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Avatar')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _selectedImage != null
              ? Image.file(_selectedImage!, height: 150)
              : Icon(Icons.image, size: 150, color: Colors.grey),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _selectImage,
            child: Text('Select Image'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _uploadImage,
            child: Text('Upload Image'),
          ),
        ],
      ),
    );
  }
}
