from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'exercises', views.ExerciseViewSet)
router.register(r'muscle-groups', views.MuscleGroupViewSet)

urlpatterns = [
    path('', include(router.urls)),
]