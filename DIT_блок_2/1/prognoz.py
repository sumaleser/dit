import pandas as pd
import numpy as np
from statsmodels.tsa.holtwinters import ExponentialSmoothing
from pathlib import Path

# Определяем пути относительно скрипта
script_dir = Path(__file__).parent  # Папка, где находится скрипт
input_file = script_dir / 'newborns_stats.csv'  # Входной файл
output_file = script_dir / 'forecast.csv'  # Выходной файл

# Загрузка данных
df = pd.read_csv(input_file)

# Создаём дату
df['date'] = pd.to_datetime(df[['year', 'month']].assign(day=1))
df = df.set_index('date').sort_index()

# Берём только целевой показатель
y = df['target']

# Модель Хольта-Винтерса (с учётом тренда и сезонности)
model = ExponentialSmoothing(
    y,
    seasonal_periods=12,  # годовая сезонность
    trend='add',
    seasonal='add'
).fit()

# Прогноз на 12 месяцев
forecast = model.forecast(12)

# Создаём даты для прогноза
last_date = y.index[-1]
forecast_dates = pd.date_range(
    start=last_date + pd.DateOffset(months=1),
    periods=12,
    freq='MS'
)

# Результат
result = pd.DataFrame({
    'year': forecast_dates.year,
    'month': forecast_dates.month,
    'predicted_users': forecast.round(0).astype(int)
})

print(result.to_string(index=False))

# Сохраняем в CSV
result.to_csv(output_file, index=False, encoding='utf-8-sig')
print(f"\n Сохранено в: {output_file}")