# Event-Driven Programming in Java

This repo is my 10-week Event-Driven Programming coursework from **Riara University**—a collection of hands-on labs, study notes, and mini-apps tracking my progression from basic event loops to full desktop GUIs.

It starts with the fundamentals (procedural vs. event-driven code and the Observer Pattern), moves through building and wiring **Swing** interfaces, transitions into modern **JavaFX** with FXML, bindings, and background tasks, and wraps up with a Week 10 **University Management System** capstone connected to a cloud PostgreSQL database on Neon.

---

## Requirements

- **Java JDK 11+** (JDK 17 or 21 recommended)
- **Maven** — needed for JavaFX weeks (6–10). Weeks 6–9 include a Maven Wrapper (`mvnw` / `mvnw.cmd`) so you can run them without a system-wide Maven install.
- Check your setup:
  ```bash
  java -version
  javac -version
  # Maven system install (optional — wrapper covers Weeks 6-9):
  mvn -version
  ```

---

## Quick Start

### 1. Build Everything
Compile all Java files across the repo:

| Shell | Command | Clean Rebuild |
| :--- | :--- | :--- |
| **Git Bash / macOS / Linux** | `./build` | `./build --clean` |
| **Windows CMD / PowerShell** | `.\build.bat` | `.\build.bat --clean` |
| **PowerShell script / Direct CLI** | `.\scripts\build.ps1` | `java scripts/AgentCLI.java build --clean` |

### 2. Run the Interactive Menu
The easiest way to run any week's activities:

- **Git Bash / macOS / Linux:**
  ```bash
  ./scripts/run-all.sh
  ```
- **Windows PowerShell:**
  ```powershell
  .\scripts\run-all.ps1
  ```

> **Note for Git Bash users on Windows:** Always use forward slashes (`./scripts/...`), never backslashes (`.\scripts\...`).

### 3. Run a Visual Launcher Directly
For Weeks 2–5, you can open a week's GUI dashboard directly:
```bash
java -cp WeekTwoObserverPattern Week2Launcher
java -cp WeekThreeSwingGui Week3Launcher
java -cp WeekFourEventHandling Week4Launcher
java -cp WeekFiveAdvancedSwing Week5Launcher
```

For Weeks 6–10 (JavaFX + Maven):
```bash
mvn -f WeekSixJavaFX/pom.xml javafx:run
mvn -f WeekSevenJavaFXEvents/pom.xml javafx:run
mvn -f WeekEightJavaFXBindings/pom.xml javafx:run
mvn -f WeekNineAsyncJavaFX/pom.xml javafx:run
mvn -f WeekTenUniversitySystem/pom.xml javafx:run
```

---

## Course Modules (Weeks 1–10)

| Week | Topic | Code Folder | Study Guide | Quick Script |
| :--- | :--- | :--- | :--- | :--- |
| **1** | Event-Driven Basics & Bug Fixes | [`WeekOneEventDrivenBasics/`](WeekOneEventDrivenBasics/) | [Week 1 Guide](Logs%20%26%20Observations/WeekOneSelfPacedActivity.md) | `./scripts/run-week1.sh` / `.\scripts\run-week1.ps1` |
| **2** | Observer Pattern | [`WeekTwoObserverPattern/`](WeekTwoObserverPattern/) | [Week 2 Guide](Logs%20%26%20Observations/WeekTwoSelfPacedActivity.md) | `./scripts/run-week2.sh` / `.\scripts\run-week2.ps1` |
| **3** | Swing GUI & Layouts | [`WeekThreeSwingGui/`](WeekThreeSwingGui/) | [Week 3 Guide](Logs%20%26%20Observations/WeekThreeSelfPacedActivity.md) | `./scripts/run-week3.sh` / `.\scripts\run-week3.ps1` |
| **4** | Event Handling in Swing | [`WeekFourEventHandling/`](WeekFourEventHandling/) | [Week 4 Guide](Logs%20%26%20Observations/WeekFourSelfPacedActivity.md) | `./scripts/run-week4.sh` / `.\scripts\run-week4.ps1` |
| **5** | Advanced Swing (`JTable`, Menus, Dialogs) | [`WeekFiveAdvancedSwing/`](WeekFiveAdvancedSwing/) | [Week 5 Guide](Logs%20%26%20Observations/WeekFiveAdvancedSwingComponents.md) | `./scripts/run-week5.sh` / `.\scripts\run-week5.ps1` |
| **6** | Intro to Modern JavaFX | [`WeekSixJavaFX/`](WeekSixJavaFX/) | [Week 6 Guide](Logs%20%26%20Observations/WeekSixIntroToJavaFX.md) | `./scripts/run-week6.sh` / `.\scripts\run-week6.ps1` |
| **7** | Event Handling in JavaFX | [`WeekSevenJavaFXEvents/`](WeekSevenJavaFXEvents/) | [Week 7 Guide](Logs%20%26%20Observations/WeekSevenJavaFXEventHandling.md) | `./scripts/run-week7.sh` / `.\scripts\run-week7.ps1` |
| **8** | JavaFX Properties & Bindings | [`WeekEightJavaFXBindings/`](WeekEightJavaFXBindings/) | [Week 8 Guide](Logs%20%26%20Observations/WeekEightJavaFXPropertiesAndBindings.md) | `./scripts/run-week8.sh` / `.\scripts\run-week8.ps1` |
| **9** | Async Programming in JavaFX | [`WeekNineAsyncJavaFX/`](WeekNineAsyncJavaFX/) | [Week 9 Guide](Logs%20%26%20Observations/WeekNineAsyncJavaFX.md) | `./scripts/run-week9.sh` / `.\scripts\run-week9.ps1` |
| **10** | Capstone: University Management System | [`WeekTenUniversitySystem/`](WeekTenUniversitySystem/) | [Week 10 Guide](Logs%20%26%20Observations/WeekTenUniversitySystemCapstone.md) | `./scripts/run-university.sh` / `.\scripts\run-university.ps1` |

### Script Flags
Each week script supports:
- `--all` / `-All` — Run all activities for that week
- `--launcher` / `-Launcher` — Open the visual GUI launcher (Weeks 2–9)

---

## Week 10 Capstone: University Management System

A JavaFX desktop app backed by **PostgreSQL on Neon**.

> **Note:** The University System uses **Neon (serverless cloud PostgreSQL)** instead of a local MySQL server because I wanted to try out Neon and make the app runnable without requiring a local database installation.

### Prerequisites (`.env` Setup)
1. Create a free database at [neon.tech](https://neon.tech) and copy your connection string.
2. Copy [`.env.example`](.env.example) to `.env` (or `.env.local`) in the repo root and set `DATABASE_URL`:
   ```env
   DATABASE_URL="postgresql://USER:PASSWORD@YOUR-NEON-HOST.neon.tech/neondb?sslmode=require"
   ```
   *(Tables `programs` and `students` plus sample programs are created automatically on first run.)*

### Run & Test
- **Launch the app:**
  ```bash
  mvn -f WeekTenUniversitySystem/pom.xml javafx:run
  ```
  Or `.\scripts\run-university.ps1` / `./scripts/run-university.sh`
- **Run database integration test:**
  ```bash
  .\scripts\run-university.ps1 -Test
  ```
  Or `./scripts/run-university.sh --test`
- **Seed sample students:**
  ```bash
  .\scripts\run-university.ps1 -Seed
  ```
  Or `./scripts/run-university.sh --seed`

---

## Running Single Files Manually

You can also compile and run any single Java activity (Weeks 1–5) from the repo root:
```bash
javac <folder>/<FileName>.java
java -cp <folder> <MainClassName>
```

Example:
```bash
javac WeekOneEventDrivenBasics/EventDrivenCalculator.java
java -cp WeekOneEventDrivenBasics EventDrivenCalculator
```

---


