import 'dart:async';

import '../models/example_model.dart';

class ApiService {
  const ApiService();

  Future<List<HealthItem>> fetchHealthItems() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return const [
      HealthItem(
        id: 'glucose',
        title: 'Glucose',
        subtitle: 'Today',
        value: '108',
        unit: 'mg/dL',
        imageUrl: 'https://images.unsplash.com/photo-1530026405186-ed1f139313f8?w=640',
      ),
      HealthItem(
        id: 'meal',
        title: 'Meals',
        subtitle: 'Logged',
        value: '3',
        unit: 'items',
        imageUrl: 'https://images.unsplash.com/photo-1506806732259-39c2d0268443?w=640',
      ),
      HealthItem(
        id: 'activity',
        title: 'Activity',
        subtitle: 'Steps',
        value: '7.2k',
        unit: 'today',
        imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=640',
      ),
      HealthItem(
        id: 'sleep',
        title: 'Sleep',
        subtitle: 'Last night',
        value: '7h 45m',
        unit: '',
        imageUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=640',
      ),
      HealthItem(
        id: 'water',
        title: 'Hydration',
        subtitle: 'Cups',
        value: '6',
        unit: '/8',
        imageUrl: 'https://images.unsplash.com/photo-1532635223-6f9f2f734e54?w=640',
      ),
      HealthItem(
        id: 'meds',
        title: 'Medication',
        subtitle: 'Reminders',
        value: '2',
        unit: 'left',
        imageUrl: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=640',
      ),
    ];
  }
}