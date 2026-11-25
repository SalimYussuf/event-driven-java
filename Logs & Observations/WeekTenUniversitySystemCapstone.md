# Week 10 Capstone — University Management System

**Code:** [`WeekTenUniversitySystem/`](../WeekTenUniversitySystem/)  
**Run:** `mvn -f WeekTenUniversitySystem/pom.xml javafx:run`  
**Scripts:** `.\scripts\run-university.ps1` (PowerShell) · `./scripts/run-university.sh` (Git Bash)

---

## What This Project Is

A production-style JavaFX desktop application for managing university students and academic programmes, backed by a cloud **PostgreSQL database on Neon**. It applies every concept from Weeks 1–9 in a single cohesive system:

| Week concept | Where it appears |
| :--- | :--- |
| Event-driven architecture (W1) | Every button, search field, and form wires an event handler |
| Observer / decoupled models (W2) | `Student` model uses JavaFX properties; the `TableView` observes changes automatically |
| Layout & component structure (W3–W5) | `BorderPane` shell, FXML-defined forms, `TableView` with custom columns |
| FXML + controllers (W6) | `MainView.fxml` → `MainController`, `StudentView.fxml` → `StudentController` |
| Event propagation (W7) | Custom validation events, button enable/disable wired to form state |
| Properties & bindings (W8) | `disableProperty()` on Add button bound to field validation; live search drives `FilteredList` |
| Background tasks (W9) | `LoadStudentsTask` queries PostgreSQL off the UI thread; `ScheduledExecutorService` runs a heartbeat |

---

## Project Structure

```
WeekTenUniversitySystem/
├── pom.xml                                    # Maven — JavaFX 21, PostgreSQL JDBC 42.7.3
├── lib/
│   └── postgresql-42.7.3.jar                  # Standalone JDBC driver (for non-Maven runs)
└── src/main/
    ├── java/com/university/
    │   ├── App.java                           # Entry point + ScheduledExecutorService heartbeat
    │   ├── DatabaseUtil.java                  # .env loader, SSL connection, table auto-init
    │   ├── LoadStudentsTask.java              # Task<ObservableList<Student>> — background DB load
    │   ├── MainController.java                # Sidebar navigation between Dashboard and Students
    │   ├── Student.java                       # Observable model (IntegerProperty, StringProperty)
    │   ├── StudentController.java             # CRUD, live search, form validation
    │   ├── SeedStudents.java                  # CLI tool — inserts 100 sample Kenyan student records
    │   └── UniversitySystemTest.java          # Headless integration test (no GUI window needed)
    └── resources/com/university/
        ├── MainView.fxml                      # Outer shell — sidebar + content area
        └── StudentView.fxml                   # Student table + add/edit form
```

---

## Database Setup — Neon PostgreSQL

> I chose **Neon** (serverless cloud PostgreSQL) over a local MySQL instance because it means anyone can run this project without installing a database server locally — just paste a connection string.

### First-Time Setup

1. Create a free database at [neon.tech](https://neon.tech).
2. Copy [`.env.example`](../.env.example) to `.env` in the repo root:
   ```bash
   cp .env.example .env
   ```
3. Set your connection string inside `.env`:
   ```env
   DATABASE_URL="postgresql://USER:PASSWORD@YOUR-HOST.neon.tech/neondb?sslmode=require"
   ```

### What Happens on First Run

[`DatabaseUtil.java`](../WeekTenUniversitySystem/src/main/java/com/university/DatabaseUtil.java) reads `.env.local`, then `.env`, then system environment variables. If none exist, it falls back to individual `PG*` variables. On first connection it auto-creates:

```sql
CREATE TABLE IF NOT EXISTS programs (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    email VARCHAR(200) UNIQUE,
    programme VARCHAR(200),
    year INT DEFAULT 1
);
```

Default programmes (`Bachelor of Computer Science`, `Diploma in IT`) are seeded if the `programs` table is empty.

---

## How the Key Parts Work

### Observable Student Model ([`Student.java`](../WeekTenUniversitySystem/src/main/java/com/university/Student.java))

Each field is a JavaFX Property so the `TableView` columns bind directly to the model — no manual cell-update code needed:

```java
public class Student {
    private final IntegerProperty id = new SimpleIntegerProperty();
    private final StringProperty name = new SimpleStringProperty();
    private final StringProperty email = new SimpleStringProperty();
    private final StringProperty programme = new SimpleStringProperty();
    private final IntegerProperty year = new SimpleIntegerProperty();

    // JavaFX TableView needs these property accessor methods
    public IntegerProperty idProperty()      { return id; }
    public StringProperty nameProperty()     { return name; }
    public StringProperty emailProperty()    { return email; }
    public StringProperty programmeProperty(){ return programme; }
    public IntegerProperty yearProperty()    { return year; }
}
```

### Background Loading ([`LoadStudentsTask.java`](../WeekTenUniversitySystem/src/main/java/com/university/LoadStudentsTask.java))

Extends `Task<ObservableList<Student>>` — the query runs on a background thread; the result is handed to the UI via `setOnSucceeded`:

```java
public class LoadStudentsTask extends Task<ObservableList<Student>> {
    protected ObservableList<Student> call() throws Exception {
        ObservableList<Student> list = FXCollections.observableArrayList();
        try (Connection conn = DatabaseUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT * FROM students ORDER BY name")) {
            while (rs.next()) {
                Student s = new Student();
                s.setId(rs.getInt("id"));
                s.setName(rs.getString("name"));
                s.setEmail(rs.getString("email"));
                // ...
                list.add(s);
            }
        }
        return list;
    }
}
```

In `StudentController`:
```java
LoadStudentsTask task = new LoadStudentsTask();
task.setOnSucceeded(e -> {
    ObservableList<Student> students = task.getValue();
    filteredList = new FilteredList<>(students, p -> true);
    sortedList = new SortedList<>(filteredList);
    sortedList.comparatorProperty().bind(tableView.comparatorProperty());
    tableView.setItems(sortedList);
});
new Thread(task).start();
```

### Live Search + CRUD ([`StudentController.java`](../WeekTenUniversitySystem/src/main/java/com/university/StudentController.java))

**Live search** filters the loaded list without hitting the database again:
```java
searchField.textProperty().addListener((obs, oldVal, newVal) ->
    filteredList.setPredicate(student ->
        newVal == null || newVal.isEmpty() ||
        student.getName().toLowerCase().contains(newVal.toLowerCase()) ||
        student.getEmail().toLowerCase().contains(newVal.toLowerCase())
    )
);
```

**Add button disabled until required fields are filled (bindings):**
```java
addBtn.disableProperty().bind(
    nameField.textProperty().isEmpty()
        .or(emailField.textProperty().isEmpty())
        .or(programmeCombo.valueProperty().isNull())
);
```

### Scheduled Heartbeat ([`App.java`](../WeekTenUniversitySystem/src/main/java/com/university/App.java))

A background service that checks for updates every 5 seconds, started in `start()` and shut down cleanly in `stop()`:

```java
scheduler = Executors.newScheduledThreadPool(1);
scheduler.scheduleAtFixedRate(() ->
    System.out.println("Heartbeat: " + new java.util.Date()),
    0, 5, TimeUnit.SECONDS
);

// In stop():
scheduler.shutdownNow();
```

---

## Running the Project

| Action | Command |
| :--- | :--- |
| **Launch the app** | `mvn -f WeekTenUniversitySystem/pom.xml javafx:run` |
| **Run integration test** | `.\scripts\run-university.ps1 -Test` |
| **Seed 100 student records** | `.\scripts\run-university.ps1 -Seed` |

**Direct Java test run (no Maven):**
```powershell
java -cp "WeekTenUniversitySystem/target/classes;WeekTenUniversitySystem/lib/postgresql-42.7.3.jar" com.university.UniversitySystemTest
```

The test connects to Neon over SSL, creates tables if needed, inserts a test student, queries it back, and prints `ALL TESTS PASSED`.

---

## What I Observed

- **`FilteredList` + `SortedList` is the right stack.** Load once from the DB, then let the user filter and sort locally. No second query needed for every search keystroke.
- **Properties make the `TableView` effortless.** Once columns are set up with `.setCellValueFactory(new PropertyValueFactory<>("name"))`, the table auto-updates whenever the underlying `Student` property changes. I never call `tableView.refresh()` manually.
- **Neon's serverless nature means cold-start latency.** On the very first connection after the database has been idle, there's a noticeable delay (~1–2 seconds). Subsequent connections within the session are fast. This is exactly why the loading runs in `LoadStudentsTask` — users see the UI immediately while the data loads in the background.
- **`DatabaseUtil` loading `.env` in pure Java** means no Node.js or npm is needed at runtime. The whole app is self-contained: compile with Maven, run with `java`.

---

## Self-Check

**Q: Why run database queries in `Task` instead of inside a button click handler?**  
Database queries over a network can take anywhere from 20ms to several seconds. Running them on the JavaFX Application Thread would freeze the entire UI for that duration. `Task` pushes the work to a background thread while the UI stays fully responsive.

**Q: How does `Task` safely update the UI when it finishes?**  
`call()` runs on a background thread. `setOnSucceeded()` and `setOnFailed()` are automatically invoked on the JavaFX Application Thread — no `Platform.runLater` required.

**Q: Why use `ScheduledExecutorService` for the heartbeat instead of a plain loop?**  
`ScheduledExecutorService` manages its own thread pool, fires at a fixed rate regardless of how long each task takes, and shuts down cleanly via `shutdownNow()` when `App.stop()` is called. A `while(true) { Thread.sleep(5000); }` loop has no clean shutdown and drifts in timing.

**Q: Why is `FilteredList` better than re-querying the database on every search keystroke?**  
Local filtering is instantaneous (sub-millisecond). A database round-trip adds network latency on every keystroke and hammers the connection pool. Load once, filter locally.

---

*Scripts reference: [`scripts/run-university.ps1`](../scripts/run-university.ps1) · [`scripts/run-university.sh`](../scripts/run-university.sh)*
