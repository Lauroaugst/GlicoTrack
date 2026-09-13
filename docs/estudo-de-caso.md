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
Pessoas com diabetes em sua maioria idosos de ambos os generos, mas principalmente pessoas que precisam acompanhar com precisão seus níveis de glicose, precisando se manter sempre informado caso os níveis se tornem fora do normal.

**Qual relação possui com o aplicativo?**
O público possui o aplicativo instalado em seu celular ou no celular de seu cuidador, geralmente sendo indicado por um médico como meio de controle e monitoramento da sua condição.

**Quais necessidades possui.**
Usuário possui alguma comorbidade que precisa de atenção com frequência em relação ao seu nível de glicose, geralmente uma diabetes tipo 2, o usuário também precisa manter seu médico informado do seu progresso.

**Em que situação poderá utilizar a solução?**
Sempre antes ou depois da refeição, que é tanto o ponto onde sua glicose está em jejum, quanto o ponto onde sua glicose está no pico, podendo assim analisar com maior precisão sua necessidade e com isso decidir qual o melhor alimento para evitar ou recomendar. Além disso, é muito útil para informar o médico em uma consulta como está indo seu tratamento, ou simplesmente um possível processo de emagrecimento.

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
