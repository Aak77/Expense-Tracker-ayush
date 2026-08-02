import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/glass_styles.dart';
import '../../../core/utils/currency_format.dart';
import '../../../core/utils/parse_utils.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _goals = [];

  @override
  void initState() {
    super.initState();
    _fetchGoals();
  }

  Future<void> _fetchGoals() async {
    try {
      setState(() { _isLoading = true; _error = null; });
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.dio.get(ApiConstants.savingsGoals);
      
      if (mounted) {
        setState(() {
          _goals = List<Map<String, dynamic>>.from(response.data ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load goals';
          _isLoading = false;
        });
      }
    }
  }

  double get _totalTarget {
    return _goals.fold(0.0, (sum, g) => sum + parseDouble(g['target_amount']));
  }

  double get _totalSaved {
    return _goals.fold(0.0, (sum, g) => sum + parseDouble(g['current_amount']));
  }

  double get _totalProgress {
    if (_totalTarget <= 0) return 0.0;
    return (_totalSaved / _totalTarget).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        title: Text(
          'Savings Goals',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.outline, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _fetchGoals,
                        child: Text('Retry', style: GoogleFonts.inter(color: AppColors.primary)),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchGoals,
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      children: [
                        // Portfolio Overview
                        if (_goals.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: GlassStyles.glassCardDecoration.copyWith(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Total Saved',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppFormatters.formatINR(_totalSaved),
                                  style: GoogleFonts.inter(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Target: ${AppFormatters.formatINR(_totalTarget)}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      '${(_totalProgress * 100).toInt()}%',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: _totalProgress,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [AppColors.primary, AppColors.secondary],
                                          ),
                                          borderRadius: BorderRadius.circular(999),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.secondary.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Goals',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (_goals.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: GlassStyles.glassCardDecoration,
                            width: double.infinity,
                            child: Column(
                              children: [
                                const Icon(Icons.flag_outlined, color: AppColors.outline, size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  'No goals set',
                                  style: GoogleFonts.inter(
                                    color: AppColors.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap + to add a saving goal',
                                  style: GoogleFonts.inter(
                                    color: AppColors.outline,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...List.generate(_goals.length, (index) {
                            final g = _goals[index];
                            final name = g['goal_name']?.toString() ?? 'Goal';
                            final target = parseDouble(g['target_amount']);
                            final current = parseDouble(g['current_amount']);
                            final progress = parseDouble(g['progress_percentage']);
                            final daysRemaining = g['days_remaining'] as int?;
                            final isTrack = g['on_track'] as bool? ?? true;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GestureDetector(
                                onTap: () => _contributeToGoal(g),
                                child: _buildGoalCard(
                                  icon: Icons.home_work_outlined,
                                  title: name,
                                  status: isTrack ? 'On Track' : 'Falling Behind',
                                  statusColor: isTrack ? AppColors.secondary : AppColors.tertiary,
                                  saved: AppFormatters.formatINR(current),
                                  target: ' / ${AppFormatters.formatINR(target)}',
                                  percentage: progress,
                                  remainingTime: daysRemaining != null ? '$daysRemaining days left' : 'No deadline',
                                ),
                              ),
                            );
                          }),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 96),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () async {
              final result = await context.push('/goals/add');
              if (result == true) _fetchGoals();
            },
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            focusElevation: 0,
            hoverElevation: 0,
            highlightElevation: 0,
            shape: const CircleBorder(),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  Future<void> _contributeToGoal(Map<String, dynamic> goal) async {
    final controller = TextEditingController();
    final goalId = goal['id']?.toString();
    final currentAmount = parseDouble(goal['current_amount']);
    final goalName = goal['goal_name']?.toString() ?? 'Goal';

    final amount = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text('Contribute to $goalName', style: GoogleFonts.inter(color: AppColors.onSurface)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: GoogleFonts.inter(color: AppColors.onSurface),
          decoration: InputDecoration(
            prefixText: '₹ ',
            prefixStyle: GoogleFonts.inter(color: AppColors.secondary),
            hintText: 'Enter amount',
            hintStyle: GoogleFonts.inter(color: AppColors.outline),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.outline)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.outline)),
          ),
          TextButton(
            onPressed: () {
              final val = double.tryParse(controller.text.trim());
              Navigator.pop(context, val);
            },
            child: Text('Add', style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (amount != null && amount > 0 && goalId != null) {
      try {
        final apiClient = context.read<ApiClient>();
        await apiClient.dio.put(
          '${ApiConstants.savingsGoals}/$goalId',
          data: {'current_amount': currentAmount + amount},
        );
        _fetchGoals();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('₹${amount.toStringAsFixed(0)} added to $goalName!'),
              backgroundColor: AppColors.secondary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to contribute'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  Widget _buildGoalCard({
    required IconData icon,
    required String title,
    required String status,
    required Color statusColor,
    required String saved,
    required String target,
    required double percentage,
    required String remainingTime,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: GlassStyles.glassCardDecoration.copyWith(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: saved,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        TextSpan(
                          text: target,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${percentage.toInt()}%',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: (percentage / 100).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                remainingTime,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
