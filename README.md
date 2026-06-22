# Reco

App iOS nativa (SwiftUI + SwiftData) que te ayuda a **no perder el contacto con las personas importantes de tu vida**.

## Idea

Cada persona tiene:
- **Importancia** (1-5)
- **Cadencia** (cada cuántos días contactar)
- **Flexibilidad** (margen ± antes de marcar como vencido)

La app calcula una **urgencia** para cada persona y te muestra la lista del día: a quién deberías escribir o llamar, priorizada.

## Stack

- **Swift 5.10 + SwiftUI** (iOS 17+)
- **SwiftData** para persistencia local (sin backend en MVP)
- **UserNotifications** para recordatorios diarios locales
- **Contacts** framework para importar contactos del iPhone
- **XcodeGen** para generar el `.xcodeproj`

## Estructura

```
Reco/
├── RecoApp.swift              # @main, ModelContainer setup
├── Info.plist                 # Permisos (Contacts, Camera, FaceID)
├── Models/Models.swift        # @Model Person, Interaction, ReminderConfig
├── Services/
│   ├── UrgencyCalculator.swift  # Algoritmo de prioridad
│   ├── NotificationService.swift # UNUserNotificationCenter wrapper
│   └── ContactsImporter.swift    # CNContactStore -> Person[]
├── Views/
│   ├── RootView.swift         # TabView (Hoy / Personas / Ajustes)
│   ├── Today/TodayView.swift  # Lista priorizada del día
│   ├── People/PeopleListView.swift
│   ├── People/NewPersonView.swift
│   ├── PersonDetail/PersonDetailView.swift
│   ├── PersonDetail/LogInteractionView.swift
│   ├── Settings/SettingsView.swift
│   └── DatabaseSeeder.swift   # Personas demo
├── Components/
└── Resources/Assets.xcassets/ # AppIcon, AccentColor (#F54F4F)
```

## Algoritmo de urgencia

```
daysSince = (now - lastInteraction.occurredAt) / 86400
raw = daysSince / cadenceDays
urgency = min(raw * importance, 3.0)
isOverdue = daysSince > (cadenceDays + flexibilityDays)
```

Hoy muestra: todas las vencidas + las que tengan urgencia >= 0.8, ordenadas por urgencia desc.

## Build

```bash
cd /Users/Mauri/Desktop/Apps/reco
xcodegen generate
xcodebuild -project Reco.xcodeproj \
  -scheme Reco \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -configuration Debug build
```

## Deploy (TestFlight)

1. Abrir `Reco.xcodeproj` en Xcode
2. Signing & Capabilities -> Team `47BY9SGLT7`
3. Archive -> Distribute App -> TestFlight
