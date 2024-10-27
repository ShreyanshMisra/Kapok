import 'package:flutter/material.dart';


class TaskListHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Member Tasks'),
          // TODO: possbile global styles to reduce styling issues
          backgroundColor: Color(0xFF083677),
          titleTextStyle: TextStyle(
          color: Colors.white
          ),
        ),
        body: TaskScreen(),
      ),
    );
  }
}

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  // expand widgets on click
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
              'Complete Tasks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // fetch from firebase
            trailing: Text("Number of Tasks: #"),
            children: [
              ListTile(
                title: Text("No tasks completed."),
              ),
            ],
            onExpansionChanged: (bool expanded) {
              setState(() => showCompleteTasks = expanded);
            },
          ),
          Divider(),
          ExpansionTile(
            initiallyExpanded: true,
            title: Text(
              'Incomplete Tasks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            children: [
              TaskList(),
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

// boilerplate 
class TaskList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return 
      SingleChildScrollView(
      child: Column(
      children: 
      List.generate(6, (index) {
        return TaskItem(task: 'Task Name', assignedTo: 'Team Member');
      }),
      
    ),
    );
    
  }
}

class TaskItem extends StatelessWidget {
  final String task;
  final String assignedTo;

  TaskItem({required this.task, required this.assignedTo});

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
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Assigned To: $assignedTo',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              // TODO: 
            },
            icon: Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}
