import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'dart:async';

import 'package:provider/provider.dart';

import '../domain/models.dart';
import '../presentation/app_store.dart';
import '../presentation/glucose_style.dart';
import '../services/hypo_alert.dart';

class MealTimeOption {
  final String id;
  final String label;
  final IconData icon;

  const MealTimeOption({
    required this.id,
    required this.label,
    required this.icon,
  });
}

abstract class MealOptions {
  static const List<MealTimeOption> mealTimes = [
    MealTimeOption(
      id: 'breakfast',
      label: 'Café da\nManhã',
      icon: Icons.wb_twilight_rounded,
    ),
    MealTimeOption(id: 'lunch', label: 'Almoço', icon: Icons.wb_sunny_outlined),
    MealTimeOption(
      id: 'dinner',
      label: 'Jantar',
      icon: Icons.nightlight_outlined,
    ),
  ];
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.record, this.active = true});
  final HealthRecord? record;
  final bool active;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedMealTimeId = MealOptions.mealTimes.first.id;
  MeasurementCategory _category = MeasurementCategory.fasting;
  final _notesController = TextEditingController();
  final _glucoseFocus = FocusNode();
  bool _saving = false;
  bool _hypoAlerted = false;
  bool _timeChosen = false;
  Timer? _alertTimer;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    if (record != null) {
      _selectedDate = record.measuredAt;
      _selectedMealTimeId = record.meal;
      _category = record.category;
      _glucoseController.text = record.glucose.toString();
      _insulinController.text = record.insulin?.toString() ?? '';
      _carbsController.text = record.carbs?.toString() ?? '';
      _notesController.text = record.notes;
    }
    _glucoseController.addListener(_onGlucoseChanged);
    _focusWhenActive();
  }

  void _focusWhenActive() {
    if (widget.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.active) _glucoseFocus.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant RegisterScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) _focusWhenActive();
    if (!widget.active) {
      _glucoseFocus.unfocus();
      _alertTimer?.cancel();
    }
  }

  void _onGlucoseChanged() {
    final value = int.tryParse(_glucoseController.text);
    _alertTimer?.cancel();
    if (value == null || value >= 70) _hypoAlerted = false;
    if (widget.active &&
        value != null &&
        value > 0 &&
        value < 70 &&
        !_hypoAlerted) {
      _alertTimer = Timer(const Duration(milliseconds: 450), () {
        if (!mounted || !widget.active) return;
        _hypoAlerted = true;
        unawaited(HypoAlert.play());
      });
    }
    if (mounted) setState(() {});
  }

  final TextEditingController _glucoseController = TextEditingController();
  final TextEditingController _insulinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();

  @override
  void dispose() {
    _alertTimer?.cancel();
    _glucoseController.removeListener(_onGlucoseChanged);
    _notesController.dispose();
    _glucoseFocus.dispose();
    _glucoseController.dispose();
    _insulinController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0060C0),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      if (!mounted) return;
      setState(
        () => _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        ),
      );
    }
  }

  double? _optionalNumber(String text) {
    if (text.trim().isEmpty) return null;
    final value = double.tryParse(text.replaceAll(',', '.'));
    if (value == null) {
      throw const FormatException('Informe uma quantidade numérica válida.');
    }
    return value;
  }

  Future<void> _saveRecord() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final store = context.read<AppStore>();
      final now = DateTime.now();
      final glucose = int.tryParse(_glucoseController.text.trim());
      if (glucose == null) {
        throw const FormatException(
          'Informe o valor da glicemia em números inteiros.',
        );
      }
      final record = HealthRecord(
        id: widget.record?.id ?? store.newId(),
        uid: store.uid,
        glucose: glucose,
        measuredAt: widget.record != null || _timeChosen
            ? _selectedDate
            : DateTime(
                _selectedDate.year,
                _selectedDate.month,
                _selectedDate.day,
                now.hour,
                now.minute,
                now.second,
              ),
        category: _category,
        meal: _selectedMealTimeId,
        createdAt: widget.record?.createdAt ?? now,
        insulin: _optionalNumber(_insulinController.text),
        carbs: _optionalNumber(_carbsController.text),
        notes: _notesController.text.trim(),
      );
      await store.saveRecord(record);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro salvo neste aparelho.'),
          backgroundColor: Color(0xFF0060C0),
        ),
      );
      if (widget.record != null) {
        Navigator.of(context).pop();
        return;
      }
      _glucoseController.clear();
      _insulinController.clear();
      _carbsController.clear();
      _notesController.clear();
      _selectedDate = DateTime.now();
      _timeChosen = false;
      _focusWhenActive();
    } catch (error) {
      if (mounted) showAppError(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _saveButton(AppStore store) => Semantics(
    label: 'Salvar registro de glicemia',
    button: true,
    child: Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 64),
      child: ElevatedButton(
        onPressed: _saving || store.deleting ? null : _saveRecord,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4889DC),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Guardar Registro',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final value = int.tryParse(_glucoseController.text);
    final status = value != null && value > 0
        ? store.settings.classify(value)
        : null;
    final statusColor = status == null ? null : glucoseColor(status);
    final headerForeground =
        status == GlucoseStatus.hyper || status == GlucoseStatus.belowTarget
        ? Colors.black87
        : Colors.white;
    return Scaffold(
      bottomNavigationBar: keyboardVisible
          ? SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  12,
                  12,
                  12,
                  12 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: _saveButton(store),
              ),
            )
          : null,
      backgroundColor: statusColor ?? const Color(0xFFE3F1FD),
      appBar: AppBar(
        backgroundColor: statusColor ?? const Color(0xFF0060C0),
        foregroundColor: headerForeground,
        elevation: 3,
        shadowColor: Colors.black45,
        centerTitle: true,
        title: Text(
          'Novo Registro',
          style: TextStyle(
            color: headerForeground,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 18.0,
            right: 18.0,
            top: 24.0,
            bottom: 120.0, // Espaço para a barra de navegação flutuante
          ),
          child: Container(
            decoration: BoxDecoration(
              color: statusColor == null
                  ? Colors.white
                  : Color.alphaBlend(
                      statusColor.withValues(alpha: 0.15),
                      Colors.white,
                    ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12, width: 1.5),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Registre sua Glicemia',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Seletor de Data
                _DatePickerField(
                  label: 'Data da Medição',
                  selectedDate: _selectedDate,
                  onTap: _pickDate,
                ),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_selectedDate),
                    );
                    if (picked != null && mounted) {
                      _timeChosen = true;
                      setState(
                        () => _selectedDate = DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day,
                          picked.hour,
                          picked.minute,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.access_time),
                  label: Text('Horário: ${timeLabel(_selectedDate)}'),
                ),
                const SizedBox(height: 20),

                // Seletor de Momento do Dia
                const Text(
                  'Momento do dia',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _MealTimeSelector(
                  options: MealOptions.mealTimes,
                  selectedId: _selectedMealTimeId,
                  onSelected: (id) {
                    setState(() {
                      _selectedMealTimeId = id;
                    });
                  },
                ),
                const SizedBox(height: 24),

                DropdownButtonFormField<MeasurementCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: 'Categoria da medição',
                  ),
                  items: MeasurementCategory.values
                      .map(
                        (c) => DropdownMenuItem(value: c, child: Text(c.label)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _category = value);
                  },
                ),
                const SizedBox(height: 20),

                // Inputs Numéricos (Retrocedidos para digitação direta, sem steppers)
                _SimpleTextField(
                  label: 'Glicemia (mg/dL)',
                  controller: _glucoseController,
                  isDecimal: false,
                  focusNode: _glucoseFocus,
                  onSubmitted: (_) => _saveRecord(),
                  large: true,
                ),
                if (status != null)
                  Semantics(
                    liveRegion: true,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        status.label,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: glucoseColor(status),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                _SimpleTextField(
                  label: 'Insulina (Unidades)',
                  controller: _insulinController,
                  isDecimal: true,
                ),
                const SizedBox(height: 20),

                _SimpleTextField(
                  label: 'Carboidratos (Gramas)',
                  controller: _carbsController,
                  isDecimal: true,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _notesController,
                  maxLength: 2000,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Observações (opcional)',
                  ),
                ),
                const SizedBox(height: 32),

                if (!keyboardVisible) _saveButton(store),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime selectedDate;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.selectedDate,
    required this.onTap,
  });

  String get _formattedDate {
    return '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label:
              'Data selecionada: $_formattedDate. Toque para alterar a data.',
          button: true,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFF9F9F9,
                ), // Fundo acinzentado para destacar do card branco
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black26, width: 1.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formattedDate,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.black87,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MealTimeSelector extends StatelessWidget {
  final List<MealTimeOption> options;
  final String selectedId;
  final ValueChanged<String> onSelected;

  const _MealTimeSelector({
    required this.options,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((option) {
        final isSelected = option.id == selectedId;
        final isLast = option == options.last;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 8.0),
            child: Semantics(
              label: 'Momento do dia: ${option.label}',
              button: true,
              selected: isSelected,
              child: InkWell(
                onTap: () => onSelected(option.id),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  constraints: const BoxConstraints(
                    minHeight: 90,
                  ), // Altura acessível
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE3F1FD)
                        : const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0060C0)
                          : Colors.black26,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        option.icon,
                        size: 32,
                        color: isSelected
                            ? const Color(0xFF0060C0)
                            : Colors.black87,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        option.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.15,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF0060C0)
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SimpleTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isDecimal;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final bool large;

  const _SimpleTextField({
    required this.label,
    required this.controller,
    this.isDecimal = false,
    this.focusNode,
    this.onSubmitted,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: TextField(
            focusNode: focusNode,
            onSubmitted: onSubmitted,
            textInputAction: onSubmitted == null
                ? TextInputAction.next
                : TextInputAction.done,
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
            style: TextStyle(
              fontSize: large ? 36 : 18,
              fontWeight: FontWeight.w500,
            ),
            inputFormatters: [
              if (isDecimal)
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
              else
                FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(
                0xFFF9F9F9,
              ), // Fundo levemente cinza para destacar da caixa branca
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black26, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF0060C0),
                  width: 2.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
