from django.db import models
from django.conf import settings
import json

class UserProfile(models.Model):
    GOAL_CHOICES = [
        ('strength', 'Ganho de Força'),
        ('hypertrophy', 'Hipertrofia'),
        ('weight_loss', 'Perda de Peso'),
        ('neural_strength', 'Força Neural'),
        ('endurance', 'Resistência'),
    ]
    
    EXPERIENCE_CHOICES = [
        ('beginner', 'Iniciante (0-6 meses)'),
        ('intermediate', 'Intermediário (6-24 meses)'),
        ('advanced', 'Avançado (2+ anos)'),
        ('expert', 'Expert/Atleta'),
    ]
    
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    primary_goal = models.CharField(max_length=20, choices=GOAL_CHOICES)
    experience_level = models.CharField(max_length=15, choices=EXPERIENCE_CHOICES)
    training_frequency = models.IntegerField(help_text="Dias por semana")
    available_equipment = models.JSONField(default=list)
    limitations = models.TextField(blank=True)
    preferences = models.JSONField(default=dict)
    last_anamnesis = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"Perfil IA - {self.user.username}"

class AIWorkoutRecommendation(models.Model):
    user_profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE)
    workout_data = models.JSONField()
    confidence_score = models.FloatField()
    generated_at = models.DateTimeField(auto_now_add=True)
    feedback_rating = models.IntegerField(null=True, blank=True)
    feedback_notes = models.TextField(blank=True)
    
    def __str__(self):
        return f"IA Recommendation - {self.user_profile.user.username}"