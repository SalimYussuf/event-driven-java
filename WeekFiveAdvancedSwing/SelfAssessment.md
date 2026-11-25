# Week 5 — Self-Assessment

**Course:** Event-Driven Programming in Java  
**Folder:** [`WeekFiveAdvancedSwing/`](./)  
**Study Guide:** [Logs & Observations/WeekFiveAdvancedSwingComponents.md](../Logs%20%26%20Observations/WeekFiveAdvancedSwingComponents.md)

---

## Deliverables

- [x] [`activity1-jlist-renderer/ContactListDemo.java`](activity1-jlist-renderer/ContactListDemo.java) — custom `ListCellRenderer`
- [x] [`activity2-jtable/StudentTableDemo.java`](activity2-jtable/StudentTableDemo.java) — `JTable` with sorting and filtering
- [x] [`activity3-jtree-tabs/FileExplorerDemo.java`](activity3-jtree-tabs/FileExplorerDemo.java) — `JTree` + `JTabbedPane` + `JSplitPane`
- [x] [`activity4-menus-dialogs/MiniEditor.java`](activity4-menus-dialogs/MiniEditor.java) — `JMenuBar`, `JToolBar`, `JFileChooser`
- [x] [`activity5-capstone-file-manager/FileManager.java`](activity5-capstone-file-manager/FileManager.java) — full desktop file manager

---

## Learning Outcome 1 — Advanced Components & Their Models

The key insight across `JList`, `JTable`, and `JTree`: **the data lives in the Model, not the View.** Change the model and the UI updates automatically.

| Component | Model class | How to add data | How to remove data |
| :--- | :--- | :--- | :--- |
| `JList<E>` | `DefaultListModel<E>` | `model.addElement(item)` | `model.remove(index)` |
| `JTable` | `DefaultTableModel` | `model.addRow(Object[])` | `model.removeRow(index)` |
| `JTree` | `DefaultTreeModel` | `model.insertNodeInto(node, parent, idx)` | `model.removeNodeFromParent(node)` |

**Why `JList` and `JTable` must be in a `JScrollPane`:**  
They have no built-in scroll mechanism. `JTable` additionally renders its column headers inside the `JScrollPane`'s `columnHeader` viewport — without it, headers don't appear at all.

**What `JSplitPane` does:**  
Places two components side by side (or stacked) with a draggable divider. The user can resize either panel. Set the initial split with `setDividerLocation(...)` *after* `frame.setVisible(true)` — it has no effect before the component is laid out.

---

## Learning Outcome 2 — Custom Renderers & Visual Styling

**How Swing renders lists and tables — the Flyweight / stamp pattern:**  
Swing doesn't create a separate component for each row. It uses a *single* renderer component, stamps it onto each row during painting, then reuses it for the next row. This is why the renderer's `getListCellRendererComponent` and `getTableCellRendererComponent` methods are called repeatedly.

**Custom `ListCellRenderer` in `ContactListDemo.java`:**
```java
public Component getListCellRendererComponent(JList<? extends Contact> list,
        Contact value, int index, boolean isSelected, boolean cellHasFocus) {
    JPanel row = new JPanel(new BorderLayout());
    row.add(new JLabel(value.name()), BorderLayout.WEST);
    JLabel badge = new JLabel(value.status());
    badge.setBackground(value.isOnline() ? Color.GREEN : Color.GRAY);
    badge.setOpaque(true);
    row.add(badge, BorderLayout.EAST);
    if (isSelected) row.setBackground(list.getSelectionBackground());
    return row;
}
```

**Custom `TableCellRenderer` for conditional GPA colouring:**
```java
public Component getTableCellRendererComponent(...) {
    Component c = super.getTableCellRendererComponent(...);
    if (value instanceof Double gpa && gpa < 3.0) {
        c.setForeground(Color.RED);
    } else {
        c.setForeground(table.getForeground());
    }
    return c;
}
```
The renderer inspects the cell value and sets the colour — it doesn't modify the underlying `DefaultTableModel` data.

---

## Learning Outcome 3 — `JTable` Sorting & Filtering

**`TableRowSorter` + `RowFilter` — the full setup:**
```java
DefaultTableModel model = new DefaultTableModel(columns, 0);
JTable table = new JTable(model);
TableRowSorter<DefaultTableModel> sorter = new TableRowSorter<>(model);
table.setRowSorter(sorter);

// Click column headers to sort ↑↓ — zero extra code

// Live filter wired to a search field:
searchField.getDocument().addDocumentListener(new DocumentListener() {
    public void insertUpdate(DocumentEvent e) { filter(); }
    public void removeUpdate(DocumentEvent e) { filter(); }
    public void changedUpdate(DocumentEvent e) {}
    void filter() {
        String text = searchField.getText();
        sorter.setRowFilter(text.isEmpty() ? null : RowFilter.regexFilter("(?i)" + text));
    }
});
```

**Why add rows to `DefaultTableModel` instead of directly to `JTable`?**  
`JTable` is the view — it has no row storage. `DefaultTableModel` stores the data and fires `TableModelEvent` to notify `JTable` to repaint. Calling `model.addRow(...)` is the correct path; calling `table.repaint()` manually is almost always wrong.

---

## Learning Outcome 4 — Menus, Toolbars & Multi-Pane Event Coordination

**`JMenuBar` accelerator setup:**
```java
JMenuItem openItem = new JMenuItem("Open");
openItem.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_O, InputEvent.CTRL_DOWN_MASK));
openItem.addActionListener(e -> openFile());
fileMenu.add(openItem);
```
Accelerators registered via `setAccelerator` work globally across the whole window — the menu system handles propagation automatically.

**`JFileChooser` correct usage:**
```java
JFileChooser chooser = new JFileChooser();
chooser.setFileFilter(new FileNameExtensionFilter("Text files", "txt"));
int result = chooser.showOpenDialog(frame);
if (result == JFileChooser.APPROVE_OPTION) {
    File selected = chooser.getSelectedFile();
    // load file...
}
```
Always check `APPROVE_OPTION` — the dialog returns `CANCEL_OPTION` if the user clicks Cancel or closes the dialog.

**`TreeSelectionListener` bridging `JTree` → `JTable` in `FileManager`:**
```java
tree.addTreeSelectionListener(e -> {
    DefaultMutableTreeNode node = (DefaultMutableTreeNode)
        tree.getLastSelectedPathComponent();
    if (node == null) return;
    loadFilesIntoTable(node.getUserObject().toString());
});
```
Double-click to drill into a folder is handled with `MouseAdapter`:
```java
table.addMouseListener(new MouseAdapter() {
    public void mouseClicked(MouseEvent e) {
        if (e.getClickCount() == 2) openSelectedFolder();
    }
});
```

---

## Run Commands

```powershell
# PowerShell (from repository root):
.\scripts\run-week5.ps1
.\scripts\run-week5.ps1 -Launcher
.\scripts\run-week5.ps1 -All
```

```bash
# Git Bash / Linux / macOS:
./scripts/run-week5.sh
./scripts/run-week5.sh --launcher
```
