# EducaIA
Plataforma de aprendizado personalizada com Flutter e Firebase.

## Estrutura
educaia/
├── android/                    # Configurações específicas para Android
├── ios/                        # Configurações específicas para iOS
├── web/                        # Configurações para web (se for multiplataforma)
├── lib/                        # Código principal do Flutter
│   ├── models/                 # Classes de dados (ex.: User, Content)
│   │   ├── user.dart           # Modelo para usuário (nome, interesses, nível)
│   │   ├── content.dart        # Modelo para conteúdo (título, tipo, dificuldade)
│   │   └── history.dart        # Modelo para histórico (status de conteúdos)
│   ├── screens/                # Telas do app
│   │   ├── cadastro_screen.dart # Tela de cadastro
│   │   ├── quiz_screen.dart    # Tela do quiz inicial
│   │   ├── recommendations_screen.dart # Tela de recomendações
│   │   ├── content_screen.dart # Tela para exibir conteúdos
│   │   ├── study_screen.dart   # Tela da área de estudo
│   │   └── chat_screen.dart    # Tela do chat IA
│   ├── services/               # Lógica de backend (Firebase, APIs)
│   │   ├── auth_service.dart   # Gerencia autenticação (Firebase Auth)
│   │   ├── firestore_service.dart # Interage com Firestore
│   │   └── chat_service.dart   # Chama API de IA (ex.: via Cloud Functions)
│   ├── widgets/                # Componentes reutilizáveis
│   │   └── content_card.dart   # Widget para cards de conteúdo
│   ├── main.dart               # Ponto de entrada do app (configura rotas)
│   └── constants.dart          # Constantes (ex.: cores, strings)
├── assets/                     # Arquivos estáticos (imagens, ícones)
│   └── logo.png                # Logo do EducaIA
├── pubspec.yaml                # Dependências e configurações do Flutter
├── google-services.json        # Configuração do Firebase (Android)
├── GoogleService-Info.plist    # Configuração do Firebase (iOS)
└── README.md                   # Documentação do projeto

## Como rodar
1. Instale o Flutter: `flutter doctor`
2. Configure o Firebase: Adicione `google-services.json` e `GoogleService-Info.plist`.
3. Rode: `flutter run`