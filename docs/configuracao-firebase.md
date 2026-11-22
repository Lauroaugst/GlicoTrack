# Configuração e execução

## Ambiente e dependências

Validar com Flutter 3.50.0 / Dart 3.14.0 ou versão compatível com o `pubspec.lock`. Aplicação móvel: Android API 23+ e iOS 15+. SQLCipher não está implementado para Web/Windows nesta entrega. Não existe fallback inseguro de banco para essas plataformas.

```powershell
cd glicotrack_dev
flutter pub get
dart format .
flutter analyze
flutter test
flutter build apk --debug
```

As ferramentas utilizadas nesta sessão foram instaladas apenas em `.tools/` (ignorada no Git). O caminho não é obrigatório para outros integrantes. Não versionar caches, SDKs, `local.properties`, credenciais de serviço ou configurações pessoais.

## Firebase do grupo e verificações externas

1. A main já contém `lib/firebase_options.dart`, com opções Android/iOS/Web do projeto `glicotrack-bf802`, publicado pelo grupo. A inicialização agora utiliza `DefaultFirebaseOptions.currentPlatform`. A presença do arquivo não comprova serviços habilitados ou regras implantadas; conferir isso no console com a conta responsável.
2. Habilitar **Authentication > Anônimo** e criar o banco **Cloud Firestore**. Definir região e revisar política de privacidade do produto. A sessão é criada automaticamente somente se não houver uma sessão persistida; não há tela de login ou cadastro.
3. Registrar aplicativos com os identificadores atuais ou alterar esses identificadores de forma coordenada: Android `com.example.glicotrack_dev`, iOS `com.example.glicotrackDev`.
4. Há dois caminhos de inicialização suportados:
   - usar as opções já versionadas em `firebase_options.dart` (padrão); ou
   - fornecer opções públicas de outro ambiente autorizado em arquivo local `firebase.local.json` e executar com `--dart-define-from-file=firebase.local.json`. Para registrar novos apps/projetos, atualizar as opções pelo FlutterFire CLI e conferir as configurações nativas geradas.
5. Para o primeiro caminho, preencher **valores reais**, sem valores de exemplo fictícios:

| Chave do arquivo local | Origem |
| --- | --- |
| FIREBASE_API_KEY | FirebaseOptions.apiKey do app cadastrado |
| FIREBASE_APP_ID | FirebaseOptions.appId da plataforma executada |
| FIREBASE_PROJECT_ID | ID do projeto |
| FIREBASE_MESSAGING_SENDER_ID | messagingSenderId |
| FIREBASE_IOS_BUNDLE_ID | Bundle ID, quando executar iOS |

As opções públicas identificam o aplicativo e não substituem as regras de acesso. Nunca usar chave administrativa/service account no Flutter. Gerar um arquivo distinto por plataforma quando os appIds diferirem.

6. Na raiz, instalar as dependências servidoras com Node 22 e publicar **após revisão na conta correta**:

```powershell
cd functions
npm ci
cd ..
firebase deploy --project glicotrack-bf802 --only firestore:rules,firestore:indexes,functions
```

O comando aponta explicitamente para o projeto identificado no arquivo do grupo; revisar a conta selecionada antes de executá-lo. Não foi feito deploy nesta integração. Cloud Functions pode exigir plano com faturamento habilitado. A callable usa `us-central1`, correspondente à instância padrão utilizada no cliente. A inicialização por `dart-define` não exige credenciais administrativas nem o plugin Google Services; se optar pelo fluxo nativo, executar integralmente os passos do FlutterFire para Android e iOS.

7. Em macOS, `flutter pub get`, `cd ios`, `pod install`, abrir o workspace e conferir assinatura/capabilities do Keychain. O Podfile está incluído porque SQLCipher requer CocoaPods. Build e execução iOS não são verificáveis neste host Windows.
8. Em produção, configurar assinatura de release: o template atual assina release com chave debug. Não distribuir esse build como versão de produção.

Se a inicialização falhar, o app permite nova tentativa. A primeira criação da sessão anônima exige internet; uma sessão já persistida é reutilizada para acesso local offline. A opção de ambiente em dart-define continua disponível.

## Emuladores e testes

Os testes locais usam o ID **demo-glicotrack**, que não representa uma conta Firebase real.

```powershell
cd functions
npm ci
npm test
cd ..
firebase emulators:exec --project demo-glicotrack --only firestore "node --test functions/test/firestore.rules.test.js"
firebase emulators:exec --project demo-glicotrack --only auth,firestore,functions "node --test --test-concurrency=1 functions/test/deletion.test.js functions/test/firestore.rules.test.js functions/test/firebase.integration.test.js"
```

Java 21+ é necessário para o emulador. Para testar o app em Android, iniciar Auth, Firestore e Functions com `firebase emulators:start --project demo-glicotrack --only auth,firestore,functions`. Configurar o app com as opções do projeto **demo** de teste, e `FIREBASE_EMULATOR_HOST=10.0.2.2` para emulador Android ou IP do computador para dispositivo físico. Portas: Auth 9099, Firestore 8080, Functions 5001. O modo emulador é ativado explicitamente por `dart-define`; não há alteração automática do ambiente de produção.

Teste de criptografia real, em dispositivo Android/iOS dedicado a testes:

```powershell
cd glicotrack_dev
flutter test integration_test/encryption_test.dart -d ID_DO_DISPOSITIVO
```

Ele verifica SQLCipher, cabeçalho não legível como SQLite comum, falha com chave incorreta e reabertura. Não substituir esse teste pelos testes FFI. O teste usa UID técnico `encryption-test` e limpa seus dados, sem acessar prontuário real.

## Roteiro de aceite em aparelho

- Abrir uma instalação nova com internet, verificar criação automática da sessão anônima e entrada nas quatro abas; reiniciar offline e conferir que o UID e os dados são preservados.
- Desligar rede; salvar cinco medições em um minuto; editar e excluir; fechar/reabrir e conferir histórico.
- Digitar 68: fundo vermelho, texto e um alerta sonoro por episódio; depois 120/200: verde/laranja. Som depende do volume/configuração da plataforma.
- Alterar meta inferior para 90 e digitar 80: exibir abaixo da meta, sem denominar hipoglicemia.
- Reconectar e conferir backup/restauração na sessão atual, incluindo IDs, contagens, perfil e metas.
- Verificar isolamento entre duas sessões anônimas. Uma instalação nova recebe outro UID; não oferece recuperação automática dos dados de outro aparelho.
- Exportar PDF/CSV com rede desligada; conferir acentos, observações e os filtros selecionados.
- Solicitar exclusão pela confirmação existente, sem senha na sessão anônima; interromper rede e repetir; confirmar bloqueio contra reenvio pelo UID excluído. Uma conta com senha já persistida ainda exige reautenticação.
- Medir abertura, persistência, atualização de lista, quadros GPU, memória e áudio em aparelho de 2 GB. Registrar resultados em `validacao-unidade-ii.md` sem substituir por números do host.

## Sessão automática e limites de recuperação

O fluxo preserva a sessão automática que já existia na main do grupo. `AppBootstrap.restoreSession` reutiliza o usuário persistido ou chama `signInAnonymously` se não houver usuário. Não há formulário de autenticação nem ação de logout. A sincronização é controlada pelo AppStore, reutilizando o AppBootstrap com `startSync: false` para evitar inicialização duplicada.

Cada UID só pode acessar os próprios documentos. O perfil da sessão anônima usa e-mail vazio. A exclusão usa o token Firebase dessa sessão e a confirmação existente; contas com senha já persistidas continuam exigindo senha recente. Não se cria outra sessão antes da conclusão da exclusão.

Sem vínculo a uma conta recuperável, reinstalar, limpar os dados do app ou mudar de aparelho pode perder o acesso ao UID anterior. Backup e restauração consultam somente o UID atual; o app não promete transferência entre aparelhos. Não foi acrescentado outro fluxo de interface para resolver essa limitação.

Para uma configuração local de emuladores em outra porta, definir `FUNCTIONS_EMULATOR_ORIGIN` (por exemplo, `http://127.0.0.1:15001`) ao executar os testes Node da callable. Os hosts Auth/Firestore são fornecidos pelo Firebase CLI. Arquivos `firebase.*.local.json` são ignorados no Git para preservar os ajustes locais.
