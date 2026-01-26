import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/notifiers/filiere_notifier.dart';
import '../../domain/entities/epreuve.dart';
import '../../domain/entities/filiere.dart';
import 'add_epreuve_page.dart';

class EpreuvesPage extends ConsumerStatefulWidget {
  const EpreuvesPage({super.key});

  @override
  ConsumerState<EpreuvesPage> createState() => _EpreuvesPageState();
}

class _EpreuvesPageState extends ConsumerState<EpreuvesPage> {
  final TextEditingController _searchController = TextEditingController();
  
  // Filters
  DateTime? _filterDate;
  DateTimeRange? _filterDateRange;
  String? _filterFiliereId;
  ExamStatus? _filterStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _filterDate = null;
      _filterDateRange = null;
      _filterFiliereId = null;
      _filterStatus = null;
    });
  }

  void _showFilterSheet(List<Filiere> filieres) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Filtres', style: Theme.of(context).textTheme.titleLarge),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                _filterDate = null;
                                _filterDateRange = null;
                                _filterFiliereId = null;
                                _filterStatus = null;
                              });
                              setState(() {});
                            },
                            child: const Text('Réinitialiser'),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      Text('Filière', style: Theme.of(context).textTheme.titleMedium),
                      DropdownButtonFormField<String>(
                        initialValue: _filterFiliereId,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Toutes')),
                          ...filieres.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))),
                        ],
                        onChanged: (val) {
                          setModalState(() => _filterFiliereId = val);
                          setState(() => _filterFiliereId = val);
                        },
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 20),
                      Text('Statut', style: Theme.of(context).textTheme.titleMedium),
                      Wrap(
                        spacing: 8,
                        children: ExamStatus.values.map((status) {
                          final isSelected = _filterStatus == status;
                          return FilterChip(
                            label: Text(status.name.toUpperCase()),
                            selected: isSelected,
                            onSelected: (selected) {
                              setModalState(() => _filterStatus = selected ? status : null);
                              setState(() => _filterStatus = selected ? status : null);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Text('Date', style: Theme.of(context).textTheme.titleMedium),
                      ListTile(
                        title: Text(_filterDate == null 
                          ? 'Choisir une date précise' 
                          : DateFormat('dd/MM/yyyy').format(_filterDate!)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setModalState(() {
                              _filterDate = date;
                              _filterDateRange = null;
                            });
                            setState(() {
                              _filterDate = date;
                              _filterDateRange = null;
                            });
                          }
                        },
                      ),
                      ListTile(
                        title: Text(_filterDateRange == null 
                          ? 'Choisir une période' 
                          : '${DateFormat('dd/MM').format(_filterDateRange!.start)} - ${DateFormat('dd/MM').format(_filterDateRange!.end)}'),
                        trailing: const Icon(Icons.date_range),
                        onTap: () async {
                          final range = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (range != null) {
                            setModalState(() {
                              _filterDateRange = range;
                              _filterDate = null;
                            });
                            setState(() {
                              _filterDateRange = range;
                              _filterDate = null;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Appliquer'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filieresState = ref.watch(filiereNotifierProvider);

    return filieresState.when(
      data: (filieres) {
        // Flatten and filter
        List<Epreuve> allEpreuves = [];
        for (var f in filieres) {
          allEpreuves.addAll(f.epreuves);
        }

        // Apply filters
        var filtered = allEpreuves.where((e) {
          // Search Text
          if (_searchController.text.isNotEmpty) {
            final query = _searchController.text.toLowerCase();
            if (!e.name.toLowerCase().contains(query) && 
                !filieres.firstWhere((f) => f.id == e.filiereId).name.toLowerCase().contains(query)) {
              return false;
            }
          }
          // Filter Filiere
          if (_filterFiliereId != null && e.filiereId != _filterFiliereId) {
            return false;
          }
          // Filter Status
          if (_filterStatus != null && e.status != _filterStatus) {
            return false;
          }
          // Filter Date
          if (_filterDate != null) {
             if (!DateUtils.isSameDay(e.date, _filterDate)) return false;
          }
          // Filter Range
          if (_filterDateRange != null) {
            if (e.date.isBefore(_filterDateRange!.start) || e.date.isAfter(_filterDateRange!.end)) {
              return false;
            }
          }
          return true;
        }).toList();

        // Sort by date
        filtered.sort((a, b) => a.startTime.compareTo(b.startTime));

        // Group by date
        final Map<DateTime, List<Epreuve>> grouped = {};
        for (var e in filtered) {
          final dateKey = DateUtils.dateOnly(e.date);
          if (!grouped.containsKey(dateKey)) {
            grouped[dateKey] = [];
          }
          grouped[dateKey]!.add(e);
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text('Épreuves'),
                floating: true,
                pinned: true,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: SearchBar(
                            controller: _searchController,
                            hintText: 'Rechercher une épreuve...',
                            leading: const Icon(Icons.search),
                            onChanged: (_) => setState(() {}),
                            trailing: [
                              if (_searchController.text.isNotEmpty || _filterDate != null || _filterDateRange != null || _filterFiliereId != null || _filterStatus != null)
                                IconButton(
                                  icon: const Icon(Icons.clear),
                                  tooltip: 'Réinitialiser les filtres',
                                  onPressed: () {
                                    _resetFilters();
                                  },
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.filter_list),
                          onPressed: () => _showFilterSheet(filieres),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (filtered.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Aucune épreuve trouvée', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final date = grouped.keys.elementAt(index);
                      final exams = grouped[date]!;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date).toUpperCase(),
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...exams.map((e) {
                            final filiereName = filieres.firstWhere((f) => f.id == e.filiereId).name;
                            return Dismissible(
                              key: Key(e.id),
                              background: Container(
                                color: Colors.blue,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 20),
                                child: const Icon(Icons.edit, color: Colors.white),
                              ),
                              secondaryBackground: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              direction: DismissDirection.horizontal,
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  // Edit
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddEpreuvePage(
                                        filiereId: e.filiereId,
                                        epreuve: e,
                                      ),
                                    ),
                                  );
                                  return false;
                                } else {
                                  // Delete
                                  return await showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Confirmer'),
                                      content: const Text('Voulez-vous vraiment supprimer cette épreuve ?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Non')),
                                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Oui')),
                                      ],
                                    ),
                                  );
                                }
                              },
                              onDismissed: (direction) {
                                if (direction == DismissDirection.endToStart) {
                                  ref.read(filiereNotifierProvider.notifier).deleteEpreuve(e);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Épreuve supprimée')),
                                  );
                                }
                              },
                              child: Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: ListTile(
                                  title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(filiereName),
                                      Row(
                                        children: [
                                          Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Text('${DateFormat('HH:mm').format(e.startTime)} - ${DateFormat('HH:mm').format(e.endTime)}'),
                                          const SizedBox(width: 8),
                                          Icon(Icons.timer_outlined, size: 14, color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Text(_formatDuration(e.duration)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: _buildStatusChip(e.status),
                                  onLongPress: () {
                                     // Show context menu
                                     _showContextMenu(context, e, filiereName);
                                  },
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddEpreuvePage(
                                          filiereId: e.filiereId,
                                          epreuve: e,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                    childCount: grouped.keys.length,
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Erreur: $err'))),
    );
  }

  void _showContextMenu(BuildContext context, Epreuve e, String filiereName) {
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEpreuvePage(
                    filiereId: e.filiereId,
                    epreuve: e,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
               // Trigger delete confirmation again or just delete
               ref.read(filiereNotifierProvider.notifier).deleteEpreuve(e);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ExamStatus status) {
    Color color;
    String label;
    switch (status) {
      case ExamStatus.past:
        color = Colors.grey;
        label = 'Terminée';
        break;
      case ExamStatus.ongoing:
        color = Colors.green;
        label = 'En cours';
        break;
      case ExamStatus.upcoming:
        color = Colors.blue;
        label = 'À venir';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h${minutes > 0 ? '$minutes' : ''}';
    }
    return '${minutes}min';
  }
}
