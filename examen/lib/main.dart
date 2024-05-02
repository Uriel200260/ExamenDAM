import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La Colmena🐝',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: HiveGame(),
    );
  }
}

class HiveGame extends StatefulWidget {
  @override
  _HiveGameState createState() => _HiveGameState();
}

class _HiveGameState extends State<HiveGame> {
  late List<List<String>> board;
  late int playerHealth;
  late int queenRow;
  late int queenCol;
  late bool gameOver;
  late Set<int> revealedCells;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    setState(() {
      board = List.generate(5, (_) => List.filled(5, '🐝'));
      playerHealth = 7;
      gameOver = false;
      revealedCells = {};
      _placeBees();
    });
  }

  void _placeBees() {
    Random random = Random();
    // Place queen in a random non-corner cell
    queenRow = random.nextInt(3) + 1;
    queenCol = random.nextInt(3) + 1;
    board[queenRow][queenCol] = 'Reina 👑';

    // Place other bees randomly
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 5; col++) {
        if (board[row][col] != 'Reina 👑') {
          List<String> beeTypes = [
            'Larva',
            'Obrera',
            'Zangano'
          ]; // Larva, Worker, Drone
          int randIndex = random.nextInt(beeTypes.length);
          board[row][col] = beeTypes[randIndex];
        }
      }
    }
  }

  void _revealCell(int row, int col) {
    setState(() {
      if (!revealedCells.contains(row * 5 + col)) {
        revealedCells.add(row * 5 + col);
        String cellContent = board[row][col];
        switch (cellContent) {
          case 'Reina 👑':
            gameOver = true;
            _showGameOverDialog('¡Encontraste a la Reina!');
            break;
          case 'Larva':
            playerHealth -= 0;
            break;
          case 'Obrera':
            playerHealth -= 1;
            break;
          case 'Zangano':
            playerHealth -= 2;
            break;
        }
        if (playerHealth <= 0) {
          gameOver = true;
          _showGameOverDialog('¡Perdiste todos tus puntos de vida!');
        }
      }
    });
  }

  void _showGameOverDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Juego Terminado'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
              },
              child: Text('Jugar de Nuevo'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('La Colmena🐝'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Puntos de Vida: $playerHealth',
                  style: TextStyle(fontSize: 20.0),
                ),
                SizedBox(width: 10), // Espacio entre el texto y el botón
                ElevatedButton(
                  onPressed: startGame,
                  child: Text('Reiniciar Juego'),
                ),
              ],
            ),
            SizedBox(height: 2.0),
            GridView.builder(
              shrinkWrap: true,
              itemCount: 25,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 3, // Elimina el espacio entre las celdas en el eje principal
                crossAxisSpacing: 3, // Elimina el espacio entre las celdas en el eje secundario
              ),
              itemBuilder: (BuildContext context, int index) {
                int row = index ~/ 5;
                int col = index % 5;
                return GestureDetector(
                  onTap: () => gameOver ? null : _revealCell(row, col),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      color: revealedCells.contains(index)
                          ? Colors.white
                          : Colors.yellow,
                    ),
                    child: Center(
                      child: Text(
                        revealedCells.contains(index) ? board[row][col] : '🐝',
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
