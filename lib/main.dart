import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.righteousTextTheme(Theme.of(context).textTheme),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _scaleAnimationController;

  bool gridIsEnable = true;
  Duration duration = const Duration(milliseconds: 250);

  int squaresPerRow = 20;
  int squaresPerCol = 40;
  final fontStyle = const TextStyle(color: Colors.white, fontSize: 20);
  final randomGen = Random();

  var snake = [
    [0, 1],
    [0, 0]
  ];
  var food = [0, 2];
  var direction = 'up';
  var isPlaying = false;

  @override
  void initState() {
    _scaleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1,
      lowerBound: 1,
      upperBound: 1.65,
    );

    super.initState();
  }

  void startGame() {
    // Snake head
    snake = [
      [(squaresPerRow / 2).floor(), (squaresPerCol / 2).floor()]
    ];

    // Snake body
    snake.add([snake.first[0], snake.first[1] - 1]);

    generateFood();

    isPlaying = true;
    Timer.periodic(duration, (timer) {
      moveSnake();
      if (checkGameOver()) {
        timer.cancel();
        endGame();
      }
    });
  }

  void generateFood() {
    food = [randomGen.nextInt(squaresPerRow), randomGen.nextInt(squaresPerCol)];
  }

  void moveSnake() {
    setState(() {
      switch (direction) {
        case 'up':
          if (snake.first[1] <= 0) {
            snake.insert(0, [snake.first[0], squaresPerCol - 1]);
          } else {
            snake.insert(0, [snake.first[0], snake.first[1] - 1]);
          }
          break;
        case 'down':
          if (snake.first[1] >= squaresPerCol - 1) {
            snake.insert(0, [snake.first[0], 0]);
          } else {
            snake.insert(0, [snake.first[0], snake.first[1] + 1]);
          }
          break;
        case 'left':
          if (snake.first[0] <= 0) {
            snake.insert(0, [squaresPerRow - 1, snake.first[1]]);
          } else {
            snake.insert(0, [snake.first[0] - 1, snake.first[1]]);
          }
          break;
        case 'right':
          if (snake.first[0] >= squaresPerRow - 1) {
            snake.insert(0, [0, snake.first[1]]);
          } else {
            snake.insert(0, [snake.first[0] + 1, snake.first[1]]);
          }
          break;
        default:
      }

      if (snake.first[0] != food[0] || snake.first[1] != food[1]) {
        snake.removeLast();
      } else {
        _scaleAnimationController.forward().then((value) {
          _scaleAnimationController.reverse();
        });
        generateFood();
      }
    });
  }

  bool checkGameOver() {
    if (!isPlaying) return true;

    for (var i = 1; i < snake.length; i++) {
      if (snake[i][0] == snake.first[0] && snake[i][1] == snake.first[1]) {
        return true;
      }
    }

    return false;
  }

  void endGame() {
    isPlaying = false;
    _showGameOverScreen();
  }

  void _showGameOverScreen() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        actionsPadding: const EdgeInsets.all(8),
        title: const Text(
          'GAME OVER!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Text(
          'You\' score: ${snake.length - 2}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'CANCEL',
              style: TextStyle(
                color: Colors.grey.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              backgroundColor: Colors.green,
            ),
            onPressed: () {
              startGame();
              Navigator.pop(context);
            },
            child: Text(
              'PLAY AGAIN!',
              style: TextStyle(
                color: Colors.grey.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    var width = screenSize.width;
    if (height % 20 != 0) {
      squaresPerCol = ((height - (height % 20)) ~/ 20).toInt() - 6;
    } else {
      squaresPerCol = (height ~/ 20).toInt() - 6;
    }
    if (width % 20 != 0) {
      squaresPerRow = ((width - (width % 20)) ~/ 20).toInt();
    } else {
      squaresPerRow = (width ~/ 20).toInt();
    }
    return Scaffold(
      backgroundColor: const Color(0xFF040406),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (direction != 'up' && details.delta.dy > 0) {
                    direction = 'down';
                  } else if (direction != 'down' && details.delta.dy < 0) {
                    direction = 'up';
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (direction != 'left' && details.delta.dx > 0) {
                    direction = 'right';
                  } else if (direction != 'right' && details.delta.dx < 0) {
                    direction = 'left';
                  }
                },
                child: Stack(
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimationController,
                      child: Center(
                        child: Text(
                          '${snake.length - 2}',
                          style: TextStyle(
                            fontSize: 200,
                            color: Colors.white.withOpacity(
                                _scaleAnimationController.isAnimating
                                    ? 0.1
                                    : 0.075),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: squaresPerRow),
                      itemCount: squaresPerRow * squaresPerCol,
                      itemBuilder: (context, index) {
                        Color color;
                        var x = index % squaresPerRow;
                        var y = (index / squaresPerRow).floor();

                        bool isSnakeBody = false;
                        for (var pos in snake) {
                          if (pos[0] == x && pos[1] == y) {
                            isSnakeBody = true;
                            break;
                          }
                        }

                        if (snake.first[0] == x && snake.first[1] == y) {
                          color = Colors.green;
                        } else if (isSnakeBody) {
                          color = Colors.green.shade200;
                        } else if (food[0] == x && food[1] == y) {
                          color = Colors.red;
                        } else {
                          color = gridIsEnable
                              ? Colors.white.withOpacity(0.05)
                              : Colors.transparent;
                        }

                        return Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Tooltip(
                    message: isPlaying ? 'Stop game' : 'Start game',
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        backgroundColor: isPlaying ? Colors.red : Colors.green,
                      ),
                      onPressed: () {
                        if (isPlaying) {
                          isPlaying = false;
                        } else {
                          startGame();
                        }
                      },
                      child: Row(
                        children: [
                          const SizedBox(width: 4),
                          Icon(
                            isPlaying
                                ? Icons.stop_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isPlaying ? 'STOP' : 'PLAY',
                            style: fontStyle,
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: gridIsEnable ? 'Disable grid' : 'Enable grid',
                    onPressed: () =>
                        setState(() => gridIsEnable = !gridIsEnable),
                    icon: Icon(
                      gridIsEnable
                          ? Icons.grid_off_rounded
                          : Icons.grid_on_rounded,
                      color: Colors.white70,
                      size: 28,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
