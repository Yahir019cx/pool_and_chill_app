import 'package:flutter/material.dart';

// ─── Selected amenity entry ───────────────────────────────────────

class HostAmenityEntry {
  final String catalogId;
  final String name;
  String quantityText;

  HostAmenityEntry({
    required this.catalogId,
    required this.name,
    this.quantityText = '',
  });
}

// ─── Editable rule row ────────────────────────────────────────────

class HostEditableRule {
  final TextEditingController ctrl;
  HostEditableRule(String text) : ctrl = TextEditingController(text: text);
  void dispose() => ctrl.dispose();
}

// ─── Mutable holder for check-in / check-out times (display strings) ─

class HostEditTimes {
  String? poolCheckIn;
  String? poolCheckOut;
  String? cabinCheckIn;
  String? cabinCheckOut;
  String? campCheckIn;
  String? campCheckOut;
}

// ─── All TextEditingControllers grouped ──────────────────────────

class HostEditControllers {
  // Basic
  final desc = TextEditingController();

  // Pool pricing
  final poolPriceWd = TextEditingController();
  final poolPriceWe = TextEditingController();

  // Pool amenities
  final poolMaxP = TextEditingController();
  final poolTempMin = TextEditingController();
  final poolTempMax = TextEditingController();

  // Cabin pricing
  final cabinMinN = TextEditingController();
  final cabinMaxN = TextEditingController();
  final cabinPriceWd = TextEditingController();
  final cabinPriceWe = TextEditingController();

  // Cabin amenities
  final cabinMaxG = TextEditingController();
  final cabinBed = TextEditingController();
  final cabinSingleB = TextEditingController();
  final cabinDoubleB = TextEditingController();
  final cabinFullBath = TextEditingController();
  final cabinHalfBath = TextEditingController();

  // Camping pricing
  final campMinN = TextEditingController();
  final campMaxN = TextEditingController();
  final campPriceWd = TextEditingController();
  final campPriceWe = TextEditingController();

  // Camping amenities
  final campMaxP = TextEditingController();
  final campArea = TextEditingController();
  final campTents = TextEditingController();

  void dispose() {
    desc.dispose();
    poolPriceWd.dispose();
    poolPriceWe.dispose();
    poolMaxP.dispose();
    poolTempMin.dispose();
    poolTempMax.dispose();
    cabinMinN.dispose();
    cabinMaxN.dispose();
    cabinPriceWd.dispose();
    cabinPriceWe.dispose();
    cabinMaxG.dispose();
    cabinBed.dispose();
    cabinSingleB.dispose();
    cabinDoubleB.dispose();
    cabinFullBath.dispose();
    cabinHalfBath.dispose();
    campMinN.dispose();
    campMaxN.dispose();
    campPriceWd.dispose();
    campPriceWe.dispose();
    campMaxP.dispose();
    campArea.dispose();
    campTents.dispose();
  }
}
