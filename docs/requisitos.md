# Atividade 03 - Funcionalidades e Requisitos

## 2.1 Funcionalidades

| Funcionalidade                      | Necessidade do usuário                                                                                                                        | Descrição                                                                      | Justificativa                                                                                                            |
| :---------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------- |
| Registro de glicemia                | Permitir que o usuário informe rapidamente o valor da glicemia, juntamente com informações como momento da medição e refeição.                | Registrar a glicemia de forma rápida e simples durante sua rotina.             | É a principal função do aplicativo e permite acompanhar a variação dos níveis de glicose ao longo do tempo.              |
| Registro de insulina                | Permitir o registro das doses de insulina aplicadas pelo usuário.                                                                             | Manter o histórico das aplicações realizadas.                                  | Complementa o registro da glicemia e facilita o acompanhamento do tratamento pelo paciente e pelo profissional de saúde. |
| Contagem de carboidratos            | Permitir o registro da quantidade de carboidratos consumida nas refeições para auxiliar no acompanhamento alimentar.                          | Compreender a relação entre alimentação e glicemia.                            | A contagem de carboidratos é relevante para o controle glicêmico e para o acompanhamento do diabetes.                    |
| Classificação da glicemia por cores | Apresentar visualmente a situação da glicemia utilizando verde para valores normais, vermelho para hipoglicemia e laranja para hiperglicemia. | Identificar rapidamente se o resultado está dentro ou fora da faixa definida.  | Facilita a compreensão das informações, principalmente para idosos e usuários com baixa familiaridade tecnológica.       |
| Alerta de hipoglicemia              | Emitir um alerta visual e sonoro quando a glicemia registrada estiver abaixo de 70 mg/dL.                                                     | Ser informado imediatamente sobre uma situação de baixa glicemia.              | A identificação rápida de uma possível hipoglicemia é importante para aumentar a segurança do usuário.                   |
| Histórico e gráfico semanal         | Exibir os registros de glicemia em uma linha do tempo e apresentar um gráfico com a variabilidade glicêmica da semana.                        | Acompanhar a evolução da glicemia e identificar padrões.                       | Permite que o usuário compreenda melhor seus registros e facilita a análise durante consultas médicas.                   |
| Geração de relatório em PDF         | Gerar um relatório contendo os dados registrados para armazenamento ou compartilhamento.                                                      | Levar os registros organizados para acompanhamento com profissionais de saúde. | Facilita o acompanhamento do tratamento e garante ao usuário a possibilidade de portar seus próprios dados.              |
| Configuração da faixa ideal         | Permitir definir a faixa de glicemia considerada adequada, como 70 a 180 mg/dL.                                                               | Adaptar o aplicativo às orientações recebidas para seu acompanhamento.         | Permite que as classificações e alertas sejam adequados às configurações utilizadas pelo usuário.                        |
| Armazenamento Offline-First         | Salvar os registros imediatamente no armazenamento local, sincronizando-os posteriormente com o Firebase quando houver conexão.               | Registrar a glicemia mesmo sem acesso à internet.                              | Evita a perda de informações e garante que a função principal esteja disponível em qualquer ambiente.                    |
| Exclusão de dados                   | Permitir que o usuário exclua seus registros e solicite a exclusão dos dados armazenados no Firebase.                                         | Ter controle sobre seus dados pessoais de saúde.                               | Atende ao compromisso de projeto e requisitos relacionados à privacidade, segurança e direitos da LGPD.

## 2.2 Requisitos funcionais

- **RF01 - Registro de glicemia:** O sistema deve permitir que o usuário registre o valor de sua glicemia de forma rápida.
- **RF02 - Registro do momento da medição:** O sistema deve permitir identificar o momento em que a glicemia foi medida, como antes ou depois de uma refeição.
- **RF03 - Registro de insulina:** O sistema deve permitir que o usuário registre as doses de insulina aplicadas.
- **RF04 - Registro de carboidratos:** O sistema deve permitir o registro da quantidade de carboidratos consumida nas refeições.
- **RF05 - Classificação da glicemia:** O sistema deve classificar visualmente o resultado da glicemia de acordo com a faixa configurada pelo usuário.
- **RF06 - Alerta de hipoglicemia:** O sistema deve emitir um alerta visual e sonoro quando o valor registrado for inferior a 70 mg/dL.
- **RF07 - Indicação de hiperglicemia:** O sistema deve identificar visualmente valores acima da faixa considerada normal, utilizando a indicação de cor laranja.
- **RF08 - Histórico de glicemias:** O sistema deve permitir que o usuário consulte os registros anteriores de glicemia.
- **RF09 - Gráfico semanal:** O sistema deve apresentar um gráfico de linha com os registros e a variabilidade glicêmica da semana.
- **RF10 - Geração de relatório:** O sistema deve permitir a geração de um relatório em formato PDF contendo os dados registrados pelo usuário.
- **RF11 - Compartilhamento do relatório:** O sistema deve permitir que o usuário compartilhe o relatório PDF com profissionais de saúde.
- **RF12 - Configuração da faixa ideal:** O sistema deve permitir que o usuário configure a faixa de glicemia utilizada para classificação dos resultados.
- **RF13 - Armazenamento local:** O sistema deve salvar os registros no armazenamento local do dispositivo imediatamente após sua inserção.
- **RF14 - Sincronização com o Firebase:** O sistema deve sincronizar os dados armazenados localmente com o Firebase quando houver conexão disponível.
- **RF15 - Funcionamento offline:** O sistema deve permitir o registro e a consulta dos dados principais mesmo quando o dispositivo estiver sem conexão com a internet.
- **RF16 - Exclusão de dados:** O sistema deve permitir que o usuário exclua seus registros e solicite a exclusão dos dados armazenados no Firebase.
- **RF17 - Consulta dos registros:** O sistema deve permitir que o usuário consulte suas informações de glicemia, insulina e carboidratos registradas anteriormente.                  |

## 2.4 CRUD

O CRUD do GlicoTrack pode ser representado principalmente pelos registros de glicemia, insulina e carboidratos, além das configurações da faixa ideal.

- **C - Criar:** Glicemia, insulina, carboidratos, momento da medição e observações (O usuário poderá inserir uma nova medição e seus dados relacionados).
- **R - Consultar:** Histórico de glicemia, insulina e carboidratos (O usuário poderá visualizar os registros anteriores e o gráfico semanal).
- **U - Atualizar:** Registros já cadastrados e faixa ideal (O usuário poderá corrigir informações registradas incorretamente e alterar a faixa ideal configurada).
- **D - Excluir:** Registros e dados armazenados (O usuário poderá excluir registros e solicitar a exclusão dos dados armazenados no Firebase).

**Justificativa:** As quatro operações são relevantes para o GlicoTrack. A criação permite registrar as informações diariamente; a consulta possibilita acompanhar o histórico; a atualização permite corrigir possíveis erros de registro; e a exclusão garante ao usuário maior controle sobre seus próprios dados, especialmente por se tratarem de informações pessoais e de saúde.

## 2.5 Priorização

| Prioridade     | Funcionalidade              | Justificativa                                                                                     |
| :------------- | :-------------------------- | :------------------------------------------------------------------------------------------------ |
| **Essencial**  | Registro de glicemia        | É a função central do aplicativo e atende diretamente à necessidade de monitoramento da glicemia. |
| **Essencial**  | Classificação por cores     | Permite compreender rapidamente a situação da glicemia.                                           |
| **Essencial**  | Alerta de hipoglicemia      | Avisa imediatamente quando o valor registrado está abaixo de 70 mg/dL.                            |
| **Essencial**  | Armazenamento Offline-First | Garante que nenhum registro seja perdido por falta de internet.                                   |
| **Essencial**  | Histórico de glicemias      | Permite acompanhar os registros e a evolução da glicemia.                                         |
| **Essencial**  | Configuração da faixa ideal | Permite adaptar a classificação dos resultados à faixa definida para o acompanhamento.            |
| **Importante** | Registro de insulina        | Complementa o acompanhamento da glicemia e do tratamento.                                         |
| **Importante** | Contagem de carboidratos    | Auxilia o usuário a relacionar alimentação e variações da glicemia.                               |
| **Importante** | Gráfico semanal             | Facilita a identificação de padrões e variações da glicemia.                                      |
| **Importante** | Relatório em PDF            | Facilita o compartilhamento das informações com profissionais de saúde.                           |
| **Importante** | Exclusão de dados           | Garante maior controle do usuário sobre seus dados pessoais e de saúde.                           |
| **Secundária** | Compartilhamento do PDF     | Agrega praticidade ao envio dos dados, mas o relatório pode ser gerado sem essa função.           |
| **Secundária** | Observações complementares  | Pode ser adicionada posteriormente para registrar informações adicionais sobre cada medição.      |
