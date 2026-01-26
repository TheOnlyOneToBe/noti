import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/notifiers/filiere_notifier.dart';
import '../../domain/entities/filiere.dart';

class FilieresPage extends ConsumerWidget {
  const FilieresPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filieresState = ref.watch(filiereNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Filières')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: filieresState.when(
        data: (filieres) {
          if (filieres.isEmpty) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                   const SizedBox(height: 16),
                   const Text('Aucune filière', style: TextStyle(fontSize: 18, color: Colors.grey)),
                   const SizedBox(height: 8),
                   FilledButton.tonal(
                      onPressed: () => _showAddEditDialog(context, ref),
                      child: const Text('Ajouter une filière'),
                   ),
                 ],
               ),
             );
          }
          
          return ListView.builder(
            itemCount: filieres.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final filiere = filieres[index];
              final epreuveCount = filiere.epreuves.length;
              final totalDuration = filiere.epreuves.fold(
                  Duration.zero, (prev, e) => prev + e.duration);

              return Card(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    context.go('/filieres/detail/${filiere.id}');
                  },
                  onLongPress: () {
                    _showContextMenu(context, ref, filiere);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          filiere.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              label: Text('$epreuveCount épreuves'),
                              avatar: const Icon(Icons.file_copy_outlined, size: 16),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(_formatDuration(totalDuration)),
                              avatar: const Icon(Icons.timer_outlined, size: 16),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }

  void _showContextMenu(BuildContext context, WidgetRef ref, Filiere filiere) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Modifier'),
            onTap: () {
              Navigator.pop(context);
              _showAddEditDialog(context, ref, filiere: filiere);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              try {
                await ref.read(filiereNotifierProvider.notifier).deleteFiliere(filiere.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filière supprimée')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, WidgetRef ref, {Filiere? filiere}) {
    final controller = TextEditingController(text: filiere?.name ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(filiere == null ? 'Nouvelle filière' : 'Modifier filière'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nom de la filière',
            hintText: 'Ex: Informatique',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              
              if (filiere == null) {
                ref.read(filiereNotifierProvider.notifier).addFiliere(controller.text.trim());
              } else {
                ref.read(filiereNotifierProvider.notifier).updateFiliere(filiere.id, controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h${minutes > 0 ? ' $minutes' : ''}';
    }
    return '${minutes}min';
  }
}
