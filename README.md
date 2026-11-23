# GlicoTrack

## Backend e entrega da Unidade II

O aplicativo existente em `glicotrack_dev/` recebeu domínio validado, Provider, SQLite/SQLCipher, sessão anônima Firebase, sincronização Firestore, CRUD integrado, relatórios PDF/CSV e regras de acesso. A inicialização utiliza o `firebase_options.dart` publicado pelo grupo para o projeto `glicotrack-bf802`, preservando a entrada direta nas telas existentes. A habilitação de autenticação anônima, o Firestore e a implantação das regras/Cloud Function ainda precisam ser conferidos na conta do grupo. A sessão é persistida no aparelho; sem um fluxo de conta, reinstalação ou troca de aparelho não permitem recuperar automaticamente o mesmo UID.

- [Configuração e comandos](docs/configuracao-firebase.md)
- [Arquitetura, SQLite e modelagem Firestore](docs/arquitetura-unidade-ii.md)
- [Casos de uso e fluxo real](docs/fluxos-unidade-ii.md)
- [Matriz RF01-RF17 / RNF01-RNF21](docs/matriz-rastreabilidade.md)
- [Escopo, EAP e sprints](docs/planejamento-unidade-ii.md)
- [Testes, desempenho e limitações](docs/validacao-unidade-ii.md)
- [Registro de IA](docs/uso-de-ia.md)

As responsabilidades históricas e referências abaixo foram preservadas. As contribuições publicadas permanecem atribuídas aos respectivos autores no histórico Git; a integração foi conciliada com as atualizações da main de 21/11/2026.

Aplicativo móvel para controle e acompanhamento da glicemia e do diabetes, com foco em registro ultrarrápido, acessibilidade severa e funcionamento offline.

**Disciplina:** Programação para Dispositivos Móveis — Universidade Tiradentes (Unit)
**Turma:** GP0029VNO06A

### Equipe

- Gustavo Henriques
- Kyslon Matos Costa
- Lauro Antenor Augusto de Souza Santos
- Leonardo Carvalho da Cruz
- Victor Lucas Fontes

### Estrutura do repositório

```
GlicoTrack/
├── README.md
├── CHANGELOG.md
├── glicotrack_dev/
└── docs/
    ├── estudo-de-caso.md      (Atividade 1)
    ├── pesquisa.md            (Atividade 2)
    ├── benchmark.md           (Atividade 2)
    ├── personas.md            (Atividade 2)
    ├── Persona1.png           (Atividade 2)
    ├── Persona2.png           (Atividade 2)
    └── apresentacao.pdf       (Atividade 2)
```

---

## 1ª Semana

# Atividade 1 — Análise do Estudo de Caso

## 1. Objetivo

Analisar o estudo de caso recebido pelo grupo, compreendendo o problema apresentado, seus usuários, contexto de utilização, objetivos, restrições e características da solução proposta, demonstrando o entendimento claro sobre o que precisa ser desenvolvido, para quem, por que e em quais condições.

## 2. Responsabilidades da Equipe

Para a execução da atividade e cumprindo os requisitos de colaboração, as seções do estudo de caso foram divididas e analisadas pelos integrantes da equipe da seguinte forma:

* **Lauro e Leonardo (Problema, Público e Contexto):** responsáveis pela análise fundamental do projeto, documentando o problema a ser solucionado, o detalhamento do público e dos usuários (quem são, necessidades e relação com o app), além do mapeamento completo do contexto de uso e da proposta de valor do GlicoTrack.
* **Victor Lucas (Personalidade, Identidade e Experiência):** responsável por definir os conceitos de palavras conceituais, tom da interface, identidade visual desejada e a experiência de uso que o aplicativo deve transmitir aos pacientes.
* **Kyslon (Funcionalidades e Características):** responsável por realizar o levantamento estruturado de todas as funcionalidades e características técnicas já previamente definidas no escopo do projeto, garantindo o alinhamento com as necessidades dos usuários.
* **Gustavo Henrique (Restrições e Pontos de Atenção):** responsável por mapear as restrições operacionais e condições técnicas do projeto (como quantidade de telas, limitações de hardware e requisitos de acessibilidade/offline), além de elencar os 3 pontos de atenção mais cruciais para o sucesso do aplicativo.
* **Todos os integrantes:** responsáveis em conjunto por ler, revisar e organizar de forma colaborativa todos os tópicos gerados pelo grupo, garantindo a coesão técnica do documento de análise de requisitos.

## 3. Entregáveis e Estrutura do Repositório

* **docs/estudo-de-caso.md:** documento principal contendo a análise completa do escopo, dividida entre problema, público, contexto, funcionalidades, restrições e pontos de atenção.
* **README.md:** atualizado na raiz do repositório para documentar o objetivo da primeira entrega e o registro das responsabilidades de cada membro da equipe.

## 4. Organização e Participação Individual

* A estruturação da análise de requisitos foi feita de forma colaborativa.
* As contribuições de texto e documentação foram realizadas e enviadas utilizando as próprias contas do GitHub de cada membro do grupo.
* Foram utilizados commits descritivos para permitir a identificação clara de qual seção do estudo de caso foi adicionada ou revisada por cada integrante.

---

## 2ª Semana

# Atividade 2 — Pesquisa, Benchmark e Personas

## 1. Objetivo

Aprofundar a compreensão do problema e dos usuários do estudo de caso por meio de pesquisa e análise de soluções existentes, utilizando essas informações para criar personas que orientem o desenvolvimento do aplicativo.

## 2. Responsabilidades da Equipe

Para a execução da atividade e cumprindo os requisitos de organização do repositório, as responsabilidades foram distribuídas entre os integrantes da equipe da seguinte forma:

* **Lauro e Leonardo (Pesquisa):** responsáveis pela realização da pesquisa sobre o problema e o público, detalhando as necessidades dos usuários, dados que possam influenciar o aplicativo, fontes utilizadas e identificando as 3 descobertas importantes para o projeto.
* **Victor Lucas (Benchmark):** responsável pela elaboração do benchmark, analisando as principais funcionalidades, pontos positivos, pontos negativos e aspectos de interface/experiência de 3 soluções existentes no mercado, além de definir o que nosso aplicativo poderá fazer de diferente ou melhor.
* **Gustavo Henrique (Personas):** responsável pela criação das 2 personas principais com base no estudo de caso e nas descobertas da pesquisa, estruturando nome fictício, perfil/contexto, objetivos, necessidades, dores, comportamentos e relação com o aplicativo, além de justificar a escolha da persona prioritária.
* **Kyslon (Apresentação e Documentação):** responsável pela estruturação do arquivo final de apresentação do grupo, compilando de forma objetiva 1 descoberta da pesquisa, 1 solução analisada no benchmark, a persona prioritária e 1 necessidade que o aplicativo deverá atender.
* **Todos os integrantes:** responsáveis em conjunto por analisar, revisar e organizar de forma colaborativa todos os tópicos gerados pelo grupo, garantindo a coesão entre a pesquisa, o benchmark, as personas e o projeto.

## 3. Entregáveis e Estrutura do Repositório

* **[docs/pesquisa.md](docs/pesquisa.md):** informações relevantes sobre o problema, necessidades e dificuldades dos usuários, dados que influenciam o aplicativo, fontes utilizadas e o destaque das 3 descobertas importantes com suas influências no projeto.
* **[docs/benchmark.md](docs/benchmark.md):** análise de 3 soluções existentes (MySugr, Glic e Diabetes:M) e o que será aproveitado ou melhorado no GlicoTrack.
* **[docs/personas.md](docs/personas.md):** perfil detalhado das 2 personas principais e a indicação justificada da persona prioritária. Os cartões visuais estão em `docs/Persona1.png` e `docs/Persona2.png`.
* **[docs/apresentacao.pdf](docs/apresentacao.pdf):** apresentação objetiva do grupo contendo 1 descoberta da pesquisa, 1 solução analisada no benchmark, a persona prioritária e 1 necessidade que o aplicativo deverá atender.
* **[CHANGELOG.md](CHANGELOG.md):** na raiz do repositório, registra o histórico de mudanças e adições de cada atividade.

## 4. Organização e Participação Individual

* O arquivo README.md foi atualizado com a divisão de tarefas de cada integrante.
* As contribuições de código e documentação foram realizadas utilizando as próprias contas do GitHub de cada membro do grupo.
* Foram utilizados commits com descrições claras que permitem identificar o trabalho realizado individualmente e em colaboração.

---

## 3ª Semana

# Atividade 3 — Funcionalidades e Requisitos

## 1. Objetivo

Definir e documentar as funcionalidades do GlicoTrack, estruturando os Requisitos Funcionais (RF), Requisitos Não Funcionais (RNF), as operações de CRUD do sistema e realizando a priorização das tarefas de desenvolvimento.

## 2. Responsabilidades da Equipe

Para a execução da atividade, as responsabilidades foram distribuídas entre os integrantes da equipe da seguinte forma para a atualização do repositório:

* **Lauro (Funcionalidades):** Responsável por documentar a tabela principal de funcionalidades, alinhando as necessidades dos usuários, a descrição e a justificativa de cada recurso do aplicativo.
* **Leonardo (Requisitos Funcionais):** Responsável por listar e mapear os 17 Requisitos Funcionais (RF) que o sistema deve cumprir para entregar o valor esperado.
* **Victor Lucas (Requisitos Não Funcionais):** Responsável por estruturar os 21 Requisitos Não Funcionais (RNF), garantindo restrições vitais de Usabilidade, Acessibilidade, Desempenho, Armazenamento, Segurança e Compatibilidade.
* **Kyslon (CRUD):** Responsável por definir as operações de Criar, Consultar, Atualizar e Excluir das entidades primárias do aplicativo.
* **Gustavo Henrique (Priorização):** Responsável por classificar as funcionalidades em matriz de prioridade (Essencial, Importante e Secundária) para guiar o fluxo de desenvolvimento.
* **Todos os integrantes:** Responsáveis em conjunto por analisar, revisar e garantir que as funcionalidades documentadas atendam ao problema mapeado nas semanas anteriores.

---

## 4ª Semana

# Atividade 4 — Justificativas de Interface e Arquitetura

## 1. Objetivo

Registrar formalmente as principais decisões de interface (UI/UX) e arquitetura do aplicativo GlicoTrack, garantindo que as escolhas de design, navegação e tecnologias (Flutter, Dart, SQLite) estejam alinhadas com as restrições de acessibilidade, contexto de uso e operação Offline-First.

## 2. Responsabilidades da Equipe

Para a execução da atividade, as responsabilidades foram distribuídas da seguinte forma:

* **Lauro (Interface):** Responsável por documentar as escolhas de cores (paleta de alerta), tipografia gigante.
* **Leonardo (Componentes e Acessibilidade):** Responsável pela configuração da acessibilidade dos componentes e acessibilidade.
* **Gustavo Henrique (Organização e Navegação):** Responsável por justificar os fluxos simplificados de 3 interações e adicionar os elementos de UI que facilitam o registro rápido.
* **Victor Lucas (Decisões relacionadas ao contexto de uso):** Responsável por alinhar as decisões visuais com o contexto dinâmico de uso do aplicativo (transporte, trabalho, etc.).
* **Kyslon (Arquitetura do Sistema):** Responsável por justificar a escolha tecnológica do Flutter/Dart, uso do CustomPainter para performance e adoção do SQLite para a arquitetura Offline-First, com Firebase apenas como backup.
* **Todos os integrantes:** Revisão colaborativa do documento final para garantir coesão com os requisitos das semanas anteriores.

## 3. Entregáveis e Estrutura do Repositório

O arquivo contendo todo o mapeamento técnico desta semana foi adicionado ao diretório do projeto:

* **docs/requisitos.md:** Contém a descrição das funcionalidades, os requisitos (RF e RNF), a análise de CRUD e a matriz de priorização do aplicativo.
* **CHANGELOG.md:** Atualizado para registrar a adição da documentação de requisitos desta semana.

---

## Divisão da Atividade 05 - APRESENTAÇÃO E ENTREGA FINAL

## 2. Responsabilidades da Equipe

Para a execução da atividade, as responsabilidades foram distribuídas da seguinte forma:

### 3.1 Problema e Solução — Lauro Antenor Augusto de Souza Santos
Responsável pela definição e apresentação do **problema identificado**, do **público-alvo** e da **proposta de solução** do aplicativo. Também participou da organização das informações utilizadas para explicar a necessidade do GlicoTrack e como a aplicação busca solucioná-la.

### 3.2 Usuários — Leonardo Carvalho da Cruz
Responsável pela definição e apresentação das **personas do projeto**, com destaque para a **persona prioritária**. Também identificou e descreveu as principais necessidades dos usuários que influenciaram as decisões tomadas durante o desenvolvimento da solução.

### 3.3 Funcionalidades — Kyslon Matos Costa
Responsável pelo levantamento e apresentação das **principais funcionalidades do aplicativo**, relacionando cada uma às necessidades identificadas para os usuários. Também auxiliou na definição e organização dos **requisitos** considerados no projeto.

### 3.4 Protótipo — Victor Lucas Nascimento Fontes
Responsável pelo desenvolvimento e apresentação dos **protótipos do aplicativo**, incluindo a elaboração das principais telas e do **fluxo de navegação**. Também demonstrou as principais funcionalidades representadas no protótipo e a interação esperada do usuário com a aplicação.

### 3.5 Arquitetura — Gustavo Henriques
Responsável pela apresentação da **arquitetura adotada no projeto**, explicando os principais componentes utilizados e suas respectivas funções. Também auxiliou na organização da estrutura técnica da aplicação e na compreensão de como os componentes se relacionam.

---

## 5ª Semana

# Atividade 5 — Criação e Adição das Telas do Aplicativo

## 1. Objetivo

Desenvolver e integrar as telas principais do aplicativo GlicoTrack em Flutter, aplicando as diretrizes de acessibilidade (WCAG AAA e Material Design 3), padronização visual com alto contraste, áreas de toque ampliadas e navegação fluida voltada ao público idoso e com dificuldades motoras ou visuais.

## 2. Responsabilidades da Equipe

Para a execução da etapa de construção da interface, o desenvolvimento e a adição das telas foram divididos entre os integrantes da seguinte forma:

* **Lauro Augusto (`MainScreen`, `SplashScreen` e `HomeScreen`):** responsável pela criação da estrutura principal de navegação com barra inferior flutuante e transições suaves (*Fade-Through*), pela tela de carregamento inicial animada (`SplashScreen`) e pela tela inicial (`HomeScreen`) com o resumo diário e atalhos rápidos de controle.
* **Leonardo Carvalho (`RegisterScreen`):** responsável pelo desenvolvimento da tela de registro de medições (`RegisterScreen`), estruturando o seletor de data acessível, a seleção de momento do dia (café da manhã, almoço e jantar) e os campos de entrada de glicemia, insulina e carboidratos com validação imediata.
* **Kyslon Matos (`HistoryScreen` e `PdfService`):** responsável pela criação da tela de histórico e análise (`HistoryScreen`), implementando o seletor de intervalo de datas, o gráfico de linha de alta performance com `CustomPainter` exibindo as faixas médicas de risco e a integração inicial com o serviço de geração de relatório médico em PDF.
* **Victor Lucas (`TimelineScreen`):** responsável pela implementação da tela de linha do tempo detalhada (`TimelineScreen`), com listagem cronológica de medições, indicadores visuais por cor de gravidade (hipoglicemia, normal e hiperglicemia), correção de responsividade contra *overflow* e diálogo de confirmação para exclusão de dados.
* **Gustavo Henriques (`ProfileHubScreen`, `PersonalInfoScreen`, `ProfileSettingsScreen` e `DataManagementScreen`):** responsável pela criação do ecossistema de perfil do usuário, contendo o painel central de configurações (`ProfileHubScreen`), o formulário de dados pessoais (`PersonalInfoScreen`), a definição de faixas ideais de glicemia (`ProfileSettingsScreen`) e a tela de segurança, backup e exclusão de dados (`DataManagementScreen`).
* **Todos os integrantes:** responsáveis em conjunto pela padronização estética das telas (adoção dos cartões brancos, alto contraste e suporte a leitores de tela via `Semantics`), testes visuais e integração de todo o fluxo no repositório.

## 3. Entregáveis e Estrutura do Repositório

* **glicotrack_dev/lib/screens/:** conjunto completo das telas funcionais do aplicativo (`splash_screen.dart`, `main_screen.dart`, `home_screen.dart`, `register_screen.dart`, `history_screen.dart`, `timeline_screen.dart`, `profile_hub_screen.dart`, `personal_info_screen.dart`, `profile_settings_screen.dart` e `data_management_screen.dart`).
* **glicotrack_dev/lib/services/pdf_service.dart:** serviço dedicado à geração de relatórios médicos em PDF.
* **CHANGELOG.md:** atualizado com o registro de criação e refinamento das telas.

## 4. Organização e Participação Individual

* Cada integrante desenvolveu, testou e enviou suas respectivas telas utilizando sua própria conta do GitHub.
* Os commits foram organizados por tela e funcionalidade para manter o histórico claro de autoria e revisões de interface.

---

## 6ª Semana

# Atividade 6 — Definição e Criação de Diagramas e Documentação de Engenharia

## 1. Objetivo

Formalizar a modelagem comportamental, estrutural e de dados do sistema GlicoTrack por meio dos diagramas de engenharia de software, histórias de usuário e refinamento dos requisitos, garantindo alinhamento completo entre a visão de negócio, a experiência do usuário e a arquitetura técnica.

## 2. Responsabilidades da Equipe

Para a execução desta etapa, toda a equipe trabalhou de maneira integrada na concepção e validação dos artefatos:

* **Todos os integrantes (Lauro Augusto, Leonardo Carvalho, Kyslon Matos, Victor Lucas e Gustavo Henriques):** participaram ativamente da criação, análise e revisão das informações contidas em todos os documentos de modelagem do projeto, incluindo:
  * **Diagrama de Caso de Uso:** mapeamento das interações entre o paciente/cuidador e os recursos principais do aplicativo.
  * **Diagrama de Classe:** definição das entidades de domínio, atributos, métodos e relacionamentos da aplicação.
  * **Diagrama de Entidade e Relacionamento (DER):** estruturação lógica das entidades e cardinalidades para persistência de dados.
  * **Diagrama de Atividades:** detalhamento dos fluxos operacionais, validações e decisões do sistema.
  * **Histórias do Usuário:** especificação das funcionalidades sob a perspectiva prática dos pacientes e cuidadores.
  * **Requisitos de Software:** consolidação, rastreabilidade e revisão final dos Requisitos Funcionais (RF) e Não Funcionais (RNF).

## 3. Entregáveis e Estrutura do Repositório

* **docs/:** documentação atualizada contendo os diagramas de Caso de Uso, Classe, Entidade e Relacionamento (DER), Atividades, Histórias do Usuário e a versão consolidada dos Requisitos de Software e matriz de rastreabilidade.
* **CHANGELOG.md:** atualizado com a inclusão e revisão dos artefatos de modelagem.

## 4. Organização e Participação Individual

* A elaboração e a revisão técnica de cada diagrama e documento foram conduzidas de forma colaborativa por todos os membros do grupo.
* As atualizações foram versionadas no repositório com histórico transparente de revisão e consenso técnico da equipe.

---

## 7ª Semana

# Atividade 7 — Modelagem e Criação do Banco de Dados

## 1. Objetivo

Modelar, estruturar e implementar a camada de persistência do GlicoTrack com foco na arquitetura *Offline-First*, garantindo armazenamento local seguro e confiável (SQLite/SQLCipher) aliado à modelagem em nuvem (Cloud Firestore) para backup e sincronização dos dados do paciente.

## 2. Responsabilidades da Equipe

Para assegurar integridade, segurança e aderência aos requisitos de privacidade (LGPD), todos os membros atuaram conjuntamente em todas as fases do banco de dados:

* **Todos os integrantes (Lauro Augusto, Leonardo Carvalho, Kyslon Matos, Victor Lucas e Gustavo Henriques):** participaram da modelagem lógica e física, criação das tabelas locais, definição das coleções e documentos no Firestore, análise de integridade referencial, configuração de segurança e revisão completa de todo o processo de persistência de dados.

## 3. Entregáveis e Estrutura do Repositório

* **glicotrack_dev/:** implementação da camada de banco de dados local (SQLite/SQLCipher), modelos de domínio e estrutura de coleções para sincronização com o Firestore.
* **docs/arquitetura-unidade-ii.md:** documentação técnica detalhando a arquitetura, o esquema SQLite e a modelagem do Firestore.
* **CHANGELOG.md:** registro das alterações de modelagem e criação do banco de dados.

## 4. Organização e Participação Individual

* Todos os integrantes acompanharam, analisaram e revisaram as definições de tabelas, chaves, índices e regras de armazenamento.
* As entregas foram registradas por meio de commits descritivos no repositório do grupo.

---

## 8ª Semana

# Atividade 8 — Implementação do Backend, Validação, Testes e Entrega Final

## 1. Objetivo

Concluir a implementação do backend integrado ao aplicativo, realizar a validação funcional e execução de testes completos do sistema, bem como produzir a apresentação final e efetuar a revisão e correção de toda a documentação do projeto GlicoTrack.

## 2. Responsabilidades da Equipe

Na reta final do desenvolvimento, a equipe atuou de forma integrada na entrega, qualidade e apresentação da solução:

* **Todos os integrantes (Lauro Augusto, Leonardo Carvalho, Kyslon Matos, Victor Lucas e Gustavo Henriques):** participaram da construção e integração do backend (gerenciamento de estado com Provider, operações completas de CRUD integradas ao banco local, sessão anônima Firebase, sincronização em nuvem, exportação de relatórios PDF/CSV e regras de acesso), bem como da execução de testes e validação de desempenho e fluxos.
* **Apresentação Final e Revisão Documental (Todos os integrantes):** elaboração da apresentação final do projeto, revisão minuciosa e aplicação de correções finais em todos os documentos técnicos, diagramas, matriz de rastreabilidade, `README.md` e `CHANGELOG.md`.

## 3. Entregáveis e Estrutura do Repositório

* **glicotrack_dev/:** aplicativo completo com backend integrado, persistência *Offline-First*, sincronização Firebase/Firestore, exportação de relatórios e suíte de testes validados.
* **docs/validacao-unidade-ii.md:** registro dos testes executados, análise de desempenho e limitações conhecidas.
* **docs/configuracao-firebase.md e docs/fluxos-unidade-ii.md:** documentação revisada de configuração, comandos e fluxos reais da aplicação.
* **Apresentação Final:** material consolidado demonstrando o funcionamento completo do aplicativo e toda a jornada de engenharia do projeto.
* **README.md e CHANGELOG.md:** atualizados e revisados para a entrega final da disciplina.

## 4. Organização e Participação Individual

* Toda a validação do backend, testes em dispositivo/emulador, revisão dos documentos e preparação da apresentação final foram conduzidos em conjunto pelos 5 integrantes.
* O repositório final foi consolidado com histórico limpo, rastreabilidade completa dos requisitos e documentação revisada.