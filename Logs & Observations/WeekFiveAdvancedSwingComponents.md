# Week 5: Advanced Swing Components

**Folder:** [`WeekFiveAdvancedSwing/`](../WeekFiveAdvancedSwing/)  
**Run GUI Launcher:** `java -cp WeekFiveAdvancedSwing Week5Launcher`  
**Scripts:** `./scripts/run-week5.sh` (Git Bash/Linux/macOS) or `.\scripts\run-week5.ps1` (PowerShell)

---

## Goals

By the end of Week 5, you should be able to:
- [ ] Build scrollable lists with `JList` and custom `ListCellRenderer`s.
- [ ] Display and edit tabular data with `JTable` and `DefaultTableModel`.
- [ ] Organize views using `JTree` and `JTabbedPane`.
- [ ] Add menus (`JMenuBar`), toolbars (`JToolBar`), and file/message dialogs (`JOptionPane`, `JFileChooser`).

---

## Core Concepts (In Plain English)

- **Model vs. View:** Components like `JList`, `JTable`, and `JTree` separate *data* (the Model, e.g. `DefaultTableModel`) from *display* (the View). To add or remove rows, update the model â€” the UI updates automatically.
- **Custom Renderers:** By default, `JList` calls `.toString()` on each item. A custom `ListCellRenderer` lets you return any `JPanel` (with icons, colors, or bold text) for each row.
- **Dialogs:**
  - `JOptionPane.showMessageDialog(...)` â€” Pop up alerts or confirmations.
  - `JFileChooser` â€” Standard Open / Save file picker.

---

## Activities

### Activity 1: `JList` & Custom Renderer (`activity1-jlist-renderer/`)
`ContactListDemo.java` â€” Displays a contact list where each row shows a name, email, and status badge using a custom `ListCellRenderer`.

### Activity 2: `JTable` & Table Models (`activity2-jtable/`)
`StudentTableDemo.java` â€” Shows student records in a sortable `JTable` backed by a `DefaultTableModel`, with buttons to add and delete rows.

### Activity 3: `JTree` & `JTabbedPane` (`activity3-jtree-tabs/`)
`FileExplorerDemo.java` â€” Combines a folder tree (`JTree`) on the left with a tabbed viewer (`JTabbedPane`) on the right inside a `JSplitPane`.

### Activity 4: Menus, Toolbars & Dialogs (`activity4-menus-dialogs/`)
`MiniEditor.java` â€” A mini text editor with a `JMenuBar` (File/Edit/Help), a `JToolBar`, keyboard accelerators (`Ctrl+S`, `Ctrl+O`), and `JFileChooser` to open/save files.

### Activity 5: Capstone File Manager (`activity5-capstone-file-manager/`)
`FileManager.java` â€” Combines `JTree`, `JTable`, `JMenuBar`, `JToolBar`, and dialogs into a working desktop file browser.

---

## Self-Check

1. **Why add rows to `DefaultTableModel` instead of `JTable` directly?**
   `JTable` only draws data; `DefaultTableModel` holds the rows and notifies the table to repaint when data changes.
2. **What does `JSplitPane` do?**
   It divides two components with a draggable divider bar.
3. **Why put `JList` or `JTable` inside a `JScrollPane`?**
   They don't scroll on their own, and `JTable` won't even show its column headers unless it's wrapped in a `JScrollPane`.

See [`WeekFiveAdvancedSwing/SelfAssessment.md`](../WeekFiveAdvancedSwing/SelfAssessment.md) for the full self-assessment.
