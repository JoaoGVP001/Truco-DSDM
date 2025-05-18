import 'package:flutter/material.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() {
  runApp(MarcadorTrucoApp());
}

class MarcadorTrucoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(), // Inicia com a splash em Dart
      debugShowCheckedModeBanner: false,
    );
  }
}

// ========================
// Splash Screen em Dart
// ========================
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 120),
            SizedBox(height: 20),
            Text(
              'Marcador de Truco',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class Player {
  String name;
  int points;
  int victories;
  Player({required this.name, this.points = 0, this.victories = 0});
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Player teamA = Player(name: 'Nós');
  Player teamB = Player(name: 'Eles');

  List<String> history = [];

  void addPoint(Player player) {
    if (player.points < 12) {
      setState(() {
        player.points++;
        history.add('${player.name}: +1 ponto');
        checkVictory(player);
        checkMaoDeOnze();
      });
    }
  }

  void subtractPoint(Player player) {
    if (player.points > 0) {
      setState(() {
        player.points--;
        history.add('${player.name}: -1 ponto');
      });
    }
  }

  void checkVictory(Player player) {
    if (player.points == 12) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('${player.name} venceu!'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  player.victories++;
                  teamA.points = 0;
                  teamB.points = 0;
                  history.clear();
                });
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void checkMaoDeOnze() {
    if (teamA.points == 11 && teamB.points == 11) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Mão de Onze!')));
    }
  }

  void renamePlayer(Player player) {
    final controller = TextEditingController(text: player.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Alterar nome'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => player.name = controller.text);
              Navigator.of(context).pop();
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void resetPoints() {
    setState(() {
      teamA.points = 0;
      teamB.points = 0;
      history.clear();
    });
  }

  void undoLastAction() {
    if (history.isEmpty) return;
    final last = history.removeLast();
    setState(() {
      if (last.contains('+1')) {
        if (last.startsWith(teamA.name)) teamA.points--;
        if (last.startsWith(teamB.name)) teamB.points--;
      } else if (last.contains('-1')) {
        if (last.startsWith(teamA.name)) teamA.points++;
        if (last.startsWith(teamB.name)) teamB.points++;
      }
    });
  }

  Widget buildPlayerColumn(Player player) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => renamePlayer(player),
            child: Text(player.name, style: TextStyle(fontSize: 24)),
          ),
          AnimatedFlipCounter(
            duration: Duration(milliseconds: 500),
            value: player.points,
            textStyle: TextStyle(fontSize: 40),
          ),
          Text('Vitórias: ${player.victories}'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => addPoint(player),
                icon: Icon(Icons.add),
              ),
              IconButton(
                onPressed: () => subtractPoint(player),
                icon: Icon(Icons.remove),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildHistoryList() {
    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return Slidable(
          key: ValueKey(item),
          endActionPane: ActionPane(
            motion: BehindMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => undoLastAction(),
                backgroundColor: Colors.red,
                icon: Icons.undo,
                label: 'Desfazer',
              ),
            ],
          ),
          child: ListTile(title: Text(item)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Marcador de Truco'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: resetPoints),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                buildPlayerColumn(teamA),
                VerticalDivider(),
                buildPlayerColumn(teamB),
              ],
            ),
          ),
          Divider(),
          Expanded(child: buildHistoryList()),
        ],
      ),
    );
  }
}
