# Generated by Django 5.1.4 on 2024-12-29 04:31

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='dogfood',
            name='notes',
            field=models.TextField(blank=True, null=True),
        ),
    ]
