# 📊 Eidra Data Trainee Case – Analysis Project

## 🧠 Overview

This project is part of a case study for the **Eidra Data Trainee role at Curamando**. The objective is to analyse consulting performance across multiple operating companies (opcos) using data from Google BigQuery.

The analysis focuses on two key business metrics:

* **Chargeability** – how much of available consultant time is billable
* **Revenue Attribution** – how invoiced revenue is distributed across consultants

The goal is not just to compute these metrics, but to extract **business insights and actionable recommendations**.

---

## 📂 Project Structure

```
├── notebooks/
│   └── analysis.ipynb        # Main analysis & visualisations
├── sql/
│   ├── chargeability.sql     # Chargeability query
│   ├── revenue_attribution.sql
│   └── revenue_diff.sql      # Theoretical vs actual revenue
├── outputs/
│   ├── charts/               # Exported visualisations
│   └── slides.pptx           # Final presentation
├── README.md
└── requirements.txt
```

---

## ⚙️ Setup

### 1. Create virtual environment

```bash
python -m venv .venv
```

### 2. Activate environment

**Windows (Git Bash):**

```bash
source .venv/Scripts/activate
```

**Windows (PowerShell):**

```powershell
.venv\Scripts\Activate.ps1
```

---

### 3. Install dependencies

```bash
pip install pandas seaborn matplotlib pandas-gbq jupyter
```

---

### 4. Connect to BigQuery

Make sure you are authenticated:

```bash
gcloud auth application-default login
```

---

## 📊 Data Sources

The dataset is hosted in **Google BigQuery**:

* **Project:** `eidra-df-case`
* **Dataset:** `eidra_data_trainee`

### Tables used:

* `employees`
* `time_entries`
* `projects`
* `clients`
* `billing_rates`
* `invoiced_revenue`
* `calendar`

---

## 📈 Key Analyses

### 1. Chargeability

* Calculated as:

```
Chargeability = Billable Hours / (Available Hours - Absence)
```

* Adjusted for:

  * working days per country
  * public holidays
  * employee start/end dates
  * absence

---

### 2. Revenue Attribution

Steps:

1. Calculate **theoretical revenue**:

   ```
   hours × billing rate
   ```
2. Aggregate by:

   * client
   * opco
   * month
3. Compare with:

   * actual invoiced revenue

---

### 3. Revenue Gap Analysis

Key metrics:

* **Revenue Gap**

  ```
  Actual - Theoretical
  ```
* **Revenue Ratio**

  ```
  Actual / Theoretical
  ```

---

## 🔍 Key Insights

### 1. Structural Pricing Differences

* Some clients (e.g. IKEA, Volvo) are consistently **underbilled**
* Others (e.g. Spotify) are consistently **overperforming**

👉 Indicates differences in:

* pricing strategy
* contract structure
* delivery efficiency

---

### 2. Revenue Concentration Risk

* A small number of clients (e.g. Equinor, Volvo) contribute a large share of revenue

👉 Business is exposed to **client dependency risk**

---

### 3. Senior Role Dynamics

* Senior consultants (Principals) show **lower chargeability**

👉 Likely due to:

* sales work
* leadership responsibilities
* internal contributions

---

### 4. Scale Amplifies Impact

* Large clients drive the majority of revenue gaps

👉 Small inefficiencies → large financial impact

---

## 📊 Visualisations

Created using **Seaborn & Matplotlib**:

* Chargeability distribution (with median)
* Revenue ratio over time (per client)
* Revenue gap trends
* Revenue share by opco
* Top contributors per client

---

## 💡 Recommendations

### 1. Pricing Optimisation

* Review contracts for underperforming clients
* Introduce pricing governance

---

### 2. Risk Mitigation

* Reduce dependency on large clients
* Diversify client portfolio

---

### 3. Performance Measurement

* Adjust KPIs for senior roles
* Track revenue contribution beyond utilisation

---

### 4. Forecasting Improvements

* Use historical revenue gaps to improve accuracy

---

## 🧪 Tools Used

* **Python**

  * pandas
  * seaborn
  * matplotlib
* **SQL (BigQuery)**
* **VS Code / Jupyter Notebook**

---

## 🧠 Key Learnings

* Importance of separating:

  * operational metrics (chargeability)
  * financial metrics (revenue)
* Handling imperfect and real-world data
* Translating data into business insights

---

## 🚀 Next Steps

* Add currency normalization (SEK, NOK, EUR)
* Build predictive models for utilisation
* Automate reporting dashboards

---

## 📬 Author

**Mark Peters**
Data Analyst / Aspiring Data Scientist
