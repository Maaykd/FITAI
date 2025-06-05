import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../design_system/colors.dart';
import '../design_system/typography.dart';
import '../widgets/premium/glassmorphism_card.dart';
import '../widgets/premium/workout_progress_ring.dart';
import '../widgets/premium/animated_background.dart';
import '../services/workout_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();

    // Carregar dados do provider (quando estiver disponível)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
        // Apenas tenta carregar se os métodos existirem
        if (workoutProvider.userStats == null) {
          // workoutProvider.loadUserStats(); // Ativar quando método existir
        }
      } catch (e) {
        // Provider ainda não configurado completamente
        debugPrint('WorkoutProvider ainda não disponível: $e');
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedFitnessBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 30),
                      _buildProgressOverview(),
                      const SizedBox(height: 25),
                      _buildQuickActions(),
                      const SizedBox(height: 25),
                      _buildTodaysWorkout(),
                      const SizedBox(height: 25),
                      _buildAIInsights(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final stats = workoutProvider.userStats;
        return GlassmorphismCard(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, Atleta! 💪',
                    style: FitTypography.displayMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stats != null && stats.currentStreak > 0 
                        ? 'Sequência de ${stats.currentStreak} dias! 🔥'
                        : 'Pronto para dominar hoje?',
                    style: FitTypography.bodyLarge.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressOverview() {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final stats = workoutProvider.userStats;
        
        return GlassmorphismCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progresso Hoje',
                style: FitTypography.headingMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildProgressItem(
                    'Treinos',
                    '${stats?.totalWorkouts ?? 0}',
                    'realizados',
                    (stats?.totalWorkouts ?? 0) / 100.0,
                    FitColors.energyOrange,
                    Icons.fitness_center,
                  ),
                  _buildProgressItem(
                    'Sequência',
                    '${stats?.currentStreak ?? 0}',
                    'dias',
                    (stats?.currentStreak ?? 0) / 30.0,
                    FitColors.energyOrange,
                    Icons.local_fire_department,
                  ),
                  _buildProgressItem(
                    'Tempo',
                    _formatMinutes(stats?.totalMinutesExercised ?? 0),
                    'exercitados',
                    (stats?.totalMinutesExercised ?? 0) / 1000.0,
                    FitColors.successGreen,
                    Icons.timer,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressItem(
    String label,
    String current,
    String subtitle,
    double progress,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        WorkoutProgressRing(
          progress: progress.clamp(0.0, 1.0),
          size: 80,
          strokeWidth: 6,
          primaryColor: color,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          current,
          style: FitTypography.metricValue.copyWith(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: FitTypography.metricLabel.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        Text(
          subtitle,
          style: FitTypography.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: FitTypography.headingMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Iniciar Treino',
                Icons.play_arrow,
                FitColors.energyGradient,
                () => _startWorkout(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'IA Coach',
                Icons.psychology,
                FitColors.neuralGradient,
                () => _openAICoach(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Gradient gradient,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: FitTypography.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysWorkout() {
    return GlassmorphismCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Treino de Hoje',
                style: FitTypography.headingMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: FitColors.successGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '45 min',
                  style: FitTypography.bodySmall.copyWith(
                    color: FitColors.successGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Treino de Peito e Tríceps',
            style: FitTypography.workoutTitle.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildExerciseItem('Supino Reto', '4 x 12', Icons.fitness_center),
          _buildExerciseItem('Supino Inclinado', '3 x 10', Icons.fitness_center),
          _buildExerciseItem('Crucifixo', '3 x 15', Icons.fitness_center),
          _buildExerciseItem('Tríceps Testa', '4 x 12', Icons.fitness_center),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: FitColors.energyOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Iniciar Treino',
                style: FitTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(String name, String reps, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: FitTypography.exerciseName.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          Text(
            reps,
            style: FitTypography.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsights() {
    return GlassmorphismCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: FitColors.neuralGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Insights da IA',
                style: FitTypography.headingMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎯 Recomendação do Dia',
                  style: FitTypography.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Consumer<WorkoutProvider>(
                  builder: (context, workoutProvider, child) {
                    final stats = workoutProvider.userStats;
                    String recommendation = 'Baseado no seu progresso, recomendo aumentar 5% na carga do supino e focar mais no descanso entre séries para maximizar ganhos.';
                    
                    if (stats != null) {
                      if (stats.currentStreak == 0) {
                        recommendation = 'É hora de retomar! Comece com um treino leve hoje para reativar seu corpo e mente. A consistência é mais importante que a intensidade.';
                      } else if (stats.currentStreak >= 7) {
                        recommendation = 'Parabéns pela sequência! Considere um dia de descanso ativo ou alongamento para permitir que seu corpo se recupere adequadamente.';
                      } else if (stats.totalWorkouts < 5) {
                        recommendation = 'Você está começando bem! Foque na execução correta dos movimentos antes de aumentar cargas. A técnica é fundamental.';
                      }
                    }
                    
                    return Text(
                      recommendation,
                      style: FitTypography.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // MÉTODOS DE AÇÃO INTEGRADOS - VERSÃO CORRIGIDA

  void _startWorkout() async {
    // Mostrar loading elegante
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Preparando seu treino...',
                style: FitTypography.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Simular carregamento da IA
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      Navigator.pop(context); // Fechar loading
      
      // Mostrar mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.fitness_center, color: Colors.white),
              SizedBox(width: 8),
              Text('Treino carregado! Vamos começar! 💪'),
            ],
          ),
          backgroundColor: FitColors.energyOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      
      // Navegar para tela de treino
      context.push('/workout/treino-do-dia');
    }
  }

  void _openAICoach() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone da IA
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: FitColors.neuralGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              
              // Título
              Text(
                'FitAI Coach 🤖',
                style: FitTypography.headingMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Descrição
              Text(
                'Seu personal trainer IA está evoluindo! Em breve teremos conversas inteligentes sobre fitness.',
                style: FitTypography.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Funcionalidades futuras
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 Em desenvolvimento:',
                      style: FitTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '🏋️ Treinos personalizados em tempo real\n📊 Análise avançada de progresso\n🍎 Dicas de nutrição inteligentes\n💬 Chat motivacional 24/7',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Botões
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Fechar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.rocket_launch, color: Colors.white),
                                SizedBox(width: 8),
                                Text('IA Coach chegando em breve! 🚀'),
                              ],
                            ),
                            backgroundColor: const Color(0xFF6366F1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Aguardar! 💪',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // HELPER METHODS

  String _formatMinutes(int totalMinutes) {
    if (totalMinutes < 60) {
      return '${totalMinutes}min';
    }
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours}h ${minutes}min';
  }
}
