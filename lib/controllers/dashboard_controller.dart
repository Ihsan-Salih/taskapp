import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardController {
  // Get the stream of tasks from Firestore
  Stream<QuerySnapshot<Map<String, dynamic>>> getTasksStream() {
    return FirebaseFirestore.instance.collection('tasks').snapshots();
  }

  // Filter tasks based on selected priority
  List<QueryDocumentSnapshot<Map<String, dynamic>>> filterTasks(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> tasks, String selectedFilter) {
    if (selectedFilter == 'All') {
      return tasks;
    }
    return tasks.where((task) {
      var priority = task['priority'] ?? '';
      return priority == selectedFilter;
    }).toList();
  }

  // Mark task as completed in Firestore
  Future<void> markTaskAsCompleted(String taskId, bool isCompleted) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
        'completed': isCompleted,
      });
    } catch (e) {
      print("Error updating task completion: $e");
    }
  }

  // Delete task from Firestore
  Future<void> deleteTask(String taskId) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
    } catch (e) {
      print("Error deleting task: $e");
    }
  }
}
