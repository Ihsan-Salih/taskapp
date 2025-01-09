import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskController {
  final CollectionReference _taskCollection =
      FirebaseFirestore.instance.collection('tasks');

  // Save a new task to Firestore
  Future<void> saveTask(
    String taskName,
    String taskDetails,
    String priority,
    DateTime date,
  ) async {
    // Check if any of the required fields are empty or null
    if (taskName.isEmpty || taskDetails.isEmpty || priority.isEmpty) {
      throw Exception('All fields are required');
    }

    // Create a new Task object
    final task = Task(
      taskName: taskName,
      taskDetails: taskDetails,
      priority: priority,
      date: date,
    );

    try {
      // Save the task to Firestore
      await _taskCollection.add(task.toMap());
    } catch (e) {
      throw Exception('Error saving task: $e');
    }
  }
  
  // Update an existing task in Firestore by taskId
  Future<void> updateTask(String taskId, String taskName, String taskDetails, String priority, DateTime date, bool completed) async {
    Task updatedTask = Task(
      taskName: taskName,
      taskDetails: taskDetails,
      priority: priority,
      date: date,
    );

    try {
      await _taskCollection.doc(taskId).update(updatedTask.toMap());
    } catch (e) {
      throw Exception('Error updating task: $e');
    }
  }
}