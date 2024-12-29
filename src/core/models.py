from django.db import models


class DogFood(models.Model):
    name = models.CharField(max_length=255)
    protein = models.FloatField()
    fat = models.FloatField()
    fiber = models.FloatField()
    notes = models.TextField(null=True, blank=True)

    def __str__(self):
        return self.name