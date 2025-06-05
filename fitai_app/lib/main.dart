import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'design_system/theme.dart';
import 'screens/home_screen.dart';
import 'screens/workout_screen.dart';
import 'services/workout_service.dart';

void main() {
  runApp(const FitAIApp());
}

class FitAIApp extends StatelessWidget {
  const FitAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configurar barra de status
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
      ],
      child: MaterialApp.router(
        title: 'FitAI - Personal Trainer com IA',
        theme: FitTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}

// CONFIGURAÇÃO DE ROTAS
final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Splash Screen
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Home Screen
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),

    // Workout Screen
    GoRoute(
      path: '/workout/:workoutId',
      name: 'workout',
      builder: (context, state) {
        final workoutId = state.pathParameters['workoutId']!;
        final workoutData = state.extra as Map<String, dynamic>? ?? {};
        
        return WorkoutScreen(
          workout: {
            'id': workoutId,
            'name': workoutData['name'] ?? 'Treino Personalizado',
            'exercises': workoutData['exercises'] ?? _getDefaultExercises(),
          },
        );
      },
    ),
  ],
);

// Exercícios padrão para demonstração
List<Map<String, dynamic>> _getDefaultExercises() {
  return [
    {
      'id': '1',
      'name': 'Supino Reto com Halteres',
      'sets': 4,
      'reps': 12,
      'restTime': 60,
      'instructions': 'Deite-se no banco, segure os halteres com os braços estendidos. Abaixe controladamente até sentir o alongamento no peitoral, depois empurre de volta à posição inicial.',
      'muscle': 'Peitoral',
      'difficulty': 'Intermediário',
      'tips': [
        'Mantenha os pés firmes no chão',
        'Controle o movimento na descida',
        'Expire ao empurrar o peso'
      ],
      'equipment': ['Halteres', 'Banco']
    },
    {
      'id': '2',
      'name': 'Agachamento Livre',
      'sets': 3,
      'reps': 15,
      'restTime': 45,
      'instructions': 'Fique em pé com os pés na largura dos ombros. Desça como se fosse sentar em uma cadeira, mantendo o peito erguido e os joelhos alinhados com os pés.',
      'muscle': 'Pernas',
      'difficulty': 'Básico',
      'tips': [
        'Mantenha o core ativado',
        'Desça até 90 graus se possível',
        'Olhe para frente durante o movimento'
      ],
      'equipment': []
    },
    {
      'id': '3',
      'name': 'Remada Curvada',
      'sets': 4,
      'reps': 10,
      'restTime': 60,
      'instructions': 'Incline o tronco para frente, segure a barra com as mãos na largura dos ombros. Puxe a barra em direção ao abdômen, contraindo as costas.',
      'muscle': 'Costas',
      'difficulty': 'Intermediário',
      'tips': [
        'Mantenha as costas retas',
        'Puxe os cotovelos para trás',
        'Contraia as escápulas no topo'
      ],
      'equipment': ['Barra', 'Anilhas']
    },
    {
      'id': '4',
      'name': 'Desenvolvimento com Halteres',
      'sets': 3,
      'reps': 12,
      'restTime': 50,
      'instructions': 'Sentado ou em pé, segure os halteres na altura dos ombros. Empurre os pesos para cima até os braços ficarem estendidos, depois retorne controladamente.',
      'muscle': 'Ombros',
      'difficulty': 'Intermediário',
      'tips': [
        'Não arqueie as costas excessivamente',
        'Empurre os pesos em linha reta',
        'Controle a descida'
      ],
      'equipment': ['Halteres']
    },
    {
      'id': '5',
      'name': 'Prancha Isométrica',
      'sets': 3,
      'reps': 1,
      'restTime': 30,
      'duration': 45, // 45 segundos
      'instructions': 'Posicione-se em prancha com os antebraços no chão. Mantenha o corpo alinhado da cabeça aos pés, contraindo o core.',
      'muscle': 'Core',
      'difficulty': 'Básico',
      'tips': [
        'Mantenha o corpo reto',
        'Respire normalmente',
        'Contraia o abdômen constantemente'
      ],
      'equipment': []
    }
  ];
}

// SPLASH SCREEN
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToHome();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    // Iniciar animações
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _textController.forward();
      }
    });
  }

  void _navigateToHome() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
              Color(0xFF9B59B6),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Animado
              AnimatedBuilder(
                animation: _logoScale,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScale.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.white,
                            Color(0xFFFF6B35),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF764BA2).withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Texto Animado
              AnimatedBuilder(
                animation: _textOpacity,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textOpacity.value,
                    child: Column(
                      children: [
                        const Text(
                          'FitAI',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Seu Personal Trainer com IA',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 50),

              // Loading Indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}