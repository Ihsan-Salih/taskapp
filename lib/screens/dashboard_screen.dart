import 'package:flutter/material.dart';
import 'package:task/screens/task_edit_view.dart';
import '../controllers/dashboard_controller.dart';
import 'task_screen.dart';
import 'resources_hub_youtube_view.dart';
import 'open_ai_integration_view.dart';
import 'progress_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedFilter = 'All';
  final DashboardController _controller = DashboardController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Edu', style: TextStyle(color: Colors.blue, fontSize: 22, fontWeight: FontWeight.bold)),
                TextSpan(text: 'Track', style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hello!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      selectedFilter = value;
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'All',
                      child: Text('All'),
                    ),
                    const PopupMenuItem(
                      value: 'High',
                      child: Row(
                        children: [
                          Icon(Icons.circle, color: Colors.red, size: 16),
                          SizedBox(width: 8),
                          Text('High'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'Medium',
                      child: Row(
                        children: [
                          Icon(Icons.circle, color: Colors.green, size: 16),
                          SizedBox(width: 8),
                          Text('Medium'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'Low',
                      child: Row(
                        children: [
                          Icon(Icons.circle, color: Colors.yellow, size: 16),
                          SizedBox(width: 8),
                          Text('Low'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _controller.getTasksStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final tasks = snapshot.data?.docs ?? [];
                  final filteredTasks = _controller.filterTasks(tasks, selectedFilter);

                  return ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      var task = filteredTasks[index].data() as Map<String, dynamic>;
                      String taskId = filteredTasks[index].id;
                      bool isCompleted = task['completed'] ?? false;

                      return Dismissible(
                        key: Key(taskId),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          _controller.deleteTask(taskId);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Task Title
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      task['taskName'] ?? 'No task name',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      Icons.circle,
                                      color: task['priority'] == 'High'
                                          ? Colors.red
                                          : task['priority'] == 'Medium'
                                          ? Colors.green
                                          : Colors.yellow,
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Task Description
                                Text(
                                  task['taskDetails'] ?? 'No description available',
                                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                // Task Date
                                Text(
                                  task['date']?.split('T')[0] ?? '',
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                                // Completion Toggle
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(isCompleted ? "Completed" : "Not Completed"),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit, color: Colors.blue),
                                              onPressed: () {
                        // Navigate to TaskEditView on icon tap
                                                   Navigator.push(
                                                      context,
                                                          MaterialPageRoute(
                                                            builder: (context) => TaskEditView(taskId: taskId, taskData: task),
                          ),
                        );
                      },  
                    ),
                                    Switch(
                                      value: isCompleted,
                                      activeColor: Colors.blue,
                                      onChanged: (value) {
                                        _controller.markTaskAsCompleted(taskId, value);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskScreen()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ResourcesHubYouTubeView()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProgressTrackerScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OpenAIIntegrationView()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Resource Hub'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Track Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.language), label: 'Language Coach'),
        ],
      ),
    );
  }
}
