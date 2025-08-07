import 'dart:ui';

import 'package:flutter/material.dart';

class StatusConfig {
  static String changeStatus(String status) {
    switch (status) {
      case 'Not Started':
        return 'Chưa bắt đầu';
      case 'In Progress':
        return 'Đang thực hiện';
      case 'On Hold':
        return 'Tạm dừng';
      case 'Completed':
        return 'Đã hoàn thành';
      default:
        return 'Trạng thái không xác định';
    }
  }

  static Color statusColor(String status) {
    switch (status) {
      case 'Not Started':
        return Colors.grey;
      case 'In Progress':
        return Colors.blue;
      case 'On Hold':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  static String changTaskStatus(String status) {
    switch (status) {
      case 'To Do':
        return 'Chưa bắt đầu';
      case 'In Progress':
        return 'Đang thực hiện';
      case 'In Review':
        return 'Đang xem xét';
      case 'Done':
        return 'Đã hoàn thành';
      case 'Blocked':
        return 'Đã bị chặn';
      default:
        return 'Trạng thái không xác định';
    }
  }

  static Color taskStatusColor(String status) {
    switch (status) {
      case 'To Do':
        return Colors.grey;
      case 'In Progress':
        return Colors.blue;
      case 'In Review':
        return Colors.orange;
      case 'Done':
        return Colors.green;
      case 'Blocked':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
