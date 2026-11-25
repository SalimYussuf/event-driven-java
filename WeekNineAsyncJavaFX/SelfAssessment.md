# Week 9 — Self-Assessment

**Course:** Event-Driven Programming in Java  
**Folder:** [`WeekNineAsyncJavaFX/`](./)  
**Study Guide:** [Logs & Observations/WeekNineAsyncJavaFX.md](../Logs%20%26%20Observations/WeekNineAsyncJavaFX.md)

---

## Deliverables

- [x] [`src/main/java/com/example/FreezeDemo.java`](src/main/java/com/example/FreezeDemo.java) — UI freeze anti-pattern
- [x] [`src/main/java/com/example/TaskDemo.java`](src/main/java/com/example/TaskDemo.java) — `Task<Void>` fix
- [x] [`src/main/java/com/example/ProgressDemo.java`](src/main/java/com/example/ProgressDemo.java) — live `ProgressBar` binding
- [x] [`src/main/java/com/example/ServiceDemo.java`](src/main/java/com/example/ServiceDemo.java) — restartable `DataSyncService`

---

## Learning Outcome 1 — Why the UI Freezes

**What causes a freeze?**  
Any blocking call inside a JavaFX event handler runs on the JavaFX Application Thread — the same thread responsible for all rendering, layout, and input processing. While it's blocked, nothing else can run.

**`FreezeDemo.java` — the anti-pattern:**
```java
startBtn.setOnAction(e -> {
    statusLabel.setText("Loading...");    // this never actually appears —
    Thread.sleep(5000);                  // the thread is blocked before it can repaint
    statusLabel.setText("Done");
});
```
Result: window goes white, OS shows "Not Responding" for 5 seconds.

**Types of work that must never run on the JavaFX Application Thread:**
- Database queries or file reads
- Network calls (HTTP, JDBC)
- `Thread.sleep(...)` for any duration
- Heavy computations

---

## Learning Outcome 2 — `Task<V>` and `Service<V>`

**`Task` — single-use background job:**
```java
Task<String> task = new Task<>() {
    protected String call() throws Exception {
        Thread.sleep(5000);           // runs on a background thread — UI stays responsive
        return "Data loaded!";
    }
};
// Callbacks run automatically on the JavaFX Application Thread:
task.setOnSucceeded(e -> statusLabel.setText(task.getValue()));
task.setOnFailed(e    -> statusLabel.setText("Error: " + task.getException().getMessage()));

new Thread(task).start();
statusLabel.setText("Loading...");    // appears immediately — thread is not blocked
```

**`Service<V>` — reusable, restartable job factory:**
```java
class DataSyncService extends Service<String> {
    protected Task<String> createTask() {
        return new Task<>() {
            protected String call() throws Exception {
                for (int i = 0; i <= 100; i++) {
                    if (isCancelled()) break;        // respect cancellation
                    Thread.sleep(50);
                    updateProgress(i, 100);
                    updateMessage("Syncing: " + i + "%");
                }
                return isCancelled() ? "Cancelled" : "Complete!";
            }
        };
    }
}

DataSyncService service = new DataSyncService();
startBtn.setOnAction(e  -> service.restart());    // creates a fresh Task, starts it
cancelBtn.setOnAction(e -> service.cancel());     // sets isCancelled() flag in call()
```

**`Task` vs. `Service` — decision table:**

| | `Task<V>` | `Service<V>` |
| :--- | :--- | :--- |
| Reusable? | ❌ Single-use | ✅ Call `restart()` any time |
| Run | `new Thread(task).start()` | `service.start()` / `service.restart()` |
| Cancel | `task.cancel()` | `service.cancel()` |
| Best for | Load on open, one-time fetch | Search, sync, polling, refresh button |

---

## Learning Outcome 3 — Safe UI Updates from Background Threads

**Three safe ways to update the UI from off the JavaFX Application Thread:**

**1. `Task` lifecycle callbacks (automatic — no extra code):**
```java
task.setOnSucceeded(e -> label.setText(task.getValue()));  // already on FX thread
task.setOnFailed(e    -> label.setText("Failed"));
```

**2. `updateProgress` / `updateMessage` inside `call()` (automatic marshalling):**
```java
protected Void call() throws Exception {
    updateProgress(50, 100);           // internally calls Platform.runLater
    updateMessage("Halfway done");     // internally calls Platform.runLater
    return null;
}
```

**3. `Platform.runLater(...)` for plain background threads:**
```java
new Thread(() -> {
    String result = fetchData();
    Platform.runLater(() -> label.setText(result));   // marshals to FX thread
}).start();
```

**Rule of thumb:** Use `Task` callbacks and `updateProgress`/`updateMessage` whenever you're inside a `Task`. Use `Platform.runLater` only when using a plain `Thread`.

---

## Learning Outcome 4 — Live Progress Feedback

**Binding `ProgressBar` to a task — zero event handlers needed:**
```java
Task<Void> downloadTask = new Task<>() {
    protected Void call() throws Exception {
        for (int i = 0; i <= 100; i++) {
            Thread.sleep(50);
            updateProgress(i, 100);
            updateMessage("Downloading: " + i + "%");
        }
        return null;
    }
};

progressBar.progressProperty().bind(downloadTask.progressProperty());
statusLabel.textProperty().bind(downloadTask.messageProperty());

downloadTask.setOnSucceeded(e -> {
    statusLabel.textProperty().unbind();              // must unbind before setText
    statusLabel.setText("Download complete!");
    progressBar.progressProperty().unbind();
});

new Thread(downloadTask).start();
```

**Why call `unbind()` before `setText(...)` at the end?**  
`statusLabel.textProperty()` is bound to `downloadTask.messageProperty()`. Calling `setText(...)` on a bound property throws `RuntimeException: A bound value cannot be set`. Unbinding releases the connection first.

**Difference between `updateProgress()` and `Platform.runLater()`:**  
`updateProgress()` is a throttled, coalesced, task-aware method that publishes to `progressProperty()` on the FX thread. `Platform.runLater()` queues an arbitrary `Runnable` onto the FX thread — more general, but no coalescing.

---

## Threading Summary (Weeks 1 → 9)

| Toolkit | UI Thread | Dispatch from background | Background task |
| :--- | :--- | :--- | :--- |
| **Swing** | EDT | `SwingUtilities.invokeLater(...)` | `SwingWorker` |
| **JavaFX** | JavaFX Application Thread | `Platform.runLater(...)` | `Task` / `Service` |

---

## Run Commands

```powershell
# From WeekNineAsyncJavaFX using Maven Wrapper:
cd WeekNineAsyncJavaFX
.\mvnw.cmd javafx:run                                             # GUI dashboard
.\mvnw.cmd javafx:run -Djavafx.mainClass=com.example.FreezeDemo
.\mvnw.cmd javafx:run -Djavafx.mainClass=com.example.TaskDemo
.\mvnw.cmd javafx:run -Djavafx.mainClass=com.example.ProgressDemo
.\mvnw.cmd javafx:run -Djavafx.mainClass=com.example.ServiceDemo
```

```powershell
# From repository root:
.\scripts\run-week9.ps1
.\scripts\run-week9.ps1 -Launcher
.\scripts\run-week9.ps1 -Activity 3   # run ProgressDemo
```
