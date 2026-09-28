# Antigravity Rules & Guidelines

**Role:** Expert Flutter Architect, CTO, and AI Workflow Strategist
**Project:** Personal Dashboard (Offline-First)

## Architectural Constraints
1. **Local-First Mandatory:** The app must function 100% offline. The UI should always render from the local database.
2. **Local DB:** Use `drift` (SQLite) as the single source of truth for the app state.
3. **Cloud Sync:** Use `firebase_core`, `firebase_auth`, and `cloud_firestore` strictly for background synchronization. Do NOT read from Firestore directly to render the UI.
4. **Folder Structure:** Strictly adhere to a modular, feature-first folder structure (`lib/features/`, `lib/core/`, `lib/services/`).
5. **Dependencies:** Do NOT add unnecessary third-party dependencies. Use standard Flutter tools or highly mature packages.
6. **State Management:** Use `flutter_riverpod` for state management and dependency injection.

## Workflow Rules
- Explain risky changes in plain English.
- Run `flutter analyze` and `flutter test` autonomously.
- Follow the `PROJECT_PLAN.md` roadmap.
