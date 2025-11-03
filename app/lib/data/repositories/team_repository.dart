import 'dart:math';
import '../../core/error/exceptions.dart';
import '../../core/services/network_checker.dart';
import '../../core/utils/logger.dart';
import '../models/team_model.dart';
import '../sources/firebase_source.dart';
import '../sources/hive_source.dart';

/// Repository for team operations
class TeamRepository {
  final FirebaseSource _firebaseSource;
  final HiveSource _hiveSource;
  final NetworkChecker _networkChecker;

  TeamRepository({
    required FirebaseSource firebaseSource,
    required HiveSource hiveSource,
    required NetworkChecker networkChecker,
  }) : _firebaseSource = firebaseSource,
       _hiveSource = hiveSource,
       _networkChecker = networkChecker;

  /// Create a new team
  Future<TeamModel> createTeam({
    required String name,
    required String leaderId,
  }) async {
    try {
      Logger.team('Creating team: $name');
      
      // Generate unique team code
      final teamCode = _generateTeamCode();
      
      // Create team model
      final team = TeamModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        leaderId: leaderId,
        teamCode: teamCode,
        memberIds: [leaderId],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );
      
      if (await _networkChecker.isConnected()) {
        // Save to Firebase
        await _firebaseSource.createTeam(team);
      }
      
      // Always save locally
      await _hiveSource.saveTeam(team);
      
      Logger.team('Team created successfully: ${team.id}');
      return team;
    } catch (e) {
      Logger.team('Error creating team', error: e);
      throw TeamException(
        message: 'Failed to create team',
        originalError: e,
      );
    }
  }

  /// Join a team using team code
  Future<TeamModel> joinTeam({
    required String teamCode,
    required String userId,
  }) async {
    try {
      Logger.team('Joining team with code: $teamCode');
      
      if (!await _networkChecker.isConnected()) {
        throw TeamException(message: 'Cannot join team while offline');
      }
      
      // Join team via Firebase
      await _firebaseSource.joinTeamByCode(teamCode, userId);
      
      // Get updated team
      final team = await _firebaseSource.getTeamByCode(teamCode);
      
      // Update local cache
      await _hiveSource.saveTeam(team);
      
      Logger.team('User joined team successfully: ${team.id}');
      return team;
    } catch (e) {
      Logger.team('Error joining team', error: e);
      if (e is TeamException) {
        rethrow;
      }
      throw TeamException(
        message: 'Failed to join team',
        originalError: e,
      );
    }
  }

  /// Leave a team
  Future<void> leaveTeam({
    required String teamId,
    required String userId,
  }) async {
    try {
      Logger.team('Leaving team: $teamId');
      
      TeamModel team;
      
      if (await _networkChecker.isConnected()) {
        team = await _firebaseSource.getTeam(teamId);
      } else {
        final cachedTeam = await _hiveSource.getTeam(teamId);
        if (cachedTeam == null) {
          throw TeamException(message: 'Team not found');
        }
        team = cachedTeam;
      }
      
      // Check if user is a member
      if (!team.memberIds.contains(userId)) {
        throw TeamException(message: 'User is not a member of this team');
      }
      
      // Check if user is the leader
      if (team.leaderId == userId) {
        throw TeamException(message: 'Team leader cannot leave the team');
      }
      
      // Remove user from team
      final updatedTeam = team.copyWith(
        memberIds: team.memberIds.where((id) => id != userId).toList(),
        updatedAt: DateTime.now(),
      );
      
      if (await _networkChecker.isConnected()) {
        // Update on Firebase
        await _firebaseSource.updateTeam(updatedTeam);
      }
      
      // Update local cache
      await _hiveSource.saveTeam(updatedTeam);
      
      Logger.team('User left team successfully');
    } catch (e) {
      Logger.team('Error leaving team', error: e);
      if (e is TeamException) {
        rethrow;
      }
      throw TeamException(
        message: 'Failed to leave team',
        originalError: e,
      );
    }
  }

  /// Get teams for a user
  Future<List<TeamModel>> getUserTeams(String userId) async {
    try {
      Logger.team('Getting teams for user: $userId');
      
      List<TeamModel> teams;
      
      if (await _networkChecker.isConnected()) {
        // Get from Firebase
        teams = await _firebaseSource.getUserTeams(userId);
        
        // Cache locally
        await _hiveSource.cacheTeams(teams);
      } else {
        // Get from local cache
        teams = await _hiveSource.getUserTeams(userId);
      }
      
      Logger.team('Found ${teams.length} teams for user');
      return teams;
    } catch (e) {
      Logger.team('Error getting user teams', error: e);
      throw TeamException(
        message: 'Failed to get user teams',
        originalError: e,
      );
    }
  }

  /// Get team by ID
  Future<TeamModel> getTeam(String teamId) async {
    try {
      Logger.team('Getting team: $teamId');
      
      TeamModel? team;
      
      if (await _networkChecker.isConnected()) {
        // Get from Firebase
        team = await _firebaseSource.getTeam(teamId);
        
        // Cache locally
        await _hiveSource.saveTeam(team);
      } else {
        // Get from local cache
        team = await _hiveSource.getTeam(teamId);
      }
      
      if (team == null) {
        throw TeamException(message: 'Team not found');
      }
      
      return team;
    } catch (e) {
      Logger.team('Error getting team', error: e);
      if (e is TeamException) {
        rethrow;
      }
      throw TeamException(
        message: 'Failed to get team',
        originalError: e,
      );
    }
  }

  /// Update team
  Future<TeamModel> updateTeam(TeamModel team) async {
    try {
      Logger.team('Updating team: ${team.id}');
      
      final updatedTeam = team.copyWith(updatedAt: DateTime.now());
      
      if (await _networkChecker.isConnected()) {
        // Update on Firebase
        await _firebaseSource.updateTeam(updatedTeam);
      }
      
      // Always update local cache
      await _hiveSource.saveTeam(updatedTeam);
      
      Logger.team('Team updated successfully');
      return updatedTeam;
    } catch (e) {
      Logger.team('Error updating team', error: e);
      throw TeamException(
        message: 'Failed to update team',
        originalError: e,
      );
    }
  }

  /// Close a team (deactivate)
  Future<void> closeTeam({
    required String teamId,
    required String userId,
  }) async {
    try {
      Logger.team('Closing team: $teamId');
      
      TeamModel team;
      
      if (await _networkChecker.isConnected()) {
        team = await _firebaseSource.getTeam(teamId);
      } else {
        final cachedTeam = await _hiveSource.getTeam(teamId);
        if (cachedTeam == null) {
          throw TeamException(message: 'Team not found');
        }
        team = cachedTeam;
      }
      
      // Check if user is the leader
      if (team.leaderId != userId) {
        throw TeamException(message: 'Only team leader can close the team');
      }
      
      // Deactivate team
      final updatedTeam = team.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );
      
      if (await _networkChecker.isConnected()) {
        // Update on Firebase
        await _firebaseSource.updateTeam(updatedTeam);
      }
      
      // Update local cache
      await _hiveSource.saveTeam(updatedTeam);
      
      Logger.team('Team closed successfully');
    } catch (e) {
      Logger.team('Error closing team', error: e);
      if (e is TeamException) {
        rethrow;
      }
      throw TeamException(
        message: 'Failed to close team',
        originalError: e,
      );
    }
  }

  /// Remove member from team
  Future<void> removeMember({
    required String teamId,
    required String memberId,
    required String leaderId,
  }) async {
    try {
      Logger.team('Removing member from team: $teamId');
      
      TeamModel team;
      
      if (await _networkChecker.isConnected()) {
        team = await _firebaseSource.getTeam(teamId);
      } else {
        final cachedTeam = await _hiveSource.getTeam(teamId);
        if (cachedTeam == null) {
          throw TeamException(message: 'Team not found');
        }
        team = cachedTeam;
      }
      
      // Check if user is the leader
      if (team.leaderId != leaderId) {
        throw TeamException(message: 'Only team leader can remove members');
      }
      
      // Check if member exists
      if (!team.memberIds.contains(memberId)) {
        throw TeamException(message: 'Member not found in team');
      }
      
      // Remove member from team
      final updatedTeam = team.copyWith(
        memberIds: team.memberIds.where((id) => id != memberId).toList(),
        updatedAt: DateTime.now(),
      );
      
      if (await _networkChecker.isConnected()) {
        // Update on Firebase
        await _firebaseSource.updateTeam(updatedTeam);
      }
      
      // Update local cache
      await _hiveSource.saveTeam(updatedTeam);
      
      Logger.team('Member removed successfully');
    } catch (e) {
      Logger.team('Error removing member', error: e);
      if (e is TeamException) {
        rethrow;
      }
      throw TeamException(
        message: 'Failed to remove member',
        originalError: e,
      );
    }
  }

  /// Generate unique team code
  String _generateTeamCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
}
