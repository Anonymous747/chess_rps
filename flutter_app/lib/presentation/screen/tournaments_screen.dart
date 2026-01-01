import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/data/service/tournament/tournament_service.dart';
import 'package:chess_rps/presentation/utils/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TournamentsScreen extends HookConsumerWidget {
  static const routeName = '/tournaments';

  const TournamentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentService = TournamentService();
    final tournamentsAsync = useState<List<TournamentModel>>([]);
    final isLoading = useState(true);
    final selectedGameMode = useState<String?>(null); // "classical", "rps", or null for all
    final selectedStatus = useState<String?>(null); // "registration", "started", "finished", or null for all

    Future<void> loadTournaments() async {
      try {
        isLoading.value = true;
        final tournaments = await tournamentService.listTournaments(
          gameMode: selectedGameMode.value,
          statusFilter: selectedStatus.value,
        );
        tournamentsAsync.value = tournaments;
      } catch (e) {
        AppLogger.error('Failed to load tournaments: $e', tag: 'TournamentsScreen', error: e);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load tournaments: ${e.toString()}'),
              backgroundColor: Palette.error,
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    // Load tournaments on init
    useEffect(() {
      loadTournaments();
      return null;
    }, [selectedGameMode.value, selectedStatus.value]);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Palette.background,
              Palette.backgroundSecondary,
              Palette.backgroundTertiary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Palette.backgroundTertiary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Palette.glassBorder,
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Palette.textPrimary),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tournaments',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Palette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Compete and climb the rankings',
                            style: TextStyle(
                              fontSize: 14,
                              color: Palette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Palette.backgroundTertiary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Palette.glassBorder,
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Palette.accent),
                        onPressed: () {
                          context.push(AppRoutes.tournamentCreate);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Filters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Game mode filter
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Palette.backgroundTertiary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Palette.glassBorder),
                        ),
                        child: DropdownButton<String>(
                          value: selectedGameMode.value,
                          hint: Text('All Modes', style: TextStyle(color: Palette.textSecondary)),
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: Palette.backgroundElevated,
                          style: TextStyle(color: Palette.textPrimary),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All Modes')),
                            const DropdownMenuItem(value: 'classical', child: Text('Classical')),
                            const DropdownMenuItem(value: 'rps', child: Text('RPS')),
                          ],
                          onChanged: (value) {
                            selectedGameMode.value = value;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Status filter
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Palette.backgroundTertiary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Palette.glassBorder),
                        ),
                        child: DropdownButton<String>(
                          value: selectedStatus.value,
                          hint: Text('All Status', style: TextStyle(color: Palette.textSecondary)),
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: Palette.backgroundElevated,
                          style: TextStyle(color: Palette.textPrimary),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All Status')),
                            const DropdownMenuItem(value: 'registration', child: Text('Registration')),
                            const DropdownMenuItem(value: 'started', child: Text('In Progress')),
                            const DropdownMenuItem(value: 'finished', child: Text('Finished')),
                          ],
                          onChanged: (value) {
                            selectedStatus.value = value;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tournaments list
              Expanded(
                child: isLoading.value
                    ? Center(
                        child: CircularProgressIndicator(color: Palette.accent),
                      )
                    : tournamentsAsync.value.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.tour, size: 64, color: Palette.textSecondary),
                                const SizedBox(height: 16),
                                Text(
                                  'No tournaments found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Palette.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Create a new tournament to get started',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Palette.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: loadTournaments,
                            color: Palette.accent,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              itemCount: tournamentsAsync.value.length,
                              itemBuilder: (context, index) {
                                final tournament = tournamentsAsync.value[index];
                                return _buildTournamentCard(context, tournament, loadTournaments);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTournamentCard(
    BuildContext context,
    TournamentModel tournament,
    Future<void> Function() refreshCallback,
  ) {
    final gameModeColor = tournament.gameMode == 'classical'
        ? Palette.accent
        : Palette.purpleAccent;
    
    final statusColor = _getStatusColor(tournament.status);
    final statusText = _getStatusText(tournament.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Palette.backgroundElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gameModeColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: gameModeColor.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push('${AppRoutes.tournamentDetails}?id=${tournament.id}');
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tournament.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Palette.textPrimary,
                            ),
                          ),
                          if (tournament.description != null && tournament.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              tournament.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Palette.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoChip(
                      icon: Icons.sports_esports,
                      label: tournament.gameMode == 'classical' ? 'Classical' : 'RPS',
                      color: gameModeColor,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      icon: Icons.people,
                      label: '${tournament.participantCount ?? 0}/${tournament.maxParticipants}',
                      color: Palette.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      icon: Icons.format_list_bulleted,
                      label: _formatTournamentFormat(tournament.format),
                      color: Palette.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Palette.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      _formatDateRange(tournament.registrationStart, tournament.registrationEnd),
                      style: TextStyle(
                        fontSize: 12,
                        color: Palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Palette.backgroundTertiary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Palette.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'registration':
        return Palette.accent;
      case 'started':
        return Palette.purpleAccent;
      case 'finished':
        return Palette.textSecondary;
      case 'cancelled':
        return Palette.error;
      default:
        return Palette.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'registration':
        return 'Registration';
      case 'started':
        return 'In Progress';
      case 'finished':
        return 'Finished';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _formatTournamentFormat(String format) {
    switch (format) {
      case 'single_elimination':
        return 'Single Elim';
      case 'double_elimination':
        return 'Double Elim';
      case 'swiss':
        return 'Swiss';
      case 'round_robin':
        return 'Round Robin';
      default:
        return format;
    }
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final now = DateTime.now();
    if (end.isBefore(now)) {
      return 'Registration ended';
    } else if (start.isAfter(now)) {
      return 'Starts ${_formatRelativeDate(start)}';
    } else {
      return 'Ends ${_formatRelativeDate(end)}';
    }
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 0) {
      return 'in ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'soon';
    }
  }
}

