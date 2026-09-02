# Atividade 1 - Análise do Estudo de Caso

## 1. Objetivo

Analisar o estudo de caso recebido pelo grupo, compreendendo o problema apresentado, seus usuários, contexto de utilização, objetivos, restrições e características da solução proposta.

A análise deverá demonstrar que o grupo compreendeu o que precisa ser desenvolvido, para quem, por que e em quais condições.

O objetivo deste estudo é analisar o desenvolvimento do GlicoTrack, um aplicativo voltado ao controle e acompanhamento da glicemia e do diabetes. A análise busca compreender as necessidades dos usuários, o contexto de uso, os objetivos e as principais características da solução proposta.

## 2.1 Problema

**Qual problema o aplicativo pretende ajudar a solucionar?**
Permite que o usuário consiga acompanhar o progresso de seu tratamento através do registro de sua glicemia em um processo rápido e de maneira prática, facilitando o acesso a informações primordiais para a análise posterior do médico.

**Por que esse problema é relevante?**
A diabetes exige um monitoramento constante e minucioso das condições do paciente, a falha no registro ou a dificuldade em interpretar números pode levar a crises imediatas, como a hipoglicemia. Além disso grande parte do público afetado inclui idosos com limitações motoras e pessoas com diferentes níveis de instrução, o que pode dificultar a adesão do paciente ao tratamento.

**Qual é a principal necessidade que a solução deverá atender?**
O registro de dados ultrarrápido (em menos de 3 segundos), sem fricção e totalmente offline. A solução precisa garantir que o usuário consiga inserir sua glicemia em no máximo 3 toques, utilizando uma interface de altíssima acessibilidade (teclado numérico gigante e aberto por padrão) e recebendo feedback imediato de seu estado de saúde através de um sistema de cores severas (verde, laranja e vermelho), sem risco de perder dados por falta de internet.

## 2.2 Público e Usuários

**Quem é?**
Em sua maioria idosos, mas principalmente pessoas que precisam acompanhar com precisão seus níveis de glicose, precisando se manter sempre informado caso os níveis se tornem fora do normal.

**Qual relação possui com o aplicativo?**
O público possui o aplicativo instalado em seu celular ou no celular de seu cuidador, geralmente sendo indicado por um médico.

**Quais necessidades possui.**
Usuário possui alguma comorbidade que precisa de atenção com frequência em relação ao seu nível de glicose, geralmente uma diabetes tipo 2, o usuário também precisa manter seu médico informado do seu progresso.

**Em que situação poderá utilizar a solução?**
Sempre antes ou depois da refeição, que é tanto o ponto onde sua glicose está em jejum, quanto o ponto onde sua glicose está no pico, podendo assim analisar com maior precisão sua necessidade e com isso decidir qual o melhor alimento para evitar ou recomendar. Além disso, é muito útil para informar o médico em uma consulta como está indo seu tratamento, ou simplesmente um possível processo de emagrecimento.

## 2.3 Contexto de Uso

- **Ambiente:** Casa, restaurante, trabalho, transporte público ou consultório médico.
- **Momento de utilização:** Antes ou depois das refeições, antes ou depois de atividades físicas, ou antes dormir ou após acordar.
- **Condições do Usuário:** Geralmente com fome, cansado, ou sob estresse. Idosos podem apresentar mãos trêmulas ou dificuldade de precisão.
- **Dispositivo:** De preferência smartphones, os mais antigos e com pouca memória.
- **Conectividade:** Deve funcionar offline, podendo registrar o nível de glicose e aplicação de insulina mesmo sem internet, após isso, os dados serão sincronizados com o Firebase quando tiver conexão.
- **Nível de atenção:** Baixo ou dividido, principalmente antes das refeições. O registro precisa ser simples, com informações visualmente claras.
- **Situação de Urgência:** Caso haja uma suspeita de hipoglicemia ou hiperglicemia. O alerta visual deve ser aparecer na tela imediatamente e de forma bem perceptível.
- **Ruídos:** Pelo fato do usuário pode estar em um restaurante ou no trabalho, o aplicativo não deve utilizar sons para transmitir informações.
- **Movimento:** Como pode ser utilizado para medir ao praticar esportes ou que estejam em um carro, ou no pior dos casos, em uma ambulância, é importante que os botões sejam bem interativos e grandes para facilitar o toque.
- **Tempo disponível:** O registro deve ser feito rápido, de no máximo 3 interações.
- **Experiência do usuário:** Como é um aplicativo que tem como público-alvo pessoas com diabetes tipo 2, e que esse público majoritariamente tem uma idade mais avançada, a interface deve priorizar símbolos, cores e textos grandes para melhorar a acessibilidade.

**Explique como esses contextos podem influenciar o desenvolvimento do aplicativo:**
Esses contextos influenciam, pois, a ideia não é somente desenvolver um aplicativo para um usuário sentado em casa, o usuário deve continuar vivendo sua vida normal, mas com um programa de suporte ajudando-o a ter uma visão melhor de como está seu tratamento, ou seja, os contextos ajudam a transformas essas situações em requisitos técnicos e de interface.

## 2.4 Objetivo e proposta de valor

O aplicativo pretende oferecer aos usuários uma forma simples e eficaz de verificar e registrar informações relacionadas a sua glicemia e controle de diabetes.

Benefício que o aplicativo deverá proporcionar ao usuário: facilidade no controle diário da glicemia, possibilitando ao usuário uma melhor compreensão sobre os seus índices glicêmicos.

## 2.5 Personalidade, identidade e experiência

_Analise: Explique como essas características deverão influenciar a solução. Não é necessário desenvolver a identidade visual nesta atividade._

- **Palavras conceituais:** As palavras deverão ser apresentadas de forma simples, possibilitando uma maior compreensão das informações importantes (controle da glicemia e diabetes).
- **Personalidade da identidade:** Deverá ser organizada e encorajadora, permitindo que os usuários sintam confiança ao utilizar o aplicativo.
- **Tom da interface:** A interface deverá ser simples e intuitiva, proporcionando uma maior facilidade na utilização do aplicativo.
- **Tom da experiência do usuário:** O tom deveria ser acolhedor e encorajador, mesmo que os resultados sejam negativos, deve haver uma comunicação clara e cuidadosa, evitando alarmismo desnecessário, a experiência deve transmitir uma ideia de que o aplicativo está lá para ajudar o usuário a acompanhar sua saúde, e não julgar resultados. O acompanhamento de sua glicemia deve ser simples e tranquilo.
- **Forma como o aplicativo deseja ser lembrado:** O Glicotrack deveria ser lembrado como um aplicativo simples, confiável e acolhedor, que ajude o usuário a cuidar da glicemia de maneira acessível e organizada.

## 2.6 Funcionalidades e características já definidas

Identifique as principais funcionalidades e características que já foram estabelecidas no estudo de caso.

- **Funcionalidade:** Registro manual da glicemia
  - **Necessidade atendida:** Permitir que o paciente registre sua glicemia de forma rápida e mantenha seu histórico de medições.
- **Funcionalidade:** Registro do momento da medição
  - **Necessidade atendida:** Permitir relacionar a glicemia no momento da alimentação, facilitando futuras análises.
- **Funcionalidade:** Registro da dose de insulina
  - **Necessidade atendida:** Permitir que o paciente mantenha o controle de suas doses de insulina junto com o histórico de glicemia.
- **Funcionalidade:** Histórico de medições
  - **Necessidade atendida:** Permitir acompanhar a evolução da glicemia ao longo do tempo, podendo identificar padrões ou possíveis pontos a se preocupar.
- **Funcionalidade:** Gráfico semanal de variabilidade da glicose
  - **Necessidade atendida:** Facilitar a visualização das oscilações da glicemia durante a semana, permitindo que o usuário possa fazer uma análise mais precisa.
- **Funcionalidade:** Alerta de Hipoglicemia
  - **Necessidade atendida:** Colocar na interface de uma forma chamativa quando um valor de glicemia pode representar uma situação de risco.
- **Funcionalidade:** Configuração de faixa ideal de glicemia
  - **Necessidade atendida:** Permitir que o usuário personalize como desejar sua classificação de resultados definidos do nível de glicose para um melhor acompanhamento.
- **Funcionalidade:** Gerar relatório em PDF
  - **Necessidade atendida:** Permitir que o usuário possa compartilhar seu histórico e gráficos com seu profissional de saúde.
- **Funcionalidade:** Armazenamento local com SQLite
  - **Necessidade atendida:** Garantir que os registros sejam salvos mesmo quando o usuário estiver offline.

## 2.7 Restrições e condições

Identifique as restrições apresentadas no estudo de caso que deverão ser respeitadas durante o projeto. Podem estar relacionadas a:

- **Quantidade de telas:** O protótipo é limitado a 4 telas principais (Formulário de entrada, Linha do tempo da semana, Geração de PDF e Configurações).
- **Número de interações:** A funcionalidade principal deve ser concluída em até 3 passos (Abrir App > Digitar número > Tocar "Ok"). O registro exige apenas 2 toques, e o sistema é estritamente proibido de exibir pop-ups de confirmação (ex: "Tem certeza?").
- **Dispositivos:** O aplicativo deve ser leve o suficiente para rodar e ser testado em aparelhos antigos com apenas 2GB de RAM. Os gráficos devem ser renderizados usando CustomPainter (Flutter) para não travar em GPUs fracas.
- **Versão do sistema operacional:** É obrigatório o uso de fontes nativas do sistema operacional para evitar bugs de renderização.
- **Privacidade:** O paciente tem 100% de posse sobre seus dados. O app deve garantir a portabilidade (exportação em PDF) e permitir a exclusão definitiva dos dados armazenados no Firebase por meio de uma requisição direta na própria interface.
- **Armazenamento e Conectividade:** Arquitetura estritamente Offline. O log deve ser salvo no banco local imediatamente, impossibilitando a perda de dados por falta de internet. O Firebase funciona apenas como espelho de backup.
- **Navegação:** O aplicativo deve carregar do zero em menos de 3 segundos. O ato de registrar a glicemia também deve levar menos de 3 segundos no total.
- **Acessibilidade:**
  1. Interface livre de jargões técnicos.
  2. O teclado numérico deve ser imenso e já abrir automaticamente junto com o app.
  3. Fontes gigantes e botão de salvar configurado como o maior elemento da tela, projetados para idosos com tremores nas mãos (incluindo trava de rolagem para evitar toques acidentais).
  4. Uso obrigatório de "cores severas" (vermelho para hipoglicemia, verde para normal, laranja para hiperglicemia) combinado com alertas sonoros, garantindo compreensão instantânea por pacientes com baixa escolaridade ou analfabetismo funcional.
- **Ambiente de utilização:** O design deve suportar uso seguro, rápido e discreto em ambientes dinâmicos e agitados, como restaurantes, transporte público, salas de aula e trabalho.
- **Outras condições específicas:** O repositório no GitHub deve obrigatoriamente manter a pasta/docs atualizada com o Documento de Requisitos, Personas, Pesquisas da SBD, justificativas de decisões visuais/acessibilidade e um arquivo CHANGELOG.md detalhando as melhorias aplicadas após testes com usuários.

## 2.8 Pontos de atenção

Quais são os 3 aspectos do estudo de caso que consideramos mais importantes para o sucesso do aplicativo?

- **Rapidez e Acessibilidade Extrema:** A capacidade de registrar a glicemia em menos de 3 segundos e em até 3 toques, utilizando fontes gigantes e teclado numérico já aberto, eliminando qualquer barreira de uso para idosos ou pessoas em ambientes agitados.
- **Confiabilidade Operacional:** O salvamento imediato no banco de dados local, garantindo que o paciente nunca perca uma anotação crítica por falta de internet.
- **Feedback Visual e Utilidade Clínica:** A tradução imediata dos números através de cores severas (alertando rapidamente sobre hipoglicemia) e a geração de relatórios em PDF, facilitando a tomada de decisão do médico.
