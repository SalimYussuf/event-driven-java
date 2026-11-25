# Week 3 — Self-Assessment

**Course:** Event-Driven Programming in Java  
**Folder:** [`WeekThreeSwingGui/`](./)  
**Study Guide:** [Logs & Observations/WeekThreeSelfPacedActivity.md](../Logs%20%26%20Observations/WeekThreeSelfPacedActivity.md)

---

## Deliverables

- [x] [`activity1-first-window/FirstWindow.java`](activity1-first-window/FirstWindow.java) — `JFrame` with `EXIT_ON_CLOSE`
- [x] [`activity2-basic-components/ComponentShowcase.java`](activity2-basic-components/ComponentShowcase.java) — 8-widget tour
- [x] [`activity3-layout-managers/FlowLayoutDemo.java`](activity3-layout-managers/FlowLayoutDemo.java)
- [x] [`activity3-layout-managers/BorderLayoutDemo.java`](activity3-layout-managers/BorderLayoutDemo.java)
- [x] [`activity3-layout-managers/GridLayoutDemo.java`](activity3-layout-managers/GridLayoutDemo.java)
- [x] [`activity3-layout-managers/CombinedLayoutDemo.java`](activity3-layout-managers/CombinedLayoutDemo.java) — nested layouts
- [x] [`activity4-edt-rule/FreezeDemo.java`](activity4-edt-rule/FreezeDemo.java) — EDT freeze anti-pattern
- [x] [`activity4-edt-rule/FixedDemo.java`](activity4-edt-rule/FixedDemo.java) — `SwingWorker` fix
- [x] [`activity5-complete-mockup/StudentPortal.java`](activity5-complete-mockup/StudentPortal.java) — full static UI

---

## Learning Outcome 1 — Creating a Functional Swing Window

**Minimal correct window (from memory):**
```java
SwingUtilities.invokeLater(() -> {
    JFrame frame = new JFrame("My App");
    frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    frame.setSize(600, 400);
    frame.setLocationRelativeTo(null);   // centres on screen
    frame.setVisible(true);
});
```

**What is the difference between `JFrame` and the content pane?**  
`JFrame` is the OS-level window (title bar, borders, close button). The content pane is the drawable surface inside it. `frame.add(comp)` is shorthand for `frame.getContentPane().add(comp)`.

**Why `EXIT_ON_CLOSE`?**  
Without it, clicking the close button hides the window but the JVM process keeps running in the background. The process never terminates unless killed manually.

**Why `SwingUtilities.invokeLater`?**  
Swing is not thread-safe. Creating components on the main thread risks race conditions with the painting system. `invokeLater` posts the creation onto the EDT so all UI code runs on the same dedicated thread.

---

## Learning Outcome 2 — Components & Layout Managers

**Core Swing components and their use:**

| Component | Use |
| :--- | :--- |
| `JLabel` | Static text or image |
| `JTextField` | Single-line text input |
| `JPasswordField` | Password (masks characters) |
| `JCheckBox` | Boolean toggle — independent |
| `JRadioButton` + `ButtonGroup` | Mutually exclusive options |
| `JComboBox<T>` | Drop-down selection |
| `JTextArea` + `JScrollPane` | Multi-line editable text |
| `JButton` | Click trigger |

**Why do `JRadioButton`s need a `ButtonGroup`?**  
Without it, radio buttons act like independent checkboxes — multiple can be selected. `ButtonGroup` enforces mutual exclusion: selecting one deselects all others in the group.

**Layout managers:**

| Layout | Behaviour | Real use |
| :--- | :--- | :--- |
| `FlowLayout` | Left-to-right, wraps to next row | Toolbars, button bars |
| `BorderLayout` | 5 regions: N, S, E, W, CENTER | Main application shell |
| `GridLayout(r, c)` | Equal-sized cells in a grid | Calculator keypads |
| **Nested panels** | Combine any of the above | Almost every real app |

**What is special about `BorderLayout.CENTER`?**  
N, S, E, W preserve their preferred height or width. CENTER claims *all remaining space* in both dimensions and resizes with the window.

**Why nest layout managers?**  
No single layout covers all needs. A real app uses `BorderLayout` for the frame, `GridLayout` for the keypad, `FlowLayout` for the button row — each `JPanel` picks the layout that fits its content.

**Why avoid `setBounds(x, y, w, h)` everywhere?**  
Hardcoded pixel positions break when the window is resized, the OS font scaling changes, or the screen resolution differs. Layout managers calculate positions at runtime and adapt automatically.

---

## Learning Outcome 3 — The EDT Rule

**Two threading rules in Swing:**

1. All Swing component creation, modification, and event handling must run **on the EDT**.
2. Never run long-running work (network, database, `Thread.sleep`) on the EDT — offload to a background thread.

**What happens if you violate Rule 1?**  
Race conditions, visual corruption, stale renders, intermittent `NullPointerException`s or `IllegalStateException`s. Swing components are not thread-safe.

**FreezeDemo vs. FixedDemo — observed comparison:**

| Metric | `FreezeDemo` | `FixedDemo` |
| :--- | :--- | :--- |
| Blocking thread | EDT (`AWT-EventQueue-0`) | Worker `Thread-0` |
| Window during wait | Frozen, white, unresponsive | Fully interactive |
| Window drag | Impossible | Smooth |
| Button state | Stuck — never shows "Working..." | Disables then re-enables |

**`SwingWorker` structure used in `FixedDemo`:**
```java
new SwingWorker<Void, Void>() {
    protected Void doInBackground() throws Exception {
        Thread.sleep(3000);   // runs on background thread — EDT is free
        return null;
    }
    protected void done() {
        statusLabel.setText("Done!");  // back on EDT automatically
        button.setEnabled(true);
    }
}.execute();
```

**How do you safely update a label from a background thread?**  
```java
SwingUtilities.invokeLater(() -> myLabel.setText("Updated"));
```

---

## Learning Outcome 4 — Static UI Layout (StudentPortal)

**How many layout managers did `StudentPortal` use?**  
At least four: `BorderLayout` (outer frame and header), `GridLayout` (metric cards, sidebar buttons), `BoxLayout` (vertical content stack), `FlowLayout` (button rows).

**What does `Box.createVerticalStrut(20)` do?**  
Creates an invisible rigid component with a fixed height of 20px and zero width — provides consistent vertical spacing between items in a `BoxLayout`.

**Why `setPreferredSize` on the sidebar?**  
`BorderLayout.WEST` stretches the sidebar to fill vertical space but respects its preferred *width*. Setting `new Dimension(180, 0)` pins the sidebar at exactly 180px wide without it collapsing or expanding.
