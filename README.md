# EducaIA

Plataforma de aprendizado personalizada desenvolvida em Flutter, integrando Firebase para autenticação, banco de dados e funções de IA.

## Estrutura do Projeto

```
educaia/
├── android/                        # Configurações específicas para Android
├── ios/                            # Configurações específicas para iOS
├── web/                            # Configurações para web (se multiplataforma)
├── lib/                            # Código principal do Flutter
│   ├── models/                     # Modelos de dados (User, Content, History)
│   │   ├── user.dart               # Modelo de usuário
│   │   ├── content.dart            # Modelo de conteúdo
│   │   └── history.dart            # Modelo de histórico do usuário
│   ├── screens/                    # Telas do app
│   │   ├── cadastro_screen.dart    # Tela de cadastro de usuário
│   │   ├── login_screen.dart       # Tela de login
│   │   ├── home_screen.dart        # Tela principal (progresso e conteúdos)
│   │   ├── content_screen.dart     # Exibição de conteúdos (vídeo, exercício)
│   │   ├── study_screen.dart       # Área de estudo do conteúdo selecionado
│   │   └── chat_screen.dart        # Chat com tutor IA (Cloud Functions)
│   ├── services/                   # Serviços de backend e integrações
│   │   ├── auth_service.dart       # Autenticação (Firebase Auth)
│   │   ├── firestore_service.dart  # Interação com Firestore
│   │   ├── chat_service.dart       # Comunicação com IA (Cloud Functions)
│   │   └── content_api_service.dart# Busca de conteúdos externos
│   ├── widgets/                    # Componentes reutilizáveis
│   │   └── content_card.dart       # Card de conteúdo
│   ├── main.dart                   # Ponto de entrada do app e rotas
│   └── constants.dart              # Constantes globais (cores, strings)
├── assets/                         # Arquivos estáticos (imagens, ícones)
│   └── logo.png                    # Logo do EducaIA
├── pubspec.yaml                    # Dependências e configurações do Flutter
├── google-services.json            # Configuração do Firebase (Android)
├── GoogleService-Info.plist        # Configuração do Firebase (iOS)
└── README.md                       # Documentação do projeto
```

## Funcionalidades

- **Cadastro e Login:** Usuário pode criar conta, selecionar interesses e acessar o app.
- **Progresso:** Visualização do histórico de estudos e status dos conteúdos.
- **Conteúdos Personalizados:** Listagem de conteúdos por assunto/interesse, integração com vídeos do YouTube e exercícios.
- **Chat IA:** Tutor inteligente via Cloud Functions para dúvidas e orientação.
- **Integração Firebase:** Autenticação, Firestore para dados e Cloud Functions para IA.

## Como rodar

1. Instale o Flutter e configure seu ambiente:
   ```sh
   flutter doctor
   ```
2. Configure o Firebase:
   - Adicione `google-services.json` (Android) em `android/app/`.
   - Adicione `GoogleService-Info.plist` (iOS) em `ios/Runner/`.
3. Instale as dependências:
   ```sh
   flutter pub get
   ```
4. Rode o app:
   ```sh
   flutter run
   ```

## Observações

- Para o chat IA funcionar, é necessário configurar as Cloud Functions do Firebase.
- O projeto utiliza Provider para gerenciamento de estado e integração com serviços.
- Os conteúdos podem ser expandidos conforme necessidade, incluindo novos assuntos e tipos.

---
Desenvolvido para fins acadêmicos.