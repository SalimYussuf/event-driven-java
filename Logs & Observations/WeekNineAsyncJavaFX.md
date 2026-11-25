# Week 9 — Asynchronous Programming in JavaFX

**Code:** [`WeekNineAsyncJavaFX/`](../WeekNineAsyncJavaFX/)  
**Run:** `mvn -f WeekNineAsyncJavaFX/pom.xml javafx:run`  
**Scripts:** `.\scripts\run-week9.ps1` (PowerShell) · `./scripts/run-week9.sh` (Git Bash)

---

## Learning Objectives

By the end of this week I should be able to:

- Explain why any slow operation on the JavaFX Application Thread freezes the UI
- Run background work off the UI thread using `javafx.concurrent.Task<V>`
- Report live progress and status back to the UI safely using `updateProgress` and `updateMessage`
- Build reusable, restartable, cancellable background jobs with `javafx.concurrent.Service<V>`
- Know when to use `Platform.runLater(...)` for manual thread marshalling

---

## The Core Threading Rule

JavaFX has one thread for all UI work: the **JavaFX Application Thread**. It handles rendering, animations, and every event handler. The rule is identical to Swing's EDT:

> **Never block the JavaFX Application Thread. Never update UI controls from any other thread.**

If you call `Thread.sleep(5000)` inside a button handler, the entire window freezes — no animations, no resizes, no button presses — for the full 5 seconds.

---

## `Task` vs `Service` — When to Use Each

| | `Task<V>` | `Service<V>` |
| :--- | :--- | :--- |
| **Purpose** | One-shot background job | Reusable, restartable job factory |
| **Run** | `new Thread(task).start()` | `service.start()` / `service.restart()` |
| **Reuse** | ❌ Single use — cannot restart | ✅ Call `restart()` as many times as needed |
| **Cancel** | `task.cancel()` + check `isCancelled()` | `service.cancel()` |
| **Result** | `task.getValue()` in `setOnSucceeded` | `service.getValue()` |
| **Best for** | Load-on-open, one-time fetch | Search, sync, polling |

---

## Activities

### Activity 1 — The Freeze Problem ([`FreezeDemo.java`](../WeekNineAsyncJavaFX/src/main/java/com/example/FreezeDemo.java))

Deliberately wrong — simulates a 5-second database query blocking the UI thread:

```java
startBtn.setOnAction(e -> {
    statusLabel.setText("Loading...");
    try {
        Thread.sleep(5000); // runs ON the JavaFX Application Thread — UI locks
    } catch (InterruptedException ex) { Thread.currentThread().interrupt(); }
    statusLabel.setText("Done");
});
```

Result: the window goes completely white and unresponsive for 5 seconds. The "Loading..." label never even appears because the thread is blocked before it can repaint.

```bash
mvn -f WeekNineAsyncJavaFX/pom.xml javafx:run -Djavafx.mainClass=com.example.FreezeDemo
```

---

### Activity 2 — Fixing It with `Task` ([`TaskDemo.java`](../WeekNineAsyncJavaFX/src/main/java/com/example/TaskDemo.java))

The correct pattern — slow work in `call()`, UI updates in the callback:

```java
startBtn.setOnAction(e -> {
    Task<String> task = new Task<>() {
        protected String call() throws Exception {
            Thread.sleep(5000); // runs on a background thread — UI stays responsive
            return "Data loaded!";
        }
    };

    // These callbacks run back on the JavaFX Application Thread automatically
    task.setOnSucceeded(evt -> statusLabel.setText(task.getValue()));
    task.setOnFailed(evt -> statusLabel.setText("Error: " + task.getException().getMessage()));

    new Thread(task).start();
    statusLabel.setText("Loading...");  // this appears immediately
});
```

```bash
mvn -f WeekNineAsyncJavaFX/pom.xml javafx:run -Djavafx.mainClass=com.example.TaskDemo
```

> **What I observed:** The moment `new Thread(task).start()` runs, the event handler returns and the JavaFX Application Thread is free again. The window stays fully interactive while the background thread does the work.

---

### Activity 3 — Live Progress Reporting ([`ProgressDemo.java`](../WeekNineAsyncJavaFX/src/main/java/com/example/ProgressDemo.java))

`Task` has built-in thread-safe methods for reporting progress:

```java
Task<Void> downloadTask = new Task<>() {
    protected Void call() throws Exception {
        for (int i = 0; i <= 100; i++) {
            Thread.sleep(50);
            updateProgress(i, 100);           // updates progressProperty on JavaFX thread
            updateMessage("Downloading: " + i + "%"); // updates messageProperty on JavaFX thread
        }
        return null;
    }
};

// Bind UI directly to task properties — no Platform.runLater needed
progressBar.progressProperty().bind(downloadTask.progressProperty());
statusLabel.textProperty().bind(downloadTask.messageProperty());

new Thread(downloadTask).start();
```

The `ProgressBar` fills smoothly in real time. No `Platform.runLater` needed — `updateProgress` and `updateMessage` marshal to the JavaFX thread internally.

```bash
mvn -f WeekNineAsyncJavaFX/pom.xml javafx:run -Djavafx.mainClass=com.example.ProgressDemo
```

---

### Activity 4 — Reusable `Service` ([`ServiceDemo.java`](../WeekNineAsyncJavaFX/src/main/java/com/example/ServiceDemo.java))

A `DataSyncService` that can be started, cancelled, and restarted as many times as needed:

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
                return isCancelled() ? "Cancelled" : "Sync complete!";
            }
        };
    }
}

DataSyncService service = new DataSyncService();
progressBar.progressProperty().bind(service.progressProperty());
statusLabel.textProperty().bind(service.messageProperty());

startBtn.setOnAction(e  -> service.restart());  // works even if already running
cancelBtn.setOnAction(e -> service.cancel());
```

> **Key benefit of `Service`:** `restart()` creates a fresh `Task`, cancels any in-flight one, and starts the new one — all in one call. With a plain `Task` you'd have to manage that yourself.

```bash
mvn -f WeekNineAsyncJavaFX/pom.xml javafx:run -Djavafx.mainClass=com.example.ServiceDemo
```

---

## `Platform.runLater` — When You Still Need It

`Task` callbacks and `updateProgress`/`updateMessage` handle JavaFX thread marshalling automatically. But if you're on a **plain background thread** (not a `Task`) and you need to touch the UI, use:

```java
new Thread(() -> {
    String result = fetchData();                       // background work
    Platform.runLater(() -> label.setText(result));    // UI update on JavaFX thread
}).start();
```

This is the manual equivalent of Swing's `SwingUtilities.invokeLater`.

---

## What I Observed

- **`Task.setOnSucceeded` runs on the JavaFX thread.** This is the most important thing to internalise. The heavy work is in `call()` (background thread); the UI update is in `setOnSucceeded` (JavaFX thread). The framework handles the switch automatically.
- **Binding to `progressProperty()` is elegant.** I expected to need a listener, but binding the `ProgressBar` directly to the task's property means zero event handler code. It just works.
- **`isCancelled()` must be checked inside `call()`.** Calling `service.cancel()` doesn't throw an exception — it just sets a flag. Your `call()` code must check the flag in its loop and exit cleanly.
- **`Service` is for anything the user might trigger repeatedly.** Search bars, refresh buttons, sync operations — anything that can be re-triggered before the last run finishes belongs in a `Service`.

---

## Self-Check

**Q: Can you reuse a `Task` after it finishes?**  
No. A `Task` is single-use. Use a `Service` if you need to run the same background job more than once — `service.restart()` creates a fresh `Task` each time.

**Q: Why is binding `progressBar.progressProperty().bind(task.progressProperty())` thread-safe?**  
`updateProgress()` internally calls `Platform.runLater` to update the property on the JavaFX Application Thread. The binding just observes a property that is always updated on the correct thread.

**Q: When do you need `Platform.runLater`?**  
When you're using a plain `Thread` (not a `Task`) and you need to update a UI node. `Task` callbacks already run on the JavaFX thread, so `Platform.runLater` isn't needed there.

---

*Full self-assessment: [`WeekNineAsyncJavaFX/SelfAssessment.md`](../WeekNineAsyncJavaFX/SelfAssessment.md)*
