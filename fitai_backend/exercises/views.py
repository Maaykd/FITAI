from rest_framework import viewsets, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from .models import Exercise, MuscleGroup
from .serializers import ExerciseSerializer, ExerciseListSerializer, MuscleGroupSerializer

class MuscleGroupViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = MuscleGroup.objects.all()
    serializer_class = MuscleGroupSerializer

class ExerciseViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Exercise.objects.all()
    serializer_class = ExerciseSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ['muscle_groups', 'equipment', 'difficulty', 'is_neural_training']
    search_fields = ['name', 'description']
    
    def get_serializer_class(self):
        if self.action == 'list':
            return ExerciseListSerializer
        return ExerciseSerializer
    
    @action(detail=False, methods=['get'])
    def neural_training(self):
        """Endpoint específico para exercícios de força neural"""
        exercises = self.queryset.filter(is_neural_training=True)
        serializer = self.get_serializer(exercises, many=True)
        return Response(serializer.data)