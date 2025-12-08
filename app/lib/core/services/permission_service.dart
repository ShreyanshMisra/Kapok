import '../../data/models/user_model.dart';
import '../../data/models/team_model.dart';
import '../../data/models/task_model.dart';
import '../enums/user_role.dart';

/// Service for permission checks throughout the application
class PermissionService {
  static PermissionService? _instance;
  static PermissionService get instance => _instance ??= PermissionService._();

  PermissionService._();

  /// Check if user can create a team
  bool canCreateTeam(UserModel user) {
    return user.userRole == UserRole.teamLeader;
  }

  /// Check if user can join a team
  /// All roles can join teams, except team leaders cannot join their own team
  bool canJoinTeam(UserModel user, {String? teamId, String? leaderId}) {
    // Admins can join any team
    if (user.userRole == UserRole.admin) {
      return true;
    }
    
    // Team members can join any team (as long as they're not already in it)
    if (user.userRole == UserRole.teamMember) {
      return true;
    }
    
    // Team leaders can join teams, but not their own team
    if (user.userRole == UserRole.teamLeader) {
      // If we have team info, check if it's their own team
      if (teamId != null && user.teamId == teamId) {
        return false; // Cannot join own team
      }
      if (leaderId != null && user.id == leaderId) {
        return false; // Cannot join team they lead
      }
      return true; // Can join other teams
    }
    
    return false;
  }

  /// Check if user can create a task
  /// All roles can create tasks, but must be in a team (except admins)
  bool canCreateTask(UserModel user) {
    if (user.userRole == UserRole.admin) {
      return true; // Admins can create tasks for any team
    }
    return user.teamId != null && user.teamId!.isNotEmpty;
  }

  /// Check if user can edit a task
  bool canEditTask(UserModel user, TaskModel task) {
    if (user.userRole == UserRole.admin) {
      return true; // Admins can edit any task
    }
    if (user.id == task.createdBy) {
      return true; // Creator can edit
    }
    if (user.userRole == UserRole.teamLeader && user.teamId == task.teamId) {
      return true; // Team leader can edit tasks in their team
    }
    return false;
  }

  /// Check if user can delete a task
  bool canDeleteTask(UserModel user, TaskModel task) {
    if (user.userRole == UserRole.admin) {
      return true; // Admins can delete any task
    }
    if (user.id == task.createdBy) {
      return true; // Creator can delete
    }
    if (user.userRole == UserRole.teamLeader && user.teamId == task.teamId) {
      return true; // Team leader can delete tasks in their team
    }
    return false;
  }

  /// Check if user can assign a task
  bool canAssignTask(UserModel user, TaskModel task) {
    if (user.userRole == UserRole.admin) {
      return true; // Admins can assign any task
    }
    if (user.userRole == UserRole.teamLeader && user.teamId == task.teamId) {
      return true; // Team leader can assign tasks in their team
    }
    return false;
  }

  /// Check if user can complete a task
  bool canCompleteTask(UserModel user, TaskModel task) {
    if (user.userRole == UserRole.admin) {
      return true; // Admins can complete any task
    }
    if (user.id == task.assignedTo) {
      return true; // Assigned user can complete
    }
    if (user.id == task.createdBy) {
      return true; // Creator can complete
    }
    return false;
  }

  /// Check if user can view all teams (admin only)
  bool canViewAllTeams(UserModel user) {
    return user.userRole == UserRole.admin;
  }

  /// Check if user can modify team members
  bool canModifyTeamMembers(UserModel user, TeamModel team) {
    if (user.userRole == UserRole.admin) {
      return true; // Admins can modify any team
    }
    if (user.userRole == UserRole.teamLeader && team.leaderId == user.id) {
      return true; // Team leader can modify their own team
    }
    return false;
  }

  /// Check if user can remove a member from team
  bool canRemoveMember(UserModel user, TeamModel team, String memberId) {
    if (user.userRole == UserRole.admin) {
      return true; // Admins can remove any member
    }
    if (user.userRole == UserRole.teamLeader && 
        team.leaderId == user.id && 
        memberId != user.id) {
      return true; // Team leader can remove members (not themselves)
    }
    return false;
  }

  /// Check if user can close/deactivate a team
  bool canCloseTeam(UserModel user, TeamModel team) {
    if (user.userRole == UserRole.admin) {
      return true; // Admins can close any team
    }
    if (user.userRole == UserRole.teamLeader && team.leaderId == user.id) {
      return true; // Team leader can close their own team
    }
    return false;
  }

  /// Check if user can view team details
  bool canViewTeam(UserModel user, TeamModel team) {
    if (user.userRole == UserRole.admin) {
      return true; // Admins can view any team
    }
    return team.memberIds.contains(user.id); // Members can view their team
  }

  /// Check if user can view task details
  bool canViewTask(UserModel user, TaskModel task) {
    if (user.userRole == UserRole.admin) {
      return true; // Admins can view any task
    }
    if (user.teamId == task.teamId) {
      return true; // Team members can view tasks in their team
    }
    return false;
  }
}

