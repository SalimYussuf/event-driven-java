# Week 8 — Self-Assessment

**Course:** Event-Driven Programming in Java  
**Folder:** [`WeekEightJavaFXBindings/`](./)  
**Study Guide:** [Logs & Observations/WeekEightJavaFXPropertiesAndBindings.md](../Logs%20%26%20Observations/WeekEightJavaFXPropertiesAndBindings.md)

---

## Deliverables

- [x] [`src/main/java/com/example/Person.java`](src/main/java/com/example/Person.java) — observable model with `StringProperty` / `IntegerProperty`
- [x] [`src/main/java/com/example/ListenerDemo.java`](src/main/java/com/example/ListenerDemo.java) — `ChangeListener` vs. `InvalidationListener`
- [x] [`src/main/java/com/example/UnidirectionalDemo.java`](src/main/java/com/example/UnidirectionalDemo.java) — `bind()`
- [x] [`src/main/java/com/example/BidirectionalDemo.java`](src/main/java/com/example/BidirectionalDemo.java) — `bindBidirectional()`
- [x] [`src/main/java/com/example/ReactiveFormApp.java`](src/main/java/com/example/ReactiveFormApp.java) — fully reactive registration form

---

## Learning Outcome 1 — Observable Data Models with Properties

**Why `StringProperty` instead of `String`?**  
A plain `String` is immutable and invisible — when you do `name = "Alice"`, nothing else knows. A `StringProperty` wraps the value in an observable container that fires notifications to any listener or binding when `.set(...)` is called.

**Standard pattern for an observable model (`Person.java`):**
```java
public class Person {
    private final StringProperty name = new SimpleStringProperty("");
    private final IntegerProperty age  = new SimpleIntegerProperty(0);

    // Standard JavaBean getter/setter
    public String getName()     { return name.get(); }
    public void   setName(String v) { name.set(v); }

    // Property accessor — required for binding and listeners
    public StringProperty nameProperty() { return name; }

    public int  getAge()        { return age.get(); }
    public void setAge(int v)   { age.set(v); }
    public IntegerProperty ageProperty() { return age; }
}
```

**Why expose `nameProperty()`?**  
So other components can call `label.textProperty().bind(person.nameProperty())` or `person.nameProperty().addListener(...)`. Without the property accessor, the caller can only use the value — they can't observe or bind to it.

**Property types at a glance:**

| Property class | Wraps | Common use |
| :--- | :--- | :--- |
| `SimpleStringProperty` | `String` | Names, labels, text inputs |
| `SimpleIntegerProperty` | `int` | Counts, years, IDs |
| `SimpleDoubleProperty` | `double` | Progress, prices |
| `SimpleBooleanProperty` | `boolean` | Valid flags, loading states |
| `SimpleObjectProperty<T>` | Any object | Selected item, enum state |

---

## Learning Outcome 2 — `ChangeListener` vs. `InvalidationListener`

**Core difference:**

| Listener | Receives | When value is re-set to same value |
| :--- | :--- | :--- |
| `InvalidationListener` | Just the observable — no values | Does not fire (already invalid) |
| `ChangeListener` | observable + old value + new value | Does not fire (equality check) |

**Code:**
```java
person.nameProperty().addListener(obs ->
    System.out.println("Invalidated")                        // InvalidationListener
);
person.nameProperty().addListener((obs, oldVal, newVal) ->
    System.out.println(oldVal + " → " + newVal)              // ChangeListener
);
```

**Observed output from `ListenerDemo` when setting name `"" → "Alice" → "Bob" → "Bob"`:**
```
--- Setting name to Alice ---
[InvalidationListener] Name was changed!
[ChangeListener] Name changed from '' to 'Alice'

--- Setting name to Bob ---
[InvalidationListener] Name was changed!
[ChangeListener] Name changed from 'Alice' to 'Bob'

--- Setting name to Bob (same value) ---
(nothing — JavaFX equality check prevents spurious notifications)
```

**When to use which:**  
- `ChangeListener` for most cases — you want the actual values.  
- `InvalidationListener` for expensive computed properties where you want to defer recalculation until `.get()` is actually called.

---

## Learning Outcome 3 — Unidirectional & Bidirectional Binding

**Unidirectional (`A.bind(B)`):** A always mirrors B. A is read-only while bound.
```java
greetingLabel.textProperty().bind(
    nameField.textProperty().concat(", welcome!")
);
// Slider → Label + ProgressBar with no event handlers:
valueLabel.textProperty().bind(slider.valueProperty().asString("%.0f%%"));
progressBar.progressProperty().bind(slider.valueProperty().divide(100));
```

**What happens if you call `setText(...)` on a bound label?**  
```java
greetingLabel.textProperty().bind(source);
greetingLabel.setText("test");  // throws RuntimeException: A bound value cannot be set
```
Call `greetingLabel.textProperty().unbind()` first if you need to set it manually.

**Bidirectional (`A.bindBidirectional(B)`):** Both stay in sync, both can be edited.
```java
nameField.textProperty().bindBidirectional(person.nameProperty());
// Numeric ↔ text with converter:
textField.textProperty().bindBidirectional(slider.valueProperty(), new NumberStringConverter());
```

---

## Learning Outcome 4 — Reactive Form with `Bindings` API

**Complete reactive validation pattern from `ReactiveFormApp.java`:**

```java
// Live character counter
charCountLabel.textProperty().bind(
    nameField.lengthProperty().asString("%d / 50 characters")
);

// Live greeting
greetingLabel.textProperty().bind(
    Bindings.concat("Hello, ", nameField.textProperty(), "!")
);

// Submit disabled until all fields valid — declarative, no event handler needed
BooleanBinding allValid =
    nameField.textProperty().length().greaterThan(1)
        .and(emailField.textProperty().containsString("@"))
        .and(passwordField.textProperty().length().greaterThanOrEqualTo(8));

submitBtn.disableProperty().bind(allValid.not());
```

**Why bindings instead of `setOnKeyReleased` for validation?**  
Bindings catch *every* source of change: typing, paste, programmatic `.setText(...)`, backspace. A key listener misses paste and programmatic updates entirely, causing the button's disabled state to fall out of sync.

**`.not()` on a `BooleanBinding`:**  
Negates the expression. `allValid.not()` = "disable the button when NOT all fields are valid".

---

## Run Commands

```powershell
# From WeekEightJavaFXBindings using Maven Wrapper:
cd WeekEightJavaFXBindings
.\mvnw.cmd javafx:run                                               # GUI dashboard
.\mvnw.cmd javafx:run -Djavafx.mainClass=com.example.ListenerDemo
.\mvnw.cmd javafx:run -Djavafx.mainClass=com.example.UnidirectionalDemo
.\mvnw.cmd javafx:run -Djavafx.mainClass=com.example.BidirectionalDemo
.\mvnw.cmd javafx:run -Djavafx.mainClass=com.example.ReactiveFormApp
```

```powershell
# From repository root:
.\scripts\run-week8.ps1
.\scripts\run-week8.ps1 -Launcher
.\scripts\run-week8.ps1 -All
```

```bash
# AgentCLI verification:
java scripts/AgentCLI.java verify --week 8
java scripts/AgentCLI.java grade  --week 8 --json
```
