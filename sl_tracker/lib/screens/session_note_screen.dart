import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class SessionNoteScreen extends StatefulWidget {
  const SessionNoteScreen({Key? key}) : super(key: key);

  @override
  State<SessionNoteScreen> createState() => _SessionNoteScreenState();
}

class _SessionNoteScreenState extends State<SessionNoteScreen> {
  late String todayDate;
  
  // 1. Le contrôleur qui va gérer le texte (vide ou pré-rempli)
  final TextEditingController _textController = TextEditingController();

  @override
void initState() {
  super.initState();
  
  // 1. Calcul de la date
  final now = DateTime.now();
  todayDate = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";

  // 2. Lancement du fetch intelligent
  _loadSmartTemplate(now);
}

// Nouvelle fonction de chargement
Future<void> _loadSmartTemplate(DateTime now) async {
  // Récupérer la config du bloc
  final config = await DatabaseHelper.instance.getBlockConfig();
  int currentWeek = config['current_week'];
  List<int> rpes = config['rpe_sequence'].split(',').map(int.parse).toList();
  
  // Récupérer le RPE de la semaine actuelle
  int currentRpe = rpes[currentWeek - 1];

  // Chercher le template pour [Jour d'aujourd'hui] + [RPE de la semaine]
  final template = await DatabaseHelper.instance.getTemplateForDayAndRpe(
    now.weekday, 
    currentRpe
  );

  if (template != null) {
    setState(() {
      _textController.text = template['content'];
    });
  }
}

  @override
  void dispose() {
    // 4. Toujours "nettoyer" un contrôleur quand on quitte la page pour libérer la RAM
    _textController.dispose();
    super.dispose();
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
        title: Text(
          "Séance du : $todayDate",
          style: TextStyle(color: theme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _textController, // 5. On connecte le contrôleur au TextField
            autofocus: true,
            maxLines: null,
            expands: true,
            keyboardType: TextInputType.multiline,
            style: TextStyle(color: theme.onSurface, fontSize: 16, height: 1.5),
            decoration: const InputDecoration(
              hintText: "Note tes séries ici...\nex: Dips 3x3 60kg",
              hintStyle: TextStyle(color: Color(0xFF9A8F85)),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}