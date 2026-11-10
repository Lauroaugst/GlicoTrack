import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late final TextEditingController _lowController;
  late final TextEditingController _normalMinController;
  late final TextEditingController _normalMaxController;
  late final TextEditingController _highController;

  @override
  void initState() {
    super.initState();
    _lowController = TextEditingController(text: '70');
    _normalMinController = TextEditingController(text: '70');
    _normalMaxController = TextEditingController(text: '180');
    _highController = TextEditingController(text: '180');
  }

  @override
  void dispose() {
    _lowController.dispose();
    _normalMinController.dispose();
    _normalMaxController.dispose();
    _highController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Configurações salvas!',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF0060C0),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F1FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0060C0),
        elevation: 3,
        shadowColor: Colors.black45,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Faixa Ideal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 24.0),
          child: Container(
            // --- CAIXA BRANCA ADICIONADA AQUI ---
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12, width: 1.5),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Faixas de Glicemia',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Defina os valores que classificarão suas medições.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 24),

                // Glicemia Baixa
                _ThresholdSettingRow(
                  title: 'Glicemia Baixa',
                  titleColor: const Color(0xFFD32F2F),
                  prefixText: 'Abaixo de',
                  controller: _lowController,
                ),
                const Divider(
                  color: Colors.black12,
                  height: 32,
                  thickness: 1.0,
                ),

                // Glicemia Normal
                _RangeSettingRow(
                  title: 'Glicemia Normal',
                  titleColor: const Color(0xFF2E7D32),
                  minController: _normalMinController,
                  maxController: _normalMaxController,
                ),
                const Divider(
                  color: Colors.black12,
                  height: 32,
                  thickness: 1.0,
                ),

                // Glicemia Alta
                _ThresholdSettingRow(
                  title: 'Glicemia Alta',
                  titleColor: const Color(0xFFE65100),
                  prefixText: 'Acima de',
                  controller: _highController,
                ),
                const SizedBox(height: 32),

                // Botão de Salvar
                SizedBox(
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4889DC),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Salvar Limites',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
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

// ============================================================================
// MODULARIZED REUSABLE WIDGETS
// ============================================================================

class _SmallNumberInput extends StatelessWidget {
  final TextEditingController controller;

  const _SmallNumberInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 6.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF9F9F9),
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black26, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF0060C0), width: 2.0),
          ),
        ),
      ),
    );
  }
}

class _ThresholdSettingRow extends StatelessWidget {
  final String title;
  final Color titleColor;
  final String prefixText;
  final TextEditingController controller;

  const _ThresholdSettingRow({
    required this.title,
    required this.titleColor,
    required this.prefixText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color: titleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              prefixText,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            _SmallNumberInput(controller: controller),
            const Text(
              'mg/dL',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ],
    );
  }
}

class _RangeSettingRow extends StatelessWidget {
  final String title;
  final Color titleColor;
  final TextEditingController minController;
  final TextEditingController maxController;

  const _RangeSettingRow({
    required this.title,
    required this.titleColor,
    required this.minController,
    required this.maxController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color: titleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 10,
          children: [
            const Text(
              'De',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            _SmallNumberInput(controller: minController),
            const Text(
              'até',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            _SmallNumberInput(controller: maxController),
            const Text(
              'mg/dL',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ],
    );
  }
}
