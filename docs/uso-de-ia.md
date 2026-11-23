# Uso de inteligência artificial

A inteligência artificial foi utilizada como ferramenta de apoio em duas frentes principais do GlicoTrack: na tradução das telas do protótipo de alta fidelidade do Figma para o frontend em Flutter (com apoio do **Gemini**) e, posteriormente, na implementação, integração e validação do backend e da documentação técnica.

## Criação do frontend a partir das telas do Figma

A construção das interfaces em `glicotrack_dev/lib/screens/` partiu do protótipo de alta fidelidade criado no Figma (registrado em `docs/prototipoAltaFidelidade.pdf`) em conjunto com as diretrizes visuais e funcionais de `docs/justificativas.md` e `docs/requisitos.md`.

O fluxo de trabalho adotado com o **Gemini** seguiu quatro etapas iterativas:

1. **Entrada visual + contexto técnico:** para cada tela, foram anexados prints/capturas das telas do Figma junto com a descrição explícita das regras da interface — paleta de alto contraste (fundo `#E3F1FD`, azul primário `#0060C0`, cartões brancos e cores de alerta `#F44336` para hipoglicemia, `#4CAF50` para faixa normal e `#FF9800` para hiperglicemia), tipografia ampliada, áreas de toque estendidas e acessibilidade (WCAG AAA, `Semantics` e respeito a `MediaQuery.disableAnimations`).
2. **Geração incremental da estrutura base:** primeiro foi gerada a casca principal do aplicativo (`MainScreen` com barra de navegação inferior flutuante e `SplashScreen`), garantindo navegação entre as quatro abas principais sem perda de estado (`_FadeIndexedStack` baseado em `IndexedStack`).
3. **Construção modular por tela:** cada tela do protótipo (`HomeScreen`, `RegisterScreen`, `HistoryScreen`, `TimelineScreen`, `ProfileHubScreen`, `PersonalInfoScreen`, `ProfileSettingsScreen` e `DataManagementScreen`) e o serviço inicial `PdfService` foram gerados separadamente com dados mockados e widgets privados reutilizáveis, facilitando a divisão entre os integrantes (commits `02a5b0f` a `d8c86a3`) e a substituição posterior dos mocks pelo `AppStore`/`Provider`.
4. **Revisão visual e ajustes iterativos:** o código gerado era executado, comparado diretamente com os prints do Figma e refinado tanto por novos prompts direcionados quanto por edição manual do grupo para corrigir layout, contraste e comportamento do gráfico.

## Prompts e solicitações mais eficientes

### Frontend (Figma → Flutter com Gemini)

Os prompts mais eficientes nessa etapa combinaram **anexo do print da tela do Figma + restrições técnicas objetivas + pedido incremental por componente**, evitando pedidos genéricos como “crie o app inteiro”:

| Prompt / Estratégia utilizada no Gemini | Por que foi eficiente | Aplicação e resultado verificável |
| --- | --- | --- |
| *\[Com print do Figma anexado\]* “Crie em Flutter a estrutura base de navegação (`MainScreen`) com barra inferior flutuante arredondada para 4 abas (Home, Registro, Perfil e Histórico), preservando o estado das telas com `IndexedStack`, transição suave de opacidade e respeito à redução de movimento do sistema (`MediaQuery.disableAnimations`), além de `Semantics` em cada ícone.” | Definiu de imediato a arquitetura de navegação, o padrão de acessibilidade e a fidelidade ao componente flutuante do Figma, evitando reconstrução desnecessária das abas | `screens/main_screen.dart` (`_FadeIndexedStack`, `_SharedBottomNavBar`) e `screens/splash_screen.dart` (commits `02a5b0f`, `5f2607c`) |
| *\[Com print da tela do Figma anexado\]* “Implemente esta tela em Flutter seguindo fielmente o layout da imagem, usando fundo `#E3F1FD`, destaque `#0060C0`, cartões brancos com bordas arredondadas, fontes grandes de alto contraste para idosos e áreas de toque mínimas de 48–64 px. Separe os blocos em widgets privados e use modelos mockados temporários para facilitar a integração futura com banco de dados.” | Travar a paleta hexadecimal, a hierarquia tipográfica e a separação entre UI e mocks reduziu divergências visuais em relação ao Figma e evitou reescrever a interface na etapa do backend | `screens/home_screen.dart`, `screens/register_screen.dart`, `screens/profile_hub_screen.dart`, `screens/personal_info_screen.dart`, `screens/profile_settings_screen.dart` e `screens/data_management_screen.dart` |
| *\[Com print da tela de Histórico anexado\]* “Crie o gráfico de linha de glicemia usando `CustomPainter` nativo do Flutter (sem bibliotecas externas de gráfico) para manter leveza em celulares com 2 GB de RAM. Desenhe faixas horizontais translúcidas para hipoglicemia (< 70 mg/dL em vermelho), faixa normal (verde) e hiperglicemia (laranja), além de rótulos nos eixos X e Y e seletor nativo de intervalo de datas.” | A restrição explícita contra pacotes externos impediu sugestões pesadas e garantiu aderência direta ao requisito de desempenho e ao `docs/justificativas.md` | `screens/history_screen.dart` (`_GlucoseCustomChart`, `GlucoseMedicalChartPainter`, `_pickDateRange`) e `services/pdf_service.dart` |
| *\[Com print da tela de Linha do Tempo / relato de corte visual\]* “Ajuste os cards de medição para evitar `RenderFlex overflow` em telas menores, aplicando `Flexible`/`Expanded` nos textos de contexto, espaçamento consistente entre cartões e `padding` inferior suficiente para o último item não ficar encoberto pela barra de navegação flutuante.” | Prompts curtos e focados em um defeito visual específico produziram correções pontuais sem descaracterizar o layout já aprovado do Figma | `screens/timeline_screen.dart`, `screens/history_screen.dart` e ajustes visuais consolidados nos commits `0820d31` e `02c137e` |

**Padrões que elevaram a eficiência dos prompts no frontend:**
- Enviar o print da tela do Figma acompanhado dos códigos hexadecimais e tamanhos mínimos de fonte/toque, em vez de depender apenas da interpretação visual automática.
- Solicitar uma tela por vez com widgets modulares e dados mockados desacoplados, facilitando testes rápidos e revisão por cada integrante.
- Descrever restrições de engenharia no mesmo prompt (ex.: uso obrigatório de `CustomPainter`, `SingleChildScrollView`, `SafeArea` e `Semantics`).

### Backend, integração e validação

| Solicitação | Aplicação e resultado verificável |
| --- | --- |
| Implementar o backend e integrá-lo às telas existentes | Modelos e validações em `lib/domain`, SQLite e Firebase em `lib/data`, Provider/AppStore nas telas existentes, sem outro projeto Flutter |
| “quero fazer o commit do resto do back, confira as novas atualizações da branch e me ajude como poderia commitar.” | Comparação com os 24 commits da main até `00086b0`, conciliação de seis conflitos e integração em `c793a49`, preservando os commits anteriores |
| “tem como validar a integração? ta tudo rodando? falta algo?” | Análise estática, testes Flutter, testes nos emuladores Firebase e compilação Android; identificação das verificações nativas e de produção ainda pendentes |
| “não remova nada do commit dos outros” | Conferência da origem da tela de login e das alterações locais; preservação do histórico e das funcionalidades dos outros integrantes |
| “devemos alinhar com esses documents, nada a mais e nada a menos” | Releitura dos dois PDFs e rastreabilidade por página/item na matriz; exceção de escopo para login registrada após o esclarecimento específico desta versão |
| “so quero que tenha as telas do front que os outros commitaram” | Remoção do login/cadastro/recuperação e da ação de logout acrescentados pela IA; restauração da sessão automática já utilizada pela equipe |

As solicitações de validação e conferência dos documentos ajudaram a distinguir implementação, resultado de teste e aceite ainda pendente. Não são evidência de revisão ou domínio do código por todos os integrantes.

## Erros gerados pela IA e correções aplicadas

| Etapa | Erro identificado no apoio da IA | Correção realizada pelo grupo | Evidência e limite |
| --- | --- | --- | --- |
| Frontend | Problemas de layout e responsividade: `overflow` em linhas com textos maiores, espaçamento insuficiente entre cards e itens inferiores encobertos pela barra de navegação flutuante (`extendBody: true`) | Inclusão de `SingleChildScrollView`, `Flexible`/`Expanded`, `padding` inferior reservado (ex.: `bottom: 120.0` no Histórico) e revisão manual de margens, bordas arredondadas e alinhamento nos cards | `screens/main_screen.dart`, `screens/history_screen.dart`, `screens/timeline_screen.dart`, `screens/profile_hub_screen.dart` e commits `0820d31` e `02c137e` |
| Frontend | Problemas no gráfico `CustomPainter`: escala vertical rígida, faixas glicêmicas fixas sem refletir metas personalizadas e rótulos de data estáticos/desalinhados no eixo X | Cálculo dinâmico de `chartMaxY`, desenho parametrizado das zonas de risco (`limitHypo`, `lower`, `limitHyper`), geração dinâmica das datas do período no eixo X e otimização de `shouldRepaint` | `screens/history_screen.dart` (`GlucoseMedicalChartPainter`) e commits `bcb9ebe`, `7fdb182` e `c793a49` |
| Frontend | Divergência visual em relação ao Figma: aplicação de estilos genéricos do Material padrão (fontes pequenas, contraste abaixo do esperado e cores de alerta imprecisas) mesmo com o print anexado | Comparação direta com `docs/prototipoAltaFidelidade.pdf`, reforço dos códigos hexadecimais exatos (`#0060C0`, `#E3F1FD`, `#F44336`, `#4CAF50`, `#FF9800`), aumento de tipografia/áreas de toque e adição explícita de `Semantics` e suporte a `disableAnimations` | `docs/prototipoAltaFidelidade.pdf`, `docs/justificativas.md` e telas em `glicotrack_dev/lib/screens/` |
| Backend / Escopo | Criar e depois restabelecer login com base no enunciado genérico sem respeitar a definição específica da interface desta versão | Removida a tela acrescentada pela IA e preservadas somente as telas existentes, com sessão automática Firebase em segundo plano | `screens/auth_gate.dart` e `services/app_bootstrap.dart`; nenhuma reescrita do histórico Git |
| Documentação | Tratar a frase resumida de uso de IA como documentação suficiente para a avaliação | Acrescentados o processo de criação do frontend a partir do Figma, os prompts eficientes, erros/correções e justificativas técnicas | Este arquivo atende aos tópicos do item b.vi; o grupo ainda precisa revisar e compreender o material |
| Validação | Usar resultados de compilação e testes de host como resposta insuficiente à pergunta sobre funcionamento completo | Separados testes executados de validações móveis/produção pendentes | `validacao-unidade-ii.md` e `matriz-rastreabilidade.md`; sem afirmar criptografia nativa, áudio físico ou desempenho de aparelho de 2 GB com base em testes FFI |

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
