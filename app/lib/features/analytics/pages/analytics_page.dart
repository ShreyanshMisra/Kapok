import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/enums/task_status.dart';
import '../../../core/enums/task_priority.dart';
import '../../../core/widgets/kapok_logo.dart';
import '../../../data/models/task_model.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../tasks/bloc/task_bloc.dart';
import '../../tasks/bloc/task_event.dart';
import '../../tasks/bloc/task_state.dart';
import '../../teams/bloc/team_bloc.dart';
import '../../teams/bloc/team_event.dart';
import '../../teams/bloc/team_state.dart';

/// Analytics dashboard — task status and priority charts.
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<TeamBloc>().add(LoadUserTeams(userId: authState.user.id));
        final teamState = context.read<TeamBloc>().state;
        if (teamState is TeamLoaded) {
          final ids = teamState.teams.map((t) => t.id).toList();
          context.read<TaskBloc>().add(
            LoadTasksForUserTeamsRequested(
              teamIds: ids,
              userId: authState.user.id,
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        centerTitle: true,
        actions: const [KapokLogo()],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final tasks = state is TasksLoaded ? state.tasks : <TaskModel>[];
          if (tasks.isEmpty) {
            return const Center(
              child: Text('No tasks yet — create some to see analytics.',
                  textAlign: TextAlign.center),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatusDonut(tasks),
              const SizedBox(height: 20),
              _buildPriorityBars(tasks),
            ],
          );
        },
      ),
    );
  }

  // ─── Status donut ─────────────────────────────────────────────

  Widget _buildStatusDonut(List<TaskModel> tasks) {
    final counts = {
      TaskStatus.pending: tasks.where((t) => t.status == TaskStatus.pending).length,
      TaskStatus.inProgress: tasks.where((t) => t.status == TaskStatus.inProgress).length,
      TaskStatus.completed: tasks.where((t) => t.status == TaskStatus.completed).length,
    };
    final colors = {
      TaskStatus.pending: Colors.grey.shade400,
      TaskStatus.inProgress: Colors.blue.shade400,
      TaskStatus.completed: Colors.green.shade500,
    };

    final sections = counts.entries
        .where((e) => e.value > 0)
        .map((e) => PieChartSectionData(
              value: e.value.toDouble(),
              color: colors[e.key]!,
              title: '${e.value}',
              radius: 55,
              titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status Distribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: counts.entries
                        .map((e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(width: 12, height: 12, decoration: BoxDecoration(color: colors[e.key], shape: BoxShape.circle)),
                                  const SizedBox(width: 6),
                                  Text(e.key.displayName, style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Priority bar chart ───────────────────────────────────────

  Widget _buildPriorityBars(List<TaskModel> tasks) {
    final counts = {
      TaskPriority.high: tasks.where((t) => t.priority == TaskPriority.high).length,
      TaskPriority.medium: tasks.where((t) => t.priority == TaskPriority.medium).length,
      TaskPriority.low: tasks.where((t) => t.priority == TaskPriority.low).length,
    };
    final colors = {
      TaskPriority.high: const Color(0xFFE53935),
      TaskPriority.medium: const Color(0xFFFFA000),
      TaskPriority.low: const Color(0xFF43A047),
    };
    final maxY = counts.values.fold(0, (a, b) => a > b ? a : b).toDouble() + 1;

    final groups = counts.entries.toList().asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: e.value.toDouble(),
            color: colors[e.key]!,
            width: 32,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tasks by Priority', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barGroups: groups,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10))),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final labels = ['High', 'Medium', 'Low'];
                          return Text(labels[v.toInt()], style: const TextStyle(fontSize: 11));
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
