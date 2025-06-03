from rest_framework import serializers
from .models import Exercise, MuscleGroup

class MuscleGroupSerializer(serializers.ModelSerializer):
    class Meta:
        model = MuscleGroup
        fields = '__all__'

class ExerciseSerializer(serializers.ModelSerializer):
    muscle_groups = MuscleGroupSerializer(many=True, read_only=True)
    muscle_group_names = serializers.StringRelatedField(source='muscle_groups', many=True, read_only=True)
    
    class Meta:
        model = Exercise
        fields = '__all__'
        
class ExerciseListSerializer(serializers.ModelSerializer):
    """Serializer simplificado para listagens"""
    muscle_groups = serializers.StringRelatedField(many=True, read_only=True)
    
    class Meta:
        model = Exercise
        fields = ['id', 'name', 'muscle_groups', 'equipment', 'difficulty', 'is_neural_training']