# Industrial IoT — Flutter Front-End

A front-end (design-only) Flutter app for an **Industrial IoT solution**: machine
monitoring, OEE, production data, dashboards and reports. Built in the same
glassmorphism design language as the PHH ERP / HRM app, and structured so a real
backend (REST / MQTT / WebSocket) can be wired in without touching the UI.

> Status: **UI + mock data only.** No live device connection yet — everything
> reads from `MockDataService`, which is the single swap-point for a backend.

## Roles

The app ships with two roles, toggled from **Settings** (or chosen at login):

- **Operator** — shop-floor view: current shift, my machines, log output/downtime, alerts, my-shift analytics.
- **Plant Manager** — plant-wide view: OEE dashboard, machines, production & OEE analytics, reports, alarms, maintenance.

## Project structure

```
lib/
├── main.dart                 # App entry, providers, routes, theme wiring
├── theme/
│   ├── app_theme.dart        # AppColors tokens + light/dark ThemeData
│   └── theme_provider.dart   # Dark/light toggle (ChangeNotifier)
├── services/
│   ├── role_provider.dart    # Operator / Manager role state
│   └── mock_data_service.dart# ⭐ ALL demo data — replace with a repository
├── models/                   # Pure-Dart models, each with a fromJson factory
│   ├── machine.dart          #    (Machine, ProductionOrder, Alarm,
│   ├── production_order.dart  #     MaintenanceTask, ShiftReport, ProductionLine)
│   ├── alarm.dart
│   ├── maintenance_task.dart
│   ├── shift_report.dart
│   └── production_line.dart
├── widgets/                  # Reusable UI: GlassCard, MeshGradientBg, OeeGauge,
│                             #   KpiTile, StatusBadge, MachineStatusCard, nav…
└── screens/
    ├── splash / login / shell / profile(settings)
    ├── manager/  (dashboard, production, reports)
    ├── operator/ (home, log_production, my-shift analytics)
    └── shared/   (machines, machine_detail, alarms, maintenance)
```

## Connecting a backend later

The UI never constructs data itself — it only calls `MockDataService`. To go live:

1. Create a repository (e.g. `MachineRepository`) that fetches from your API/broker
   and returns the **same model types** (`Machine`, `Alarm`, …). Each model already
   has a `fromJson` factory.
2. Swap the static getters in `MockDataService` for repository calls, or inject the
   repository via `provider` and have screens read from it (turn the static getters
   into `Future`/`Stream` and wrap widgets in `FutureBuilder`/`StreamBuilder`).
3. For live telemetry, expose a `Stream<Machine>` (MQTT/WebSocket) — the gauges,
   status badges and sparklines are already driven off model fields.

No colours, layouts or charts need to change.

## Run

```bash
flutter pub get
flutter run
```

## Dependencies

`provider` · `google_fonts` (Poppins) · `fl_chart` · `flutter_staggered_animations`
· `shimmer` · `intl` · `shared_preferences`.
