from rest_framework import serializers
from .models import UserProfile, AIWorkoutRecommendation

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = '__all__'
        read_only_fields = ('user',)

class AIWorkoutRecommendationSerializer(serializers.ModelSerializer):
    class Meta:
        model = AIWorkoutRecommendation
        fields = '__all__'
        read_only_fields = ('user_profile', 'generated_at')

class AnamneseSerializer(serializers.Serializer):
    primary_goal = serializers.ChoiceField(choices=UserProfile.GOAL_CHOICES)
    experience_level = serializers.ChoiceField(choices=UserProfile.EXPERIENCE_CHOICES)
    training_frequency = serializers.IntegerField(min_value=1, max_value=7)
    available_equipment = serializers.ListField(child=serializers.CharField())
    limitations = serializers.CharField(allow_blank=True)
    
    def validate_training_frequency(self, value):
        if value < 1 or value > 7:
            raise serializers.ValidationError("Frequência deve ser entre 1 e 7 dias por semana")
        return value