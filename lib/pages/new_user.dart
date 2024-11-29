import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:new_project/model/user_model.dart';
import 'package:new_project/pages/user_list.dart';
import 'package:new_project/service/api_service.dart';
import 'package:new_project/service/savedData.dart';

class NewEmployee extends StatefulWidget {
  const NewEmployee({super.key});

  @override
  State<NewEmployee> createState() => _NewEmployeeState();
}

class _NewEmployeeState extends State<NewEmployee> {
  final serviceInNewEmployee = ApiService();
  final savedData = TokenService();

  final newFirstNameController = TextEditingController();
  final newLastNameController = TextEditingController();
  final newPositionController = TextEditingController();
  final newEmailController = TextEditingController();
  final newPhoneController = TextEditingController();
  final newBirthdayController = TextEditingController();
  final newHiredDayController = TextEditingController();
  final newResignedDayController = TextEditingController();

  File? avatarFile;

  Future<void> selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      controller.text = "${pickedDate.toLocal()}".split(' ')[0];
    }
  }

  Future<void> pickedAvatar() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        avatarFile = File(result.files.single.path!);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    newFirstNameController.dispose();
    newLastNameController.dispose();
    newPositionController.dispose();
    newEmailController.dispose();
    newPhoneController.dispose();
    newBirthdayController.dispose();
    newHiredDayController.dispose();
    newResignedDayController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Information of new Employee',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Form(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            avatarFile != null
                ? Image.file(avatarFile!, height: 100, width: 100, fit: BoxFit.cover)
                : const SizedBox.shrink(), 

            ElevatedButton(
              onPressed: pickedAvatar,
              child: const Text(
                'Choose the image for avatar',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: newFirstNameController,
              decoration: const InputDecoration(
                labelText: 'First name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: newLastNameController,
              decoration: const InputDecoration(
                labelText: 'Last name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: newPositionController,
              decoration: const InputDecoration(
                labelText: 'Position',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: newEmailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: newPhoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: newBirthdayController,
              readOnly: true,
              onTap: () => selectDate(context, newBirthdayController),
              decoration: const InputDecoration(
                labelText: 'Birthday',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: newHiredDayController,
                    readOnly: true,
                    onTap: () => selectDate(context, newHiredDayController),
                    decoration: const InputDecoration(
                      labelText: 'Hired Day',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: newResignedDayController,
                    readOnly: true,
                    onTap: () => selectDate(context, newResignedDayController),
                    decoration: const InputDecoration(
                      labelText: 'Resigned Day',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                ),


TextButton(
  onPressed: () async {
    // // Check if file is selected
    // if (avatarFile == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Please select a file first')),
    //   );
    //   return;
    // }

    try {
      // Construct an Employee object with the new fields
      Employee newUser = Employee(
        id: null, // Pass null if it's a new record
        avatar: avatarFile != null
            ? await MultipartFile.fromFile(
                avatarFile!.path,
                filename: avatarFile!.path.split('/').last,
              ).toString()
            : null,
        firstName: newFirstNameController.text,
        lastName: newLastNameController.text,
        birthDate: DateTime.now(), 
        phoneNumber: newPhoneController.text,
        position: newPositionController.text,
        email: newEmailController.text,
        hireDate: DateTime.now(), 
       
      );

      // Convert the Employee object to FormData
      FormData formData = FormData.fromMap({
        ...newUser.toJson(),
        if (avatarFile != null)
          'avatar': await MultipartFile.fromFile(
            avatarFile!.path,
            filename: avatarFile!.path.split('/').last,
          ),
      });

      // Log the FormData for debugging
      print('FormData Fields: ${formData.fields}');

      // Post the data
      await serviceInNewEmployee.postData(
        formData,
        await savedData.getAccessToken(),
      );

      // Fetch the updated employee list
      final newEmployeeList = await serviceInNewEmployee.getData(await savedData.getAccessToken());

      // Navigate to the employee list screen after successful upload
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserList(employeeList: newEmployeeList),
        ),
      );
    } catch (e) {
      // Handle error during file upload
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  },
  child: Text('Upload File'),
)


                // TextButton(
                //   onPressed: () async {
                //     Employee newUser = Employee(
                //       avatar: avatarFile != null ? await MultipartFile.fromFile(avatarFile!.path).toString() : null,
                //       firstName: newFirstNameController.text,
                //       lastName: newLastNameController.text,
                //       birthDate: DateTime.now(),
                //       phoneNumber: newPhoneController.text,
                //       position: newPositionController.text,
                //       email: newEmailController.text,
                //       hireDate: DateTime.now(),
                //     );

                //     try {
                //       FormData newData = FormData.fromMap(newUser.toJson());
                //       print('This is the path of avatarFile${avatarFile!.path}');
                //       print('We are below of the newData');
                //       print('We have to post the following data ${newData.fields}');
                //       await serviceInNewEmployee.postData(
                //         newData,
                //         await savedData.getAccessToken(),
                //       );

                //       final newEmployeeList = await serviceInNewEmployee.getData(await savedData.getAccessToken());

                //       if (!mounted) return;
                //       Navigator.pushReplacement(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => UserList(employeeList: newEmployeeList),
                //         ),
                //       );
                //     } catch (e) {
                //       ScaffoldMessenger.of(context).showSnackBar(
                //         SnackBar(content: Text('Error: ${e.toString()}')),
                //       );
                //     }
                //   },
                //   child: const Text(
                //     'Add',
                //     style: TextStyle(
                //       color: Colors.green,
                //       fontWeight: FontWeight.bold,
                //       fontSize: 24.0,
                //     ),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
