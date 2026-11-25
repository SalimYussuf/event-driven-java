# Week 1 — Self-Assessment

**Course:** Event-Driven Programming in Java  
**Folder:** [`WeekOneEventDrivenBasics/`](./)  
**Study Guide:** [Logs & Observations/WeekOneSelfPacedActivity.md](../Logs%20%26%20Observations/WeekOneSelfPacedActivity.md)

---

## Deliverables

- [x] [`ProceduralCalculator.java`](ProceduralCalculator.java) — sequential console calculator
- [x] [`EventDrivenCalculator.java`](EventDrivenCalculator.java) — Swing GUI calculator
- [x] [`SmartHomePrototype.java`](SmartHomePrototype.java) — multi-sensor event-driven Swing app
- [x] [`BugFixChallenge/Bug1_BlockingEDT.java`](BugFixChallenge/Bug1_BlockingEDT.java) — EDT freeze fix
- [x] [`BugFixChallenge/Bug2_MissingListener.java`](BugFixChallenge/Bug2_MissingListener.java) — unwired listener fix
- [x] [`BugFixChallenge/Bug3_WrongThread.java`](BugFixChallenge/Bug3_WrongThread.java) — wrong-thread UI update fix
- [x] [`BugFixChallenge/Bug4_MemoryLeak.java`](BugFixChallenge/Bug4_MemoryLeak.java) — listener list memory leak fix

---

## Learning Outcome 1 — The Four Core Parts

**What is an event?**  
An object representing something that happened — a button click, a key press, a timer firing. In Swing: `ActionEvent`, `KeyEvent`, `MouseEvent`.

**What is an event source?**  
The component that detected the user action and created the event. `JButton`, `JTextField`, `javax.swing.Timer`.

**What is an event listener?**  
An interface registered with a source to be notified when that event occurs. `ActionListener`, `MouseListener`, `KeyListener`.

**What is an event handler?**  
The code that runs when the notification arrives — the body of `actionPerformed(e)`, or a lambda `e -> label.setText("Done")`.

**How they connect:**
```
JButton (source)
  │ fires ActionEvent
  ▼
ActionListener.actionPerformed(e)   ← registered via addActionListener(...)
  │ runs
  ▼
Handler code — updates label, opens dialog, etc.
```

**Can one source have multiple listeners?**  
Yes. A "Submit" button can have a listener that disables it, another that validates inputs, and another that logs analytics — all wired independently.

**Can one listener handle multiple sources?**  
Yes. A single `ActionListener` attached to `btnSave`, `btnCancel`, and `btnHelp` uses `e.getSource()` or `e.getActionCommand()` to decide which branch to run.

---

## Learning Outcome 2 — Procedural vs. Event-Driven

| Aspect | `ProceduralCalculator.java` | `EventDrivenCalculator.java` |
| :--- | :--- | :--- |
| **Who controls flow?** | The program — dictates prompt order | The user — clicks in any order |
| **Execution model** | Blocks at `Scanner.nextLine()` waiting for input | Idle until an event fires |
| **Error recovery** | Restart required on bad input | Press Clear and try again |
| **Code structure** | One linear `main()` | Decoupled button handlers |

**When would I choose procedural over event-driven?**  
Batch scripts, data transformations, compiler pipelines — anything with a defined input, a single execution pass, and no user interaction mid-run.

---

## Learning Outcome 3 — The Event Loop & the EDT

**What is the event queue?**  
A FIFO buffer that holds pending events (clicks, key presses, timer ticks, paint requests) while the current handler is running. Nothing is lost.

**What is the event loop?**  
A background process that continuously pulls the next event off the queue and routes it to the registered listener. In Swing, this is the **Event Dispatch Thread (EDT)**.

**Why must the EDT never be blocked?**  
The EDT handles *everything* — drawing, resizing, clicking, all events. If it's sleeping or waiting on a network call, nothing else can happen. The window goes white, the OS marks it "Not Responding".

**The correct pattern for slow work:**
```java
new Thread(() -> {
    String result = fetchFromDatabase();             // background thread
    SwingUtilities.invokeLater(() ->
        label.setText(result)                        // back on EDT
    );
}).start();
```

---

## Learning Outcome 4 — Bug Fixes

| Bug | Root Cause | Fix |
| :--- | :--- | :--- |
| **Bug 1 — Blocking EDT** | `Thread.sleep(5000)` inside `actionPerformed` | Move work to background thread; update label with `invokeLater` |
| **Bug 2 — Missing Listener** | Button created but `addActionListener` never called | `button.addActionListener(e -> count++)` |
| **Bug 3 — Wrong Thread** | Background thread calls `label.setText(...)` directly | `SwingUtilities.invokeLater(() -> label.setText(text))` |
| **Bug 4 — Memory Leak** | Buttons removed from panel but `createdButtons` list never cleared | `createdButtons.clear()` when clearing the UI |

**Bug 2 observation:** This is easy to miss during development. Creating the button and wiring it are two separate steps — it's silent until you notice the click does nothing.

---

## Learning Outcome 5 — Real-World Event-Driven Systems

Five systems that are event-driven at their core:

1. **Web browser** — DOM click, scroll, network load events
2. **Car ECU** — throttle sensor, ABS brake trigger, door open signal
3. **Smartphone OS** — touch gestures, push notifications, GPS updates
4. **Stock exchange engine** — order submitted event, price match event
5. **Smart home alarm** — motion sensor trigger, door contact switch, keypad input

**SmartHomePrototype breakdown:**

| Component | Role |
| :--- | :--- |
| Toggle buttons | Event sources |
| `ActionListener` lambdas | Listeners |
| Label updates | Handlers — change state display |
| `JPanel` | View layer — holds all sources |

---

## Three Threading Rules — Memorised

1. **Never block the EDT.** Long work belongs on a background thread.
2. **Never touch Swing components from outside the EDT.** Wrap every UI update in `SwingUtilities.invokeLater(...)`.
3. **Clean up listeners.** Remove them when the component is destroyed to avoid memory leaks.
