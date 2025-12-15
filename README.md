# Kapok

<img width="4096" height="4096" alt="kapok_icon" src="https://github.com/user-attachments/assets/e744cb33-858e-4d11-b096-c7836504bee8" />

**Kapok** is a mobile application for coordinating volunteer disaster relief teams. Built with Flutter and Firebase, it enables organizations to efficiently manage tasks, teams, and field operations during crisis response, even in areas with limited connectivity.

Developed for the **National Center for Technology and Dispute Resolution (NCTDR)** at UMass Amherst, led by **Dr. Leah Wing**, Professor of Legal Studies. The application will be handed off to **A Fair Resolution, LLC** for deployment to **National Nurses United**.

---

## Features

- **Team Management** — Create teams, generate join codes, and manage membership
- **Task Coordination** — Create, assign, and track location-based tasks with priority levels
- **Interactive Maps** — Mapbox-powered maps with task visualization and offline caching
- **Offline-First** — Full functionality without internet; automatic sync when connected
- **Multi-Language** — English and Spanish support
- **Role-Based Access** — Team Member, Team Leader, and Admin roles

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter (Dart) |
| Backend | Firebase (Auth, Firestore, Storage, Crashlytics) |
| Maps | Mapbox GL |
| Local Storage | Hive |
| State Management | BLoC Pattern |

---

## Project Structure

```
Kapok/
├── app/          # Flutter application source code
├── firebase/     # Firebase configuration and Firestore rules
└── docs/         # Technical and user documentation
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.9.2+)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- Mapbox access token

### Setup

1. Clone the repository
   ```bash
   git clone https://github.com/your-org/kapok.git
   cd kapok/app
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Configure environment variables
   ```bash
   # Create .env file in app/ directory
   echo "MAPBOX_ACCESS_TOKEN=your_token_here" > .env
   ```

4. Run the application
   ```bash
   flutter run
   ```

### Running on Specific Platforms

```bash
flutter run -d chrome      # Web
flutter run -d ios         # iOS Simulator
flutter run -d android     # Android Emulator
```

---

## Documentation

Comprehensive documentation is available in the [`/docs`](./docs) folder:

- [Overview](./docs/01_overview.md) — Application purpose and features
- [Tech Stack](./docs/02_tech_stack.md) — Dependencies and configuration
- [Architecture](./docs/03_architecture.md) — Code structure and patterns
- [User Manual](./docs/14_user_manual.md) — End-user guide
- [Handoff Documentation](./docs/13_handoff_documentation.md) — App store publishing guide

---

## Development Team

Kapok was developed by [**BUILD UMass**](https://buildumass.com/), a student-led software development organization at the University of Massachusetts Amherst.

### Fall 2025

| Role | Name |
|------|------|
| Project Lead | Shreyansh Misra |
| Product Manager | Shriya Sanas |
| Software Developers | Sonny Zhang, Brian Nguyen, Ngoc Duc Nghiem, Dia Sutaria, Jonathan Zhang, Shivansh Soni, Kiran Balasundaram Kuppuraj |

### Spring 2025

| Role | Name |
|------|------|
| Project Leads | Shreyansh Misra, Adhiraj Chadha |
| Product Manager | Aastha Agrawal |
| Software Developers | Atonbara Diete-Koki, Shobhit Mehrotra, Chau Tran, Ahmed Khan, Abhignan Muppavaram |

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
| Software Developers | Emmet Hamell, Kevin Li, Shobhit Mehrotra, Suryam Gupta, Adhiraj Chadha |

---

## Acknowledgments

- **Dr. Leah Wing** — National Center for Technology and Dispute Resolution, UMass Amherst
- **A Fair Resolution, LLC** — Application handoff partner
- **National Nurses United** — End-user organization
- **BUILD UMass** — Student development team

---

## License

This project is proprietary software developed for A Fair Resolution, LLC. All rights reserved.

