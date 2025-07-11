# Generated by Django 5.2.1 on 2025-06-02 18:18

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('exercises', '0001_initial'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='WorkoutTemplate',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100)),
                ('description', models.TextField()),
                ('goal', models.CharField(choices=[('strength', 'Força'), ('hypertrophy', 'Hipertrofia'), ('endurance', 'Resistência'), ('neural_strength', 'Força Neural'), ('weight_loss', 'Perda de Peso')], max_length=20)),
                ('difficulty', models.CharField(choices=[('beginner', 'Iniciante'), ('intermediate', 'Intermediário'), ('advanced', 'Avançado')], max_length=15)),
                ('estimated_duration', models.IntegerField(help_text='Duração em minutos')),
                ('is_ai_generated', models.BooleanField(default=False)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('trainer', models.ForeignKey(limit_choices_to={'role': 'trainer'}, on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='WorkoutExercise',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('sets', models.IntegerField()),
                ('reps', models.CharField(help_text='Ex: 8-12 ou 30 segundos', max_length=20)),
                ('rest_time', models.IntegerField(help_text='Descanso em segundos')),
                ('load_percentage', models.FloatField(blank=True, help_text='% do 1RM', null=True)),
                ('order', models.PositiveIntegerField()),
                ('notes', models.TextField(blank=True)),
                ('exercise', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='exercises.exercise')),
                ('workout_template', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='workouts.workouttemplate')),
            ],
            options={
                'ordering': ['order'],
            },
        ),
        migrations.CreateModel(
            name='UserWorkout',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('scheduled_date', models.DateTimeField()),
                ('started_at', models.DateTimeField(blank=True, null=True)),
                ('completed_at', models.DateTimeField(blank=True, null=True)),
                ('status', models.CharField(choices=[('scheduled', 'Agendado'), ('in_progress', 'Em Progresso'), ('completed', 'Concluído'), ('skipped', 'Pulado')], default='scheduled', max_length=15)),
                ('notes', models.TextField(blank=True)),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
                ('workout_template', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='workouts.workouttemplate')),
            ],
        ),
    ]
