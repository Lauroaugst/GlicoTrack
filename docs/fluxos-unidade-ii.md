# Casos de uso e navegação - Unidade II

## Casos de uso

```mermaid
flowchart LR
  pessoa[Paciente ou cuidador]
  profissional[Profissional de saúde]
  firebase[Firebase Auth / Firestore]
  pessoa --> inicio([Abrir as telas existentes com sessão automática])
  pessoa --> registro([Registrar glicemia, dose e carboidratos offline])
  pessoa --> editar([Consultar, filtrar, editar e excluir medições])
  pessoa --> metas([Editar perfil e metas])
  pessoa --> indicadores([Ver frequência, estatísticas e tendências])
  pessoa --> exportar([Exportar PDF e CSV])
  exportar --> profissional
  pessoa --> backup([Sincronizar e restaurar])
  pessoa --> excluir([Confirmar exclusão dos próprios dados])
  inicio --> firebase
  backup --> firebase
  excluir --> servidor[Callable autenticada: bloquear, excluir e impedir reenvio]
  registro --> validar[Validar e persistir SQLite criptografado]
  validar --> alerta[Classificar por meta; alerta visual e sonoro abaixo de 70]
```

Paciente e cuidador usam a mesma conta responsável pelos dados; não foi implementado compartilhamento de prontuário entre contas ou um perfil de profissional com acesso remoto. O profissional recebe somente o arquivo que o paciente decide compartilhar.

## Navegação real

```mermaid
flowchart TD
  inicio[Abrir aplicativo] --> boot[Inicializar Firebase sem espera artificial]
  boot -->|configuração ausente ou inválida| configurar[Mensagem de configuração / tentar novamente]
  configurar --> boot
  boot --> sessao{Sessão Firebase persistida?}
  sessao -->|não| anonima[Criar sessão anônima com internet]
  anonima --> local[Abrir SQLCipher e carregar UID]
  sessao -->|sim| local
  local -->|falha de armazenamento| tentar[Tentar novamente]
  tentar --> local
  local --> abas[MainScreen: Home / Registro / Perfil / Histórico]
  abas --> home[Home: resumo real e frequência]
  home --> registro[Registro com foco numérico]
  abas --> registro
  registro --> salvo[Validar e salvar localmente]
  salvo --> dados[Atualizar Home / Histórico / fila]
  abas --> historico[Histórico: semana, mês, período, categoria]
  historico --> pdf[PDF compartilhável]
  historico --> csv[CSV compartilhável]
  historico --> timeline[Linha do tempo]
  timeline --> editar[Editar no mesmo formulário]
  timeline --> remover[Excluir registro ou histórico com confirmação]
  abas --> perfil[Perfil]
  perfil --> pessoais[Nome, idade, peso, foto]
  perfil --> faixa[Meta glicêmica personalizada]
  perfil --> seguranca[Segurança e Dados]
  seguranca --> backup[Backup / restauração]
  seguranca --> exclusao[Confirmação de exclusão]
  exclusao -->|sucesso| anonima
  exclusao -->|falha após bloqueio| pendente[Exclusão pendente; fila bloqueada e retentativa]
```

A Splash mostra a marca enquanto inicializa. A sessão persistida é reutilizada, inclusive offline; na primeira abertura, a criação anônima exige internet e permite nova tentativa em caso de falha. Em seguida são abertas as quatro abas existentes, sem tela de login. O Navigator é vinculado ao UID e descartado quando a sessão muda após exclusão.

Não há confirmação extra no salvamento. O teclado oferece ação de conclusão; com o teclado visível, o botão original de salvar aparece em área fixa para continuar acessível. Data/hora, refeição e categoria têm valores iniciais, que podem ser alterados. A fonte ampliada, cores, componentes e quatro abas permanecem alinhados ao frontend existente. O fundo da tela de registro muda conforme a classificação, além do texto explícito. A meta inferior nunca altera o limiar fixo de hipoglicemia.

Sessões anônimas existentes conservam o UID e seus registros. AppBootstrap é reutilizado após a verificação da sessão, com uma única sincronização por Provider. A confirmação de exclusão não exige senha de uma sessão anônima; contas com senha já persistidas conservam a exigência de senha recente. Sem vínculo de conta, a restauração só alcança o UID atual, não uma instalação nova ou outro aparelho.
