from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from exercises.models import MuscleGroup, Exercise
from workouts.models import WorkoutTemplate, WorkoutExercise

User = get_user_model()

class Command(BaseCommand):
    help = 'Popula o banco com dados de teste'

    def handle(self, *args, **options):
        self.stdout.write('Criando dados de teste...')
        
        # Criar grupos musculares
        muscle_groups = [
            {'name': 'Peito', 'description': 'Músculos peitorais'},
            {'name': 'Costas', 'description': 'Músculos das costas'},
            {'name': 'Pernas', 'description': 'Músculos das pernas'},
            {'name': 'Ombros', 'description': 'Músculos dos ombros'},
            {'name': 'Braços', 'description': 'Bíceps e tríceps'},
            {'name': 'Core', 'description': 'Músculos do core'},
        ]
        
        for mg_data in muscle_groups:
            mg, created = MuscleGroup.objects.get_or_create(
                name=mg_data['name'],
                defaults={'description': mg_data['description']}
            )
            if created:
                self.stdout.write(f'Grupo muscular criado: {mg.name}')
        
        # Criar exercícios
        exercises_data = [
            {
                'name': 'Supino Reto',
                'description': 'Exercício para peito com barra',
                'equipment': 'barbell',
                'difficulty': 'intermediate',
                'instructions': 'Deite no banco, segure a barra, abaixe até o peito e empurre para cima',
                'muscle_groups': ['Peito', 'Braços'],
                'is_neural_training': False
            },
            {
                'name': 'Agachamento Explosivo',
                'description': 'Agachamento com foco em força neural',
                'equipment': 'barbell',
                'difficulty': 'advanced',
                'instructions': 'Agachamento com movimento explosivo na subida',
                'muscle_groups': ['Pernas'],
                'is_neural_training': True
            },
            {
                'name': 'Levantamento Terra',
                'description': 'Exercício composto para força',
                'equipment': 'barbell',
                'difficulty': 'advanced',
                'instructions': 'Levante a barra do chão mantendo as costas retas',
                'muscle_groups': ['Costas', 'Pernas'],
                'is_neural_training': True
            },
            {
                'name': 'Flexão de Braço',
                'description': 'Exercício com peso corporal',
                'equipment': 'bodyweight',
                'difficulty': 'beginner',
                'instructions': 'Posição de prancha, desça e suba o corpo',
                'muscle_groups': ['Peito', 'Braços'],
                'is_neural_training': False
            },
        ]
        
        for ex_data in exercises_data:
            muscle_group_names = ex_data.pop('muscle_groups')
            exercise, created = Exercise.objects.get_or_create(
                name=ex_data['name'],
                defaults=ex_data
            )
            
            if created:
                # Adicionar grupos musculares
                for mg_name in muscle_group_names:
                    mg = MuscleGroup.objects.get(name=mg_name)
                    exercise.muscle_groups.add(mg)
                
                self.stdout.write(f'Exercício criado: {exercise.name}')
        
        # Criar personal trainer de teste
        trainer, created = User.objects.get_or_create(
            username='trainer_test',
            defaults={
                'email': 'trainer@fitai.com',
                'first_name': 'Personal',
                'last_name': 'Trainer',
                'role': 'trainer',
                'is_staff': True
            }
        )
        
        if created:
            trainer.set_password('123456789')
            trainer.save()
            self.stdout.write(f'Personal trainer criado: {trainer.username}')
        
        # Criar template de treino
        template, created = WorkoutTemplate.objects.get_or_create(
            name='Treino Neural Completo',
            defaults={
                'description': 'Treino focado em força neural',
                'goal': 'neural_strength',
                'difficulty': 'advanced',
                'estimated_duration': 45,
                'trainer': trainer,
                'is_ai_generated': True
            }
        )
        
        if created:
            # Adicionar exercícios ao template
            exercises = Exercise.objects.filter(is_neural_training=True)
            for i, exercise in enumerate(exercises[:3]):
                WorkoutExercise.objects.create(
                    workout_template=template,
                    exercise=exercise,
                    sets=4,
                    reps='6',
                    rest_time=180,
                    load_percentage=85.0,
                    order=i+1
                )
            
            self.stdout.write(f'Template de treino criado: {template.name}')
        
        self.stdout.write(
            self.style.SUCCESS('Dados de teste criados com sucesso!')
        )