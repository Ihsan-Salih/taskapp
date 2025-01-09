import 'package:flutter/material.dart';
import '../controllers/task_controller.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TaskController _taskController = TaskController();
  final TextEditingController _taskDetailsController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedPriority;
  String? _selectedSubject; // Added variable to store selected subject

  // List of 11 main subjects for OL
  final List<String> _subjects = [
    'Mathematics', 'English Language', 'Science', 'Sinhala', 'Tamil',
    'History', 'Geography', 'Civics', 'Commerce', 'Accountancy', 'Economics'
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _setPriority(String priority) {
    setState(() {
      _selectedPriority = priority;
    });
  }
Future<void> _saveTask() async {
  try {
    await _taskController.saveTask(
      _selectedSubject!,
      _taskDetailsController.text,
      _selectedPriority!,
      _selectedDate!,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task saved successfully!')),
    );

    _taskDetailsController.clear();
    setState(() {
      _selectedPriority = null;
      _selectedDate = null;
      _selectedSubject = null;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save task: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("New Task"),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Set Priority:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () => _setPriority("High"),
                  child: const Text("High"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _selectedPriority == "High" ? Colors.red : Colors.black,
                  ),
                ),
                OutlinedButton(
                  onPressed: () => _setPriority("Medium"),
                  child: const Text("Medium"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _selectedPriority == "Medium" ? Colors.orange : Colors.black,
                  ),
                ),
                OutlinedButton(
                  onPressed: () => _setPriority("Low"),
                  child: const Text("Low"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _selectedPriority == "Low" ? Colors.green : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              "Subject Name:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Dropdown for selecting the subject
            DropdownButton<String>(
              value: _selectedSubject, // Store the selected subject
              hint: const Text('Select Subject', style: TextStyle(color: Colors.black)),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSubject = newValue;
                });
              },
              style: TextStyle(color: Colors.black), // Black text color
              dropdownColor: Colors.blue, // Blue background color
              items: _subjects.map<DropdownMenuItem<String>>((String subject) {
                return DropdownMenuItem<String>(
                  value: subject,
                  child: Text(subject),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            const Text(
              "Task Details:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _taskDetailsController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Enter task details',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            if (_selectedDate != null || _selectedPriority != null) ...[
              const Text(
                "Summary:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Selected Date: ${_selectedDate != null ? "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}" : "None"}",
              ),
              Text(
                "Priority: ${_selectedPriority ?? "None"}",
              ),
            ],

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveTask,
                child: const Text('Save Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
