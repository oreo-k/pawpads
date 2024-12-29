from django.shortcuts import render
from django.http import HttpResponse
from .models import DogFood
# Create your views here.

def hello_world(request):
    return HttpResponse("Hello, PawPads World!")

def search_dogfood(request):
    query = request.GET.get('query', '')
    results=[]

    if query:
        # search for dog food
        results = DogFood.objects.filter(name__icontains=query) | DogFood.objects.filter(notes__icontains=query)
    return render(request, 'search_dogfood.html', {'query':query, 'results':results}) # search page