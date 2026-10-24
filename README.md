# Kapok


<p align="center">
   <br />
  <img
    width="200"
    height="200"
    alt="kapok_icon"
    src="https://github.com/user-attachments/assets/e744cb33-858e-4d11-b096-c7836504bee8"
  />
   <br />
   <br />
</p>


**Kapok** is a mobile application for coordinating volunteer disaster response teams. Built with Flutter and Firebase, it enables organizations to efficiently manage tasks, teams, and field operations during crisis response, even in areas with limited connectivity.

Developed for the **A Fair Resolution, LLC**, led by **Dr. Leah Wing**, Professor of Legal Studies. The application will be handed off to the RN Response Network (RNRN), a national network of direct-care RNs powered by National Nurses United, that coordinates sending volunteers to disaster stricken areas where and when they are needed most.

---

## Features

- **Team Management**: create teams, share join codes, manage membership, transfer leadership
- **Task Coordination**: create, assign, and track location-based tasks with priorities (★–★★★) and categories
- **Interactive Maps**: Mapbox-powered maps with task pins, address search, and offline caching
- **Offline-First**: works without internet; queued changes sync automatically when connected
- **Multi-Language**: English and Spanish
- **Role-Based Access**: Team Member, Team Leader, and Admin roles
- **Privacy**: in-app account deletion; works without location permission

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter (Dart) |
| Backend | Firebase (Auth, Firestore, Storage, Crashlytics, Analytics) |
| Maps | Mapbox Maps SDK (mobile), Mapbox GL JS (web) |
| Local Storage | Hive |
| State Management | BLoC Pattern |

---

## Project Structure

```
Kapok/
├── app/          # Flutter application source code
├── firebase/     # Firestore/Storage rules and indexes
├── docs/         # Technical, handoff, store, and user documentation
├── .github/      # CI workflow (analyze + test)
└── CHANGELOG.md
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.35.4 (stable; Dart ^3.9.2)
- [Firebase CLI](https://firebase.google.com/docs/cli) (for rules deploys)
- Mapbox public access token (`pk.*`)
- Xcode 26+ for iOS, Android Studio / SDK for Android

### Setup

1. Clone the repository
   ```bash
   git clone https://github.com/ShreyanshMisra/Kapok.git
   cd Kapok/app
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Configure environment variables
   ```bash
   cp .env.example .env   # then set MAPBOX_ACCESS_TOKEN=pk....
   ```

4. Add the Firebase config files (gitignored; download from the `build-kapok` Firebase project). See [`app/README.md`](./app/README.md).

5. Run the application
   ```bash
   flutter run
   ```

### Running on Specific Platforms

```bash
flutter run -d ios         # iOS Simulator (iPhone only)
flutter run -d android     # Android Emulator
flutter run -d chrome      # Web (development/QA only)
```

---

## Documentation

Comprehensive documentation is available in the [`/docs`](./docs) folder:

| Doc | Contents |
|-----|----------|
| [01 Overview](./docs/01_overview.md) | Purpose, features, roles, platforms |
| [02 Tech Stack](./docs/02_tech_stack.md) | Dependencies and platform configuration |
| [03 Architecture](./docs/03_architecture.md) | Layers, BLoCs, routes, data flow |
| [04 Authentication](./docs/04_features_authentication.md) | Sign-in/up, password reset, account deletion |
| [05 Tasks](./docs/05_features_tasks.md) | Task model, pages, permissions |
| [06 Teams](./docs/06_features_teams.md) | Teams, join codes, leadership, close vs. delete |
| [07 Map](./docs/07_features_map.md) | Map page, offline regions, web/mobile controllers |
| [08 Profile & Settings](./docs/08_features_profile.md) | Profile, Settings, legal docs, About |
| [09 Data Models](./docs/09_data_models.md) | Models, enums, Firestore collections |
| [10 Services](./docs/10_services.md) | Services, data sources, repositories |
| [11 Project Structure](./docs/11_project_structure.md) | Directory layout and config files |
| [12 Development Notes](./docs/12_development_notes.md) | Setup, building, rules deploys, recent fixes |
| [13 Handoff](./docs/13_handoff_documentation.md) | Test accounts and store publishing steps |
| [14 User Manual](./docs/14_user_manual.md) | End-user guide |
| [15 Store Readiness](./docs/15_store_readiness_evaluation.md) | App Store / Play readiness review |
| [16 Client Submission Guide](./docs/16_client_store_submission_guide.md) | Business-owner actions for publishing |

---

## Development Team

Kapok was developed by [**BUILD UMass**](https://buildumass.com/), a student-led software development organization at the University of Massachusetts Amherst.

### Fall 2025

| Role | Name |
|------|------|
| Project Lead | Shreyansh Misra |
| Product Manager | Shriya Sanas |
| Software Developers | Sonny Zhang, Brian Nguyen, Kiran Balasundaram Kuppuraj, Dia Sutaria, Ngoc Duc Nghiem, Shivansh Soni, Jonathan Zhang |

### Spring 2025

| Role | Name |
|------|------|
| Project Leads | Shreyansh Misra, Adhiraj Chadha |
| Product Manager | Aastha Agrawal |
| Software Developers | Shobhit Mehrotra, Ahmed Khan, Chau Tran, Atonbara Diete-Koki, Abhignan Muppavaram |

### Fall 2024

| Role | Name |
|------|------|
| Project Leads | Shreyansh Misra, Adhiraj Chadha |
| Product Managers | Arushi Agrawal, Aastha Agrawal |
| Software Developers | Emmet Hamell, Ahmed Khan, Shobhit Mehrotra, Suryam Gupta, Abhignan Muppavaram, Atonbara Diete-Koki |

### Spring 2024

| Role | Name |
|------|------|
| Project Lead | Eric Wu |
| Product Managers | Shreyansh Misra, Khushi Rajoria |
| Software Developers | Emmet Hamell, Shobhit Mehrotra, Suryam Gupta, Adhiraj Chadha, Kevin Li |

---

## Acknowledgments

- **Dr. Leah Wing** — National Center for Technology and Dispute Resolution, UMass Amherst
- **A Fair Resolution, LLC** — Application handoff partner
- **National Nurses United** — End-user organization
- **BUILD UMass** — Student development team

---

## License

This project is proprietary software developed for A Fair Resolution, LLC. All rights reserved.

