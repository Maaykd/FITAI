from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from django.utils import timezone
from .models import WorkoutTemplate, UserWorkout
from .serializers import (
    WorkoutTemplateSerializer, 
    WorkoutTemplateCreateSerializer,
    UserWorkoutSerializer
)

class WorkoutTemplateViewSet(viewsets.ModelViewSet):
    queryset = WorkoutTemplate.objects.all()
    serializer_class = WorkoutTemplateSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['goal', 'difficulty', 'trainer', 'is_ai_generated']
    
    def get_serializer_class(self):
        if self.action == 'create':
            return WorkoutTemplateCreateSerializer
        return WorkoutTemplateSerializer
    
    def get_queryset(self):
        if self.request.user.role == 'trainer':
            return self.queryset.filter(trainer=self.request.user)
        return self.queryset
    
    @action(detail=False, methods=['get'])
    def my_templates(self):
        """Templates criados pelo trainer logado"""
        if self.request.user.role != 'trainer':
            return Response({'error': 'Apenas personal trainers podem acessar esta função'}, 
                          status=status.HTTP_403_FORBIDDEN)
        
        templates = self.queryset.filter(trainer=self.request.user)
        serializer = self.get_serializer(templates, many=True)
        return Response(serializer.data)

class UserWorkoutViewSet(viewsets.ModelViewSet):
    serializer_class = UserWorkoutSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['status', 'scheduled_date']
    
    def get_queryset(self):
        return UserWorkout.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
    
    @action(detail=True, methods=['post'])
    def start_workout(self, request, pk=None):
        """Iniciar um treino"""
        workout = self.get_object()
        if workout.status != 'scheduled':
            return Response({'error': 'Treino já foi iniciado ou concluído'}, 
                          status=status.HTTP_400_BAD_REQUEST)
        
        workout.status = 'in_progress'
        workout.started_at = timezone.now()
        workout.save()
        
        serializer = self.get_serializer(workout)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def complete_workout(self, request, pk=None):
        """Finalizar um treino"""
        workout = self.get_object()
        if workout.status != 'in_progress':
            return Response({'error': 'Treino deve estar em progresso para ser finalizado'}, 
                          status=status.HTTP_400_BAD_REQUEST)
        
        workout.status = 'completed'
        workout.completed_at = timezone.now()
        workout.notes = request.data.get('notes', '')
        workout.save()
        
        serializer = self.get_serializer(workout)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def today(self):
        """Treinos agendados para hoje"""
        today = timezone.now().date()
        workouts = self.get_queryset().filter(scheduled_date__date=today)
        serializer = self.get_serializer(workouts, many=True)
        return Response(serializer.data)