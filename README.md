# Reserved Cart App

A high-performance Flutter application demonstrating a **Reserved Cart / Limited Stock** system with precise server-side time synchronization.

## 🏗 High-Level Architectural Design

The project follows a **Feature-First + Clean Architecture** approach, designed to handle the unique constraints of the mobile environment such as intermittent connectivity and variable device performance.

### 1. Data Flow & State Synchronization

- **Unidirectional Data Flow**: State flows down from Providers to Widgets, and events flow up.
- **Single Source of Truth**: The `CartNotifier` and `ProductsNotifier` serve as the single source of truth for the UI.
- **Mobile Constraints**:
  - **Network**: We use a `NetworkMonitor` with active polling to detect connection changes.
  - **Offline-First**: We use a "Stale-While-Revalidate" strategy with `SharedPreferences`. The app displays cached data immediately while fetching fresh data in the background. Operations like "Reserve" are blocked when offline to prevent state inconsistency.

### 2. Layered Structure

```
lib/
 ├── core/              # Global shared logic (Time, Network, Ticker)
 ├── features/
 │    ├── products/     # Product Listing (Data, Domain, Presentation)
 │    ├── cart/         # Cart & Reservation (Data, Domain, Presentation)
 ├── main.dart          # Entry point & Dependency Injection
```

## 🔐 Time Synchronization Strategy

**Problem**: Relying on `DateTime.now()` on the device is unsafe. Users can manipulate their device clock to bypass reservation expiry, and device clocks may drift.

**Solution**:

1.  **Server Authority**: The Backend is the absolute time authority.
2.  **Offset Calculation**:
    - On every cart fetch, the server returns its current time.
    - We calculate `offset = serverTime - deviceTime`.
3.  **Client Adjustment**:
    - `ServerTimeService.now()` returns `DateTime.now() + offset`.
    - All countdown checks use this synchronized time ( `reservedUntil.isAfter(ServerTimeService.now())`).

## 🚀 Scalability: Handling 100+ Timers

**Challenge**: If the cart has 100 items, creating 100 individual `Timer` objects (one for each widget) would be disastrous for performance (CPU usage, battery drain, and UI jank).

**Our Approach**:

1.  **Single Global Ticker**: We use **one** `Stream<DateTime>` that emits a value every second.
2.  **Broadcast Stream**: This single stream is provided via `StreamProvider` to the entire app.
3.  **Passive Listeners**:
    - Each `CartItemTile` listens to the global tick.
    - It calculates `remaining = reservedUntil - tick` on the fly.
4.  **Efficiency**:
    - **O(1) Timer Overhead**: Regardless of whether there are 10 items or 1000 items, there is only **one** active timer in the background.
    - **View-Only Calculation**: Only the widgets currently visible on screen (rendered by `ListView.builder`) perform the subtraction calculation.

## 💾 Offline Caching & Resilience

- **Persisted State**: Cart and Products are serialized and saved to local storage.
- **Network Recovery**: When `NetworkMonitor` detects a reconnection, the app automatically triggers a `refresh()` to sync with the server.

## 🛠 Tech Stack

- **Flutter**: UI Framework.
- **Provider**: State Management & Dependency Injection.
- **SharedPreferences**: Local Storage.
- **Http**: API Networking.
