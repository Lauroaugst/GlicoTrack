import 'package:flutter/material.dart';

import 'personal_info_screen.dart';
import 'profile_settings_screen.dart';
import 'data_management_screen.dart'; // <--- Nova tela de Backup e Exclusão

class ProfileHubScreen extends StatelessWidget {
  const ProfileHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F1FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0060C0),
        elevation: 3,
        shadowColor: Colors.black45,
        centerTitle: true,
        title: const Text(
          'Meu Perfil',
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
            bottom: 120.0,
          ),
          child: Container(
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
                  'Configurações da Conta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                // Card 1: Dados Pessoais
                _MenuActionCard(
                  title: 'Dados Pessoais',
                  subtitle: 'Nome, Idade, Peso e Foto',
                  icon: Icons.person_rounded,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PersonalInfoScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Card 2: Faixa de Glicemia
                _MenuActionCard(
                  title: 'Faixa Ideal de Glicemia',
                  subtitle: 'Configurar limites médicos',
                  icon: Icons.monitor_heart_rounded,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProfileSettingsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Card 3: Segurança e Dados (Backup, Restaurar e Excluir)
                _MenuActionCard(
                  title: 'Segurança e Dados',
                  subtitle: 'Backup, Restauração e Exclusão',
                  icon: Icons.cloud_sync_rounded,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DataManagementScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Acessar $title.$subtitle',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 90),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF0060C0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
