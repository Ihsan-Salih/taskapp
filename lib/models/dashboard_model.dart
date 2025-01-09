import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardModel {
  // Fetch tasks from Firestore
  Stream<QuerySnapshot> getTasksStream() {
    return FirebaseFirestore.instance.collection('tasks').snapshots();
  }

  // Mark task as completed
  Future<void> markTaskAsCompleted(String taskId, bool isCompleted) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
        'completed': isCompleted,
      });
    } catch (e) {
      print("Error updating task completion: $e");
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
    } catch (e) {
      print("Error deleting task: $e");
    }
  }}