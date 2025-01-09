import 'package:flutter/material.dart';
import '../controllers/task_controller.dart';

class TaskEditView extends StatefulWidget {
  final String taskId;
  final Map<String, dynamic> taskData;

  const TaskEditView({Key? key, required this.taskId, required this.taskData}) : super(key: key);

  @override
  _TaskEditViewState createState() => _TaskEditViewState();
}

class _TaskEditViewState extends State<TaskEditView> {
  late TextEditingController _taskNameController;
  late TextEditingController _taskDetailsController;
  String? _priority;
  bool _isCompleted = false;
  late TaskController _taskController;
  late DateTime _date; // Store the due date here

  @override
  void initState() {
    super.initState();
    _taskController = TaskController();
    _taskNameController = TextEditingController(text: widget.taskData['taskName']);
    _taskDetailsController = TextEditingController(text: widget.taskData['taskDetails']);
    _priority = widget.taskData['priority'];
    _isCompleted = widget.taskData['completed'] ?? false;
    _date = DateTime.parse(widget.taskData['date']); // Parse the due date from Firestore
  }

  // Function to open the date picker and set the due date
  Future<void> _pickDueDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _updateTask() async {
  try {
    // Call the controller's update method to update the task in Firestore
    await _taskController.updateTask(
      widget.taskId,
      _taskNameController.text,
      _taskDetailsController.text,
      _priority ?? 'Medium',
      _date,
      _isCompleted,
    );
    Navigator.pop(context); // Close the edit screen
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task updated successfully!')));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating task: $e')));
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _taskNameController,
              decoration: const InputDecoration(labelText: 'Task Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _taskDetailsController,
              decoration: const InputDecoration(labelText: 'Task Details'),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _priority,
              onChanged: (value) => setState(() => _priority = value),
              decoration: const InputDecoration(labelText: 'Priority'),
              items: const [
                DropdownMenuItem(value: 'High', child: Text('High')),
                DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                DropdownMenuItem(value: 'Low', child: Text('Low')),
              ],
            ),
            Row(
              children: [
                const Text('Due Date: '),
                Text(
                  '${_date.toLocal()}'.split(' ')[0], 
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDueDate,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateTask, // Save the changes when pressed
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
