enum TailorAvailability { available, limited, unavailable }

extension TailorAvailabilityValue on TailorAvailability {
  String get storageValue => switch (this) {
        TailorAvailability.available => 'available',
        TailorAvailability.limited => 'limited',
        TailorAvailability.unavailable => 'unavailable',
      };

  String get label => switch (this) {
        TailorAvailability.available => 'Disponible',
        TailorAvailability.limited => 'Places limitées',
        TailorAvailability.unavailable => 'Indisponible',
      };

  static TailorAvailability fromStorage(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'limited' => TailorAvailability.limited,
      'unavailable' => TailorAvailability.unavailable,
      _ => TailorAvailability.available,
    };
  }
}
