import 'package:flutter/material.dart';

class Task {
  final String title;
  final String status;
  final Color statusColor;
  final String dueDate;
  bool isChecked;

  Task(this.title, this.status, this.statusColor, this.dueDate, {this.isChecked = false});
}

class Aircraft {
  final String code;
  final String subCode;
  final double progress;
  final String imageUrl;

  Aircraft(this.code, this.subCode, this.progress, this.imageUrl);
}