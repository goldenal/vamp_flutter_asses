# Reserved Cart App

A high-performance Flutter application demonstrating a **Reserved Cart / Limited Stock** system with precise server-side time synchronization.

## 🏗 Architecture

The project follows a **Feature-First + Clean Architecture** approach:

```
lib/
 ├── core/              # Global shared logic (Time, Network, Ticker)
 ├── features/
 │    ├── products/     # Product Listing Feature
 │    ├── cart/         # Cart & Reservation Feature
 ├── main.dart          # Entry point & App Lifecycle
```

- **Core**: Contains the `ServerTimeService` (Time Authority) and `GlobalTicker`.
- **Features**: Each feature (Cart, Products) is self-contained with its own Data, Domain, and Presentation layers.
- **State Management**: Uses **Provider** for dependency injection and state management.
- **Storage**: Uses **SharedPreferences** for offline data persistence.

## 🔐 Time Synchronization

**Problem**: Relying on `DateTime.now()` on the device is unsafe because users can manipulate their device clock, allowing them to bypass reservation expiry.

**Solution**:

1.  **Source of Truth**: The Backend (`vamp-asses.onrender.com`) is the only time authority.
2.  **Offset Calculation**:
    - When the app fetches the cart, it receives `serverTime`.
    - `offset = serverTime - deviceNow`.
3.  **Usage**:
    - `ServerTimeService.now()` returns `DateTime.now() + offset`.
    - This ensures all countdowns are synchronized with the server, even if the user changes their clock or is offline temporarily.

## 💾 Offline Caching & Resilience

**Strategy**: The app implements a "Stale-While-Revalidate" fallback strategy to support usage in poor network conditions.

1.  **Local Storage Service**: A wrapper around `SharedPreferences` persists serialized `Product` and `CartItem` data.
2.  **Fallback Logic**:
    - **Happy Path**: App fetches fresh data from API -> Updates UI -> Saves to Cache.
    - **Offline/Error Path**: App fails to fetch -> Loads from Cache -> Displays cached content (with potentially stale data).
3.  **Loading States**:
    - Granular loading indicators (spinners) on "Reserve" buttons prevent double-booking and provide immediate visual feedback during async operations.

## ⏱ Countdown Strategy

**Why single ticker?**
Creating a `Timer` for every cart item is inefficient. If a user has 100 items, 100 timers would consume unnecessary resources and cause UI jank.

**Implementation**:

1.  **Global Ticker**: A single `Stream<DateTime>` emits a tick every second (provided via `StreamProvider`).
2.  **Reactive UI**: `CartItemTile` listens to `context.watch<DateTime>()`.
3.  **Calculation**: `remaining = reservedUntil - ServerTime.now()`.
4.  **Efficiency**:
    - Only **ONE** timer runs in the entire app.
    - `ListView.builder` ensures only visible items calculate their time.
    - Scalable to hundreds of items without performance degradation.

## 🚀 Scalability & Performance

- **Memory**: No per-item controllers or timers.
- **Network**:
  - App resumes (background -> foreground) trigger a `refresh()` to re-sync server time and reservations.
  - Optimistic updates are used for immediate feedback.
- **Offline Support**: Full read-only access to last known state.

## 🔄 App Lifecycle

- **Cold Start**: Fetches products and cart, calculates time offset.
- **Background**: Countdown logic relies on absolute timestamps (`reservedUntil`), so it works perfectly even if the app was suspended.
- **Resume**: Triggers `CartNotifier.refresh()` to ensure validity.

## 🛠 Backend Assumptions

- `GET /cart` response includes `serverTime` (mandatory for sync).
- `POST /cart/reserve` returns the reserved item with `reservedUntil`.
- Backend handles actual inventory decrement/release.

## 📝 Future Improvements for Production

1.  **WebSockets / SSE**: For real-time updates (e.g., "Item out of stock" push notification).
2.  **Detailed Error Handling**: More robust retry policies for network failures.
3.  **Testing**: Add unit tests for `ServerTimeService` and Widget tests for `CartScreen`.
