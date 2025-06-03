from django.db import models
from django.conf import settings
from exercises.models import Exercise

class WorkoutTemplate(models.Model):
    GOAL_CHOICES = [
        ('strength', 'Força'),
        ('hypertrophy', 'Hipertrofia'),
        ('endurance', 'Resistência'),
        ('neural_strength', 'Força Neural'),
        ('weight_loss', 'Perda de Peso'),
    ]
    
    name = models.CharField(max_length=100)
    description = models.TextField()
    goal = models.CharField(max_length=20, choices=GOAL_CHOICES)
    difficulty = models.CharField(max_length=15, choices=[
        ('beginner', 'Iniciante'),
        ('intermediate', 'Intermediário'),
        ('advanced', 'Avançado'),
    ])
    estimated_duration = models.IntegerField(help_text="Duração em minutos")
    trainer = models.ForeignKey(
        settings.AUTH_USER_MODEL, 
        on_delete=models.CASCADE,
        limit_choices_to={'role': 'trainer'}
    )
    is_ai_generated = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.name} - {self.get_goal_display()}"

class WorkoutExercise(models.Model):
    workout_template = models.ForeignKey(WorkoutTemplate, on_delete=models.CASCADE)
    exercise = models.ForeignKey(Exercise, on_delete=models.CASCADE)
    sets = models.IntegerField()
    reps = models.CharField(max_length=20, help_text="Ex: 8-12 ou 30 segundos")
    rest_time = models.IntegerField(help_text="Descanso em segundos")
    load_percentage = models.FloatField(null=True, blank=True, help_text="% do 1RM")
    order = models.PositiveIntegerField()
    notes = models.TextField(blank=True)
    
    class Meta:
        ordering = ['order']
    
    def __str__(self):
        return f"{self.exercise.name} - {self.sets}x{self.reps}"

class UserWorkout(models.Model):
    STATUS_CHOICES = [
        ('scheduled', 'Agendado'),
        ('in_progress', 'Em Progresso'),
        ('completed', 'Concluído'),
        ('skipped', 'Pulado'),
    ]
    
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    workout_template = models.ForeignKey(WorkoutTemplate, on_delete=models.CASCADE)
    scheduled_date = models.DateTimeField()
    started_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    status = models.CharField(max_length=15, choices=STATUS_CHOICES, default='scheduled')
    notes = models.TextField(blank=True)
    
    def __str__(self):
        return f"{self.user.username} - {self.workout_template.name}"