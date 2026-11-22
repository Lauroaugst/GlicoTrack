# Uso de inteligência artificial

A inteligência artificial foi utilizada como ferramenta de apoio na criação, adaptação e correção do código e da documentação do GlicoTrack.

## Solicitações utilizadas

| Solicitação | Aplicação e resultado verificável |
| --- | --- |
| Implementar o backend e integrá-lo às telas existentes | Modelos e validações em `lib/domain`, SQLite e Firebase em `lib/data`, Provider/AppStore nas telas existentes, sem outro projeto Flutter |
| “quero fazer o commit do resto do back, confira as novas atualizações da branch e me ajude como poderia commitar.” | Comparação com os 24 commits da main até `00086b0`, conciliação de seis conflitos e integração em `c793a49`, preservando os commits anteriores |
| “tem como validar a integração? ta tudo rodando? falta algo?” | Análise estática, testes Flutter, testes nos emuladores Firebase e compilação Android; identificação das verificações nativas e de produção ainda pendentes |
| “não remova nada do commit dos outros” | Conferência da origem da tela de login e das alterações locais; preservação do histórico e das funcionalidades dos outros integrantes |
| “devemos alinhar com esses documents, nada a mais e nada a menos” | Releitura dos dois PDFs e rastreabilidade por página/item na matriz; exceção de escopo para login registrada após o esclarecimento específico desta versão |
| “so quero que tenha as telas do front que os outros commitaram” | Remoção do login/cadastro/recuperação e da ação de logout acrescentados pela IA; restauração da sessão automática já utilizada pela equipe |

As solicitações de validação e conferência dos documentos ajudaram a distinguir implementação, resultado de teste e aceite ainda pendente. Não são evidência de revisão ou domínio do código por todos os integrantes.

## Erros e correções

| Erro identificado no apoio da IA | Correção | Evidência e limite |
| --- | --- | --- |
| Criar e depois restabelecer login com base no enunciado genérico sem respeitar a definição específica da interface desta versão | Removida a tela acrescentada pela IA e preservadas somente as telas existentes, com sessão automática Firebase em segundo plano | `screens/auth_gate.dart` e `services/app_bootstrap.dart`; nenhuma reescrita do histórico Git |
| Tratar a frase resumida de uso de IA como documentação suficiente para a avaliação | Acrescentadas solicitações, erros/correções e justificativas técnicas | Este arquivo atende aos tópicos do item b.vi; o grupo ainda precisa revisar e compreender o material |
| Usar resultados de compilação e testes de host como resposta insuficiente à pergunta sobre funcionamento completo | Separados testes executados de validações móveis/produção pendentes | `validacao-unidade-ii.md` e `matriz-rastreabilidade.md`; sem afirmar criptografia nativa, áudio físico ou desempenho de aparelho de 2 GB com base em testes FFI |

## Justificativa das bibliotecas

| Biblioteca | Finalidade e motivo da escolha |
| --- | --- |
| `firebase_core`, `firebase_auth`, `cloud_firestore` | Inicialização, autenticação e banco Firebase exigidos pela disciplina; reutilização da configuração publicada pelo grupo |
| `provider` | Gerenciamento de estado previsto no aditivo, compatível com as telas e com `ChangeNotifier` |
| `sqflite_sqlcipher`, `sqflite_common` | SQLite como armazenamento principal e criptografia nativa dos registros; manutenção da API de consultas/transações |
| `flutter_secure_storage` | Guarda da chave aleatória do banco em armazenamento seguro da plataforma |
| `connectivity_plus` | Disparo de nova tentativa de sincronização; a disponibilidade de rede não é tratada como prova de acesso ao servidor |
| `uuid`, `path` | Identificadores estáveis sem duplicidade na sincronização e composição de caminhos locais |
| `pdf`, `printing` | Ampliação do gerador PDF já existente e compartilhamento nativo, sem um segundo mecanismo de relatórios |
| `share_plus` | Compartilhamento do CSV exigido no aditivo |
| `image_picker` | Conexão do controle de foto já existente na tela de dados pessoais |
| `material_ui` | Compatibilidade dos componentes Material com o SDK utilizado, preservando os componentes do frontend |
| `cloud_functions`, `firebase-functions`, `firebase-admin` | Exclusão autenticada dos dados remotos, usando o UID verificado no servidor e bloqueio contra reenvio |
| `flutter_test`, `integration_test`, `sqflite_common_ffi`, `@firebase/rules-unit-testing` | Testes de domínio/interface, persistência no host, criptografia em aparelho e autorização nos emuladores; cada resultado possui limites distintos |

O gráfico do aplicativo continua usando `CustomPainter`, sem biblioteca gráfica adicional. As fontes empacotadas são usadas apenas no PDF offline; o tema da interface conserva a configuração existente.

## Validação e compreensão pelo grupo

Os resultados e os comandos estão em `validacao-unidade-ii.md` e `configuracao-firebase.md`. Nenhum teste local comprova por si só o funcionamento no Firebase real. A defesa oral e a compreensão do código são responsabilidades do grupo e não foram certificadas por esta documentação.
