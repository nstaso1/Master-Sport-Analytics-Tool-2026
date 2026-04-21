# omni-sport-engine
# 🌐 Master Omni-Sport Analytics Engine (2026 Edition)

An elite, multi-platform scouting and live game analytics architecture supporting Baseball, Basketball, Football, Hockey, and Soccer across both Pro and D1 College levels.

Google Site Link Frontend HTML Easy Setup: [https://sites.google.com/view/mysticsglobalsportanalytics?usp=sharing](url)

## 🏗️ System Architecture
This project utilizes a Hub-and-Spoke architecture with Firebase as the central nervous system:
* **Frontend (HTML/JS):** A zero-latency, client-side scouting dashboard for logging live plays, evaluating prospect tool-grades, and running auto-bracket tournament simulations (March Madness, CFP, World Cup).
* **Data Pipeline (Python):** A headless backend script that polls the ESPN/Sportradar APIs and syncs live box scores to the cloud.
* **Front Office (R Shiny):** A cloud-connected dashboard that reads from Firebase to display global recruiting boards in real-time.

## 🚀 Features
* **Omni-Sport Logic:** Custom physics and efficiency algorithms (e.g., KenPom-style Net Efficiency for Basketball, Max EV tracking for Baseball).
* **Live Webhook Sync:** Push live game data straight to Google Sheets or Firebase.
* **Auto-Bracket Simulator:** Uses Monte Carlo-style variance and custom chaos factors to predict tournament outcomes.
* **Data Science Exports:** Export dashboards natively to PDF, JSON, SAS `.sas` files, R scripts, and Python Pandas environments.

## 💻 Setup Instructions
1. **Frontend:** Simply open `frontend_web/index.html` in any modern browser. No build step required. 
2. **Python:** Run `pip install -r backend_python/requirements.txt`, add your Firebase credentials, and run `python espn_live_sync.py`.
3. **R Shiny:** Open `backend_r/app.R` in RStudio, install `shiny` and `httr`, and click "Run App".
