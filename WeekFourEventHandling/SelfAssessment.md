# Week 4 — Self-Assessment

**Course:** Event-Driven Programming in Java  
**Folder:** [`WeekFourEventHandling/`](./)  
**Study Guide:** [Logs & Observations/WeekFourSelfPacedActivity.md](../Logs%20%26%20Observations/WeekFourSelfPacedActivity.md)

---

## Deliverables

- [x] [`activity1-actionlistener-basics/FirstButton.java`](activity1-actionlistener-basics/FirstButton.java)
- [x] [`activity2-listener-techniques/ListenerDemo.java`](activity2-listener-techniques/ListenerDemo.java) — 4 listener styles
- [x] [`activity2-listener-techniques/EventSourceDemo.java`](activity2-listener-techniques/EventSourceDemo.java) — `getSource()` / `getActionCommand()`
- [x] [`activity3-item-and-document-listeners/ItemListenerDemo.java`](activity3-item-and-document-listeners/ItemListenerDemo.java) — pizza order form
- [x] [`activity3-item-and-document-listeners/DocumentListenerDemo.java`](activity3-item-and-document-listeners/DocumentListenerDemo.java) — character counter
- [x] [`activity3-item-and-document-listeners/LiveSearchDemo.java`](activity3-item-and-document-listeners/LiveSearchDemo.java) — live search filter
- [x] [`activity4-counter-app/CounterApp.java`](activity4-counter-app/CounterApp.java) — keyboard shortcuts
- [x] [`activity5-interactive-form/RegistrationForm.java`](activity5-interactive-form/RegistrationForm.java) — form validation
- [x] [`activity6-mouse-and-key/DrawingApp.java`](activity6-mouse-and-key/DrawingApp.java) — freehand canvas
- [x] [`activity6-mouse-and-key/KeyboardMover.java`](activity6-mouse-and-key/KeyboardMover.java) — arrow-key movement

---

## Learning Outcome 1 — `ActionListener` with Multiple Techniques

**Four ways to attach the same listener:**

```java
// 1. Named inner class — reusable, testable
class SaveListener implements ActionListener {
    public void actionPerformed(ActionEvent e) { save(); }
}
button.addActionListener(new SaveListener());

// 2. Anonymous class — legacy / multi-method interfaces
button.addActionListener(new ActionListener() {
    public void actionPerformed(ActionEvent e) { save(); }
});

// 3. Lambda — modern standard for single-method interfaces
button.addActionListener(e -> save());

// 4. Method reference — cleanest when a named handler already exists
button.addActionListener(this::save);
```

**When to use each:**
- Lambda → almost always, for concise inline logic
- Method reference → when the handler is a named method with its own clear purpose
- Named class → when the handler is complex, stateful, or reused across multiple places
- Anonymous class → legacy code or interfaces with more than one method to override

**How one listener handles multiple sources:**
```java
ActionListener shared = e -> {
    if (e.getSource() == saveBtn) {
        save();
    } else if (e.getActionCommand().equals("Delete")) {
        delete();
    }
};
saveBtn.addActionListener(shared);
deleteBtn.setActionCommand("Delete");
deleteBtn.addActionListener(shared);
```

---

## Learning Outcome 2 — State & Document Listeners

**Component-to-listener map:**

| Component | Use this listener | Key method |
| :--- | :--- | :--- |
| `JButton` | `ActionListener` | `actionPerformed(e)` |
| `JCheckBox` | `ItemListener` | `itemStateChanged(e)` |
| `JRadioButton` | `ItemListener` | `itemStateChanged(e)` |
| `JComboBox` | `ItemListener` / `ActionListener` | `itemStateChanged` / `actionPerformed` |
| `JTextField` (live) | `DocumentListener` | `insertUpdate`, `removeUpdate`, `changedUpdate` |
| `JTextField` (on Enter) | `ActionListener` | `actionPerformed(e)` |
| `JSlider` | `ChangeListener` | `stateChanged(e)` |
| `JPanel` / canvas | `MouseListener`, `MouseMotionListener` | `mouseClicked`, `mouseDragged` |

**`DocumentListener` gotcha — never mutate text from inside a callback:**
```java
// THIS THROWS IllegalStateException at runtime:
textField.getDocument().addDocumentListener(new DocumentListener() {
    public void insertUpdate(DocumentEvent e) {
        textField.setText("modified");  // ❌ mutating the document while it's firing
    }
    // ...
});

// FIX: defer the mutation to after the event completes:
public void insertUpdate(DocumentEvent e) {
    SwingUtilities.invokeLater(() -> textField.setText("modified"));  // ✅
}
```

**When to use `DocumentListener` vs `ActionListener` on a text field:**  
`DocumentListener` fires on every character — typing, paste, backspace, autocomplete. `ActionListener` fires only on Enter. For live search, counters, or validation: `DocumentListener`.

---

## Learning Outcome 3 — Keyboard Shortcuts via `InputMap` / `ActionMap`

**Why `InputMap`/`ActionMap` over `KeyListener`:**  
`KeyListener` only fires when the specific component has focus. `InputMap`/`ActionMap` registered at the root pane (`WHEN_IN_FOCUSED_WINDOW`) fire no matter which component is focused — global shortcuts.

```java
InputMap im = frame.getRootPane().getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW);
ActionMap am = frame.getRootPane().getActionMap();

im.put(KeyStroke.getKeyStroke(KeyEvent.VK_UP, 0), "increment");
am.put("increment", new AbstractAction() {
    public void actionPerformed(ActionEvent e) { increment(); }
});

im.put(KeyStroke.getKeyStroke(KeyEvent.VK_R, 0), "reset");
am.put("reset", new AbstractAction() {
    public void actionPerformed(ActionEvent e) { reset(); }
});
```

---

## Learning Outcome 4 — Interactive Apps with Validation & Mouse/Key Events

**Registration form validation approach in `RegistrationForm.java`:**
- Name: `name.trim().length() >= 2`
- Email: `email.matches("^[\\w.-]+@[\\w.-]+\\.[a-z]{2,}$")`
- Password: `password.length() >= 8 && password.matches(".*\\d.*")`
- Errors shown inline next to each field — no dialog popups, immediate feedback

**Why `MouseAdapter` / `KeyAdapter` instead of implementing the interface directly:**  
`MouseListener` has 5 methods; `KeyListener` has 3. Implementing the interface means writing empty stubs for the ones you don't use. Extending the Adapter gives you the stubs for free — override only what you need:

```java
canvas.addMouseMotionListener(new MouseMotionAdapter() {
    public void mouseDragged(MouseEvent e) {   // only this one matters
        g2d.drawLine(lastX, lastY, e.getX(), e.getY());
        lastX = e.getX(); lastY = e.getY();
        canvas.repaint();
    }
    // mouseEntered, mouseExited, etc. — not needed, adapter provides empty stubs
});
```

**Boundary clamping in `KeyboardMover.java`:**
```java
case KeyEvent.VK_LEFT  -> x = Math.max(0, x - STEP);
case KeyEvent.VK_RIGHT -> x = Math.min(getWidth() - SIZE, x + STEP);
case KeyEvent.VK_UP    -> y = Math.max(0, y - STEP);
case KeyEvent.VK_DOWN  -> y = Math.min(getHeight() - SIZE, y + STEP);
```

---

## Run Commands

```powershell
# From repository root (PowerShell):
.\scripts\run-week4.ps1              # interactive menu
.\scripts\run-week4.ps1 -Launcher   # open GUI dashboard
.\scripts\run-week4.ps1 -All        # launch all 10 activities at once
.\scripts\run-week4.ps1 -Activity 4 # run CounterApp directly
```

```bash
# Git Bash / Linux / macOS:
./scripts/run-week4.sh
./scripts/run-week4.sh --launcher
./scripts/run-week4.sh --all
```
