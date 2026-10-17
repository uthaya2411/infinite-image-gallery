import 'package:flutter/material.dart';

class CategoryItem {
  final String id;
  final String label;
  final IconData icon;

  const CategoryItem({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class AppCategories {
  static const List<CategoryItem> categories = [
    CategoryItem(id: 'all', label: 'All', icon: Icons.auto_awesome_rounded),
    CategoryItem(id: 'nature', label: 'Nature', icon: Icons.forest_rounded),
    CategoryItem(id: 'backgrounds', label: 'Wallpapers', icon: Icons.wallpaper_rounded),
    CategoryItem(id: 'animals', label: 'Animals', icon: Icons.pets_rounded),
    CategoryItem(id: 'places', label: 'Architecture', icon: Icons.location_city_rounded),
    CategoryItem(id: 'travel', label: 'Travel', icon: Icons.flight_takeoff_rounded),
    CategoryItem(id: 'food', label: 'Food', icon: Icons.restaurant_rounded),
    CategoryItem(id: 'sports', label: 'Sports', icon: Icons.sports_basketball_rounded),
    CategoryItem(id: 'science', label: 'Science', icon: Icons.biotech_rounded),
    CategoryItem(id: 'music', label: 'Music', icon: Icons.music_note_rounded),
    CategoryItem(id: 'people', label: 'People', icon: Icons.people_alt_rounded),
    CategoryItem(id: 'business', label: 'Business', icon: Icons.business_center_rounded),
  ];
}
