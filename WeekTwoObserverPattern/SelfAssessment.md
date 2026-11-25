# Week 2 — Self-Assessment

**Course:** Event-Driven Programming in Java  
**Folder:** [`WeekTwoObserverPattern/`](./)  
**Study Guide:** [Logs & Observations/WeekTwoSelfPacedActivity.md](../Logs%20%26%20Observations/WeekTwoSelfPacedActivity.md)

---

## Deliverables

- [x] [`activity1-weather-station/WeatherStationMain.java`](activity1-weather-station/WeatherStationMain.java) — push-model Observer with 3 displays
- [x] [`activity2-legacy-observer/LegacyMain.java`](activity2-legacy-observer/LegacyMain.java) — `java.util.Observer` demo & critique
- [x] [`activity3-custom-observer/TightlyCoupledSystem.java`](activity3-custom-observer/TightlyCoupledSystem.java) — anti-pattern baseline
- [x] [`activity3-custom-observer/RefactoredMain.java`](activity3-custom-observer/RefactoredMain.java) — decoupled observer refactor
- [x] [`activity4-comparison/PropertyChangeDemo.java`](activity4-comparison/PropertyChangeDemo.java) — `PropertyChangeListener` alternative
- [x] [`Week2Launcher.java`](Week2Launcher.java) — GUI launcher for all activities

---

## Learning Outcome 1 — Design & Implement the Observer Pattern

**The minimum Subject interface:**
```java
public interface Subject {
    void registerObserver(Observer o);
    void removeObserver(Observer o);
    void notifyObservers();
}
```

**Why does the Subject need a list?**  
The Observer pattern is a one-to-many relationship. The Subject cannot hardcode references to `CurrentConditionsDisplay`, `StatisticsDisplay`, and `ForecastDisplay` — that defeats the purpose. The list lets it notify any number of observers without knowing their concrete types.

**How `notifyObservers` works:**
```java
@Override
public void notifyObservers() {
    for (Observer o : observers) {
        o.update(temperature, humidity, pressure);
    }
}
```
Called at the end of `setMeasurements(...)` every time sensor data changes.

**UML structure:**
```
«interface»          «interface»
Subject          ◆────────────▷  Observer
registerObserver()   1       *   update(data)
removeObserver()
notifyObservers()
     ▲                              ▲
     │ implements                   │ implements
WeatherData                 CurrentConditionsDisplay
                            StatisticsDisplay
                            ForecastDisplay
```

---

## Learning Outcome 2 — Why `java.util.Observable` Was Deprecated

Three core problems with the legacy API:

**1. `Observable` is a class, not an interface.**  
Java has single inheritance. If your model extends `Observable`, it can't extend anything else — not `JPanel`, not `Thread`, not your own domain class. This kills composition.

**2. `setChanged()` must be called before `notifyObservers()` — silently fails if forgotten.**  
```java
setChanged();          // forget this and nothing gets notified — no error, no warning
notifyObservers(arg);  // silently does nothing
```
This is the most common silent bug with the legacy API.

**3. `update(Observable, Object)` has no type safety.**  
```java
public void update(Observable o, Object arg) {
    LegacyWeatherData data = (LegacyWeatherData) o;  // unsafe downcast required
    float temp = data.getTemperature();               // must pull data manually
}
```
The observer is forced to downcast and call getters — coupling it to the concrete Subject type. The push model (`update(float temp, float humidity, float pressure)`) is strictly better.

**Additional reasons for deprecation:** No guaranteed notification order, weak thread-safety guarantees, no way to filter *which* property changed.

---

## Learning Outcome 3 — Tight Coupling vs. Decoupled Observer

**Tightly coupled (the anti-pattern):**
```java
// DataModel must import and reference every concrete display
public void updateAll(int value) {
    this.barChart.update(value);           // direct method call
    this.currentLabel.setText(String.valueOf(value));
    this.textLogger.log(value);
}
```
Adding a 4th display means editing `DataModel`. This violates Open-Closed Principle.

**Decoupled (the fix):**
```java
// DataModel only knows about the Observer interface
public void notifyObservers() {
    for (DataObserver o : observers) {
        o.onDataChanged(currentValue);
    }
}
```
`BarChartDisplay`, `LabelDisplay`, `TextLogger` all implement `DataObserver` and self-register. `DataModel` never imports any of them.

**Preventing memory leaks:**  
The Subject holds strong references to all registered observers. If a panel is closed but never unregistered, the GC cannot reclaim it:
```java
// Always unregister when the observer is no longer needed
weatherData.removeObserver(forecastDisplay);
```

---

## Learning Outcome 4 — Comparing Notification Mechanisms

| Mechanism | Type-safe? | Built-in JDK? | Old & new value? | Bindable to UI? |
| :--- | :---: | :---: | :---: | :---: |
| **Custom Observer interface** | ✅ | ❌ | Optional | No |
| **`java.util.Observer`** | ❌ | ✅ (deprecated) | ❌ | No |
| **`PropertyChangeListener`** | Partial | ✅ | ✅ | No |
| **JavaFX Properties** | ✅ | ✅ (JavaFX) | ✅ | ✅ |

**Which is best for JavaFX?**  
JavaFX Properties (`StringProperty`, `IntegerProperty`, etc.) — they support `ChangeListener`, `InvalidationListener`, and `.bind()` / `.bindBidirectional()` natively. No custom boilerplate.

**Which is deprecated?**  
`java.util.Observer` (interface) and `java.util.Observable` (class) — deprecated since Java 9. Never use in new code.

**Pull model vs. push model:**

| | Push | Pull |
| :--- | :--- | :--- |
| Data delivery | Sent directly in `update(data)` args | Observer calls getters on the Subject |
| Coupling | Low — observer doesn't need Subject type | High — observer must know Subject's API |
| Preferred? | ✅ Yes | ❌ Avoid |

---

## Key Insight

The Observer pattern's power isn't in `notifyObservers()` — it's in the fact that `WeatherData` has zero `import` statements for any display class. The Subject is completely blind to its observers. That blindness *is* the architecture.
