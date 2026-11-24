Modelagem do Banco de Dados Firebase — GlicoTrack
Banco de dados: Cloud Firestore
Aplicativo: GlicoTrack
Linguagem: Dart / Flutter
Arquitetura: Offline-first (SQLite + Firebase Firestore)
Autenticação: Firebase Authentication anônima

O banco de dados do GlicoTrack utiliza o Firebase Cloud Firestore, um banco NoSQL orientado a documentos, como mecanismo 
de armazenamento e sincronização em nuvem. Os dados são organizados hierarquicamente na coleção users, em que cada documento 
representa um usuário identificado pelo Firebase Authentication. Cada usuário possui uma subcoleção documents, destinada aos
registros sincronizados.

1. Visão geral da arquitetura
O GlicoTrack utiliza dois bancos de dados com responsabilidades diferentes.

SQLite - Dados locais criptografados

Firestore - Sincronização na nuvem


A arquitetura offline-first utiliza SQLite criptografado como armazenamento local e o Firestore como mecanismo de
sincronização, possibilitando que o aplicativo continue funcionando sem conexão com a internet. A separação dos dados por UID permite
que diferentes usuários utilizem o mesmo projeto Firebase sem compartilhar seus registros, desde que as regras de segurança estejam
corretamente configuradas.

2. Estrutura de coleções e documentos
No Firestore, a organização utilizada pelo projeto segue a estrutura:

users/{uid}/documents/{documentId}
users

  uid_usuario_A

    documents

      registro_001

      registro_002

      outro_documento


  uid_usuario_B

Cada usuário possui uma subcoleção documents independente.

Diferentemente de uma modelagem relacional, o Firestore não utiliza tabelas, chaves estrangeiras e JOIN. Os dados são 
organizados em documentos e coleções.

A coleção documents é genérica porque a camada de sincronização utiliza um identificador de tipo (kind) para diferenciar
os documentos.

3. Modelagem lógica dos documentos

A estrutura pode ser dividida em duas partes: os metadados de sincronização e os dados de domínio.

O documentId identifica o registro no caminho do Firestore, enquanto o uid identifica o proprietário pelo caminho 
users/{uid}.


4. Mapeamento da classe HealthRecord
A principal entidade de domínio é HealthRecord, responsável por representar medições de glicemia e informações associadas,
incluindo data, horário, categoria, refeição, dose de insulina, quantidade de carboidratos e observações. Os objetos são 
convertidos em mapas JSON por meio dos métodos toJson() e fromJson(), permitindo sua persistência e recuperação.

class HealthRecord {
  final String id;
  final String uid;
  final int glucose;
  final DateTime measuredAt;
  final MeasurementCategory category;
  final String meal;
  final DateTime createdAt;
  final double? insulin;
  final double? carbs;
  final String notes;
}

Correspondência Dart → Firestore

Atributo Dart                   	Campo no payload	                        Tipo armazenado
id	                              ID do documento                          	String
uid	                              Identificador no caminho do usuário      	String
glucose                         	glucose	                                  Number (inteiro)
measuredAt	                      measuredAt	                              Number (milissegundos Unix)
category	                        category	                                String
meal	                            meal	                                    String
createdAt	                        createdAt	                                Number (milissegundos Unix)
insulin                         	insulin	                                  Number ou null
carbs	                            carbs                                    	Number ou null
notes                           	notes	                                    String



5. Mapeamento das classes de domínio
HealthRecord (Entidade de domínio Dart)
id, uid, glucose, measuredAt, category, meal, insulin, carbs, notes, createdAt

            ⇩⇩⇩
HealthRecord.toJson() (Serialização para Map<String, dynamic>)

            ⇩⇩⇩
SyncDocument (Envelope de sincronização)
kind, payload, revisão e metadados

            ⇩⇩⇩
Firestore (users/{uid}/documents/{documentId})


No sentido inverso, o documento é recuperado do Firestore, seu payload é extraído e o objeto de domínio pode ser reconstruído com:
HealthRecord.fromJson(
  doc.id,
  doc.uid,
  doc.payload,
);

É justamente esse processo que foi utilizado para carregar os registros reais no Histórico e na Linha do Tempo.

Outras classes do domínio
Classe ou conceito	                  Mapeamento
HealthRecord	                        Documento com kind: 'record' e dados no payload
MeasurementCategory	                  Enum serializado como String dentro de category
SyncDocument	                        Representação intermediária com dados e metadados de sincronização
Perfil do usuário	                    Necessário verificar a classe e o serviço de persistência para determinar o documento correspondente
Configurações de glicemia            	Necessário verificar a implementação atual antes de definir os campos e o tipo de documento

6. Relacionamento entre usuários e registros

Um usuário pode possuir vários registros. Cada registro pertence a um usuário.

No Firestore, essa relação é representada pelo caminho dos documentos, sem necessidade de uma chave estrangeira relacional.

Para garantir o isolamento entre usuários, as regras de segurança devem exigir que o UID autenticado corresponda ao UID presente no caminho do documento.

7. Como a sincronização funciona
    1. O usuário registra uma glicemia no aplicativo Flutter.
    2. O GlicoTrack cria um objeto HealthRecord e o serializa com toJson().
    3. O registro é persistido no SQLite criptografado, permitindo o funcionamento offline.
    4. O serviço de sincronização identifica os documentos pendentes e os envia ao Firestore, quando possível.
    5. O Firestore armazena os dados no caminho correspondente ao UID do usuário.
    6. Na leitura, os documentos são convertidos novamente em objetos Dart por meio de fromJson().
