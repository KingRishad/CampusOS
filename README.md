# CampusOS — Intelligent Campus Platform & AI Agent

An intelligent university platform built with **Flutter**, powered by an autonomous AI agent that reads and acts on real-time campus data.

Designed with a sleek notch-level UI/UX matching modern mobile apps (Dark Emerald Green palette `#006837`, rounded card containers, filter pills, custom bottom navigation, and top notification header).

---

## 🌟 Key Features

### Part 1 — The Campus Data Manager (5 Core Systems)
Full CRUD (Create, Read, Update, Delete) capability with instant UI updates and persistent state backings for:
1. **Schedule**: Class courses, times, rooms, days, instructors
2. **Rooms**: Room numbers, seating capacity, equipment (Projector, AC, Smart Board), booking state, student details
3. **Events**: Campus workshops, competitions, capacity counters, registration tracking
4. **Announcements**: Campus notices, reschedules, priority badges (High/Medium/Low)
5. **Assignments**: Course tasks, deadlines, status toggling (Pending/Submitted/Completed)

> ⚡ **Real-Time Data Persistence**: Changes made in the Data Manager immediately write to local storage and update the database truth read by the AI Agent!

---

### Part 2 — The AI Agent (Real Tool Calling & Autonomous Execution)
The AI Agent operates directly on the live database using real function calling / tool calls:
- **`get_schedules`**: Fetches current class schedules and checks for notices/room moves.
- **`get_assignments`**: Checks upcoming assignment deadlines.
- **`get_rooms`**: Filters available rooms by capacity, equipment (e.g. Projector), and times.
- **`book_room`**: Books room slots and updates database state.
- **`register_event`**: Registers students for workshops/competitions.
- **Vagueness Handling**: Detects ambiguous queries (e.g., *"Just book me any room tomorrow afternoon"*) and asks clarifying questions before calling any mutation tool.

---

### Authentication & Guest Login
- **Student Login** (e.g. Shahzaib Ahmad)
- **Admin Login** (Administrator permissions & room/announcement management)
- **Guest Login** (One-click instant access for guests)

---

## 📱 Visual & UI Design Highlights
- **Palette**: Dark Emerald Green (`#006837`), Mint Accent (`#E6F4EA`), Pure White Cards (`#FFFFFF`).
- **Typography**: Clean Google Inter Font.
- **Components**: Floating Search Bar, Horizontal Category Chips, Hero Banner with AI CTA, Activity Audit Logs.

---

## 🚀 How to Run in Android Studio

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.13+)
- Android Studio with Flutter plugin or VS Code

### Steps
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/campusOS.git
   cd campusOS
   ```

2. **Fetch Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run Unit & Integration Tests**:
   ```bash
   flutter test
   ```

4. **Launch Application**:
   Open Android Studio, select your target device (Android Emulator, iOS Simulator, or Chrome), and click **Run** `main.dart`, or run via terminal:
   ```bash
   flutter run
   ```

---

## 🧪 Sample AI Queries to Test During Judging

| Query | What CampusOS AI Does |
| :--- | :--- |
| *"When is my next class?"* | Checks schedule + notices (returns CSE321 relocated to Room 304 at 2:00 PM). |
| *"What have I got due this week?"* | Retrieves pending assignment deadlines. |
| *"I am free until 2 - is there anything on campus I could drop into?"* | Cross-references today's events before 2 PM. |
| *"Book Room 302 tomorrow, 3 to 5 PM."* | Checks availability, executes `book_room` tool, and updates Data Manager. |
| *"I need a room for 5 people with a projector."* | Filters rooms by capacity >= 5 and equipment containing "Projector". |
| *"Just book me any room tomorrow afternoon."* | Detects vague request and prompts user for time, size, and equipment details before acting. |

---

## 🏗️ Project Architecture

```
lib/
├── main.dart
├── models/             # Schedule, Room, Event, Announcement, Assignment, ActivityLog
├── services/           # StorageService, SeedDataLoader, AIAgentEngine
├── providers/          # CampusProvider, AuthProvider, ChatProvider
├── theme/              # AppColors, AppTheme
└── views/
    ├── auth/           # LoginScreen with Guest/Student/Admin login
    ├── home/           # DashboardScreen matching screenshot
    ├── data_manager/   # DataManagerScreen (5-system CRUD hub)
    ├── ai_agent/       # ChatScreen with tool call badges
    ├── activity/       # ActivityLogScreen for real-time changes
    └── profile/        # ProfileScreen & Role Switcher
```
