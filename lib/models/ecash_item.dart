enum EcashStatus {
  ready,
  used,
}

class EcashItem {
  final String id;
  final String token; // Encoded token string for QR code
  final int amount; // Always 21 sats
  final EcashStatus status;
  final DateTime createdAt;
  final DateTime? usedAt; // Optional, when marked as used

  EcashItem({
    required this.id,
    required this.token,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.usedAt,
  });

  EcashItem copyWith({
    String? id,
    String? token,
    int? amount,
    EcashStatus? status,
    DateTime? createdAt,
    DateTime? usedAt,
  }) {
    return EcashItem(
      id: id ?? this.id,
      token: token ?? this.token,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      usedAt: usedAt ?? this.usedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token': token,
      'amount': amount,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'usedAt': usedAt?.toIso8601String(),
    };
  }

  factory EcashItem.fromJson(Map<String, dynamic> json) {
    return EcashItem(
      id: json['id'] as String,
      token: json['token'] as String,
      amount: json['amount'] as int,
      status: EcashStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EcashStatus.ready,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      usedAt: json['usedAt'] != null
          ? DateTime.parse(json['usedAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EcashItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
