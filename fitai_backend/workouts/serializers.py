from rest_framework import serializers
from .models import WorkoutTemplate, WorkoutExercise, UserWorkout
from exercises.serializers import ExerciseSerializer

class WorkoutExerciseSerializer(serializers.ModelSerializer):
    exercise = ExerciseSerializer(read_only=True)
    exercise_id = serializers.IntegerField(write_only=True)
    
    class Meta:
        model = WorkoutExercise
        fields = '__all__'

class WorkoutTemplateSerializer(serializers.ModelSerializer):
    exercises = WorkoutExerciseSerializer(source='workoutexercise_set', many=True, read_only=True)
    trainer_name = serializers.CharField(source='trainer.get_full_name', read_only=True)
    
    class Meta:
        model = WorkoutTemplate
        fields = '__all__'

class WorkoutTemplateCreateSerializer(serializers.ModelSerializer):
    exercises = WorkoutExerciseSerializer(many=True, write_only=True)
    
    class Meta:
        model = WorkoutTemplate
        fields = ['name', 'description', 'goal', 'difficulty', 'estimated_duration', 'exercises']
    
    def create(self, validated_data):
        exercises_data = validated_data.pop('exercises')
        validated_data['trainer'] = self.context['request'].user
        workout = WorkoutTemplate.objects.create(**validated_data)
        
        for exercise_data in exercises_data:
            WorkoutExercise.objects.create(workout_template=workout, **exercise_data)
        
        return workout

class UserWorkoutSerializer(serializers.ModelSerializer):
    workout_template = WorkoutTemplateSerializer(read_only=True)
    workout_template_id = serializers.IntegerField(write_only=True)
    
    class Meta:
        model = UserWorkout
        fields = '__all__'
        read_only_fields = ('user',)