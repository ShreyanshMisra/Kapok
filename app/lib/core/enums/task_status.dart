/// Task status enum
enum TaskStatus {
  pending('pending', 'Pending'),
  inProgress('inProgress', 'In Progress'),
  completed('completed', 'Completed');

  final String value;
  final String displayName;

  const TaskStatus(this.value, this.displayName);

  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TaskStatus.pending,
    );
  }
}
