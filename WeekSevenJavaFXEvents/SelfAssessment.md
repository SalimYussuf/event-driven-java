# Week 7 — Self-Assessment

**Course:** Event-Driven Programming in Java  
**Folder:** [`WeekSevenJavaFXEvents/`](./)  
**Study Guide:** [Logs & Observations/WeekSevenJavaFXEventHandling.md](../Logs%20%26%20Observations/WeekSevenJavaFXEventHandling.md)

---

## Deliverables

- [x] [`src/main/java/com/example/EventPropagationDemo.java`](src/main/java/com/example/EventPropagationDemo.java) — capturing vs. bubbling
- [x] [`src/main/java/com/example/MouseKeyDemo.java`](src/main/java/com/example/MouseKeyDemo.java) — coordinates, arrow key circle
- [x] [`src/main/java/com/example/DragDropDemo.java`](src/main/java/com/example/DragDropDemo.java) — Dragboard / ClipboardContent
- [x] [`src/main/java/com/example/LoginSuccessEvent.java`](src/main/java/com/example/LoginSuccessEvent.java) — custom event class
- [x] [`src/main/java/com/example/CustomEventDemo.java`](src/main/java/com/example/CustomEventDemo.java) — fire and handle custom event

---

## Learning Outcome 1 — Event Propagation: Filtering vs. Handling

**Two-phase delivery:**

```
Capturing (top → down):   Stage → Scene → StackPane → VBox → Button
Bubbling  (bottom → up):  Button → VBox → StackPane → Scene → Stage
```

| Registration method | Phase | Use case |
| :--- | :--- | :--- |
| `addEventFilter(type, handler)` | Capturing — before target | Intercept/cancel before the target sees it |
| `addEventHandler(type, handler)` | Bubbling — after target | Normal response after event reaches target |
| `setOnAction(...)` / `setOnMouseClicked(...)` | Bubbling (target phase) | Standard convenience handlers |

**Observed execution order in `EventPropagationDemo`:**
```
[FILTER]  StackPane — capturing
[FILTER]  VBox — capturing
[HANDLER] Button — target (bubbling)
[HANDLER] VBox — bubbling
[HANDLER] StackPane — bubbling
```

**What `event.consume()` does:**  
Marks the event as handled and stops it from travelling further in either direction. Called inside a filter at the `VBox` level: the button never sees the click.

**Which runs first — filter or handler?**  
The filter. It runs during the top-down capturing phase, before the event reaches its target.

---

## Learning Outcome 2 — Mouse & Keyboard Events

**Tracking mouse position without clicking:**
```java
scene.setOnMouseMoved(e -> {
    coordLabel.setText(String.format("X: %.0f  Y: %.0f", e.getX(), e.getY()));
});
```

**Moving a shape with arrow keys:**
```java
scene.setOnKeyPressed(e -> {
    switch (e.getCode()) {
        case LEFT  -> cx = Math.max(RADIUS, cx - STEP);
        case RIGHT -> cx = Math.min(canvas.getWidth() - RADIUS, cx + STEP);
        case UP    -> cy = Math.max(RADIUS, cy - STEP);
        case DOWN  -> cy = Math.min(canvas.getHeight() - RADIUS, cy + STEP);
    }
    redraw();
});
```

**Why might `KeyEvent` not fire?**  
The target node doesn't have input focus. Fix:
```java
root.setFocusTraversable(true);
primaryStage.setOnShown(e -> root.requestFocus());
```

**Modifier key checks:**
```java
e.isControlDown()   // Ctrl held
e.isShiftDown()     // Shift held
e.isAltDown()       // Alt held
```

---

## Learning Outcome 3 — Drag and Drop

**Three mandatory steps — missing any one silently breaks the whole chain:**

```java
// Step 1: Detect drag on the source
source.setOnDragDetected(e -> {
    Dragboard db = source.startDragAndDrop(TransferMode.MOVE);
    ClipboardContent content = new ClipboardContent();
    content.putString(source.getText());
    db.setContent(content);
    e.consume();
});

// Step 2: Accept on the target (MUST call acceptTransferModes — without this, drop never fires)
target.setOnDragOver(e -> {
    if (e.getDragboard().hasString()) {
        e.acceptTransferModes(TransferMode.MOVE);
    }
    e.consume();
});

// Step 3: Handle the drop
target.setOnDragDropped(e -> {
    Dragboard db = e.getDragboard();
    if (db.hasString()) {
        target.setText(db.getString());
        e.setDropCompleted(true);
    }
    e.consume();
});
```

**Visual feedback during drag (optional but good UX):**
```java
target.setOnDragEntered(e -> target.setStyle("-fx-border-color: green;"));
target.setOnDragExited(e  -> target.setStyle("-fx-border-color: lightgray;"));
```

**Most common mistake:**  
Forgetting `e.acceptTransferModes(...)` inside `setOnDragOver`. The drop is silently rejected — `setOnDragDropped` never fires, no error is thrown.

---

## Learning Outcome 4 — Custom Events

**Why create a custom event instead of calling a method directly?**  
Loose coupling. The login button doesn't need to know about the welcome label, the session manager, or anything else that cares about a successful login. It just fires an event. Any component anywhere in the scene tree can listen for it independently.

**Custom event class:**
```java
public class LoginSuccessEvent extends Event {
    public static final EventType<LoginSuccessEvent> LOGIN_SUCCESS =
        new EventType<>(Event.ANY, "LOGIN_SUCCESS");

    private final String username;

    public LoginSuccessEvent(String username) {
        super(LOGIN_SUCCESS);
        this.username = username;
    }

    public String getUsername() { return username; }
}
```

**Firing and handling:**
```java
// Fire from anywhere in the scene
loginBtn.fireEvent(new LoginSuccessEvent(usernameField.getText()));

// Handle from anywhere in the scene — no direct reference to the button needed
scene.addEventHandler(LoginSuccessEvent.LOGIN_SUCCESS, e ->
    welcomeLabel.setText("Welcome, " + e.getUsername() + "!")
);
```

**What class must custom events extend?**  
`javafx.event.Event`.

**How is the event type declared?**  
`public static final EventType<MyEvent> MY_TYPE = new EventType<>(Event.ANY, "MY_TYPE_NAME")`.

---

## Run Commands

```powershell
# From WeekSevenJavaFXEvents using Maven Wrapper:
cd WeekSevenJavaFXEvents
.\mvnw.cmd javafx:run                                                 # GUI dashboard
.\mvnw.cmd javafx:run -Djavafx.mainClass=com.example.EventPropagationDemo
.\mvnw.cmd javafx:run -Djavafx.mainClass=com.example.MouseKeyDemo
.\mvnw.cmd javafx:run -Djavafx.mainClass=com.example.DragDropDemo
.\mvnw.cmd javafx:run -Djavafx.mainClass=com.example.CustomEventDemo
```

```powershell
# From repository root using runner script:
.\scripts\run-week7.ps1
.\scripts\run-week7.ps1 -Launcher
.\scripts\run-week7.ps1 -All
```
