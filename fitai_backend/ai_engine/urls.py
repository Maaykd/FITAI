from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'profile', views.UserProfileViewSet, basename='userprofile')
router.register(r'engine', views.AIEngineViewSet, basename='aiengine')

urlpatterns = [
    path('', include(router.urls)),
]