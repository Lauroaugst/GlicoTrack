### 2.4 Justificativas

Registre brevemente as principais decisões de interface e arquitetura, como:

*   **Escolha das cores (paleta e contraste):** A interface adota majoritariamente o branco e o azul-claro para gerar uma sensação de assepsia e clareza mental. O uso de cores severas é obrigatório para indicar o estado de saúde: vermelho para hipoglicemia (abaixo de 70 mg/dL), verde para a faixa normal e laranja para hiperglicemia. Essa escolha de contraste ajuda pacientes com baixa escolaridade ou analfabetos funcionais a entenderem o resultado imediatamente apenas pela cor.

*   **Tipografia (hierarquia e legibilidade):** O aplicativo utilizará fontes nativas do sistema operacional para evitar bugs de renderização. A tela de registro contará com uma fonte gigante, projetada especificamente para facilitar a leitura por idosos ou pessoas com as mãos trêmulas. A linguagem visual e textual não possuirá jargões desnecessários.

*   **Organização das informações (disposição e fluxo visual):** O visual segue o formato de um "dashboard" (painel) limpo e organizado. O elemento de maior importância (salvar a medição) ganha destaque absoluto: o botão de salvar será o maior da tela de registro.

*   **Navegação (fluxos, menus e facilidade de localização):** A principal funcionalidade deve ocorrer em, no máximo, 3 interações (Abrir o App > Digitar o número > Tocar "Ok"). Para garantir agilidade na anotação, o aplicativo não utilizará telas de confirmação (como "Tem certeza?") e deverá abrir com o teclado numérico já expandido na tela principal.

*   **Componentes (elementos de UI utilizados):** A interface fará uso de um teclado numérico nativo imenso e formulários com campos gigantes. Para o gráfico de linha que mostra a variabilidade glicêmica da semana, será utilizado o *CustomPainter* do Flutter, visando otimização para que a interface não trave em dispositivos com GPUs mais fracas.

*   **Acessibilidade (conformidade com padrões de inclusão):** Além da indicação por cores agressivas, o aplicativo contará com alertas multissensoriais; por exemplo, ao digitar um valor de hipoglicemia (como 68 mg/dL), o app reagirá imediatamente com um alerta claro e sonoro. O projeto também atende à portabilidade e privacidade da LGPD, garantindo que o relatório PDF pertença 100% ao usuário e permitindo a exclusão de dados em nuvem via requisição no app.

*   **Decisões relacionadas ao contexto de uso (condições e ambiente em que o sistema será acessado):** O sistema é projetado para engajamento vitalício crônico (4x ao dia) e de vigília (para cuidadores). Como será acessado em restaurantes, salas de aula, trabalho e transporte público, o app foi desenhado para registrar a glicemia em menos de 3 segundos, permitindo que o paciente faça a anotação de forma rápida e discreta antes de comer ou aplicar a insulina.

*   **Arquitetura do sistema (visão geral da arquitetura adotada e principais componentes):**
    *   **Frontend (Interface):** O desenvolvimento será realizado utilizando a linguagem Dart e o framework Flutter. A arquitetura foca em alta performance, devendo abrir em menos de 3 segundos e suportar perfeitamente aparelhos mais antigos com até 2GB de RAM.
    *   **Backend e Banco de Dados Local:** O aplicativo adotará uma arquitetura "Offline-First" utilizando o banco de dados local SQLite. Essa decisão garante que o log seja salvo localmente de forma imediata, garantindo que o paciente nunca perca um dado por falta de acesso à internet.
    *   **Sincronização em Nuvem:** O serviço de nuvem Firebase será utilizado exclusivamente como um espelho de backup para os dados salvos no SQLite, não sendo um impeditivo para o funcionamento offline da aplicação.