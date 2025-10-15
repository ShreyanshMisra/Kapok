import 'package:flutter/material.dart';
import 'package:kapok_new/models/task_model.dart';
import 'package:translator/translator.dart';

// class CreateTaskPage extends StatefulWidget {
//   @override
//   _CreateTaskPageState createState() => _CreateTaskPageState();
// }

// class _CreateTaskPageState extends State<CreateTaskPage> {
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _coordinatesController = TextEditingController();
//   final TextEditingController _locationNotesController =
//       TextEditingController();
//   final TextEditingController _instructionsController = TextEditingController();

//   String _selectedCategory = 'Construction';
//   int _urgency = 3;

//   final List<String> _categories = [
//     'Construction',
//     'Electrical',
//     'Engineering',
//     'Medical',
//     'Plumbing',
//     'Supplies',
//     'Transportation',
//     'Other',
//   ];

//   @override
//   void dispose() {
//     _addressController.dispose();
//     _coordinatesController.dispose();
//     _locationNotesController.dispose();
//     _instructionsController.dispose();
//     super.dispose();
//   }

//   Future<void> _saveTask() async {
//     Task task = Task(
//       address: _addressController.text,
//       coordinates: _coordinatesController.text,
//       locationNotes: _locationNotesController.text,
//       category: _selectedCategory,
//       instructions: _instructionsController.text,
//       urgency: _urgency,
//     );

//     try {
//       // TODO: Create firebase instance and store
//       // await FirebaseFirestore.instance.collection('tasks').add(task.toMap());
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Task created successfully')),
//       );
//     } catch (e) {
//       print(e);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to create task')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Create Task',
//           style: TextStyle(
//               fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         backgroundColor: Color(0xFF083677),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Location
//             Text('Location',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             TextField(
//               controller: _addressController,
//               decoration: InputDecoration(labelText: 'Address'),
//             ),
//             TextField(
//               controller: _coordinatesController,
//               decoration: InputDecoration(labelText: 'Coordinates'),
//             ),
//             TextField(
//               controller: _locationNotesController,
//               decoration: InputDecoration(labelText: 'Location Notes'),
//             ),
//             SizedBox(height: 20),

//             // Category
//             Text('Category',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             DropdownButtonFormField<String>(
//               value: _selectedCategory,
//               items: _categories
//                   .map((category) => DropdownMenuItem(
//                         value: category,
//                         child: Text(category),
//                       ))
//                   .toList(),
//               onChanged: (value) => setState(() {
//                 _selectedCategory = value!;
//               }),
//               decoration: InputDecoration(labelText: 'Select Category'),
//             ),
//             SizedBox(height: 20),

//             // Instructions/Notes
//             // TODO:
//             Text('Instructions/Notes',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             TextField(
//               controller: _instructionsController,
//               decoration: InputDecoration(labelText: 'Instructions'),
//               maxLines: 5,
//               onTapOutside: (event) {
//                 FocusManager.instance.primaryFocus?.unfocus();
//               },
//               onSubmitted: (_) {
//                 FocusManager.instance.primaryFocus?.unfocus();
//               }, //TODO: Add gesture detector for swiping down on the keyboard to get rid of it
//             ),
//             SizedBox(height: 20),

//             // Urgency
//             Text('Urgency',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             _buildStarRating(),
//             SizedBox(height: 20),

//             ElevatedButton(
//               onPressed: _saveTask,
//               child: Text('Create Task'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget for star rating
//   Widget _buildStarRating() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(5, (index) {
//         return IconButton(
//           icon: Icon(
//             index < _urgency ? Icons.star : Icons.star_border,
//             color: Colors.orange,
//           ),
//           onPressed: () {
//             setState(() {
//               _urgency = index + 1;
//             });
//           },
//         );
//       }),
//     );
//   }
// }

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  _CreateTaskPageState createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _coordinatesController = TextEditingController();
  final TextEditingController _locationNotesController =
      TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  int _urgency = 3;

  final GoogleTranslator _translator = GoogleTranslator();

  // UI Strings
  String _pageTitle = 'Create Task';
  String _locationLabel = 'Location';
  String _addressLabel = 'Address';
  String _coordinatesLabel = 'Coordinates';
  String _locationNotesLabel = 'Location Notes';
  String _categoryLabel = 'Category';
  String _selectCategoryLabel = 'Select Category';
  String _instructionsLabel = 'Instructions/Notes';
  String _instructionsHint = 'Instructions';
  String _urgencyLabel = 'Urgency';
  String _createTaskLabel = 'Create Task';

  bool _isTranslated = false;

  // Categories & selected
  List<String> _categories = [
    'Construction',
    'Electrical',
    'Education',
    'Engineering',
    'Medical',
    'Plumbing',
    'Supplies',
    'Transportation',
    'Other',
  ];
  List<String> _originalCategories = []; // to store originals for reverting
  String _selectedCategory = 'Construction';

  @override
  void initState() {
    super.initState();
    _originalCategories = List.from(_categories); // clone original categories
  }

  @override
  void dispose() {
    _addressController.dispose();
    _coordinatesController.dispose();
    _locationNotesController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _translateTexts() async {
    if (_isTranslated) {
      // Revert to English
      setState(() {
        _pageTitle = 'Create Task';
        _locationLabel = 'Location';
        _addressLabel = 'Address';
        _coordinatesLabel = 'Coordinates';
        _locationNotesLabel = 'Location Notes';
        _categoryLabel = 'Category';
        _selectCategoryLabel = 'Select Category';
        _instructionsLabel = 'Instructions/Notes';
        _instructionsHint = 'Instructions';
        _urgencyLabel = 'Urgency';
        _createTaskLabel = 'Create Task';
        _categories = List.from(_originalCategories);
        _selectedCategory = _categories[0];
        _isTranslated = false;
      });
      return;
    }

    // Translate labels
    final pageTitleEs = await _translator.translate(_pageTitle, to: 'es');
    final locationLabelEs =
        await _translator.translate(_locationLabel, to: 'es');
    final addressLabelEs = await _translator.translate(_addressLabel, to: 'es');
    final coordinatesLabelEs =
        await _translator.translate(_coordinatesLabel, to: 'es');
    final locationNotesLabelEs =
        await _translator.translate(_locationNotesLabel, to: 'es');
    final categoryLabelEs =
        await _translator.translate(_categoryLabel, to: 'es');
    final selectCategoryLabelEs =
        await _translator.translate(_selectCategoryLabel, to: 'es');
    final instructionsLabelEs =
        await _translator.translate(_instructionsLabel, to: 'es');
    final instructionsHintEs =
        await _translator.translate(_instructionsHint, to: 'es');
    final urgencyLabelEs = await _translator.translate(_urgencyLabel, to: 'es');
    final createTaskLabelEs =
        await _translator.translate(_createTaskLabel, to: 'es');

    // Translate categories
    List<String> translatedCategories = [];
    for (var category in _originalCategories) {
      final translated = await _translator.translate(category, to: 'es');
      translatedCategories.add(translated.text);
    }

    setState(() {
      _pageTitle = pageTitleEs.text;
      _locationLabel = locationLabelEs.text;
      _addressLabel = addressLabelEs.text;
      _coordinatesLabel = coordinatesLabelEs.text;
      _locationNotesLabel = locationNotesLabelEs.text;
      _categoryLabel = categoryLabelEs.text;
      _selectCategoryLabel = selectCategoryLabelEs.text;
      _instructionsLabel = instructionsLabelEs.text;
      _instructionsHint = instructionsHintEs.text;
      _urgencyLabel = urgencyLabelEs.text;
      _createTaskLabel = createTaskLabelEs.text;
      _categories = translatedCategories;
      _selectedCategory = translatedCategories[0];
      _isTranslated = true;
    });
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
      // await FirebaseFirestore.instance.collection('tasks').add(task.toMap());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created successfully')),
      );
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
        title: Text(
          _pageTitle,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF083677),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(_locationLabel,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: _addressLabel),
            ),
            TextField(
              controller: _coordinatesController,
              decoration: InputDecoration(labelText: _coordinatesLabel),
            ),
            TextField(
              controller: _locationNotesController,
              decoration: InputDecoration(labelText: _locationNotesLabel),
            ),
            const SizedBox(height: 20),
            Text(_categoryLabel,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              items: _categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) => setState(() {
                _selectedCategory = value!;
              }),
              decoration: InputDecoration(labelText: _selectCategoryLabel),
            ),
            const SizedBox(height: 20),
            Text(_instructionsLabel,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              controller: _instructionsController,
              decoration: InputDecoration(labelText: _instructionsHint),
              maxLines: 5,
              onTapOutside: (event) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            ),
            const SizedBox(height: 20),
            Text(_urgencyLabel,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            _buildStarRating(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTask,
              child: Text(_createTaskLabel),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _translateTexts,
        backgroundColor: Colors.white,
        child: const Icon(Icons.translate),
      ),
    );
  }

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
