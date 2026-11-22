import 'package:material_ui/material_ui.dart';

import '../domain/models.dart';

String mealLabel(String meal) => switch (meal) {
  'breakfast' => 'Café da manhã',
  'lunch' => 'Almoço',
  'dinner' => 'Jantar',
  _ => meal,
};

Color glucoseColor(GlucoseStatus status) => switch (status) {
  GlucoseStatus.hypo => const Color(0xFFD32F2F),
  GlucoseStatus.inRange => const Color(0xFF2E7D32),
  GlucoseStatus.hyper => const Color(0xFFE65100),
  GlucoseStatus.belowTarget => const Color(0xFF8D6E00),
};

void showAppError(BuildContext context, Object error) {
  final message = error is FormatException
      ? error.message
      : 'Não foi possível concluir. Seus dados não foram descartados. Tente novamente.';
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: const Color(0xFFB00020)),
  );
}

String dateLabel(DateTime date) {
  final d = date.toLocal();
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

String timeLabel(DateTime date) {
  final d = date.toLocal();
  return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
