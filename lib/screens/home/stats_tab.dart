import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/stats_service.dart';
import '../../main.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});
  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  UserModel? _user;
  int _totalSeconds = 0;
  Map<int, int>    _daily    = {};
  Map<String, int> _top      = {};
  int  _goalHours = 20;
  bool _loading   = true;

  static const _goalOptions = [10, 15, 20, 25, 30, 40, 50];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final goal  = prefs.getInt('monthly_goal_hours') ?? 20;
    final user  = await AuthService.getUserModel();
    final total = await StatsService.totalSecondsThisMonth();
    final daily = await StatsService.dailyMinutesThisMonth();
    final top   = await StatsService.topTracksThisMonth();
    if (!mounted) return;
    setState(() {
      _user = user; _totalSeconds = total;
      _daily = daily; _top = top; _goalHours = goal; _loading = false;
    });
  }

  Future<void> _setGoal(int h) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('monthly_goal_hours', h);
    setState(() => _goalHours = h);
  }

  String _fmt(int s) => '${s ~/ 3600}h ${(s % 3600) ~/ 60}min';
  double get _progress =>
      (_totalSeconds / (_goalHours * 3600)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(
        child: CircularProgressIndicator(color: AppColors.deepTeal));

    final month = DateFormat('MMMM yyyy').format(DateTime.now());

    return RefreshIndicator(
      color: AppColors.deepTeal,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome
            _Card(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome back,',
                    style: TextStyle(color: AppColors.deepTeal, fontSize: 14)),
                const SizedBox(height: 4),
                Text(_user?.fullName ?? 'User',
                    style: const TextStyle(color: AppColors.darkGreen,
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(children: [
                  const Icon(Icons.headphones,
                      color: AppColors.deepTeal, size: 20),
                  const SizedBox(width: 8),
                  Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('This month',
                        style: TextStyle(color: AppColors.deepTeal,
                            fontSize: 11)),
                    Text(_fmt(_totalSeconds),
                        style: const TextStyle(color: AppColors.darkGreen,
                            fontWeight: FontWeight.w700, fontSize: 16)),
                  ]),
                ]),
              ],
            )),
            const SizedBox(height: 14),

            // Goal
            _Card(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Monthly Goal',
                        style: TextStyle(color: AppColors.darkGreen,
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    DropdownButton<int>(
                      value: _goalHours,
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: AppColors.darkGreen),
                      underline: const SizedBox(),
                      items: _goalOptions.map((h) => DropdownMenuItem(
                          value: h,
                          child: Text('$h h',
                              style: const TextStyle(
                                  color: AppColors.darkGreen)))).toList(),
                      onChanged: (v) => v != null ? _setGoal(v) : null,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: AppColors.lightTeal.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation(AppColors.deepTeal),
                    minHeight: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text('${(_progress * 100).toStringAsFixed(1)}% of $_goalHours hours',
                    style: const TextStyle(
                        color: AppColors.deepTeal, fontSize: 13)),
              ],
            )),
            const SizedBox(height: 14),

            // Chart
            _Card(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily listening – $month',
                    style: const TextStyle(color: AppColors.darkGreen,
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 180,
                  child: _daily.isEmpty
                      ? const Center(child: Text('No data yet',
                          style: TextStyle(color: AppColors.deepTeal)))
                      : BarChart(BarChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (_) => FlLine(
                                color: AppColors.lightTeal.withOpacity(0.4),
                                strokeWidth: 1),
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                              showTitles: true, reservedSize: 28,
                              getTitlesWidget: (v, _) => Text('${v.toInt()}m',
                                  style: const TextStyle(
                                      color: AppColors.deepTeal,
                                      fontSize: 10)),
                            )),
                            bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) {
                                final d = v.toInt();
                                if (d % 5 != 0) return const SizedBox.shrink();
                                return Text('$d',
                                    style: const TextStyle(
                                        color: AppColors.deepTeal,
                                        fontSize: 10));
                              },
                            )),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          barGroups: _daily.entries.map((e) =>
                              BarChartGroupData(x: e.key, barRods: [
                                BarChartRodData(
                                  toY: e.value.toDouble(),
                                  color: e.key == DateTime.now().day
                                      ? AppColors.accent
                                      : AppColors.deepTeal,
                                  width: 6,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ])).toList(),
                        )),
                ),
              ],
            )),
            const SizedBox(height: 14),

            // Top tracks
            _Card(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Most Listened',
                    style: TextStyle(color: AppColors.darkGreen,
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                if (_top.isEmpty)
                  const Text('No listening activity yet.',
                      style: TextStyle(color: AppColors.deepTeal))
                else
                  ..._top.entries.toList().asMap().entries.map((e) {
                    final rank = e.key + 1;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(children: [
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: rank == 1
                                ? AppColors.accent.withOpacity(0.3)
                                : AppColors.lightTeal.withOpacity(0.3),
                          ),
                          child: Center(child: Text('$rank',
                              style: TextStyle(
                                color: rank == 1
                                    ? AppColors.darkGreen : AppColors.deepTeal,
                                fontWeight: FontWeight.bold, fontSize: 12))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(e.value.key,
                            style: const TextStyle(
                                color: AppColors.darkGreen, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)),
                        Text(_fmt(e.value.value),
                            style: const TextStyle(
                                color: AppColors.deepTeal, fontSize: 12)),
                      ]),
                    );
                  }),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(
        color: AppColors.deepTeal.withOpacity(0.07),
        blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: child,
  );
}
