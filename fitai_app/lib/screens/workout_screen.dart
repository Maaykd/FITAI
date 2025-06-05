import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/premium/glassmorphism_card.dart';

class WorkoutScreen extends StatefulWidget {
  final Map<String, dynamic> workout;

  const WorkoutScreen({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _timerController;
  late AnimationController _restController;
  late AnimationController _pulseController;
  late AnimationController _slideController;

  // Animations
  late Animation<double> _timerAnimation;
  late Animation<double> _restAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  // Workout State
  int currentExerciseIndex = 0;
  int currentSet = 1;
  int completedReps = 0;
  bool isResting = false;
  bool isWorkoutActive = false;
  int restTimeRemaining = 0;
  int workoutTimeElapsed = 0;

  // Timer
  DateTime? workoutStartTime;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startWorkoutTimer();
  }

  void _initializeAnimations() {
    // Timer Animation (spinning progress)
    _timerController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    _timerAnimation = Tween<double>(begin: 0, end: 1).animate(_timerController);

    // Rest Animation (countdown circle)
    _restController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );
    _restAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _restController, curve: Curves.linear),
    );

    // Pulse Animation (for active state)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Slide Animation (for exercise transitions)
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  void _startWorkoutTimer() {
    workoutStartTime = DateTime.now();
    isWorkoutActive = true;
    
    // Update elapsed time every second
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted && isWorkoutActive && !isResting) {
        setState(() {
          workoutTimeElapsed = DateTime.now().difference(workoutStartTime!).inSeconds;
        });
      }
    });
  }

  void _completeSet() {
    HapticFeedback.mediumImpact();
    
    final currentExercise = getCurrentExercise();
    final totalSets = currentExercise['sets'] as int;
    
    if (currentSet < totalSets) {
      _startRestPeriod();
    } else {
      _nextExercise();
    }
  }

  void _startRestPeriod() {
    setState(() {
      isResting = true;
      restTimeRemaining = getCurrentExercise()['restTime'] as int;
      currentSet++;
    });

    _restController.duration = Duration(seconds: restTimeRemaining);
    _restController.forward(from: 0);

    // Countdown timer
    Stream.periodic(const Duration(seconds: 1)).take(restTimeRemaining).listen(
      (tick) {
        if (mounted) {
          setState(() {
            restTimeRemaining--;
          });
        }
      },
    ).onDone(() {
      if (mounted) {
        _endRestPeriod();
      }
    });
  }

  void _endRestPeriod() {
    setState(() {
      isResting = false;
      completedReps = 0;
    });
    _restController.reset();
    HapticFeedback.lightImpact();
  }

  void _nextExercise() {
    if (currentExerciseIndex < getExercises().length - 1) {
      setState(() {
        currentExerciseIndex++;
        currentSet = 1;
        completedReps = 0;
      });
      _slideController.forward(from: 0);
    } else {
      _completeWorkout();
    }
  }

  void _completeWorkout() {
    setState(() {
      isWorkoutActive = false;
    });
    _showWorkoutCompleteDialog();
  }

  void _showWorkoutCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🎉 Treino Concluído!',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Parabéns! Você completou o treino em ${_formatDuration(workoutTimeElapsed)}',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildWorkoutStats(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Finalizar',
              style: TextStyle(color: Color(0xFF667EEA), fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutStats() {
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Exercícios', '${getExercises().length}', Icons.fitness_center),
            _buildStatItem('Tempo', _formatDuration(workoutTimeElapsed), Icons.timer),
            _buildStatItem('Séries', '${_getTotalSets()}', Icons.repeat),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF667EEA), size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Map<String, dynamic> getCurrentExercise() {
    return getExercises()[currentExerciseIndex];
  }

  List<Map<String, dynamic>> getExercises() {
    return widget.workout['exercises'] as List<Map<String, dynamic>>? ?? [
      {
        'name': 'Supino Reto',
        'sets': 4,
        'reps': 12,
        'restTime': 60,
        'instructions': 'Mantenha os pés firmes no chão e controle o movimento',
        'muscle': 'Peitoral',
        'difficulty': 'Intermediário'
      },
      {
        'name': 'Agachamento',
        'sets': 3,
        'reps': 15,
        'restTime': 45,
        'instructions': 'Mantenha o core ativado e desça até 90 graus',
        'muscle': 'Pernas',
        'difficulty': 'Básico'
      },
      {
        'name': 'Remada Curvada',
        'sets': 4,
        'reps': 10,
        'restTime': 60,
        'instructions': 'Puxe o peso em direção ao abdômen, contraindo as costas',
        'muscle': 'Costas',
        'difficulty': 'Intermediário'
      }
    ];
  }

  int _getTotalSets() {
    return getExercises().fold(0, (sum, exercise) => sum + (exercise['sets'] as int));
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timerController.dispose();
    _restController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF0f0f23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.workout['name'] ?? 'Treino Personalizado',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.pause, color: Colors.white),
            onPressed: () => _showPauseDialog(),
          ),
        ],
      ),
      body: isResting ? _buildRestScreen() : _buildWorkoutScreen(),
    );
  }

  Widget _buildWorkoutScreen() {
    final currentExercise = getCurrentExercise();
    final progress = (currentExerciseIndex + 1) / getExercises().length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress Bar
          _buildProgressBar(progress),
          const SizedBox(height: 24),

          // Current Exercise Card
          SlideTransition(
            position: _slideAnimation,
            child: _buildExerciseCard(currentExercise),
          ),
          const SizedBox(height: 24),

          // Set Counter
          _buildSetCounter(currentExercise),
          const SizedBox(height: 24),

          // Rep Counter
          _buildRepCounter(currentExercise),
          const SizedBox(height: 32),

          // Action Buttons
          _buildActionButtons(),
          const SizedBox(height: 24),

          // Timer Display
          _buildTimerDisplay(),
        ],
      ),
    );
  }

  Widget _buildRestScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Descanso',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            // Rest Timer Circle
            AnimatedBuilder(
              animation: _restAnimation,
              builder: (context, child) {
                return SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _restAnimation.value,
                        strokeWidth: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      Text(
                        '$restTimeRemaining',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            Text(
              'Próxima série: $currentSet/${getCurrentExercise()['sets']}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),

            TextButton(
              onPressed: _endRestPeriod,
              child: const Text(
                'Pular Descanso',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progresso do Treino',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${currentExerciseIndex + 1}/${getExercises().length}',
                  style: const TextStyle(
                    color: Color(0xFF667EEA),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
              minHeight: 6,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    exercise['muscle'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(exercise['difficulty']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    exercise['difficulty'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              exercise['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              exercise['instructions'],
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetCounter(Map<String, dynamic> exercise) {
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildCounterItem('Série', '$currentSet/${exercise['sets']}', Icons.repeat),
            Container(width: 1, height: 40, color: Colors.white24),
            _buildCounterItem('Meta', '${exercise['reps']} reps', Icons.flag),
          ],
        ),
      ),
    );
  }

  Widget _buildRepCounter(Map<String, dynamic> exercise) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isWorkoutActive ? _pulseAnimation.value : 1.0,
          child: GlassmorphismCard(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Text(
                    'Repetições',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: completedReps > 0 ? () {
                          setState(() => completedReps--);
                          HapticFeedback.lightImpact();
                        } : null,
                        icon: const Icon(Icons.remove_circle_outline, size: 32),
                        color: const Color(0xFF667EEA),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          '$completedReps',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF667EEA),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() => completedReps++);
                          HapticFeedback.lightImpact();
                        },
                        icon: const Icon(Icons.add_circle_outline, size: 32),
                        color: const Color(0xFF667EEA),
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
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: completedReps >= getCurrentExercise()['reps'] ? _completeSet : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              currentSet < getCurrentExercise()['sets'] ? 'Completar Série' : 'Próximo Exercício',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerDisplay() {
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _timerAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _timerAnimation.value * 2 * 3.14159,
                  child: const Icon(
                    Icons.timer,
                    color: Color(0xFF667EEA),
                    size: 24,
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            Text(
              'Tempo: ${_formatDuration(workoutTimeElapsed)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF667EEA), size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'básico':
        return Colors.green;
      case 'intermediário':
        return Colors.orange;
      case 'avançado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Pausar Treino', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Deseja pausar o treino atual?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuar', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Sair',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}