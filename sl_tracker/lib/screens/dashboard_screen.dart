import 'package:flutter/material.dart';
import 'session_note_screen.dart';
import 'settings_screen.dart'; // Le nouveau fichier qu'on va créer

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PageController _pageController = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: GestureDetector(
          onTap: () {},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Bloc 1 - Semaine 1', 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.onSurface)),
              Icon(Icons.keyboard_arrow_down, color: theme.onSurface),
            ],
          ),
        ),
        actions: [
          // Bouton Paramètres en haut à droite
          IconButton(
            icon: Icon(Icons.settings, color: theme.onSurface),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: [
          const Center(child: Text("Swipe Gauche : Anciens Blocs")),
          _buildEmptyState(theme), // L'écran vierge
          const Center(child: Text("Swipe Droite : Nouveau Bloc")),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: theme.surface,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        elevation: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.emoji_events_outlined), 
              color: theme.primary,
              onPressed: () {},
            ),
            const SizedBox(width: 48),
            IconButton(
              icon: const Icon(Icons.timer_outlined), 
              color: theme.primary,
              onPressed: () {},
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.secondary,
        elevation: 2,
        child: Icon(Icons.add, color: theme.onSurface, size: 30),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SessionNoteScreen()),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // --- LE NOUVEL ÉTAT VIERGE ---
  Widget _buildEmptyState(ColorScheme theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_note, size: 80, color: theme.secondary),
            const SizedBox(height: 24),
            Text(
              "Aucune séance enregistrée",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.primary),
            ),
            const SizedBox(height: 12),
            Text(
              "Appuie sur le + pour créer ta première séance. N'oublie pas de configurer tes templates dans les paramètres.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: theme.onSurface.withOpacity(0.6), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}