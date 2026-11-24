# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

## [Unidade II - Entrega Final e Validação Android] - 2026-11-23

### Adicionado e documentado

* Publicados os diagramas atualizados em `docs/casoDeUso.pdf` e `docs/diagramaDeClasse.pdf`.
* Adicionada a documentação detalhada do fluxo de navegação real do aplicativo em `docs/fluxo-navegacao.md`.
* Adicionada a modelagem do banco de dados em `docs/modelagem-banco-de-dados.md` (renomeada com extensão `.md` e vinculada ao `README.md`).
* Complementado `docs/uso-de-ia.md` com o fluxo de criação do frontend a partir dos prints do Figma no Gemini, prompts mais eficientes, erros/correções de interface, integração Firebase e justificativa das bibliotecas (item b.vi).
* Formalizada a decisão de segurança clínica (SBD) em `docs/arquitetura-unidade-ii.md`, `docs/justificativas.md` e `docs/matriz-rastreabilidade.md`: o app registra a dose de insulina aplicada pelo usuário sem sugerir cálculo prescritivo automático.
* Atualizado `README.md` com índice completo da Unidade II, árvore atualizada do repositório e alinhamento da autoria das telas com o histórico Git.

### Corrigido e refinado

* Ajustes visuais e de responsividade nos cartões da Linha do Tempo (espaçamento e proteção contra *overflow*), na tela Meu Perfil e no formato de data do Novo Registro (`0820d31`, `02c137e`).
* Padronização do nome do arquivo e alinhamento do cabeçalho nos relatórios PDF e CSV (`7c8b485`).
* Correção do fluxo de exclusão de dados no Firebase com fallback compatível quando Cloud Functions não está implantada e reinício limpo da sessão anônima (`5c9d418`).

### Validação em Android

* Executado com sucesso o teste nativo de criptografia `integration_test/encryption_test.dart` no emulador **Pixel 7 Pro** (`API 36.1`), comprovando SQLCipher real (`PRAGMA cipher_version`), arquivo ilegível como `SQLite format 3`, rejeição com chave incorreta e reabertura via Android Keystore.
* Validado na prática no emulador Android o roteiro de aceite: entrada direta nas 4 abas, foco automático do teclado numérico, mudança de cor e alerta sonoro audível abaixo de 70 mg/dL, 5 medições em 1 minuto sem travar lista/gráfico, funcionamento offline-first com Modo Avião + sincronização no Firestore real (`glicotrack-bf802`) e compartilhamento nativo de PDF/CSV (registrado em `docs/validacao-unidade-ii.md` e `docs/matriz-rastreabilidade.md`).

## [Unidade II - Conferência dos documentos e remoção do login] - 2026-11-22

* Conferidos o estudo de caso, o aditivo e o enunciado da avaliação, com rastreabilidade por página/item e distinção entre implementação e aceite pendente.
* Removidos login, cadastro, recuperação de senha e logout acrescentados na integração. Mantidas somente as telas existentes da equipe, conforme o escopo específico desta versão, com sessão automática Firebase em segundo plano.
* Perfil sem e-mail e exclusão pela confirmação existente adaptados à sessão anônima; isolamento por UID e bloqueio contra reenvio preservados.
* Cores da classificação aplicadas também ao cabeçalho e ao painel do formulário para cumprir a mudança de cor da tela exigida no aditivo, mantendo os campos e a navegação.
* Complementado `docs/uso-de-ia.md` com solicitações utilizadas, erros/correções e justificativas das bibliotecas exigidas no item b.vi.
* Registradas as pendências de aceite nativo/produção e a ausência de definição para o cálculo de insulina mencionado no objetivo do estudo de caso.

## [Unidade II - Integração do backend às telas] - 2026-11-21

### Adicionado

* Fluxo de login, cadastro, recuperação de senha, logout e vinculação da sessão anônima existente a uma conta, preservando o UID.
* Provider para integrar Home, Registro, Perfil, Histórico e linha do tempo ao backend já versionado.
* Edição/exclusão de registros, categorias, metas, perfil, indicadores reais e exportação CSV.
* Documentação de arquitetura, configuração, navegação, planejamento, rastreabilidade e validação.

### Integrado e corrigido

* Incorporados os 24 commits da main posteriores a `61f3be0`, mantendo `firebase_options.dart` e reaproveitando `AppBootstrap`.
* Inicialização Firebase passou a usar as opções publicadas pelo grupo; configuração alternativa por dart-define preservada.
* Consultas e atualização de estado centralizadas no AppStore, incluindo correção das referências fora de escopo no Histórico.
* Refeição, insulina, carboidratos e observações da linha do tempo preservados na integração com edição e exclusão.
* CustomPainter existente otimizado por conteúdo, com limites personalizados e posição cronológica; PdfService ampliado com dados reais e fontes locais.
* Confirmação após commit SQLite, botão acessível com teclado e alertas visuais/ponte sonora conectados ao formulário.
* Backup, restauração e exclusão passaram a acionar os serviços reais. Sincronização não é iniciada duas vezes pela inicialização da sessão.

### Validação

* Resultados e limitações registrados em `docs/validacao-unidade-ii.md`; os testes utilizam emuladores demo, sem implantar alterações no Firebase real.


## [Unidade II - Base de domínio e dados] - 2026-11-17

### Adicionado

* Modelos de domínio, validações, classificação glicêmica e contratos de repositório.
* SQLite com SQLCipher, chave em armazenamento seguro, fila e resolução de conflitos.
* Sincronização Firestore, regras de acesso e função autenticada de exclusão.
* Testes de domínio, persistência, sincronização e segurança; registro de uso de IA.


## [Atividade 5 - Apresentação e Entrega Final] - 2026-10-05

### Adicionado

* Atualização do `README.md` com as responsabilidades individuais para a apresentação final.
* Definição da divisão dos 5 tópicos da apresentação entre os integrantes:

  * **Victor Lucas:** Problema e Solução.
  * **Gustavo Henriques:** Usuários.
  * **Leonardo:** Funcionalidades.
  * **Lauro:** Protótipo.
  * **Kyslon:** Arquitetura.
* Organização dos materiais finais da Unidade I.
* Inclusão da apresentação final em `docs/apresentacaoFinalUnidadeI.pdf`.

## [Atividade 4 - Prototipação] - 2026-10-05

### Adicionado

* Criação dos protótipos de baixa e alta fidelidade.
* Criação do arquivo `docs/justificativas.md` com as principais decisões de UI/UX e arquitetura.
* Atualização do `README.md` com a divisão de tarefas referentes à Atividade 4.
* Inclusão dos arquivos `prototipoBaixaFidelidade.pdf` e `prototipoAltaFidelidade.pdf`.

## [Atividade 3 - Requisitos e Funcionalidades] - 2026-09-15

### Adicionado

* Criação do arquivo `docs/requisitos.md`.
* Mapeamento de 17 Requisitos Funcionais (RF) e 21 Requisitos Não Funcionais (RNF).
* Documentação das operações CRUD.
* Criação da matriz de priorização das funcionalidades.
* Atualização do `README.md` com a divisão de tarefas referentes à Atividade 3.

## [Atividade 2 - Pesquisa, Benchmark e Personas] - 2026-09-13

### Adicionado

* Criação dos arquivos `docs/pesquisa.md`, `docs/benchmark.md` e `docs/personas.md`.
* Criação das imagens das personas e da apresentação da atividade.
* Pesquisa sobre o problema e público-alvo.
* Benchmark de 3 soluções existentes.
* Definição das 2 personas principais e da persona prioritária.

### Alterado

* Atualização do `README.md` com as responsabilidades dos integrantes.
* Organização do `CHANGELOG.md` na raiz do repositório.

## [Atividade 1 - Análise do Estudo de Caso] - 2026-09-01

### Adicionado

* Criação de `docs/estudo-de-caso.md`.
* Análise do problema, público, contexto, funcionalidades, restrições e pontos de atenção.
* Estruturação inicial do repositório e criação do `README.md`.
* Definição das responsabilidades da equipe.
