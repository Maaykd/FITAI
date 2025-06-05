import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../models/workout_session.dart';
import '../models/user.dart';

class WorkoutService {
  static const String baseUrl = 'https://api.fitai.com'; // Substituir pela URL real
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  WorkoutService() : _dio = Dio() {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Adicionar token de autenticação
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Content-Type'] = 'application/json';
          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle token refresh if needed
          if (error.response?.statusCode == 401) {
            await _handleTokenRefresh();
            // Retry the request
            final retryResponse = await _dio.fetch(error.requestOptions);
            handler.resolve(retryResponse);
          } else {
            handler.next(error);
          }
        },
      ),
    );
  }

  Future<void> _handleTokenRefresh() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken != null) {
        final response = await _dio.post(
          '$baseUrl/auth/refresh/',
          data: {'refresh_token': refreshToken},
        );
        
        if (response.statusCode == 200) {
          final newToken = response.data['access_token'];
          await _storage.write(key: 'auth_token', value: newToken);
        }
      }
    } catch (e) {
      // Redirect to login if refresh fails
      await _storage.deleteAll();
    }
  }

  // WORKOUT MANAGEMENT
  
  /// Buscar treinos recomendados com base no perfil do usuário
  Future<List<Workout>> getRecommendedWorkouts({
    String? fitnessLevel,
    List<String>? targetMuscles,
    int? duration,
    List<String>? equipment,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/workouts/recommended/',
        queryParameters: {
          if (fitnessLevel != null) 'fitness_level': fitnessLevel,
          if (targetMuscles != null) 'target_muscles': targetMuscles.join(','),
          if (duration != null) 'duration': duration,
          if (equipment != null) 'equipment': equipment.join(','),
        },
      );

      final List<dynamic> workoutsJson = response.data['results'];
      return workoutsJson.map((json) => Workout.fromJson(json)).toList();
    } catch (e) {
      throw WorkoutServiceException('Erro ao buscar treinos recomendados: $e');
    }
  }

  /// Buscar treinos populares
  Future<List<Workout>> getPopularWorkouts({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '$baseUrl/workouts/popular/',
        queryParameters: {'limit': limit},
      );

      final List<dynamic> workoutsJson = response.data['results'];
      return workoutsJson.map((json) => Workout.fromJson(json)).toList();
    } catch (e) {
      throw WorkoutServiceException('Erro ao buscar treinos populares: $e');
    }
  }

  /// Gerar treino personalizado com IA
  Future<Workout> generateAIWorkout({
    required String fitnessLevel,
    required List<String> targetMuscles,
    required int duration,
    required List<String> equipment,
    String? specificGoal,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/ai/generate-workout/',
        data: {
          'fitness_level': fitnessLevel,
          'target_muscles': targetMuscles,
          'duration': duration,
          'equipment': equipment,
          'specific_goal': specificGoal,
          'preferences': preferences,
        },
      );

      return Workout.fromJson(response.data);
    } catch (e) {
      throw WorkoutServiceException('Erro ao gerar treino personalizado: $e');
    }
  }

  /// Buscar detalhes de um treino específico
  Future<Workout> getWorkoutDetails(String workoutId) async {
    try {
      final response = await _dio.get('$baseUrl/workouts/$workoutId/');
      return Workout.fromJson(response.data);
    } catch (e) {
      throw WorkoutServiceException('Erro ao buscar detalhes do treino: $e');
    }
  }

  // WORKOUT SESSION MANAGEMENT

  /// Iniciar nova sessão de treino
  Future<WorkoutSession> startWorkoutSession(String workoutId) async {
    try {
      final response = await _dio.post(
        '$baseUrl/workout-sessions/',
        data: {
          'workout_id': workoutId,
          'start_time': DateTime.now().toIso8601String(),
          'status': 'in_progress',
        },
      );

      return WorkoutSession.fromJson(response.data);
    } catch (e) {
      throw WorkoutServiceException('Erro ao iniciar sessão de treino: $e');
    }
  }

  /// Registrar série completada
  Future<void> logExerciseSet({
    required String sessionId,
    required String exerciseId,
    required int setNumber,
    required int targetReps,
    required int actualReps,
    double? weight,
    String? weightUnit,
    int? duration,
    double? rpe,
    String? notes,
  }) async {
    try {
      await _dio.post(
        '$baseUrl/workout-sessions/$sessionId/sets/',
        data: {
          'exercise_id': exerciseId,
          'set_number': setNumber,
          'target_reps': targetReps,
          'actual_reps': actualReps,
          'weight': weight,
          'weight_unit': weightUnit,
          'duration': duration,
          'rpe': rpe,
          'notes': notes,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw WorkoutServiceException('Erro ao registrar série: $e');
    }
  }

  /// Finalizar sessão de treino
  Future<WorkoutSession> completeWorkoutSession({
    required String sessionId,
    double? userRating,
    String? userNotes,
    List<String>? photosUrls,
  }) async {
    try {
      final response = await _dio.patch(
        '$baseUrl/workout-sessions/$sessionId/',
        data: {
          'end_time': DateTime.now().toIso8601String(),
          'status': 'completed',
          'user_rating': userRating,
          'user_notes': userNotes,
          'photos_urls': photosUrls,
        },
      );

      return WorkoutSession.fromJson(response.data);
    } catch (e) {
      throw WorkoutServiceException('Erro ao finalizar sessão: $e');
    }
  }

  /// Pausar sessão de treino
  Future<void> pauseWorkoutSession(String sessionId) async {
    try {
      await _dio.patch(
        '$baseUrl/workout-sessions/$sessionId/',
        data: {'status': 'paused'},
      );
    } catch (e) {
      throw WorkoutServiceException('Erro ao pausar sessão: $e');
    }
  }

  /// Cancelar sessão de treino
  Future<void> cancelWorkoutSession(String sessionId) async {
    try {
      await _dio.patch(
        '$baseUrl/workout-sessions/$sessionId/',
        data: {'status': 'cancelled'},
      );
    } catch (e) {
      throw WorkoutServiceException('Erro ao cancelar sessão: $e');
    }
  }

  // EXERCISE MANAGEMENT

  /// Buscar exercícios por categoria
  Future<List<Exercise>> getExercisesByCategory(String category) async {
    try {
      final response = await _dio.get(
        '$baseUrl/exercises/',
        queryParameters: {'category': category},
      );

      final List<dynamic> exercisesJson = response.data['results'];
      return exercisesJson.map((json) => Exercise.fromJson(json)).toList();
    } catch (e) {
      throw WorkoutServiceException('Erro ao buscar exercícios: $e');
    }
  }

  /// Buscar exercícios por grupo muscular
  Future<List<Exercise>> getExercisesByMuscleGroup(String muscleGroup) async {
    try {
      final response = await _dio.get(
        '$baseUrl/exercises/',
        queryParameters: {'muscle_group': muscleGroup},
      );

      final List<dynamic> exercisesJson = response.data['results'];
      return exercisesJson.map((json) => Exercise.fromJson(json)).toList();
    } catch (e) {
      throw WorkoutServiceException('Erro ao buscar exercícios: $e');
    }
  }

  /// Buscar exercícios alternativos
  Future<List<Exercise>> getAlternativeExercises(String exerciseId) async {
    try {
      final response = await _dio.get('$baseUrl/exercises/$exerciseId/alternatives/');
      
      final List<dynamic> exercisesJson = response.data['results'];
      return exercisesJson.map((json) => Exercise.fromJson(json)).toList();
    } catch (e) {
      throw WorkoutServiceException('Erro ao buscar exercícios alternativos: $e');
    }
  }

  // USER STATS AND PROGRESS

  /// Buscar histórico de treinos do usuário
  Future<List<WorkoutSession>> getUserWorkoutHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/user/workout-history/',
        queryParameters: {
          if (startDate != null) 'start_date': startDate.toIso8601String(),
          if (endDate != null) 'end_date': endDate.toIso8601String(),
          if (limit != null) 'limit': limit,
        },
      );

      final List<dynamic> sessionsJson = response.data['results'];
      return sessionsJson.map((json) => WorkoutSession.fromJson(json)).toList();
    } catch (e) {
      throw WorkoutServiceException('Erro ao buscar histórico: $e');
    }
  }

  /// Buscar estatísticas do usuário
  Future<UserStats> getUserStats() async {
    try {
      final response = await _dio.get('$baseUrl/user/stats/');
      return UserStats.fromJson(response.data);
    } catch (e) {
      throw WorkoutServiceException('Erro ao buscar estatísticas: $e');
    }
  }

  /// Atualizar progresso semanal
  Future<void> updateWeeklyProgress(WeeklyProgress progress) async {
    try {
      await _dio.post(
        '$baseUrl/user/weekly-progress/',
        data: progress.toJson(),
      );
    } catch (e) {
      throw WorkoutServiceException('Erro ao atualizar progresso: $e');
    }
  }

  // AI COACH FEATURES

  /// Obter feedback da IA sobre o treino
  Future<String> getAIWorkoutFeedback({
    required String sessionId,
    required Map<String, dynamic> performanceData,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/ai/workout-feedback/',
        data: {
          'session_id': sessionId,
          'performance_data': performanceData,
        },
      );

      return response.data['feedback'];
    } catch (e) {
      throw WorkoutServiceException('Erro ao obter feedback da IA: $e');
    }
  }

  /// Chat com personal trainer virtual
  Future<String> chatWithAITrainer({
    required String message,
    String? context,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/ai/chat/',
        data: {
          'message': message,
          'context': context,
        },
      );

      return response.data['response'];
    } catch (e) {
      throw WorkoutServiceException('Erro no chat com IA: $e');
    }
  }

  /// Obter dicas personalizadas
  Future<List<String>> getPersonalizedTips() async {
    try {
      final response = await _dio.get('$baseUrl/ai/personalized-tips/');
      return List<String>.from(response.data['tips']);
    } catch (e) {
      throw WorkoutServiceException('Erro ao buscar dicas: $e');
    }
  }

  // OFFLINE SUPPORT

  /// Salvar treino para uso offline
  Future<void> saveWorkoutOffline(Workout workout) async {
    try {
      final workoutJson = jsonEncode(workout.toJson());
      await _storage.write(key: 'offline_workout_${workout.id}', value: workoutJson);
    } catch (e) {
      throw WorkoutServiceException('Erro ao salvar treino offline: $e');
    }
  }

  /// Buscar treinos salvos offline
  Future<List<Workout>> getOfflineWorkouts() async {
    try {
      final allKeys = await _storage.readAll();
      final workoutKeys = allKeys.keys.where((key) => key.startsWith('offline_workout_'));
      
      final List<Workout> workouts = [];
      for (final key in workoutKeys) {
        final workoutJson = allKeys[key];
        if (workoutJson != null) {
          final workoutData = jsonDecode(workoutJson);
          workouts.add(Workout.fromJson(workoutData));
        }
      }
      
      return workouts;
    } catch (e) {
      throw WorkoutServiceException('Erro ao buscar treinos offline: $e');
    }
  }

  /// Sincronizar dados quando conectar
  Future<void> syncOfflineData() async {
    try {
      // Buscar sessões offline pendentes
      final allKeys = await _storage.readAll();
      final offlineSessionKeys = allKeys.keys.where((key) => key.startsWith('offline_session_'));
      
      for (final key in offlineSessionKeys) {
        final sessionJson = allKeys[key];
        if (sessionJson != null) {
          try {
            final sessionData = jsonDecode(sessionJson);
            await _dio.post('$baseUrl/workout-sessions/sync/', data: sessionData);
            await _storage.delete(key: key);
          } catch (e) {
            // Manter dados offline se falhar a sincronização
            debugPrint('Falha ao sincronizar sessão $key: $e');
          }
        }
      }
    } catch (e) {
      throw WorkoutServiceException('Erro ao sincronizar dados offline: $e');
    }
  }

  /// Salvar sessão offline (quando sem internet)
  Future<void> saveSessionOffline(WorkoutSession session) async {
    try {
      final sessionJson = jsonEncode(session.toJson());
      await _storage.write(
        key: 'offline_session_${session.id}', 
        value: sessionJson,
      );
    } catch (e) {
      throw WorkoutServiceException('Erro ao salvar sessão offline: $e');
    }
  }

  /// Limpar cache de treinos
  Future<void> clearWorkoutCache() async {
    try {
      final allKeys = await _storage.readAll();
      final cacheKeys = allKeys.keys.where((key) => 
        key.startsWith('cache_') || key.startsWith('offline_workout_'));
      
      for (final key in cacheKeys) {
        await _storage.delete(key: key);
      }
    } catch (e) {
      throw WorkoutServiceException('Erro ao limpar cache: $e');
    }
  }
}

// EXCEPTION HANDLING
class WorkoutServiceException implements Exception {
  final String message;
  
  WorkoutServiceException(this.message);
  
  @override
  String toString() => 'WorkoutServiceException: $message';
}

// WORKOUT PROVIDER (Estado global)
class WorkoutProvider extends ChangeNotifier {
  final WorkoutService _workoutService = WorkoutService();
  
  // Estado atual
  List<Workout> _recommendedWorkouts = [];
  List<Workout> _popularWorkouts = [];
  final List<Exercise> _exercises = [];
  WorkoutSession? _currentSession;
  UserStats? _userStats;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Workout> get recommendedWorkouts => _recommendedWorkouts;
  List<Workout> get popularWorkouts => _popularWorkouts;
  List<Exercise> get exercises => _exercises;
  WorkoutSession? get currentSession => _currentSession;
  UserStats? get userStats => _userStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // WORKOUT METHODS

  Future<void> loadRecommendedWorkouts({
    String? fitnessLevel,
    List<String>? targetMuscles,
    int? duration,
    List<String>? equipment,
  }) async {
    try {
      _setLoading(true);
      _recommendedWorkouts = await _workoutService.getRecommendedWorkouts(
        fitnessLevel: fitnessLevel,
        targetMuscles: targetMuscles,
        duration: duration,
        equipment: equipment,
      );
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadPopularWorkouts() async {
    try {
      _setLoading(true);
      _popularWorkouts = await _workoutService.getPopularWorkouts();
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<Workout?> generateAIWorkout({
    required String fitnessLevel,
    required List<String> targetMuscles,
    required int duration,
    required List<String> equipment,
    String? specificGoal,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      _setLoading(true);
      final workout = await _workoutService.generateAIWorkout(
        fitnessLevel: fitnessLevel,
        targetMuscles: targetMuscles,
        duration: duration,
        equipment: equipment,
        specificGoal: specificGoal,
        preferences: preferences,
      );
      _clearError();
      return workout;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // SESSION METHODS

  Future<bool> startWorkout(String workoutId) async {
    try {
      _setLoading(true);
      _currentSession = await _workoutService.startWorkoutSession(workoutId);
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> logSet({
    required String exerciseId,
    required int setNumber,
    required int targetReps,
    required int actualReps,
    double? weight,
    String? weightUnit,
    int? duration,
    double? rpe,
    String? notes,
  }) async {
    if (_currentSession == null) return false;

    try {
      await _workoutService.logExerciseSet(
        sessionId: _currentSession!.id,
        exerciseId: exerciseId,
        setNumber: setNumber,
        targetReps: targetReps,
        actualReps: actualReps,
        weight: weight,
        weightUnit: weightUnit,
        duration: duration,
        rpe: rpe,
        notes: notes,
      );

      // Atualizar sessão local
      final newSet = ExerciseSet(
        exerciseId: exerciseId,
        setNumber: setNumber,
        targetReps: targetReps,
        actualReps: actualReps,
        weight: weight,
        weightUnit: weightUnit,
        duration: duration,
        timestamp: DateTime.now(),
        notes: notes,
        rpe: rpe,
      );

      _currentSession = WorkoutSession(
        id: _currentSession!.id,
        workoutId: _currentSession!.workoutId,
        userId: _currentSession!.userId,
        startTime: _currentSession!.startTime,
        endTime: _currentSession!.endTime,
        status: _currentSession!.status,
        completedSets: [..._currentSession!.completedSets, newSet],
        totalRestTime: _currentSession!.totalRestTime,
        userRating: _currentSession!.userRating,
        userNotes: _currentSession!.userNotes,
        metrics: _currentSession!.metrics,
        photosUrls: _currentSession!.photosUrls,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> completeWorkout({
    double? userRating,
    String? userNotes,
    List<String>? photosUrls,
  }) async {
    if (_currentSession == null) return false;

    try {
      _setLoading(true);
      _currentSession = await _workoutService.completeWorkoutSession(
        sessionId: _currentSession!.id,
        userRating: userRating,
        userNotes: userNotes,
        photosUrls: photosUrls,
      );
      
      // Atualizar estatísticas
      await loadUserStats();
      
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> pauseWorkout() async {
    if (_currentSession == null) return;

    try {
      await _workoutService.pauseWorkoutSession(_currentSession!.id);
      // Atualizar estado local se necessário
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> cancelWorkout() async {
    if (_currentSession == null) return;

    try {
      await _workoutService.cancelWorkoutSession(_currentSession!.id);
      _currentSession = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // STATS METHODS

  Future<void> loadUserStats() async {
    try {
      _userStats = await _workoutService.getUserStats();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // AI METHODS

  Future<String?> getAIFeedback(Map<String, dynamic> performanceData) async {
    if (_currentSession == null) return null;

    try {
      return await _workoutService.getAIWorkoutFeedback(
        sessionId: _currentSession!.id,
        performanceData: performanceData,
      );
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<String?> chatWithAI(String message, {String? context}) async {
    try {
      return await _workoutService.chatWithAITrainer(
        message: message,
        context: context,
      );
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // HELPER METHODS

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearCurrentSession() {
    _currentSession = null;
    notifyListeners();
  }
// Método dispose removido - não é necessário quando só chama super.dispose()
}