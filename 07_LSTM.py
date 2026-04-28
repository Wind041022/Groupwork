import pandas as pd
import numpy as np
import torch
import torch.nn as nn
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score

df = pd.read_csv('preprocessed_data.csv')

train_df = df[(df['Date'] >= '2021-01-03') & (df['Date'] <= '2024-12-31')]
test_df = df[(df['Date'] >= '2025-01-01') & (df['Date'] <= '2025-12-31')]

continuous_vars = ["Avg_Temp_1", "Avg_Temp_2", "Pressure_1", "Pressure_2", "Dew_point_1", "Dew_point_2", "Yday"]
categorical_vars = ["Month", "Wind_direction", "Sunshine_1", "Wind_Speed_1", "Humidity_1"]

preprocessor = ColumnTransformer([
    ('num', StandardScaler(), continuous_vars),
    ('cat', OneHotEncoder(handle_unknown='ignore', sparse_output=False), categorical_vars)
])

X_train_raw = preprocessor.fit_transform(train_df)
X_test_raw = preprocessor.transform(test_df)

y_scaler = StandardScaler()
y_train_raw = y_scaler.fit_transform(train_df['Avg_Temp'].values.reshape(-1, 1))

X_train = torch.tensor(X_train_raw, dtype=torch.float32).unsqueeze(1)
y_train = torch.tensor(y_train_raw, dtype=torch.float32)
X_test = torch.tensor(X_test_raw, dtype=torch.float32).unsqueeze(1)

class SimpleLSTM(nn.Module):
    def __init__(self, input_dim):
        super().__init__()
        self.lstm = nn.LSTM(input_size=input_dim, hidden_size=input_dim, num_layers=1, batch_first=True)
        
        # 3层全连接，逐步降维
        hidden1 = max(input_dim // 2, 8)
        hidden2 = max(hidden1 // 2, 4)
        
        self.dropout = nn.Dropout(0.2)
        self.fc1 = nn.Linear(input_dim, hidden1)
        self.relu1 = nn.ReLU()
        self.fc2 = nn.Linear(hidden1, hidden2)
        self.relu2 = nn.ReLU()
        self.fc3 = nn.Linear(hidden2, 1)
        
    def forward(self, x):
        out, _ = self.lstm(x)
        out = out[:, -1, :]
        
        out = self.dropout(out)
        out = self.relu1(self.fc1(out))
        out = self.dropout(out)
        out = self.relu2(self.fc2(out))
        out = self.dropout(out)
        out = self.fc3(out)
        return out

input_dim = X_train.shape[2]
model = SimpleLSTM(input_dim)
criterion = nn.MSELoss()
optimizer = torch.optim.Adam(model.parameters(), lr=0.01)

best_loss = float('inf')
patience_counter = 0
min_delta = 1e-4  # 定义最小提升幅度

# 训练并加入早停
for epoch in range(1000):
    model.train()
    optimizer.zero_grad()
    outputs = model(X_train)
    loss = criterion(outputs, y_train)
    loss.backward()
    optimizer.step()
    
    # 只有当损失函数的下降幅度超过 min_delta 时，才认为有提升
    if loss.item() < best_loss - min_delta:
        best_loss = loss.item()
        patience_counter = 0
        torch.save(model.state_dict(), 'lstm_model.pth')
    else:
        patience_counter += 1
        # 连续20轮没有显著提升则早停
        if patience_counter >= 20:
            break

model.load_state_dict(torch.load('lstm_model.pth', weights_only=True))
model.eval()
with torch.no_grad():
    preds_scaled = model(X_test).numpy()
    preds = y_scaler.inverse_transform(preds_scaled).flatten()

out_df = pd.DataFrame({
    'date': test_df['Date'],
    'true_temp': test_df['Avg_Temp'],
    'pred_temp': preds
})
out_df.to_csv('2025_lstm_pred.csv', index=False, encoding='utf-8')

# 计算评估指标（直接依据输出的CSV文件）
eval_df = pd.read_csv('2025_lstm_pred.csv')
valid_mask = eval_df['true_temp'].notna()
if valid_mask.any():
    y_true = eval_df.loc[valid_mask, 'true_temp']
    y_pred = eval_df.loc[valid_mask, 'pred_temp']
    
    mse = mean_squared_error(y_true, y_pred)
    rmse = np.sqrt(mse)
    mae = mean_absolute_error(y_true, y_pred)
    r2 = r2_score(y_true, y_pred)
    
    print("\n--- 依据CSV计算的 2025预测评估指标 ---")
    print(f"MSE:  {mse:.4f}")
    print(f"RMSE: {rmse:.4f}")
    print(f"MAE:  {mae:.4f}")
    print(f"R2:   {r2:.4f}")
else:
    print("\nCSV文件中没有真实的温度数据，无法计算评估指标。")
