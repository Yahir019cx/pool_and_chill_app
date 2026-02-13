import 'package:flutter/material.dart';

const Color kDetailPrimary = Color(0xFF3CA2A2);
const Color kDetailDark = Color(0xFF1A1A2E);
const Color kDetailGrey = Color(0xFF2E2E3E);
const Color kDetailGreyLight = Color(0xFF44445A);

IconData iconForAmenity(String? iconCode, String? amenityCode) {
  final code = iconCode ?? amenityCode ?? '';
  switch (code.toLowerCase()) {
    case 'sunbed':
    case 'sunbeds':
      return Icons.deck_outlined;
    case 'umbrella':
    case 'umbrellas':
      return Icons.beach_access_outlined;
    case 'table':
    case 'tables':
    case 'tables_camping':
      return Icons.table_restaurant_outlined;
    case 'grill':
    case 'bbq':
    case 'bbq_camping':
      return Icons.outdoor_grill_outlined;
    case 'shower':
    case 'showers':
      return Icons.shower_outlined;
    case 'door':
    case 'changing_rooms':
      return Icons.door_sliding_outlined;
    case 'toilet':
    case 'bathrooms':
      return Icons.wc_outlined;
    case 'palapa':
    case 'palapa_camping':
      return Icons.umbrella_outlined;
    case 'cooler':
    case 'cooler_camping':
      return Icons.ac_unit_outlined;
    case 'speaker':
    case 'speakers':
    case 'speakers_cabin':
    case 'speakers_camping':
      return Icons.speaker_outlined;
    case 'fridge':
    case 'refrigerator':
    case 'refrigerator_cabin':
      return Icons.kitchen_outlined;
    case 'bar':
      return Icons.local_bar_outlined;
    case 'float':
    case 'floats':
      return Icons.pool_outlined;
    case 'chair':
    case 'chairs':
      return Icons.chair_outlined;
    case 'parking':
    case 'parking_pool':
    case 'parking_cabin':
    case 'parking_camping':
      return Icons.local_parking_outlined;
    case 'towel':
    case 'towels_pool':
    case 'towels_cabin':
      return Icons.dry_cleaning_outlined;
    case 'wifi':
      return Icons.wifi_outlined;
    case 'tv':
      return Icons.tv_outlined;
    case 'kitchen':
    case 'cocina':
      return Icons.countertops_outlined;
    case 'washer':
      return Icons.local_laundry_service_outlined;
    case 'ac':
      return Icons.ac_unit_outlined;
    case 'sofa':
    case 'sofas':
      return Icons.weekend_outlined;
    case 'microwave':
      return Icons.microwave_outlined;
    case 'dining':
      return Icons.dining_outlined;
    case 'utensils':
    case 'kitchenware':
      return Icons.restaurant_outlined;
    case 'fireplace':
      return Icons.fireplace_outlined;
    case 'fire':
    case 'firepit':
      return Icons.local_fire_department_outlined;
    case 'wood':
    case 'firewood':
      return Icons.forest_outlined;
    default:
      return Icons.check_circle_outline;
  }
}

String formatPrice(int n) {
  if (n >= 1000) {
    final thousands = n ~/ 1000;
    final remainder = n % 1000;
    if (remainder == 0) return '$thousands,000';
    return '$thousands,${remainder.toString().padLeft(3, '0')}';
  }
  return n.toString();
}

class SpecItem {
  final IconData icon;
  final String value;
  final String label;
  const SpecItem(this.icon, this.value, this.label);
}

class InfoPair {
  final String label;
  final String value;
  const InfoPair(this.label, this.value);
}
