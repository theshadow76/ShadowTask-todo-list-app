const String tableTasks = 'tasks';

class TaskFields {
  static final List<String> values = [
    id,
    unique_id,
    email,
    taskState,
    title,
    startDate,
    endDate,
    catagory,
    description,
    status,
    updatedOn
  ];

  static const String id = '_id';
  static const String unique_id = "unique_id";
  static const String email = 'email';
  static const String taskState = 'taskState';
  static const String title = 'title';
  static const String startDate = 'startDate';
  static const String endDate = 'endDate';
  static const String catagory = 'catagory';
  static const String description = 'description';
  static const String status = "status";
  static const String updatedOn = "updatedOn";
}

class Task {
  final int? id;
  final String email;
  final String unique_id;
  final String taskState;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String catagory;
  final String description;
  final String status;
  final DateTime updatedOn;

  const Task(
      {this.id,
      required this.email,
      required this.unique_id,
      required this.taskState,
      required this.title,
      required this.startDate,
      required this.endDate,
      required this.catagory,
      required this.description,
      required this.status,
      required this.updatedOn});

  Task copy(
          {int? id,
          String? email,
          String? unique_id,
          String? taskState,
          String? title,
          DateTime? startDate,
          DateTime? endDate,
          String? catagory,
          String? description,
          String? status,
          DateTime? updatedOn}) =>
      Task(
          id: id ?? this.id,
          email: email ?? this.email,
          unique_id: unique_id ?? this.unique_id,
          taskState: taskState ?? this.taskState,
          title: title ?? this.title,
          startDate: startDate ?? this.startDate,
          endDate: endDate ?? this.endDate,
          catagory: catagory ?? this.catagory,
          description: description ?? this.description,
          status: status ?? this.status,
          updatedOn: updatedOn ?? this.updatedOn);

  static Task fromJson(Map<String, Object?> json) => Task(
      id: json[TaskFields.id] as int?,
      email: json[TaskFields.email] as String,
      unique_id: json[TaskFields.unique_id] as String,
      taskState: json[TaskFields.taskState] as String,
      title: json[TaskFields.title] as String,
      startDate: DateTime.parse(json[TaskFields.startDate] as String),
      endDate: DateTime.parse(json[TaskFields.endDate] as String),
      catagory: json[TaskFields.catagory] as String,
      description: json[TaskFields.description] as String,
      status: json[TaskFields.status] as String,
      updatedOn: DateTime.parse(json[TaskFields.updatedOn] as String));

  Map<String, Object?> toJson() => {
        TaskFields.id: id,
        TaskFields.email: email,
        TaskFields.unique_id:unique_id,
        TaskFields.taskState: taskState,
        TaskFields.title: title,
        TaskFields.startDate: startDate.toIso8601String(),
        TaskFields.endDate: endDate.toIso8601String(),
        TaskFields.catagory: catagory,
        TaskFields.description: description,
        TaskFields.status: status,
        TaskFields.updatedOn: updatedOn.toIso8601String()
      };
}
