import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kapok_new/models/task_model.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  _CreateTaskPageState createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _coordinatesController = TextEditingController();
  final TextEditingController _locationNotesController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  String _selectedCategory = 'Construction';
  int _urgency = 3;

  final List<String> _categories = [
    'Construction',
    'Electrical',
    'Engineering',
    'Medical',
    'Plumbing',
    'Supplies',
    'Transportation',
    'Other',
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _coordinatesController.dispose();
    _locationNotesController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    Task task = Task(
      address: _addressController.text,
      coordinates: _coordinatesController.text,
      locationNotes: _locationNotesController.text,
      category: _selectedCategory,
      instructions: _instructionsController.text,
      urgency: _urgency,
    );

    try {
      // Save the task to Firestore
      await FirebaseFirestore.instance.collection('tasks').add(task.toMap());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created successfully')),
      );
      Navigator.pop(context);  // Return to the previous page
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create task')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Task',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        backgroundColor: const Color(0xFF083677),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Location
            const Text('Location', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: _coordinatesController,
              decoration: const InputDecoration(labelText: 'Coordinates'),
            ),
            TextField(
              controller: _locationNotesController,
              decoration: const InputDecoration(labelText: 'Location Notes'),
            ),
            const SizedBox(height: 20),

            // Category
            const Text('Category', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) => setState(() {
                _selectedCategory = value!;
              }),
              decoration: const InputDecoration(labelText: 'Select Category'),
            ),
            const SizedBox(height: 20),

            // Instructions/Notes
            const Text('Instructions/Notes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              controller: _instructionsController,
              decoration: const InputDecoration(labelText: 'Instructions'),
              maxLines: 5,
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              onSubmitted: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
            ),
            const SizedBox(height: 20),

            // Urgency
            const Text('Urgency', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            _buildStarRating(),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _saveTask,
              child: const Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for star rating
  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _urgency ? Icons.star : Icons.star_border,
            color: Colors.orange,
          ),
          onPressed: () {
            setState(() {
              _urgency = index + 1;
            });
          },
        );
      }),
    );
  }
}
