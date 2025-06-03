from django.db import models

class MuscleGroup(models.Model):
    name = models.CharField(max_length=50, unique=True)
    description = models.TextField(blank=True)
    
    def __str__(self):
        return self.name

class Exercise(models.Model):
    DIFFICULTY_CHOICES = [
        ('beginner', 'Iniciante'),
        ('intermediate', 'Intermediário'),
        ('advanced', 'Avançado'),
        ('expert', 'Expert'),
    ]
    
    EQUIPMENT_CHOICES = [
        ('bodyweight', 'Peso Corporal'),
        ('dumbbell', 'Halter'),
        ('barbell', 'Barra'),
        ('machine', 'Máquina'),
        ('cable', 'Cabo'),
        ('kettlebell', 'Kettlebell'),
        ('resistance_band', 'Faixa Elástica'),
    ]
    
    name = models.CharField(max_length=100)
    description = models.TextField()
    muscle_groups = models.ManyToManyField(MuscleGroup, related_name='exercises')
    equipment = models.CharField(max_length=20, choices=EQUIPMENT_CHOICES)
    difficulty = models.CharField(max_length=15, choices=DIFFICULTY_CHOICES)
    instructions = models.TextField()
    video_url = models.URLField(blank=True)
    image = models.ImageField(upload_to='exercises/', blank=True)
    is_neural_training = models.BooleanField(default=False, help_text="Exercício para força neural")
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return self.name