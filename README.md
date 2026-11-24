# GlicoTrack

Aplicativo móvel para controle e acompanhamento da glicemia e do diabetes, com foco em registro ultrarrápido, acessibilidade severa e funcionamento offline.

**Disciplina:** Programação para Dispositivos Móveis — Universidade Tiradentes (Unit)
**Turma:** GP0029VNO06A

## Backend e entrega da Unidade II

O aplicativo existente em `glicotrack_dev/` recebeu domínio validado, Provider, SQLite/SQLCipher, sessão anônima Firebase, sincronização Firestore, CRUD integrado, relatórios PDF/CSV e regras de acesso. A inicialização utiliza o `firebase_options.dart` publicado pelo grupo para o projeto `glicotrack-bf802`, preservando a entrada direta nas telas existentes. A habilitação de autenticação anônima, o Firestore e a implantação das regras/Cloud Function ainda precisam ser conferidos na conta do grupo. A sessão é persistida no aparelho; sem um fluxo de conta, reinstalação ou troca de aparelho não permitem recuperar automaticamente o mesmo UID.

### Artefatos técnicos da Unidade II

- [Diagrama de Casos de Uso (PDF)](docs/casoDeUso.pdf)
- [Diagrama de Classes (PDF)](docs/diagramaDeClasse.pdf)
- [Arquitetura, SQLite e modelagem Firestore (mapeamento Dart ↔ Firestore)](docs/arquitetura-unidade-ii.md)
- [Modelagem do banco de dados (Firestore e SQLite)](docs/modelagem-banco-de-dados.md)
- [Casos de uso e visão resumida da Unidade II](docs/fluxos-unidade-ii.md)
- [Fluxo de navegação real detalhado](docs/fluxo-navegacao.md)
- [Registro de uso de IA](docs/uso-de-ia.md)
- [Configuração Firebase e comandos](docs/configuracao-firebase.md)
- [Matriz RF01-RF17 / RNF01-RNF21](docs/matriz-rastreabilidade.md)
- [Escopo, EAP e sprints](docs/planejamento-unidade-ii.md)
- [Testes, desempenho e limitações](docs/validacao-unidade-ii.md)

As responsabilidades históricas e referências abaixo foram preservadas. As contribuições publicadas permanecem atribuídas aos respectivos autores no histórico Git; o repositório encontra-se consolidado com as atualizações da `main` até 23/11/2026.

## Equipe

- Gustavo Henriques
- Kyslon Matos Costa
- Lauro Antenor Augusto de Souza Santos
- Leonardo Carvalho da Cruz
- Victor Lucas Fontes

## Estrutura do repositório

```text
GlicoTrack/
├── README.md
├── CHANGELOG.md
├── LICENSE
├── firebase.json
├── firestore.rules
├── firestore.indexes.json
├── functions/                          (Cloud Functions e testes de regras Firebase)
├── glicotrack_dev/                     (Aplicativo Flutter: telas, domínio, SQLite/SQLCipher, Firestore e testes)
└── docs/
    ├── estudo-de-caso.md               (Unidade I — Atividade 1)
    ├── pesquisa.md                     (Unidade I — Atividade 2)
    ├── benchmark.md                    (Unidade I — Atividade 2)
    ├── personas.md                     (Unidade I — Atividade 2)
    ├── Persona1.png                    (Unidade I — Atividade 2)
    ├── Persona2.png                    (Unidade I — Atividade 2)
    ├── apresentacao.pdf                (Unidade I — Atividade 2)
    ├── requisitos.md                   (Unidade I — Atividade 3)
    ├── apresentacaoRequisitos.pdf      (Unidade I — Atividade 3)
    ├── justificativas.md               (Unidade I — Atividade 4)
    ├── prototipoBaixaFidelidade.pdf    (Unidade I — Atividade 4)
    ├── prototipoAltaFidelidade.pdf     (Unidade I — Atividade 4)
    ├── apresentacaoFinalUnidadeI.pdf   (Unidade I — Apresentação Final)
    ├── casoDeUso.pdf                   (Unidade II — Diagrama de Casos de Uso)
    ├── diagramaDeClasse.pdf            (Unidade II — Diagrama de Classes)
    ├── arquitetura-unidade-ii.md       (Unidade II — Arquitetura, SQLite e Firestore)
    ├── modelagem-banco-de-dados.md     (Unidade II — Modelagem detalhada Firestore e SQLite)
    ├── fluxos-unidade-ii.md            (Unidade II — Casos de uso e fluxo resumido)
    ├── fluxo-navegacao.md              (Unidade II — Fluxo de navegação real detalhado)
    ├── configuracao-firebase.md        (Unidade II — Configuração e comandos Firebase)
    ├── matriz-rastreabilidade.md       (Unidade II — Rastreabilidade RF01-RF17 / RNF01-RNF21)
    ├── planejamento-unidade-ii.md      (Unidade II — Escopo, EAP e sprints)
    ├── validacao-unidade-ii.md         (Unidade II — Testes, desempenho e limitações)
    └── uso-de-ia.md                    (Unidade II — Registro de uso de IA)
```

---

## Unidade I — Planejamento, Pesquisa, Requisitos e Prototipação

### 1ª Semana — Atividade 1: Análise do Estudo de Caso

#### 1. Objetivo

Analisar o estudo de caso recebido pelo grupo, compreendendo o problema apresentado, seus usuários, contexto de utilização, objetivos, restrições e características da solução proposta, demonstrando o entendimento claro sobre o que precisa ser desenvolvido, para quem, por que e em quais condições.

#### 2. Responsabilidades da Equipe

Para a execução da atividade e cumprindo os requisitos de colaboração, as seções do estudo de caso foram divididas e analisadas pelos integrantes da equipe da seguinte forma:

* **Lauro e Leonardo (Problema, Público e Contexto):** responsáveis pela análise fundamental do projeto, documentando o problema a ser solucionado, o detalhamento do público e dos usuários (quem são, necessidades e relação com o app), além do mapeamento completo do contexto de uso e da proposta de valor do GlicoTrack.
* **Victor Lucas (Personalidade, Identidade e Experiência):** responsável por definir os conceitos de palavras conceituais, tom da interface, identidade visual desejada e a experiência de uso que o aplicativo deve transmitir aos pacientes.
* **Kyslon (Funcionalidades e Características):** responsável por realizar o levantamento estruturado de todas as funcionalidades e características técnicas já previamente definidas no escopo do projeto, garantindo o alinhamento com as necessidades dos usuários.
* **Gustavo Henriques (Restrições e Pontos de Atenção):** responsável por mapear as restrições operacionais e condições técnicas do projeto (como quantidade de telas, limitações de hardware e requisitos de acessibilidade/offline), além de elencar os 3 pontos de atenção mais cruciais para o sucesso do aplicativo.
* **Todos os integrantes:** responsáveis em conjunto por ler, revisar e organizar de forma colaborativa todos os tópicos gerados pelo grupo, garantindo a coesão técnica do documento de análise de requisitos.

#### 3. Entregáveis e Estrutura do Repositório

* **[docs/estudo-de-caso.md](docs/estudo-de-caso.md):** documento principal contendo a análise completa do escopo, dividida entre problema, público, contexto, funcionalidades, restrições e pontos de atenção.
* **README.md:** atualizado na raiz do repositório para documentar o objetivo da primeira entrega e o registro das responsabilidades de cada membro da equipe.

#### 4. Organização e Participação Individual

* A estruturação da análise de requisitos foi feita de forma colaborativa.
* As contribuições de texto e documentação foram realizadas e enviadas utilizando as próprias contas do GitHub de cada membro do grupo.
* Foram utilizados commits descritivos para permitir a identificação clara de qual seção do estudo de caso foi adicionada ou revisada por cada integrante.

---

### 2ª Semana — Atividade 2: Pesquisa, Benchmark e Personas

#### 1. Objetivo

Aprofundar a compreensão do problema e dos usuários do estudo de caso por meio de pesquisa e análise de soluções existentes, utilizando essas informações para criar personas que orientem o desenvolvimento do aplicativo.

#### 2. Responsabilidades da Equipe

Para a execução da atividade e cumprindo os requisitos de organização do repositório, as responsabilidades foram distribuídas entre os integrantes da equipe da seguinte forma:

* **Lauro e Leonardo (Pesquisa):** responsáveis pela realização da pesquisa sobre o problema e o público, detalhando as necessidades dos usuários, dados que possam influenciar o aplicativo, fontes utilizadas e identificando as 3 descobertas importantes para o projeto.
* **Victor Lucas (Benchmark):** responsável pela elaboração do benchmark, analisando as principais funcionalidades, pontos positivos, pontos negativos e aspectos de interface/experiência de 3 soluções existentes no mercado, além de definir o que nosso aplicativo poderá fazer de diferente ou melhor.
* **Gustavo Henriques (Personas):** responsável pela criação das 2 personas principais com base no estudo de caso e nas descobertas da pesquisa, estruturando nome fictício, perfil/contexto, objetivos, necessidades, dores, comportamentos e relação com o aplicativo, além de justificar a escolha da persona prioritária.
* **Kyslon (Apresentação e Documentação):** responsável pela estruturação do arquivo final de apresentação do grupo, compilando de forma objetiva 1 descoberta da pesquisa, 1 solução analisada no benchmark, a persona prioritária e 1 necessidade que o aplicativo deverá atender.
* **Todos os integrantes:** responsáveis em conjunto por analisar, revisar e organizar de forma colaborativa todos os tópicos gerados pelo grupo, garantindo a coesão entre a pesquisa, o benchmark, as personas e o projeto.

#### 3. Entregáveis e Estrutura do Repositório

* **[docs/pesquisa.md](docs/pesquisa.md):** informações relevantes sobre o problema, necessidades e dificuldades dos usuários, dados que influenciam o aplicativo, fontes utilizadas e o destaque das 3 descobertas importantes com suas influências no projeto.
* **[docs/benchmark.md](docs/benchmark.md):** análise de 3 soluções existentes (MySugr, Glic e Diabetes:M) e o que será aproveitado ou melhorado no GlicoTrack.
* **[docs/personas.md](docs/personas.md):** perfil detalhado das 2 personas principais e a indicação justificada da persona prioritária. Os cartões visuais estão em `docs/Persona1.png` e `docs/Persona2.png`.
* **[docs/apresentacao.pdf](docs/apresentacao.pdf):** apresentação objetiva do grupo contendo 1 descoberta da pesquisa, 1 solução analisada no benchmark, a persona prioritária e 1 necessidade que o aplicativo deverá atender.
* **[CHANGELOG.md](CHANGELOG.md):** na raiz do repositório, registra o histórico de mudanças e adições de cada atividade.

#### 4. Organização e Participação Individual

* O arquivo `README.md` foi atualizado com a divisão de tarefas de cada integrante.
* As contribuições de código e documentação foram realizadas utilizando as próprias contas do GitHub de cada membro do grupo.
* Foram utilizados commits com descrições claras que permitem identificar o trabalho realizado individualmente e em colaboração.

---

### 3ª Semana — Atividade 3: Funcionalidades e Requisitos

#### 1. Objetivo

Definir e documentar as funcionalidades do GlicoTrack, estruturando os Requisitos Funcionais (RF), Requisitos Não Funcionais (RNF), as operações de CRUD do sistema e realizando a priorização das tarefas de desenvolvimento.

#### 2. Responsabilidades da Equipe

Para a execução da atividade, as responsabilidades foram distribuídas entre os integrantes da equipe da seguinte forma para a atualização do repositório:

* **Lauro (Funcionalidades):** responsável por documentar a tabela principal de funcionalidades, alinhando as necessidades dos usuários, a descrição e a justificativa de cada recurso do aplicativo.
* **Leonardo (Requisitos Funcionais):** responsável por listar e mapear os 17 Requisitos Funcionais (RF) que o sistema deve cumprir para entregar o valor esperado.
* **Victor Lucas (Requisitos Não Funcionais):** responsável por estruturar os 21 Requisitos Não Funcionais (RNF), garantindo restrições vitais de Usabilidade, Acessibilidade, Desempenho, Armazenamento, Segurança e Compatibilidade.
* **Kyslon (CRUD):** responsável por definir as operações de Criar, Consultar, Atualizar e Excluir das entidades primárias do aplicativo.
* **Gustavo Henriques (Priorização):** responsável por classificar as funcionalidades em matriz de prioridade (Essencial, Importante e Secundária) para guiar o fluxo de desenvolvimento.
* **Todos os integrantes:** responsáveis em conjunto por analisar, revisar e garantir que as funcionalidades documentadas atendam ao problema mapeado nas semanas anteriores.

#### 3. Entregáveis e Estrutura do Repositório

* **[docs/requisitos.md](docs/requisitos.md):** contém a descrição das funcionalidades, os requisitos (RF01-RF17 e RNF01-RNF21), a análise de CRUD e a matriz de priorização do aplicativo.
* **[docs/apresentacaoRequisitos.pdf](docs/apresentacaoRequisitos.pdf):** slides de apresentação dos requisitos da etapa.
* **[CHANGELOG.md](CHANGELOG.md):** atualizado para registrar a adição da documentação de requisitos desta semana.

---

### 4ª Semana — Atividade 4: Justificativas de Interface, Prototipação e Arquitetura

#### 1. Objetivo

Registrar formalmente as principais decisões de interface (UI/UX), prototipação e arquitetura do aplicativo GlicoTrack, garantindo que as escolhas de design, navegação e tecnologias (Flutter, Dart, SQLite) estejam alinhadas com as restrições de acessibilidade, contexto de uso e operação Offline-First.

#### 2. Responsabilidades da Equipe

Para a execução da atividade, as responsabilidades foram distribuídas da seguinte forma:

* **Lauro (Interface):** responsável por documentar as escolhas de cores (paleta de alerta) e tipografia ampliada.
* **Leonardo (Componentes e Acessibilidade):** responsável pela definição e justificativa dos componentes e requisitos de acessibilidade, além do protótipo de baixa fidelidade.
* **Gustavo Henriques (Organização, Navegação e Protótipo de Alta Fidelidade):** responsável por justificar os fluxos simplificados de 3 interações, organizar as justificativas e publicar o protótipo de alta fidelidade.
* **Victor Lucas (Decisões relacionadas ao contexto de uso):** responsável por alinhar as decisões visuais com o contexto dinâmico de uso do aplicativo (transporte, trabalho, etc.).
* **Kyslon (Arquitetura do Sistema):** responsável por justificar a escolha tecnológica do Flutter/Dart, o uso do `CustomPainter` para performance e a adoção do SQLite para a arquitetura Offline-First, com Firebase como backup.
* **Todos os integrantes:** revisão colaborativa do documento final para garantir coesão com os requisitos das semanas anteriores.

#### 3. Entregáveis e Estrutura do Repositório

* **[docs/justificativas.md](docs/justificativas.md):** principais decisões de cores, tipografia, organização, navegação, componentes, acessibilidade, contexto de uso e arquitetura.
* **[docs/prototipoBaixaFidelidade.pdf](docs/prototipoBaixaFidelidade.pdf):** protótipo inicial de baixa fidelidade.
* **[docs/prototipoAltaFidelidade.pdf](docs/prototipoAltaFidelidade.pdf):** protótipo de alta fidelidade elaborado no Figma, utilizado como referência para a criação das telas em Flutter.
* **[CHANGELOG.md](CHANGELOG.md):** atualizado com os registros da Atividade 4.

---

### Encerramento da Unidade I — Apresentação e Entrega Final

#### Responsabilidades na Apresentação Final (Unidade I)

* **Problema e Solução — Lauro Antenor Augusto de Souza Santos:** responsável pela definição e apresentação do problema identificado, do público-alvo e da proposta de solução do aplicativo.
* **Usuários — Leonardo Carvalho da Cruz:** responsável pela definição e apresentação das personas do projeto, com destaque para a persona prioritária e as necessidades que influenciaram a solução.
* **Funcionalidades — Kyslon Matos Costa:** responsável pelo levantamento e apresentação das principais funcionalidades do aplicativo, relacionando cada uma às necessidades dos usuários e aos requisitos.
* **Protótipo — Victor Lucas Nascimento Fontes:** responsável pela apresentação dos protótipos do aplicativo, das principais telas e do fluxo de navegação esperado.
* **Arquitetura — Gustavo Henriques:** responsável pela apresentação da arquitetura adotada no projeto, explicando os principais componentes e como se relacionam.

#### Entregável

* **[docs/apresentacaoFinalUnidadeI.pdf](docs/apresentacaoFinalUnidadeI.pdf):** slides consolidados da apresentação final da Unidade I.

---

## Unidade II — Desenvolvimento do Aplicativo, Banco de Dados, Backend e Documentação Final

### 5ª Semana — Criação e Adição das Telas do Aplicativo

#### 1. Objetivo

Desenvolver e integrar as telas principais do aplicativo GlicoTrack em Flutter com base no protótipo de alta fidelidade do Figma, aplicando as diretrizes de acessibilidade (WCAG AAA e Material Design 3), padronização visual com alto contraste, áreas de toque ampliadas e navegação fluida voltada ao público idoso e com dificuldades motoras ou visuais.

#### 2. Responsabilidades da Equipe (conforme histórico Git)

Para a execução da etapa de construção da interface, o desenvolvimento e o envio das telas foram organizados da seguinte forma:

* **Lauro Augusto (`MainScreen`, `HomeScreen`, `HistoryScreen`, `DataManagementScreen` e `PdfService`):** responsável pela criação inicial do projeto Flutter (`glicotrack_dev/`), da estrutura principal de navegação com barra inferior flutuante e transições suaves (`_FadeIndexedStack`), da tela inicial (`HomeScreen`), da tela de histórico e análise (`HistoryScreen`) com gráfico em `CustomPainter`, da tela de gerenciamento/segurança de dados (`DataManagementScreen`) e do serviço inicial de geração de relatórios em PDF (`PdfService`).
* **Kyslon Matos (`SplashScreen` e `ProfileHubScreen`):** responsável pela criação da tela de carregamento inicial animada (`SplashScreen`) com respeito à redução de movimento e do painel central de perfil (`ProfileHubScreen`).
* **Victor Lucas (`RegisterScreen` e `TimelineScreen`):** responsável pela criação da tela de registro de medições (`RegisterScreen`), da tela de linha do tempo detalhada (`TimelineScreen`) e pela ligação inicial dessas telas e do histórico com o banco local e Firebase.
* **Leonardo Carvalho (`PersonalInfoScreen` e refinamentos visuais):** responsável pelo desenvolvimento da tela de informações pessoais (`PersonalInfoScreen`) e pelos refinamentos posteriores de espaçamento, alinhamento, formato de data e apresentação visual em `TimelineScreen`, `ProfileHubScreen`, `RegisterScreen` e nos relatórios PDF/CSV.
* **Gustavo Henriques (`ProfileSettingsScreen`):** responsável pela criação da tela de configuração das faixas ideais de glicemia (`ProfileSettingsScreen`), além da estruturação da base do backend na semana seguinte.
* **Todos os integrantes:** responsáveis em conjunto pela padronização estética das telas (cartões brancos, alto contraste e suporte a leitores de tela via `Semantics`), testes visuais e integração de todo o fluxo no repositório.

#### 3. Entregáveis e Estrutura do Repositório

* **`glicotrack_dev/lib/screens/`:** conjunto completo das telas funcionais do aplicativo (`splash_screen.dart`, `main_screen.dart`, `home_screen.dart`, `register_screen.dart`, `history_screen.dart`, `timeline_screen.dart`, `profile_hub_screen.dart`, `personal_info_screen.dart`, `profile_settings_screen.dart` e `data_management_screen.dart`).
* **`glicotrack_dev/lib/services/pdf_service.dart`:** serviço dedicado à geração de relatórios médicos em PDF.
* **[CHANGELOG.md](CHANGELOG.md):** atualizado com o registro de criação e refinamento das telas.

#### 4. Organização e Participação Individual

* Cada integrante desenvolveu, testou e enviou suas respectivas telas utilizando sua própria conta do GitHub.
* Os commits foram organizados por tela e funcionalidade para manter o histórico claro de autoria e revisões de interface.

---

### 6ª Semana — Diagramas e Documentação de Engenharia

#### 1. Objetivo

Formalizar a modelagem comportamental, estrutural e de navegação do sistema GlicoTrack por meio dos diagramas de engenharia de software e da consolidação dos requisitos, garantindo alinhamento completo entre a visão de negócio, a experiência do usuário e a arquitetura técnica.

#### 2. Responsabilidades da Equipe

Para a execução desta etapa, toda a equipe trabalhou de maneira integrada na concepção e validação dos artefatos:

* **Todos os integrantes (Lauro Augusto, Leonardo Carvalho, Kyslon Matos, Victor Lucas e Gustavo Henriques):** participaram ativamente da criação, análise e revisão dos documentos de modelagem e engenharia do projeto, incluindo:
  * **Diagrama de Casos de Uso:** mapeamento das interações entre o paciente/cuidador, profissional de saúde e serviços Firebase.
  * **Diagrama de Classes (Modelos de Domínio):** definição das entidades de domínio em Dart, atributos, métodos e relacionamentos.
  * **Fluxo de Navegação Real:** mapeamento prático de como as telas, abas, pilhas e diálogos do aplicativo se conectam.
  * **Requisitos e Rastreabilidade:** consolidação e rastreabilidade dos Requisitos Funcionais (RF01-RF17) e Não Funcionais (RNF01-RNF21).

#### 3. Entregáveis e Estrutura do Repositório

* **[docs/casoDeUso.pdf](docs/casoDeUso.pdf) e [docs/fluxos-unidade-ii.md](docs/fluxos-unidade-ii.md):** Diagrama de Casos de Uso atualizado com as regras de negócio da Unidade II.
* **[docs/diagramaDeClasse.pdf](docs/diagramaDeClasse.pdf) e [docs/arquitetura-unidade-ii.md](docs/arquitetura-unidade-ii.md):** Diagrama de Classes (modelos de domínio Dart) e visão arquitetural.
* **[docs/fluxo-navegacao.md](docs/fluxo-navegacao.md):** fluxo de navegação real detalhado do aplicativo.
* **[docs/requisitos.md](docs/requisitos.md) e [docs/matriz-rastreabilidade.md](docs/matriz-rastreabilidade.md):** requisitos consolidados e matriz de rastreabilidade.
* **[CHANGELOG.md](CHANGELOG.md):** atualizado com a inclusão e revisão dos artefatos.

#### 4. Organização e Participação Individual

* A elaboração e a revisão técnica de cada diagrama e documento foram conduzidas de forma colaborativa por todos os membros do grupo.
* As atualizações foram versionadas no repositório com histórico transparente de revisão e consenso técnico da equipe.

---

### 7ª Semana — Modelagem e Criação do Banco de Dados

#### 1. Objetivo

Modelar, estruturar e implementar a camada de persistência do GlicoTrack com foco na arquitetura *Offline-First*, garantindo armazenamento local seguro e confiável (SQLite/SQLCipher) aliado à modelagem em nuvem (Cloud Firestore) para backup e sincronização dos dados do paciente.

#### 2. Responsabilidades da Equipe

Para assegurar integridade, segurança e aderência aos requisitos de privacidade (LGPD), todos os membros atuaram conjuntamente nas decisões de persistência:

* **Todos os integrantes (Lauro Augusto, Leonardo Carvalho, Kyslon Matos, Victor Lucas e Gustavo Henriques):** participaram da modelagem lógica e física, definição das tabelas locais, estrutura de coleções e documentos no Firestore, mapeamento das classes Dart para o Firestore, regras de acesso (`firestore.rules`) e revisão do fluxo de persistência.

#### 3. Entregáveis e Estrutura do Repositório

* **`glicotrack_dev/lib/domain/` e `glicotrack_dev/lib/data/`:** modelos de domínio, camada de banco de dados local (SQLite/SQLCipher), fila de sincronização e repositório Firestore.
* **`firestore.rules`, `firestore.indexes.json` e `functions/`:** regras de segurança por UID, índices do Firestore e Cloud Function autenticada para exclusão de dados.
* **[docs/arquitetura-unidade-ii.md](docs/arquitetura-unidade-ii.md) e [docs/modelagem-banco-de-dados.md](docs/modelagem-banco-de-dados.md):** documentação técnica detalhando a arquitetura, o esquema SQLite e a modelagem/mapeamento no Firestore.
* **[CHANGELOG.md](CHANGELOG.md):** registro das alterações de modelagem e criação do banco de dados.

#### 4. Organização e Participação Individual

* Todos os integrantes acompanharam, analisaram e revisaram as definições de tabelas, chaves, índices e regras de armazenamento.
* As entregas foram registradas por meio de commits descritivos no repositório do grupo.

---

### 8ª Semana — Implementação do Backend, Validação, Testes e Entrega Final

#### 1. Objetivo

Concluir a implementação do backend integrado ao aplicativo, realizar a validação funcional e execução de testes completos do sistema, bem como consolidar a documentação técnica, o registro de uso de IA e a apresentação final do projeto GlicoTrack.

#### 2. Responsabilidades da Equipe

Na reta final do desenvolvimento, a equipe atuou de forma integrada na entrega, qualidade e apresentação da solução:

* **Todos os integrantes (Lauro Augusto, Leonardo Carvalho, Kyslon Matos, Victor Lucas e Gustavo Henriques):** participaram da construção, integração e ajustes do backend (gerenciamento de estado com Provider, operações completas de CRUD integradas ao banco local, sessão anônima Firebase, sincronização em nuvem, exportação de relatórios PDF/CSV, exclusão de dados no Firebase e regras de acesso), bem como da execução de testes e validação dos fluxos.
* **Apresentação Final e Revisão Documental (Todos os integrantes):** elaboração da apresentação final do projeto, registro do uso de IA, revisão minuciosa e aplicação de correções finais nos documentos técnicos, diagramas, matriz de rastreabilidade, `README.md` e `CHANGELOG.md`.

#### 3. Entregáveis e Estrutura do Repositório

* **`glicotrack_dev/` e `functions/`:** aplicativo completo com backend integrado, persistência *Offline-First*, sincronização Firebase/Firestore, exclusão autenticada via Cloud Functions, exportação de relatórios PDF/CSV e suíte de testes.
* **[docs/casoDeUso.pdf](docs/casoDeUso.pdf) e [docs/diagramaDeClasse.pdf](docs/diagramaDeClasse.pdf):** diagramas finais de Casos de Uso e de Classes.
* **[docs/arquitetura-unidade-ii.md](docs/arquitetura-unidade-ii.md) e [docs/modelagem-banco-de-dados.md](docs/modelagem-banco-de-dados.md):** modelagem do banco local e mapeamento das classes Dart para coleções/documentos no Firestore.
* **[docs/fluxo-navegacao.md](docs/fluxo-navegacao.md) e [docs/fluxos-unidade-ii.md](docs/fluxos-unidade-ii.md):** fluxo de navegação real do aplicativo e casos de uso.
* **[docs/uso-de-ia.md](docs/uso-de-ia.md):** registro do uso de IA (criação do frontend a partir do Figma com Gemini, backend, prompts mais eficientes, erros/correções e justificativa das bibliotecas).
* **[docs/validacao-unidade-ii.md](docs/validacao-unidade-ii.md) e [docs/configuracao-firebase.md](docs/configuracao-firebase.md):** registro dos testes executados, análise de desempenho, limitações conhecidas e guia de configuração Firebase.
* **`README.md` e [CHANGELOG.md](CHANGELOG.md):** atualizados e revisados para a entrega final da disciplina.

#### 4. Organização e Participação Individual

* Toda a validação do backend, testes em dispositivo/emulador, revisão dos documentos e preparação da apresentação final foram conduzidos em conjunto pelos 5 integrantes.
* O repositório final foi consolidado com histórico limpo, rastreabilidade completa dos requisitos e documentação revisada.
