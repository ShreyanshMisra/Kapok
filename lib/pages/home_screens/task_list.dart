// import 'package:flutter/material.dart';

// class TaskListPage extends StatefulWidget {
//   const TaskListPage({super.key});

//   @override
//   State<TaskListPage> createState() => _TaskListPageState();
// }

// class _TaskListPageState extends State<TaskListPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//             'Member Tasks',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white
//           ),
//         ),
//         // TODO: possbile global styles to reduce styling issues
//         backgroundColor: Color(0xFF083677),
//       ),
//       body: TaskScreen(),
//     );
//   }
// }

// // class TaskListHome extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: Scaffold(
// //         appBar: AppBar(
// //           title: Text('Member Tasks'),
// //           // TODO: possbile global styles to reduce styling issues
// //           backgroundColor: Color(0xFF083677),
// //           titleTextStyle: TextStyle(
// //           color: Colors.white
// //           ),
// //         ),
// //         body: TaskScreen(),
// //       ),
// //     );
// //   }
// // }

// class TaskScreen extends StatefulWidget {
//   @override
//   _TaskScreenState createState() => _TaskScreenState();
// }

// class _TaskScreenState extends State<TaskScreen> {
//   // expand widgets on click
//   bool showCompleteTasks = false;
//   bool showIncompleteTasks = true;

//   @override
//   Widget build(BuildContext context) {
//   return Padding(
//     padding: const EdgeInsets.all(16.0),
//     child: SingleChildScrollView(
//       child: Column(
//         children: [
//           ExpansionTile(
//             title: Text(
//               'Complete Tasks',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             // fetch from firebase
//             trailing: Text("Number of Tasks: #"),
//             children: [
//               ListTile(
//                 title: Text("No tasks completed."),
//               ),
//             ],
//             onExpansionChanged: (bool expanded) {
//               setState(() => showCompleteTasks = expanded);
//             },
//           ),
//           Divider(),
//           ExpansionTile(
//             initiallyExpanded: true,
//             title: Text(
//               'Incomplete Tasks',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             children: [
//               TaskList(),
//             ],
//             onExpansionChanged: (bool expanded) {
//               setState(() => showIncompleteTasks = expanded);
//             },
//           ),
//         ],
//       ),
//     ),
//   );
// }

// }

// // boilerplate
// class TaskList extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return
//       SingleChildScrollView(
//       child: Column(
//       children:
//       List.generate(6, (index) {
//         return TaskItem(task: 'Task Name', assignedTo: 'Team Member');
//       }),

//     ),
//     );

//   }
// }

// class TaskItem extends StatelessWidget {
//   final String task;
//   final String assignedTo;

//   TaskItem({required this.task, required this.assignedTo});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Checkbox(value: false, onChanged: (value) {}),
//               SizedBox(width: 8),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     task,
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   Text(
//                     'Assigned To: $assignedTo',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           IconButton(
//             onPressed: () {
//               // TODO:
//             },
//             icon: Icon(Icons.arrow_forward),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final GoogleTranslator _translator = GoogleTranslator();
  bool _isTranslated = false;

  String _titleLabel = 'Member Tasks';
  String _completeLabel = 'Complete Tasks';
  String _incompleteLabel = 'Incomplete Tasks';
  String _noTasksLabel = 'No tasks completed.';
  String _assignedToLabel = 'Assigned To';
  String _taskNameLabel = 'Task Name';
  String _taskCountLabel = 'Number of Tasks: #';

  Future<void> _translateTexts() async {
    if (_isTranslated) {
      setState(() {
        _titleLabel = 'Member Tasks';
        _completeLabel = 'Complete Tasks';
        _incompleteLabel = 'Incomplete Tasks';
        _noTasksLabel = 'No tasks completed.';
        _assignedToLabel = 'Assigned To';
        _taskNameLabel = 'Task Name';
        _taskCountLabel = 'Number of Tasks: #';
        _isTranslated = false;
      });
    } else {
      final title = await _translator.translate(_titleLabel, to: 'es');
      final complete = await _translator.translate(_completeLabel, to: 'es');
      final incomplete =
          await _translator.translate(_incompleteLabel, to: 'es');
      final noTasks = await _translator.translate(_noTasksLabel, to: 'es');
      final assigned = await _translator.translate(_assignedToLabel, to: 'es');
      final taskName = await _translator.translate(_taskNameLabel, to: 'es');
      final taskCount =
          await _translator.translate('Number of Tasks:', to: 'es');

      setState(() {
        _titleLabel = title.text;
        _completeLabel = complete.text;
        _incompleteLabel = incomplete.text;
        _noTasksLabel = noTasks.text;
        _assignedToLabel = assigned.text;
        _taskNameLabel = taskName.text;
        _taskCountLabel = '${taskCount.text} #';
        _isTranslated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titleLabel,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF083677),
      ),
      body: TaskScreen(
        completeLabel: _completeLabel,
        incompleteLabel: _incompleteLabel,
        noTasksLabel: _noTasksLabel,
        assignedToLabel: _assignedToLabel,
        taskNameLabel: _taskNameLabel,
        taskCountLabel: _taskCountLabel,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _translateTexts,
        backgroundColor: Colors.white,
        child: const Icon(Icons.translate, color: Colors.black),
      ),
    );
  }
}

class TaskScreen extends StatefulWidget {
  final String completeLabel;
  final String incompleteLabel;
  final String noTasksLabel;
  final String assignedToLabel;
  final String taskNameLabel;
  final String taskCountLabel;

  const TaskScreen({
    super.key,
    required this.completeLabel,
    required this.incompleteLabel,
    required this.noTasksLabel,
    required this.assignedToLabel,
    required this.taskNameLabel,
    required this.taskCountLabel,
  });

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  bool showCompleteTasks = false;
  bool showIncompleteTasks = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ExpansionTile(
              title: Text(
                widget.completeLabel,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: Text(widget.taskCountLabel),
              children: [
                ListTile(title: Text(widget.noTasksLabel)),
              ],
              onExpansionChanged: (bool expanded) {
                setState(() => showCompleteTasks = expanded);
              },
            ),
            const Divider(),
            ExpansionTile(
              initiallyExpanded: true,
              title: Text(
                widget.incompleteLabel,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              children: [
                TaskList(
                  taskNameLabel: widget.taskNameLabel,
                  assignedToLabel: widget.assignedToLabel,
                ),
              ],
              onExpansionChanged: (bool expanded) {
                setState(() => showIncompleteTasks = expanded);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  final String taskNameLabel;
  final String assignedToLabel;

  const TaskList(
      {super.key, required this.taskNameLabel, required this.assignedToLabel});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(6, (index) {
          return TaskItem(
              task: taskNameLabel, assignedTo: '$assignedToLabel: Team Member');
        }),
      ),
    );
  }
}

class TaskItem extends StatelessWidget {
  final String task;
  final String assignedTo;

  const TaskItem({super.key, required this.task, required this.assignedTo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Checkbox(value: false, onChanged: (value) {}),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(assignedTo, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}
