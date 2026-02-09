/// Task category enum
enum TaskCategory {
  medical('medical', 'Medical'),
  engineering('engineering', 'Engineering'),
  carpentry('carpentry', 'Carpentry'),
  plumbing('plumbing', 'Plumbing'),
  construction('construction', 'Construction'),
  electrical('electrical', 'Electrical'),
  supplies('supplies', 'Supplies'),
  transportation('transportation', 'Transportation'),
  other('other', 'Other');

  final String value;
  final String displayName;

  const TaskCategory(this.value, this.displayName);

  static TaskCategory fromString(String value) {
    return TaskCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => TaskCategory.other,
    );
  }
}
