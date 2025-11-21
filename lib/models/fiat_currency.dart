enum FiatCurrency {
  // Existing
  usd,
  eur,
  inr,

  // Added based on your waitlist countries
  cad, // Canada
  gbp, // UK
  sek, // Sweden
  ron, // Romania
  ngn, // Nigeria
  nad, // Namibia
  thb, // Thailand
  idr, // Indonesia
  lak, // Laos
}

const supportedCurrencies = [
  // Existing
  FiatCurrency.usd,
  FiatCurrency.eur,
  FiatCurrency.inr,

  // Added
  FiatCurrency.cad,
  FiatCurrency.gbp,
  FiatCurrency.sek,
  FiatCurrency.ron,
  FiatCurrency.ngn,
  FiatCurrency.nad,
  FiatCurrency.thb,
  FiatCurrency.idr,
  FiatCurrency.lak,
];

extension FiatCurrencyX on FiatCurrency {
  String get code => name.toLowerCase();

  String get label {
    switch (this) {
      case FiatCurrency.usd:
        return 'US Dollar';
      case FiatCurrency.eur:
        return 'Euro';
      case FiatCurrency.inr:
        return 'Indian Rupee';
      case FiatCurrency.cad:
        return 'Canadian Dollar';
      case FiatCurrency.gbp:
        return 'British Pound';
      case FiatCurrency.sek:
        return 'Swedish Krona';
      case FiatCurrency.ron:
        return 'Romanian Leu';
      case FiatCurrency.ngn:
        return 'Nigerian Naira';
      case FiatCurrency.nad:
        return 'Namibian Dollar';
      case FiatCurrency.thb:
        return 'Thai Baht';
      case FiatCurrency.idr:
        return 'Indonesian Rupiah';
      case FiatCurrency.lak:
        return 'Lao Kip';
    }
  }

  String get symbol {
    switch (this) {
      case FiatCurrency.usd:
        return '\$';
      case FiatCurrency.eur:
        return '€';
      case FiatCurrency.inr:
        return '₹';
      case FiatCurrency.cad:
        return '\$';
      case FiatCurrency.gbp:
        return '£';
      case FiatCurrency.sek:
        return 'kr';
      case FiatCurrency.ron:
        return 'lei';
      case FiatCurrency.ngn:
        return '₦';
      case FiatCurrency.nad:
        return '\$';
      case FiatCurrency.thb:
        return '฿';
      case FiatCurrency.idr:
        return 'Rp';
      case FiatCurrency.lak:
        return '₭';
    }
  }

  // NEW: Added a flag for a better UI in your currency selector
  String get flag {
    switch (this) {
      case FiatCurrency.usd:
        return '🇺🇸';
      case FiatCurrency.eur:
        return '🇪🇺';
      case FiatCurrency.inr:
        return '🇮🇳';
      case FiatCurrency.cad:
        return '🇨🇦';
      case FiatCurrency.gbp:
        return '🇬🇧';
      case FiatCurrency.sek:
        return '🇸🇪';
      case FiatCurrency.ron:
        return '🇷🇴';
      case FiatCurrency.ngn:
        return '🇳🇬';
      case FiatCurrency.nad:
        return '🇳🇦';
      case FiatCurrency.thb:
        return '🇹🇭';
      case FiatCurrency.idr:
        return '🇮🇩';
      case FiatCurrency.lak:
        return '🇱🇦';
    }
  }

  static FiatCurrency? fromCode(String code) {
    for (final e in FiatCurrency.values) {
      if (e.code == code.toLowerCase()) return e;
    }
    return null;
  }
}
