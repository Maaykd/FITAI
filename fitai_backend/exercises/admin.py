from django.contrib import admin
from .models import Exercise, MuscleGroup

@admin.register(MuscleGroup)
class MuscleGroupAdmin(admin.ModelAdmin):
    list_display = ('name', 'description')
    search_fields = ('name',)

@admin.register(Exercise)
class ExerciseAdmin(admin.ModelAdmin):
    list_display = ('name', 'equipment', 'difficulty', 'is_neural_training', 'created_at')
    list_filter = ('equipment', 'difficulty', 'is_neural_training', 'muscle_groups')
    search_fields = ('name', 'description')
    filter_horizontal = ('muscle_groups',)
    
    fieldsets = (
        ('Informações Básicas', {
            'fields': ('name', 'description', 'muscle_groups')
        }),
        ('Configurações', {
            'fields': ('equipment', 'difficulty', 'is_neural_training')
        }),
        ('Instruções e Mídia', {
            'fields': ('instructions', 'video_url', 'image')
        }),
    )