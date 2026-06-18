import pandas as pd
from pathlib import Path

# Определяем путь к файлу относительно скрипта
script_dir = Path(__file__).parent  # Папка, где находится скрипт
input_file = script_dir / 'test_name.csv'  # Тестовый файл

# Загрузка данных
data = pd.read_csv(input_file)

# Словарь замены: латиница - кириллица (только визуально одинаковые)
REPLACEMENTS = {
    'A': 'А', 'a': 'а',
    'B': 'В', 'b': 'в',
    'E': 'Е', 'e': 'е',
    'K': 'К', 'k': 'к',
    'M': 'М', 'm': 'м',
    'H': 'Н', 'h': 'н',
    'O': 'О', 'o': 'о',
    'P': 'Р', 'p': 'р',
    'C': 'С', 'c': 'с',
    'T': 'Т', 't': 'т',
    'X': 'Х', 'x': 'х',
    'Y': 'У', 'y': 'у'
}

def clean_name(name):
    """Заменяет латиницу на кириллицу"""
    result = ''
    for char in name:
        # Если символ есть в словаре - заменяем
        if char in REPLACEMENTS:
            result += REPLACEMENTS[char]
        else:
            result += char
    return result

# Применяем очистку
data['clean_name'] = data['name'].apply(clean_name)

# Находим дубли и назначаем new_id (минимальный id в группе)
data['new_id'] = data.groupby('clean_name')['id'].transform('min')

# Вывод результата в консоль
print(data[['id', 'name', 'clean_name', 'new_id']].to_string(index=False))

# Сохраняем результат в CSV рядом со скриптом
output_file = script_dir / 'result.csv'
data[['id', 'name', 'clean_name', 'new_id']].to_csv(output_file, index=False)
print(f"\n Результат сохранён в: {output_file}")
