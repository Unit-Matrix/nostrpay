class LNInvoice {
  final String bolt11;
  final String? description;
  final int? amountSat;

  LNInvoice({required this.bolt11, this.description, this.amountSat});

  @override
  int get hashCode =>
      bolt11.hashCode ^ description.hashCode ^ amountSat.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LNInvoice &&
          runtimeType == other.runtimeType &&
          bolt11 == other.bolt11 &&
          description == other.description &&
          amountSat == other.amountSat;

  @override
  String toString() {
    return 'LNInvoice{bolt11: $bolt11, description: $description, amountSat: $amountSat}';
  }
}
