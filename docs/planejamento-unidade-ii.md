# Escopo, EAP e sprints - Unidade II

## Escopo

Transformar o frontend existente em diário funcional de glicemia, insulina e carboidratos, com sessão Firebase automática, SQLite criptografado como armazenamento principal, sincronização/backup Firestore, metas, filtros, indicadores e portabilidade. Preservar Home, Registro, Perfil, Histórico e as telas secundárias já desenvolvidas pela equipe, sem criar telas de login, cadastro ou recuperação de senha. A sessão anônima é criada em segundo plano somente se não houver uma sessão persistida.

Fora do escopo atual: diagnóstico, integração com glicosímetros, prontuário compartilhado entre contas, notificações programadas, execução de sincronização com processo encerrado e certificação regulatória. A revisão clínica e jurídica e a configuração de produção dependem do grupo e dos responsáveis pelo produto.

Definição pendente: o objetivo do estudo de caso, página 1, menciona cálculo de insulina baseado nas diretrizes da SBD. Os PDFs não fornecem fórmula, parâmetros individuais ou fluxo de cálculo, e as telas existentes registram doses já aplicadas. O registro está implementado; o cálculo não pode ser declarado atendido nem descartado como dispensável sem esclarecimento com a disciplina. Não foi inventada uma regra de dose.

## EAP simplificada

1. Análise: requisitos/PDFs, auditoria de código e decisões de preservação.
2. Domínio: registro agregado, validações, metas, classificação e tendências informativas.
3. Dados locais: esquema SQLite, criptografia, chave segura, CRUD, fila e conflitos.
4. Nuvem: autenticação, transações, importação, restauração, segurança e exclusão recursiva.
5. Integração: telas existentes, foco/alertas, histórico e CustomPainter, perfil e relatórios.
6. Qualidade: testes de domínio, persistência, sincronização, interface, regras e aceite nativo.
7. Entrega: diagramas, matriz, configuração, registro de IA e defesa do código.

## Planejamento de sprints (proposta para organização do grupo)

| Sprint | Objetivo | Critério de aceite |
| --- | --- | --- |
| 1 | Auditoria, domínio, SQLite e autenticação | Sem dados simulados; CRUD local testado; sessão protegida |
| 2 | Integração das telas, metas, categorias, gráficos e relatórios | Usuário salva offline e consulta/edita/exporta os próprios dados |
| 3 | Sincronização, conflitos, regras, backup e exclusão | Testes com emuladores e duas contas; tombstones sem duplicidade |
| 4 | Configuração real, testes nativos, acessibilidade e apresentação | APK executado em aparelho, medição 2 GB, rastreabilidade e revisão coletiva |

Essa tabela é um plano de organização, não evidência de sprints presenciais já realizadas. Não foram atribuídas novas contribuições a integrantes. As responsabilidades históricas do README foram preservadas. Cada integrante deve compreender o código, revisar os resultados e registrar somente as contribuições que de fato realizar com sua própria conta.
