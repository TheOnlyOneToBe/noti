import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../application/notifiers/filiere_notifier.dart';
import '../../domain/entities/filiere.dart';

class FiliereDetailPage extends ConsumerStatefulWidget {
  final String filiereId;

  const FiliereDetailPage({super.key, required this.filiereId});

  @override
  ConsumerState<FiliereDetailPage> createState() => _FiliereDetailPageState();
}

class _FiliereDetailPageState extends ConsumerState<FiliereDetailPage> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _filterDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filieresAsync = ref.watch(filiereNotifierProvider);

    return filieresAsync.when(
      data: (filieres) {
        Filiere? filiere;
        try {
          filiere = filieres.firstWhere((f) => f.id == widget.filiereId);
        } catch (_) {
          // Fallback if deleted or not found
          return Scaffold(
            appBar: AppBar(title: const Text('Détails')),
            body: const Center(child: Text('Filière introuvable')),
          );
        }

        final filteredEpreuves = filiere.epreuves.where((e) {
          final query = _searchController.text.toLowerCase();
          final matchesName = e.name.toLowerCase().contains(query);
          
          if (_filterDate != null) {
            return matchesName && isSameDay(e.date, _filterDate!);
          }
          return matchesName;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(filiere.name),
            actions: [
               IconButton(
                 icon: Icon(_filterDate == null ? Icons.calendar_month_outlined : Icons.calendar_month),
                 onPressed: () async {
                   final picked = await showDatePicker(
                     context: context,
                     initialDate: _filterDate ?? DateTime.now(),
                     firstDate: DateTime(2020),
                     lastDate: DateTime(2030),
                   );
                   if (picked != null) {
                     setState(() {
                       _filterDate = picked;
                     });
                   } else if (_filterDate != null) {
                      // Option pour effacer le filtre si on annule ? Non, bouton dédié mieux.
                   }
                 },
                 tooltip: 'Filtrer par date',
               ),
               if (_filterDate != null)
                 IconButton(
                   icon: const Icon(Icons.clear),
                   onPressed: () => setState(() => _filterDate = null),
                   tooltip: 'Effacer la date',
                 ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher une épreuve...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
               context.go(
                  '/filieres/detail/${widget.filiereId}/add-epreuve',
                );
            },
            child: const Icon(Icons.add),
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
              : filteredEpreuves.isEmpty 
                  ? const Center(child: Text('Aucune épreuve trouvée.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredEpreuves.length,
                      itemBuilder: (context, index) {
                        final epreuve = filteredEpreuves[index];
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
                                  '/filieres/detail/${widget.filiereId}/add-epreuve',
                                  extra: epreuve,
                                );
                              },
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(
                                  epreuve.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(dateFormat.format(epreuve.date)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text('${timeFormat.format(epreuve.startTime)} - ${timeFormat.format(epreuve.endTime)}'),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.edit, color: Colors.blueGrey),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Erreur: $err'))),
    );
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }

    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
