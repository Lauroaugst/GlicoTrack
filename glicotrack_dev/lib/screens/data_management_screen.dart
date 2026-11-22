import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../presentation/app_store.dart';
import '../presentation/glucose_style.dart';

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  bool _isLoading = false;

  final _password = TextEditingController();
  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _performAction(
    Future<void> Function() action,
    String successMessage,
  ) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(successMessage)));
      }
    } catch (error) {
      if (mounted) showAppError(context, error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Diálogo de segurança acessível para evitar exclusão acidental por idosos
  Future<void> _showDeleteConfirmation() async {
    _password.clear();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFD32F2F),
                size: 32,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Atenção Crítica!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Isso apaga os registros deste aparelho, os dados na nuvem e sua conta. A ação não pode ser desfeita. Confirme sua senha para continuar.',
              ),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha atual'),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.all(16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.black87, fontSize: 18),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final password = _password.text;
                Navigator.of(dialogContext).pop();
                _performAction(
                  () => context.read<AppStore>().deleteAccount(password),
                  'Exclusão concluída.',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Sim, Excluir',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
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
          'Segurança e Dados',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF0060C0)),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18.0,
                  vertical: 24.0,
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
                        'Gerenciamento',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Mantenha seus dados seguros na nuvem para não perdê-los se trocar de aparelho.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 32),

                      if (store.deleting)
                        const Text(
                          'Exclusão pendente. Os registros estão bloqueados para impedir novos envios. Conecte-se à internet e tente excluir novamente.',
                        ),
                      if (!store.deleting) ...[
                        // Botão 1: Backup (Upload)
                        _DataActionButton(
                          title: 'Fazer Backup Agora',
                          subtitle: 'Salvar dados atuais na nuvem',
                          icon: Icons.cloud_upload_rounded,
                          color: const Color(0xFF0060C0),
                          onTap: () => _performAction(
                            () => store.sync.syncNow(),
                            'Sincronização com a nuvem concluída.',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Botão 2: Restaurar (Download)
                        _DataActionButton(
                          title: 'Restaurar Dados',
                          subtitle: 'Baixar dados de um aparelho antigo',
                          icon: Icons.cloud_download_rounded,
                          color: const Color(
                            0xFF4CAF50,
                          ), // Verde para indicar recuperação segura
                          onTap: () => _performAction(
                            () => store.sync.syncNow(restore: true),
                            'Dados remotos incorporados ao histórico local.',
                          ),
                        ),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Divider(color: Colors.black12, thickness: 1.5),
                      ),

                      const Text(
                        'Solicitar Exclusão de Dados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD32F2F),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Botão 3: Excluir (Destrutivo)
                      _DataActionButton(
                        title: 'Excluir Meus Dados',
                        subtitle: 'Apagar tudo (Irreversível)',
                        icon: Icons.delete_forever_rounded,
                        color: const Color(0xFFD32F2F), // Vermelho alerta
                        onTap: _showDeleteConfirmation,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _DataActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DataActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Botão de ação: $title. $subtitle',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2.0),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
