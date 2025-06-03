from django.contrib import admin
from .models import WorkoutTemplate, WorkoutExercise, UserWorkout

class WorkoutExerciseInline(admin.TabularInline):
    model = WorkoutExercise
    extra = 1
    fields = ('exercise', 'sets', 'reps', 'rest_time', 'load_percentage', 'order')

@admin.register(WorkoutTemplate)
class WorkoutTemplateAdmin(admin.ModelAdmin):
    list_display = ('name', 'goal', 'difficulty', 'trainer', 'estimated_duration', 'is_ai_generated')
    list_filter = ('goal', 'difficulty', 'is_ai_generated', 'trainer')
    search_fields = ('name', 'description')
    inlines = [WorkoutExerciseInline]
    
    fieldsets = (
        ('Informações do Treino', {
            'fields': ('name', 'description', 'goal', 'difficulty')
        }),
        ('Configurações', {
            'fields': ('estimated_duration', 'trainer', 'is_ai_generated')
        }),
    )

@admin.register(UserWorkout)
class UserWorkoutAdmin(admin.ModelAdmin):
    list_display = ('user', 'workout_template', 'status', 'scheduled_date', 'completed_at')
    list_filter = ('status', 'scheduled_date', 'workout_template__goal')
    search_fields = ('user__username', 'workout_template__name')
    
    fieldsets = (
        ('Informações do Usuário', {
            'fields': ('user', 'workout_template')
        }),
        ('Agendamento', {
            'fields': ('scheduled_date', 'status')
        }),
        ('Execução', {
            'fields': ('started_at', 'completed_at', 'notes')
        }),
    )