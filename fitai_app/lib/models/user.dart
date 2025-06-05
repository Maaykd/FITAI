import 'package:flutter/material.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final DateTime createdAt;
  final UserPreferences preferences;
  final UserStats stats;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.createdAt,
    required this.preferences,
    required this.stats,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImageUrl: json['profile_image_url'],
      createdAt: DateTime.parse(json['created_at']),
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      stats: UserStats.fromJson(json['stats'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'preferences': preferences.toJson(),
      'stats': stats.toJson(),
    };
  }
}

class UserPreferences {
  final String fitnessLevel; // beginner, intermediate, advanced
  final List<String> fitnessGoals; // weight_loss, muscle_gain, endurance, etc.
  final int workoutFrequency; // times per week
  final int sessionDuration; // preferred duration in minutes
  final List<String> availableEquipment;
  final List<String> preferredMuscleGroups;
  final bool notificationsEnabled;
  final TimeOfDay? preferredWorkoutTime;

  UserPreferences({
    required this.fitnessLevel,
    required this.fitnessGoals,
    required this.workoutFrequency,
    required this.sessionDuration,
    required this.availableEquipment,
    required this.preferredMuscleGroups,
    this.notificationsEnabled = true,
    this.preferredWorkoutTime,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      fitnessLevel: json['fitness_level'] ?? 'beginner',
      fitnessGoals: List<String>.from(json['fitness_goals'] ?? []),
      workoutFrequency: json['workout_frequency'] ?? 3,
      sessionDuration: json['session_duration'] ?? 45,
      availableEquipment: List<String>.from(json['available_equipment'] ?? []),
      preferredMuscleGroups: List<String>.from(json['preferred_muscle_groups'] ?? []),
      notificationsEnabled: json['notifications_enabled'] ?? true,
      preferredWorkoutTime: json['preferred_workout_time'] != null 
          ? _timeFromString(json['preferred_workout_time']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fitness_level': fitnessLevel,
      'fitness_goals': fitnessGoals,
      'workout_frequency': workoutFrequency,
      'session_duration': sessionDuration,
      'available_equipment': availableEquipment,
      'preferred_muscle_groups': preferredMuscleGroups,
      'notifications_enabled': notificationsEnabled,
      'preferred_workout_time': preferredWorkoutTime?.format24Hour(),
    };
  }

  static TimeOfDay? _timeFromString(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length == 2) {
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    return null;
  }
}

class UserStats {
  final int totalWorkouts;
  final int totalMinutesExercised;
  final int currentStreak;
  final int longestStreak;
  final double averageWorkoutRating;
  final Map<String, int> muscleGroupsWorked;
  final DateTime? lastWorkoutDate;
  final List<WeeklyProgress> weeklyProgress;

  UserStats({
    this.totalWorkouts = 0,
    this.totalMinutesExercised = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.averageWorkoutRating = 0.0,
    this.muscleGroupsWorked = const {},
    this.lastWorkoutDate,
    this.weeklyProgress = const [],
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalWorkouts: json['total_workouts'] ?? 0,
      totalMinutesExercised: json['total_minutes_exercised'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      averageWorkoutRating: (json['average_workout_rating'] ?? 0.0).toDouble(),
      muscleGroupsWorked: Map<String, int>.from(json['muscle_groups_worked'] ?? {}),
      lastWorkoutDate: json['last_workout_date'] != null 
          ? DateTime.parse(json['last_workout_date']) 
          : null,
      weeklyProgress: (json['weekly_progress'] as List<dynamic>?)
          ?.map((e) => WeeklyProgress.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_workouts': totalWorkouts,
      'total_minutes_exercised': totalMinutesExercised,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'average_workout_rating': averageWorkoutRating,
      'muscle_groups_worked': muscleGroupsWorked,
      'last_workout_date': lastWorkoutDate?.toIso8601String(),
      'weekly_progress': weeklyProgress.map((e) => e.toJson()).toList(),
    };
  }
}

class WeeklyProgress {
  final DateTime weekStart;
  final int workoutsCompleted;
  final int totalMinutes;
  final double averageRating;

  WeeklyProgress({
    required this.weekStart,
    required this.workoutsCompleted,
    required this.totalMinutes,
    required this.averageRating,
  });

  factory WeeklyProgress.fromJson(Map<String, dynamic> json) {
    return WeeklyProgress(
      weekStart: DateTime.parse(json['week_start']),
      workoutsCompleted: json['workouts_completed'],
      totalMinutes: json['total_minutes'],
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week_start': weekStart.toIso8601String(),
      'workouts_completed': workoutsCompleted,
      'total_minutes': totalMinutes,
      'average_rating': averageRating,
    };
  }
}

// Extensão para TimeOfDay
extension TimeOfDayExtension on TimeOfDay {
  String format24Hour() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}