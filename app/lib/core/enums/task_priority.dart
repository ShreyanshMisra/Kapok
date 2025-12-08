/// Task priority enum
enum TaskPriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High');

  final String value;
  final String displayName;

  const TaskPriority(this.value, this.displayName);

  static TaskPriority fromString(String value) {
    return TaskPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => TaskPriority.medium,
    );
  }
}
