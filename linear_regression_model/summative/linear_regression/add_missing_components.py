import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.linear_model import SGDRegressor
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import mean_squared_error
import joblib

# Load data
df = pd.read_csv('african_crises (1).csv')
df_clean = df.dropna(subset=['inflation_annual_cpi'])

# Feature engineering
country_dummies = pd.get_dummies(df_clean['country'], prefix='country')
df_clean['banking_crisis'] = df_clean['banking_crisis'].map({'crisis': 1, 'no_crisis': 0})
df_clean = pd.concat([df_clean, country_dummies], axis=1)

base_features = ['year', 'systemic_crisis', 'exch_usd', 'domestic_debt_in_default', 
                'sovereign_external_debt_default', 'gdp_weighted_default', 
                'inflation_crises', 'banking_crisis']
country_features = list(country_dummies.columns)
features = base_features + country_features

# Prepare data
X = df_clean[features]
y = df_clean['inflation_annual_cpi']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Train SGD model with loss tracking
sgd_model = SGDRegressor(random_state=42, max_iter=1000, learning_rate='constant', eta0=0.01)

# Track loss during training
train_losses = []
test_losses = []
n_iterations = 100

for i in range(n_iterations):
    sgd_model.partial_fit(X_train_scaled, y_train)
    train_pred = sgd_model.predict(X_train_scaled)
    test_pred = sgd_model.predict(X_test_scaled)
    train_losses.append(mean_squared_error(y_train, train_pred))
    test_losses.append(mean_squared_error(y_test, test_pred))

# Plot loss curve (MANDATORY)
plt.figure(figsize=(10, 6))
plt.plot(range(n_iterations), train_losses, label='Training Loss', color='blue')
plt.plot(range(n_iterations), test_losses, label='Test Loss', color='red')
plt.xlabel('Iterations')
plt.ylabel('Mean Squared Error')
plt.title('Gradient Descent Loss Curve')
plt.legend()
plt.grid(True)
plt.savefig('inflation_gd_loss_curve.png', dpi=300, bbox_inches='tight')
plt.show()

# Scatter plot: True vs Predicted (MANDATORY)
final_predictions = sgd_model.predict(X_test_scaled)
plt.figure(figsize=(10, 6))
plt.scatter(y_test, final_predictions, alpha=0.6, color='green')
plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--', lw=2)
plt.xlabel('True Inflation Rate')
plt.ylabel('Predicted Inflation Rate')
plt.title('True vs Predicted Inflation Rates (Gradient Descent)')
plt.grid(True)
plt.savefig('inflation_true_vs_predicted_scatter.png', dpi=300, bbox_inches='tight')
plt.show()

print("Missing components added successfully!")
print(f"Final Test MSE: {test_losses[-1]:.4f}")
