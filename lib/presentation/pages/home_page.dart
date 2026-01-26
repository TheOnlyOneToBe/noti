// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../application/notifiers/filiere_notifier.dart';
import '../../domain/entities/epreuve.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filieresState = ref.watch(filiereNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: filieresState.when(
        data: (filieres) {
          // Flatten epreuves
          List<Epreuve> allEpreuves = [];
          for (var f in filieres) {
            allEpreuves.addAll(f.epreuves);
          }
          allEpreuves.sort((a, b) => a.startTime.compareTo(b.startTime));

          // Find ongoing and upcoming
          final ongoing = allEpreuves.where((e) => e.status == ExamStatus.ongoing).toList();
          final upcoming = allEpreuves.where((e) => e.status == ExamStatus.upcoming).take(5).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
               Text(DateFormat('EEEE d MMMM', 'fr_FR').format(DateTime.now()).toUpperCase(), 
                 style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey)),
               const SizedBox(height: 8),
               Text("Tableau de bord", style: Theme.of(context).textTheme.headlineMedium),
               const SizedBox(height: 24),
               
               if (ongoing.isNotEmpty) ...[
                 Text("En cours", style: Theme.of(context).textTheme.titleLarge),
                 const SizedBox(height: 12),
                 ...ongoing.map((e) => _OngoingExamCard(
                   epreuve: e, 
                   filiereName: filieres.firstWhere((f) => f.id == e.filiereId).name
                 )),
                 const SizedBox(height: 32),
               ],
               
               Text("Prochaines épreuves", style: Theme.of(context).textTheme.titleLarge),
               const SizedBox(height: 12),
               if (upcoming.isEmpty)
                 Card(
                   elevation: 0,
                   color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                   child: const Padding(
                     padding: EdgeInsets.all(24),
                     child: Center(
                       child: Column(
                         children: [
                           Icon(Icons.event_available, size: 48, color: Colors.grey),
                           SizedBox(height: 16),
                           Text("Rien de prévu prochainement.", style: TextStyle(color: Colors.grey)),
                         ],
                       ),
                     ),
                   ),
                 )
               else
                 ...upcoming.map((e) => Card(
                   margin: const EdgeInsets.only(bottom: 12),
                   child: ListTile(
                     leading: Container(
                       padding: const EdgeInsets.all(8),
                       decoration: BoxDecoration(
                         color: Theme.of(context).colorScheme.primaryContainer,
                         borderRadius: BorderRadius.circular(8),
                       ),
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           Text(DateFormat('dd').format(e.date), style: const TextStyle(fontWeight: FontWeight.bold)),
                           Text(DateFormat('MMM', 'fr_FR').format(e.date).toUpperCase(), style: const TextStyle(fontSize: 10)),
                         ],
                       ),
                     ),
                     title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                     subtitle: Text('${filieres.firstWhere((f) => f.id == e.filiereId).name} • ${DateFormat('HH:mm').format(e.startTime)}'),
                     trailing: const Icon(Icons.chevron_right),
                   ),
                 )),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSelectFiliereDialog(context, ref),
        label: const Text('Ajouter une épreuve'),
        icon: const Icon(Icons.add_task),
      ),
    );
  }

  void _showSelectFiliereDialog(BuildContext context, WidgetRef ref) {
    ref.read(filiereNotifierProvider).whenData((filieres) {
      if (filieres.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez d\'abord créer une filière.')),
        );
        return;
      }
      showModalBottomSheet(
        context: context,
        builder: (ctx) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Choisir une filière', style: Theme.of(context).textTheme.titleLarge),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filieres.length,
                itemBuilder: (ctx, index) {
                  final f = filieres[index];
                  return ListTile(
                    title: Text(f.name),
                    onTap: () {
                      Navigator.pop(ctx);
                      context.go('/filieres/detail/${f.id}/add-epreuve');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _OngoingExamCard extends StatefulWidget {
  final Epreuve epreuve;
  final String filiereName;

  const _OngoingExamCard({required this.epreuve, required this.filiereName});

  @override
  State<_OngoingExamCard> createState() => _OngoingExamCardState();
}

class _OngoingExamCardState extends State<_OngoingExamCard> {
  late Timer _timer;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _updateProgress();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _updateProgress());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateProgress() {
    final now = DateTime.now();
    final total = widget.epreuve.duration.inMinutes;
    final elapsed = now.difference(widget.epreuve.startTime).inMinutes;
    
    setState(() {
      _progress = (elapsed / total).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.epreuve.name, 
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold
                    )
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('EN COURS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                )
              ],
            ),
            Text(widget.filiereName, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8))),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _progress, backgroundColor: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('HH:mm').format(widget.epreuve.startTime), style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(DateFormat('HH:mm').format(widget.epreuve.endTime), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
