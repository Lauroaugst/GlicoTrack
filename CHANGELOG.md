# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

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
