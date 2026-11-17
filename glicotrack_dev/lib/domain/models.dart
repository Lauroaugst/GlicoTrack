import 'dart:math' as math;

enum MeasurementCategory {
  fasting('Jejum'),
  beforeMeal('Pré-refeição'),
  afterMeal('Pós-refeição'),
  bedtime('Antes de dormir');

  const MeasurementCategory(this.label);
  final String label;
}

enum GlucoseStatus {
  hypo('Hipoglicemia'),
  belowTarget('Abaixo da meta'),
  inRange('Na faixa'),
  hyper('Hiperglicemia');

  const GlucoseStatus(this.label);
  final String label;
}

class GlucoseSettings {
  const GlucoseSettings({this.lower = 70, this.upper = 180});
  final int lower;
  final int upper;

  void validate() {
    if (lower < 70 || upper <= lower || upper > 1000) {
      throw const FormatException(
        'Informe uma faixa entre 70 e 1000, com mínimo menor que máximo.',
      );
    }
  }

  GlucoseStatus classify(num value) {
    if (value < 70) return GlucoseStatus.hypo;
    if (value < lower) return GlucoseStatus.belowTarget;
    if (value > upper) return GlucoseStatus.hyper;
    return GlucoseStatus.inRange;
  }

  Map<String, dynamic> toJson() => {'lower': lower, 'upper': upper};
  factory GlucoseSettings.fromJson(Map<String, dynamic> json) {
    final settings = GlucoseSettings(
      lower: json['lower'] as int,
      upper: json['upper'] as int,
    );
    settings.validate();
    return settings;
  }
}

class PatientProfile {
  const PatientProfile({
    required this.name,
    required this.email,
    required this.createdAt,
    this.age,
    this.weight,
    this.photo,
  });
  final String name;
  final String email;
  final DateTime createdAt;
  final int? age;
  final double? weight;
  // Base64 JPEG/PNG, kept inside the encrypted database and private Firestore document.
  final String? photo;

  void validate() {
    if (name.trim().isEmpty ||
        name.length > 120 ||
        email.length > 254 ||
        (age != null && (age! < 0 || age! > 130)) ||
        (weight != null &&
            (!weight!.isFinite || weight! <= 0 || weight! > 700)) ||
        (photo != null && photo!.length > 300000)) {
      throw const FormatException('Confira nome, idade, peso e foto.');
    }
  }

  Map<String, dynamic> toJson() => {
    'name': name.trim(),
    'email': email,
    'createdAt': createdAt.toUtc().millisecondsSinceEpoch,
    'age': age,
    'weight': weight,
    'photo': photo,
  };
  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    final profile = PatientProfile(
      name: json['name'] as String,
      email: json['email'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] as int,
        isUtc: true,
      ),
      age: json['age'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      photo: json['photo'] as String?,
    );
    profile.validate();
    return profile;
  }
}

class HealthRecord {
  const HealthRecord({
    required this.id,
    required this.uid,
    required this.glucose,
    required this.measuredAt,
    required this.category,
    required this.meal,
    required this.createdAt,
    this.insulin,
    this.carbs,
    this.notes = '',
  });
  final String id;
  final String uid;
  final int glucose;
  final DateTime measuredAt;
  final MeasurementCategory category;
  final String meal;
  final DateTime createdAt;
  final double? insulin;
  final double? carbs;
  final String notes;

  void validate() {
    if (id.isEmpty ||
        uid.isEmpty ||
        glucose <= 0 ||
        glucose > 1000 ||
        !['breakfast', 'lunch', 'dinner'].contains(meal) ||
        notes.length > 2000 ||
        (insulin != null &&
            (!insulin!.isFinite || insulin! < 0 || insulin! > 1000)) ||
        (carbs != null && (!carbs!.isFinite || carbs! < 0 || carbs! > 5000))) {
      throw const FormatException(
        'Confira glicemia (1–1000), insulina (0–1000), carboidratos (0–5000) e observações.',
      );
    }
  }

  Map<String, dynamic> toJson() => {
    'glucose': glucose,
    'measuredAt': measuredAt.toUtc().millisecondsSinceEpoch,
    'category': category.name,
    'meal': meal,
    'createdAt': createdAt.toUtc().millisecondsSinceEpoch,
    'insulin': insulin,
    'carbs': carbs,
    'notes': notes,
  };
  factory HealthRecord.fromJson(
    String id,
    String uid,
    Map<String, dynamic> json,
  ) {
    final record = HealthRecord(
      id: id,
      uid: uid,
      glucose: json['glucose'] as int,
      measuredAt: DateTime.fromMillisecondsSinceEpoch(
        json['measuredAt'] as int,
        isUtc: true,
      ).toLocal(),
      category: MeasurementCategory.values.byName(json['category'] as String),
      meal: json['meal'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] as int,
        isUtc: true,
      ),
      insulin: (json['insulin'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      notes: json['notes'] as String,
    );
    record.validate();
    return record;
  }
}

/// Insulin is recorded only. Dose calculation requires a documented clinical rule
/// and individually prescribed parameters before an implementation can be added.
abstract interface class PrescribedDoseCalculator {
  double calculate(Map<String, double> prescribedParameters);
}

class RecordStatistics {
  RecordStatistics(
    List<HealthRecord> records,
    GlucoseSettings settings, {
    required this.days,
  }) {
    count = records.length;
    if (records.isEmpty) return;
    final values = records.map((e) => e.glucose);
    average = values.reduce((a, b) => a + b) / count;
    min = values.reduce(math.min);
    max = values.reduce(math.max);
    inRangePercent =
        records
            .where((e) => settings.classify(e.glucose) == GlucoseStatus.inRange)
            .length *
        100 /
        count;
  }
  final int days;
  int count = 0;
  double? average;
  int? min;
  int? max;
  double inRangePercent = 0;
  double get frequency => count / math.max(1, days);
}

class TrendIndicator {
  const TrendIndicator(this.message);
  final String message;

  factory TrendIndicator.analyze(
    List<HealthRecord> records,
    GlucoseSettings settings,
  ) {
    final sorted = [...records]
      ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
    if (sorted.length < 6) {
      return const TrendIndicator(
        'São necessárias ao menos 6 medições para comparar tendências.',
      );
    }
    final recent = sorted.sublist(sorted.length - 6);
    final older = RecordStatistics(recent.take(3).toList(), settings, days: 1);
    final newer = RecordStatistics(recent.skip(3).toList(), settings, days: 1);
    final delta = (newer.average! - older.average!) / 3;
    final projected = recent.last.glucose + delta;
    final direction = newer.inRangePercent > older.inRangePercent
        ? 'Mais medições na meta.'
        : newer.inRangePercent < older.inRangePercent
        ? 'Menos medições na meta.'
        : 'Frequência na meta estável.';
    final risk = projected < 70
        ? ' Tendência numérica de baixa glicemia.'
        : projected > settings.upper
        ? ' Tendência numérica de glicemia elevada.'
        : '';
    return TrendIndicator(
      '$direction$risk Indicador histórico; não prevê o horário de um episódio e não orienta doses ou tratamento.',
    );
  }
}
