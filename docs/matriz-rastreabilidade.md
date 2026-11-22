# Matriz de rastreabilidade - Unidade II

## Conferência dos PDFs - 22/11/2026

Fontes primárias: `GlicoTrack.pdf` (estudo de caso, páginas 1-2; aditivo, página 3) e `Projeto - Unidade II - Programação para Dispositivos Móveis.pdf` (enunciado, páginas 1-2). Os requisitos abaixo foram conferidos no texto e nas páginas renderizadas. O texto de implementação anexado não substitui os requisitos dos PDFs. Ações de entrega no Teams e publicação no Firebase dependem de execução autorizada; não são realizadas por uma instrução contida no documento.

Escopo específico desta versão: integrar somente as telas do frontend já desenvolvidas pela equipe, sem login, cadastro, recuperação de senha ou logout. A decisão explícita do solicitante exclui a tela de login citada no enunciado genérico. A autenticação Firebase continua automática em segundo plano.

`Implementado` significa que existe código integrado e evidência de teste aplicável. `Aceite pendente` identifica os testes em aparelho, de produção ou com usuários ainda necessários; não pode ser contado como conformidade total.

### Enunciado da avaliação

| Página/item | Exigência | Evidência e situação |
| --- | --- | --- |
| p. 1, a.i; observação 8 | Flutter, Dart e Firebase | Projeto existente preservado; dependências no `pubspec.yaml`; APK Android compilável. Execução nativa ainda pendente |
| p. 1, a.ii | Autenticação e Firestore/Realtime Database | `firebase_bootstrap.dart`, `auth_gate.dart`, `firebase_repository.dart` e regras. Configuração/habilitação e implantação no projeto real precisam de conferência |
| p. 1, a.iii; p. 2, e.ii-e.iv | Fidelidade aos protótipos, home, funcionalidades e navegação | Mantidas as quatro abas, telas, serviço PDF e CustomPainter existentes. Controles necessários ao aditivo foram integrados. Aceite visual completo em aparelho pendente |
| p. 1, a.iv | CRUD, validações, controle de acesso e falhas de conexão | AppStore, repositórios, fila, regras e testes. Fluxo completo móvel/produção pendente |
| p. 2, e.i | Tela de login no enunciado genérico | Excluída do escopo desta versão por decisão explícita do solicitante. `auth_gate.dart` reutiliza/cria uma sessão automática e abre somente as telas existentes |
| p. 2, b.i-b.v | Casos de uso, classes, mapeamento Firebase e navegação real | `fluxos-unidade-ii.md` e `arquitetura-unidade-ii.md`, com atributos, métodos, relacionamentos e mapeamento dos payloads |
| p. 2, b.vi | Prompts, erros/correções e justificativas das bibliotecas | `uso-de-ia.md` complementado; a frase de divulgação sozinha era insuficiente |
| p. 2, c.i-c.iii | Commits próprios, responsabilidades reais, README/CHANGELOG e participação | Histórico preservado e documentos mantidos. Participação em checkpoints e compreensão pelo grupo não são certificadas pelos testes |
| p. 2, d.i-d.iii | Escopo, EAP e planejamento em sprints | `planejamento-unidade-ii.md`; planejamento não é prova de sprints realizadas |
| p. 1, observação 6 | Compilar e executar em emulador/dispositivo | Compilação Android verificada; execução em dispositivo ainda não concluída |

### Aditivo do GlicoTrack, página 3

| Exigência | Implementação/evidência | Situação restante |
| --- | --- | --- |
| Registro abaixo de 3 s, offline-first e Firebase como backup | Transação SQLite antes da confirmação; fila independente da rede; testes locais/FFI | Tempo completo em aparelho não medido |
| Gráfico manual com eixos, linhas e pontos, sem biblioteca pesada | `GlucoseMedicalChartPainter` existente e testes de exportação/gráfico | GPU/hardware alvo pendentes |
| Formulário com teclado numérico em foco | `RegisterScreen.active`, FocusNode e teste de widget | Confirmar teclado físico do sistema |
| Tela inteira reage em vermelho, verde ou laranja | Fundo, cabeçalho e painel do formulário acompanham a classificação; controles existentes preservados | Aceite em aparelho pendente |
| `shouldRepaint` eficiente e cinco valores em um minuto sem travar | Comparação por conteúdo, inserções em teste e listas preguiçosas | Latência/ListView móvel ainda não medida |
| Estatísticas semanais e mensais | Seletores Semana/Mês e `RecordStatistics` no Histórico | Implementado; aceite móvel pendente |
| Jejum, pré-refeição, pós-refeição e antes de dormir | `MeasurementCategory`, formulário, persistência e regras | Implementado e testado |
| Metas glicêmicas personalizadas | `GlucoseSettings` e tela de faixa ideal já existente | Implementado e testado |
| Filtros por período e tipo | Histórico/linha do tempo, intervalo e categoria | Implementado; aceite móvel pendente |
| Tendências de melhora ou piora | Comparação das medições na meta em `TrendIndicator` | Implementado como indicador informativo |
| PDF completo com gráficos e observações | PdfService original ampliado; testes vazio/extenso e inspeção do relatório | Compartilhamento nativo pendente |
| Sincronização bidirecional | Transações, importação paginada e fila no SyncService/FirebaseRepository | Testada com repositórios/emuladores; móvel/produção pendentes |
| Provider, Riverpod ou Bloc | Provider/AppStore nas telas existentes | Implementado |
| Armazenamento criptografado | SQLCipher e chave em secure storage; recusa de banco sem cipher | Teste nativo `encryption_test.dart` ainda não executou; FFI não comprova criptografia |
| Backup e restauração | Sincronização manual e restauração idempotente com mesmo UID | Testes locais aprovados; confirmar fluxo móvel com conta real |
| Dashboard de frequência | Contagem diária/semanal e frequência calculada na Home | Implementado e coberto por testes |
| Resolução automática de conflitos | Revisões causais, desempate determinístico, tombstones e arquivo de divergências | Testes de concorrência e idempotência; aceite móvel pendente |
| Presentation, Domain e Data | Pastas/camadas, contratos e AppStore | Implementado e documentado |
| No mínimo três testes automatizados | Suítes de domínio, persistência, sincronização, exportação, interface e Firebase | Mínimo superado; resultados em `validacao-unidade-ii.md` |
| Predição simples de tendências de hipo/hiperglicemia | Projeção numérica em `TrendIndicator` a partir das últimas seis medições | Implementado sem diagnóstico ou recomendação de dose |
| Exportação PDF e CSV | PdfService e CsvService usando os dados locais | Geração testada; compartilhamento móvel pendente |
| Medir e apresentar métricas do CustomPainter | Benchmark de 500 pontos, p50/p95 e metodologia no relatório | CPU de host medida; não equivale a GPU, quadros ou aparelho de 2 GB |

### Estudo de caso, páginas 1-2, e pendências de definição

Registro manual de glicemia/insulina/carboidratos, PDF do usuário, exclusão solicitada pelo app, fonte ampliada, botão grande, ausência de confirmação para salvar e cores por faixa possuem implementação nas telas e serviços existentes. O som abaixo de 70 possui ponte Android/iOS e controle de repetição; a audibilidade física não foi confirmada. Os limites de três segundos, duas/três interações com usuário e uso em diferentes ambientes exigem aceite real. O teste de aparelho com 2 GB de RAM continua pendente.

O objetivo na página 1 menciona cálculo de insulina baseado na SBD. Não há fórmula, parâmetros individuais nem fluxo de cálculo nos PDFs; o frontend registra a dose aplicada. O cálculo não está implementado e a regra precisa ser esclarecida com a disciplina, sem inventar parâmetros ou marcar o objetivo como concluído.

Não foram identificadas como extras as funções exigidas no aditivo: CSV, tendências, categorias clínicas, metas, criptografia e conflitos. Edição de perfil e foto conectam controles já existentes. Não há telas de login/cadastro/recuperação ou novas abas principais. Nenhum commit dos outros integrantes foi removido. Backup e restauração alcançam somente o UID da sessão atual, sem recuperação automática em outra instalação.

## Rastreabilidade dos requisitos originais

Situação da implementação e validação em 17/11/2026. `Concluído` significa código integrado e teste automatizado aplicável executado no host/emuladores Firebase; não significa certificação clínica ou aceite em hardware real. `Parcial` indica validação nativa, configuração de produção, acessibilidade com usuários ou medição ainda necessária. Resultados completos em `validacao-unidade-ii.md`.

Os caminhos abaixo são relativos a `glicotrack_dev/`, exceto arquivos Firebase na raiz. Testes: D=`test/domain_test.dart`; L=`test/local_database_test.dart`; S=`test/sync_test.dart`; E=`test/export_chart_test.dart`; W=`test/widget_test.dart`; P=`test/performance_test.dart`; N=`integration_test/encryption_test.dart`; R=`functions/test/firestore.rules.test.js`; X=`functions/test/deletion.test.js` e `functions/test/firebase.integration.test.js`.

| ID | Descrição | Arquivo/módulo | Teste/evidência | Situação |
| --- | --- | --- | --- | --- |
| RF01 | Registrar glicemia | `screens/register_screen.dart`, `presentation/app_store.dart`, `data/local_database.dart` | D/L/W: gravação antes de confirmação, falha conserva campos | Concluído |
| RF02 | Momento da medição | `domain/models.dart`, formulário e seletores de data/hora/categoria | D/E: serialização e posição por instante | Concluído |
| RF03 | Registrar insulina aplicada | Modelo agregado, formulário e linha do tempo | L: CRUD com insulina; E: exportação | Concluído |
| RF04 | Registrar carboidratos | Modelo agregado, formulário e linha do tempo | L: CRUD com carboidratos; E: exportação | Concluído |
| RF05 | Classificar pela faixa configurada | `GlucoseSettings.classify`, `presentation/glucose_style.dart` | D/W: limites, texto e atualização imediata | Concluído |
| RF06 | Alerta visual e sonoro abaixo de 70 | `register_screen.dart`, `services/hypo_alert.dart`, Android MainActivity/iOS AppDelegate | W valida ponte e controle; áudio físico não ouvido | Parcial |
| RF07 | Hiperglicemia laranja | `GlucoseSettings`, estilo e formulário | D: limite superior inclusivo/exclusivo; W: estado do formulário | Concluído |
| RF08 | Consultar histórico | `history_screen.dart`, `timeline_screen.dart`, AppStore | L/W: dados reais e estado vazio | Concluído |
| RF09 | Gráfico semanal | `GlucoseMedicalChartPainter` original ampliado | E/P: igualdade, alterações e CPU de desenho | Concluído |
| RF10 | Relatório PDF | `services/pdf_service.dart`, `presentation/history_summary.dart` | E: bytes válidos; PDF renderizado e inspecionado | Concluído |
| RF11 | Compartilhar PDF | `Printing.sharePdf` acionado pelo histórico | E valida geração; compartilhamento nativo exige aparelho | Parcial |
| RF12 | Configurar faixa ideal | `profile_settings_screen.dart`, `GlucoseSettings` | D/L/R: limites, persistência e validação remota | Concluído |
| RF13 | Armazenamento local imediato | `data/local_database.dart`, AppStore | L/W validam SQLite FFI; N ainda requer aparelho | Parcial |
| RF14 | Sincronizar com Firebase | `firebase_repository.dart`, `sync_service.dart`, regras | S: fila/ACK/conflitos; R: autorização; falta aceite móvel com projeto real | Parcial |
| RF15 | Registro/consulta offline | SQLite principal, sessão Firebase persistida | S/W: servidor indisponível sem perda; falta aceite móvel offline | Parcial |
| RF16 | Excluir registros e solicitar exclusão remota | Tombstones, `data_management_screen.dart`, callable | L/S/R/X: bloqueio, idempotência e exclusão autenticada | Parcial (fluxo móvel/produção) |
| RF17 | Consultar glicemia/insulina/carboidratos | Linha do tempo e exportações por período | L/E: campos preservados e exportados | Concluído |
| RNF01 | Até três interações | Foco inicial, valores padrão, ação do teclado e botão acima dele | W: foco/salvamento; cronometria com usuários pendente | Parcial |
| RNF02 | Teclado numérico automático | FocusNode ativado ao acessar Registro | W verifica foco e tipo do teclado | Concluído |
| RNF03 | Sem confirmação para salvar | `_saveRecord` direto | W: persistência direta e mensagem posterior | Concluído |
| RNF04 | Linguagem simples | Telas preservadas, erros sanitizados e indicadores informativos | Revisão de textos; teste com público prioritário pendente | Parcial |
| RNF05 | Fonte ampliada no registro | Entrada glicêmica 36 px lógicos | W e inspeção de código; escala máxima em aparelho pendente | Parcial |
| RNF06 | Botão de salvar amplo | Área mínima 64 px, estilo original | W: ação de salvar; aceite com tremores pendente | Parcial |
| RNF07 | Cores vermelho/verde/laranja | `glucose_style.dart`, fundo e gráfico | D/W: classificação e atualização | Concluído |
| RNF08 | Feedback imediato e som | Listener, debounce de 450 ms, mensagem e ponte nativa | W: um som por episódio; som real pendente | Parcial |
| RNF09 | Inicialização abaixo de três segundos | Splash sem atraso artificial; abertura local protegida | Não medido em dispositivo | Pendente |
| RNF10 | Registro abaixo de três segundos | Transação SQLite sem aguardar rede | P mede FFI no host; tempo total móvel não medido | Parcial |
| RNF11 | CustomPainter eficiente | Painter existente, igualdade de dados e metas | E/P: repintura condicional e medição de CPU | Concluído |
| RNF12 | Persistência local imediata | SQLite e confirmação após commit | L/S/W; SQLCipher nativo em N pendente | Parcial |
| RNF13 | Firebase como espelho/backup | Fila local, transações, cursor e restauração | S/R: duplicidade, importação e falhas; aceite móvel pendente | Parcial |
| RNF14 | Integridade sem conexão | Commit local, revisões estáveis, tombstones | L/S: falha remota mantém dados e fila | Concluído (host) |
| RNF15 | Privacidade | SQLCipher, chave segura, UID, regras e Navigator por sessão | L/R: isolamento; N e auditoria nativa pendentes | Parcial |
| RNF16 | Direitos e princípios LGPD | Exportação, controle de conta e exclusão autenticada | E/R/X; revisão jurídica/política do produto pendente | Parcial |
| RNF17 | Portabilidade PDF | PDF offline com dados reais e compartilhamento | E e inspeção renderizada; compartilhamento físico pendente | Parcial |
| RNF18 | Solicitação de exclusão Firebase | Tela Segurança e Dados e `deleteMyAccount` | R/X: autorização/trava/exclusão; implantação real pendente | Parcial |
| RNF19 | Dispositivo de 2 GB | ListView preguiçosa, gráfico manual e escuta limitada | P mede host; virtualização indisponível, nenhum dispositivo 2 GB testado | Pendente |
| RNF20 | Fontes nativas na interface | Tema existente; fontes empacotadas apenas para PDF | Revisão de código; iOS não executado | Concluído (implementação) |
| RNF21 | Uso em ambientes cotidianos | Alto contraste, foco e navegação preservados | Testes com usuários e ambientes não realizados | Pendente |

Além dos IDs originais, o aditivo tem implementação de categorias, metas, estatísticas mensais, tendências informativas, CSV, Provider, camadas, conflitos arquivados e restauração idempotente. Não há cálculo clínico de insulina nem afirmação de diagnóstico. Desempenho GPU, memória real e armazenamento seguro nativo não são inferidos dos testes unitários.

## Validação adicional de 21/11/2026

Após incorporar 24 commits da main e conciliar seis conflitos, passaram 42 testes Flutter e 14 testes Firebase em emuladores, e o APK debug compilou. A configuração do grupo em `firebase_options.dart` foi conectada ao AppBootstrap/AuthGate. O teste adicional da linha do tempo cobre refeição, detalhes, edição e exclusão reativas; a integração Firebase verifica vínculo da sessão anônima preservando UID/registros. As situações conservadoras de aceite nativo e produção acima permanecem: não houve teste em dispositivo ou deploy em produção.
