import pandas as pd
import json
import statsmodels.api as sm

# 1. Load the exported JSON database from the Mystics Dashboard
print("Loading Mystics Analytics Database...")
with open('MysticsAnalytics_Save.json', 'r') as file:
    data = json.load(file)

# 2. Extract Pickleball Data (Combining Minor League and Pro League for a larger sample)
pbl_minor = data['masterDB']['minor']['pbl']
pbl_pro = data['masterDB']['proleague']['pbl']
df = pd.DataFrame(pbl_minor + pbl_pro)

# 3. Define our Variables
# X = Independent Variables (DUPR, 3rd Shot Drop %, Kitchen Reset %)
# Y = Dependent Variable (Overall Draft Score)
X = df[['p1', 'p2', 'p3']] 
y = df['score']

# Add a constant to the model (the y-intercept)
X = sm.add_constant(X)

# 4. Fit the Ordinary Least Squares (OLS) Regression Model
print("Running Multiple Linear Regression Model for Pickleball Readiness...\n")
model = sm.OLS(y, X).fit()

# 5. Output the full statistical summary
print(model.summary())
