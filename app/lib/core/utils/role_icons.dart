import 'package:flutter/material.dart';

/// Shared utility for mapping specialty role strings to Material icons.
/// Used by team detail, task detail, and create task pages.
IconData getRoleIcon(String role) {
  switch (role.toLowerCase()) {
    case 'medical':
      return Icons.medical_services;
    case 'engineering':
      return Icons.engineering;
    case 'carpentry':
      return Icons.handyman;
    case 'plumbing':
      return Icons.plumbing;
    case 'construction':
      return Icons.construction;
    case 'electrical':
      return Icons.electrical_services;
    case 'supplies':
      return Icons.inventory;
    case 'transportation':
      return Icons.local_shipping;
    default:
      return Icons.work;
  }
}
