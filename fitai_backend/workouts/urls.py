from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'templates', views.WorkoutTemplateViewSet)
router.register(r'user-workouts', views.UserWorkoutViewSet, basename='userworkout')

urlpatterns = [
    path('', include(router.urls)),
]