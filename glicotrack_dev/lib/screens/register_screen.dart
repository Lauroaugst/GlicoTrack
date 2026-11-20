import 'package:glicotrack_dev/data/local_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

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

abstract class GlucoseMockData {
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
  
  final LocalDatabase localDatabase;

  const RegisterScreen({
    super.key,
    required this.localDatabase,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedMealTimeId = GlucoseMockData.mealTimes.first.id;

  final TextEditingController _glucoseController = TextEditingController();
  final TextEditingController _insulinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();

  @override
  void dispose() {
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
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveRecord() async {
  // 1. Obtém e valida o valor da glicemia.
  final glucose = int.tryParse(_glucoseController.text.trim());

  if (glucose == null || glucose < 1 || glucose > 1000) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Informe uma glicemia válida entre 1 e 1000 mg/dL.'),
        backgroundColor: Color(0xFFB00020),
      ),
    );
    return;
  }

  // 2. Converte os campos opcionais para números.
  final insulinText = _insulinController.text.trim();
  final carbsText = _carbsController.text.trim();

  final insulin = insulinText.isEmpty
      ? null
      : double.tryParse(insulinText.replaceAll(',', '.'));

  final carbs = carbsText.isEmpty
      ? null
      : double.tryParse(carbsText.replaceAll(',', '.'));

  // Verifica se os campos opcionais foram preenchidos corretamente.
  if ((insulinText.isNotEmpty && insulin == null) ||
      (carbsText.isNotEmpty && carbs == null)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Confira os valores de insulina e carboidratos.'),
        backgroundColor: Color(0xFFB00020),
      ),
    );
    return;
  }

  try {
    // 3. Recupera o usuário autenticado no Firebase.
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('Usuário não autenticado.');
    }

    // 4. Cria um identificador único para o registro.
    final id = const Uuid().v4();

    // 5. Combina a data selecionada com o horário atual.
    final now = DateTime.now();

    final measuredAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      now.hour,
      now.minute,
      now.second,
    );

    // 6. Cria o objeto com os dados informados pelo usuário.
    final record = HealthRecord(
      id: id,
      uid: user.uid,
      glucose: glucose,
      measuredAt: measuredAt,
      category: _selectedCategory,
      meal: _selectedMealTimeId,
      createdAt: now,
      insulin: insulin,
      carbs: carbs,
    );

    // 7. Valida os dados conforme as regras do modelo.
    record.validate();

    // 8. Salva o registro no SQLite criptografado.
    await widget.localDatabase.save(
      record.id,
      'record',
      record.toJson(),
    );
    final savedDocuments = await widget.localDatabase.all(pendingOnly: false);

      debugPrint(
        'GlicoTrack: ${savedDocuments.length} documento(s) '
        'encontrado(s) imediatamente após salvar.',
      );
    if (!mounted) return;

    // 9. Exibe sucesso somente após salvar no SQLite.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Registro salvo com sucesso!',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF0060C0),
      ),
    );

    // 10. Limpa os campos para permitir um novo registro.
    _glucoseController.clear();
    _insulinController.clear();
    _carbsController.clear();
  } catch (error) {
    if (!mounted) return;

    // Exibe uma mensagem caso ocorra erro na validação ou no banco.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Não foi possível salvar o registro: $error'),
        backgroundColor: const Color(0xFFB00020),
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo azul claro padrão do app
      backgroundColor: const Color(0xFFE3F1FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0060C0),
        elevation: 3,
        shadowColor: Colors.black45,
        centerTitle: true,
        title: const Text(
          'Novo Registro',
          style: TextStyle(
            color: Colors.white,
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
              color: Colors.white,
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
                  options: GlucoseMockData.mealTimes,
                  selectedId: _selectedMealTimeId,
                  onSelected: (id) {
                    setState(() {
                      _selectedMealTimeId = id;
                    });
                  },
                ),
                const SizedBox(height: 24),
                // Seleção da categoria da medição.
                const Text(
                  'Momento da medição',
                    style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                          ),
                     ),
                const SizedBox(height: 8),

                    DropdownButtonFormField<MeasurementCategory>(
                      initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                         items: const [
                    DropdownMenuItem(
                        value: MeasurementCategory.beforeMeal,
                        child: Text('Antes da refeição'),
                      ),
                    DropdownMenuItem(
                         value: MeasurementCategory.afterMeal,
                          child: Text('Depois da refeição'),
                      ),
                     DropdownMenuItem(
                           value: MeasurementCategory.fasting,
                           child: Text('Em jejum'),
                      ),
                      DropdownMenuItem(
                          value: MeasurementCategory.bedtime,
                          child: Text('Antes de dormir'),
                      ),
                        ],
                          onChanged: (value) {
                              if (value != null) {
                                  setState(() {
                                     _selectedCategory = value;
                                  });
                                }
                            },
                        ),

                        const SizedBox(height: 24),
                // Inputs Numéricos (Retrocedidos para digitação direta, sem steppers)
                _SimpleTextField(
                  label: 'Glicemia (mg/dL)',
                  controller: _glucoseController,
                  isDecimal: false,
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
                const SizedBox(height: 32),

                // Botão Salvar
                Semantics(
                  label: 'Salvar registro de glicemia',
                  button: true,
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 64),
                    child: ElevatedButton(
                      onPressed: _saveRecord,
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
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
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

  const _SimpleTextField({
    required this.label,
    required this.controller,
    this.isDecimal = false,
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
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
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
