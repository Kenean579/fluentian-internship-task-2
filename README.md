# 🍽️ Smart Restaurant Ordering System

A full-stack digital restaurant ordering platform built for the Fluentian Internship Task 2.
Customers scan a QR code at their table, browse an Ethiopian menu, place orders, and track them in real time.
Staff manage the full order lifecycle from a live dashboard.

---

## 📐 System Architecture

```
┌──────────────────────────────────────────────────────────┐
│                   Flutter Frontend (Mobile)               │
│  QR Scanner → Menu → Cart → Order Tracking → History    │
└────────────────────────┬─────────────────────────────────┘
                         │  HTTP (REST API)
                         ▼
┌──────────────────────────────────────────────────────────┐
│               Laravel 11 Backend (API)                    │
│                                                           │
│  SessionController   → table session lifecycle            │
│  MenuController      → menu items + categories            │
│  CartController      → session-scoped cart management     │
│  OrderController     → order placement + retrieval        │
│  StaffController     → status updates + Pusher broadcast  │
│  RecommendationCtrl  → AI recommendation engine           │
│  UserBehaviorCtrl    → user behavior profile tracking     │
└────────────┬──────────────────────────┬───────────────────┘
             │  MySQL (Eloquent ORM)    │  Pusher Channels
             ▼                          ▼
      ┌─────────────┐          ┌──────────────────┐
      │   Database  │          │  Pusher Service  │
      │  (MySQL)    │          │ (WebSocket Relay)│
      └─────────────┘          └──────────────────┘
                                        │
                               Pushed to Flutter via
                               pusher_channels_flutter
```

---

## 🗄️ Database Schema

| Table             | Purpose                                           |
|-------------------|---------------------------------------------------|
| `table_sessions`  | Links a device UUID to a table (QR scan result)  |
| `categories`      | Ethiopian food categories                         |
| `menu_items`      | Menu with price, prep time, availability          |
| `carts`           | One cart per session                              |
| `cart_items`      | Items in cart with snapshotted price              |
| `orders`          | Placed orders with status & unique order number   |
| `order_items`     | Items per order (snapshotted price)               |

---

## 📱 Feature Coverage

### 1. QR-Based Table Session

Each table has a unique QR code encoding the table ID (e.g., `Table-5`).

**Flow:**
1. Customer scans QR → `POST /api/sessions/start` with `{ table_id, user_device_id }`
2. Backend finds or creates a session for that `(table_id, user_device_id)` pair
3. Session ID is stored in `SharedPreferences` on the device
4. On next app launch, `restoreSession()` is called → validates the stored session via the backend
5. If valid → skip QR screen, go straight to menu
6. If invalid → show QR scanner

**Session Persistence Logic:**
- `user_device_id` is a UUID generated once and stored permanently on the device
- Even if the user clears the app or switches devices, presenting the same QR regenerates the session
- Sessions are scoped by `(table_id, device_id)` so two devices at the same table are independent

---

### 2. Digital Menu System

- Items grouped by Ethiopian food categories
- Each item shows: name, price (ETB), estimated prep time, availability status
- Category filtering via tab bar
- Items marked as unavailable are shown but cannot be added to cart

---

### 3. Ordering System

- Items added to a session-scoped cart via `POST /api/sessions/{id}/cart`
- Prices are **snapshotted** at add time — price changes don't affect in-progress orders
- `POST /api/sessions/{id}/orders` converts cart to order and clears the cart
- Returns a unique `order_number` that persists for the session lifetime
- Order history is retrievable anytime via `GET /api/sessions/{id}/orders`

---

### 4. Restaurant Staff Panel

Separate Staff Panel screen accessible from the menu (no auth — separate UI as permitted).

- `GET /api/staff/orders/pending` — live view of all active orders
- `GET /api/staff/orders/all` — full order history
- `PATCH /api/staff/orders/{id}/status` — update status with values:
  - `received` → `cooking` → `ready` → `delivered`
- On every status change, a **Pusher broadcast** is fired on channel `order.{orderId}`

---

### 5. Order Tracking (User Side)

- After placing an order, user is taken to `OrderTrackingScreen`
- Subscribes to Pusher channel `order.{orderId}` event `OrderStatusUpdated`
- Status updates appear in real time without polling
- Animated progress stepper shows: Received → Cooking → Ready → Delivered
- Estimated waiting time is shown based on the menu item prep times
- `OrderHistoryScreen` shows all orders for the current session

---

### 6. User Behavior Tracking

**Endpoint:** `GET /api/sessions/{sessionId}/behavior`

Tracks behavior across **all sessions for a device** (cross-session profile):

| Field | Description |
|---|---|
| `most_ordered` | Top 5 items ranked by total quantity ordered by this device |
| `recently_ordered` | Last 5 distinct items in the current session |
| `preference_profile` | Category-level spend breakdown with % preference weight |
| `total_orders` | Total orders placed across all sessions |
| `total_sessions` | Number of distinct table sessions for this device |

This data feeds into the AI recommendation engine and is available for staff analytics.

---

### 7. AI Feature — Personalized Recommendation Engine

**Endpoint:** `GET /api/sessions/{sessionId}/recommendations`

A **three-tier collaborative filtering algorithm** runs on each call:

```
Tier 1: Personalized (session history)
  → Count frequency of items ordered in this session
  → Return top 3 not already in cart
  → Label: "Personalized recommendations"

Tier 2: Popularity Fallback (global)
  → If no session history, rank items by total orders across all sessions
  → Return top 3 not already in cart
  → Label: "Popular recommendations"

Tier 3: Featured (cold start)
  → If no order data exists at all, return 3 random available items
  → Label: "Featured items"
```

**Why it's not decorative:**
- Shown as a horizontal carousel on the menu screen

---

### 8. AI Feature — Dynamic Wait-Time Prediction (Requirement 7)

**Endpoint:** `GET /api/kitchen/load`

The system monitors kitchen congestion in real-time to prevent unrealistic customer expectations.

**Logic:**
- Counts active orders (status: `received` or `cooking`).
- **Load Balancing:**
  - 0-4 orders: **Normal** (+0 mins)
  - 5-9 orders: **Medium** (+5 mins)
  - 10+ orders: **High** (+15 mins)
- The Menu Screen displays a **"High Demand"** alert banner if the kitchen is busy.
- Individual menu item prep times are **dynamically adjusted** in the UI to show the "Predicted" time.

**Why it's meaningful:**
- It is a predictive model based on real-time system load.
- It directly impacts user behavior (customers might choose faster items if the kitchen is busy).
- Uses logic typically found in professional food delivery apps (UberEats/DoorDash).

---

## 🛠️ Tech Stack

| Layer       | Technology                                   |
|-------------|----------------------------------------------|
| Backend     | Laravel 11 + MySQL                           |
| Frontend    | Flutter (Android/iOS mobile)                 |
| Real-time   | Pusher Channels (WebSocket)                  |
| State Mgmt  | Provider (Flutter)                           |
| Persistence | SharedPreferences (device session storage)   |
| HTTP        | `http` package (Flutter)                     |
| QR Scanning | `mobile_scanner` package                     |

---

## ⚙️ Setup Instructions

### Backend (Laravel)

```bash
cd backend
cp .env.example .env
composer install
php artisan key:generate
# Configure MySQL credentials in .env
# Configure Pusher credentials in .env (BROADCAST_DRIVER=pusher)
php artisan migrate --seed
php artisan serve --host=0.0.0.0 --port=8000
```

### Frontend (Flutter)

```bash
cd frontend
flutter pub get
# In lib/services/api_service.dart:
flutter run
```

### 🚀 Production Deployment (Render)

The backend is configured for deployment on **Render.com**.

1. **Root Directory:** `backend`
2. **Build Command:** `./render-build.sh`
3. **Start Command:** `vendor/bin/heroku-php-apache2 public/`
4. **Environment Variables Required:**
   - `APP_KEY`, `APP_DEBUG=false`, `DB_CONNECTION=pgsql`, `DATABASE_URL`, `BROADCAST_DRIVER=pusher`

### 📱 Production APK Build

To generate the final Android app for submission:

```bash
cd frontend
flutter build apk --release
```
The file will be located at: `build/app/outputs/flutter-apk/app-release.apk`


---

## 🔌 Key API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/sessions/start` | Start or resume a table session |
| GET | `/api/menu` | Get full menu with categories |
| GET | `/api/sessions/{id}/cart` | View cart |
| POST | `/api/sessions/{id}/cart` | Add item to cart |
| DELETE | `/api/sessions/{id}/cart/items/{itemId}` | Remove cart item |
| POST | `/api/sessions/{id}/orders` | Place order |
| GET | `/api/sessions/{id}/orders` | Get session order history |
| GET | `/api/orders/{orderId}` | Get single order details |
| PATCH | `/api/staff/orders/{id}/status` | Update order status (staff) |
| GET | `/api/sessions/{id}/recommendations` | AI recommendations |
| GET | `/api/sessions/{id}/behavior` | User behavior profile |

---

## 🎯 Design Decisions

| Decision | Rationale |
|----------|-----------|
| **Price snapshotting** | Cart items store the price at time of addition — menu price changes don't retroactively affect in-progress orders |
| **Device UUID persistence** | Using `uuid` package to generate a permanent device ID stored in SharedPreferences — enables cross-session behavior tracking without auth |
| **Session scoping** | All carts, orders, and recommendations are scoped to a `session_id` preventing cross-table data leakage |
| **Provider pattern** | Flutter's Provider used for global state (session, cart, menu, recommendations) — lightweight, no complex boilerplate |
| **Pusher over polling** | WebSocket connection via Pusher gives instant status updates without battery-draining HTTP polling |
| **ETB currency** | All prices in Ethiopian Birr — appropriate for an Ethiopian restaurant context |
| **mobile_scanner** | Replaced deprecated `qr_code_scanner` — supports Android API 21+, no namespace issues |

---

## 🗳️ Ethiopian Menu (Seeded Data)

| Item | Category | Price (ETB) | Prep Time |
|------|----------|-------------|-----------|
| Doro Wat | Traditional Mains | 450 | 20 min |
| Firfir | Traditional Mains | 180 | 10 min |
| Awaze Tibs | Meat Dishes | 350 | 18 min |
| Kitfo | Meat Dishes | 400 | 12 min |
| Shiro Wat | Vegetarian | 150 | 15 min |
| Beyaynetu | Vegetarian | 200 | 25 min |
| Ethiopian Coffee (Buna) | Beverages | 30 | 10 min |
| Tej | Beverages | 100 | 5 min |

---

## 🔮 Bonus Features Implemented

- ✅ Real-time updates via Pusher WebSockets
- ✅ Session persistence across app restarts
- ✅ Cross-session user behavior profile
- ✅ AI recommendation carousel on menu screen
- ✅ AI dynamic wait-time prediction based on kitchen load
- ✅ Estimated waiting time on order tracking screen
- ✅ Order history for current session
- ✅ Automated Render deployment scripts
- ✅ Detailed Item Modal with quantity selector
- ✅ Payment Simulation (Telebirr, CBE Birr, Cash)
- ✅ Cart quantity editing & live updates
