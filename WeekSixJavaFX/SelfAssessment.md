# Week 6 — Self-Assessment

**Course:** Event-Driven Programming in Java  
**Folder:** [`WeekSixJavaFX/`](./)  
**Study Guide:** [Logs & Observations/WeekSixIntroToJavaFX.md](../Logs%20%26%20Observations/WeekSixIntroToJavaFX.md)

---

## Deliverables

- [x] [`src/main/java/programmaticdemo/Main.java`](src/main/java/programmaticdemo/Main.java) — first JavaFX window (programmatic)
- [x] [`src/main/java/programmaticdemo/LayoutDemo.java`](src/main/java/programmaticdemo/LayoutDemo.java) — VBox, HBox, GridPane, BorderPane
- [x] [`src/main/java/programmaticdemo/FXMLApp.java`](src/main/java/programmaticdemo/FXMLApp.java) — FXML loader + controller wiring
- [x] [`src/main/java/programmaticdemo/LoginController.java`](src/main/java/programmaticdemo/LoginController.java) — `@FXML` injection
- [x] [`src/main/java/programmaticdemo/DashboardApp.java`](src/main/java/programmaticdemo/DashboardApp.java) — SaaS metric dashboard

---

## Learning Outcome 1 — JavaFX Application Architecture

**The core hierarchy:**
```
Application.start(Stage stage)
└── Stage   ← the OS window
    └── Scene(root, width, height)
        └── Root Node (e.g. VBox, BorderPane)
            ├── Button
            ├── Label
            └── TextField
```

**What is the difference between `Stage` and `Scene`?**  
`Stage` is the OS-managed window (title bar, close button, border). `Scene` holds the content tree inside it. You can swap scenes on the same stage to navigate between screens — the window stays open, only the content changes.

**What is the JavaFX Application Thread?**  
The single dedicated thread for all UI rendering, layout calculation, and event handling. The same rule as Swing's EDT: never block it, never touch UI nodes from another thread. Use `Platform.runLater(...)` for UI updates from background threads.

**Swing EDT vs. JavaFX Application Thread:**

| Concern | Swing | JavaFX |
| :--- | :--- | :--- |
| UI thread name | Event Dispatch Thread (EDT) | JavaFX Application Thread |
| Dispatch from background | `SwingUtilities.invokeLater(...)` | `Platform.runLater(...)` |
| Background task helper | `SwingWorker<T,V>` | `Task<V>` / `Service<V>` |
| Styling | `UIManager` / per-component calls | CSS (`-fx-*` properties) |
| Layout | Manager objects | Pane subclasses |
| UI declaration | Java code only | Java code or FXML (XML) |

---

## Learning Outcome 2 — Layout Panes

**When to use each:**

| Pane | Use for | Key property |
| :--- | :--- | :--- |
| `VBox` | Vertical stack | `spacing`, `alignment` |
| `HBox` | Horizontal row | `spacing`, `alignment` |
| `GridPane` | Form / row-column grid | `add(node, col, row)`, `hgap`, `vgap` |
| `BorderPane` | App shell with regions | `top`, `left`, `center`, `right`, `bottom` |
| `StackPane` | Layered overlay | Children stack back-to-front |

**Which pane is best for a top nav + sidebar + main content?**  
`BorderPane`: nav bar in `top`, sidebar in `left`, main content in `center`. `center` claims all remaining space automatically.

**`GridPane` column spanning example:**
```java
GridPane grid = new GridPane();
grid.setHgap(10); grid.setVgap(8);
grid.add(new Label("Email:"), 0, 0);
grid.add(emailField, 1, 0);
grid.add(submitBtn, 0, 1);
GridPane.setColumnSpan(submitBtn, 2);   // button spans both columns
```

---

## Learning Outcome 3 — FXML & Controller Wiring

**How `@FXML` injection works:**  
`FXMLLoader` parses the XML, builds the node tree, instantiates the controller class specified in `fx:controller`, then uses reflection to match `fx:id` values in the XML to field names annotated with `@FXML` in the controller.

**Minimal FXML + controller pair:**

`login.fxml`:
```xml
<VBox xmlns:fx="http://javafx.com/fxml/1"
      fx:controller="programmaticdemo.LoginController"
      spacing="10" alignment="CENTER">
    <TextField fx:id="usernameField" promptText="Username"/>
    <PasswordField fx:id="passwordField" promptText="Password"/>
    <Button text="Login" onAction="#handleLoginButtonAction"/>
</VBox>
```

`LoginController.java`:
```java
public class LoginController {
    @FXML private TextField usernameField;
    @FXML private PasswordField passwordField;

    @FXML
    private void handleLoginButtonAction(ActionEvent e) {
        String user = usernameField.getText();
        if (user.isEmpty()) {
            usernameField.setStyle("-fx-border-color: red;");
            return;
        }
        // proceed with login...
    }

    // initialize() runs after all @FXML fields are injected:
    public void initialize() {
        usernameField.requestFocus();
    }
}
```

**`FXMLApp.java` loading pattern:**
```java
Parent root = FXMLLoader.load(getClass().getResource("login.fxml"));
stage.setScene(new Scene(root, 400, 300));
```

**What does `@FXML` do vs. not doing anything?**  
Without `@FXML`, the field stays `null` even if the FXML has a matching `fx:id`. The annotation is the signal to `FXMLLoader` to inject the node reference.

---

## Learning Outcome 4 — MVC Separation & CSS Styling

**MVC in the FXML architecture:**

| Layer | File | Responsibility |
| :--- | :--- | :--- |
| **View** | `login.fxml` | Layout, widget hierarchy, spacing — zero Java code |
| **Controller** | `LoginController.java` | Event handlers, validation, `@FXML` fields |
| **Bridge** | `FXMLLoader` | Parses XML, instantiates controller, injects fields |

**Inline CSS in `DashboardApp.java`:**
```java
HBox header = new HBox();
header.setStyle("-fx-background-color: #2c3e50; -fx-padding: 15;");

Label title = new Label("Dashboard");
title.setStyle("-fx-text-fill: white; -fx-font-size: 18;");
```
CSS in JavaFX uses the same mental model as web CSS — `-fx-` prefixes the properties. External stylesheets can be attached to a `Scene` with `scene.getStylesheets().add(...)`.

---

## Run Commands

```powershell
# From WeekSixJavaFX directory using Maven Wrapper:
cd WeekSixJavaFX
.\mvnw.cmd javafx:run                                             # launches default main
.\mvnw.cmd javafx:run -Djavafx.mainClass=programmaticdemo.Main
.\mvnw.cmd javafx:run -Djavafx.mainClass=programmaticdemo.LayoutDemo
.\mvnw.cmd javafx:run -Djavafx.mainClass=programmaticdemo.FXMLApp
.\mvnw.cmd javafx:run -Djavafx.mainClass=programmaticdemo.DashboardApp
```

```bash
# From repository root using runner script:
./scripts/run-week6.sh
./scripts/run-week6.sh --launcher
```
