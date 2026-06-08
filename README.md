# RemoteRecruit iOS Application

iOS job browsing app built with SwiftUI, MVVM, and async/await.

---

## Architecture

### MVVM + Protocol-Oriented Dependency Injection

```
View  →  ViewModel  →  ServiceProtocol  →  Concrete Service
                             ↑
                         MockService (tests)
```

**Why MVVM?**
- Views are pure layout/render code with zero business logic
- ViewModels own all state transitions and can be tested synchronously without a running UI
- `@MainActor` on ViewModels guarantees thread-safe `@Published` updates

**Why protocol injection?**
- `JobRepositoryProtocol` is the seam between business logic and data layer
- In tests, `MockJobService` is dropped in without any framework (no OHHTTPStubs, etc.)
- Swapping `LocalJobService` → `NetworkJobService` changes zero lines in ViewModels or Views

---

## State Machine

Every screen uses `ViewState<T>`:

```
.idle → .loading → .loaded(T)
                 ↘ .empty
                 ↘ .error(AppError)
```

This is a **sum type**: it is impossible to be both `.loading` and `.error` simultaneously. This eliminates the class of bugs from boolean flag combinations (`isLoading && hasError`).

---

## Project Structure

```
JobBoard/
├── App/
│   └── RemoteRecruitApp.swift     # @main entry point
├── Models/
│   ├── Job.swift                  # Core domain model
│   ├── AppError.swift             # Typed error enum
│   └── ViewState.swift            # Generic UI state machine
├── Services/
│   └── JobServiceProtocol.swift   # DI boundary + search helper
├── ViewModels/
│   ├── JobsListViewModel.swift    # List + search logic
│   └── JobDetailViewModel.swift   # Single job fetch logic
├── Views/
│   ├── Components/
│   │   └── SharedComponents.swift # LoadingView, EmptyStateView, TagView…
│   ├── JobList/
│   │   ├── JobListView.swift      # Root screen
│   │   └── JobCardView.swift      # List row
│   └── JobDetail/
│       └── JobDetailView.swift    # Detail screen
├── Resources/
│   └── jobs.json                  # 12-job mock dataset
└── Tests/
    ├── Mocks/
    │   └── MockJobService.swift   # Configurable test double
    ├── ViewModelTests/
    │   ├── JobListViewModelTests.swift
    │   └── JobDetailViewModelTests.swift
    └── ServiceTests/
        └── ServiceAndModelTests.swift
```

---

## Data Source

**Local JSON (`jobs.json`)** — 12 realistic job listings spanning FinTech, EdTech, Music, Health and more.

Rationale: a local file gives deterministic, network-free testing and avoids API key management. The `LocalJobService` introduces a 600ms artificial delay so loading states are visible during development.

**To swap in a real API:**
1. Create `NetworkJobService: JobServiceProtocol`
2. Implement `fetchJobs()` / `fetchJob(id:)` using `URLSession`
3. Pass it to `JobListView(service: NetworkJobService())` in `JobBoardApp.swift`
4. Zero lines change in ViewModels, Views, or tests

---

## Search

Search is implemented **client-side** after an initial full fetch:
- `JobListViewModel` stores `allJobs` and derives `displayedJobs` from a filter
- Combine `debounce(300ms)` prevents filtering on every keystroke
- Case-insensitive, matches `title` OR `company.name`
- Empty/whitespace query returns all jobs

---

## Testing

### Coverage targets (business logic)

| Layer | Tests | Coverage |
|---|---|---|
| `AppError` | 5 | ~100% |
| `ViewState<T>` | 6 | ~100% |
| `Job` model | 4 | ~100% |
| `JobListViewModel` | 12 | ~95% |
| `JobDetailViewModel` | 8 | ~95% |
| `MockJobService` | 7 | ~100% |

Total: **42 tests** — well above the 70% business logic threshold.

### Running tests

```bash
# CLI (requires Xcode command line tools)
xcodebuild test \
  -scheme JobBoard \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# Or with Swift Package Manager
swift test
```

---

## Key Design Decisions

| Decision | Rationale |
|---|---|
| `@MainActor` on ViewModels | Thread-safe @Published without manual `DispatchQueue.main.async` |
| `ViewState<T>` enum over booleans | Impossible states are unrepresentable |
| Protocol-based service | Testable without mocking frameworks |
| `async/await` over Combine | Cleaner sequential read, easier error propagation with `try` |
| Combine only for debounce | Using Combine only where it adds genuine value (reactive search) |
| `final class` ViewModels | Prevents accidental subclassing; `@StateObject` expects reference type |
| Job id passed to DetailVM | Supports deep links, push notifications, future paginated APIs |


---

## Screenshots

<img width="724" height="1573" alt="Simulator Screenshot - iPhone 17 Pro - 2026-06-08 at 15 42 29" src="https://github.com/user-attachments/assets/42fda0b1-7a86-4b78-85cf-da7880c2a17a" />   <img width="724" height="1573" alt="Simulator Screenshot - iPhone 17 Pro - 2026-06-08 at 15 42 39" src="https://github.com/user-attachments/assets/3e07359e-c645-4454-a887-d245a0c495cd" />

<img width="724" height="1573" alt="Simulator Screenshot - iPhone 17 Pro - 2026-06-08 at 14 33 34" src="https://github.com/user-attachments/assets/5a742ac0-a4ed-4ec8-8f62-924a8e6b782d" />   <img width="724" height="1573" alt="Simulator Screenshot - iPhone 17 Pro - 2026-06-08 at 17 37 23" src="https://github.com/user-attachments/assets/1f97313b-1785-43bd-b4f4-8f64ce6c59b8" />





