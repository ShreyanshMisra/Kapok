import 'package:flutter/material.dart';
import 'package:kapok_new/models/task_model.dart';

class CreateTaskPage extends StatefulWidget {
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
      // TODO: Create firebase instance and store
     // await FirebaseFirestore.instance.collection('tasks').add(task.toMap());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task created successfully')),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create task')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Create Task',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white
          ),
        ),
        backgroundColor: Color(0xFF083677),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Location 
            Text('Location', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: _coordinatesController,
              decoration: InputDecoration(labelText: 'Coordinates'),
            ),
            TextField(
              controller: _locationNotesController,
              decoration: InputDecoration(labelText: 'Location Notes'),
            ),
            SizedBox(height: 20),

            // Category 
            Text('Category', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
              decoration: InputDecoration(labelText: 'Select Category'),
            ),
            SizedBox(height: 20),

            // Instructions/Notes 
            // TODO: 
            Text('Instructions/Notes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              controller: _instructionsController,
              decoration: InputDecoration(labelText: 'Instructions'),
              maxLines: 5,
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              onSubmitted: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
              }, //TODO: Add gesture detector for swiping down on the keyboard to get rid of it
            ),
            SizedBox(height: 20),

            // Urgency 
            Text('Urgency', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            _buildStarRating(),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: _saveTask,
              child: Text('Create Task'),
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
