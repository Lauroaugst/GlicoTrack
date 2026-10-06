### 2.4 Justificativas

Registre brevemente as principais decisões de interface e arquitetura, como:

- **Escolha das cores (paleta e contraste):** A interface adota majoritariamente o branco e o azul-claro para gerar uma sensação de assepsia e clareza mental. O uso de cores severas é obrigatório para indicar o estado de saúde: vermelho para hipoglicemia (abaixo de 70 mg/dL), verde para a faixa normal e laranja para hiperglicemia. Essa escolha de contraste ajuda pacientes com baixa escolaridade ou analfabetos funcionais a entenderem o resultado imediatamente apenas pela cor.

- **Tipografia (hierarquia e legibilidade):** O aplicativo utilizará fontes nativas do sistema operacional para evitar bugs de renderização. A tela de registro contará com uma fonte gigante, projetada especificamente para facilitar a leitura por idosos ou pessoas com as mãos trêmulas. A linguagem visual e textual não possuirá jargões desnecessários.

- **Arquitetura do sistema (visão geral da arquitetura adotada e principais componentes):**
  - **Frontend (Interface):** O desenvolvimento será realizado utilizando a linguagem Dart e o framework Flutter. A arquitetura foca em alta performance, devendo abrir em menos de 3 segundos e suportar perfeitamente aparelhos mais antigos com até 2GB de RAM.
  - **Backend e Banco de Dados Local:** O aplicativo adotará uma arquitetura "Offline-First" utilizando o banco de dados local SQLite. Essa decisão garante que o log seja salvo localmente de forma imediata, garantindo que o paciente nunca perca um dado por falta de acesso à internet.
  - **Sincronização em Nuvem:** O serviço de nuvem Firebase será utilizado exclusivamente como um espelho de backup para os dados salvos no SQLite, não sendo um impeditivo para o funcionamento offline da aplicação.
