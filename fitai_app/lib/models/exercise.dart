import 'workout.dart';

class Exercise {
  final String id;
  final String name;
  final String description;
  final List<String> instructions;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final ExerciseType type;
  final String category;
  final int sets;
  final int reps;
  final int? duration; // for time-based exercises
  final int restTimeSeconds;
  final double? weight; // suggested weight
  final String? weightUnit; // kg, lbs
  final List<String> equipment;
  final WorkoutDifficulty difficulty;
  final List<String> tips;
  final List<String> commonMistakes;
  final String? videoUrl;
  final String? thumbnailUrl;
  final List<String> alternatives; // alternative exercise IDs
  final Map<String, dynamic>? trackingData;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.instructions,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.type,
    required this.category,
    required this.sets,
    required this.reps,
    this.duration,
    required this.restTimeSeconds,
    this.weight,
    this.weightUnit,
    required this.equipment,
    required this.difficulty,
    required this.tips,
    required this.commonMistakes,
    this.videoUrl,
    this.thumbnailUrl,
    required this.alternatives,
    this.trackingData,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      instructions: List<String>.from(json['instructions']),
      primaryMuscles: List<String>.from(json['primary_muscles']),
      secondaryMuscles: List<String>.from(json['secondary_muscles']),
      type: ExerciseType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ExerciseType.strength,
      ),
      category: json['category'],
      sets: json['sets'],
      reps: json['reps'],
      duration: json['duration'],
      restTimeSeconds: json['rest_time_seconds'],
      weight: json['weight']?.toDouble(),
      weightUnit: json['weight_unit'],
      equipment: List<String>.from(json['equipment']),
      difficulty: WorkoutDifficulty.values.firstWhere(
        (e) => e.toString().split('.').last == json['difficulty'],
        orElse: () => WorkoutDifficulty.beginner,
      ),
      tips: List<String>.from(json['tips'] ?? []),
      commonMistakes: List<String>.from(json['common_mistakes'] ?? []),
      videoUrl: json['video_url'],
      thumbnailUrl: json['thumbnail_url'],
      alternatives: List<String>.from(json['alternatives'] ?? []),
      trackingData: json['tracking_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'instructions': instructions,
      'primary_muscles': primaryMuscles,
      'secondary_muscles': secondaryMuscles,
      'type': type.toString().split('.').last,
      'category': category,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'rest_time_seconds': restTimeSeconds,
      'weight': weight,
      'weight_unit': weightUnit,
      'equipment': equipment,
      'difficulty': difficulty.toString().split('.').last,
      'tips': tips,
      'common_mistakes': commonMistakes,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'alternatives': alternatives,
      'tracking_data': trackingData,
    };
  }

  bool get isTimeBasedExercise => duration != null && duration! > 0;
  
  String get formattedRestTime {
    final minutes = restTimeSeconds ~/ 60;
    final seconds = restTimeSeconds % 60;
    if (minutes > 0) {
      return '${minutes}min ${seconds}s';
    }
    return '${seconds}s';
  }
  
  String get difficultyDisplayName {
    switch (difficulty) {
      case WorkoutDifficulty.beginner:
        return 'Iniciante';
      case WorkoutDifficulty.intermediate:
        return 'Intermediário';
      case WorkoutDifficulty.advanced:
        return 'Avançado';
      case WorkoutDifficulty.expert:
        return 'Expert';
    }
  }
}

enum ExerciseType {
  strength,
  cardio,
  flexibility,
  balance,
  plyometric,
  isometric,
  compound,
  isolation
}