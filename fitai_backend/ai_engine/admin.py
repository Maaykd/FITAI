from django.contrib import admin
from .models import UserProfile, AIWorkoutRecommendation

@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'primary_goal', 'experience_level', 'training_frequency', 'last_anamnesis')
    list_filter = ('primary_goal', 'experience_level', 'training_frequency')
    search_fields = ('user__username', 'user__email')
    
    fieldsets = (
        ('Usuário', {
            'fields': ('user',)
        }),
        ('Objetivos e Experiência', {
            'fields': ('primary_goal', 'experience_level', 'training_frequency')
        }),
        ('Equipamentos e Limitações', {
            'fields': ('available_equipment', 'limitations', 'preferences')
        }),
    )

@admin.register(AIWorkoutRecommendation)
class AIWorkoutRecommendationAdmin(admin.ModelAdmin):
    list_display = ('user_profile', 'confidence_score', 'generated_at', 'feedback_rating')
    list_filter = ('confidence_score', 'generated_at', 'feedback_rating')
    search_fields = ('user_profile__user__username',)
    readonly_fields = ('generated_at',)
    
    fieldsets = (
        ('Recomendação', {
            'fields': ('user_profile', 'workout_data', 'confidence_score', 'generated_at')
        }),
        ('Feedback', {
            'fields': ('feedback_rating', 'feedback_notes')
        }),
    )