import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../application/notifiers/filiere_notifier.dart';
import '../../domain/entities/filiere.dart';

class FiliereDetailPage extends ConsumerWidget {
  final String filiereId;

  const FiliereDetailPage({super.key, required this.filiereId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filieresAsync = ref.watch(filiereNotifierProvider);

    return filieresAsync.when(
      data: (filieres) {
        Filiere? filiere;
        try {
          filiere = filieres.firstWhere((f) => f.id == filiereId);
        } catch (_) {
          // Fallback if deleted or not found
          return Scaffold(
            appBar: AppBar(title: const Text('Détails')),
            body: const Center(child: Text('Filière introuvable')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(filiere.name),
          ),
          body: filiere.epreuves.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event_note, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Planifiez votre première épreuve',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filiere.epreuves.length,
                  itemBuilder: (context, index) {
                    final epreuve = filiere?.epreuves[index];
                    if (epreuve == null) return const SizedBox.shrink();
                    final dateFormat = DateFormat.yMMMMEEEEd('fr_FR');
                    final timeFormat = DateFormat.Hm('fr_FR');

                    return Dismissible(
                      key: Key(epreuve.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                         return await showDialog(
                           context: context,
                           builder: (ctx) => AlertDialog(
                             title: const Text('Confirmer'),
                             content: const Text('Supprimer cette épreuve ?'),
                             actions: [
                               TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Non')),
                               TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Oui')),
                             ],
                           ),
                         );
                      },
                      onDismissed: (_) {
                        ref.read(filiereNotifierProvider.notifier).deleteEpreuve(epreuve);
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        clipBehavior: Clip.antiAlias,
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            context.go(
                              '/filieres/detail/$filiereId/add-epreuve',
                              extra: epreuve,
                            );
                          },
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              epreuve.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: const Icon(Icons.edit, color: Colors.blueGrey),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(dateFormat.format(epreuve.date)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(
                                      "${timeFormat.format(epreuve.startTime)} - ${timeFormat.format(epreuve.endTime)} (${epreuve.duration.inHours}h${epreuve.duration.inMinutes.remainder(60) > 0 ? ' ${epreuve.duration.inMinutes.remainder(60)}min' : ''})",
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.go('/filieres/detail/$filiereId/add-epreuve'),
            label: const Text('Ajouter une épreuve'),
            icon: const Icon(Icons.add_alarm),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Erreur: $err'))),
    );
  }
}
