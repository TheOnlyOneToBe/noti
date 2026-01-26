import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../widgets/reminder_preview_widget.dart';
import '../../application/notifiers/filiere_notifier.dart';
import '../../domain/entities/epreuve.dart';

class AddEpreuvePage extends ConsumerStatefulWidget {
  final String filiereId;
  final Epreuve? epreuve;

  const AddEpreuvePage({
    super.key, 
    required this.filiereId,
    this.epreuve,
  });

  @override
  ConsumerState<AddEpreuvePage> createState() => _AddEpreuvePageState();
}

class _AddEpreuvePageState extends ConsumerState<AddEpreuvePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    if (widget.epreuve != null) {
      _nameController.text = widget.epreuve!.name;
      _selectedDate = widget.epreuve!.date;
      _startTime = TimeOfDay.fromDateTime(widget.epreuve!.startTime);
      _endTime = TimeOfDay.fromDateTime(widget.epreuve!.endTime);
    } else {
      _selectedDate = DateTime.now();
      _startTime = const TimeOfDay(hour: 8, minute: 0);
      _endTime = const TimeOfDay(hour: 10, minute: 0);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)), // Allow past dates for editing
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
          // Auto adjust end time if it's before start
          if (_endTime.hour < _startTime.hour || (_endTime.hour == _startTime.hour && _endTime.minute < _startTime.minute)) {
             final newHour = (_startTime.hour + 2) % 24;
             _endTime = TimeOfDay(hour: newHour, minute: _startTime.minute);
          }
        } else {
          _endTime = picked;
        }
      });
    }
  }

  DateTime _combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  @override
  Widget build(BuildContext context) {
    final startDateTime = _combineDateTime(_selectedDate, _startTime);
    final endDateTime = _combineDateTime(_selectedDate, _endTime);
    final dateFormat = DateFormat.yMMMMEEEEd('fr_FR');
    final isEditing = widget.epreuve != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier l\'épreuve' : 'Nouvelle Épreuve'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Nom de l'épreuve
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'épreuve',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 24),

              // 2. Date
              ListTile(
                title: const Text('Date de l\'épreuve'),
                subtitle: Text(dateFormat.format(_selectedDate)),
                leading: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),

              // 3. Heures (Start / End)
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Début'),
                      subtitle: Text(_startTime.format(context)),
                      leading: const Icon(Icons.access_time),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ListTile(
                      title: const Text('Fin'),
                      subtitle: Text(_endTime.format(context)),
                      leading: const Icon(Icons.access_time_filled),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 4. Aperçu des notifications (Reactive)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications_none, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          "Aperçu des rappels",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    ReminderPreviewWidget(
                      startTime: startDateTime,
                      endTime: endDateTime,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 5. Validation Button
              FilledButton.icon(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (endDateTime.isBefore(startDateTime)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('La fin doit être après le début')),
                      );
                      return;
                    }

                    if (isEditing) {
                      final updatedEpreuve = widget.epreuve!.copyWith(
                        name: _nameController.text,
                        date: _selectedDate,
                        startTime: startDateTime,
                        endTime: endDateTime,
                      );
                      await ref.read(filiereNotifierProvider.notifier).updateEpreuve(updatedEpreuve);
                    } else {
                      await ref.read(filiereNotifierProvider.notifier).addEpreuve(
                            widget.filiereId,
                            _nameController.text,
                            _selectedDate,
                            startDateTime,
                            endDateTime,
                          );
                    }
                    
                    if (context.mounted) {
                      context.pop();
                    }
                  }
                },
                icon: Icon(isEditing ? Icons.save : Icons.check),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(isEditing ? 'Enregistrer les modifications' : 'Planifier l\'épreuve'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
