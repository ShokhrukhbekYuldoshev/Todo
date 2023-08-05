import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum TodoPriority { low, medium, high }

TodoPriority todoPriorityFromName(String name) {
  return TodoPriority.values.firstWhere(
    (element) => element.name == name,
    orElse: () => TodoPriority.low,
  );
}

enum TodoSort { createdAt, dueAt, priority }

enum TodoOrder { asc, desc }

enum TodoFilter { all, completed, uncompleted }

// ignore: must_be_immutable
class Todo extends Equatable {
  int? id;
  final String title;
  final String? description;
  final Color color;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueAt;
  final DateTime? completedAt;
  final TodoPriority priority;

  Todo({
    this.id,
    required this.title,
    this.description,
    required this.color,
    this.completed = false,
    required this.createdAt,
    required this.updatedAt,
    this.dueAt,
    this.completedAt,
    required this.priority,
  });

  Todo copyWith({
    int? id,
    String? title,
    String? description,
    Color? color,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueAt,
    DateTime? completedAt,
    TodoPriority? priority,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueAt: dueAt ?? this.dueAt,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'color': color.value,
      'completed': completed ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'dueAt': dueAt?.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'priority': priority.name,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int,
      title: map['title'] as String,
      description:
          map['description'] != null ? map['description'] as String : null,
      color: Color(map['color'] as int),
      completed: map['completed'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      dueAt: map['dueAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueAt'] as int)
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int)
          : null,
      priority: TodoPriority.values
          .firstWhere((element) => element.name == map['priority'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory Todo.fromJson(String source) =>
      Todo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      id,
      title,
      description,
      color,
      completed,
      createdAt,
      updatedAt,
      dueAt,
      completedAt,
      priority,
    ];
  }
}
