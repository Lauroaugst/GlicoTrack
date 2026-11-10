import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Gabriel da Silva',
  );
  final TextEditingController _ageController = TextEditingController(
    text: '65',
  );
  final TextEditingController _weightController = TextEditingController(
    text: '78.5',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Dados salvos com sucesso!',
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
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Dados Pessoais',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto de Perfil
                Center(
                  child: Semantics(
                    label: 'Foto de perfil. Toque para selecionar uma imagem.',
                    button: true,
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(60),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          const CircleAvatar(
                            radius: 56,
                            backgroundColor: Color(0xFF003D80),
                            child: Icon(
                              Icons.person_rounded,
                              size: 72,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4889DC),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Campos de Digitação Direta
                _SimpleTextField(
                  label: 'Nome Completo',
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 20),

                _SimpleTextField(
                  label: 'Idade (anos)',
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  isNumber: true,
                ),
                const SizedBox(height: 20),

                _SimpleTextField(
                  label: 'Peso (kg)',
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  isNumber: true,
                ),
                const SizedBox(height: 32),

                // Botão Salvar
                Semantics(
                  label: 'Salvar informações pessoais',
                  button: true,
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 64),
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4889DC),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Salvar Dados',
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

class _SimpleTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool isNumber;

  const _SimpleTextField({
    required this.label,
    required this.controller,
    required this.keyboardType,
    this.isNumber = false,
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
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            inputFormatters: isNumber
                ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
                : [],
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(
                0xFFF9F9F9,
              ), // Leve cinza para destacar dentro da caixa branca
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
