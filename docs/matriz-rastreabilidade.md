# Matriz de rastreabilidade - Unidade II

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
