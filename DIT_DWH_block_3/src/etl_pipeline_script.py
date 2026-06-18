import pandas as pd
from pathlib import Path
from sqlalchemy import text, create_engine
import logging
from datetime import datetime
import sys
import warnings
warnings.filterwarnings('ignore')

# ==================== ПАРАМЕТРЫ ПОДКЛЮЧЕНИЯ ====================
# Здесь хранятся настройки для подключения к Greenplum.
# Если разворачиваешь проект на другом сервере — меняй эти параметры.
DB_USER = 'gpadmin'
DB_PASSWORD = 'gpadmin'
DB_HOST = 'localhost'
DB_PORT = '5432'
DB_NAME = 'dwh_dit_db'

print("=" * 50)
print("Проверка базы данных...")
print("=" * 50)

# Сначала проверяем, существует ли база. Если нет — создаём.
# Это нужно, чтобы скрипт не падал при первом запуске.
try:
    default_conn_string = f'postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/postgres'
    default_engine = create_engine(default_conn_string)
    
    with default_engine.connect() as conn:
        result = conn.execute(
            text("SELECT 1 FROM pg_database WHERE datname = :dbname"),
            {"dbname": DB_NAME}
        )
        exists = result.scalar() is not None
        
        if not exists:
            conn.execute(text("COMMIT"))
            conn.execute(text(f"CREATE DATABASE {DB_NAME}"))
            print(f"База данных '{DB_NAME}' создана")
        else:
            print(f"База данных '{DB_NAME}' уже существует")
            
    default_engine.dispose()
    
except Exception as e:
    print(f"Ошибка: {e}")
    print("Проверьте:")
    print("1. Запущен ли PostgreSQL")
    print("2. Пароль и пользователь")
    print("3. Порт")
    input("Нажмите Enter для выхода...")
    sys.exit(1)

print("=" * 50)
print()

# ==================== НАСТРОЙКА ЛОГИРОВАНИЯ ====================
# Логи пишутся в папку logs/ в корне проекта.
# bad_records/ — сюда попадают строки, которые не прошли проверку.
project_root = Path(__file__).parent.parent
LOG_DIR = project_root / 'logs'
LOG_DIR.mkdir(exist_ok=True)

BAD_DIR = project_root / 'bad_records'
BAD_DIR.mkdir(exist_ok=True)

log_filename = LOG_DIR / f'etl_{datetime.now().strftime("%Y%m%d_%H%M%S")}.log'

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(log_filename, encoding='utf-8'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

logger.info("=" * 60)
logger.info("Запуск ETL процесса")
logger.info("=" * 60)

# ==================== ФУНКЦИИ ====================

def log_bad_records(df, df_name, issue_type, filter_condition):
    """
    Сохраняет проблемные строки в CSV.
    Это помогает позже разобраться, какие данные были испорчены.
    """
    bad_df = df[filter_condition].copy()
    if len(bad_df) > 0:
        project_root = Path(__file__).parent.parent
        bad_dir = project_root / 'bad_records'
        bad_dir.mkdir(exist_ok=True)
        
        filename = bad_dir / f"{df_name}_{issue_type}_{datetime.now().strftime('%Y%m%d')}.csv"
        bad_df.to_csv(filename, index=False, encoding='utf-8')
        logger.warning(f"{df_name}: найдено {len(bad_df)} проблемных записей ({issue_type})")
    return len(bad_df)


def clean_phone(phone):
    """
    Приводит номера телефонов к единому формату: +7XXXXXXXXXX.
    Если формат не распознаётся — оставляет как есть.
    """
    if pd.isna(phone):
        return phone

    digits = ''.join(filter(str.isdigit, str(phone)))

    if len(digits) == 11 and digits.startswith('7'):
        return '+' + digits
    elif len(digits) == 10:
        return '+7' + digits
    elif len(digits) == 11 and digits.startswith('8'):
        return '+7' + digits[1:]
    else:
        return phone


def clean_fk(df, df_name, fk_column, valid_df, valid_column):
    """
    Проверяет внешние ключи: если ID нет в таблице-источнике — заменяет на -1.
    -1 — это служебное значение, означающее «неизвестно».
    """
    valid_ids = set(valid_df[valid_column].dropna().unique())
    valid_ids.add(-1)

    original_count = df[fk_column].notna().sum()

    bad_fk = ~df[fk_column].isin(valid_ids) & df[fk_column].notna()
    log_bad_records(df, df_name, f'invalid_{fk_column}', bad_fk)

    df[fk_column] = df[fk_column].apply(
        lambda x: x if pd.isna(x) or x in valid_ids else -1
    )

    df[fk_column] = df[fk_column].fillna(0)
    df[fk_column] = df[fk_column].astype('Int64')

    invalid_count = original_count - df[fk_column].notna().sum()
    logger.info(f"{df_name}: {fk_column} заменено {invalid_count} невалидных значений на -1")

    return df


# ==================== EXTRACT ====================
# Читаем исходные данные из файлов.
# data/ лежит в корне проекта, на одном уровне с src/.
logger.info("Чтение данных из файлов...")

script_dir = Path(__file__).parent
source_dir = script_dir.parent / 'data'

try:
    customers = pd.read_csv(source_dir / 'customers.csv')
    logger.info(f"customers.csv: {len(customers)} записей")
except Exception as e:
    logger.error(f"Ошибка чтения customers.csv: {e}")
    sys.exit(1)

try:
    orders = pd.read_json(source_dir / 'orders.json')
    logger.info(f"orders.json: {len(orders)} записей")
except Exception as e:
    logger.error(f"Ошибка чтения orders.json: {e}")
    sys.exit(1)

try:
    payments = pd.read_csv(source_dir / 'payments.csv', sep='^')
    logger.info(f"payments.csv: {len(payments)} записей")
except Exception as e:
    logger.error(f"Ошибка чтения payments.csv: {e}")
    sys.exit(1)

try:
    events = pd.read_xml(source_dir / 'events.xml')
    logger.info(f"events.xml: {len(events)} записей")
except Exception as e:
    logger.error(f"Ошибка чтения events.xml: {e}")
    sys.exit(1)

try:
    products = pd.read_excel(source_dir / 'products.xlsx')
    logger.info(f"products.xlsx: {len(products)} записей")
except Exception as e:
    logger.error(f"Ошибка чтения products.xlsx: {e}")
    sys.exit(1)


# ==================== UNKNOWN ====================
# Добавляем служебные записи.
# -1 — данные невалидны (ссылаются на несуществующий ID)
# 0 — вместо NULL (изначально данных не было)
logger.info("Добавление служебных записей...")

unknown_customer = pd.DataFrame({
    'customer_id': [-1],
    'full_name': ['Unknown'],
    'email': [None],
    'phone': [None],
    'city': ['Unknown'],
    'created_at': [pd.NaT]
})
customers = pd.concat([customers, unknown_customer], ignore_index=True)

unknown_product = pd.DataFrame({
    'product_id': [-1],
    'product_name': ['Unknown'],
    'category': ['Unknown'],
    'price': [None],
    'currency': [None],
    'is_active': [False]
})
products = pd.concat([products, unknown_product], ignore_index=True)

unknown_order = pd.DataFrame({
    'order_id': [-1],
    'customer_id': [-1],
    'product_id': [-1],
    'quantity': [0],
    'unit_price': [0],
    'currency': ['Unknown'],
    'order_timestamp': [pd.NaT],
    'status': ['Unknown']
})
orders = pd.concat([orders, unknown_order], ignore_index=True)


# ==================== TRANSFORM ====================
# Очистка и приведение данных к нужным типам.
logger.info("Трансформация данных...")

# ----- Customers -----
logger.info("Обработка customers...")

log_bad_records(customers, 'customers', 'empty_phone', customers['phone'].isna() | (customers['phone'] == ''))
log_bad_records(customers, 'customers', 'invalid_date', ~pd.to_datetime(customers['created_at'], errors='coerce').notna())

customers['created_at'] = pd.to_datetime(customers['created_at'], errors='coerce')
customers['phone'] = customers['phone'].replace(['', 'NaN', 'nan', 'UNKNOWN', 'None'], None)
customers['phone'] = customers['phone'].apply(clean_phone)

customers = customers.drop_duplicates(subset=['customer_id'])
customers = customers.dropna(subset=['customer_id'])
logger.info(f"customers: {len(customers)} записей")


# ----- Orders -----
logger.info("Обработка orders...")

log_bad_records(orders, 'orders', 'invalid_date', ~pd.to_datetime(orders['order_timestamp'], errors='coerce').notna())

orders['customer_id'] = pd.to_numeric(orders['customer_id'], errors='coerce').astype('Int64')
orders['order_timestamp'] = pd.to_datetime(orders['order_timestamp'], errors='coerce')

orders = orders.drop_duplicates(subset=['order_id'])
orders = orders.dropna(subset=['order_id'])

orders = clean_fk(orders, 'orders', 'customer_id', customers, 'customer_id')
orders = clean_fk(orders, 'orders', 'product_id', products, 'product_id')

logger.info(f"orders: {len(orders)} записей")


# ----- Payments -----
logger.info("Обработка payments...")

log_bad_records(payments, 'payments', 'invalid_amount', ~pd.to_numeric(payments['amount'], errors='coerce').notna())
log_bad_records(payments, 'payments', 'invalid_date', ~pd.to_datetime(payments['payment_timestamp'], errors='coerce').notna())

payments['amount'] = pd.to_numeric(payments['amount'], errors='coerce')
payments['payment_timestamp'] = pd.to_datetime(payments['payment_timestamp'], errors='coerce')

payments = payments.drop_duplicates(subset=['payment_id'])
payments = payments.dropna(subset=['payment_id'])

payments = clean_fk(payments, 'payments', 'order_id', orders, 'order_id')

logger.info(f"payments: {len(payments)} записей")


# ----- Events -----
logger.info("Обработка events...")

log_bad_records(events, 'events', 'invalid_date', ~pd.to_datetime(events['event_timestamp'], errors='coerce').notna())

events['event_id'] = pd.to_numeric(events['event_id'], errors='coerce').astype('Int64')
events['customer_id'] = pd.to_numeric(events['customer_id'], errors='coerce').astype('Int64')
events['product_id'] = pd.to_numeric(events['product_id'], errors='coerce').astype('Int64')

events['event_timestamp'] = pd.to_datetime(events['event_timestamp'], errors='coerce')

events = events.drop_duplicates(subset=['event_id'])
events = events.dropna(subset=['event_id'])

events = clean_fk(events, 'events', 'customer_id', customers, 'customer_id')
events = clean_fk(events, 'events', 'product_id', products, 'product_id')

logger.info(f"events: {len(events)} записей")


# ----- Products -----
logger.info("Обработка products...")

products = products.drop_duplicates(subset=['product_id'])
products = products.dropna(subset=['product_id'])

logger.info(f"products: {len(products)} записей")


# ==================== LOAD ====================
# Загружаем очищенные данные в схему dds.
logger.info("Загрузка данных в Greenplum...")

conn_string = f'postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}'
engine = create_engine(conn_string)

try:
    with engine.connect() as conn:
        conn.execute(text("CREATE SCHEMA IF NOT EXISTS dds"))
        conn.commit()
    logger.info("Схема dds создана")
except Exception as e:
    logger.error(f"Ошибка создания схемы: {e}")
    sys.exit(1)

try:
    customers.to_sql('customers', engine, schema='dds', if_exists='replace', index=False)
    logger.info(f"customers загружены: {len(customers)} записей")
except Exception as e:
    logger.error(f"Ошибка загрузки customers: {e}")

try:
    orders.to_sql('orders', engine, schema='dds', if_exists='replace', index=False)
    logger.info(f"orders загружены: {len(orders)} записей")
except Exception as e:
    logger.error(f"Ошибка загрузки orders: {e}")

try:
    payments.to_sql('payments', engine, schema='dds', if_exists='replace', index=False)
    logger.info(f"payments загружены: {len(payments)} записей")
except Exception as e:
    logger.error(f"Ошибка загрузки payments: {e}")

try:
    events.to_sql('events', engine, schema='dds', if_exists='replace', index=False)
    logger.info(f"events загружены: {len(events)} записей")
except Exception as e:
    logger.error(f"Ошибка загрузки events: {e}")

try:
    products.to_sql('products', engine, schema='dds', if_exists='replace', index=False)
    logger.info(f"products загружены: {len(products)} записей")
except Exception as e:
    logger.error(f"Ошибка загрузки products: {e}")


# ==================== ФИНИШ ====================

logger.info("=" * 60)
logger.info("ETL процесс завершён")
logger.info("=" * 60)