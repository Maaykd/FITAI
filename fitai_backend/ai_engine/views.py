from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
import random
from .models import UserProfile, AIWorkoutRecommendation
from .serializers import (
    UserProfileSerializer, 
    AIWorkoutRecommendationSerializer,
    AnamneseSerializer
)

class UserProfileViewSet(viewsets.ModelViewSet):
    serializer_class = UserProfileSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return UserProfile.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class AIEngineViewSet(viewsets.ViewSet):
    permission_classes = [IsAuthenticated]
    
    @action(detail=False, methods=['post'])
    def anamnese(self, request):
        """Processar anamnese e criar/atualizar perfil do usuário"""
        serializer = AnamneseSerializer(data=request.data)
        if serializer.is_valid():
            data = serializer.validated_data
            
            # Criar ou atualizar perfil
            profile, created = UserProfile.objects.update_or_create(
                user=request.user,
                defaults={
                    'primary_goal': data['primary_goal'],
                    'experience_level': data['experience_level'],
                    'training_frequency': data['training_frequency'],
                    'available_equipment': data['available_equipment'],
                    'limitations': data['limitations'],
                    'last_anamnesis': timezone.now()
                }
            )
            
            return Response({
                'profile': UserProfileSerializer(profile).data,
                'message': 'Anamnese processada com sucesso!'
            }, status=status.HTTP_200_OK)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=False, methods=['post'])
    def generate_workout(self, request):
        """Gerar treino personalizado com IA"""
        try:
            profile = UserProfile.objects.get(user=request.user)
        except UserProfile.DoesNotExist:
            return Response({'error': 'Perfil não encontrado. Faça a anamnese primeiro.'}, 
                          status=status.HTTP_404_NOT_FOUND)
        
        # Simulação de IA (aqui você implementaria o algoritmo real)
        workout_data = self._simulate_ai_workout_generation(profile)
        confidence_score = random.uniform(0.85, 0.98)
        
        # Salvar recomendação
        recommendation = AIWorkoutRecommendation.objects.create(
            user_profile=profile,
            workout_data=workout_data,
            confidence_score=confidence_score
        )
        
        return Response({
            'workout': workout_data,
            'confidence_score': confidence_score,
            'recommendation_id': recommendation.id,
            'message': 'Treino gerado com sucesso pela IA!'
        })
    
    def _simulate_ai_workout_generation(self, profile):
        """Simulação do algoritmo de IA - substitua pela implementação real"""
        goal_workouts = {
            'neural_strength': {
                'name': 'Treino Neural IA',
                'exercises': [
                    {'name': 'Agachamento Explosivo', 'sets': 4, 'reps': '6', 'load': '85% 1RM'},
                    {'name': 'Supino Velocidade', 'sets': 5, 'reps': '3', 'load': 'Máxima velocidade'},
                    {'name': 'Levantamento Olímpico', 'sets': 4, 'reps': '4', 'load': 'Técnica perfeita'},
                ]
            },
            'strength': {
                'name': 'Treino de Força IA',
                'exercises': [
                    {'name': 'Agachamento', 'sets': 4, 'reps': '5', 'load': '80% 1RM'},
                    {'name': 'Supino', 'sets': 4, 'reps': '5', 'load': '80% 1RM'},
                    {'name': 'Levantamento Terra', 'sets': 3, 'reps': '5', 'load': '85% 1RM'},
                ]
            }
        }
        
        return goal_workouts.get(profile.primary_goal, goal_workouts['strength'])
    
    @action(detail=False, methods=['get'])
    def my_recommendations(self, request):
        """Histórico de recomendações da IA"""
        try:
            profile = UserProfile.objects.get(user=request.user)
            recommendations = AIWorkoutRecommendation.objects.filter(
                user_profile=profile
            ).order_by('-generated_at')
            
            serializer = AIWorkoutRecommendationSerializer(recommendations, many=True)
            return Response(serializer.data)
            
        except UserProfile.DoesNotExist:
            return Response({'error': 'Perfil não encontrado'}, 
                          status=status.HTTP_404_NOT_FOUND)