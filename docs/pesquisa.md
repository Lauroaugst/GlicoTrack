1. Informações relevantes sobre o problema

O ponto de partida do GlicoTrack começa analisando o Diabetes Mellitus que é uma doença metabólica que ocorre quando o organismo se torna incapaz de produzir insulina ou até produz, mas em quantidade insuficiente para suprir a demanda interna, ou seja, é uma condição crônica que exige monitoramento contínuo para evitar complicações de saúde severas. O controle inadequado pode levar a picos perigosos: a hiperglicemia (excesso de açúcar no sangue) e a hipoglicemia (níveis abaixo de 70 mg/dL), que requerem ação imediata.

A adesão ao tratamento é um desafio global. O engajamento com o monitoramento precisa ser vitalício e diário, ocorrendo em média 4 vezes ao dia. Muitos pacientes recém-diagnosticados sentem confusão e ansiedade ao lidar com uma grande quantidade de informações, números e jargões médicos, o que dificulta a contagem de carboidratos e a compreensão das doses de insulina basal e bolus.

2. Necessidades e dificuldades dos usuários

Acessibilidade física e visual: Cuidadores de idosos e pacientes mais velhos frequentemente lidam com tremores nas mãos ou visão reduzida, exigindo botões e fontes significativamente maiores.

Baixa escolaridade e analfabetismo funcional: Uma parcela dos pacientes pode ter dificuldade de interpretar gráficos complexos ou mensagens de erro em texto, dependendo de estímulos visuais claros e coloridos para entender o próprio estado de saúde.

Agilidade em espaços públicos: O aplicativo será operado em ambientes diversos comuns no cotidiano das pessoas (restaurantes, transporte público, salas de aula). Portanto o usuário não deverá perder tempo navegando por menus complexos; ele precisa registrar o dado antes de comer ou aplicar a insulina de maneira ágil e prática.

Preocupação com a conectividade e segurança: O paciente não pode perder o histórico médico por estar em uma área sem internet. Além disso, há a necessidade legal e pessoal de ter controle e posse total sobre seus dados de saúde.

3. Dados que possam influenciar o aplicativo

Restrições de Hardware e Desempenho: Devido à prevalência de smartphones de entrada no mercado brasileiro (dispositivos com cerca de 2GB de RAM e GPUs de menor capacidade), o aplicativo requer uma arquitetura estritamente leve. A otimização contínua é um requisito obrigatório para garantir a fluidez da interface e evitar travamentos, especialmente durante a renderização de gráficos.

Eficiência e Tempo de Resposta: A jornada principal do usuário exige máxima agilidade operacional. O fluxo de registro da glicemia deve ser concluído em um tempo inferior a 3 segundos, limitando-se a um ciclo exato de três interações diretas (Abrir o App > Digitar o valor > Confirmar).

Feedback Visual Estratégico (Cores): A interface deve adotar a padronização universal de cores da saúde como seu principal mecanismo de comunicação. A resposta visual imediata sendo o vermelho intenso para hipoglicemia (abaixo de 70), verde para níveis normais e laranja para hiperglicemia é um fator determinante para garantir a compreensão intuitiva e acelerar a tomada de decisão do paciente.

Privacidade e Conformidade (LGPD): Por lidar com métricas crônicas de saúde (classificadas como dados sensíveis), o sistema exige que o paciente tenha controle total sobre suas informações. O aplicativo deve garantir o direito à portabilidade (através da exportação de relatórios em PDF) e disponibilizar um recurso nativo para que o usuário solicite a exclusão definitiva de seus dados armazenados no Firebase.

4. Fontes utilizadas

   Sociedade Brasileira de Diabetes (SBD): Diretrizes Oficiais para o tratamento e monitoramento de Diabetes Tipo 1 e Tipo 2 no Brasil.

https://diretriz.diabetes.org.br/

    Federação Internacional de Diabetes (IDF - International Diabetes Federation): Atlas do Diabetes (informações globais sobre prevalência e desafios do tratamento crônico).
    https://diabetesatlas.org/

    Ministério da Saúde (Brasil): Linha de Cuidado do Diabetes Mellitus (panorama prático do SUS, fluxo de atendimento e protocolos de atenção primária).

https://linhasdecuidado.saude.gov.br/portal/diabetes-mellitus-tipo-2/

    W3C (World Wide Web Consortium): Web Content Accessibility Guidelines - WCAG (diretrizes internacionais de acessibilidade para fundamentar as decisões visuais e de usabilidade do aplicativo).

https://www.w3.org/WAI/standards-guidelines/wcag/
