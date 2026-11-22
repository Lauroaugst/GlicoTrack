# Relatório de implementação e validação - Unidade II

> As seções históricas abaixo registram 17/11 e 21/11/2026. A conferência dos PDFs e os testes de 22/11 estão registrados a seguir.

## Conferência dos PDFs e validação - 22/11/2026

Os dois PDFs foram reabertos, seu texto foi extraído e as páginas do enunciado/aditivo foram renderizadas e inspecionadas. A rastreabilidade está em `matriz-rastreabilidade.md`, com a exceção de escopo explicitamente definida para esta versão: somente telas já desenvolvidas pela equipe, sem login, cadastro, recuperação ou logout. O fluxo atual reutiliza a sessão Firebase persistida ou cria uma sessão anônima em segundo plano. `login_screen.dart`, acrescentado na integração, foi removido; o histórico e as telas da equipe foram preservados. Perfil sem e-mail e exclusão na confirmação existente foram adaptados, mantendo isolamento por UID e bloqueio contra reenvio. O formulário mantém as cores por classificação e os campos existentes.

| Verificação desta revisão | Resultado |
| --- | --- |
| `flutter analyze --no-pub` | Sem apontamentos |
| `flutter test --no-pub` | 45 testes aprovados, incluindo reutilização da sessão, criação anônima e falha de primeira conexão |
| Emuladores Auth/Firestore/Functions, projeto `demo-glicotrack` | 15 testes aprovados, incluindo perfil sem e-mail, isolamento e exclusão da sessão anônima; nenhum acesso ao Firebase real |
| `flutter build apk --debug --no-pub` | APK gerado com sucesso; avisos de versões AGP/Kotlin já conhecidos |
| Celular via ADB | Nenhum dispositivo listado nesta conferência; execução nativa pendente |
| Firebase CLI | Nenhuma conta autenticada; habilitação e implantação no projeto real não verificadas |

Métricas de host desta execução: painter de 500 pontos, p50 **4,786 ms**, p95 **6,864 ms**; cinco commits SQLite FFI em arquivo: **16,457; 6,669; 8,815; 5,882; 6,009 ms** (total **43,832 ms**). São medições de CPU/FFI sob a metodologia descrita abaixo, com possível carga concorrente do host; não comprovam GPU, três segundos de interação, SQLCipher nativo nem aparelho de 2 GB.

A primeira criação da sessão anônima exige internet; uma sessão persistida permite acesso local offline. Backup/restauração consultam somente o UID atual: reinstalação, limpeza de dados ou troca de aparelho não recuperam automaticamente a sessão anterior sem vínculo de conta. Nenhuma nova tela foi criada para contornar esse limite.

Permanecem pendentes o aceite em dispositivo (criptografia, som, compartilhamento, cinco registros sem travar, tempo de abertura/registro), teste em hardware de 2 GB, conferência do Firebase real e compreensão/defesa pelo grupo. O objetivo do estudo de caso menciona cálculo de insulina, mas não define fórmula nem parâmetros: o registro de dose aplicada está implementado, e a regra de cálculo precisa de esclarecimento antes de ser implementada. Não é uma funcionalidade concluída. Nenhum novo commit, push ou deploy foi realizado nesta revisão.

Trabalho iniciado em 16/11/2026 e finalizado em 17/11/2026 (São Paulo), diretamente no checkout existente, branch `main`, inicialmente limpo. Na entrega inicial, antes do versionamento parcial, não haviam sido feitos commits ou deploy de produção. O versionamento posterior e a integração estão registrados no histórico Git.

## Diagnóstico inicial

O Flutter existente já tinha quatro abas, identidade visual, PdfService e CustomPainter. Home/Histórico usavam mocks; o registro apenas mostrava sucesso e limpava campos; perfil e metas eram fixos; backup/restauração/exclusão eram simulados. A Splash acessava MainScreen sem autenticação, após espera artificial. Não havia Firebase, SQLite ou gerenciador de estado. O único teste era o contador padrão Flutter, incompatível com o aplicativo.

## Arquitetura e funcionalidades entregues

Domain contém registro agregado, perfil, metas, categorias, validações, classificação e estatísticas/tendências informativas. Data contém SQLite/SQLCipher, chave aleatória em secure storage, transações, fila persistente, revisões, tombstones, arquivo de conflitos e isolamento por UID. Presentation utiliza Provider/AppStore nas telas existentes. Login/cadastro/recuperação fazem parte do fluxo de entrada; Home, Registro, Perfil e Histórico permanecem como quatro abas.

Firebase foi integrado por código: inicialização configurável, Auth, transações Firestore, importação paginada, sincronização ao abrir/retomar/reconectar, retentativas, backup/restauração e callable de exclusão autenticada. Não foram criadas credenciais fictícias ou selecionado projeto real. O funcionamento em produção depende das opções reais e da implantação externa.

O SQLite possui `accounts`, `categories`, `documents` e `conflicts`, versão inicial 1, com chaves estrangeiras, índices e transações. Metadados de sincronização ficam no envelope de documentos, incluindo pendência, revisão, pai da revisão e exclusão. Migração de versão futura desconhecida falha explicitamente, sem apagar dados. A estrutura completa, regras e diagramas estão em [arquitetura-unidade-ii.md](arquitetura-unidade-ii.md).

| Tela/serviço | Integração |
| --- | --- |
| Registro | Commit local antes do sucesso; glicemia, dose aplicada, carboidratos, categoria, data/hora e observações; foco numérico, classificação, fundo por faixa e ponte de áudio |
| Home | Últimos valores por refeição, frequência diária/semanal/mensal, percentual na meta, indicadores e estado de sincronização |
| Histórico | Período/semana/mês/categoria, médias/extremos/contagem/frequência/percentual, gráfico real, PDF e CSV |
| Linha do tempo | Dados reais completos, filtros, edição no mesmo formulário e exclusões |
| Perfil | Nome, idade, peso e foto privados; metas persistidas e logout removendo pilha protegida |
| Segurança e Dados | Backup/restauração reais, senha recente para exclusão, bloqueio persistente e retentativa |
| Inicialização | Splash sem espera artificial, sessão protegida e orientação quando falta configuração Firebase |
| CustomPainter | Código existente preservado; instantes reais, escala adaptativa, metas configuradas e repintura por conteúdo |
| PdfService | Serviço existente ampliado: paciente, período, registros, doses, carboidratos, observações, gráfico e estatísticas; fontes locais |
| CSV | Escape de separadores/aspas/quebras e neutralização de fórmulas; compartilhamento nativo |

Não foi implementada calculadora clínica de insulina, diagnóstico ou recomendação de tratamento. Faltam fórmula validada e parâmetros prescritos. Os fluxos estão em [fluxos-unidade-ii.md](fluxos-unidade-ii.md).

## Ambiente e verificações executadas

Windows 11, AMD Ryzen 5 5600X (6 núcleos), RAM física reportada de 51.449.614.336 bytes (aproximadamente 47,9 GiB). Flutter 3.50.0, Dart 3.14.0, Java Temurin 21.0.13 e SDK Android local. Node 24.22.0 no host; implantação das Functions configurada para Node 22. O emulador executou com Node 24, com aviso explícito. Ferramentas/caches foram preparados em `.tools/`, ignorada pelo Git; não havia SDK móvel utilizável no início.

| Verificação | Resultado final |
| --- | --- |
| `dart format .` | Passou antes da compilação. Depois do build, encontrou caminho longo gerado pelo Gradle no Windows; fontes finais formatadas explicitamente com `dart format lib test integration_test` |
| `flutter analyze` | **No issues found** |
| `flutter test` | **41 testes passaram** |
| Testes servidor/Firebase nos emuladores | **13 passaram**: 3 unitários de exclusão, 8 regras e 2 integração Auth/Functions/Firestore |
| `npm audit` e `npm audit --omit=dev` em `functions/` | Zero vulnerabilidades após atualização de dependências e correção compatível de gRPC |
| `flutter build apk --debug` | APK Android compilado com sucesso |
| PDF | Relatório de teste gerado sem fontes externas, texto extraído, página renderizada e inspecionada: acentos, gráfico, valores e observações legíveis |
| Histórico | Captura de widget inspecionada, com dados reais de teste e componentes preservados |
| `git diff --check` | Sem erros de whitespace; aviso de conversão LF/CRLF não é erro do produto |

Os testes Flutter cobrem classificação (incluindo 70 e meta personalizada), validação, serialização, estatísticas vazias, tendências, resolução determinística, CRUD SQLite, isolamento, restauração, edição durante upload, exclusão concorrente preservando edição intermediária, cinco inserções, falha remota sem perda local, tombstones, CSV, PDF vazio/extenso, posição cronológica e repintura, foco/alerta controlado, salvamento/falha e teclado inclusive na navegação principal.

Os testes Firebase usam exclusivamente `demo-glicotrack` local. Comprovam bloqueio de acesso sem autenticação/de outra conta, rejeição de campos inválidos, timestamps de servidor, metas/perfil, imutabilidade idempotente de conflitos, bloqueio após exclusão e recusa de ressurreição. A integração invoca a callable com token emitido pelo emulador Auth, apaga registros/conflitos e a conta autenticada, preservando outra conta mesmo quando seu UID é enviado em payload malicioso. Mensagens `PERMISSION_DENIED` nos cenários negativos são esperadas.

## Métricas reais do host

Execução final de `test/performance_test.dart`. Medições de desenvolvimento no computador acima, sem controle térmico ou garantia de ausência de carga concorrente. Não são métricas de GPU nem de aparelho de 2 GB.

| Métrica | Metodologia | Resultado |
| --- | --- | --- |
| CPU do painter com 500 pontos | 210 chamadas `paint`, Canvas 360×240, 10 aquecimentos descartados, 200 amostras ordenadas de Stopwatch; Picture descartado a cada chamada | p50 **3,030 ms**, p95 **3,870 ms** |
| Cinco commits SQLite FFI em arquivo real | Banco criado antes do cronômetro, 5 transações sequenciais com validação/leitura de revisão/gravação; fechar e remover arquivo temporário depois | **16,566; 5,838; 5,504; 17,685; 4,953 ms**, total **50,546 ms** |
| Integridade das inserções | Consulta após o último commit | 5 registros; testes também verificam as 5 pendências |

SQLite FFI não utiliza SQLCipher. O painter mede gravação de comandos em CPU, não rasterização/frame GPU. Não foram medidos startup móvel, tempo total de interação, latência real da ListView, memória móvel ou quadros GPU. Esses resultados não comprovam os limites de três segundos em celular.

## Pendências e limites técnicos

1. **Firebase real:** fornecer opções, habilitar e-mail/senha/Firestore e publicar regras, índices e callable na conta do grupo. Passos exatos em [configuracao-firebase.md](configuracao-firebase.md). O APK sem essas opções mostra orientação; não oferece autenticação falsa.
2. **Execução móvel:** não realizada. `emulator -accel-check` retornou código 6, driver de hipervisor ausente; hardware reportou virtualização desativada. Não foi alterado BIOS/Windows. Nenhum aparelho físico estava disponível.
3. **Criptografia e chaves nativas:** SQLCipher/Keystore/Keychain implementados por integração, com teste `integration_test/encryption_test.dart`, ainda não executado em dispositivo. FFI não comprova criptografia.
4. **Áudio/foto/compartilhamento:** ponte e controle de repetição testados; áudio físico, seleção de foto e compartilhamento do sistema dependem de aceite em aparelho. Volume/configuração da plataforma podem limitar o som.
5. **iOS:** Podfile, configuração e ponte sonora incluídos; CocoaPods, assinatura/capabilities, compilação e execução exigem macOS/Xcode e não foram validados neste host.
6. **Dispositivo de 2 GB:** pendente; não há métricas inventadas de RAM, startup ou aparelho. O roteiro de aceite está documentado.
7. **Distribuição:** APK de depuração serve a testes. O template mantém assinatura debug para release; assinatura de produção é externa. O build atual passou com avisos de futura descontinuação de AGP/Kotlin e avisos Java/unchecked de dependências.
8. **Conflitos:** versões divergentes são preservadas; não há tela de recuperação do arquivo. Recuperação exige ferramenta administrativa autorizada. Trava técnica remota conserva somente UID/estado para impedir reenvio de outro aparelho offline, sem prontuário; revisar política de retenção antes de produção.
9. **Produto:** sem dose clínica, diagnóstico, acesso compartilhado entre contas ou garantia de sincronização com processo encerrado. Históricos extensos e acessibilidade com personas exigem aceite adicional.

## Rastreabilidade e documentação

Todos os RF01-RF17 e RNF01-RNF21 têm módulo, evidência e situação em [matriz-rastreabilidade.md](matriz-rastreabilidade.md). Criptografia/áudio nativos, produção, startup, hardware de 2 GB e aceite com usuários não foram marcados como totalmente validados. Diagramas, EAP/sprints e registro de IA incluídos; referências anteriores e responsabilidades reais preservadas.

## Inventário de alterações

Caminhos relativos à raiz do repositório. SDKs, caches, logs, capturas e PDFs de QA em `.tools/` não são código-fonte versionável. APK: `glicotrack_dev/build/app/outputs/flutter-apk/app-debug.apk`.

### Modificados

- `.gitignore`
- `CHANGELOG.md`
- `README.md`
- `docs/justificativas.md`
- `docs/requisitos.md`
- `glicotrack_dev/android/app/build.gradle.kts`
- `glicotrack_dev/android/app/src/main/AndroidManifest.xml`
- `glicotrack_dev/android/app/src/main/kotlin/com/example/glicotrack_dev/MainActivity.kt`
- `glicotrack_dev/android/gradle/wrapper/gradle-wrapper.properties`
- `glicotrack_dev/android/settings.gradle.kts`
- `glicotrack_dev/ios/Runner/AppDelegate.swift`
- `glicotrack_dev/ios/Runner/Info.plist`
- `glicotrack_dev/lib/main.dart`
- `glicotrack_dev/lib/screens/data_management_screen.dart`
- `glicotrack_dev/lib/screens/history_screen.dart`
- `glicotrack_dev/lib/screens/home_screen.dart`
- `glicotrack_dev/lib/screens/main_screen.dart`
- `glicotrack_dev/lib/screens/personal_info_screen.dart`
- `glicotrack_dev/lib/screens/profile_hub_screen.dart`
- `glicotrack_dev/lib/screens/profile_settings_screen.dart`
- `glicotrack_dev/lib/screens/register_screen.dart`
- `glicotrack_dev/lib/screens/splash_screen.dart`
- `glicotrack_dev/lib/screens/timeline_screen.dart`
- `glicotrack_dev/lib/services/pdf_service.dart`
- `glicotrack_dev/pubspec.lock`
- `glicotrack_dev/pubspec.yaml`
- `glicotrack_dev/test/widget_test.dart`

### Criados

- `docs/arquitetura-unidade-ii.md`
- `docs/configuracao-firebase.md`
- `docs/fluxos-unidade-ii.md`
- `docs/matriz-rastreabilidade.md`
- `docs/planejamento-unidade-ii.md`
- `docs/uso-de-ia.md`
- `docs/validacao-unidade-ii.md`
- `firebase.json`
- `firestore.indexes.json`
- `firestore.rules`
- `functions/deletion.js`
- `functions/index.js`
- `functions/package-lock.json`
- `functions/package.json`
- `functions/test/deletion.test.js`
- `functions/test/firebase.integration.test.js`
- `functions/test/firestore.rules.test.js`
- `glicotrack_dev/android/app/src/main/res/xml/data_extraction_rules.xml`
- `glicotrack_dev/assets/fonts/LICENSE`
- `glicotrack_dev/assets/fonts/NotoSans-Bold.ttf`
- `glicotrack_dev/assets/fonts/NotoSans-Regular.ttf`
- `glicotrack_dev/integration_test/encryption_test.dart`
- `glicotrack_dev/ios/Podfile`
- `glicotrack_dev/lib/data/firebase_bootstrap.dart`
- `glicotrack_dev/lib/data/firebase_repository.dart`
- `glicotrack_dev/lib/data/local_database.dart`
- `glicotrack_dev/lib/data/sync_service.dart`
- `glicotrack_dev/lib/domain/models.dart`
- `glicotrack_dev/lib/domain/repositories.dart`
- `glicotrack_dev/lib/domain/sync_document.dart`
- `glicotrack_dev/lib/presentation/app_store.dart`
- `glicotrack_dev/lib/presentation/glucose_style.dart`
- `glicotrack_dev/lib/presentation/history_summary.dart`
- `glicotrack_dev/lib/screens/auth_gate.dart`
- `glicotrack_dev/lib/screens/login_screen.dart`
- `glicotrack_dev/lib/services/csv_service.dart`
- `glicotrack_dev/lib/services/hypo_alert.dart`
- `glicotrack_dev/test/domain_test.dart`
- `glicotrack_dev/test/export_chart_test.dart`
- `glicotrack_dev/test/local_database_test.dart`
- `glicotrack_dev/test/performance_test.dart`
- `glicotrack_dev/test/support/fixtures.dart`
- `glicotrack_dev/test/support/memory_repository.dart`
- `glicotrack_dev/test/sync_test.dart`



## Integração da branch em 21/11/2026

Base atualizada por fast-forward de `61f3be0` até `00086b0`, preservando os 24 commits publicados pela equipe. As alterações locais restantes foram copiadas e verificadas antes da atualização, além de mantidas em stash local. Seis conflitos de conteúdo ocorreram em `main.dart`, MainScreen, Splash, Registro, Histórico e linha do tempo; foram resolvidos na integração, sem reescrever commits remotos.

O `firebase_options.dart` publicado pelo grupo foi preservado sem alteração. `initializeFirebase` agora utiliza essas opções; `AppBootstrap` foi reaproveitado para criar os serviços depois da verificação de autenticação. Provider/AppStore centraliza estado, leitura e atualização das telas, evitando iniciar a mesma sincronização duas vezes. A sessão anônima anterior pode ser vinculada a e-mail/senha, mantendo seu UID e registros; não é criada outra conta anônima automaticamente.

A exibição de refeição, insulina, carboidratos e observações foi mantida na linha do tempo. O teste de interface comprova que ela atualiza após editar/excluir uma medição. O carregamento e os erros ficam no estado compartilhado, corrigindo as referências fora de escopo identificadas no Histórico da branch. O formulário continua confirmando somente após o commit SQLite.

### Verificações desta integração

| Verificação | Resultado em 21/11/2026 |
| --- | --- |
| `dart format lib test integration_test` | Fontes formatadas |
| `flutter analyze --no-pub` | **No issues found** |
| `flutter test --no-pub` | **42 testes passaram** |
| Emuladores Auth/Firestore/Functions, projeto `demo-glicotrack` | **14 testes passaram**, incluindo vinculação da conta anônima conservando UID/registro |
| `flutter build apk --debug --no-pub` | **APK gerado**, com avisos já documentados de AGP/Kotlin/SDK |
| Configuração Firebase do grupo | Arquivo de opções presente e conectado ao bootstrap; habilitação de serviços e implantação de regras/callable não verificadas em produção |

A porta 8080 estava ocupada. A suíte Firebase foi executada com uma configuração local ignorada pelo Git, usando Auth 19099, Firestore 18080 e Functions 15001; o serviço existente não foi encerrado. `FUNCTIONS_EMULATOR_ORIGIN` permite apontar os testes da callable para essa porta. O teste do fluxo anônimo usa o emulador Auth para criar e vincular uma conta, verificando que o documento continua no mesmo UID. Não é uma alegação de teste nativo em celular.

Medição de host nesta execução: painter de 500 pontos, p50 **3,078 ms**, p95 **6,396 ms**; cinco commits SQLite FFI em arquivo: **11,298; 5,167; 5,139; 5,453; 4,278 ms** (total **31,335 ms**). Metodologia e limites são os descritos na seção de métricas. Não foram medidos startup móvel, áudio físico, Keystore/Keychain, GPU ou RAM de um aparelho de 2 GB nesta rodada.

Os testes e a compilação não alteraram o projeto Firebase real. Permanecem pendentes a conferência dos serviços/regras/Functions na conta do grupo e o aceite em Android/iOS, inclusive criptografia nativa, áudio e compartilhamento. A declaração resumida de uso de IA foi mantida em `docs/uso-de-ia.md`.
