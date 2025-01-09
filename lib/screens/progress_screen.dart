import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressTrackerScreen extends StatelessWidget {
  // Function to calculate progress for a subject
  Future<Map<String, double>> _calculateSubjectProgress() async {
    // Query the Firestore collection for tasks
    QuerySnapshot tasksSnapshot = await FirebaseFirestore.instance.collection('tasks').get();
    var tasks = tasksSnapshot.docs;

    Map<String, int> subjectTaskCount = {};
    Map<String, int> subjectCompletedCount = {};

    for (var taskDoc in tasks) {
      var task = taskDoc.data() as Map<String, dynamic>;
      String subject = task['subject'] ?? 'You have completed:';
      bool isCompleted = task['completed'] ?? false;

      // Count total tasks and completed tasks per subject
      subjectTaskCount[subject] = (subjectTaskCount[subject] ?? 0) + 1;
      if (isCompleted) {
        subjectCompletedCount[subject] = (subjectCompletedCount[subject] ?? 0) + 1;
      }
    }

    // Calculate progress for each subject
    Map<String, double> subjectProgress = {};
    subjectTaskCount.forEach((subject, totalTasks) {
      int completedTasks = subjectCompletedCount[subject] ?? 0;
      double progress = (totalTasks > 0) ? (completedTasks / totalTasks) * 100 : 0;
      subjectProgress[subject] = progress;
    });

    return subjectProgress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('        Progress Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tasks completed:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Display progress for each subject
            FutureBuilder<Map<String, double>>(
              future: _calculateSubjectProgress(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error calculating progress'));
                }

                var subjectProgress = snapshot.data ?? {};

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: subjectProgress.length,
                  itemBuilder: (context, index) {
                    String subject = subjectProgress.keys.elementAt(index);
                    double progress = subjectProgress[subject] ?? 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  subject,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${progress.toStringAsFixed(0)}%',
                                  style: const TextStyle(fontSize: 16, color: Colors.blue),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress / 100,
                              color: Colors.blue,
                              backgroundColor: Colors.grey[300],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
