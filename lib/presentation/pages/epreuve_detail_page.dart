import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/notifiers/filiere_notifier.dart';
import '../../domain/entities/epreuve.dart';

class EpreuveDetailPage extends ConsumerWidget {
  final String epreuveId;

  const EpreuveDetailPage({super.key, required this.epreuveId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filieresAsync = ref.watch(filiereNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'épreuve'),
      ),
      body: filieresAsync.when(
        data: (filieres) {
          Epreuve? epreuve;
          String? filiereName;
          
          for (final f in filieres) {
            try {
              epreuve = f.epreuves.firstWhere((e) => e.id == epreuveId);
              filiereName = f.name;
              break;
            } catch (_) {}
          }

          if (epreuve == null) {
            return const Center(child: Text('Épreuve non trouvée'));
          }

          final dateFormat = DateFormat('EEE d MMM yyyy', 'fr_FR');
          final timeFormat = DateFormat('HH:mm');

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  epreuve.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Filière: $filiereName',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoRow(context, Icons.calendar_today, 'Date', dateFormat.format(epreuve.date)),
                const SizedBox(height: 16),
                _buildInfoRow(context, Icons.access_time, 'Début', timeFormat.format(epreuve.startTime)),
                const SizedBox(height: 16),
                _buildInfoRow(context, Icons.access_time_filled, 'Fin', timeFormat.format(epreuve.endTime)),
                const SizedBox(height: 16),
                _buildInfoRow(context, Icons.timer, 'Durée', '${epreuve.duration.inHours}h ${epreuve.duration.inMinutes % 60}min'),
                
                const Spacer(),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ],
    );
  }
}
