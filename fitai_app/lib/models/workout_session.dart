class WorkoutSession {
  final String id;
  final String workoutId;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final SessionStatus status;
  final List<ExerciseSet> completedSets;
  final int totalRestTime;
  final double? userRating;
  final String? userNotes;
  final Map<String, dynamic> metrics;
  final List<String> photosUrls;

  WorkoutSession({
    required this.id,
    required this.workoutId,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.completedSets,
    this.totalRestTime = 0,
    this.userRating,
    this.userNotes,
    this.metrics = const {},
    this.photosUrls = const [],
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] ?? '',
      workoutId: json['workout_id'] ?? '',
      userId: json['user_id'] ?? '',
      startTime: json['start_time'] != null 
          ? DateTime.parse(json['start_time']) 
          : DateTime.now(),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      status: SessionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => SessionStatus.inProgress,
      ),
      completedSets: (json['completed_sets'] as List<dynamic>?)
          ?.map((e) => ExerciseSet.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      totalRestTime: json['total_rest_time'] ?? 0,
      userRating: json['user_rating']?.toDouble(),
      userNotes: json['user_notes'],
      metrics: Map<String, dynamic>.from(json['metrics'] ?? {}),
      photosUrls: List<String>.from(json['photos_urls'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workout_id': workoutId,
      'user_id': userId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'status': status.toString().split('.').last,
      'completed_sets': completedSets.map((e) => e.toJson()).toList(),
      'total_rest_time': totalRestTime,
      'user_rating': userRating,
      'user_notes': userNotes,
      'metrics': metrics,
      'photos_urls': photosUrls,
    };
  }

  Duration? get duration => endTime?.difference(startTime);
  
  bool get isCompleted => status == SessionStatus.completed;
  
  int get totalSetsCompleted => completedSets.length;
  
  int get totalRepsCompleted => completedSets.fold(0, (sum, set) => sum + set.actualReps);
  
  double get averageWeight {
    final setsWithWeight = completedSets.where((s) => s.weight != null);
    if (setsWithWeight.isEmpty) return 0.0;
    return setsWithWeight.fold(0.0, (sum, set) => sum + (set.weight ?? 0)) / setsWithWeight.length;
  }
}

enum SessionStatus {
  inProgress,
  paused,
  completed,
  cancelled
}

class ExerciseSet {
  final String exerciseId;
  final int setNumber;
  final int targetReps;
  final int actualReps;
  final double? weight;
  final String? weightUnit;
  final int? duration;
  final DateTime timestamp;
  final String? notes;
  final double? rpe;

  ExerciseSet({
    required this.exerciseId,
    required this.setNumber,
    required this.targetReps,
    required this.actualReps,
    this.weight,
    this.weightUnit,
    this.duration,
    required this.timestamp,
    this.notes,
    this.rpe,
  });

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      exerciseId: json['exercise_id'] ?? '',
      setNumber: json['set_number'] ?? 0,
      targetReps: json['target_reps'] ?? 0,
      actualReps: json['actual_reps'] ?? 0,
      weight: json['weight']?.toDouble(),
      weightUnit: json['weight_unit'],
      duration: json['duration'],
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      notes: json['notes'],
      rpe: json['rpe']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise_id': exerciseId,
      'set_number': setNumber,
      'target_reps': targetReps,
      'actual_reps': actualReps,
      'weight': weight,
      'weight_unit': weightUnit,
      'duration': duration,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'rpe': rpe,
    };
  }

  bool get isCompleted => actualReps >= targetReps;
  
  String get displayWeight => weight != null ? '$weight${weightUnit ?? 'kg'}' : '-';
}