import 'exercise.dart';

class Workout {
  final String id;
  final String name;
  final String description;
  final WorkoutType type;
  final WorkoutDifficulty difficulty;
  final int estimatedDurationMinutes;
  final List<String> targetMuscleGroups;
  final List<String> requiredEquipment;
  final List<Exercise> exercises;
  final String? thumbnailUrl;
  final double rating;
  final int completionCount;
  final DateTime createdAt;
  final String? createdBy; // personal trainer ID
  final bool isPremium;
  final Map<String, dynamic>? aiPersonalization;

  Workout({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.estimatedDurationMinutes,
    required this.targetMuscleGroups,
    required this.requiredEquipment,
    required this.exercises,
    this.thumbnailUrl,
    this.rating = 0.0,
    this.completionCount = 0,
    required this.createdAt,
    this.createdBy,
    this.isPremium = false,
    this.aiPersonalization,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: WorkoutType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => WorkoutType.strength,
      ),
      difficulty: WorkoutDifficulty.values.firstWhere(
        (e) => e.toString().split('.').last == json['difficulty'],
        orElse: () => WorkoutDifficulty.beginner,
      ),
      estimatedDurationMinutes: json['estimated_duration_minutes'],
      targetMuscleGroups: List<String>.from(json['target_muscle_groups']),
      requiredEquipment: List<String>.from(json['required_equipment']),
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList(),
      thumbnailUrl: json['thumbnail_url'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      completionCount: json['completion_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      createdBy: json['created_by'],
      isPremium: json['is_premium'] ?? false,
      aiPersonalization: json['ai_personalization'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'difficulty': difficulty.toString().split('.').last,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'target_muscle_groups': targetMuscleGroups,
      'required_equipment': requiredEquipment,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'thumbnail_url': thumbnailUrl,
      'rating': rating,
      'completion_count': completionCount,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'is_premium': isPremium,
      'ai_personalization': aiPersonalization,
    };
  }

  int get totalSets => exercises.fold(0, (sum, exercise) => sum + exercise.sets);
  
  int get totalReps => exercises.fold(0, (sum, exercise) => sum + (exercise.reps * exercise.sets));
  
  List<String> get allMuscleGroups => exercises
      .expand((exercise) => exercise.primaryMuscles + exercise.secondaryMuscles)
      .toSet()
      .toList();
}

enum WorkoutType {
  strength,
  cardio,
  hiit,
  yoga,
  stretching,
  crossTraining,
  bodyweight,
  powerlifting,
  circuit,
  functional
}

enum WorkoutDifficulty {
  beginner,
  intermediate,
  advanced,
  expert
}