import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Map<String, dynamic>> _templates = [];
  
  // Variables de configuration du bloc
  int _totalWeeks = 4;
  int _currentWeek = 1;
  List<int> _rpes = [7, 8, 9, 6];

  final Map<int, String> _jours = {
    1: 'Lundi', 2: 'Mardi', 3: 'Mercredi', 4: 'Jeudi', 5: 'Vendredi', 6: 'Samedi', 7: 'Dimanche'
  };

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final data = await DatabaseHelper.instance.getTemplates();
    final config = await DatabaseHelper.instance.getBlockConfig();
    
    setState(() {
      _templates = data;
      _totalWeeks = config['total_weeks'];
      _currentWeek = config['current_week'];
      _rpes = config['rpe_sequence'].split(',').map(int.parse).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Paramètres", style: TextStyle(color: theme.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- SECTION 1 : STRUCTURE DU BLOC ---
          Text("Structure du Bloc", style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Nombre de semaines :", style: TextStyle(fontWeight: FontWeight.w500)),
                DropdownButton<int>(
                  value: _totalWeeks,
                  items: [1, 2, 3, 4, 5, 6].map((e) => DropdownMenuItem(value: e, child: Text("$e"))).toList(),
                  onChanged: (val) async {
                    if (val == null) return;
                    setState(() => _totalWeeks = val);
                    await DatabaseHelper.instance.updateBlockConfig({'total_weeks': val});
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          // --- SECTION 2 : MES TEMPLATES ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Mes Templates", style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
              Text("${_templates.length} enregistrés", style: TextStyle(color: theme.onSurface.withValues(alpha: 0.5), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),

          if (_templates.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  "Aucun template configuré.\nAppuie sur + pour commencer.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.onSurface.withValues(alpha: 0.6)),
                ),
              ),
            )
          else
            // On utilise une Column ici car on est déjà dans une ListView
            Column(
              children: _templates.map((t) {
                final nomJour = _jours[t['day_of_week']];
                final rpeText = t['rpe'] != null ? "RPE ${t['rpe']}" : "Standard (tous RPE)";
                
                return Card(
                  color: theme.surface,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.secondary.withValues(alpha: 0.3)),
                  ),
                  child: ListTile(
                    title: Text("$nomJour", style: TextStyle(fontWeight: FontWeight.bold, color: theme.primary)),
                    subtitle: Text(rpeText, style: TextStyle(color: theme.onSurface.withValues(alpha: 0.7))),
                    trailing: Icon(Icons.edit, color: theme.secondary),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TemplateEditorScreen(day: t['day_of_week'], rpe: t['rpe']),
                        ),
                      );
                      _loadAllData();
                    },
                  ),
                );
              }).toList(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.secondary,
        child: Icon(Icons.add, color: theme.onSurface),
        onPressed: () => _showAddTemplateBottomSheet(context),
      ),
    );
  }

  void _showAddTemplateBottomSheet(BuildContext context) {
    int selectedDay = 1;
    int? selectedRpe;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context).colorScheme;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nouveau Template", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.onSurface)),
                  const SizedBox(height: 24),
                  Text("Jour de la semaine", style: TextStyle(color: theme.primary, fontWeight: FontWeight.w600)),
                  DropdownButton<int>(
                    value: selectedDay,
                    isExpanded: true,
                    dropdownColor: theme.surface,
                    items: _jours.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                    onChanged: (val) => setModalState(() => selectedDay = val!),
                  ),
                  const SizedBox(height: 16),
                  Text("RPE spécifique (Optionnel)", style: TextStyle(color: theme.primary, fontWeight: FontWeight.w600)),
                  DropdownButton<int?>(
                    value: selectedRpe,
                    isExpanded: true,
                    dropdownColor: theme.surface,
                    hint: const Text("Template standard"),
                    items: [
                      const DropdownMenuItem(value: null, child: Text("Template standard")),
                      ...List.generate(5, (index) => index + 6).map((rpe) => DropdownMenuItem(value: rpe, child: Text("RPE $rpe"))),
                    ],
                    onChanged: (val) => setModalState(() => selectedRpe = val),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TemplateEditorScreen(day: selectedDay, rpe: selectedRpe),
                          ),
                        ).then((_) => _loadAllData());
                      },
                      child: const Text("Rédiger le template", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }
}

// --- ÉCRAN D'ÉDITION DU TEMPLATE ---
class TemplateEditorScreen extends StatefulWidget {
  final int day;
  final int? rpe;

  const TemplateEditorScreen({super.key, required this.day, this.rpe});

  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen> {
  final TextEditingController _controller = TextEditingController();
  final Map<int, String> _jours = {
    1: 'Lundi', 2: 'Mardi', 3: 'Mercredi', 4: 'Jeudi', 5: 'Vendredi', 6: 'Samedi', 7: 'Dimanche'
  };

  @override
  void initState() {
    super.initState();
    _fetchExistingTemplate();
  }

  Future<void> _fetchExistingTemplate() async {
    final existing = await DatabaseHelper.instance.getTemplateForDayAndRpe(widget.day, widget.rpe);
    if (existing != null) {
      _controller.text = existing['content'];
    }
  }

  Future<void> _saveTemplate() async {
    if (_controller.text.trim().isEmpty) return;

    await DatabaseHelper.instance.insertTemplate({
      'day_of_week': widget.day,
      'rpe': widget.rpe,
      'content': _controller.text,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Template sauvegardé !"), backgroundColor: Color(0xFF6B8E23)),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final title = "${_jours[widget.day]} ${widget.rpe != null ? '(RPE ${widget.rpe})' : ''}";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: TextStyle(color: theme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, size: 28),
            onPressed: _saveTemplate,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _controller,
            autofocus: true,
            maxLines: null,
            expands: true,
            style: TextStyle(color: theme.onSurface, fontSize: 16, height: 1.5),
            decoration: const InputDecoration(
              hintText: "Rédige ton modèle ici...",
              hintStyle: TextStyle(color: Color(0xFF9A8F85)),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}