class DaftarRecord {
  final int? id;
  final String module;
  final String title;
  final double amount;
  final String details;
  final String createdAt;

  const DaftarRecord({
    this.id,
    required this.module,
    required this.title,
    required this.amount,
    required this.details,
    required this.createdAt,
  });

  factory DaftarRecord.fromMap(Map<String, Object?> map) => DaftarRecord(
        id: map['id'] as int?,
        module: map['module'] as String,
        title: map['title'] as String,
        amount: (map['amount'] as num).toDouble(),
        details: map['details'] as String? ?? '',
        createdAt: map['created_at'] as String,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'module': module,
        'title': title,
        'amount': amount,
        'details': details,
        'created_at': createdAt,
      };
}
