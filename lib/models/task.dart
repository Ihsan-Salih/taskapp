class Task {
  final String taskName;
  final String taskDetails;
  final String priority;
  final DateTime date;


  Task({
    required this.taskName,
    required this.taskDetails,
    required this.priority,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'taskName': taskName,
      'taskDetails': taskDetails,
      'priority': priority,
      'date': date.toIso8601String(),
    };
  }
}
