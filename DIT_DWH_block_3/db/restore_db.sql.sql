--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.26
-- Dumped by pg_dump version 17.0

-- Started on 2026-06-16 19:54:04

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE dwh_dit_db;
--
-- TOC entry 2548 (class 1262 OID 49152)
-- Name: dwh_dit_db; Type: DATABASE; Schema: -; Owner: gpadmin
--

CREATE DATABASE dwh_dit_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE dwh_dit_db OWNER TO gpadmin;

\connect dwh_dit_db

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 9 (class 2615 OID 49304)
-- Name: dds; Type: SCHEMA; Schema: -; Owner: gpadmin
--

CREATE SCHEMA dds;


ALTER SCHEMA dds OWNER TO gpadmin;

--
-- TOC entry 10 (class 2615 OID 49425)
-- Name: dim; Type: SCHEMA; Schema: -; Owner: gpadmin
--

CREATE SCHEMA dim;


ALTER SCHEMA dim OWNER TO gpadmin;

--
-- TOC entry 11 (class 2615 OID 49426)
-- Name: fact; Type: SCHEMA; Schema: -; Owner: gpadmin
--

CREATE SCHEMA fact;


ALTER SCHEMA fact OWNER TO gpadmin;

--
-- TOC entry 12 (class 2615 OID 49505)
-- Name: mart; Type: SCHEMA; Schema: -; Owner: gpadmin
--

CREATE SCHEMA mart;


ALTER SCHEMA mart OWNER TO gpadmin;

SET default_tablespace = '';

--
-- TOC entry 284 (class 1259 OID 49526)
-- Name: customers; Type: TABLE; Schema: dds; Owner: gpadmin
--

CREATE TABLE dds.customers (
    customer_id bigint,
    full_name text,
    email text,
    phone text,
    city text,
    created_at timestamp without time zone
);


ALTER TABLE dds.customers OWNER TO gpadmin;

--
-- TOC entry 287 (class 1259 OID 49544)
-- Name: events; Type: TABLE; Schema: dds; Owner: gpadmin
--

CREATE TABLE dds.events (
    event_id bigint,
    customer_id bigint,
    event_type text,
    event_timestamp timestamp without time zone,
    product_id bigint
);


ALTER TABLE dds.events OWNER TO gpadmin;

--
-- TOC entry 285 (class 1259 OID 49532)
-- Name: orders; Type: TABLE; Schema: dds; Owner: gpadmin
--

CREATE TABLE dds.orders (
    order_id bigint,
    customer_id bigint,
    product_id bigint,
    quantity bigint,
    unit_price double precision,
    currency text,
    order_timestamp timestamp without time zone,
    status text
);


ALTER TABLE dds.orders OWNER TO gpadmin;

--
-- TOC entry 286 (class 1259 OID 49538)
-- Name: payments; Type: TABLE; Schema: dds; Owner: gpadmin
--

CREATE TABLE dds.payments (
    payment_id bigint,
    order_id bigint,
    payment_method text,
    amount double precision,
    currency text,
    payment_timestamp timestamp without time zone
);


ALTER TABLE dds.payments OWNER TO gpadmin;

--
-- TOC entry 288 (class 1259 OID 49550)
-- Name: products; Type: TABLE; Schema: dds; Owner: gpadmin
--

CREATE TABLE dds.products (
    product_id bigint,
    product_name text,
    category text,
    price double precision,
    currency text,
    is_active boolean
);


ALTER TABLE dds.products OWNER TO gpadmin;

--
-- TOC entry 273 (class 1259 OID 49469)
-- Name: dim_customer; Type: TABLE; Schema: dim; Owner: gpadmin
--

CREATE TABLE dim.dim_customer (
    customer_id bigint,
    name text,
    email text,
    phone text,
    city text,
    registration_date date
);


ALTER TABLE dim.dim_customer OWNER TO gpadmin;

--
-- TOC entry 275 (class 1259 OID 49481)
-- Name: dim_date; Type: TABLE; Schema: dim; Owner: gpadmin
--

CREATE TABLE dim.dim_date (
    date_id date,
    year double precision,
    month double precision,
    day double precision,
    quarter double precision,
    year_month text
);


ALTER TABLE dim.dim_date OWNER TO gpadmin;

--
-- TOC entry 274 (class 1259 OID 49475)
-- Name: dim_product; Type: TABLE; Schema: dim; Owner: gpadmin
--

CREATE TABLE dim.dim_product (
    product_id bigint,
    name text,
    category text,
    price double precision,
    currency text,
    is_active boolean
);


ALTER TABLE dim.dim_product OWNER TO gpadmin;

--
-- TOC entry 277 (class 1259 OID 49493)
-- Name: fact_events; Type: TABLE; Schema: fact; Owner: gpadmin
--

CREATE TABLE fact.fact_events (
    date_id date,
    event_id bigint,
    customer_id bigint,
    event_type text,
    event_timestamp timestamp without time zone,
    product_id bigint
);


ALTER TABLE fact.fact_events OWNER TO gpadmin;

--
-- TOC entry 276 (class 1259 OID 49487)
-- Name: fact_orders; Type: TABLE; Schema: fact; Owner: gpadmin
--

CREATE TABLE fact.fact_orders (
    date_id date,
    order_id bigint,
    customer_id bigint,
    product_id bigint,
    quantity bigint,
    unit_price double precision,
    currency text,
    order_timestamp timestamp without time zone,
    status text
);


ALTER TABLE fact.fact_orders OWNER TO gpadmin;

--
-- TOC entry 278 (class 1259 OID 49499)
-- Name: fact_payments; Type: TABLE; Schema: fact; Owner: gpadmin
--

CREATE TABLE fact.fact_payments (
    date_id date,
    payment_id bigint,
    order_id bigint,
    payment_method text,
    amount double precision,
    currency text,
    payment_timestamp timestamp without time zone
);


ALTER TABLE fact.fact_payments OWNER TO gpadmin;

--
-- TOC entry 283 (class 1259 OID 49522)
-- Name: v_customers_without_orders; Type: VIEW; Schema: mart; Owner: gpadmin
--

CREATE VIEW mart.v_customers_without_orders AS
 SELECT c.customer_id,
    c.name AS customer_name,
    c.email,
    c.phone,
    c.city,
    c.registration_date
   FROM (dim.dim_customer c
     LEFT JOIN fact.fact_orders o ON ((c.customer_id = o.customer_id)))
  WHERE ((o.order_id IS NULL) AND (c.customer_id > 0))
  ORDER BY c.customer_id;


ALTER VIEW mart.v_customers_without_orders OWNER TO gpadmin;

--
-- TOC entry 280 (class 1259 OID 49510)
-- Name: v_revenue_by_month; Type: VIEW; Schema: mart; Owner: gpadmin
--

CREATE VIEW mart.v_revenue_by_month AS
 SELECT d.year_month,
    d.year,
    d.month,
    count(DISTINCT o.order_id) AS orders_count,
    sum(((o.quantity)::double precision * o.unit_price)) AS total_revenue,
    avg(((o.quantity)::double precision * o.unit_price)) AS avg_order_value
   FROM (fact.fact_orders o
     JOIN dim.dim_date d ON ((o.date_id = d.date_id)))
  WHERE (o.customer_id > 0)
  GROUP BY d.year, d.month, d.year_month
  ORDER BY d.year, d.month;


ALTER VIEW mart.v_revenue_by_month OWNER TO gpadmin;

--
-- TOC entry 282 (class 1259 OID 49518)
-- Name: v_top5_last_activity; Type: VIEW; Schema: mart; Owner: gpadmin
--

CREATE VIEW mart.v_top5_last_activity AS
 WITH top_customers AS (
         SELECT fact_orders.customer_id,
            count(fact_orders.order_id) AS orders_count
           FROM fact.fact_orders
          WHERE (fact_orders.customer_id > 0)
          GROUP BY fact_orders.customer_id
          ORDER BY count(fact_orders.order_id) DESC
         LIMIT 5
        )
 SELECT tc.customer_id,
    c.name AS customer_name,
    tc.orders_count,
    max(o.order_timestamp) AS last_activity_date
   FROM ((top_customers tc
     JOIN fact.fact_orders o ON ((tc.customer_id = o.customer_id)))
     JOIN dim.dim_customer c ON ((tc.customer_id = c.customer_id)))
  GROUP BY tc.orders_count, tc.customer_id, c.name
  ORDER BY tc.orders_count DESC;


ALTER VIEW mart.v_top5_last_activity OWNER TO gpadmin;

--
-- TOC entry 279 (class 1259 OID 49506)
-- Name: v_top_customers; Type: VIEW; Schema: mart; Owner: gpadmin
--

CREATE VIEW mart.v_top_customers AS
 SELECT c.customer_id,
    c.name AS customer_name,
    c.city,
    sum(((o.quantity)::double precision * o.unit_price)) AS total_spent,
    count(DISTINCT o.order_id) AS orders_count
   FROM (fact.fact_orders o
     JOIN dim.dim_customer c ON ((o.customer_id = c.customer_id)))
  WHERE (o.customer_id > 0)
  GROUP BY c.customer_id, c.name, c.city
  ORDER BY sum(((o.quantity)::double precision * o.unit_price)) DESC
 LIMIT 10;


ALTER VIEW mart.v_top_customers OWNER TO gpadmin;

--
-- TOC entry 281 (class 1259 OID 49514)
-- Name: v_top_products; Type: VIEW; Schema: mart; Owner: gpadmin
--

CREATE VIEW mart.v_top_products AS
 SELECT p.product_id,
    p.name AS product_name,
    p.category,
    count(DISTINCT o.order_id) AS orders_count,
    sum(o.quantity) AS total_quantity_sold,
    sum(((o.quantity)::double precision * o.unit_price)) AS total_revenue
   FROM (fact.fact_orders o
     JOIN dim.dim_product p ON ((o.product_id = p.product_id)))
  WHERE (o.product_id > 0)
  GROUP BY p.product_id, p.name, p.category
  ORDER BY sum(o.quantity) DESC
 LIMIT 10;


ALTER VIEW mart.v_top_products OWNER TO gpadmin;

--
-- TOC entry 2538 (class 0 OID 49526)
-- Dependencies: 284
-- Data for Name: customers; Type: TABLE DATA; Schema: dds; Owner: gpadmin
--

COPY dds.customers (customer_id, full_name, email, phone, city, created_at) FROM stdin;
2	Егоров Тихон Федосеевич	serafim_1986@gmail.com	\N	п. Мостовской	2024-07-21 00:00:00
1	Мишин Емельян Валерьевич	mechislav_37@hotmail.com	\N	п. Печора	2024-05-31 00:00:00
3	Зыков Вацлав Алексеевич	fharitonova@gmail.com	+79749621470	ст. Луга	2024-06-15 00:00:00
5	София Тимофеевна Михеева	selivan_1979@ao.ru	+79206468299	г. Уренгой	2026-01-17 00:00:00
4	Савельева Юлия Кузьминична	odintsovgerman@ignatev.biz	\N	п. Воскресенск	2025-03-28 00:00:00
11	Зыкова Глафира Геннадиевна	silagushchin@mail.ru	\N	клх Печора	2025-08-20 00:00:00
6	Варвара Степановна Шилова	aksenovkazimir@rao.biz	+79298471886	п. Карпинск	2025-06-15 00:00:00
12	Геннадий Матвеевич Цветков	\N	+79413140753	п. Борзя	2024-09-09 00:00:00
7	Гедеон Феофанович Андреев	belovemmanuil@hotmail.com	\N	п. Руза	2023-06-08 00:00:00
14	г-н Волков Фирс Алексеевич	artem1973@ooo.ru	+79320452650	ст. Верхний Тагил	2024-04-12 00:00:00
8	Орехова Ангелина Дмитриевна	nonna_92@hotmail.com	+79993631208	клх Красная Поляна	2025-03-05 00:00:00
15	Прокофий Владиленович Уваров	solovevfrol@rambler.ru	+79348059918	ст. Южно-Курильск	2023-11-12 00:00:00
9	София Константиновна Полякова	lavrnekrasov@yahoo.com	\N	с. Петушки	2024-12-16 00:00:00
17	Сазонов Ипат Адамович	kirill_2014@evdokimov.edu	+79213717787	с. Кемерово	2026-02-17 00:00:00
10	Евдокия Аркадьевна Ларионова	elise1970@gmail.com	+79282116655	г. Бийск	2025-09-21 00:00:00
20	Королева Олимпиада Владимировна	igormamontov@mail.ru	\N	п. Касимов	2024-05-26 00:00:00
13	Мирослав Гертрудович Виноградов	\N	+79119778234	г. Чита	2023-08-26 00:00:00
23	Валерия Афанасьевна Беспалова	ladislav_2007@kirillov.net	\N	клх Саратов	2024-12-08 00:00:00
16	Марфа Вячеславовна Павлова	leonti1997@yahoo.com	+79721802072	с. Яшкуль	2023-07-28 00:00:00
25	Трофимов Максим Игнатьевич	januari_2015@aviakompanija.biz	\N	клх Невьянск	2026-03-04 00:00:00
18	Жданова Екатерина Александровна	sazonovharlampi@zao.edu	+79965953266	\N	2026-03-05 00:00:00
26	Фортунат Гавриилович Гордеев	askoldlitkin@yahoo.com	\N	г. Верхнее Пенжино	2025-09-03 00:00:00
19	Руслан Антонович Попов	fedoseevsilanti@mjasnikova.biz	+79594768704	д. Стрежевой	2026-03-06 00:00:00
30	Наталья Ждановна Тарасова	oktjabrina_84@rambler.ru	\N	клх Санкт-Петербург	2025-11-15 00:00:00
21	Авдеев Ермолай Аверьянович	kovalevairaida@arhipov.info	\N	клх Хасан	2024-10-05 00:00:00
31	Боброва Светлана Николаевна	lavrmartinov@ip.org	+79121757837	к. Пермь	2024-07-23 00:00:00
22	Шарапов Фрол Ааронович	sisoevgennadi@yahoo.com	+79867699222	п. Ессентуки	2024-05-04 00:00:00
35	Эрнст Филиппович Игнатов	kkapustin@gmail.com	\N	клх Ноябрьск	2024-08-07 00:00:00
24	Носкова Нонна Петровна	apollinari24@mail.ru	\N	г. Усть-Кулом	2026-04-07 00:00:00
36	Устин Егорович Сафонов	\N	+79948228268	к. Санкт-Петербург	2023-09-29 00:00:00
27	Сорокин Автоном Давыдович	uljanbikov@yahoo.com	\N	к. Нефтекамск	2025-09-01 00:00:00
38	Фомин Сильвестр Афанасьевич	vitali2015@yahoo.com	+79852055581	клх Сорочинск	2024-09-17 00:00:00
28	Быков Ульян Филиппович	viktorin78@hotmail.com	+79087091896	ст. Уренгой	2024-12-01 00:00:00
40	Абрамов Кирилл Григорьевич	vsevolodkalashnikov@rambler.ru	+79921907485	с. Новый Уренгой	2025-12-11 00:00:00
29	Комиссарова Варвара Рудольфовна	anikeisaev@yandex.ru	+79626713347	клх Алексин	2023-09-08 00:00:00
44	Александр Ефремович Сафонов	velimir_94@mosmetrostro.ru	+79737507241	с. Калининград	2024-09-03 00:00:00
32	Рогов Никанор Венедиктович	anzhela_1976@teterina.com	\N	д. Оленегорск (Якут.)	2023-08-01 00:00:00
46	Ефрем Федосьевич Бирюков	shirjaevmark@rambler.ru	+79376672634	к. Нефтеюганск	2024-05-27 00:00:00
33	Рюрик Бенедиктович Борисов	fekla_1996@gmail.com	+79123940587	п. Каменск-Уральский	2025-06-23 00:00:00
47	Иосиф Глебович Мамонтов	tverdislav1979@mail.ru	+79308071259	к. Каспийск	2025-10-23 00:00:00
34	Януарий Игнатович Русаков	loginovfeliks@yahoo.com	+79770530217	ст. Онега	2025-08-10 00:00:00
48	Олимпиада Геннадьевна Гаврилова	evdokimtsvetkov@egorova.com	+79474765466	с. Тотьма	2025-11-12 00:00:00
37	Тимофеева Ульяна Степановна	evdokimovaanastasija@yandex.ru	+79391541578	к. Шелехов	2025-07-06 00:00:00
49	Лукия Александровна Красильникова	lmelnikova@yahoo.com	+79817345221	к. Александровск-Сахалинский	2025-09-14 00:00:00
39	Тихон Тихонович Романов	pgorbacheva@rambler.ru	+79225221332	п. Златоуст	2024-01-28 00:00:00
50	Мишина Антонина Макаровна	ivanna25@gmail.com	\N	к. Соловки	2023-09-23 00:00:00
41	Таисия Геннадиевна Котова	kornilovmodest@antonov.info	+79207371533	клх Сладково	2024-05-11 00:00:00
52	Емельянов Симон Виленович	dkudrjavtseva@ooo.edu	\N	с. Казань	2025-06-25 00:00:00
42	Марина Валериевна Журавлева	anisim1994@npo.net	+79029635852	с. Сальск	2024-12-11 00:00:00
56	Евгения Тимуровна Князева	rusakovparfen@yandex.ru	+79882563718	с. Саранск	2024-06-22 00:00:00
43	Борислав Харлампьевич Евдокимов	dkudrjavtsev@mail.ru	+79554535065	к. Ачхой Мартан	2023-05-26 00:00:00
57	Петр Жоресович Брагин	kapitonvorobev@sds-ugol.edu	+79919909014	г. Мостовской	2024-05-20 00:00:00
45	Клавдий Дмитриевич Калашников	kabanovvadim@ao.ru	\N	к. Сунтар	2024-01-03 00:00:00
61	Рыбакова Евдокия Матвеевна	rjurikovchinnikov@hotmail.com	+79227268503	д. Аргаяш	2025-08-15 00:00:00
51	Евдокимова Раиса Руслановна	nikonovamarfa@gmail.com	\N	к. Москва, МГУ	2024-07-12 00:00:00
63	Силина Октябрина Матвеевна	selivanermakov@mail.ru	\N	с. Шелагонцы	2026-04-11 00:00:00
53	Леонтий Игоревич Якушев	zinovevanani@hotmail.com	\N	г. Губаха	2024-04-30 00:00:00
64	Клавдия Никифоровна Самойлова	ktretjakova@ao.info	+79803079055	г. Комсомольск-на-Амуре	2025-10-07 00:00:00
54	Рябова Милица Константиновна	ermola36@ooo.ru	\N	с. Чикола	2025-02-04 00:00:00
68	Юрий Захарьевич Мартынов	chernovanadezhda@zao.info	\N	к. Бодайбо	2024-02-28 00:00:00
55	Евдокимова Наталья Робертовна	fevronija1984@sistemni.edu	+79355501946	г. Тихвин	2026-03-06 00:00:00
69	Оксана Вадимовна Фомина	galkinkliment@simonov.info	\N	д. Кажим	2025-04-27 00:00:00
58	Самсонов Юлий Терентьевич	braginmaksim@zao.edu	+79418744974	клх Северо-Курильск	2023-07-01 00:00:00
71	  ivan IVANOV 	jakub2021@rao.net	+79277403790	ст. Тамбов	2023-08-24 00:00:00
59	Щукин Матвей Тимурович	amos_1991@glenkor.org	+79718197581	г. Чебаркуль	2025-02-16 00:00:00
72	Ангелина Афанасьевна Павлова	zabramov@yandex.ru	+79436398872	ст. Вуктыл	2025-06-04 00:00:00
60	Ольга Кузьминична Голубева	leonid64@gmail.com	+79690147183	к. Малая Вишера	2025-07-27 00:00:00
74	Станимир Феликсович Брагин	kuznetsovalora@mail.ru	\N	ст. Игнашино	2024-06-15 00:00:00
62	Ефимов Савва Гурьевич	\N	+79804258674	клх Норильск	2024-05-05 00:00:00
76	Воробьева Евпраксия Архиповна	vorobevgalaktion@oao.edu	+79894027897	клх Беломорск	2024-09-01 00:00:00
65	Кулакова Эмилия Александровна	modest2009@gmail.com	+79396899658	д. Теберда	2024-07-18 00:00:00
78	Марфа Константиновна Лаврентьева	spartak19@yandex.ru	+79472949775	г. Тихорецк	2024-01-27 00:00:00
66	Горбунов Ипполит Бенедиктович	blohinafevronija@zao.info	+79864929067	клх Хасавюрт	2023-06-09 00:00:00
79	Фомичев Митофан Матвеевич	tatjana03@yandex.ru	\N	к. Оймякон	2023-09-17 00:00:00
67	Роман Дмитриевич Якушев	kapiton28@kordiant.edu	\N	клх Ирбит	\N
83	Кудряшов Кузьма Юльевич	gromovamaja@zao.org	+79098033943	клх Змеиногорск	2024-11-04 00:00:00
70	Герман Викторович Гусев	germankabanov@zao.com	+79727249558	п. Кыштым	\N
85	Чеслав Демидович Рыбаков	ekononov@rambler.ru	\N	п. Певек	2024-10-29 00:00:00
73	Лапина Зинаида Анатольевна	oabramova@oao.ru	\N	к. Енисейск	2025-02-24 00:00:00
86	Всеслав Иосифович Кондратьев	milan_1978@ooo.org	\N	клх Бавлы	2026-02-03 00:00:00
75	Измаил Аксёнович Устинов	aleksandrovaviktorija@yandex.ru	+79296889215	д. Салават	2024-03-15 00:00:00
87	Майя Юльевна Горшкова	petrovvarfolome@npo.edu	\N	г. Терскол	2023-06-29 00:00:00
77	Иван Еремеевич Потапов	\N	+79932503106	с. Волгодонск	2025-12-31 00:00:00
88	Коновалова Прасковья Макаровна	burovsimon@oao.com	+79194872482	с. Губкин	2026-02-06 00:00:00
80	Прасковья Станиславовна Рябова	marfa_1993@rao.info	\N	ст. Североуральск	2026-04-13 00:00:00
89	тов. Миронов Евграф Ефимович	makarovefim@yandex.ru	\N	д. Петухово	2026-02-18 00:00:00
81	Пономарева Валентина Олеговна	stepanovajulija@aksenov.ru	+79077242236	г. Ведено	2025-02-12 00:00:00
91	Пестов Гурий Валерьянович	avksenti2010@detski.info	+79474637858	д. Салехард	2025-12-20 00:00:00
82	Светлана Леонидовна Беляева	terentevmefodi@rao.org	+79637599912	с. Долинск	2024-06-03 00:00:00
95	Фадеева Вероника Валериевна	osip1980@gmail.com	\N	д. Вязьма	2024-05-04 00:00:00
84	Антонова Галина Борисовна	uosipova@yahoo.com	\N	п. Надым	2024-11-28 00:00:00
96	Мария Игоревна Архипова	sokrat_52@npo.biz	\N	к. Асино	2024-04-06 00:00:00
90	Молчанов Милий Данилович	spiridon_1973@gmail.com	\N	с. Каменск-Шахтинский	2023-12-04 00:00:00
98	Ульяна Константиновна Одинцова	mamontovippolit@yahoo.com	+79995201550	г. Курск	2025-08-27 00:00:00
92	Журавлева Фаина Борисовна	rusakovjan@hotmail.com	+79749740261	с. Минусинск	2025-09-15 00:00:00
105	Ксения Мироновна Кабанова	gmartinova@yandex.ru	\N	п. Сковородино	2024-12-27 00:00:00
93	Беляева Агата Петровна	kapustinavera@gmail.com	+79126128312	п. Александровск-Сахалинский	2023-09-27 00:00:00
106	Кабанова Ия Феликсовна	komarovavarvara@npo.org	+79169625036	клх Курильск	2025-02-20 00:00:00
94	Сила Арсеньевич Воронов	rkulakov@ip.ru	\N	ст. Красноуфимск	2026-04-05 00:00:00
107	Авдеева Клавдия Юльевна	dementi1997@gmail.com	\N	ст. Азов (Рост.)	2023-11-09 00:00:00
97	Кира Аркадьевна Трофимова	denis2006@softline.com	+79708817958	ст. Каргасок	2025-05-17 00:00:00
111	Фаина Антоновна Фомина	pgorbacheva@gmail.com	\N	д. Тулун	2023-12-10 00:00:00
99	Полякова Ия Георгиевна	hpanov@yandex.ru	\N	\N	2025-08-29 00:00:00
114	Егорова Вероника Алексеевна	kapustinparfen@mail.ru	+79014945047	п. Териберка	2025-12-03 00:00:00
100	Евдокимов Владислав Евстигнеевич	sigizmund1996@ao.biz	\N	к. Соль-Илецк	2026-01-04 00:00:00
116	Блохина Марфа Васильевна	sidor1990@ip.org	+79237691219	п. Иркутск	2025-03-05 00:00:00
101	Анатолий Эдуардович Шашков	apollon_70@yandex.ru	\N	г. Новомосковск	2026-02-24 00:00:00
119	Зосима Федосеевич Матвеев	kapiton_48@yandex.ru	+79918532650	д. Диксон	2025-06-21 00:00:00
102	Дроздов Валерий Егорович	faina_2025@ip.com	\N	клх Обнинск	2024-08-21 00:00:00
121	Нинель Романовна Якушева	taras1997@rambler.ru	+79169058236	клх Новая Игирма	2024-11-28 00:00:00
103	Мирослав Валерьевич Марков	\N	+79816440738	с. Томари	2023-10-12 00:00:00
122	Сафонов Анатолий Богданович	foma75@bikov.info	+79158435089	ст. Мостовской	2026-01-19 00:00:00
104	Вышеслав Геннадиевич Нестеров	valerija2017@yahoo.com	+79402482554	г. Киренск	2025-05-08 00:00:00
123	Максим Даниилович Стрелков	gorshkovviktorin@yandex.ru	+79384659715	к. Тверь	2025-12-10 00:00:00
108	Калинин Константин Эдгарович	ivan65@nezavisimaja.net	+79617199615	клх Иваново	2025-01-03 00:00:00
124	Филатова Кира Львовна	birjukovpantelemon@hotmail.com	+79511365210	клх Бреды	2026-04-08 00:00:00
109	Кузьмина Лукия Сергеевна	nikandrvolkov@hotmail.com	+79651831074	к. Щельяюр	2023-05-26 00:00:00
125	Горшкова Евпраксия Мироновна	pankrat1974@rambler.ru	\N	ст. Холмогоры	2025-06-21 00:00:00
110	Никифорова Лидия Наумовна	\N	\N	п. Томари	2025-07-19 00:00:00
128	Козлова Наина Тарасовна	beljaevprokl@ip.org	\N	ст. Кяхта	2025-12-12 00:00:00
112	Викентий Ефимович Жуков	bronislav87@yandex.ru	+79275919523	ст. Фатеж	2024-12-01 00:00:00
132	Зиновьев Август Ярославович	sokrat1975@kuzmin.net	+79644685429	г. Котельнич	2024-07-25 00:00:00
113	Калашников Эмиль Авдеевич	fedosi_02@npo.com	\N	г. Находка	2024-01-17 00:00:00
134	Аникита Геннадиевич Соколов	ermola_2018@mail.ru	+79890626742	д. Саранск	2026-01-24 00:00:00
115	Савельев Никита Григорьевич	lazargorbachev@ip.ru	+79251064359	г. Буденновск	2025-03-17 00:00:00
135	Прохор Жоресович Овчинников	darja_70@npo.org	+79376908532	с. Сарапул	2025-10-09 00:00:00
117	Клавдия Натановна Устинова	shilovalukija@rao.com	\N	к. Красноуральск	2024-07-03 00:00:00
136	Пелагея Станиславовна Александрова	samson2025@yahoo.com	\N	г. Якша	2024-07-28 00:00:00
118	Кириллова Пелагея Наумовна	fedotovilarion@ao.org	+79106323670	ст. Ардон	2023-11-11 00:00:00
137	Куликов Матвей Терентьевич	alla_79@ip.biz	\N	д. Гремячинск (Бурят.)	2025-03-24 00:00:00
120	Тамара Наумовна Тимофеева	milen1989@mail.ru	+79296225446	д. Камень-на-Оби	2025-03-16 00:00:00
138	Максимильян Филимонович Сидоров	sofon2009@hotmail.com	\N	с. Гремячинск (Бурят.)	2023-07-24 00:00:00
126	Владимир Аверьянович Родионов	ignati_02@rambler.ru	+79965580338	г. Диксон	2025-10-10 00:00:00
144	Таисия Филипповна Кузьмина	dbikov@evon.info	\N	с. Воскресенск	2025-10-02 00:00:00
127	Рюрик Исидорович Алексеев	agafon05@minudobrenija.net	+79628530544	ст. Южноуральск	2024-06-03 00:00:00
148	Регина Львовна Голубева	viktorin_2008@rambler.ru	+79677944609	д. Каргополь	2025-08-13 00:00:00
129	Давыд Бориславович Кулагин	kozlovsilanti@zao.biz	\N	д. Крымск	2025-09-25 00:00:00
149	Лукьян Борисович Исаков	kasjan_28@nordgold.biz	+79893027458	г. Туруханск	2024-03-30 00:00:00
130	Иван Венедиктович Горбунов	ermakovavarvara@td.ru	\N	клх Звенигород	2024-01-14 00:00:00
150	Влас Харитонович Пахомов	psavina@rambler.ru	+79869533218	к. Егорьевск	2023-10-28 00:00:00
131	Беляева Оксана Семеновна	gordeevaevdokija@rambler.ru	+79603102938	с. Нарьян-Мар	2025-06-20 00:00:00
152	Сидорова Дарья Рубеновна	pestovkallistrat@yandex.ru	+79415985367	с. Старая Русса	2026-04-23 00:00:00
133	Гришин Аполлон Елизарович	fokafomichev@gmail.com	\N	д. Быково (метеост.)	2023-06-22 00:00:00
154	Зыкова Анастасия Захаровна	petrsharapov@semenova.net	+79625711790	ст. Иркутск	2026-05-11 00:00:00
139	Лора Ильинична Голубева	gusevaelizaveta@rao.net	+79053256086	г. Верещагино (Перм.)	\N
155	Соловьева София Мироновна	moise46@ooo.info	\N	клх Адлер	2025-10-29 00:00:00
140	Гаврилова Регина Яковлевна	kornil_32@bank.net	+79412221073	с. Чулым	2025-05-08 00:00:00
157	Людмила Олеговна Копылова	ladimirdoronin@hotmail.com	+79147709679	д. Поронайск	2024-10-05 00:00:00
141	Викторин Елисеевич Якушев	\N	+79894807263	г. Верхний Тагил	2023-08-22 00:00:00
158	Фадей Германович Ильин	alekseevgeorgi@npo.org	\N	п. Октябрьское (Хант.)	2024-10-16 00:00:00
142	Вишнякова Алла Матвеевна	ilarionershov@oao.ru	+79546876191	п. Асино	2025-09-09 00:00:00
159	Регина Владимировна Борисова	vsemil96@mail.ru	+79391163514	п. Поярково	2024-07-01 00:00:00
143	Доброслав Бенедиктович Петухов	prohorjakushev@yahoo.com	\N	п. Томари	2024-09-25 00:00:00
160	Мартынова Дарья Альбертовна	naum_72@ip.edu	+79573397840	д. Камышин	2024-02-15 00:00:00
145	Лидия Ниловна Пономарева	kovalevajulija@rambler.ru	+79994575492	с. Березники	2026-04-12 00:00:00
161	Фаина Альбертовна Мамонтова	evstafi1982@ao.ru	\N	ст. Норильск	2023-11-16 00:00:00
146	Баранова Антонина Эдуардовна	ribakovvalentin@npo.net	\N	д. Батайск	2026-01-24 00:00:00
162	Прокофий Эдгардович Носков	ljubim2001@ao.edu	+79268438908	д. Арзамас	2023-10-22 00:00:00
147	Викентий Игнатьевич Смирнов	andreevapraskovja@ooo.info	+79992303073	ст. Поронайск	2026-03-20 00:00:00
166	Владимир Викентьевич Данилов	ipat_77@gureva.ru	+79978227067	г. Стерлитамак	\N
151	Иван Денисович Богданов	milan2004@yandex.ru	\N	к. Тымовское	2023-09-27 00:00:00
167	Баранов Кир Венедиктович	\N	\N	д. Верещагино (Перм.)	2023-10-19 00:00:00
153	Одинцова Агата Олеговна	filatovstojan@yahoo.com	+79717945946	клх Шатой	2024-09-28 00:00:00
168	Фортунат Терентьевич Денисов	fedoseevnifont@mail.ru	+79581642473	клх Петрозаводск	2023-11-18 00:00:00
156	Муравьева Лукия Федоровна	anatoli_63@zao.org	\N	п. Ханты-Мансийск	2026-04-27 00:00:00
169	Лукин Прокофий Юльевич	leonti_1986@npo.org	+79447286055	к. Октябрьское (Челяб.)	2025-06-12 00:00:00
163	Сидорова Агафья Юльевна	upetrov@rambler.ru	\N	с. Губаха	2023-07-22 00:00:00
170	Алевтина Натановна Ермакова	maslovtit@rao.biz	+79021833792	д. Малгобек	2024-11-14 00:00:00
164	Владимиров Тихон Геннадиевич	nikandr1993@yahoo.com	+79035241660	\N	2025-08-12 00:00:00
171	Пономарев Бажен Артемьевич	aristarh25@mail.ru	+79258906986	клх Кизилюрт	2026-01-09 00:00:00
165	Кондратьев Лука Борисович	braginvarlaam@rambler.ru	\N	г. Дивногорск	2026-04-29 00:00:00
172	Архипов Аггей Игнатьевич	kirill85@hotmail.com	+79694469232	д. Нижневартовск	2026-01-07 00:00:00
176	Валентина Егоровна Николаева	moiseevstojan@yandex.ru	\N	к. Чебаркуль	2024-07-15 00:00:00
173	Матвей Алексеевич Игнатьев	jakushevmarian@zhukov.info	+79315081566	с. Старый Оскол	2026-04-10 00:00:00
177	Филарет Ермолаевич Фадеев	qmaksimova@npo.info	\N	с. Верещагино (Перм.)	2025-05-28 00:00:00
174	Регина Эдуардовна Архипова	lidija_88@ooo.com	+79553388913	д. Воркута	2024-08-26 00:00:00
180	Макар Глебович Федосеев	valerjantrofimov@hotmail.com	\N	с. Чусовой	2023-09-10 00:00:00
175	Зыков Иннокентий Игнатьевич	pankrati_96@oao.ru	+79955078872	с. Аргаяш	2025-10-22 00:00:00
182	Устин Игнатьевич Титов	vkrilov@hotmail.com	\N	п. Орел	2025-06-26 00:00:00
178	Кузнецов Матвей Афанасьевич	afanasevaekaterina@yandex.ru	+79476642996	к. Кемерово	2024-11-06 00:00:00
183	Каллистрат Венедиктович Королев	evdokimfokin@mail.ru	\N	п. Миасс	2025-10-20 00:00:00
179	Кулагин Эммануил Егорович	agapmamontov@oao.info	\N	ст. Добрянка	2025-03-18 00:00:00
185	Тимофеев Феофан Елисеевич	dorlov@yandex.ru	+79908179132	ст. Дно	2026-03-22 00:00:00
181	Ирина Архиповна Власова	sharovratmir@reno.com	+79568811983	п. Смоленск	2024-10-14 00:00:00
187	Филатова Олимпиада Афанасьевна	gavrilovasinklitikija@novartis.ru	+79441087900	клх Тутаев	2024-05-12 00:00:00
184	Юлий Александрович Крылов	alla_68@yahoo.com	+79373045064	п. Ейск	2024-06-21 00:00:00
190	Шашкова Анжелика Кузьминична	mokeershov@hotmail.com	+79210777576	ст. Ершов	2024-06-14 00:00:00
186	Ираклий Васильевич Ефремов	fokinazhanna@ip.biz	+79530452018	п. Югорск	2024-06-20 00:00:00
192	Афанасьев Савва Тимурович	natannikitin@mail.ru	+79721421320	ст. Каменск-Шахтинский	2024-10-17 00:00:00
188	Кузьмина Таисия Кузьминична	savelisorokin@gmail.com	+79597967654	г. Кыштым	2023-08-17 00:00:00
193	Ия Кузьминична Веселова	margarita_1986@yahoo.com	\N	с. Сибай	2025-06-29 00:00:00
189	Надежда Ниловна Соболева	savelevjan@ao.org	+79556141725	к. Железногорск(Курск.)	2024-07-01 00:00:00
195	Данилов Селиверст Артемьевич	kulakovstojan@mail.ru	+79428118701	к. Соль-Илецк	2026-03-31 00:00:00
191	Иванова Анна Вениаминовна	zuevaljudmila@gmail.com	\N	ст. Южноуральск	2025-12-26 00:00:00
197	Константинова Тамара Павловна	emmanuilzhukov@yahoo.com	\N	г. Ангарск	2025-04-10 00:00:00
194	Александра Натановна Тихонова	shirjaevostromir@yahoo.com	\N	с. Пушкинские Горы	2023-07-13 00:00:00
198	Дорофеев Лукьян Ермолаевич	izot2004@oao.ru	+79422240582	ст. Суздаль	2024-08-31 00:00:00
196	Конон Терентьевич Селезнев	mitofan_1982@ao.ru	\N	с. Коломна	2024-09-27 00:00:00
203	Антонов Никандр Валерьянович	demjan2018@rambler.ru	+79650967273	клх Дзержинск	2023-07-09 00:00:00
199	  ivan IVANOV 	strelkovdobroslav@oao.edu	+79637119396	г. Туруханск	2023-10-29 00:00:00
205	Кириллова Марина Григорьевна	milenshchukin@blinov.edu	+79875903641	с. Армавир	2025-08-13 00:00:00
200	Агата Богдановна Пестова	bolshakovvissarion@mail.ru	\N	к. Томпа	2023-06-24 00:00:00
207	Лукина Любовь Геннадиевна	kozlovlavrenti@ao.info	\N	к. Буденновск	2025-04-24 00:00:00
201	Гремислав Игнатович Прохоров	bespalovmechislav@sidorova.com	+79414838889	ст. Брянск	2025-08-03 00:00:00
209	Александра Алексеевна Филатова	fedoseevleonti@gmail.com	\N	с. Миллерово	2023-07-07 00:00:00
202	Комиссарова Наталья Даниловна	\N	+79853514394	д. Ейск	2026-01-02 00:00:00
211	Кондратий Владиленович Комаров	dementi_2006@yandex.ru	+79741139461	к. Туапсе	2024-10-26 00:00:00
204	Вероника Афанасьевна Иванова	milenveselov@rosteh.info	\N	клх Омск	2025-10-05 00:00:00
215	Януарий Адамович Селезнев	timur20@ip.org	\N	ст. Карпинск	2023-07-13 00:00:00
206	Аггей Ааронович Ковалев	ljudmila_1981@rambler.ru	\N	д. Кимры	2025-03-29 00:00:00
218	Устин Феликсович Алексеев	kalashnikovanaina@yahoo.com	+79899371401	\N	2025-04-28 00:00:00
208	Агафья Болеславовна Суханова	panfilsorokin@yahoo.com	+79162598077	ст. Сортавала	2024-12-29 00:00:00
219	Сазонова Наталья Сергеевна	taisija_1976@krokus.info	+79772095246	д. Туапсе	2023-11-02 00:00:00
210	Вадим Ефремович Пономарев	glafira_2000@yahoo.com	+79868909792	клх Ребриха	2025-01-23 00:00:00
223	Бирюков Дорофей Трофимович	fedorovairina@npo.org	+79344374884	д. Азов (Рост.)	2025-12-27 00:00:00
212	Олимпиада Святославовна Сысоева	lev2014@gmail.com	+79615766024	к. Санкт-Петербург	2026-01-05 00:00:00
224	Элеонора Наумовна Кондратьева	sharapovanani@rao.biz	+79736665942	д. Поронайск	2025-10-30 00:00:00
213	Лапин Твердислав Ефстафьевич	valerjangorbachev@ooo.ru	+79275354619	д. Нижний Новгород	2024-08-26 00:00:00
225	Галкин Вадим Артемьевич	moiseevfoka@bss.org	\N	с. Ирбит	2024-02-02 00:00:00
214	Потапов Ермил Демидович	simonovaevfrosinija@ooo.biz	\N	к. Верхний Уфалей	2023-09-09 00:00:00
229	Комарова Нонна Павловна	gordeevmodest@yandex.ru	+79490483627	к. Юрьевец (Иван.)	2025-11-23 00:00:00
216	Игорь Тихонович Емельянов	avdeevalora@rao.info	+79169587940	с. Игнашино	2024-03-05 00:00:00
230	Панфилова Алина Георгиевна	anatoli_32@oao.edu	\N	г. Поронайск	2023-06-30 00:00:00
217	Кира Тарасовна Веселова	dorofeevparfen@hotmail.com	+79836873978	п. Каменномостский	2024-02-27 00:00:00
233	Лукия Олеговна Суворова	belozerovartemi@es.edu	\N	с. Клин	\N
220	Викторин Феофанович Хохлов	varvara_40@startteh.edu	+79502533479	ст. Канск	2026-02-20 00:00:00
236	Марина Валентиновна Котова	rgorshkova@gmail.com	+79233291033	ст. Медногорск	2025-03-16 00:00:00
221	Сигизмунд Изотович Стрелков	pshubin@gmail.com	\N	клх Надым	2024-01-10 00:00:00
237	Януарий Бенедиктович Егоров	emeljanovlavr@rao.ru	+79936895083	клх Адыгейск	2023-09-25 00:00:00
222	Артемьева Полина Руслановна	\N	\N	с. Бузулук	2025-12-29 00:00:00
239	Галактион Адамович Колобов	lsilina@rambler.ru	\N	с. Карпинск	2026-02-13 00:00:00
226	Аполлинарий Гаврилович Силин	egor_2016@ip.org	+79753703117	ст. Стерлитамак	2024-03-30 00:00:00
241	Гордеева Лариса Антоновна	valerjanfomichev@rosbank.net	+79603857319	ст. Пятигорск	2025-08-03 00:00:00
227	Савина Алла Вениаминовна	vladlenuvarov@zao.net	\N	д. Приозерск	2024-09-07 00:00:00
244	Зиновьев Сергей Ефимьевич	pankrati05@npo.info	\N	к. Шерегеш	2024-12-19 00:00:00
228	Емельян Тарасович Аксенов	ermolagordeev@hotmail.com	\N	к. Курганинск	2024-03-07 00:00:00
246	Доронина Лидия Наумовна	pankrat1991@sitnikova.net	+79608795036	\N	2025-04-18 00:00:00
231	Сысоев Куприян Федотович	emmanuil_1973@rao.edu	\N	д. Надым	2023-10-12 00:00:00
247	Пелагея Рубеновна Комиссарова	sofongavrilov@zao.net	+79746936347	к. Лысьва	2024-04-25 00:00:00
232	тов. Бирюков Харлампий Адамович	januaribolshakov@yahoo.com	+79086167773	к. Саранск	2025-03-08 00:00:00
251	Кир Гурьевич Сергеев	aleksandrovladislav@moskovski.org	+79489636644	\N	2025-11-07 00:00:00
234	Харитонова Алла Оскаровна	artemi_95@rao.biz	+79407245006	п. Находка	2024-09-09 00:00:00
252	Чернов Мокей Тихонович	\N	\N	к. Цимлянск	2024-04-17 00:00:00
235	Фомичева Ольга Вячеславовна	ljubomir_87@yahoo.com	+79708881871	ст. Гдов	2026-03-22 00:00:00
256	Степанова Антонина Оскаровна	prokofi_85@yahoo.com	\N	клх Октябрьское (Хант.)	2026-03-20 00:00:00
238	Фомин Гордей Жоресович	jan89@zao.net	+79285234845	г. Яшалта	2025-12-31 00:00:00
257	Любовь Сергеевна Лаврентьева	naum24@peterburgski.ru	+79510564546	г. Нижневартовск	2026-04-25 00:00:00
240	Зуев Афанасий Гертрудович	kuzminamvrosi@gmail.com	\N	д. Кырен	2024-03-19 00:00:00
258	Артемьева Акулина Робертовна	borisovdenis@gmail.com	\N	клх Салехард	2025-07-15 00:00:00
242	Никифоров Афанасий Игоревич	nsisoev@yandex.ru	+79909602544	д. Амурск	2024-03-19 00:00:00
260	Артемьев Селиван Феофанович	kirillovzosima@rao.org	+79150270803	д. Майкоп	2023-06-27 00:00:00
243	Харитон Федотович Фомин	vasilevanani@ip.org	+79817865301	п. Кош-Агач	2024-09-07 00:00:00
261	Мясников Анатолий Ильясович	shcherbakovanaina@gmail.com	+79787096051	д. Выборг	2025-09-21 00:00:00
245	Ия Кирилловна Киселева	sofija1998@rao.ru	\N	г. Балашиха	2025-10-21 00:00:00
262	Козлов Владислав Эдгардович	nonna43@oao.ru	+79552909784	г. Псков	2025-12-20 00:00:00
248	Тихонова Александра Станиславовна	juri_2012@mail.ru	+79776914430	п. Кизляр	2024-11-23 00:00:00
263	Марк Гертрудович Комаров	sazonovsofron@hotmail.com	+79088087644	с. Лянтор	2024-03-09 00:00:00
249	Семенова Феврония Тимуровна	vasilevmoke@npo.edu	+79773430762	ст. Новая Игирма	2024-06-23 00:00:00
266	Максимов Ефрем Харлампович	feraponteliseev@ao.com	+79614137833	к. Лодейное Поле	2026-02-11 00:00:00
250	Семенов Станимир Давыдович	nifonttitov@gmail.com	+79717490982	клх Пушкино (Моск.)	2024-01-14 00:00:00
267	Воронцова Ангелина Никифоровна	popovaviktorija@rambler.ru	+79296311802	д. Казань	2023-10-23 00:00:00
253	Турова Иванна Кузьминична	dementi69@mail.ru	+79159877461	с. Колпашево	2025-03-10 00:00:00
270	Евпраксия Афанасьевна Турова	ustinovapollon@yahoo.com	\N	ст. Кимры	2025-08-31 00:00:00
254	Измаил Ермолаевич Аксенов	ponomarevaagafja@gmail.com	+79426164289	к. Усть-Илимск	2025-07-13 00:00:00
272	Шилов Лазарь Ярославович	agafon_1972@rambler.ru	+79780839406	ст. Юрюзань	2026-04-19 00:00:00
255	Марфа Семеновна Кузьмина	mihe91@rao.info	+79921505800	д. Чулым	2023-06-08 00:00:00
274	Власов Варфоломей Елисеевич	lev_93@zao.info	\N	с. Воткинск	2025-08-01 00:00:00
259	Белова Маргарита Геннадьевна	kiselevvseslav@hotmail.com	\N	ст. Одинцово	2025-03-09 00:00:00
275	Варвара Кирилловна Архипова	fade36@oao.com	+79685240944	г. Шатой	2025-02-08 00:00:00
264	Сергеев Любосмысл Ярославович	gmaslova@mail.ru	\N	к. Нурлат	2025-07-26 00:00:00
279	Пелагея Александровна Голубева	pankrat1985@hotmail.com	+79783993370	г. Буйнакск	2026-02-26 00:00:00
265	Мария Сергеевна Лыткина	drozdovfeofan@vertoleti.edu	+79640942859	п. Кыштым	2026-03-12 00:00:00
282	Моисеева Таисия Андреевна	kirillovarkadi@a-ol.info	\N	д. Рославль	2023-10-01 00:00:00
268	Гущина Жанна Александровна	\N	\N	д. Туапсе	2025-06-14 00:00:00
285	Лихачева Элеонора Захаровна	parfen_1973@mostotrest.ru	+79377940931	д. Азов (Рост.)	2024-05-05 00:00:00
269	Синклитикия Захаровна Никонова	zharitonov@rambler.ru	\N	ст. Карабудахкент	2024-11-07 00:00:00
286	Нинель Семеновна Зайцева	kshirjaev@gmail.com	+79107882750	д. Новомосковск	2024-01-01 00:00:00
271	Анжелика Николаевна Елисеева	fomichevpavel@rambler.ru	+79314335845	с. Березники	2024-11-08 00:00:00
287	Анжела Никифоровна Мельникова	isa_69@ip.biz	+79762418359	клх Неплюевка	2025-04-02 00:00:00
273	Дьячкова Вероника Натановна	efremovkonon@ip.ru	\N	п. Плес	2025-05-22 00:00:00
288	Герасимова Виктория Оскаровна	kondrat1993@yahoo.com	+79525749126	п. Кострома	2024-01-31 00:00:00
276	Якушева Вера Ильинична	amos_1992@hotmail.com	\N	п. Новороссийск	2025-04-05 00:00:00
290	Фролова Иванна Оскаровна	kondratibaranov@rambler.ru	\N	п. Сусуман	2023-07-09 00:00:00
277	Казимир Устинович Маслов	andron1972@zao.org	\N	к. Морозовск	2025-08-06 00:00:00
291	Игнатьев Симон Гаврилович	antonina_85@ip.biz	+79121559383	п. Апрелевка	2024-01-05 00:00:00
278	Раиса Вадимовна Юдина	ljudmila2008@zao.ru	+79729667145	г. Верхний Уфалей	2025-11-29 00:00:00
294	Аким Жоресович Орехов	julichernov@npo.net	+79884598890	к. Мурманск	2024-03-04 00:00:00
280	Васильев Всеволод Анатольевич	afinogen46@poljakov.com	+79748143863	к. Арзамас	2023-11-23 00:00:00
295	Уваров Исай Викторович	admitriev@npo.org	\N	г. Цимлянск	2023-06-02 00:00:00
281	Артем Дорофеевич Герасимов	semen_2008@oao.info	+79943497632	п. Усть-Катав	2025-11-08 00:00:00
296	Гурьев Порфирий Гертрудович	andreevpetr@ooo.ru	+79657952227	г. Александровск-Сахалинский	2024-06-28 00:00:00
283	Николаева Прасковья Дмитриевна	evdokija94@zao.com	+79417509245	ст. Серафимович	2026-05-04 00:00:00
298	Юдин Ефрем Федосьевич	gleb1974@messojahaneftegaz.biz	+79432557724	п. Йошкар-Ола	2024-12-02 00:00:00
284	Маргарита Григорьевна Носкова	rodionovluchezar@ooo.edu	+79491291025	д. Усмань	2024-02-03 00:00:00
299	Олимпиада Валериевна Никифорова	potap71@oao.net	+79524033772	д. Шахты	2025-11-05 00:00:00
289	Голубев Сергей Егорович	jsitnikova@yandex.ru	\N	клх Углич	2024-06-05 00:00:00
301	Носова Полина Натановна	\N	+79437981615	с. Шенкурск	2024-07-02 00:00:00
292	Савин Добромысл Иосифович	potap40@gmail.com	+79058786679	к. Ревда (Сверд.)	2024-02-05 00:00:00
304	Киселева Анжела Мироновна	florentin2025@gmail.com	\N	\N	2023-12-31 00:00:00
293	Милица Дмитриевна Осипова	paramon17@oao.net	+79573695421	с. Кетченеры	2024-06-07 00:00:00
308	Олег Игоревич Нестеров	nadezhda_1973@oao.info	+79178702585	п. Дербент	2024-03-14 00:00:00
297	Ангелина Кирилловна Князева	simonlitkin@rambler.ru	+79817626034	ст. Буйнакск	2023-08-21 00:00:00
309	Трифон Ермилович Панов	dementevigor@gmail.com	+79692156071	д. Коломна	2025-11-18 00:00:00
300	Соболева Элеонора Мироновна	evdokija_2010@yandex.ru	+79275393773	клх Джубга	2024-10-19 00:00:00
310	Анжела Оскаровна Большакова	polina_1995@yahoo.com	+79383107687	п. Черкесск	2024-11-04 00:00:00
302	Зыкова Кира Ниловна	adrian97@zao.biz	+79947198944	с. Ангарск	2025-11-04 00:00:00
311	Марина Игоревна Горбачева	pankrat_2002@yandex.ru	+79076248559	к. Долинск	2025-01-24 00:00:00
303	Карл Афанасьевич Зиновьев	dorofe82@mail.ru	+79321845795	клх Бомнак	2024-01-15 00:00:00
312	Нинель Филипповна Некрасова	agata_1971@oao.info	+79924291998	\N	2025-11-17 00:00:00
305	Мефодий Изотович Буров	uljan2014@hotmail.com	+79746891707	ст. Кинешма	2025-01-12 00:00:00
315	Рябов Филимон Якубович	gushchinernest@oao.org	+79218181642	с. Павловская	2026-04-01 00:00:00
306	Кондрат Захарьевич Никитин	radovan62@zao.net	+79394666352	ст. Ямбург	2026-05-20 00:00:00
319	Лидия Рудольфовна Гаврилова	ikotov@gmail.com	+79031521039	д. Пинега	2023-08-21 00:00:00
307	Маргарита Болеславовна Некрасова	afanasevaagafja@yandex.ru	+79564593790	д. Нефтекамск	2025-11-26 00:00:00
320	Гаврилов Творимир Адамович	baranovorest@yandex.ru	\N	д. Рубцовск	2023-10-24 00:00:00
313	Емельян Витальевич Александров	prokl98@npo.edu	\N	ст. Шахты	2025-08-22 00:00:00
322	Никифор Валерианович Прохоров	ilja68@yahoo.com	+79862338680	п. Середниково	2023-08-05 00:00:00
314	Крюков Тихон Александрович	ernest52@gmail.com	+79454810443	п. Адлер	2025-07-24 00:00:00
325	Софон Еремеевич Чернов	birjukovljubosmisl@rambler.ru	\N	п. Тырныауз	2025-06-15 00:00:00
316	Рябов Константин Даниилович	fadeevsevastjan@rao.com	\N	к. Ишим	2024-01-14 00:00:00
326	Сила Тимурович Смирнов	danila71@hotmail.com	+79161669421	г. Волгоград	\N
317	Прокл Васильевич Абрамов	seliverst_00@yahoo.com	+79013598909	г. Темрюк	2025-02-12 00:00:00
329	Богдан Филиппович Захаров	seliverstsharov@hotmail.com	\N	г. Мончегорск	2025-11-26 00:00:00
318	Быкова Иванна Юрьевна	kolesnikovakim@ooo.ru	+79840725996	п. Руза	2023-06-22 00:00:00
331	Иванов Варлаам Тихонович	rfomichev@promsvjazbank.biz	\N	клх Минусинск	2024-12-30 00:00:00
321	  ivan IVANOV 	\N	+79047285340	к. Кажим	2023-10-25 00:00:00
333	Медведев Леон Викторович	nikifor_1997@npo.org	+79908138715	к. Абакан	2024-09-08 00:00:00
323	Рогова Полина Максимовна	eduard2016@yandex.ru	+79924274419	к. Когалым	2024-03-01 00:00:00
334	Антонина Олеговна Соловьева	qisakov@npo.com	\N	клх Рославль	2024-07-28 00:00:00
324	Авдей Валерьевич Лазарев	viktorin_28@rambler.ru	\N	клх Екатеринбург	2024-01-06 00:00:00
335	Вера Васильевна Лапина	nikon2025@gmail.com	+79311966923	клх Оха	2025-03-29 00:00:00
327	Пахом Ефремович Щукин	ribakovnifont@kulikov.edu	\N	к. Тихорецк	2024-02-18 00:00:00
338	Дмитриева Елена Валериевна	romanovgostomisl@rambler.ru	+79216876560	с. Каргополь	\N
328	Вячеслав Аксёнович Зимин	filipp1988@oao.biz	\N	ст. Волгоград	2024-04-13 00:00:00
341	Орлова Синклитикия Эльдаровна	aleksandra62@gmail.com	+79839575663	к. Буденновск	2023-09-01 00:00:00
330	Харлампий Германович Васильев	novikovatatjana@yandex.ru	+79280236885	д. Ангарск	2024-10-15 00:00:00
344	Панфилова Алина Эльдаровна	gromovharlampi@yahoo.com	+79901108031	ст. Хасан	2025-09-02 00:00:00
332	Петров Харитон Давидович	pavel2000@ooo.com	+79156485536	с. Котельнич	2024-02-27 00:00:00
345	Коновалов Максимильян Иосипович	svjatoslav_13@oao.ru	+79457051399	с. Белокуриха	2024-01-31 00:00:00
336	Яковлев Святополк Августович	petuhovselivan@oao.org	+79884412594	\N	2025-08-13 00:00:00
346	Козлова Регина Ниловна	evse_1996@gmail.com	+79870161616	д. Наро-Фоминск	2024-09-09 00:00:00
337	Иосиф Георгиевич Силин	mishinmihail@yandex.ru	+79069226321	к. Каменск-Уральский	2025-09-06 00:00:00
348	Горбунов Радим Гертрудович	karl07@rambler.ru	\N	клх Нефтекамск	2023-11-23 00:00:00
339	Глафира Натановна Миронова	narkis_53@mail.ru	\N	с. Моздок	2024-09-23 00:00:00
350	Евсеева Феврония Рубеновна	azari_83@npo.net	+79714609188	с. Двинской	2024-03-08 00:00:00
340	Беспалов Тит Юлианович	skolobova@yandex.ru	+79071894559	п. Оренбург	2023-05-31 00:00:00
352	Эмилия Егоровна Емельянова	afanasevjuli@gazprom.edu	+79783269182	ст. Мыс Шмидта	2026-01-21 00:00:00
342	Людмила Николаевна Селиверстова	rozhkovalora@drozdova.org	+79027984900	ст. Луга	2023-06-18 00:00:00
354	Кононов Никон Харламович	kirill53@mail.ru	\N	г. Катав-Ивановск	2025-01-04 00:00:00
343	Волков Вышеслав Эдгарович	ivanna_62@rao.org	+79506467254	г. Тольятти	2025-10-01 00:00:00
355	Зайцев Михаил Терентьевич	kondrat_2023@rao.net	+79446595822	к. Джубга	2023-12-09 00:00:00
347	Денис Феофанович Дроздов	samsonovfilipp@yahoo.com	+79365887237	д. Юровск	2024-11-09 00:00:00
356	Зиновьева Нинель Федоровна	evgraf92@rambler.ru	\N	ст. Крымск	2025-02-10 00:00:00
349	Алла Ивановна Маркова	mina1983@npo.info	+79786356993	д. Новомичуринск	2023-05-26 00:00:00
358	Натан Августович Денисов	akulina_27@ohk.info	\N	к. Энгельс	2026-03-09 00:00:00
351	Евлампий Чеславович Уваров	\N	\N	ст. Тайшет	2023-11-06 00:00:00
360	Щукина Вера Антоновна	dobroslavkudrjashov@rambler.ru	+79644476518	г. Касимов	2023-08-13 00:00:00
353	Ларионов Степан Ерофеевич	\N	+79217512195	д. Набережные Челны	2024-10-03 00:00:00
361	Горшков Устин Изотович	uljana_14@ooo.org	\N	п. Темрюк	2023-11-04 00:00:00
357	Цветкова Майя Олеговна	gromovkazimir@oao.edu	+79701955386	д. Александровск-Сахалинский	2025-08-27 00:00:00
362	Лариса Станиславовна Моисеева	emilprohorov@rao.com	+79047907058	клх Лысьва	2023-12-05 00:00:00
359	Нестерова Милица Эльдаровна	antonin96@rao.edu	+79421875543	\N	2025-04-11 00:00:00
363	Мир Архипович Котов	morozovuljan@blinov.edu	\N	д. Иваново	2025-10-05 00:00:00
365	Горшкова Алевтина Геннадьевна	foti2022@zao.biz	\N	ст. Андреаполь	2024-07-02 00:00:00
364	Василиса Валериевна Сергеева	ilja_2006@rambler.ru	+79499387663	ст. Сунтар	2025-10-17 00:00:00
368	  ivan IVANOV 	svjatopolk_88@ip.info	\N	д. Иркутск	2023-12-03 00:00:00
366	Зинаида Вячеславовна Симонова	maslovboleslav@gmail.com	\N	п. Приозерск	2024-03-28 00:00:00
372	Елизавета Болеславовна Фомичева	uljana2015@rti.org	\N	д. Терней	2026-05-16 00:00:00
367	Третьякова Анжела Григорьевна	ibolshakova@yahoo.com	\N	к. Адыгейск	2023-07-21 00:00:00
375	Глафира Григорьевна Одинцова	galina65@yandex.ru	\N	г. Абакан	2026-04-05 00:00:00
369	Корнил Бенедиктович Агафонов	fekla_68@rambler.ru	+79450535448	д. Ряжск	2026-04-01 00:00:00
376	Гордеева Анна Натановна	umorozov@ooo.net	+79222973517	п. Пятигорск	2024-05-22 00:00:00
370	Кудрявцев Вадим Иларионович	kornilovuljan@mail.ru	\N	д. Омск	2025-12-16 00:00:00
377	Ирина Макаровна Тимофеева	svjatoslav_75@oao.biz	\N	клх Красная Поляна	2024-08-17 00:00:00
371	Януарий Федосеевич Антонов	naum_50@maksidom.ru	+79653538609	г. Абакан	2024-02-28 00:00:00
378	Феврония Афанасьевна Кулагина	ribakovamarina@mail.ru	+79934671611	с. Октябрьское (Хант.)	2026-05-23 00:00:00
373	Любовь Сергеевна Кулагина	kovalevafanasi@yandeks.ru	+79322638422	п. Якша	2025-10-10 00:00:00
380	Надежда Степановна Зуева	tihonovataisija@yahoo.com	+79928389318	п. Новосибирск	2026-01-07 00:00:00
374	Емельянов Григорий Валерианович	nadezhda_65@npo.info	\N	с. Асбест	2023-07-22 00:00:00
382	Тимофеева Валерия Никифоровна	bojanaleksandrov@ao.net	+79627588309	к. Медногорск	2026-05-07 00:00:00
379	Федот Терентьевич Сысоев	ddementeva@rambler.ru	\N	к. Яхрома	2025-05-06 00:00:00
384	Кузьмина Галина Тарасовна	romanovanadezhda@rambler.ru	\N	г. Андреаполь	2025-08-25 00:00:00
381	Евгения Аркадьевна Воронова	morozovsofron@gmail.com	+79398299245	п. Верхнее Пенжино	2025-12-12 00:00:00
385	Комиссаров Кирилл Измаилович	varfolome_20@npo.info	\N	к. Канск	2025-01-10 00:00:00
383	Панкратий Тихонович Фокин	proklandreev@hotmail.com	+79116076355	к. Губкин	2023-07-22 00:00:00
386	Белоусова Вероника Болеславовна	anikitakuznetsov@yahoo.com	\N	п. Качканар	2026-01-10 00:00:00
389	Кузьма Юлианович Фомин	radim07@rambler.ru	+79329730298	с. Качканар	2023-12-07 00:00:00
387	Алина Рубеновна Романова	anatoli_1977@gmail.com	\N	ст. Якутск	2025-10-04 00:00:00
390	Мария Антоновна Кудрявцева	avdeevaninel@oao.info	\N	к. Быково (метеост.)	2024-03-30 00:00:00
388	Исаева Юлия Степановна	alina2014@yahoo.com	+79929278133	к. Челябинск	2025-11-23 00:00:00
391	Василиса Валентиновна Князева	danila_29@zao.org	+79192403553	клх Бологое	2024-07-28 00:00:00
392	Лукьян Анатольевич Киселев	alekseevajulija@metallotorg.ru	+79768443155	с. Минусинск	2023-09-27 00:00:00
393	Бирюкова Агафья Ждановна	kotovjulian@rambler.ru	+79978923183	г. Красногорск (Моск.)	2026-04-04 00:00:00
396	Валерия Рубеновна Логинова	nikolaevazari@hotmail.com	\N	с. Ржев	2024-08-26 00:00:00
394	Маргарита Тимуровна Зыкова	sergeevauljana@ip.ru	+79680202067	ст. Шарья	\N
398	Шашков Чеслав Ярославович	\N	\N	д. Партизанск	2025-05-24 00:00:00
395	Денис Иосифович Васильев	mironovaskold@zao.biz	+79004427929	п. Беломорск	2025-07-17 00:00:00
399	Шестаков Доброслав Теймуразович	hristoforzuev@ip.biz	\N	п. Саратов	2026-05-07 00:00:00
397	Виктор Борисович Устинов	xkarpova@rao.edu	+79674456597	к. Солнечногорск	2024-09-11 00:00:00
400	Вера Кузьминична Котова	cponomareva@oao.edu	+79740613153	г. Кущевская	2025-09-19 00:00:00
403	Изяслав Ильясович Савин	\N	\N	ст. Благовещенск (Амур.)	2024-06-15 00:00:00
401	Аполлон Жанович Носков	seliverst1990@hotmail.com	+79009990686	клх Темрюк	2026-01-21 00:00:00
404	Дмитрий Егорович Чернов	galaktion1994@ao.info	\N	с. Талдом	2024-07-04 00:00:00
402	Гедеон Евстигнеевич Васильев	spartak_2003@ip.info	\N	г. Осташков	2026-02-08 00:00:00
406	Воронцова Акулина Валериевна	kiselevapraskovja@yandex.ru	+79053773200	к. Обоянь	2023-09-30 00:00:00
405	Мельникова Александра Анатольевна	burovfilimon@yahoo.com	+79971499471	п. Соликамск	2026-05-14 00:00:00
410	Мельникова Лукия Филипповна	emeljan1983@oao.biz	+79978422280	клх Черусти	2023-06-30 00:00:00
407	Логинова Анастасия Кирилловна	zoja2011@rao.info	\N	г. Петрозаводск	2025-05-21 00:00:00
412	Сигизмунд Давидович Артемьев	dmitrikudrjavtsev@hotmail.com	\N	клх Дербент	2023-05-28 00:00:00
408	Рубен Ефимьевич Лазарев	samolovatatjana@mail.ru	\N	клх Кандалакша	2023-11-21 00:00:00
414	Севастьян Арсенович Харитонов	faina13@yandex.ru	+79658111412	д. Нерчинск	2024-02-28 00:00:00
409	Наина Валентиновна Красильникова	kuzma_1994@ikea.net	+79537643124	п. Урус-Мартан	2026-02-19 00:00:00
415	Муравьева Агата Антоновна	lturova@rambler.ru	+79304384516	п. Бугуруслан	2026-03-31 00:00:00
411	Громова Олимпиада Геннадиевна	qjudin@zao.biz	+79121265692	\N	2024-09-23 00:00:00
416	Оксана Аскольдовна Игнатьева	serafim2015@vinogradov.com	+79476944168	д. Избербаш	2026-02-18 00:00:00
413	Логинов Олег Игоревич	dveselov@hotmail.com	\N	клх Урюпинск	2023-09-10 00:00:00
418	Комаров Егор Валентинович	jaropolk_91@yandex.ru	\N	п. Глазов	2026-02-11 00:00:00
417	г-н Матвеев Творимир Гертрудович	maksimkabanov@hotmail.com	+79886812783	г. Каменск-Уральский	2025-08-28 00:00:00
421	Регина Феликсовна Морозова	koshelevjuvenali@yahoo.com	\N	с. Кропоткин (Краснод.)	2025-01-30 00:00:00
419	Федосеева Галина Ильинична	emeljanovaelizaveta@gmail.com	+79797147094	\N	2023-06-09 00:00:00
422	Селиван Виленович Сазонов	mili_2010@rambler.ru	\N	ст. Елатьма	2024-06-13 00:00:00
420	Элеонора Тарасовна Сергеева	evlasova@ao.net	\N	ст. Владимир	2023-09-10 00:00:00
424	Полякова Алина Семеновна	ytretjakov@rambler.ru	\N	клх Ржев	2024-10-03 00:00:00
423	Устинова Клавдия Вячеславовна	visheslav2011@yahoo.com	+79957513948	г. Славгород	2025-09-19 00:00:00
425	Григорьева Евдокия Аскольдовна	rodion39@nikolaeva.edu	+79653901994	клх Великий Устюг	2025-05-07 00:00:00
427	Шилова Октябрина Леоновна	zhukovaakulina@mail.ru	+79946669037	г. Торжок	2024-10-29 00:00:00
426	Дементий Ильясович Козлов	evdokimpanfilov@hotmail.com	\N	г. Махачкала	2024-05-07 00:00:00
430	Тетерин Радим Феофанович	ermakovisidor@rao.info	+79286665729	ст. Екатеринбург	2024-08-08 00:00:00
428	Туров Моисей Ильясович	bikovalarisa@ooo.edu	\N	ст. Сусуман	2023-07-28 00:00:00
431	Тимофеева Таисия Семеновна	foka2004@npo.ru	\N	клх Гремячинск (Перм.)	2024-06-02 00:00:00
429	Александр Артурович Никитин	\N	+79716354624	\N	2026-02-01 00:00:00
432	Бобров Георгий Гавриилович	smirnovvenedikt@mail.ru	+79602659666	д. Горячинск	2024-12-02 00:00:00
435	Нина Игоревна Лаврентьева	fedot_2017@hotmail.com	+79778371032	с. Сасово	2026-04-25 00:00:00
433	Ширяев Ян Арсеньевич	valerinazarov@samsonova.com	+79484966397	к. Юровск	2025-05-21 00:00:00
436	Гаврилова Маргарита Алексеевна	timur_1981@sibirskaja.info	+79356694326	с. Соловки	2023-12-14 00:00:00
434	Лукия Борисовна Рожкова	iosif_1997@npo.ru	\N	к. Рыльск	2024-04-27 00:00:00
437	Пелагея Святославовна Яковлева	prokltretjakov@ooo.ru	\N	с. Юрюзань	2025-07-24 00:00:00
440	Ипатий Артёмович Стрелков	beljaevavalentina@gmail.com	\N	д. Когалым	2023-12-20 00:00:00
438	Сократ Гурьевич Копылов	dementi_1976@hotmail.com	\N	к. Гремячинск (Бурят.)	2023-07-25 00:00:00
441	Кудрявцев Антип Бенедиктович	\N	\N	с. Ямбург	2024-02-22 00:00:00
439	Филарет Алексеевич Наумов	hristofor24@mail.ru	\N	д. Кондопога	2024-07-29 00:00:00
442	Миронов Ярослав Евстигнеевич	filippovevdokim@rao.edu	\N	с. Гаврилов-Ям	2024-02-17 00:00:00
444	Роман Яковлевич Власов	ostap2017@ip.org	+79455491430	к. Муром	2025-03-17 00:00:00
443	Михеева Марфа Федоровна	rjabovrjurik@zao.ru	+79218917878	к. Верхнее Пенжино	2025-02-22 00:00:00
446	Белоусов Артемий Якубович	averjanbeljaev@yandex.ru	+79244432632	д. Нязепетровск	2025-09-08 00:00:00
445	Игнатова Наталья Леоновна	silanti_70@oao.net	+79165092727	к. Кизляр	2023-09-25 00:00:00
447	Харлампий Ефимьевич Панов	julija_1990@kuznetsova.org	+79688722430	г. Урай	2024-11-01 00:00:00
448	Абрамов Владимир Матвеевич	dvlasov@mail.ru	+79736456606	клх Яхрома	2023-12-08 00:00:00
449	Евгения Васильевна Кузнецова	kallistrat_2012@ip.org	+79316730716	г. Краснокамск	2025-02-23 00:00:00
450	Агата Робертовна Бобылева	platon69@mail.ru	\N	к. Тикси	2024-10-21 00:00:00
452	Герасимов Боян Бориславович	varlaammorozov@gromova.net	\N	г. Яр-Сале	2025-02-16 00:00:00
451	Севастьян Адрианович Сорокин	zahar_2010@ip.edu	+79268665437	клх Аргаяш	2024-12-01 00:00:00
455	Тамара Вячеславовна Кузьмина	haritonovapollon@porshe.info	+79328216558	г. Гаврилов-Ям	2025-11-24 00:00:00
453	Октябрина Андреевна Орехова	efrembeljaev@hotmail.com	+79269173782	г. Великие Луки	2025-09-12 00:00:00
456	Аполлон Иларионович Кононов	bobilevmitofan@velesstro.edu	\N	д. Белогорск (Амур.)	2026-04-11 00:00:00
454	Михей Вилорович Большаков	epifanshilov@poljakov.net	+79665200007	к. Токсово	2024-07-03 00:00:00
457	Гущина Акулина Константиновна	naumovafekla@ao.com	+79994127280	г. Светлогорск (Калин.)	2025-05-08 00:00:00
463	Милица Степановна Федорова	elizarabramov@yandex.ru	\N	ст. Вязьма	2023-08-27 00:00:00
458	  ivan IVANOV 	gshashkov@rambler.ru	+79210917183	с. Аршан (Бурят.)	2023-12-04 00:00:00
467	Павлов Ювеналий Венедиктович	sazonovaalla@gmail.com	+79175503139	с. Юрюзань	2025-03-07 00:00:00
459	Варвара Святославовна Галкина	silinaksenija@aleksandrov.ru	\N	п. Курумкан	2023-09-20 00:00:00
468	Абрамов Чеслав Валерьевич	rusakovataisija@natsionalnaja.org	\N	к. Новый Уренгой	2025-11-12 00:00:00
460	Анисим Георгиевич Трофимов	oksana2021@gmail.com	\N	с. Дно	2025-05-20 00:00:00
472	Дьячков Корнил Устинович	nadezhda81@mail.ru	+79527152884	к. Россошь	2025-09-22 00:00:00
461	Виноградова Валентина Тарасовна	kazakovkondrat@gmail.com	+79504727411	г. Шарья	2025-07-27 00:00:00
474	Тетерина Оксана Руслановна	karpovaninel@npo.ru	\N	клх Санкт-Петербург	2025-12-28 00:00:00
462	Колобов Ладислав Демидович	nifont1973@chernov.info	\N	п. Петропавловск-Камчатский	2025-03-31 00:00:00
477	Петр Яковлевич Жданов	jakov_34@zao.info	+79796065791	ст. Объячево	2026-03-29 00:00:00
464	Платон Денисович Родионов	bogdanovaninel@mail.ru	\N	к. Кашхатау	2024-03-22 00:00:00
478	Фаина Евгеньевна Брагина	cefimova@lokoteh.net	+79941420660	г. Снежинск	2023-06-03 00:00:00
465	Голубева Людмила Константиновна	savvaseleznev@yandex.ru	+79293663355	д. Андреаполь	2025-02-12 00:00:00
480	Шаров Мина Якубович	ustin_09@ao.biz	\N	д. Можга	2025-02-20 00:00:00
466	Синклитикия Вениаминовна Яковлева	zinaida06@hotmail.com	\N	\N	2024-11-12 00:00:00
481	Панфил Борисович Фокин	larionovfortunat@yandex.ru	\N	п. Астрахань	2025-02-21 00:00:00
469	Князева Вероника Ивановна	evgeniuvarov@yahoo.com	\N	д. Нефедова	2025-04-13 00:00:00
483	Леонид Зиновьевич Михайлов	kudrjashovrjurik@ooo.biz	+79859910144	клх Тымовское	2023-09-16 00:00:00
470	Лукина Майя Васильевна	bronislav_92@hotmail.com	\N	п. Нефтекамск	2026-02-28 00:00:00
488	Мечислав Егорович Лыткин	dgolubev@gmail.com	+79016499677	п. Кущевская	2023-06-29 00:00:00
471	Антонина Федоровна Жукова	vladislavsokolov@mail.ru	\N	п. Истра	2025-02-25 00:00:00
489	Олимпий Аверьянович Ковалев	evstafimjasnikov@ooo.edu	\N	\N	2023-06-07 00:00:00
473	Гаврилова Валентина Макаровна	\N	\N	п. Ведено	2024-07-30 00:00:00
492	Мельникова Майя Аскольдовна	sharapovanike@rao.info	+79587976885	г. Карабулак	\N
475	Акулина Яковлевна Панфилова	ivanovaoktjabrina@pochta.ru	\N	д. Бавлы	2024-01-03 00:00:00
496	Щукина Жанна Дмитриевна	radovan_44@ip.biz	+79382281482	ст. Яшалта	2024-01-10 00:00:00
476	Павлов Милен Авдеевич	bojan2003@oao.com	+79246408985	ст. Катайск	2025-04-19 00:00:00
497	Ратмир Бориславович Калинин	bogdan2007@ao.ru	\N	п. Обоянь	2025-02-20 00:00:00
479	Евфросиния Матвеевна Андреева	avgust_2012@yandex.ru	+79438994061	п. Ноябрьск	2023-06-27 00:00:00
499	Орлова Ольга Владимировна	lebedevanisim@aktsionerni.ru	\N	д. Ачхой Мартан	2025-08-14 00:00:00
482	Федор Эдгарович Лобанов	valerjan55@hotmail.com	\N	г. Кировск (Мурм.)	2026-01-26 00:00:00
503	Котова Лора Максимовна	isa1984@ao.edu	+79596291839	с. Томари	2023-11-17 00:00:00
484	Фомичева Фёкла Игоревна	\N	\N	г. Шамары	2026-05-02 00:00:00
504	Анна Феликсовна Гришина	xkostin@hotmail.com	\N	д. Саянск	2025-08-03 00:00:00
485	Игнатова Агафья Егоровна	mihail55@ip.org	+79787717646	д. Буденновск	2023-07-30 00:00:00
507	Варвара Николаевна Сорокина	martjan2014@oao.edu	+79697787747	п. Сосногорск	2024-07-28 00:00:00
486	Соболева Олимпиада Михайловна	radovan_99@zao.edu	+79013069476	г. Апшеронск	2023-09-17 00:00:00
510	Рубен Витальевич Федосеев	blohinasinklitikija@filatov.com	+79692181541	с. Биробиджан	2023-07-14 00:00:00
487	Ефрем Ефимьевич Абрамов	fsharov@anisimova.net	\N	к. Нижний Новгород	2026-02-14 00:00:00
511	Шарапов Парамон Давыдович	uignatov@rambler.ru	+79559350437	п. Усть-Ишим	\N
490	Андреев Влас Давидович	vladilen_2002@yandex.ru	\N	к. Архыз	2025-05-05 00:00:00
517	Велимир Викентьевич Миронов	sharapovaemilija@hotmail.com	\N	\N	2023-07-07 00:00:00
491	Соколова Глафира Максимовна	zbolshakova@yandex.ru	+79689328342	с. Магнитогорск	2025-08-05 00:00:00
518	Павел Захарьевич Матвеев	simonsubbotin@vladimirova.com	+79990084878	п. Архыз	2025-05-30 00:00:00
493	Селиверст Глебович Кудрявцев	kozlovaekaterina@ao.biz	+79246885603	клх Юрьевец (Иван.)	\N
521	Клавдия Семеновна Суханова	ljudmila1989@yahoo.com	\N	п. Тобольск	2023-08-13 00:00:00
494	Кабанов Арсений Власович	slarionova@oao.org	+79431778032	к. Сызрань	2025-10-30 00:00:00
523	  ivan IVANOV 	kirillovkapiton@ao.ru	\N	п. Нальчик	2024-05-15 00:00:00
495	Панова Евдокия Федоровна	sergeevvaleri@rao.net	+79246103540	г. Новгород Великий	2023-12-02 00:00:00
527	Быков Ратмир Чеславович	taisija_1989@yahoo.com	\N	с. Ржев	2026-02-27 00:00:00
498	Ангелина Семеновна Жданова	tsoloveva@sovkomflot.net	\N	к. Красновишерск	2026-03-19 00:00:00
528	Харитонова Оксана Матвеевна	simon1990@bank.biz	+79271992483	г. Ковров	2024-04-03 00:00:00
500	Рогов Христофор Гаврилович	fedotgrishin@yahoo.com	+79407407714	с. Уварово	2025-05-11 00:00:00
529	Агата Григорьевна Некрасова	\N	+79466177523	п. Нижневартовск	2026-02-27 00:00:00
501	Наум Денисович Шубин	kalashnikovkapiton@rao.info	+79368397022	г. Вендинга	2025-09-01 00:00:00
532	Прохорова Ия Васильевна	filatovpankrati@oao.biz	+79828745466	клх Киров (Вятка)	2024-07-23 00:00:00
502	Дарья Степановна Турова	egor_30@zao.biz	+79140809604	к. Курильск	2024-01-28 00:00:00
534	Козлова Оксана Васильевна	nina_72@ip.biz	+79172167429	к. Курчатов	2024-12-19 00:00:00
505	Никандр Бенедиктович Тимофеев	timofeevvladlen@ooo.ru	+79051227475	клх Абинск	2026-04-17 00:00:00
536	Власова Любовь Александровна	valentin_51@oao.com	\N	ст. Костомукша	2024-01-19 00:00:00
506	Марфа Львовна Петрова	\N	+79359334721	п. Улан-Удэ	2024-04-13 00:00:00
538	Стрелкова Ульяна Валентиновна	konstantinovfoma@npo.info	\N	п. Южноуральск	2023-09-04 00:00:00
508	Крюков Амос Геннадиевич	burovradim@gk.info	+79628936720	ст. Льгов	2023-09-08 00:00:00
540	Анисимова Акулина Архиповна	veniamin2012@hotmail.com	+79387541399	клх Набережные Челны	2026-02-18 00:00:00
509	Татьяна Леоновна Логинова	moke58@goznak.org	+79613791169	д. Петропавловск-Камчатский	2025-05-06 00:00:00
542	Мясников Федор Федосеевич	kasjan_1986@hotmail.com	+79296445934	клх Кириши	2023-12-05 00:00:00
512	Агата Руслановна Горшкова	tustinov@rambler.ru	+79426324454	с. Меренга	2023-07-13 00:00:00
544	Воронцова Полина Никифоровна	sila1981@npo.ru	+79706019487	с. Кедровый	2024-06-03 00:00:00
513	Сысоева Майя Феликсовна	varlaam1987@npo.ru	+79191869359	д. Черемхово	2024-09-30 00:00:00
545	Нинель Альбертовна Веселова	vasilevvitali@rambler.ru	+79419655762	д. Лысьва	2025-07-09 00:00:00
514	Елисеев Фома Ильич	budimir_84@ip.info	\N	г. Сосновый Бор	2025-02-06 00:00:00
546	Цветков Вышеслав Марсович	petrovmir@gmail.com	+79229703585	клх Адыгейск	2026-03-08 00:00:00
515	Юрий Фадеевич Блинов	abramovaraisa@npo.ru	\N	п. Надым	2025-01-04 00:00:00
547	Панфилова Синклитикия Васильевна	pbogdanova@npo.com	+79639695468	г. Камышлов	2025-10-22 00:00:00
516	Валентина Эльдаровна Артемьева	samolovanaina@yandex.ru	+79517169553	д. Междуреченский	2024-09-10 00:00:00
549	Морозова Валентина Архиповна	merkushevaninel@yahoo.com	+79466964139	к. Губкинский	2024-04-07 00:00:00
519	Голубев Селиверст Ерофеевич	rodionovratibor@mail.ru	\N	г. Ирбит	2026-02-26 00:00:00
551	Вера Викторовна Щукина	vladimirovefrem@gmail.com	\N	г. Верхнее Пенжино	2023-12-13 00:00:00
520	Екатерина Афанасьевна Воробьева	mir_1998@oao.org	+79820916739	клх Данков	2023-06-18 00:00:00
552	  ivan IVANOV 	osip1973@ooo.biz	\N	с. Сусуман	2026-04-11 00:00:00
522	Иванна Эдуардовна Осипова	hohlovemeljan@mail.ru	+79897377234	с. Балашиха	\N
553	Василий Гурьевич Никонов	konstantinovanaina@oao.biz	\N	к. Обоянь	2023-06-10 00:00:00
524	Панфил Ааронович Буров	radovan_86@yandex.ru	+79634806999	с. Павловский Посад	2024-03-03 00:00:00
554	Герасимов Лонгин Данилович	ogrigorev@yahoo.com	+79238462628	ст. Устюжна	2023-11-26 00:00:00
525	Красильникова Синклитикия Святославовна	ananinikiforov@yandex.ru	+79832850970	г. Соловки	2024-05-21 00:00:00
557	Осипова Мария Владимировна	kornilovsilvestr@rambler.ru	\N	п. Шадринск	2024-04-03 00:00:00
526	Баранов Мартьян Харитонович	olimpi_1974@rambler.ru	+79824790131	ст. Тутончаны	2024-11-16 00:00:00
559	Любовь Афанасьевна Харитонова	andronmjasnikov@zao.net	+79472944000	к. Ижевск	2025-02-16 00:00:00
530	Ия Артемовна Самойлова	juri_1997@npo.biz	\N	клх Нефтеюганск	2025-10-03 00:00:00
561	Владилен Феликсович Горбачев	zahar51@yahoo.com	+79683163679	д. Череповец	2023-08-14 00:00:00
531	Галина Сергеевна Рябова	lev_1986@ip.edu	\N	к. Северодвинск	2025-01-11 00:00:00
562	Лидия Наумовна Федорова	pestovaveronika@tsvetkov.net	\N	ст. Катайск	2024-07-06 00:00:00
533	Олимпий Анатольевич Кузнецов	birjukovterenti@yahoo.com	\N	ст. Нязепетровск	2025-07-30 00:00:00
566	Эрнест Адрианович Родионов	kazakovisidor@hotmail.com	\N	к. Серпухов	2023-12-22 00:00:00
535	Регина Аркадьевна Федорова	popovauljana@npo.com	+79406994931	д. Находка	2024-05-29 00:00:00
567	Будимир Елизарович Вишняков	kudrjashovsidor@rao.info	\N	ст. Устюжна	2023-06-10 00:00:00
537	Зоя Валентиновна Федосеева	\N	+79415199251	к. Листвянка (Иркут.)	2025-04-29 00:00:00
568	Агафья Ниловна Беспалова	pelageja_2007@yahoo.com	\N	к. Котлас	2024-02-15 00:00:00
539	Новикова Надежда Вадимовна	ershovbronislav@yandex.ru	+79753621656	п. Чегем	2024-09-09 00:00:00
569	Галина Эдуардовна Бобылева	jfilatova@gmail.com	+79774376779	д. Холмогоры	2024-12-03 00:00:00
541	Боброва Светлана Ильинична	tpestov@zhuravleva.info	\N	ст. Охотск	2024-07-15 00:00:00
570	Кириллова Ангелина Альбертовна	jakushevrodion@mail.ru	\N	к. Мытищи	2024-06-28 00:00:00
543	Соловьев Олимпий Анисимович	karp_52@mail.ru	+79599299989	п. Терскол	2025-05-07 00:00:00
571	Рожкова Марина Феликсовна	vlasovamarija@ooo.net	+79197713683	д. Минусинск	2025-07-18 00:00:00
548	Вениамин Венедиктович Пестов	\N	+79612750316	п. Мыс Шмидта	2024-10-30 00:00:00
573	Вероника Макаровна Тарасова	konon76@hotmail.com	+79657518717	к. Тарко-Сале	2024-09-30 00:00:00
550	Журавлева Вера Феликсовна	vsidorova@mail.ru	+79776938677	клх Магас	2026-04-11 00:00:00
574	Савельева Алла Макаровна	borisovgalaktion@ao.com	\N	п. Каневская	2025-06-20 00:00:00
555	Федоров Никита Вячеславович	kulaginselivan@gmail.com	+79951508061	ст. Тулпан	2026-04-10 00:00:00
578	Виссарион Витальевич Иванов	nalekseev@ershova.com	\N	к. Нарьян-Мар	2023-10-22 00:00:00
556	Давыд Дорофеевич Абрамов	nikanor_2002@yahoo.com	\N	с. Елабуга	2025-12-25 00:00:00
579	Селиверстов Селиверст Александрович	andreevfortunat@adidas.net	+79045543743	ст. Ербогачен	2023-06-01 00:00:00
558	Вадим Ильич Сазонов	georgi2014@ooo.edu	\N	г. Усть-Калманка	2023-06-12 00:00:00
583	Комиссарова София Альбертовна	epifan89@ip.info	\N	ст. Талдом	2025-04-05 00:00:00
560	Никонов Федот Гурьевич	jaropolkkozlov@kolesnikova.com	+79260971128	ст. Волхов	2026-01-26 00:00:00
585	Устинова Алла Петровна	matveevevdokim@hotmail.com	\N	п. Тикси	2025-10-13 00:00:00
563	Князева Иванна Эльдаровна	fedot91@kononov.ru	+79499247875	\N	2025-12-15 00:00:00
587	Самсонов Всеслав Георгиевич	xmakarova@hotmail.com	\N	п. Змеиногорск	2025-02-15 00:00:00
564	Мирослав Геннадиевич Лаврентьев	aksenovsavva@zao.edu	\N	с. Воскресенск	2023-08-15 00:00:00
588	Корнилов Кир Данилович	zatsevmaksim@mail.ru	+79262758762	клх Видное	2025-12-31 00:00:00
565	Федорова Олимпиада Валериевна	milan_1981@mail.ru	+79994660711	клх Междуреченский	2024-11-20 00:00:00
589	Кулагина Лидия Филипповна	kirill1984@maslov.org	+79039428930	ст. Усть-Калманка	2024-11-13 00:00:00
572	Константин Дорофеевич Фадеев	guljaevantip@ao.org	+79524106691	\N	2023-09-14 00:00:00
591	Карпова Евдокия Андреевна	filimon83@mail.ru	+79804592121	к. Казань	2025-12-19 00:00:00
575	Натан Дорофеевич Белоусов	makar_1997@prohorova.com	+79243311462	к. Владимир	2024-10-12 00:00:00
592	Князева Любовь Ждановна	fedotovmilen@mail.ru	\N	г. Ельня	2024-07-05 00:00:00
576	Вишнякова Лариса Романовна	dmitrieliseev@knjazeva.biz	+79995469480	к. Юровск	2023-11-08 00:00:00
593	тов. Лапина Таисия Архиповна	vsemilsharov@mail.ru	\N	клх Курильск	2025-07-05 00:00:00
577	Сысоева Алина Олеговна	sinklitikija50@gmail.com	\N	клх Гдов	2025-10-27 00:00:00
595	Цветкова Синклитикия Захаровна	komarovaklavdija@yandex.ru	+79534445451	к. Кировск (Ленин.)	2024-01-09 00:00:00
580	Денис Адамович Гришин	gerasim2018@gmail.com	\N	д. Карабудахкент	2025-07-02 00:00:00
596	Марфа Юльевна Денисова	ljubosmisl_05@npo.ru	\N	д. Александров	2026-01-12 00:00:00
581	Иванна Егоровна Гуляева	borislav72@trofimova.ru	\N	д. Оленегорск (Якут.)	2023-09-17 00:00:00
597	Орехов Андрей Димитриевич	gromovgavrila@oao.edu	+79358406707	к. Пинега	2026-02-07 00:00:00
582	Светлана Яковлевна Кабанова	ermola86@ooo.info	\N	д. Гатчина	2023-06-08 00:00:00
598	Евграф Ааронович Молчанов	osipovgostomisl@ao.net	+79544053844	ст. Джубга	2024-10-05 00:00:00
584	Азарий Иларионович Кузнецов	mihe82@gmail.com	\N	с. Лодейное Поле	2025-09-12 00:00:00
599	Марфа Федоровна Емельянова	izmailvladimirov@mail.ru	\N	г. Люберцы	2025-08-05 00:00:00
586	  ivan IVANOV 	gerasim2017@rambler.ru	\N	клх Сунтар	2026-05-16 00:00:00
602	Милица Антоновна Степанова	lkabanov@rambler.ru	+79033471933	г. Волхов	2025-02-18 00:00:00
590	Кира Аскольдовна Силина	lavrenti52@ao.edu	+79207884688	г. Кизилюрт	2023-08-04 00:00:00
605	Воронцова Жанна Игоревна	afinogenmedvedev@ooo.net	+79365196671	ст. Химки	2026-01-25 00:00:00
594	Мясникова Зоя Константиновна	panfilovalidija@fmsm.biz	+79910316138	д. Озеры	2024-09-16 00:00:00
606	Афанасьева Василиса Романовна	saveli84@hotmail.com	\N	ст. Ардон	2025-05-11 00:00:00
600	Денисова Майя Тарасовна	lavr12@mishina.ru	+79996206898	д. Калевала	2024-08-12 00:00:00
608	Беляков Чеслав Архипович	feofan_52@gmail.com	\N	п. Витим	2023-12-10 00:00:00
601	Киселев Изяслав Анатольевич	skoshelev@rambler.ru	+79266919752	д. Борзя	2024-02-27 00:00:00
609	Колесников Емельян Владиславович	simon14@rambler.ru	\N	п. Курганинск	2024-08-08 00:00:00
603	Феоктист Игнатьевич Кудряшов	beljakovkondrat@slavneft.biz	\N	к. Ярославль	2026-04-23 00:00:00
614	Тарасов Орест Евсеевич	ilinasvetlana@yandex.ru	+79248779766	с. Ангарск	2025-10-06 00:00:00
604	Фаина Тарасовна Воронцова	rjabovaanzhela@rambler.ru	+79324945099	д. Краснокамск	2025-08-03 00:00:00
615	Екатерина Аркадьевна Турова	panfilovelizar@ao.info	+79420989391	к. Сургут (Хант.)	2023-10-05 00:00:00
607	Фёкла Олеговна Жукова	dobroslav60@yandex.ru	+79357867151	\N	2025-12-04 00:00:00
619	Зиновий Ааронович Матвеев	zhdanovlazar@yandex.ru	\N	г. Анадырь	2025-07-10 00:00:00
610	Сазонов Лазарь Феодосьевич	olimpi_04@yandex.ru	\N	п. Верхотурье	2023-08-29 00:00:00
621	Муравьев Владислав Устинович	kimbolshakov@rao.com	+79768895851	ст. Приозерск	2025-03-14 00:00:00
611	Морозова Евпраксия Робертовна	ershovamarija@hotmail.com	\N	к. Богучар	2026-01-04 00:00:00
623	Горбунов Глеб Ааронович	florentin_2005@gmail.com	\N	клх Середниково	2024-03-23 00:00:00
612	Гаврила Иосифович Ефремов	radislav15@yandex.ru	\N	клх Ангарск	2024-07-24 00:00:00
624	Фомичева София Харитоновна	dmitri_40@ooo.net	+79656583196	г. Хоста	2023-12-26 00:00:00
613	Беляев Федот Трофимович	mir_86@ip.biz	+79990831766	ст. Кашира	2025-08-08 00:00:00
625	Федорова Светлана Антоновна	igormatveev@oao.biz	+79967522662	д. Ельня	2025-04-17 00:00:00
616	Аникей Ермилович Сергеев	borislav98@mail.ru	\N	п. Котельнич	2025-12-07 00:00:00
627	Игнатьева Таисия Вячеславовна	blohinazinaida@gmail.com	+79202107025	с. Камышин	2026-01-22 00:00:00
617	Анна Филипповна Ефимова	safonovipati@oao.ru	\N	к. Батайск	2026-01-15 00:00:00
629	Фаина Ильинична Коновалова	bespalovaeleonora@ao.edu	\N	п. Шали	2025-01-02 00:00:00
618	Мирослав Трофимович Ефремов	mir1989@rambler.ru	\N	клх Белый Яр (Томск.)	2023-07-10 00:00:00
630	Регина Святославовна Субботина	vladislav1999@npo.edu	\N	с. Нарьян-Мар	2024-06-19 00:00:00
620	Ипатий Якубович Емельянов	solomon_13@hotmail.com	\N	клх Ачинск	2024-02-11 00:00:00
632	Елена Кирилловна Федосеева	loginovaija@ao.ru	\N	с. Новороссийка	2024-01-05 00:00:00
622	Анжела Макаровна Костина	zatsevafevronija@yahoo.com	\N	д. Тутаев	2025-03-08 00:00:00
633	Медведева Екатерина Эльдаровна	ignatovfeoktist@yandex.ru	+79578958595	к. Кинешма	2025-07-06 00:00:00
626	Константин Эдгардович Анисимов	zodintsova@yahoo.com	+79755039050	д. Неплюевка	2026-05-11 00:00:00
636	Лора Матвеевна Маркова	amosustinov@npo.edu	+79520507291	клх Тула	2024-08-02 00:00:00
628	Маслов Спиридон Марсович	sofija_2018@yandex.ru	\N	г. Диксон	2025-02-06 00:00:00
637	Юлий Владленович Кузнецов	novikovnikita@rao.ru	+79353814211	п. Соль-Илецк	2025-04-25 00:00:00
631	Павлов Иннокентий Артурович	januari1984@gmail.com	+79618853630	с. Ямбург	2024-12-05 00:00:00
638	Антонина Ниловна Богданова	\N	+79397034107	с. Александров	2024-12-30 00:00:00
634	Соловьева Иванна Семеновна	blinovaaleksandra@gmail.com	+79616290544	с. Лабинск	2024-08-17 00:00:00
639	Таисия Максимовна Горбачева	janbaranov@zao.biz	+79199577362	с. Кулунда	2026-03-26 00:00:00
635	Суворова Лукия Ниловна	vasilisa52@suhanova.info	+79037931259	д. Красноуфимск	2026-05-16 00:00:00
641	Фаина Болеславовна Пахомова	isakovkliment@zao.com	\N	\N	2024-11-22 00:00:00
640	Никифор Артёмович Стрелков	jaropolk1972@zao.info	\N	к. Хужир	2025-09-17 00:00:00
642	Оксана Алексеевна Степанова	faina19@ooo.info	+79569355272	д. Красная Поляна	2025-07-22 00:00:00
648	Зимин Захар Вячеславович	petrovapelageja@konar.biz	+79316290643	г. Яхрома	2025-01-04 00:00:00
643	Фирс Аверьянович Агафонов	ignatiromanov@gmail.com	\N	ст. Биробиджан	2024-02-17 00:00:00
649	Агафья Олеговна Кабанова	shilovcheslav@mail.ru	\N	к. Приозерск	2023-11-28 00:00:00
644	Лебедев Мечислав Ерофеевич	modestkulakov@npo.edu	+79953479685	ст. Улан-Удэ	2025-09-14 00:00:00
650	Владилен Арсенович Виноградов	nikolaevolimpi@lanit.edu	\N	к. Апшеронск	2023-11-05 00:00:00
645	Дарья Федоровна Константинова	tit1973@rao.org	+79861081811	к. Оренбург	2023-10-14 00:00:00
651	Адам Абрамович Чернов	noskovgennadi@ip.biz	+79234490716	ст. Артем	2024-02-23 00:00:00
646	Евгения Станиславовна Жданова	shestakovaelizaveta@yandex.ru	+79241341389	ст. Тавда	2025-01-25 00:00:00
652	Алина Геннадьевна Сысоева	evstigne2014@zao.biz	+79078296722	к. Кош-Агач	2025-04-03 00:00:00
647	Харитонова Таисия Алексеевна	filaret47@oao.org	\N	ст. Тутончаны	2025-06-25 00:00:00
655	Мартынова Акулина Юрьевна	marian_2008@vinogradova.net	+79430156867	д. Тавда	2026-03-28 00:00:00
653	Октябрина Степановна Силина	julian_29@mironov.ru	\N	ст. Беломорск	\N
656	Беспалов Самуил Феликсович	german50@yandex.ru	+79109616847	к. Адыгейск	2026-03-15 00:00:00
654	Щербакова Светлана Рубеновна	noskovvisheslav@yahoo.com	\N	п. Темрюк	\N
657	Моисеев Радован Валерьянович	jdavidova@gmail.com	+79137459855	клх Минеральные Воды	2025-09-29 00:00:00
659	Петр Васильевич Зуев	ekulikov@npo.biz	+79571161453	с. Можайск	2026-04-25 00:00:00
658	Боян Бориславович Пономарев	olimpi2021@npo.info	\N	к. Барнаул	2024-03-22 00:00:00
660	Харитонов Владимир Эдуардович	apollinari_97@ooo.org	+79665699678	к. Мичуринск	2025-05-05 00:00:00
662	Радим Фадеевич Буров	sofonkomissarov@npo.net	\N	с. Ростов	2025-02-21 00:00:00
661	  ivan IVANOV 	karp_07@oao.com	+79753011714	клх Баргузин	2025-06-21 00:00:00
663	Тимофеева Феврония Ниловна	ljubomir34@rao.org	+79255365396	с. Бугуруслан	2024-03-09 00:00:00
665	Мария Захаровна Лукина	evstafi2011@gorshkov.edu	\N	с. Выборг	2024-08-15 00:00:00
664	Мартьян Антонович Колобов	valentin22@rao.info	\N	ст. Хужир	2025-07-05 00:00:00
667	Аникей Даниилович Филиппов	miheevvarlaam@ignatov.biz	+79985879826	с. Кулунда	2025-03-27 00:00:00
666	Дементьева Евдокия Святославовна	vmaksimova@rao.biz	+79007756709	д. Карталы	2024-07-26 00:00:00
668	Агафонов Роман Феоктистович	milan1982@mail.ru	+79770086298	г. Волхов	2024-12-18 00:00:00
670	Эмилия Ждановна Громова	qkononova@yahoo.com	\N	к. Яр-Сале	2025-09-18 00:00:00
669	Константинов Евдоким Антонович	viktorija_48@zao.ru	\N	с. Кирово-Чепецк	2024-02-23 00:00:00
671	Иванов Бажен Абрамович	ipati_2016@hotmail.com	\N	г. Гаврилов-Ям	2025-02-02 00:00:00
674	Дмитрий Филатович Степанов	mefodi1990@hotmail.com	\N	к. Обоянь	2024-04-01 00:00:00
672	Дарья Георгиевна Петрова	kostinaekaterina@gmail.com	+79066503230	с. Тимашевск	\N
676	Павлов Измаил Виленович	glafira1994@yahoo.com	+79048088217	г. Тавда	2026-01-13 00:00:00
673	Василиса Святославовна Григорьева	vladimirovvseslav@rao.biz	+79802178290	г. Аргаяш	2026-01-30 00:00:00
680	Валентина Борисовна Бирюкова	sevastjanblohin@kmr.ru	+79787564180	ст. Бузулук	2024-08-21 00:00:00
675	Гришин Ладислав Бориславович	burovgerman@ooo.edu	+79401026552	п. Нарткала	2025-10-03 00:00:00
681	Феликс Ермилович Сидоров	karl57@ip.info	+79106711198	клх Щелково	2026-04-29 00:00:00
677	Авдей Феодосьевич Ковалев	lavrenti2008@ip.info	+79377183091	п. Валаам	2025-06-11 00:00:00
682	Гришина Наина Богдановна	prohorovelizar@yahoo.com	+79097420069	п. Краснодар	2024-05-16 00:00:00
678	Большаков Всеволод Иосифович	denisovizot@yandex.ru	+79666003785	к. Новороссийка	2024-12-14 00:00:00
683	Гаврилов Ладислав Афанасьевич	juri2013@yandex.ru	+79497959196	п. Муром	2023-09-15 00:00:00
679	  ivan IVANOV 	petremeljanov@rambler.ru	+79466271010	к. Раменское	2024-04-09 00:00:00
685	Комиссаров Карп Димитриевич	kolesnikovanani@egorova.com	+79666208705	с. Териберка	2025-04-18 00:00:00
684	г-н Дроздов Станимир Бориславович	slobanov@zao.com	\N	к. Ногинск (Моск.)	2026-05-11 00:00:00
686	Быкова София Болеславовна	zhanna_11@yandex.ru	+79119149420	с. Фатеж	2023-10-16 00:00:00
688	Терентьев Венедикт Аксёнович	djachkovaraisa@ooo.net	+79754672588	клх Шереметьево	2024-11-28 00:00:00
687	Тетерина Мария Ждановна	evgenija1997@rao.edu	\N	д. Балтийск	2023-11-03 00:00:00
691	Полина Харитоновна Гришина	kostinatatjana@yandex.ru	+79223951923	к. Зарайск	2024-12-15 00:00:00
689	Игнатьев Леон Валерьевич	gorbachevairina@mail.ru	\N	к. Владикавказ	2023-07-30 00:00:00
692	Наталья Анатольевна Сысоева	bshirjaev@ooo.com	+79673532691	к. Вязьма	2026-03-17 00:00:00
690	Некрасов Ладимир Ильясович	dementevljubomir@ip.edu	\N	клх Кызыл	2024-11-24 00:00:00
696	Щукина Ульяна Валентиновна	\N	+79853042013	д. Волгоград	2025-05-30 00:00:00
693	Белозеров Агафон Филимонович	sidor_61@yahoo.com	+79692211324	г. Арсеньев	2025-07-25 00:00:00
697	Давыдов Фрол Адамович	evdokim_58@ip.com	+79334783336	клх Абинск	2024-07-29 00:00:00
694	Лора Яковлевна Сысоева	arhipovfoti@oao.org	+79896428066	г. Ясный (Оренб.)	2024-06-07 00:00:00
700	Михеев Тимофей Даниилович	\N	\N	д. Объячево	2025-10-10 00:00:00
695	Татьяна Тимуровна Шестакова	azarikrjukov@ooo.info	+79614804616	г. Жиганск	2026-02-14 00:00:00
-1	Unknown	\N	\N	Unknown	\N
698	Сократ Владиславович Мельников	mishinignati@general.edu	\N	п. Качканар	\N
699	Бобылева Нонна Ниловна	drogov@ooo.com	\N	к. Валдай	2024-03-28 00:00:00
\.


--
-- TOC entry 2541 (class 0 OID 49544)
-- Dependencies: 287
-- Data for Name: events; Type: TABLE DATA; Schema: dds; Owner: gpadmin
--

COPY dds.events (event_id, customer_id, event_type, event_timestamp, product_id) FROM stdin;
2	550	login	2025-11-30 00:01:33	20
1	483	view	2025-06-23 18:40:09	281
3	570	login	2025-02-16 21:53:55	588
5	202	purchase	2025-04-03 12:11:22	453
4	213	view	2025-07-12 08:14:08	408
11	269	view	2026-03-15 11:17:56	113
6	407	purchase	2025-09-16 03:22:28	593
12	186	login	2026-01-05 11:55:07	581
7	649	purchase	2025-12-19 00:43:43	416
14	422	logout	2026-01-14 09:38:05	337
8	211	click	2025-08-19 00:00:37	472
15	226	view	2024-08-07 00:54:45	399
9	143	logout	2025-09-11 03:25:39	-1
17	-1	logout	2024-07-06 19:51:55	600
10	646	view	2024-10-25 05:32:16	587
20	494	click	2025-05-18 07:42:20	281
13	472	login	2026-02-24 06:50:07	27
23	73	login	2024-07-20 19:21:47	39
16	111	logout	\N	411
25	11	logout	2025-02-17 20:02:38	-1
18	35	view	2025-07-17 12:46:22	238
26	679	view	2024-09-11 09:56:23	320
19	279	click	2025-04-30 21:23:00	430
30	636	click	2025-11-17 13:12:55	125
21	547	purchase	2025-08-06 10:01:35	577
31	206	purchase	2026-05-15 15:57:41	268
22	559	purchase	2025-11-24 21:01:34	64
35	392	purchase	2025-07-20 14:23:44	102
24	76	logout	2024-07-23 17:52:12	411
36	-1	login	2026-01-15 20:18:11	139
27	672	click	2024-06-23 06:44:36	40
38	139	login	2025-05-24 03:41:19	5
28	155	login	2025-07-22 02:25:51	122
40	297	click	2026-05-03 12:29:43	471
29	414	view	2025-12-21 15:16:26	75
44	620	logout	2025-08-09 16:28:40	82
32	160	click	2024-11-04 15:02:32	77
46	674	view	2025-08-23 21:51:31	294
33	436	login	2025-05-12 05:14:11	99
47	174	click	2026-05-15 02:49:11	291
34	498	logout	2025-03-18 12:01:58	557
48	50	click	2025-11-20 11:18:35	344
37	-1	purchase	2025-06-29 07:09:59	17
49	224	login	2024-12-04 07:32:59	444
39	166	logout	2025-03-26 03:32:01	91
50	678	view	2024-09-14 06:58:56	260
41	648	click	2025-05-16 22:32:18	77
52	320	view	2025-11-13 01:08:20	373
42	623	login	2024-11-20 18:16:28	523
56	613	view	2026-05-09 23:05:26	109
43	378	purchase	2026-04-17 01:31:12	193
57	606	purchase	2025-10-14 03:59:33	357
45	39	login	2025-07-29 01:51:50	114
61	415	purchase	2025-05-28 16:05:21	9
51	353	purchase	2026-02-12 04:31:22	509
63	114	view	2024-07-15 20:40:33	388
53	290	view	2025-03-22 10:28:31	478
64	522	login	2025-07-21 01:05:00	267
54	598	logout	2025-09-26 12:02:47	539
68	-1	login	2026-03-01 10:15:48	514
55	368	logout	2024-11-24 22:10:22	584
69	-1	purchase	2025-06-16 04:47:23	166
58	680	click	2025-06-06 16:21:47	517
71	570	view	2025-11-10 09:47:00	483
59	304	click	2025-10-04 20:23:25	89
72	335	logout	2024-09-16 17:05:11	-1
60	467	login	2025-06-16 06:21:19	371
74	40	logout	2025-11-07 05:54:10	-1
62	-1	view	2024-11-09 21:14:10	282
76	356	purchase	2025-05-30 15:15:57	454
65	42	logout	2025-06-11 18:31:24	106
78	448	purchase	2026-02-13 23:01:02	570
66	-1	login	2026-05-23 23:17:14	-1
79	42	login	2024-07-26 21:20:08	30
67	61	view	2026-05-16 05:34:03	550
83	523	view	2025-01-12 15:07:13	269
70	144	logout	2024-08-28 06:45:43	180
85	644	view	2025-09-14 04:47:41	523
73	606	view	\N	95
86	691	logout	2025-08-28 15:16:21	395
75	119	view	2026-03-26 20:55:00	253
87	228	login	2024-08-18 21:46:47	573
77	150	logout	2024-12-20 00:32:57	8
88	658	view	2024-06-04 02:23:30	233
80	131	view	2026-04-15 22:15:07	25
89	476	view	2026-05-10 08:27:12	100
81	308	purchase	2025-06-13 00:37:43	338
91	257	click	2025-06-19 07:29:42	413
82	249	logout	2024-10-02 08:03:46	130
95	192	view	2025-03-16 05:18:29	-1
84	295	login	2025-05-02 05:21:19	295
96	441	view	2024-09-09 08:15:19	368
90	228	logout	2025-07-01 03:43:23	456
98	69	login	2026-01-18 10:19:32	471
92	611	purchase	2025-02-23 07:17:55	566
105	276	login	2026-01-16 16:29:31	185
93	331	login	2024-07-10 03:08:37	-1
106	331	view	2025-10-31 19:35:39	189
94	586	view	2025-05-03 08:36:36	285
107	247	purchase	2024-07-19 15:29:32	309
97	157	logout	2024-11-21 14:32:15	387
111	548	login	2024-08-23 13:48:34	599
99	247	purchase	2026-05-15 00:05:23	45
114	245	click	2025-03-14 17:44:05	148
100	85	click	2024-10-28 11:35:19	96
116	228	purchase	2026-04-08 23:05:26	143
101	229	logout	2024-06-12 14:10:17	-1
119	615	click	2025-12-19 22:48:34	303
102	566	purchase	2025-07-13 10:30:45	21
121	418	click	2026-05-09 13:31:37	368
103	525	login	2025-02-01 22:06:59	-1
122	-1	click	2024-11-22 00:57:54	392
104	629	logout	2024-09-01 17:49:37	303
123	619	view	2025-11-29 09:58:51	130
108	-1	view	2025-02-07 08:25:42	466
124	364	click	2025-10-27 03:33:02	237
109	-1	view	2025-12-06 19:55:09	351
125	601	view	2026-02-26 08:47:23	367
110	253	login	2024-08-10 23:12:17	336
128	383	login	2026-05-16 21:39:52	87
112	30	login	2024-07-26 19:13:49	388
132	-1	logout	2025-12-27 04:27:55	363
113	16	click	2025-04-27 09:42:38	63
134	147	purchase	2025-03-25 00:57:54	353
115	636	logout	2024-11-16 23:51:55	186
135	-1	click	2024-09-25 10:47:48	240
117	538	view	2025-05-20 14:25:32	144
136	85	login	2026-03-08 19:57:10	548
118	620	click	2025-11-16 22:25:13	-1
137	78	login	2025-05-20 17:20:34	295
120	161	click	\N	90
138	251	view	2025-12-31 04:19:41	362
126	8	view	2025-05-05 21:25:18	600
144	679	logout	2026-03-22 10:51:53	136
127	50	click	2025-11-22 12:02:08	217
148	155	login	2024-11-08 01:57:45	365
129	619	view	2024-11-28 15:36:34	189
149	600	click	2024-06-25 22:08:56	530
130	-1	purchase	2024-10-26 00:47:48	386
150	-1	logout	2024-08-23 07:48:43	226
131	150	purchase	2024-10-01 07:18:44	288
152	320	view	\N	251
133	615	login	2025-04-01 09:47:00	-1
154	579	click	2026-04-21 14:41:13	75
139	201	view	2025-05-13 15:29:15	463
155	213	login	2025-03-23 09:54:21	-1
140	511	login	2024-09-16 11:56:41	349
157	491	logout	2024-10-20 14:54:40	106
141	60	login	2026-03-08 00:11:12	429
158	503	click	2024-09-30 14:13:48	509
142	69	logout	2025-08-06 22:19:02	89
159	423	view	2024-12-22 02:12:45	350
143	-1	login	2025-10-20 11:39:58	417
160	216	click	2026-03-31 22:58:08	101
145	252	view	2025-12-13 22:39:24	-1
161	282	view	2026-02-11 05:56:41	362
146	561	login	\N	-1
162	168	login	2025-12-11 04:02:26	442
147	490	click	2026-03-17 05:37:31	139
166	501	purchase	2025-12-25 09:06:32	322
151	510	purchase	2025-11-26 07:27:02	-1
167	396	login	2026-04-03 05:18:24	452
153	465	click	2025-10-18 21:16:03	551
168	524	login	2025-09-12 02:20:14	286
156	515	login	2026-05-08 16:12:11	130
169	592	purchase	2024-07-12 12:15:40	23
163	456	click	2024-08-06 23:43:34	378
170	315	click	2026-04-04 21:51:14	424
164	66	login	2025-02-22 04:12:08	287
171	593	logout	2026-01-16 12:44:18	393
165	324	click	2025-04-03 01:58:44	255
172	547	view	2025-02-17 09:30:03	56
176	142	logout	2025-01-25 22:43:27	448
173	432	login	2025-12-15 02:54:50	505
177	673	view	2025-05-06 18:44:25	201
174	184	click	2025-10-09 16:35:58	23
180	141	logout	2025-01-28 04:12:58	54
175	629	click	2024-10-16 17:38:57	276
182	138	login	2025-01-13 04:03:51	148
178	300	login	2024-09-04 01:17:32	7
183	249	click	2024-07-13 00:28:09	582
179	294	login	2024-12-08 22:53:02	475
185	500	login	\N	202
181	-1	click	2024-12-20 20:15:50	543
187	437	view	2025-06-19 05:00:21	142
184	-1	purchase	2024-09-06 08:59:35	405
190	557	click	2024-10-07 00:19:49	463
186	417	click	2026-02-01 10:50:39	533
192	171	logout	2026-05-01 07:53:23	511
188	-1	view	2025-04-17 06:57:03	531
193	-1	view	2025-08-12 16:20:47	391
189	300	purchase	2026-03-28 00:55:23	260
195	446	logout	2026-01-08 17:08:25	576
191	692	view	2024-09-01 20:46:40	522
197	117	click	2024-07-10 00:46:30	379
194	9	purchase	2025-03-22 05:57:04	293
198	96	click	2025-08-24 06:44:19	1
196	380	purchase	2026-01-20 22:42:59	54
203	63	purchase	2024-08-24 05:30:53	357
199	80	purchase	2024-11-22 21:00:15	113
205	339	view	2025-12-13 00:24:07	223
200	487	logout	2026-02-07 19:59:19	62
207	202	view	2025-11-18 20:44:37	413
201	554	click	2026-03-23 21:50:45	522
209	499	login	2025-08-25 23:24:44	37
202	591	view	2024-06-13 23:02:31	70
211	673	logout	2024-10-22 15:02:26	573
204	416	logout	2024-06-09 23:59:10	219
215	482	login	2025-07-10 17:50:06	594
206	489	purchase	2025-03-06 23:32:06	52
218	550	click	2025-07-05 21:49:54	553
208	529	login	2026-03-11 13:07:23	113
219	69	login	2025-07-19 10:35:46	154
210	94	logout	2026-02-18 08:53:37	474
223	344	view	2025-01-07 11:55:04	553
212	662	login	2025-09-03 22:26:56	447
224	275	login	2026-02-08 13:35:36	-1
213	96	logout	2026-03-04 09:23:26	435
225	-1	click	\N	528
214	530	view	2026-02-05 04:57:02	585
229	531	purchase	2025-03-12 05:58:39	245
216	-1	click	2025-06-04 17:17:12	68
230	5	login	2025-08-18 22:08:06	8
217	488	purchase	2025-03-28 10:01:04	341
233	496	login	2026-01-23 02:59:45	119
220	559	purchase	2026-05-04 11:21:54	254
236	-1	logout	2025-08-19 14:44:21	454
221	593	logout	2026-03-07 13:10:23	164
237	85	view	2024-05-29 11:07:19	286
222	398	click	2025-01-07 16:39:49	494
239	358	login	2025-05-09 22:08:34	458
226	350	login	2024-07-01 10:55:56	394
241	124	logout	2025-08-08 17:08:17	111
227	441	click	2024-10-16 01:03:52	72
244	625	login	2026-02-06 19:31:55	241
228	654	view	2024-09-12 08:47:21	129
246	-1	click	2026-01-22 18:34:32	289
231	549	login	2025-08-08 18:07:44	9
247	142	login	2025-04-15 12:31:19	374
232	655	click	2025-10-26 16:26:32	171
251	-1	click	2024-09-07 16:52:42	117
234	124	logout	2025-09-04 09:02:35	327
252	343	logout	2024-12-09 01:28:03	337
235	132	login	2026-02-28 20:41:19	400
256	-1	purchase	2026-02-08 09:50:58	345
238	145	purchase	2026-01-20 01:17:01	54
257	613	logout	2025-03-05 21:30:38	209
240	481	logout	2025-08-28 20:07:58	438
258	226	logout	2026-03-18 20:47:27	212
242	386	logout	2025-08-13 22:56:07	409
260	291	login	2025-11-16 11:39:54	259
243	413	login	2025-02-17 13:33:07	-1
261	394	logout	2024-09-22 08:01:18	-1
245	200	purchase	\N	-1
262	397	click	2025-06-16 15:16:04	24
248	201	logout	2024-08-14 06:20:58	187
263	213	login	2025-04-04 13:51:22	418
249	131	logout	2025-09-22 20:32:39	265
266	686	view	2025-05-19 16:10:22	36
250	250	view	2024-10-06 20:34:48	371
267	-1	click	\N	401
253	39	view	2025-10-21 10:30:40	407
270	287	click	2025-07-27 15:06:12	118
254	-1	click	2026-01-24 18:20:18	32
272	241	login	2025-09-19 22:34:47	223
255	-1	login	2025-03-04 06:26:57	586
274	60	view	2025-10-17 00:23:58	539
259	367	view	2025-05-04 08:10:46	111
275	610	view	2025-02-06 06:29:46	534
264	434	logout	2025-12-01 13:47:26	403
279	700	click	2025-09-02 22:30:13	269
265	552	logout	2025-11-12 00:37:29	511
282	525	view	2026-03-28 08:14:49	141
268	681	purchase	2025-09-05 00:56:30	387
285	356	click	2025-07-20 19:39:05	91
269	18	logout	\N	347
286	38	logout	2026-04-01 01:25:09	251
271	411	click	2026-04-17 14:39:51	203
287	9	login	2025-12-17 03:45:14	208
273	391	click	2024-08-15 16:20:48	92
288	620	logout	2026-02-26 12:14:37	143
276	117	purchase	2024-12-22 22:06:44	545
290	684	click	2024-06-29 22:43:42	418
277	46	click	2024-08-20 15:09:26	286
291	365	view	2025-02-06 10:55:58	498
278	67	logout	2025-05-26 15:37:11	-1
294	222	click	2025-04-07 04:56:55	539
280	-1	login	2025-07-10 23:44:56	91
295	681	view	2025-11-25 10:42:03	407
281	249	login	2025-12-14 13:11:42	26
296	656	login	2025-11-10 00:49:39	163
283	691	logout	2025-09-30 10:58:58	586
298	12	click	2025-08-30 21:47:31	407
284	311	purchase	2025-05-16 22:08:11	4
299	88	purchase	2025-07-12 15:44:10	564
289	97	view	2024-10-06 09:18:51	144
301	475	logout	2025-09-06 20:11:56	326
292	438	view	2024-06-09 01:40:52	491
304	508	view	2025-05-13 01:33:42	193
293	408	click	2025-02-26 21:32:00	556
308	597	view	2025-09-23 22:05:09	143
297	189	login	2025-07-06 17:06:19	528
309	605	purchase	2024-09-20 01:41:13	360
300	657	logout	2025-03-25 19:57:34	1
310	96	login	2024-10-08 02:03:03	117
302	580	click	2024-08-15 18:20:17	-1
311	316	view	2025-01-16 18:20:42	370
303	489	click	2025-11-17 02:28:11	-1
312	-1	logout	2025-01-04 06:24:54	277
305	571	logout	\N	31
315	51	view	2025-06-25 06:10:29	-1
306	75	purchase	2024-08-22 06:51:23	452
319	412	logout	2026-04-09 22:09:29	186
307	112	login	2026-02-10 14:04:34	565
320	166	click	2024-11-03 06:26:15	216
313	609	click	2025-10-18 14:49:27	458
322	14	login	2025-12-30 03:42:11	21
314	575	login	2025-02-19 21:44:37	475
325	481	purchase	2024-10-07 07:19:51	335
316	-1	view	2025-07-05 09:35:25	154
326	507	view	2025-05-06 19:03:54	284
317	349	view	2025-09-14 05:03:08	401
329	556	click	2026-03-26 13:13:45	312
318	-1	purchase	2026-02-03 16:05:27	24
331	288	login	2024-08-20 00:29:06	550
321	122	view	2024-08-28 17:37:17	43
333	204	purchase	2024-08-26 00:34:59	304
323	140	click	2025-06-28 04:19:15	434
334	576	click	2024-08-06 10:59:26	362
324	143	logout	2025-04-20 21:52:40	245
335	671	login	2025-03-15 19:08:06	427
327	313	logout	2024-07-07 15:10:57	418
338	485	login	\N	521
328	695	login	2026-03-20 05:13:14	390
341	612	logout	2025-11-25 03:57:19	25
330	260	click	2026-01-30 16:05:16	68
344	475	view	2025-12-05 03:12:54	202
332	679	purchase	2025-12-20 17:30:26	527
345	288	logout	2026-02-22 21:44:45	581
336	507	login	2025-10-09 13:00:37	531
346	47	login	2025-07-10 16:53:43	502
337	321	view	2024-06-27 17:38:38	472
348	683	view	2025-02-07 11:23:57	30
339	624	click	2026-02-28 22:58:57	419
350	113	click	2024-12-27 01:36:29	5
340	625	purchase	2026-04-13 11:41:31	441
352	97	purchase	2025-04-10 16:27:13	67
342	-1	purchase	2026-03-06 15:54:56	370
354	230	logout	2024-10-28 22:10:29	339
343	-1	click	2025-02-13 14:56:32	411
355	193	view	2026-03-10 07:26:38	245
347	146	logout	2024-09-07 07:00:49	354
356	673	view	2024-07-18 10:10:22	171
349	65	purchase	2025-11-27 13:52:14	360
358	565	login	2026-01-25 19:49:13	353
351	308	view	2026-04-16 15:03:54	576
360	542	purchase	2025-12-11 14:15:59	351
353	143	logout	2024-05-26 09:41:43	239
361	83	login	2024-12-27 17:26:08	-1
357	411	login	2026-05-04 00:25:09	153
362	641	click	2025-01-13 23:41:51	81
359	114	logout	2026-01-10 05:15:15	229
363	489	purchase	2025-02-14 15:13:23	367
365	428	click	2025-08-08 16:37:06	111
364	321	click	2024-11-29 01:34:49	33
368	488	login	2025-10-04 00:35:42	171
366	426	click	2025-02-16 02:01:12	395
372	435	view	2024-12-01 22:40:52	442
367	98	click	2026-05-10 02:27:48	326
375	319	purchase	2025-01-27 01:00:26	-1
369	436	view	2024-12-04 23:47:54	435
376	553	click	2026-03-14 15:01:50	429
370	30	logout	2025-11-22 10:47:23	453
377	452	view	2025-09-29 17:19:20	221
371	402	logout	2024-12-09 12:35:10	61
378	288	logout	2025-02-14 06:37:36	544
373	-1	click	2026-02-06 08:39:27	-1
380	674	click	2025-08-10 09:51:22	379
374	345	login	2025-05-19 07:58:26	61
382	696	click	2026-03-27 18:08:36	244
379	40	purchase	2025-06-04 17:34:18	93
384	453	click	2026-03-17 04:48:30	66
381	623	login	2025-11-26 04:50:32	48
385	113	purchase	2024-06-03 06:57:05	293
383	110	click	2025-10-25 11:32:25	380
386	644	view	2024-06-16 14:34:48	208
389	681	login	2026-04-01 05:42:19	110
387	663	login	2025-04-10 13:47:08	382
390	-1	click	2025-09-05 01:57:28	118
388	231	view	2025-07-23 15:12:55	161
391	690	logout	2025-06-09 21:40:52	348
392	66	click	2025-02-01 10:23:49	522
393	115	click	2024-11-30 01:42:58	86
396	581	purchase	2025-05-31 15:21:53	472
394	55	login	2025-07-02 14:16:04	-1
398	141	login	2024-08-18 02:15:11	453
395	160	logout	2026-03-20 05:08:00	407
399	659	logout	2026-01-09 10:34:34	83
397	446	view	2024-10-13 02:42:44	368
400	383	view	2024-12-08 04:11:52	326
403	219	purchase	2025-12-09 02:03:27	57
401	-1	click	\N	387
404	175	logout	2025-07-20 19:26:08	407
402	534	login	2025-01-15 09:45:20	36
406	-1	purchase	2025-05-19 19:41:50	471
405	49	view	2025-02-04 00:15:21	-1
410	177	purchase	2025-10-30 01:22:38	251
407	696	view	2025-03-17 18:46:15	150
412	-1	click	2025-01-13 17:16:51	561
408	246	logout	2026-03-10 21:54:49	46
414	202	view	2025-08-17 17:27:43	397
409	78	logout	2025-04-08 02:12:54	458
415	536	login	2026-02-20 17:48:03	10
411	288	view	2025-12-05 10:19:12	164
416	244	view	2024-07-09 18:34:46	491
413	174	click	2025-05-15 16:34:08	564
418	607	login	2024-11-21 10:08:59	189
417	252	logout	\N	523
421	468	click	2026-05-17 00:39:57	374
419	48	purchase	2025-03-10 20:51:24	264
422	29	logout	2025-03-31 11:39:19	329
420	-1	view	2025-12-03 20:08:18	10
424	83	logout	2024-07-18 18:06:17	-1
423	107	login	\N	381
425	272	purchase	2024-12-06 18:59:35	373
427	347	view	2026-02-18 13:14:03	465
426	431	click	2025-01-10 10:15:52	353
430	436	purchase	2026-01-13 10:45:00	138
428	439	click	2025-03-29 12:07:31	120
431	412	login	2025-07-25 17:27:21	452
429	-1	logout	2026-01-06 01:40:40	145
432	557	view	2024-08-09 11:32:34	507
435	223	purchase	2025-11-14 23:05:44	71
433	213	click	2025-05-25 04:29:56	538
436	310	login	2024-10-24 23:21:58	181
434	490	view	2025-08-25 02:36:42	144
437	507	click	\N	114
440	524	logout	2026-04-02 10:44:50	545
438	74	login	2025-10-12 07:45:34	306
441	432	login	2026-03-16 17:46:55	28
439	179	view	2024-12-31 01:26:27	303
442	257	login	2025-07-22 14:49:30	579
444	387	click	\N	285
443	397	login	2025-02-19 14:53:19	222
446	412	view	2025-01-29 15:56:54	591
445	555	logout	2025-11-14 12:06:23	234
447	186	click	2025-05-18 19:28:49	-1
448	117	click	2024-11-19 16:34:26	60
449	393	click	2025-01-14 03:03:08	45
450	271	click	2025-04-26 21:08:47	84
452	492	click	\N	550
451	557	click	2024-09-10 23:26:25	288
455	539	logout	2025-04-04 04:43:37	591
453	117	logout	2025-02-17 13:38:42	411
456	489	logout	2024-07-21 09:35:53	-1
454	668	login	2024-06-04 04:32:58	459
457	615	click	2024-11-20 19:02:16	139
463	97	login	2024-08-09 18:33:56	376
458	110	view	2025-03-30 09:27:16	420
467	217	logout	2026-03-11 21:04:29	600
459	344	purchase	2025-09-21 21:03:45	98
468	55	click	2024-09-25 22:43:18	117
460	567	view	2025-05-17 21:00:27	10
472	79	logout	2026-01-04 20:41:59	593
461	444	click	2026-04-22 23:49:12	321
474	58	click	2025-01-22 10:41:18	303
462	417	view	2026-03-20 05:08:42	205
477	562	view	2025-12-11 03:51:24	286
464	361	click	2026-03-05 11:30:25	425
478	224	click	2025-05-17 02:47:09	330
465	106	purchase	2024-06-08 12:12:04	224
480	-1	purchase	2024-12-16 06:11:43	69
466	500	logout	2024-11-01 11:56:56	588
481	645	purchase	2024-11-12 09:49:20	432
469	213	view	2025-10-25 20:27:50	437
483	-1	view	2025-10-22 23:21:25	556
470	506	click	2024-12-10 03:13:11	228
488	678	logout	2025-03-20 05:18:19	-1
471	-1	view	2025-07-31 10:53:56	248
489	439	purchase	2026-02-14 12:57:03	594
473	38	view	2026-04-27 08:09:02	-1
492	-1	login	2024-09-18 23:06:23	193
475	381	purchase	2026-02-24 00:17:11	350
496	-1	login	2025-10-27 09:44:07	301
476	-1	click	2024-09-16 01:11:30	-1
497	12	click	2025-02-27 05:32:16	176
479	351	purchase	2025-06-15 07:35:43	-1
499	538	click	2026-02-16 18:56:41	63
482	184	view	2026-02-09 17:04:17	187
503	304	logout	2025-07-27 06:27:57	278
484	405	logout	2026-01-02 10:30:51	265
504	160	view	2025-04-18 03:46:53	287
485	101	logout	2025-10-02 05:37:49	240
507	121	logout	2026-01-26 04:13:11	67
486	97	click	2024-11-26 19:16:22	-1
510	553	view	2024-11-08 20:35:22	479
487	-1	login	2025-01-24 09:58:33	534
511	40	click	2024-10-19 14:15:02	333
490	552	purchase	2025-01-07 01:32:51	33
517	615	click	2025-07-30 20:58:32	240
491	576	logout	2024-05-30 17:19:07	181
518	238	view	2024-09-20 12:09:19	96
493	337	view	2026-01-19 08:46:53	521
521	130	click	2025-05-07 21:29:38	388
494	66	click	2026-02-19 05:06:05	-1
523	420	purchase	2025-08-06 03:30:01	552
495	482	login	2025-08-01 03:14:31	490
527	295	click	2026-04-17 15:13:46	181
498	662	purchase	2025-05-02 06:16:10	-1
528	393	click	2024-12-21 14:05:33	352
500	422	click	2024-12-28 08:17:39	241
529	22	click	2025-06-24 20:12:53	23
501	445	view	2025-02-26 13:03:42	558
532	624	login	2025-01-10 19:54:33	9
502	103	purchase	2025-04-20 15:21:01	173
534	291	purchase	2025-06-29 21:32:12	482
505	251	purchase	\N	-1
536	536	view	2026-01-15 18:44:25	-1
506	316	purchase	2025-05-24 05:46:23	94
538	218	purchase	2024-11-29 08:16:33	-1
508	345	purchase	\N	590
540	441	logout	2025-04-22 21:25:16	265
509	292	login	2024-07-26 12:22:49	-1
542	444	view	2024-10-19 16:39:25	-1
512	96	logout	2026-04-15 17:25:01	184
544	537	login	2025-12-07 08:35:55	402
513	395	view	\N	205
545	492	login	2025-08-13 12:36:38	334
514	326	logout	2025-02-03 08:52:24	592
546	1	view	2025-06-27 20:19:00	518
515	608	view	2025-10-15 22:59:00	179
547	433	view	2025-12-10 13:34:48	300
516	248	login	2025-11-09 08:18:21	434
549	377	login	2025-12-17 00:53:04	336
519	67	logout	2026-03-23 09:00:00	197
551	662	login	2024-09-06 07:28:59	591
520	624	logout	2025-05-12 23:28:26	313
552	235	purchase	2026-01-27 01:54:01	271
522	435	logout	2025-03-21 00:18:17	277
553	183	login	2026-03-13 15:49:25	550
524	620	click	2026-01-02 16:15:11	484
554	602	purchase	2025-09-29 09:20:15	128
525	380	logout	2026-03-23 15:57:53	-1
557	386	purchase	2026-05-21 05:20:55	74
526	261	logout	2026-03-13 03:56:21	371
559	587	login	2024-06-08 02:07:00	54
530	592	click	2025-08-14 14:47:26	573
561	20	view	\N	82
531	649	logout	2025-10-10 19:05:21	383
562	145	logout	2026-03-09 05:53:42	342
533	255	logout	2025-04-16 17:46:47	433
566	50	login	2025-02-26 14:24:19	151
535	415	purchase	2024-11-08 22:46:56	563
567	53	login	2025-08-29 02:48:49	312
537	349	logout	2026-01-19 07:20:00	467
568	697	logout	2024-08-28 11:32:45	521
539	661	login	2024-11-13 21:32:07	445
569	613	click	2024-10-28 20:17:16	551
541	-1	view	2024-10-21 05:38:02	23
570	74	click	2026-05-16 00:46:08	380
543	451	view	\N	221
571	451	view	2024-11-10 12:11:23	49
548	268	click	2026-01-20 06:09:20	213
573	287	login	2025-04-23 08:58:30	439
550	20	purchase	2024-06-01 15:17:02	18
574	178	click	2026-03-28 11:21:53	402
555	308	click	2026-03-24 07:52:53	247
578	515	click	2024-08-28 15:33:45	195
556	552	login	2025-06-13 01:25:37	177
579	457	purchase	2025-05-25 12:25:04	29
558	645	click	2025-07-05 21:38:55	295
583	360	view	2025-10-16 15:38:02	483
560	688	purchase	2025-08-10 05:57:34	227
585	60	view	2026-01-24 21:07:14	285
563	87	logout	2024-08-27 06:17:04	2
587	154	purchase	2026-03-06 05:18:09	352
564	302	logout	2024-06-25 19:45:38	151
588	251	purchase	2025-07-09 19:29:35	433
565	-1	purchase	2025-08-02 14:29:47	487
589	375	click	2025-09-23 09:15:57	134
572	460	view	2025-04-04 20:26:01	309
591	38	view	2025-12-28 07:49:22	585
575	456	view	2024-09-04 13:37:45	568
592	81	click	2025-07-17 07:28:11	599
576	620	login	2025-09-20 03:25:22	508
593	682	login	2025-01-16 04:06:11	-1
577	384	purchase	2025-05-09 05:33:57	293
595	322	view	2025-07-05 22:37:39	326
580	246	login	2024-07-23 02:09:15	487
596	515	login	2025-09-18 19:12:35	284
581	-1	click	\N	492
597	412	purchase	2025-12-08 06:21:12	482
582	432	view	2024-10-15 03:38:35	456
598	460	view	2025-02-17 04:11:33	419
584	213	click	2024-10-20 08:15:13	-1
599	524	view	2026-04-14 07:44:29	473
586	35	purchase	2026-04-04 17:52:48	519
602	414	logout	2025-12-09 04:10:46	18
590	422	view	2025-08-04 06:47:24	14
605	589	login	2025-01-27 10:22:20	293
594	-1	logout	2025-07-30 18:22:08	409
606	18	login	2024-08-20 07:13:05	-1
600	598	login	2025-10-05 05:15:47	151
608	364	view	2026-01-29 07:08:58	386
601	-1	purchase	2025-12-06 07:38:41	378
609	34	purchase	2025-02-06 06:43:33	250
603	540	view	2026-03-09 16:49:32	169
614	517	click	2025-02-27 04:50:49	85
604	-1	click	\N	185
615	551	login	2025-08-17 02:30:04	509
607	548	click	2025-12-12 03:02:23	57
619	326	view	2024-11-07 14:41:18	-1
610	219	view	2024-12-23 21:17:27	513
621	501	purchase	2025-03-08 17:01:33	-1
611	348	login	2026-02-05 16:36:12	310
623	175	logout	2024-12-22 20:56:27	339
612	-1	purchase	2025-09-09 15:41:51	289
624	370	view	2026-01-10 06:06:21	354
613	-1	click	2024-10-25 15:26:53	232
625	636	logout	2024-10-03 09:19:32	100
616	491	click	2025-01-05 09:09:50	209
627	94	view	2026-04-07 22:38:39	201
617	376	click	\N	364
629	266	logout	2024-06-13 06:01:32	178
618	527	purchase	2024-06-07 03:29:51	429
630	320	view	2024-08-31 09:00:33	379
620	540	purchase	2025-01-29 09:49:14	122
632	602	view	2025-11-11 18:44:49	528
622	635	logout	2026-02-03 13:47:45	78
633	322	click	2025-10-12 17:00:34	90
626	602	logout	2025-07-14 07:36:44	586
636	65	view	2025-06-13 07:39:52	315
628	546	purchase	2024-08-27 00:33:57	194
637	-1	login	2025-01-05 00:32:44	103
631	589	click	2025-06-11 14:19:57	54
638	49	login	2025-11-01 20:28:43	563
634	303	view	2025-12-04 20:29:23	86
639	311	purchase	2024-07-08 21:11:49	417
635	341	purchase	2025-12-07 22:39:57	56
641	123	click	2025-03-25 04:36:00	101
640	-1	purchase	2025-11-10 06:58:35	311
642	145	logout	2026-03-21 03:30:42	-1
648	428	click	2024-06-10 22:06:36	86
643	274	view	2025-02-07 10:05:28	85
649	649	purchase	2025-09-09 12:23:36	412
644	633	view	\N	108
650	175	login	2024-09-19 13:00:10	583
645	-1	login	2026-05-19 17:24:34	96
651	391	view	2025-11-30 21:24:21	-1
646	18	logout	2026-01-30 16:42:35	164
652	278	view	2024-06-09 18:09:55	12
647	681	view	2025-03-29 02:11:04	145
655	565	view	2025-12-30 10:21:35	162
653	354	click	2025-09-30 01:43:19	-1
656	-1	login	2025-03-21 11:52:45	274
654	649	purchase	2024-08-07 07:29:07	136
657	573	login	2025-05-26 08:50:30	261
659	91	click	2024-12-01 17:19:23	46
658	196	view	2025-09-26 07:48:02	359
660	340	logout	2024-07-12 02:22:45	24
662	45	view	2024-08-13 14:33:52	187
661	-1	logout	2024-08-17 17:04:20	390
663	-1	purchase	2026-01-01 08:15:03	489
665	350	logout	\N	86
664	270	login	2025-04-09 13:44:52	-1
667	402	purchase	2025-10-01 14:41:56	97
666	650	logout	2025-03-25 21:20:32	447
668	399	purchase	2024-07-22 15:53:54	138
670	454	login	2024-08-01 14:05:29	-1
669	226	login	2025-03-17 14:55:16	523
671	639	view	2026-01-03 13:39:04	54
674	287	logout	2025-02-12 03:02:56	458
672	427	click	2024-10-23 17:29:43	24
676	18	view	2024-07-23 23:55:21	263
673	91	click	2024-09-27 21:25:37	10
680	-1	purchase	2025-08-22 08:24:18	452
675	82	logout	\N	522
681	132	logout	2026-03-31 01:52:17	96
677	534	purchase	2025-07-21 19:48:59	574
682	419	view	2025-12-31 13:29:30	340
678	173	logout	2026-04-26 21:20:09	76
683	-1	login	2025-12-18 15:29:09	570
679	604	view	2025-05-13 04:30:09	577
685	542	login	2025-04-03 12:50:01	340
684	262	logout	2025-06-21 07:24:30	-1
686	390	click	2026-04-02 23:21:05	171
688	539	logout	2025-01-27 01:57:48	114
687	377	logout	2026-03-08 11:37:47	163
691	-1	login	2025-03-13 03:06:16	420
689	540	click	2024-08-16 12:41:53	43
692	655	view	2024-12-25 06:00:57	409
690	448	logout	2026-05-05 15:48:54	549
696	331	purchase	2025-05-25 08:50:06	163
693	286	logout	2024-06-19 13:11:25	276
697	516	login	2025-09-13 05:28:59	469
694	288	logout	2024-08-18 07:20:42	151
700	124	view	2025-12-08 11:44:34	-1
695	82	click	2026-02-22 07:38:42	490
701	505	purchase	2024-11-06 16:41:55	-1
698	284	view	2026-03-18 08:59:13	299
702	417	purchase	2024-06-26 02:32:21	367
699	540	click	2025-07-01 04:43:40	331
703	657	view	2025-11-26 00:49:57	452
704	543	click	2024-10-14 02:58:08	9
705	52	click	2025-03-04 10:20:51	517
706	189	view	2024-07-27 15:25:45	197
708	177	click	2024-12-07 20:01:08	288
707	39	purchase	2025-06-08 02:38:19	159
709	555	click	2025-01-11 14:39:14	-1
712	85	logout	2024-11-20 00:50:58	282
710	172	login	2025-12-12 22:49:22	582
714	6	purchase	2025-04-10 11:00:12	450
711	644	purchase	2025-10-31 11:54:48	51
716	107	purchase	2024-09-22 00:22:20	427
713	9	click	2026-02-09 15:50:49	567
717	17	logout	2025-09-17 03:20:16	403
715	248	logout	2024-12-15 09:05:20	498
718	42	login	2025-01-31 18:38:50	274
720	645	click	2025-01-18 11:34:54	307
719	413	click	2026-02-13 02:47:51	50
721	640	view	2025-03-26 15:17:23	157
722	-1	purchase	2025-11-28 04:28:23	-1
723	700	logout	2025-03-29 16:43:01	44
724	175	purchase	2026-02-11 15:01:55	223
725	571	view	2025-11-02 11:13:50	465
728	380	logout	2024-11-30 22:44:19	405
726	349	logout	2026-05-11 12:29:54	163
732	468	purchase	2025-04-01 01:13:26	587
727	396	purchase	2025-04-09 14:15:33	-1
734	619	purchase	2025-07-25 10:27:53	103
729	3	logout	2026-03-20 19:34:29	23
735	440	logout	2024-09-01 04:13:51	533
730	493	view	2025-09-08 11:58:50	577
736	690	logout	2026-02-25 02:38:22	345
731	-1	view	2025-01-01 22:00:18	67
737	679	purchase	2024-12-22 09:16:44	445
733	694	purchase	2025-01-17 22:36:13	315
739	-1	purchase	2025-07-31 18:57:45	-1
738	359	purchase	2026-03-05 09:23:53	38
740	270	click	2025-02-07 16:42:43	314
741	228	login	2025-09-08 18:39:43	505
743	145	logout	2025-08-23 12:11:14	-1
742	105	login	2024-08-07 10:21:00	179
745	355	logout	2025-06-10 08:50:51	128
744	56	click	2025-08-09 14:12:21	116
748	630	click	2024-10-20 04:14:26	269
746	53	view	2024-12-25 03:31:23	342
758	644	click	2024-11-10 02:15:12	245
747	659	login	2025-05-31 20:31:14	295
759	219	purchase	2026-03-11 13:35:39	308
749	-1	click	2025-03-15 07:09:40	375
760	19	purchase	2024-10-09 17:42:14	-1
750	480	purchase	2025-09-06 02:47:41	107
763	570	purchase	2026-05-16 19:27:59	43
751	229	login	2025-10-11 20:06:58	403
764	531	login	2025-08-08 00:47:55	382
752	547	purchase	2025-10-17 11:51:16	-1
766	196	login	2025-04-17 01:46:20	80
753	682	click	2024-11-10 04:35:38	550
767	472	view	2024-08-09 03:30:28	41
754	376	purchase	2025-02-06 09:39:35	597
768	108	view	2025-08-03 13:51:46	472
755	353	logout	2024-09-27 14:36:17	500
769	587	purchase	2025-04-04 06:11:30	501
756	371	view	2026-01-25 13:09:34	413
773	681	logout	2026-04-24 04:13:50	412
757	46	logout	2025-08-07 23:18:56	269
774	694	click	2025-12-14 21:40:15	499
761	456	view	2026-03-28 02:26:58	505
776	418	view	2024-07-09 01:15:47	137
762	686	click	2024-11-04 04:50:38	128
780	318	purchase	2025-11-27 09:42:44	233
765	-1	view	2025-08-19 05:10:28	27
782	424	view	2025-05-22 15:02:00	275
770	557	logout	2024-07-28 18:54:18	542
784	681	login	2025-05-29 15:13:34	234
771	321	view	2024-08-13 11:57:05	160
786	158	view	2024-12-02 10:55:11	351
772	113	purchase	2025-01-16 11:11:43	243
789	536	logout	2025-07-11 14:22:57	130
775	246	purchase	2026-02-14 18:05:37	-1
790	689	click	2026-05-07 16:04:58	171
777	547	purchase	2026-04-13 07:11:38	219
791	78	click	2024-10-26 23:40:31	163
778	237	view	2025-08-03 20:08:13	-1
793	582	click	2024-06-19 06:51:48	-1
779	8	click	2024-05-28 04:59:12	480
795	645	login	2024-09-23 20:08:06	220
781	443	click	2024-09-04 02:49:18	582
796	186	purchase	2025-03-20 15:13:08	79
783	533	click	2024-06-07 16:25:49	12
797	113	logout	2025-11-05 16:41:02	351
785	373	login	2025-01-28 14:13:50	575
799	-1	view	2025-09-21 12:17:27	553
787	186	login	2025-01-15 17:04:53	483
804	250	purchase	2025-07-15 18:30:19	62
788	606	view	2024-09-12 06:02:07	519
807	299	login	2025-05-29 10:44:38	587
792	387	view	2026-02-13 09:26:44	560
811	652	view	2024-05-28 14:21:29	43
794	314	purchase	2026-03-19 12:02:18	271
812	289	logout	2025-04-28 01:31:58	51
798	88	login	2024-05-25 20:56:57	19
813	673	logout	2025-09-01 07:10:06	589
800	103	click	2026-04-20 23:41:12	440
816	479	logout	2024-07-19 00:20:45	411
801	526	view	2025-06-26 01:44:04	287
818	397	purchase	2025-03-13 07:17:52	583
802	509	purchase	2024-06-12 19:49:59	138
820	306	view	2025-10-17 18:13:35	-1
803	-1	view	2025-07-19 19:19:28	535
822	573	click	2025-12-06 20:04:48	558
805	100	login	2025-04-15 23:59:48	213
823	146	login	2025-01-11 03:37:21	474
806	-1	view	2025-12-23 19:55:27	405
824	284	purchase	2024-11-03 08:46:14	69
808	11	login	2026-03-09 20:35:37	557
825	613	login	2025-03-12 01:20:13	350
809	243	login	2026-01-19 20:11:34	-1
828	467	purchase	2026-05-04 08:42:14	145
810	-1	login	2025-09-29 15:43:25	68
829	618	purchase	2025-06-14 15:33:58	516
814	228	click	2025-08-24 12:07:12	305
830	306	logout	2024-08-23 04:35:24	5
815	671	login	2024-07-20 03:07:47	440
834	84	view	2024-11-24 07:49:39	557
817	38	click	2025-02-21 10:46:17	21
835	251	logout	2026-04-18 09:38:25	526
819	34	login	2026-04-24 18:15:25	235
836	651	login	2025-04-03 12:55:10	13
821	462	view	2025-10-13 17:43:25	383
837	226	logout	2024-09-30 11:20:08	505
826	176	view	2024-09-02 16:44:27	116
838	505	login	2026-01-19 19:27:41	197
827	434	view	2025-05-10 17:20:16	523
839	34	logout	2026-04-11 14:24:22	59
831	419	click	2025-03-16 01:02:30	335
840	587	click	2025-09-03 05:18:48	392
832	87	purchase	2025-12-04 16:48:58	387
843	459	purchase	2025-01-10 09:33:42	571
833	588	purchase	2024-07-31 14:15:47	167
845	-1	purchase	2025-01-06 07:45:28	333
841	5	login	2026-01-01 13:41:30	238
846	672	logout	2025-10-27 00:56:13	466
842	650	logout	2024-06-09 08:08:34	245
848	243	click	2025-11-28 07:23:06	595
844	465	login	2025-06-07 23:53:47	447
855	369	purchase	2024-09-16 07:41:20	424
847	693	click	2025-11-24 16:57:38	484
856	121	view	2024-12-24 12:17:31	590
849	431	login	2025-06-23 15:27:33	512
857	485	login	2026-02-11 21:01:08	360
850	271	purchase	2025-02-23 03:33:59	1
860	346	view	2025-06-14 14:37:46	594
851	310	logout	2025-02-19 14:27:24	-1
861	11	purchase	2024-12-15 09:44:07	390
852	311	login	2024-11-29 19:36:02	223
865	-1	login	2025-11-20 05:00:46	468
853	120	purchase	2026-01-26 03:38:11	350
866	450	login	2025-12-22 08:33:28	211
854	297	view	2025-06-01 01:58:22	598
868	509	click	2024-07-04 08:39:20	455
858	429	click	2026-03-07 23:38:06	467
870	245	view	2024-12-28 13:23:06	-1
859	156	logout	2024-11-20 08:08:08	520
877	551	purchase	2024-12-10 04:24:40	-1
862	542	login	\N	445
879	-1	view	2024-12-02 06:27:55	272
863	389	logout	2024-06-20 23:29:18	418
882	593	logout	2025-04-05 07:20:47	263
864	70	click	2025-09-02 04:21:17	562
883	171	purchase	2025-09-05 06:38:18	543
867	584	login	2024-06-15 00:51:50	229
886	564	login	2025-11-06 22:20:13	29
869	72	view	2025-07-05 15:05:37	449
889	96	purchase	2025-11-06 16:59:57	425
871	430	view	2026-04-19 17:41:15	172
890	214	logout	2026-04-05 21:14:54	553
872	295	click	2025-07-07 00:20:45	248
894	486	logout	2025-03-13 23:38:08	308
873	54	click	2025-06-14 14:06:25	236
900	370	purchase	2025-06-30 23:43:46	283
874	259	view	2025-11-20 08:49:32	29
901	543	click	2025-02-27 04:47:55	70
875	387	purchase	2024-09-15 23:50:03	3
903	478	view	2024-08-14 14:02:46	365
876	409	click	2025-09-05 06:56:25	449
904	176	logout	2024-12-09 10:09:02	283
878	313	logout	2024-11-24 15:21:50	494
905	175	click	2025-06-03 23:01:23	408
880	260	logout	2024-07-09 12:04:28	545
906	57	purchase	2026-05-05 22:18:59	556
881	491	purchase	2025-01-07 00:59:26	120
907	194	logout	2025-06-08 12:48:10	520
884	7	login	2025-04-20 10:43:23	310
908	506	click	2026-04-30 14:51:38	222
885	136	view	2025-07-17 11:52:21	435
909	408	view	2025-10-09 11:37:33	91
887	696	click	2026-03-16 17:33:22	134
915	633	view	2025-08-01 20:01:06	48
888	173	view	2024-07-10 02:50:00	36
916	123	click	2024-11-28 05:37:40	362
891	484	login	2024-07-15 22:31:09	532
918	4	logout	2026-04-26 03:14:12	203
892	509	view	2024-10-04 09:02:40	162
922	86	click	2026-01-22 22:37:32	478
893	318	login	2024-12-11 22:00:15	116
924	318	purchase	2024-10-20 03:13:26	479
895	118	click	2025-12-10 12:45:08	188
927	183	logout	2025-05-25 13:59:39	482
896	555	view	2025-09-22 05:41:03	20
928	-1	login	2024-06-05 05:55:32	473
897	332	view	2025-08-27 01:20:33	500
930	203	purchase	2026-01-23 09:59:29	-1
898	320	view	2025-11-05 17:56:40	22
933	229	view	2024-07-16 11:01:30	-1
899	151	view	2024-06-16 20:48:53	501
935	-1	purchase	2025-09-12 19:53:32	483
902	57	purchase	2024-07-02 17:42:53	135
937	582	logout	2024-09-12 22:27:15	363
910	266	logout	2025-04-14 11:04:50	138
939	416	click	2025-10-23 23:15:33	268
911	411	purchase	2025-06-30 12:22:45	545
941	237	view	2026-05-23 16:11:42	275
912	351	view	2025-10-04 11:26:15	472
943	478	view	2026-05-06 20:34:41	189
913	8	view	2026-01-12 18:01:31	580
944	187	view	2024-07-22 08:12:30	337
914	443	login	2025-07-22 00:44:07	29
946	68	click	2025-08-28 19:44:33	229
917	130	click	2025-06-08 03:29:44	461
948	460	click	2025-02-16 03:18:00	552
919	489	logout	2025-01-20 10:20:25	106
950	-1	login	2024-07-18 02:08:42	85
920	352	purchase	2024-12-19 18:59:14	128
952	171	click	2026-03-02 01:56:10	477
921	80	click	2025-07-14 14:41:10	455
954	-1	logout	2025-09-30 07:24:39	589
923	343	login	2025-08-07 18:25:46	114
959	411	logout	2025-09-19 23:50:01	63
925	244	click	2025-01-31 04:32:27	355
960	444	purchase	2024-09-30 17:01:27	275
926	616	logout	2024-08-11 22:56:53	72
961	585	click	2024-08-08 00:30:59	237
929	492	purchase	2026-04-08 17:07:52	314
964	179	logout	2026-02-28 15:05:19	343
931	474	click	2026-02-14 22:36:57	386
965	468	logout	2025-07-06 17:51:57	227
932	371	purchase	2026-03-31 02:04:06	315
966	-1	login	2026-01-09 05:25:51	349
934	586	click	2026-03-12 06:07:46	547
967	255	click	2025-11-18 21:04:38	236
936	596	view	2024-11-25 16:42:01	52
969	-1	logout	2024-09-09 11:00:26	196
938	495	login	2026-02-16 21:44:04	172
971	356	view	2025-03-14 09:40:34	129
940	609	view	2024-07-06 19:07:01	-1
972	255	purchase	2025-03-25 23:04:50	30
942	645	view	2025-03-18 15:50:08	152
974	548	view	2026-02-27 19:26:40	274
945	432	view	2024-10-06 09:32:25	-1
977	313	logout	2024-09-14 19:32:15	381
947	223	logout	2026-01-25 00:14:59	280
981	-1	purchase	2024-05-24 17:26:05	261
949	653	purchase	2024-10-24 04:07:42	426
982	71	login	2024-12-17 08:22:32	510
951	362	logout	\N	173
984	443	click	2025-11-16 01:30:37	-1
953	-1	login	2026-03-21 04:35:51	44
985	666	purchase	2025-07-25 10:26:35	18
955	39	view	2025-06-19 15:45:37	465
987	688	logout	2025-10-16 09:56:44	443
956	417	purchase	2024-08-15 23:10:51	463
990	158	logout	2024-08-17 23:00:11	395
957	516	purchase	2026-03-26 07:46:42	54
991	513	login	2025-06-12 23:25:28	472
958	-1	click	2026-04-19 14:48:25	128
993	25	logout	2026-04-19 12:30:20	-1
962	-1	logout	\N	328
994	39	view	2025-02-18 17:51:54	428
963	218	logout	2025-07-13 05:27:26	356
996	526	logout	2026-03-12 18:52:02	-1
968	434	click	2024-08-18 11:29:25	488
998	249	view	2025-05-04 20:52:05	521
970	-1	click	2025-07-27 03:04:17	236
1001	37	login	2026-02-22 05:20:32	410
973	500	purchase	2024-07-25 23:05:40	333
1002	571	click	2024-08-30 00:37:57	181
975	650	view	2025-06-28 16:01:00	156
1004	161	logout	2025-11-05 04:44:29	298
976	664	purchase	2025-04-18 01:42:43	403
1005	459	click	2025-10-21 21:53:41	361
978	382	click	2025-06-21 12:41:32	523
1007	547	login	2026-02-02 11:00:40	533
979	37	logout	2025-08-01 02:17:59	94
1010	473	purchase	2026-04-16 22:52:24	270
980	256	purchase	2024-06-11 21:04:07	358
1012	-1	purchase	2025-05-29 22:06:57	575
983	322	view	2026-01-10 08:18:34	402
1014	363	purchase	2024-07-04 00:19:16	375
986	441	login	2024-12-21 16:41:40	77
1016	516	login	2025-08-27 17:21:21	151
988	244	view	2024-11-10 06:35:55	1
1018	439	click	2025-12-10 14:32:59	481
989	470	view	2026-02-11 19:48:02	297
1020	102	logout	2024-12-22 10:42:01	-1
992	80	click	2025-12-01 14:10:37	433
1021	165	view	2024-07-06 09:05:15	561
995	99	click	2025-08-17 06:06:37	498
1025	605	logout	2025-11-13 11:57:24	38
997	-1	login	2025-06-12 19:42:25	396
1026	682	logout	2026-01-22 01:23:38	582
999	485	purchase	2024-11-25 20:05:13	362
1028	490	login	2025-11-07 10:15:55	220
1000	431	view	2026-01-21 21:25:36	-1
1030	688	view	2025-04-07 15:12:50	299
1003	-1	login	2025-12-07 04:30:31	500
1032	19	purchase	2024-06-07 18:34:28	582
1006	431	login	2024-06-29 16:28:17	30
1033	580	login	2026-05-21 17:52:17	278
1008	613	logout	2025-01-02 21:39:52	262
1034	424	click	2025-11-29 12:55:26	509
1009	355	logout	2025-06-19 04:39:30	422
1037	648	view	2025-10-02 02:19:27	256
1011	-1	login	2026-04-11 02:55:07	528
1038	39	purchase	2025-02-19 19:51:34	392
1013	346	view	2024-12-26 23:35:08	312
1039	480	view	2024-09-14 06:25:52	81
1015	412	purchase	2024-08-26 21:53:06	92
1040	676	logout	2024-09-12 08:29:23	269
1017	17	click	2024-09-08 07:26:37	355
1041	105	click	2024-06-13 04:00:40	520
1019	-1	click	\N	205
1043	-1	view	2025-05-09 02:29:46	223
1022	493	view	2025-11-23 19:22:22	148
1052	113	view	2025-10-30 19:30:37	390
1023	269	click	2025-12-13 03:57:30	298
1053	696	logout	2024-10-09 15:20:51	270
1024	346	view	2024-09-06 18:40:15	303
1054	125	click	2025-08-11 20:43:06	419
1027	508	login	2024-08-26 13:18:21	523
1055	7	view	2025-09-26 05:52:01	95
1029	14	purchase	2024-12-13 18:42:15	226
1056	514	view	2026-05-19 12:56:32	595
1031	229	logout	2025-06-22 03:32:16	232
1058	674	click	2025-11-20 08:42:43	498
1035	-1	view	2025-09-18 00:29:32	387
1059	420	click	2025-12-23 06:49:50	47
1036	161	click	2024-08-17 21:22:50	336
1060	226	purchase	2024-12-25 02:11:03	72
1042	13	login	2025-05-20 13:01:35	45
1061	529	logout	2024-09-25 19:12:08	320
1044	594	logout	2025-01-17 13:48:07	283
1062	10	purchase	2025-07-12 15:59:15	238
1045	498	view	2024-07-26 19:30:00	391
1069	279	click	2024-12-12 23:22:58	157
1046	199	purchase	2025-06-15 01:20:05	401
1070	469	login	2024-12-16 12:14:16	56
1047	627	logout	2025-11-07 13:44:52	289
1072	272	logout	2024-08-28 09:34:54	538
1048	311	view	2025-02-02 00:31:28	266
1075	646	purchase	2025-11-01 18:35:41	395
1049	-1	purchase	2025-09-07 23:18:38	403
1076	18	login	2024-10-19 22:11:28	462
1050	196	click	2026-01-20 08:35:40	241
1078	47	login	2024-07-28 18:47:30	38
1051	474	purchase	2025-08-17 22:54:09	76
1085	-1	click	2025-06-30 18:48:01	110
1057	631	purchase	2024-08-18 13:17:07	388
1086	26	login	2025-08-13 06:52:37	5
1063	161	view	2025-05-20 03:01:14	-1
1087	74	click	2024-08-10 14:56:48	321
1064	-1	purchase	2026-02-22 00:39:02	515
1088	588	logout	2025-10-31 01:03:15	207
1065	370	logout	2025-03-05 01:12:30	49
1090	453	login	2024-12-20 06:32:19	38
1066	396	purchase	2024-11-29 16:36:20	516
1091	285	click	2026-03-01 07:47:42	275
1067	470	view	\N	108
1092	294	purchase	2025-12-11 20:22:14	-1
1068	269	purchase	2025-08-17 01:22:45	400
1093	434	click	2025-09-06 13:12:52	532
1071	466	view	2025-03-07 20:55:15	461
1094	311	login	2026-02-24 20:47:07	351
1073	-1	click	2025-08-14 00:48:21	110
1095	384	click	2026-03-20 16:20:28	112
1074	-1	logout	2025-01-09 08:56:12	191
1096	492	view	2024-07-03 16:48:09	240
1077	360	view	2025-07-04 23:41:31	570
1097	369	view	2024-10-02 22:02:22	57
1079	-1	logout	2026-01-27 01:57:52	341
1099	642	purchase	2024-05-24 14:49:26	396
1080	303	view	2025-01-18 00:16:53	232
1100	-1	logout	2024-11-07 20:05:38	468
1081	-1	purchase	\N	288
1103	-1	click	2024-05-25 05:56:35	574
1082	452	logout	2025-08-26 21:19:50	-1
1104	358	login	2025-01-13 08:07:35	250
1083	308	login	2025-08-21 18:03:23	598
1105	637	login	2025-10-31 02:58:01	398
1084	532	logout	2025-05-11 21:16:53	72
1106	567	view	2024-09-07 09:06:54	81
1089	38	view	2025-02-18 00:50:30	76
1111	398	view	2025-09-12 04:34:45	-1
1098	319	logout	2026-04-09 01:01:25	394
1112	571	purchase	2025-11-02 21:39:54	403
1101	242	login	2024-06-07 14:20:18	582
1113	310	logout	2025-08-30 05:42:40	-1
1102	311	click	2025-11-22 18:57:56	508
1114	-1	purchase	2025-06-13 14:53:08	-1
1107	248	click	2025-08-30 00:46:33	494
1115	662	login	\N	237
1108	624	view	2026-04-19 23:45:01	375
1116	614	purchase	2024-09-29 22:26:13	487
1109	373	view	2026-02-03 14:52:07	235
1121	114	view	2025-11-16 21:29:54	335
1110	328	click	2025-12-18 07:45:39	125
1122	435	view	2025-12-19 01:30:45	471
1117	-1	view	2025-08-23 22:04:45	405
1124	642	click	2024-08-12 02:19:52	237
1118	408	logout	2025-10-30 07:31:03	371
1125	2	logout	2026-04-04 08:22:39	198
1119	330	view	2025-03-05 22:14:01	-1
1126	544	login	2025-11-03 13:12:49	-1
1120	178	view	\N	83
1128	131	click	2026-03-10 04:48:53	271
1123	198	purchase	2026-02-21 21:34:26	-1
1130	644	login	2025-12-03 22:48:51	372
1127	53	logout	2026-03-27 07:33:19	490
1132	74	logout	2026-01-14 09:26:06	144
1129	682	view	2024-07-19 21:03:31	478
1134	295	login	2025-08-12 01:09:22	-1
1131	325	view	2024-05-31 19:22:49	130
1136	195	view	2026-04-19 04:02:57	447
1133	22	view	2024-12-28 22:12:53	408
1137	623	logout	2024-09-30 23:18:24	-1
1135	643	click	2024-09-18 13:21:24	160
1140	683	logout	2025-08-24 07:18:33	184
1138	625	login	2024-11-19 18:56:59	445
1142	466	click	2026-03-12 19:28:22	-1
1139	-1	click	2024-08-11 02:40:47	592
1143	247	purchase	2024-08-11 16:56:41	-1
1141	352	logout	2025-04-07 19:05:02	412
1144	582	click	2025-01-17 06:15:35	321
1147	645	logout	2025-09-13 18:33:16	116
1145	190	login	2024-07-27 10:50:46	265
1151	609	view	2026-03-24 09:41:21	398
1146	309	purchase	2025-06-11 06:30:29	255
1152	-1	login	2026-03-29 17:56:55	-1
1148	119	click	2024-07-27 11:08:51	437
1154	17	purchase	2025-09-12 14:16:27	242
1149	-1	logout	\N	576
1156	405	click	2024-10-16 22:44:43	332
1150	512	purchase	2025-02-21 09:52:30	357
1158	638	logout	2024-10-28 10:52:58	502
1153	54	purchase	2026-05-14 17:53:42	156
1161	324	view	2025-08-27 19:01:58	150
1155	480	login	2025-11-12 22:48:23	407
1164	13	logout	2024-11-27 22:30:25	364
1157	521	logout	2026-05-11 15:19:52	180
1165	403	login	2025-12-23 07:29:22	107
1159	480	login	2024-07-26 02:55:36	585
1167	211	view	2024-09-20 06:44:44	371
1160	201	purchase	2025-12-11 02:29:35	593
1170	143	click	2025-08-07 16:43:54	176
1162	261	purchase	2024-11-22 01:21:45	76
1172	538	click	2025-06-19 22:22:56	236
1163	66	click	2025-09-29 14:53:19	467
1174	558	click	\N	137
1166	106	logout	2024-08-22 21:59:46	165
1178	215	purchase	2026-04-03 17:20:07	-1
1168	408	view	2025-06-15 18:31:46	521
1179	-1	purchase	2025-12-01 15:24:44	20
1169	-1	click	2026-04-21 18:24:46	573
1181	634	logout	2025-10-05 22:31:20	132
1171	-1	login	2024-11-27 12:28:42	535
1182	132	click	2026-01-16 02:24:02	49
1173	-1	purchase	2025-06-04 18:26:22	298
1183	14	view	2024-10-05 00:38:42	138
1175	7	login	2025-12-25 09:58:03	564
1184	133	view	2025-10-28 01:44:02	542
1176	303	login	2024-07-15 03:41:39	72
1185	-1	click	2026-02-09 01:13:01	146
1177	448	click	2024-10-11 06:34:05	441
1188	-1	logout	2024-10-04 16:07:40	426
1180	19	view	2025-01-28 12:48:00	118
1189	-1	view	2026-03-24 02:42:48	437
1186	656	login	2024-11-06 14:58:53	210
1190	627	logout	2024-08-24 09:32:32	313
1187	589	login	2026-04-13 17:02:32	145
1195	338	view	2024-08-15 21:11:04	307
1191	10	view	2024-05-30 17:35:06	286
1197	-1	click	2025-12-26 06:04:32	122
1192	259	view	2024-12-29 15:03:28	447
1198	-1	view	2025-03-29 04:01:52	418
1193	401	login	\N	560
1199	631	login	2025-05-16 19:59:54	200
1194	295	purchase	2024-11-14 06:58:28	103
1200	126	click	2024-06-12 00:10:58	382
1196	147	login	2026-02-17 22:45:23	175
1206	110	purchase	2025-09-29 18:24:11	333
1201	164	click	2024-08-09 21:21:43	566
1208	457	logout	2025-04-17 22:59:57	412
1202	50	logout	2026-03-17 15:08:06	467
1211	547	logout	\N	-1
1203	664	purchase	2026-03-14 11:11:09	278
1215	47	purchase	2024-11-25 12:33:56	454
1204	59	purchase	2025-08-27 21:24:37	415
1220	700	login	\N	584
1205	179	click	2025-05-11 08:45:27	48
1221	366	logout	2024-11-14 03:11:32	40
1207	328	login	2024-10-22 12:43:30	475
1222	112	click	2025-06-01 12:29:59	211
1209	42	login	2025-09-15 11:10:06	-1
1225	444	view	2025-01-19 07:25:14	520
1210	20	view	2024-05-28 10:03:03	368
1226	651	logout	2024-12-08 16:49:31	233
1212	483	logout	2025-10-05 14:14:43	317
1232	693	click	2024-10-30 04:08:35	575
1213	135	click	2025-11-15 18:31:46	337
1233	630	logout	2024-11-29 21:19:32	560
1214	-1	purchase	2025-05-05 04:14:23	186
1235	53	logout	\N	5
1216	329	logout	2024-10-07 18:32:20	91
1237	627	purchase	2026-02-22 05:10:29	321
1217	110	login	2025-05-07 13:49:58	562
1240	175	click	2026-05-09 05:55:15	352
1218	-1	purchase	2024-10-31 11:40:57	479
1241	292	purchase	2024-07-15 10:51:33	364
1219	422	login	2025-02-11 19:56:54	333
1242	582	login	2025-09-01 16:02:56	266
1223	207	logout	2025-11-01 04:24:16	385
1243	256	logout	2024-10-10 22:29:58	-1
1224	-1	logout	2024-10-23 13:41:11	470
1244	529	logout	2024-08-26 13:51:33	474
1227	8	login	2025-09-04 05:40:29	109
1245	621	logout	2025-12-03 06:33:56	373
1228	120	logout	2025-05-17 09:38:01	491
1247	689	login	2024-11-12 07:06:23	566
1229	592	logout	2024-08-18 20:49:29	108
1255	194	logout	2025-04-27 16:06:18	134
1230	649	purchase	2024-08-17 04:00:24	50
1258	323	login	2025-10-16 13:57:02	339
1231	226	login	2025-02-08 12:56:15	532
1260	-1	click	2026-04-13 22:22:08	252
1234	265	logout	2025-06-26 17:37:31	249
1262	338	logout	2026-02-16 03:40:23	366
1236	482	logout	2024-09-20 05:19:07	597
1265	76	purchase	2025-07-21 12:30:20	370
1238	474	purchase	2026-02-03 04:13:53	318
1266	578	login	2025-08-02 09:04:15	114
1239	284	view	2024-10-11 23:40:38	596
1267	164	logout	2026-02-09 02:23:23	-1
1246	519	login	2025-10-28 09:13:26	229
1269	429	login	2024-09-21 23:26:42	106
1248	74	logout	2025-05-11 09:57:30	224
1270	158	click	2025-11-09 19:03:41	555
1249	314	login	2024-07-26 08:45:14	216
1276	552	purchase	2024-11-29 14:10:51	222
1250	59	view	2024-09-24 13:16:06	478
1278	591	view	2024-09-05 17:04:36	421
1251	477	view	2024-11-02 16:30:09	198
1280	410	click	2025-07-19 22:50:42	435
1252	324	view	2025-08-04 19:48:51	548
1282	455	purchase	2025-01-24 17:32:54	411
1253	224	click	2026-02-11 13:00:25	203
1287	488	view	2025-03-24 07:59:28	76
1254	-1	purchase	2025-01-28 07:20:41	242
1288	565	click	2025-12-02 14:51:16	237
1256	568	view	2026-03-15 11:27:57	230
1290	592	logout	2026-04-21 12:39:07	3
1257	90	click	2025-11-03 16:40:29	403
1293	149	login	2025-03-02 17:01:56	287
1259	122	login	2025-01-11 16:49:00	-1
1298	82	click	2025-10-21 22:48:24	591
1261	275	view	2025-01-20 18:55:19	-1
1300	375	purchase	2025-04-29 08:45:01	278
1263	322	login	2025-05-31 16:02:16	43
1301	503	logout	2024-10-24 21:05:05	20
1264	-1	login	2024-08-21 06:06:16	258
1302	663	purchase	2024-08-06 03:14:48	-1
1268	96	click	2024-12-09 10:21:31	15
1303	264	purchase	2026-03-08 04:32:01	473
1271	665	view	2026-02-08 21:24:32	304
1304	223	login	2025-03-23 03:24:26	481
1272	291	purchase	2026-04-22 03:47:36	5
1305	507	logout	2025-01-20 02:52:13	453
1273	263	purchase	2025-01-22 16:30:14	349
1309	157	click	2026-05-12 18:46:10	63
1274	595	click	2025-04-07 03:16:40	218
1310	614	click	2026-02-14 20:16:12	73
1275	-1	view	2025-01-06 12:54:05	499
1312	-1	click	2025-07-24 11:57:40	77
1277	238	login	2025-04-15 08:56:51	197
1314	-1	logout	2025-10-24 15:40:38	207
1279	-1	click	2025-07-13 00:43:04	251
1324	492	view	2025-03-19 14:27:01	57
1281	-1	click	2026-04-26 04:10:09	578
1325	483	view	2025-02-01 10:57:12	231
1283	107	logout	2026-04-06 07:53:04	474
1326	435	logout	2025-07-04 05:30:11	454
1284	25	view	2026-01-07 06:09:12	111
1327	612	click	2025-09-09 12:59:58	301
1285	-1	click	2024-08-28 15:49:55	214
1328	423	view	2026-03-31 10:20:41	69
1286	259	view	2025-10-17 10:40:22	-1
1329	-1	logout	2024-09-08 12:21:45	53
1289	603	view	2026-01-04 23:18:58	162
1330	693	view	2024-10-25 04:14:49	371
1291	346	login	2025-07-10 23:32:25	178
1333	236	logout	2025-03-14 23:09:47	84
1292	428	view	2024-06-03 03:05:32	129
1334	13	click	2025-11-08 05:08:50	482
1294	187	view	2025-12-31 19:54:27	-1
1335	374	logout	2024-07-01 23:23:37	472
1295	574	logout	2024-12-27 22:02:32	456
1336	691	purchase	2025-10-02 05:55:41	-1
1296	171	click	2024-11-26 14:13:25	199
1338	172	login	2026-05-04 19:47:50	-1
1297	155	logout	2026-01-06 05:01:58	27
1339	265	click	2024-10-30 18:53:05	86
1299	567	purchase	2026-01-04 00:09:57	430
1340	415	purchase	2026-05-08 21:04:52	217
1306	4	logout	2024-10-13 09:27:01	326
1344	459	view	2025-11-28 02:51:28	386
1307	491	view	2024-11-17 21:51:44	89
1345	5	purchase	2026-01-27 22:23:18	91
1308	146	logout	2025-12-17 14:21:10	465
1346	469	view	2025-04-20 03:06:17	534
1311	-1	login	2024-12-11 00:59:38	449
1348	282	logout	2025-08-07 05:27:55	60
1313	661	login	2024-06-05 19:36:03	397
1350	291	purchase	2025-07-13 13:14:11	272
1315	77	login	2025-08-08 14:26:28	484
1351	-1	logout	2025-02-10 02:54:50	448
1316	592	view	2024-09-19 19:50:46	597
1352	215	purchase	2026-05-07 05:07:19	325
1317	537	view	2024-08-12 06:52:48	269
1354	93	view	2024-11-16 01:08:00	531
1318	137	purchase	2025-11-15 00:53:01	383
1356	421	logout	2024-09-15 08:43:06	330
1319	689	view	2024-11-10 14:48:57	19
1358	591	logout	2025-07-08 12:31:07	54
1320	87	view	2024-09-14 04:02:37	570
1359	675	click	2025-03-25 03:46:52	545
1321	698	view	2025-06-28 22:09:36	3
1364	496	logout	2025-11-22 06:54:24	-1
1322	-1	view	2025-09-01 09:08:16	410
1370	512	view	2026-03-08 16:28:28	353
1323	498	view	2024-08-30 12:16:46	41
1371	148	click	2025-04-09 09:06:38	439
1331	29	view	2026-04-01 23:45:39	153
1372	635	logout	2024-11-21 19:51:28	466
1332	357	logout	2026-04-15 15:11:13	-1
1375	302	click	2025-06-13 15:35:20	119
1337	433	login	2026-04-12 08:34:35	261
1376	626	click	2025-01-14 15:04:27	596
1341	452	purchase	2026-02-24 17:17:10	193
1379	341	view	2026-04-04 19:38:28	596
1342	245	logout	2024-09-03 23:32:34	455
1383	-1	purchase	2025-11-10 21:39:50	72
1343	434	login	2024-11-17 04:25:17	-1
1387	31	click	2025-01-12 21:38:38	36
1347	306	login	2025-08-24 05:31:24	81
1391	651	purchase	2024-10-16 06:16:12	361
1349	217	purchase	2025-12-31 10:51:51	176
1397	340	login	2025-12-28 13:06:17	444
1353	149	logout	2025-11-28 08:28:09	120
1399	170	logout	2024-08-13 06:55:56	181
1355	381	view	2025-04-20 01:53:00	257
1400	347	click	2026-04-22 19:14:59	536
1357	611	click	2025-10-15 02:37:28	366
1402	629	logout	2024-06-26 18:17:47	-1
1360	9	view	2024-07-09 23:06:08	152
1403	539	click	2025-10-01 19:17:11	161
1361	673	purchase	2025-04-17 06:15:58	-1
1404	-1	purchase	2025-04-05 17:53:47	37
1362	508	click	\N	340
1406	691	logout	2026-02-12 03:35:58	472
1363	304	click	2025-12-17 15:40:57	530
1407	94	click	2024-12-19 16:02:58	164
1365	145	purchase	2024-09-21 04:14:51	262
1408	18	login	2025-08-16 19:55:27	536
1366	624	purchase	2025-07-02 20:52:53	396
1411	191	logout	2025-04-28 11:01:06	388
1367	6	logout	2025-01-22 00:01:39	467
1413	460	purchase	2025-12-23 09:17:06	82
1368	107	logout	2024-06-13 17:21:59	486
1414	8	logout	2025-08-25 04:18:31	228
1369	185	login	2026-04-03 02:09:36	188
1416	492	login	2025-05-21 06:34:40	133
1373	604	logout	2026-05-07 11:56:35	482
1417	464	view	2024-11-18 23:58:28	339
1374	339	purchase	2024-08-28 10:30:43	463
1418	219	purchase	2024-06-11 21:38:31	482
1377	-1	login	2024-12-27 10:32:12	4
1419	224	click	2025-04-28 02:00:58	226
1378	-1	logout	2026-05-21 20:36:54	465
1421	459	view	2024-09-08 18:22:56	168
1380	214	click	2025-05-15 03:31:08	28
1422	261	click	2025-12-04 07:54:09	346
1381	114	purchase	2025-05-01 13:37:02	541
1423	298	logout	2025-08-19 14:21:50	229
1382	294	login	2025-07-03 04:41:36	433
1424	593	login	2024-12-18 15:21:52	301
1384	369	login	2025-06-18 20:01:51	136
1425	107	login	2025-04-02 02:32:17	551
1385	-1	view	2024-12-18 21:38:18	477
1426	71	logout	2025-09-07 01:51:47	293
1386	29	purchase	2026-01-05 15:09:00	531
1427	410	login	2026-03-07 19:31:28	401
1388	135	login	2026-02-17 07:03:16	307
1431	639	click	2024-07-14 08:14:06	-1
1389	248	click	2025-01-22 00:54:11	181
1432	339	login	2024-09-09 08:30:11	449
1390	667	login	2025-09-24 10:58:11	424
1434	694	purchase	2025-04-11 20:01:08	-1
1392	429	view	2025-12-29 08:43:46	108
1435	694	click	2025-06-08 04:18:55	33
1393	134	click	2024-11-02 04:30:26	15
1437	61	view	2025-08-18 04:56:24	251
1394	504	click	2026-04-09 17:38:18	500
1440	254	logout	2024-12-28 15:06:15	329
1395	553	view	2024-10-05 13:26:55	427
1441	562	view	2026-03-17 16:09:51	18
1396	80	purchase	2026-01-24 07:32:35	523
1442	120	click	2024-11-07 00:37:46	287
1398	334	purchase	2025-10-09 16:58:03	30
1445	391	login	2025-06-23 02:37:17	377
1401	-1	login	2025-03-16 02:57:25	324
1451	527	purchase	2026-05-14 12:36:56	573
1405	337	click	2025-06-04 23:30:02	226
1452	230	click	2025-02-10 19:31:48	135
1409	447	click	2025-10-16 20:20:04	493
1453	679	click	2025-02-22 20:57:23	64
1410	559	login	2026-04-11 16:40:43	347
1464	240	view	2024-08-19 17:59:44	93
1412	30	click	\N	495
1465	181	view	2025-06-12 03:28:00	40
1415	273	purchase	2024-05-26 09:59:12	378
1466	371	click	2024-08-28 12:36:44	586
1420	652	click	2024-09-03 09:22:00	353
1469	158	login	\N	567
1428	352	view	2025-08-23 05:27:36	286
1471	-1	purchase	2025-05-22 23:39:04	376
1429	528	purchase	2024-10-12 06:50:20	442
1474	90	click	2024-08-09 00:14:26	132
1430	512	click	2025-10-16 20:33:50	183
1478	36	logout	2026-01-07 13:08:42	52
1433	-1	login	2025-07-25 00:28:23	245
1479	570	logout	2026-01-02 14:34:53	593
1436	500	logout	2025-09-25 02:55:56	212
1480	389	purchase	2025-07-27 16:37:34	162
1438	590	view	2025-09-01 15:39:38	517
1482	-1	click	2024-11-17 06:14:39	223
1439	511	login	2025-01-04 19:07:49	230
1484	97	click	2026-02-23 20:10:07	442
1443	203	login	\N	461
1485	642	view	2025-06-22 04:50:59	71
1444	503	login	2026-01-06 22:14:34	327
1486	496	click	2024-12-16 06:30:01	577
1446	474	logout	2024-10-26 23:40:56	303
1489	-1	click	2025-08-28 07:09:09	270
1447	362	purchase	2025-09-11 19:06:44	-1
1492	60	login	2024-08-07 01:29:46	158
1448	584	purchase	\N	351
1494	387	click	2025-06-05 08:56:10	27
1449	332	click	2026-04-04 07:02:15	397
1495	201	logout	2025-08-06 22:10:48	96
1450	138	view	2025-11-25 00:22:01	308
1496	668	view	2025-10-23 22:34:28	451
1454	465	logout	2024-11-18 01:25:04	513
1497	32	logout	2026-05-14 21:57:34	211
1455	168	view	2026-04-19 18:15:59	321
1498	62	login	\N	354
1456	99	logout	2026-01-05 17:15:43	190
1457	95	purchase	2026-01-08 01:14:23	303
1458	328	click	2026-04-07 07:33:18	139
1459	485	logout	2026-04-13 07:27:54	475
1460	-1	logout	2025-02-27 10:04:00	59
1461	194	purchase	2026-02-22 11:41:14	248
1462	177	view	2025-07-16 03:20:08	292
1463	-1	click	2024-05-25 22:59:41	447
1467	325	view	2025-01-25 17:47:50	290
1468	490	purchase	2026-02-23 16:51:04	243
1470	609	view	2025-01-19 08:05:25	310
1472	485	click	2025-09-11 08:18:13	-1
1473	443	login	2025-06-01 11:25:07	426
1475	119	click	\N	170
1476	635	click	2026-05-04 03:30:22	230
1477	41	logout	2025-08-04 19:21:36	574
1481	193	logout	2026-05-20 08:00:46	590
1483	197	logout	2024-08-11 18:35:07	212
1487	95	logout	2025-10-15 13:39:04	491
1488	-1	view	2026-03-20 16:33:44	211
1490	607	view	2025-10-16 05:03:08	79
1491	263	login	2026-01-14 16:08:42	354
1493	367	login	2024-06-02 13:58:00	78
1499	609	login	2025-06-18 21:07:32	407
1500	407	click	2024-12-19 22:47:33	141
\.


--
-- TOC entry 2539 (class 0 OID 49532)
-- Dependencies: 285
-- Data for Name: orders; Type: TABLE DATA; Schema: dds; Owner: gpadmin
--

COPY dds.orders (order_id, customer_id, product_id, quantity, unit_price, currency, order_timestamp, status) FROM stdin;
2	467	117	5	218.669999999999987	EUR	2026-02-18 02:28:23	completed
1	380	512	3	256.019999999999982	USD	\N	processing
3	470	391	5	89.7000000000000028	EUR	2025-01-14 11:22:12	cancelled
5	92	-1	4	60.7999999999999972	RUB	2025-01-22 15:48:14	processing
4	676	90	3	354.029999999999973	USD	2025-05-30 03:09:57	completed
11	175	198	2	282.310000000000002	EUR	2024-11-12 05:51:09	processing
6	103	217	1	337.180000000000007	EUR	2024-12-12 04:11:41	completed
12	660	400	5	220.259999999999991	RUB	2025-02-28 18:51:50	processing
7	466	476	4	475.769999999999982	EUR	2024-12-17 00:16:14	cancelled
14	122	331	3	420.300000000000011	USD	2025-05-23 12:48:47	completed
8	661	520	1	470.410000000000025	USD	2024-12-30 16:57:31	cancelled
15	96	557	5	84.9899999999999949	RUB	2024-11-07 14:01:18	completed
9	275	425	4	339.920000000000016	USD	2025-04-05 12:29:27	completed
17	192	388	3	104.980000000000004	USD	2024-07-27 04:07:00	cancelled
10	0	326	5	411.819999999999993	RUB	2026-01-21 03:56:04	cancelled
20	80	23	2	201.490000000000009	EUR	2024-07-20 09:27:33	cancelled
13	178	130	2	224.330000000000013	USD	2025-03-06 08:09:27	processing
23	622	-1	3	496.930000000000007	EUR	2025-02-10 03:12:51	processing
16	586	-1	2	491.870000000000005	RUB	2026-02-03 08:08:20	cancelled
25	0	118	2	115.989999999999995	EUR	2025-06-22 20:48:51	completed
18	676	594	2	317.439999999999998	RUB	2025-01-05 06:00:33	completed
26	31	205	2	141.120000000000005	EUR	2026-03-07 09:06:44	completed
19	114	185	1	79.5	EUR	2025-02-10 05:37:05	completed
30	457	393	3	315.230000000000018	RUB	2026-03-30 23:21:33	cancelled
21	76	322	2	346.79000000000002	EUR	2024-07-05 00:20:51	processing
31	205	524	1	230.210000000000008	USD	2025-09-21 11:42:37	cancelled
22	462	581	1	452.779999999999973	RUB	2025-08-02 14:16:29	processing
35	477	291	2	285.199999999999989	EUR	2025-11-19 05:40:49	processing
24	0	-1	3	464.029999999999973	USD	2025-04-27 12:35:46	completed
36	218	77	3	360.970000000000027	RUB	2025-10-26 17:58:59	processing
27	357	447	4	375.149999999999977	EUR	2025-11-04 11:16:05	processing
38	506	176	4	68.4399999999999977	EUR	2024-12-15 07:36:45	processing
28	410	288	2	346.660000000000025	RUB	2025-01-28 13:48:55	cancelled
40	473	541	4	28.129999999999999	RUB	2024-09-01 23:29:10	completed
29	106	500	3	91.1700000000000017	USD	2024-11-19 22:07:32	cancelled
44	0	447	1	77.980000000000004	EUR	2026-04-29 18:48:16	completed
32	601	118	5	182.599999999999994	USD	2025-11-07 21:59:15	completed
46	54	77	1	33.5200000000000031	EUR	2026-04-08 18:15:53	cancelled
33	331	381	2	45.5900000000000034	RUB	2024-08-01 00:19:44	cancelled
47	338	142	4	142.259999999999991	USD	2024-08-30 02:42:22	processing
34	149	337	3	347.259999999999991	RUB	2025-07-11 11:43:09	completed
48	472	458	2	378.990000000000009	EUR	2025-12-24 11:10:46	processing
37	662	202	3	408.560000000000002	USD	2025-01-25 13:47:44	completed
49	126	330	4	334.019999999999982	EUR	2024-09-21 07:12:23	processing
39	335	590	1	149.669999999999987	RUB	2024-09-01 13:44:00	completed
50	495	572	3	358.579999999999984	EUR	2025-11-02 18:49:24	completed
41	346	309	1	416.629999999999995	EUR	2025-11-14 02:44:17	cancelled
52	14	349	4	102.079999999999998	USD	2025-07-15 18:11:31	completed
42	325	-1	5	389.560000000000002	EUR	2025-11-02 16:21:05	completed
56	315	113	1	82.1700000000000017	USD	2025-01-28 16:51:18	completed
43	403	383	4	425.850000000000023	USD	2026-01-27 19:22:46	processing
57	17	464	1	243.360000000000014	RUB	2024-10-02 18:33:27	cancelled
45	175	6	3	409.910000000000025	RUB	2024-09-09 14:32:53	processing
61	532	118	2	479.899999999999977	USD	2026-04-27 22:44:37	completed
51	676	62	1	46.8200000000000003	EUR	2024-09-29 03:00:53	completed
63	-1	275	2	369.620000000000005	RUB	2024-11-28 15:28:57	cancelled
53	605	465	3	382.639999999999986	EUR	2025-04-25 16:11:52	processing
64	211	4	3	355.870000000000005	EUR	2024-12-31 08:07:38	completed
54	158	395	2	117.200000000000003	EUR	2026-04-11 01:15:11	cancelled
68	361	113	4	437.879999999999995	EUR	2025-06-15 23:27:33	completed
55	636	169	2	43.6300000000000026	EUR	2024-11-08 17:22:54	processing
69	18	151	2	267.379999999999995	USD	2025-06-06 19:02:27	completed
58	272	407	3	221.419999999999987	USD	2025-11-30 09:39:46	processing
71	680	342	1	415.600000000000023	EUR	2024-08-20 05:14:31	processing
59	442	392	3	191.189999999999998	USD	2025-02-09 21:17:00	processing
72	680	532	5	247.330000000000013	EUR	2026-03-04 21:26:41	processing
60	433	-1	2	301.079999999999984	RUB	2026-01-12 10:41:02	cancelled
74	32	92	4	186.120000000000005	RUB	2025-10-24 05:32:16	completed
62	37	-1	5	59.509999999999998	USD	2024-09-21 05:17:57	processing
76	272	283	3	201.599999999999994	EUR	2026-01-28 20:44:12	cancelled
65	190	245	4	372.149999999999977	RUB	2024-08-24 01:41:20	completed
78	581	511	3	63.990000000000002	USD	2025-01-04 03:46:58	processing
66	323	14	3	450.939999999999998	USD	2026-03-17 03:15:31	processing
79	151	167	3	315.660000000000025	RUB	2025-12-08 18:52:48	cancelled
67	486	10	3	441.819999999999993	USD	\N	processing
83	-1	298	2	221.699999999999989	USD	2025-09-09 04:43:12	completed
70	103	559	4	250.419999999999987	EUR	2025-12-07 23:44:17	cancelled
85	612	205	3	404.149999999999977	USD	2024-10-04 16:12:21	cancelled
73	0	366	2	333.089999999999975	USD	2024-11-17 05:26:37	cancelled
86	139	-1	3	51.9399999999999977	RUB	2026-03-15 17:33:11	cancelled
75	387	540	5	450.620000000000005	EUR	2024-09-15 17:59:26	completed
87	559	453	4	57.0600000000000023	RUB	2025-10-29 03:10:32	processing
77	0	444	3	418.740000000000009	USD	2024-06-07 11:41:29	cancelled
88	321	478	3	239.509999999999991	EUR	2025-05-28 19:49:27	cancelled
80	499	290	1	232.389999999999986	USD	2025-10-27 08:09:46	processing
89	421	91	1	479.170000000000016	EUR	2025-08-05 17:45:16	completed
81	127	52	4	182.610000000000014	USD	2024-12-13 14:28:40	cancelled
91	580	7	4	71.7099999999999937	RUB	2025-08-09 04:22:15	cancelled
82	142	159	5	336.009999999999991	RUB	2025-12-06 12:39:00	completed
95	508	7	2	157.439999999999998	EUR	2025-06-02 12:59:28	cancelled
84	33	268	4	217.060000000000002	USD	2024-05-30 23:47:50	cancelled
96	639	533	1	84.980000000000004	USD	2026-02-01 18:16:17	completed
90	630	-1	5	260.980000000000018	USD	2026-01-09 02:30:08	processing
98	415	267	2	422.439999999999998	RUB	2025-07-23 19:28:34	processing
92	531	110	1	142.389999999999986	RUB	2025-06-19 13:11:29	cancelled
105	10	538	5	113.280000000000001	RUB	2025-07-09 08:11:57	cancelled
93	609	125	4	348.389999999999986	USD	2025-03-03 22:04:35	processing
106	526	348	3	331.410000000000025	RUB	2025-02-04 08:04:09	cancelled
94	599	148	1	353.769999999999982	RUB	2025-01-14 04:32:14	processing
107	-1	496	3	462.5	USD	2025-03-24 02:52:08	cancelled
97	254	125	5	227.469999999999999	USD	2025-05-22 08:39:11	cancelled
111	238	394	2	61.6599999999999966	USD	2024-08-12 13:11:37	cancelled
99	698	23	1	221.849999999999994	RUB	2024-11-29 18:47:11	completed
114	137	449	2	105.900000000000006	EUR	2025-03-31 04:56:45	processing
100	146	560	2	260.639999999999986	RUB	2025-05-09 09:51:28	completed
116	25	6	2	26.2899999999999991	USD	2026-01-13 21:40:34	cancelled
101	488	377	1	479.949999999999989	EUR	2024-12-06 16:09:32	processing
119	142	81	4	438.25	RUB	2024-11-12 23:50:58	completed
102	282	152	1	237.340000000000003	EUR	2026-02-25 00:07:38	completed
121	230	70	3	201.310000000000002	EUR	2026-04-27 05:16:40	completed
103	291	-1	1	294.45999999999998	USD	2025-03-13 00:28:18	cancelled
122	295	320	5	466.589999999999975	RUB	2025-03-21 17:24:27	cancelled
104	44	470	2	239.27000000000001	RUB	2024-07-24 16:52:25	cancelled
123	634	31	1	295.560000000000002	EUR	2026-01-15 10:07:41	completed
108	484	266	5	389.949999999999989	RUB	2026-05-10 13:46:51	completed
124	347	338	1	78.25	RUB	2025-05-22 13:19:40	processing
109	-1	70	3	296.399999999999977	EUR	2026-01-22 01:29:38	completed
125	64	37	5	453.120000000000005	RUB	2024-06-30 04:32:38	cancelled
110	31	488	1	335.980000000000018	EUR	2025-02-20 16:59:27	cancelled
128	490	27	2	20.5100000000000016	USD	2025-02-16 17:19:12	completed
112	66	453	1	424.930000000000007	USD	2025-05-26 09:03:41	cancelled
132	233	256	5	288.339999999999975	USD	2024-12-07 21:59:01	completed
113	622	461	2	167.370000000000005	RUB	\N	cancelled
134	251	79	4	244.560000000000002	USD	2024-07-24 18:10:54	completed
115	293	89	4	408.779999999999973	USD	2025-11-10 13:13:15	processing
135	257	455	3	449.839999999999975	USD	2025-11-15 21:10:09	processing
117	418	541	3	100.799999999999997	RUB	2026-04-20 23:35:56	cancelled
136	310	540	3	435.800000000000011	USD	2024-12-16 14:03:33	cancelled
118	195	-1	4	255.419999999999987	EUR	2025-01-29 11:54:39	processing
137	327	-1	1	179.849999999999994	EUR	2025-11-14 17:50:07	cancelled
120	530	339	2	35.2199999999999989	RUB	2024-11-10 02:17:03	completed
138	287	567	5	122.959999999999994	RUB	2024-07-27 02:02:58	completed
126	73	491	5	465.389999999999986	RUB	2026-01-05 16:08:09	completed
144	222	59	5	222.699999999999989	EUR	2026-04-27 02:30:56	completed
127	278	359	4	258.730000000000018	RUB	2025-06-11 06:46:36	cancelled
148	346	257	3	187.22999999999999	RUB	2026-04-16 09:29:43	processing
129	548	397	1	280.720000000000027	USD	2024-10-10 05:33:46	cancelled
149	0	455	3	419.639999999999986	USD	2025-12-23 08:43:40	cancelled
130	-1	121	5	77.5100000000000051	EUR	2024-07-28 03:23:12	processing
150	18	224	3	245.300000000000011	RUB	2025-10-25 02:44:55	cancelled
131	377	-1	1	126.700000000000003	USD	2025-03-15 15:56:30	completed
152	265	179	4	72.3400000000000034	RUB	2025-01-02 21:37:59	completed
133	79	-1	3	31.4200000000000017	EUR	2024-06-30 02:15:14	processing
154	0	264	1	476.329999999999984	EUR	2025-10-07 08:23:37	completed
139	126	451	2	27.5799999999999983	USD	2025-03-12 13:19:35	processing
155	695	241	5	361.980000000000018	RUB	2024-06-26 06:58:28	cancelled
140	465	394	1	142.449999999999989	RUB	\N	cancelled
157	381	147	1	324.519999999999982	EUR	2025-11-30 22:33:38	completed
141	87	394	4	252.72999999999999	EUR	2024-11-22 10:03:57	cancelled
158	335	482	4	449.720000000000027	EUR	2026-02-01 06:35:02	cancelled
142	46	313	4	270.920000000000016	RUB	2024-06-21 18:11:12	completed
159	0	27	3	465.850000000000023	RUB	2024-09-12 20:13:58	completed
143	555	269	5	379.689999999999998	EUR	2026-01-20 17:47:18	processing
160	624	353	5	393.899999999999977	RUB	2025-04-18 02:42:29	completed
145	567	475	3	430.670000000000016	RUB	2026-02-01 16:38:24	cancelled
161	388	81	2	196.72999999999999	RUB	2025-06-10 05:09:07	completed
146	587	479	3	89.6500000000000057	EUR	2025-07-30 06:35:05	processing
162	230	125	5	369.639999999999986	RUB	2026-01-13 00:37:05	processing
147	244	556	3	51.9099999999999966	USD	\N	cancelled
166	79	236	5	122.870000000000005	EUR	2026-01-27 07:15:51	processing
151	60	452	5	280.20999999999998	USD	2025-12-12 07:34:25	completed
167	129	142	4	340.310000000000002	RUB	2025-08-10 23:00:21	processing
153	633	451	1	100.290000000000006	RUB	2024-08-31 00:40:39	processing
168	267	518	1	49.9399999999999977	EUR	2024-10-05 21:09:23	completed
156	112	334	5	47.9500000000000028	USD	2026-03-04 14:51:16	processing
169	590	16	2	450.939999999999998	EUR	2025-12-16 11:43:48	completed
163	53	200	5	226.099999999999994	EUR	2024-07-14 11:16:09	processing
170	124	35	4	374	USD	2024-07-04 00:43:16	cancelled
164	301	119	3	123.140000000000001	EUR	2024-11-20 00:21:21	processing
171	25	398	2	262.300000000000011	RUB	2025-10-14 16:25:35	cancelled
165	247	574	4	187.319999999999993	EUR	2024-11-15 19:59:58	processing
172	363	345	2	358.870000000000005	USD	2025-05-05 21:19:11	cancelled
176	379	-1	3	224.909999999999997	RUB	2024-09-30 18:11:24	cancelled
173	606	460	1	46.1400000000000006	EUR	2025-08-07 19:03:56	cancelled
177	100	594	1	286.420000000000016	RUB	2025-10-30 11:46:58	processing
174	646	138	3	381.25	RUB	2025-04-13 13:02:20	processing
180	295	-1	2	151.349999999999994	EUR	2025-09-29 23:52:34	completed
175	188	-1	5	51.0600000000000023	USD	2026-01-30 17:19:42	processing
182	613	7	5	273.579999999999984	USD	2025-04-08 09:35:44	cancelled
178	437	216	2	477.220000000000027	USD	2026-03-12 13:45:39	cancelled
183	27	534	5	218.990000000000009	EUR	2026-01-15 23:42:13	completed
179	532	170	3	58.740000000000002	EUR	2025-10-25 11:42:13	completed
185	89	228	1	484.54000000000002	USD	2025-11-29 12:19:55	processing
181	238	173	2	280.560000000000002	RUB	2025-09-18 07:05:05	completed
187	76	534	1	222.360000000000014	RUB	2024-09-23 19:47:51	cancelled
184	465	506	1	227.759999999999991	EUR	2025-08-02 15:32:50	cancelled
190	497	91	3	74.5799999999999983	RUB	2024-08-15 06:28:06	processing
186	77	526	3	232.199999999999989	RUB	2025-07-02 04:27:43	processing
192	0	241	5	196.340000000000003	RUB	2026-02-22 20:57:33	processing
188	195	9	1	475.100000000000023	RUB	2025-01-13 06:57:11	completed
193	358	300	2	440.170000000000016	USD	2025-10-22 22:54:11	processing
189	141	482	2	339.939999999999998	EUR	2025-05-22 19:12:56	completed
195	225	334	3	215.599999999999994	EUR	2025-01-18 13:40:18	completed
191	-1	214	1	250.439999999999998	RUB	\N	processing
197	132	241	4	304.519999999999982	RUB	2026-03-15 09:35:27	completed
194	497	303	5	184.990000000000009	EUR	2025-10-12 22:32:36	completed
198	298	268	4	39.7899999999999991	EUR	2025-06-17 01:44:38	processing
196	679	408	3	333.699999999999989	EUR	2024-11-10 12:08:51	processing
203	567	161	2	187.430000000000007	USD	2024-08-17 22:28:14	processing
199	326	275	4	205.349999999999994	USD	2025-12-12 08:17:10	cancelled
205	567	105	1	424.29000000000002	RUB	2024-06-21 23:12:00	processing
200	-1	227	1	161.169999999999987	EUR	2025-08-25 21:36:30	processing
207	0	277	4	331.089999999999975	USD	2026-04-16 19:33:10	completed
201	171	-1	1	474.45999999999998	RUB	2024-07-06 21:06:12	cancelled
209	156	320	4	105.200000000000003	RUB	2025-09-26 22:48:33	cancelled
202	133	342	1	403.180000000000007	USD	\N	cancelled
211	591	575	1	118.900000000000006	EUR	2026-03-20 06:39:06	cancelled
204	406	424	2	456.220000000000027	EUR	2024-07-06 17:20:27	completed
215	86	145	4	300.769999999999982	USD	2025-02-03 05:15:18	cancelled
206	408	-1	3	157.719999999999999	USD	2026-04-01 21:38:04	processing
218	417	559	2	379.970000000000027	EUR	2025-03-24 01:55:25	cancelled
208	79	555	4	19.879999999999999	RUB	2024-07-14 18:46:24	processing
219	321	569	4	357.350000000000023	RUB	2024-08-26 01:23:56	processing
210	436	271	3	234.860000000000014	USD	\N	processing
223	446	381	3	266.019999999999982	RUB	2026-04-17 17:35:09	processing
212	495	509	5	129.860000000000014	USD	2025-07-04 22:22:06	processing
224	666	381	2	403.379999999999995	RUB	2024-09-03 01:46:21	processing
213	404	26	1	231.610000000000014	RUB	2024-10-23 14:42:10	cancelled
225	620	139	3	464.269999999999982	RUB	2025-07-06 22:40:26	completed
214	238	148	1	324.980000000000018	EUR	2024-11-07 03:04:13	processing
229	15	377	4	296.389999999999986	EUR	2024-12-05 00:47:34	processing
216	632	506	5	382.680000000000007	USD	2024-08-29 12:33:18	cancelled
230	413	106	2	47.9600000000000009	USD	2024-06-14 23:45:54	processing
217	422	579	2	27.8900000000000006	RUB	2024-06-07 12:17:40	processing
233	485	-1	2	494.649999999999977	USD	\N	completed
220	84	166	1	194.090000000000003	USD	2024-06-03 07:51:48	processing
236	403	325	4	183.949999999999989	RUB	2025-01-25 19:01:01	processing
221	125	508	1	29.1400000000000006	EUR	2025-02-27 04:51:18	completed
237	81	147	2	473.29000000000002	EUR	2024-09-18 04:11:01	cancelled
222	642	304	5	214.889999999999986	USD	2025-09-15 14:00:09	completed
239	357	435	4	387.660000000000025	EUR	2026-03-19 16:06:36	completed
226	537	482	3	213.990000000000009	USD	2025-08-26 20:29:02	completed
241	453	378	5	162.090000000000003	USD	2024-10-09 20:20:05	cancelled
227	6	97	1	273.490000000000009	EUR	2024-08-08 20:07:49	completed
244	483	559	4	95.1500000000000057	RUB	2026-04-27 22:34:06	completed
228	640	354	3	321.810000000000002	USD	2026-04-06 22:52:01	processing
246	430	322	4	322.360000000000014	USD	2025-07-16 07:42:17	completed
231	222	-1	1	72.0900000000000034	RUB	2025-02-13 09:44:40	processing
247	558	325	5	371.350000000000023	EUR	2025-05-18 00:17:52	processing
232	393	-1	5	306.339999999999975	RUB	2025-07-05 21:17:33	processing
251	281	89	4	288.399999999999977	RUB	2024-11-03 05:18:11	processing
234	147	141	3	48.1199999999999974	USD	2025-05-17 09:16:54	processing
252	475	326	2	367.480000000000018	USD	2025-08-15 11:36:09	processing
235	451	247	3	255.180000000000007	USD	2024-11-05 06:23:21	processing
256	193	271	3	137.080000000000013	EUR	2024-12-28 05:27:39	completed
238	574	446	3	345.829999999999984	RUB	2025-06-21 14:31:01	processing
257	502	175	5	230.340000000000003	RUB	2025-01-13 09:24:38	completed
240	632	11	2	197.400000000000006	USD	2025-06-08 09:46:59	completed
258	600	356	2	496.939999999999998	EUR	2025-03-18 04:08:39	processing
242	515	491	1	327.139999999999986	RUB	2024-12-03 04:37:05	cancelled
260	526	530	4	137.810000000000002	USD	2025-12-09 18:12:37	processing
243	45	32	3	316.379999999999995	RUB	2025-01-22 21:58:28	processing
261	647	387	5	168.27000000000001	RUB	2024-08-22 14:33:17	processing
245	40	135	2	355.759999999999991	USD	2026-05-07 07:48:25	completed
262	603	163	1	318.439999999999998	USD	2024-07-28 06:00:50	cancelled
248	174	413	3	263.009999999999991	RUB	2025-01-25 03:55:58	cancelled
263	487	314	1	101.680000000000007	EUR	2025-04-23 14:36:41	completed
249	684	86	5	82.2800000000000011	EUR	2024-07-27 21:24:42	completed
266	495	111	2	383.949999999999989	RUB	2025-11-08 18:40:38	cancelled
250	0	4	5	210.530000000000001	RUB	2024-05-26 13:31:05	cancelled
267	437	525	4	300.610000000000014	USD	2024-06-09 12:27:40	completed
253	642	472	1	116.590000000000003	EUR	2024-09-08 17:33:57	completed
270	406	309	2	108.200000000000003	USD	\N	cancelled
254	-1	136	2	376.230000000000018	RUB	2025-01-26 10:56:07	cancelled
272	569	483	4	88.0699999999999932	USD	2025-03-16 22:07:47	processing
255	55	424	3	78.8100000000000023	EUR	2025-03-29 22:25:02	completed
274	397	290	2	205.939999999999998	EUR	2024-10-12 11:40:32	processing
259	699	276	5	280.29000000000002	RUB	2024-07-22 05:57:58	completed
275	-1	-1	5	45.1099999999999994	EUR	2026-05-02 22:23:00	completed
264	479	-1	4	406.519999999999982	EUR	2025-12-22 02:57:46	processing
279	292	184	4	27.0700000000000003	EUR	2025-10-17 03:31:24	completed
265	-1	-1	2	133.759999999999991	EUR	2024-06-15 11:33:33	cancelled
282	0	311	4	217	USD	2025-12-30 22:03:00	cancelled
268	308	143	5	107.25	RUB	2024-08-24 11:29:22	completed
285	8	-1	5	136.340000000000003	RUB	2024-08-07 04:58:00	processing
269	680	355	1	161.539999999999992	USD	2026-04-01 17:16:03	cancelled
286	466	472	1	69.5600000000000023	EUR	2026-04-19 03:51:00	cancelled
271	83	158	4	54.1799999999999997	USD	2025-06-20 14:34:44	processing
287	52	304	3	218.590000000000003	RUB	2025-11-27 14:56:49	completed
273	-1	249	4	337.529999999999973	EUR	2025-06-01 05:00:46	completed
288	556	305	4	18.5799999999999983	EUR	2025-09-14 03:02:19	processing
276	228	514	2	190.870000000000005	EUR	2026-03-19 00:01:23	completed
290	87	282	2	320.129999999999995	EUR	2025-06-21 03:29:25	cancelled
277	626	512	1	326.329999999999984	USD	2024-09-10 11:55:03	completed
291	470	79	5	288.839999999999975	USD	2025-03-14 05:28:31	cancelled
278	46	436	3	198.189999999999998	USD	2025-09-10 18:39:35	completed
294	669	585	4	482.930000000000007	USD	2024-11-09 04:34:29	cancelled
280	408	104	4	405.050000000000011	EUR	2026-01-28 09:06:56	processing
295	311	384	2	350.189999999999998	USD	2025-08-12 21:05:17	processing
281	415	394	3	73.0799999999999983	RUB	\N	processing
296	485	284	3	375.970000000000027	USD	2026-01-24 12:05:25	processing
283	265	344	4	256.009999999999991	EUR	2025-04-23 22:03:33	processing
298	0	-1	2	144.639999999999986	EUR	2024-08-20 10:16:22	processing
284	374	82	4	270.54000000000002	EUR	2024-12-23 22:02:08	completed
299	326	295	3	118.319999999999993	RUB	2026-03-29 17:26:48	processing
289	37	255	1	270.319999999999993	EUR	2024-11-17 12:17:24	completed
301	488	156	3	166.620000000000005	EUR	\N	cancelled
292	0	81	1	197.139999999999986	RUB	2026-01-27 07:05:31	cancelled
304	299	599	4	24.4899999999999984	RUB	2025-04-05 19:43:06	completed
293	653	264	1	100.129999999999995	RUB	2025-07-12 13:09:13	processing
308	419	-1	5	146.650000000000006	EUR	2025-06-26 06:26:09	completed
297	0	6	2	342.319999999999993	EUR	2025-11-17 22:02:44	cancelled
309	681	402	3	256.129999999999995	RUB	2024-09-30 11:56:24	completed
300	-1	555	4	321.04000000000002	EUR	2025-10-05 13:34:13	cancelled
310	414	410	4	86.9099999999999966	USD	2024-11-23 04:42:05	cancelled
302	511	586	4	135.289999999999992	USD	2025-12-12 16:55:50	completed
311	4	101	4	331.529999999999973	RUB	2024-07-10 01:16:50	cancelled
303	647	379	1	111.700000000000003	RUB	2025-08-13 15:08:24	cancelled
312	595	-1	4	102.549999999999997	USD	2024-09-06 02:44:52	completed
305	640	570	1	378.180000000000007	EUR	2026-01-14 07:40:00	processing
315	616	166	5	260.550000000000011	USD	2024-11-21 09:02:00	cancelled
306	503	127	5	74.5300000000000011	RUB	2026-02-01 07:58:13	completed
319	251	417	1	376.819999999999993	RUB	2024-11-10 08:53:48	processing
307	406	411	5	151.780000000000001	USD	2025-02-07 09:01:17	processing
320	482	551	4	479.20999999999998	RUB	2024-09-21 11:13:16	completed
313	142	419	1	303.79000000000002	RUB	2024-11-17 21:29:55	completed
322	62	524	1	188.050000000000011	RUB	2026-04-26 06:28:07	processing
314	333	24	4	345.339999999999975	EUR	2025-01-30 02:53:28	processing
325	271	504	1	234.539999999999992	RUB	2024-07-08 11:34:56	completed
316	378	331	4	469.199999999999989	USD	2025-12-05 04:59:49	completed
326	267	265	3	395.810000000000002	RUB	2025-05-15 02:31:04	processing
317	301	-1	5	235.97999999999999	USD	2025-09-29 19:46:51	cancelled
329	451	394	2	81.7999999999999972	EUR	2024-12-31 05:39:33	cancelled
318	248	340	5	324.279999999999973	RUB	2024-10-31 15:03:24	completed
331	373	175	5	208.860000000000014	RUB	2026-04-21 10:54:11	cancelled
321	-1	493	5	360.230000000000018	EUR	2025-08-12 12:11:26	processing
333	174	67	4	449.600000000000023	USD	2026-01-29 06:18:42	cancelled
323	666	594	1	81.5300000000000011	EUR	2024-11-14 05:56:07	completed
334	231	123	3	308.230000000000018	RUB	2024-11-05 07:28:43	processing
324	-1	495	3	79.5600000000000023	USD	2025-12-23 17:39:44	completed
335	202	234	1	421.589999999999975	RUB	2024-05-31 07:57:22	processing
327	282	227	2	265.670000000000016	USD	2025-11-27 20:08:34	cancelled
338	536	251	2	347.949999999999989	RUB	2024-09-05 02:38:27	completed
328	578	487	2	288.139999999999986	EUR	2025-11-12 11:10:17	processing
341	250	327	4	58.1499999999999986	USD	2025-03-19 17:25:34	processing
330	653	13	5	158.449999999999989	RUB	2025-04-30 20:13:55	cancelled
344	200	417	4	496.199999999999989	EUR	2025-05-02 03:15:54	processing
332	660	497	3	266.439999999999998	EUR	2025-01-16 16:34:01	processing
345	278	307	5	246.810000000000002	EUR	2025-05-18 07:28:32	cancelled
336	208	69	1	476.490000000000009	RUB	2026-04-23 13:41:35	cancelled
346	545	451	5	256.5	RUB	2025-09-11 12:25:21	completed
337	567	458	5	437.579999999999984	USD	2024-11-29 00:25:54	processing
348	443	552	4	177.789999999999992	RUB	2025-11-29 11:19:54	completed
339	-1	94	5	140.219999999999999	EUR	2026-02-08 16:59:47	processing
350	484	159	5	113.040000000000006	RUB	2024-11-08 04:03:27	cancelled
340	195	213	2	266.050000000000011	USD	2025-05-06 08:39:08	completed
352	529	235	4	392.079999999999984	EUR	2025-12-08 03:35:40	cancelled
342	75	556	1	243.259999999999991	USD	2025-09-02 05:19:35	processing
354	323	414	4	383.720000000000027	USD	2024-12-30 14:58:30	completed
343	221	454	1	295.04000000000002	USD	2025-07-15 22:13:46	processing
355	419	208	4	385.850000000000023	USD	2025-04-23 00:58:45	completed
347	187	184	5	240.550000000000011	USD	2026-03-04 07:26:16	completed
356	678	392	3	21.6000000000000014	EUR	2024-07-11 21:38:37	cancelled
349	199	328	2	160.530000000000001	EUR	2026-02-09 01:20:56	processing
358	77	482	4	471.329999999999984	RUB	2025-03-11 00:29:53	completed
351	161	161	2	427.660000000000025	RUB	2025-08-01 02:43:00	cancelled
360	61	292	3	273.569999999999993	EUR	2025-03-16 11:17:52	completed
353	484	363	3	81.0400000000000063	EUR	2025-05-06 19:17:35	processing
361	484	424	3	488.819999999999993	RUB	2025-12-22 17:22:10	completed
357	572	281	2	312.600000000000023	EUR	2024-10-23 05:27:16	completed
362	155	336	5	53.1199999999999974	USD	2024-09-21 10:18:22	processing
359	676	-1	4	132.419999999999987	RUB	2026-03-03 10:39:42	cancelled
363	560	23	5	410.480000000000018	RUB	2025-11-18 15:27:17	completed
365	220	266	4	187.47999999999999	USD	2024-09-25 08:03:08	cancelled
364	70	457	3	479.029999999999973	EUR	2025-06-07 03:08:54	processing
368	517	342	5	251.080000000000013	RUB	2025-09-30 10:29:37	processing
366	619	406	1	324.699999999999989	EUR	\N	cancelled
372	590	589	4	445.800000000000011	EUR	2024-08-25 16:12:46	cancelled
367	50	448	5	193	RUB	2025-12-18 18:39:04	completed
375	364	212	5	84.7800000000000011	USD	2026-03-07 18:00:56	cancelled
369	69	163	5	392.490000000000009	RUB	2025-05-23 00:36:59	processing
376	186	357	1	391.939999999999998	RUB	2024-07-18 15:44:12	completed
370	90	442	2	378.430000000000007	RUB	2026-03-26 19:54:32	cancelled
377	336	435	2	108.829999999999998	USD	2024-12-28 14:26:55	cancelled
371	477	187	2	328.720000000000027	USD	2024-05-25 09:49:13	processing
378	239	127	3	23.379999999999999	EUR	2025-11-12 06:14:38	cancelled
373	7	155	1	120.359999999999999	EUR	2025-09-28 09:39:54	cancelled
380	204	519	1	55.5	USD	2025-07-23 02:03:28	processing
374	229	206	5	234.300000000000011	RUB	2024-10-26 14:15:25	processing
382	325	490	1	401.899999999999977	EUR	2025-09-12 06:13:43	cancelled
379	27	450	2	196.400000000000006	EUR	2025-03-26 05:14:05	cancelled
384	364	308	1	222.72999999999999	RUB	2025-06-24 20:15:33	completed
381	-1	-1	2	68.980000000000004	EUR	2025-08-19 11:17:48	cancelled
385	-1	282	4	439.20999999999998	USD	2024-12-20 09:45:09	processing
383	521	410	1	196.210000000000008	EUR	2024-12-31 03:18:39	completed
386	663	132	2	96.9099999999999966	USD	2025-04-16 02:31:48	processing
389	685	510	1	395.410000000000025	USD	2024-06-20 23:42:54	completed
387	160	301	1	39.9799999999999969	USD	2025-01-16 21:36:42	cancelled
390	314	27	3	314.740000000000009	USD	2025-07-29 18:43:19	cancelled
388	633	156	2	95.5699999999999932	RUB	2026-03-31 23:44:25	processing
391	30	553	2	457.649999999999977	USD	2025-06-12 10:42:51	cancelled
392	613	95	1	17.3200000000000003	USD	2024-07-01 16:35:23	cancelled
393	68	451	4	429.509999999999991	RUB	2025-03-05 20:27:13	completed
396	129	98	2	120.519999999999996	USD	2025-04-24 20:58:29	processing
394	618	132	4	240.050000000000011	EUR	\N	cancelled
398	-1	135	5	263.279999999999973	EUR	2025-09-28 06:39:23	cancelled
395	673	585	1	244.120000000000005	RUB	2025-06-28 14:30:24	completed
399	433	-1	1	376.490000000000009	EUR	2026-04-23 10:43:59	completed
397	414	309	2	120.849999999999994	USD	2024-12-29 01:57:27	cancelled
400	203	166	1	419.339999999999975	USD	\N	cancelled
403	346	563	3	405.420000000000016	EUR	2026-01-10 23:31:38	cancelled
401	0	416	3	102	RUB	2025-06-11 00:17:34	cancelled
404	680	437	5	138.800000000000011	EUR	2025-04-25 12:30:28	processing
402	220	527	4	67.730000000000004	EUR	2025-03-25 06:00:52	cancelled
406	-1	85	3	231.759999999999991	RUB	2024-11-13 04:33:32	processing
405	27	124	2	487.79000000000002	USD	2025-10-25 02:47:47	processing
410	163	156	5	120.870000000000005	RUB	2025-07-14 09:44:10	processing
407	187	228	5	105.489999999999995	RUB	2025-07-25 17:57:57	completed
412	535	308	4	167.740000000000009	RUB	2024-09-02 10:06:07	completed
408	204	544	5	392.170000000000016	RUB	2025-09-22 06:41:23	processing
414	69	249	2	245.659999999999997	USD	2025-02-20 12:21:36	cancelled
409	49	171	2	349.910000000000025	RUB	2025-08-28 16:00:37	cancelled
415	164	73	2	131.800000000000011	EUR	2025-04-12 06:09:13	completed
411	625	304	1	479.939999999999998	EUR	2025-02-17 13:01:00	cancelled
416	283	211	5	472.730000000000018	USD	2025-02-02 03:41:55	cancelled
413	77	-1	3	112.290000000000006	RUB	2025-09-27 20:11:37	processing
418	106	128	2	333.610000000000014	EUR	2025-04-05 16:26:16	processing
417	146	319	1	322.009999999999991	RUB	2025-03-17 06:20:48	processing
421	231	248	5	480.269999999999982	EUR	2025-12-08 13:07:27	processing
419	625	391	3	438.870000000000005	USD	2025-01-30 01:54:30	cancelled
422	507	287	4	37.759999999999998	USD	2024-12-03 23:15:59	processing
420	116	499	2	439.360000000000014	RUB	2024-11-29 04:07:33	cancelled
424	14	-1	2	297.029999999999973	USD	2026-05-17 14:53:41	cancelled
423	283	366	3	215.629999999999995	EUR	2025-02-14 11:05:55	completed
425	682	385	4	284.730000000000018	RUB	2025-06-27 07:09:19	processing
427	98	-1	3	294.259999999999991	RUB	2025-07-21 07:00:28	cancelled
426	532	101	1	304.810000000000002	RUB	2025-07-10 14:42:15	processing
430	0	30	1	153.219999999999999	EUR	2024-10-30 04:04:52	processing
428	404	536	4	427.589999999999975	RUB	2026-01-23 03:25:00	completed
431	468	284	3	182.669999999999987	USD	2025-05-29 10:18:19	cancelled
429	409	222	4	337.839999999999975	USD	2024-05-30 01:37:34	processing
432	49	215	3	386.620000000000005	USD	2026-05-12 03:05:24	processing
435	93	208	4	323.339999999999975	EUR	2024-06-25 08:33:10	cancelled
433	561	512	3	392.670000000000016	USD	2024-08-20 19:43:46	completed
436	-1	173	4	448.930000000000007	USD	2024-12-27 06:16:13	cancelled
434	342	104	2	165.099999999999994	EUR	2024-09-01 07:17:34	processing
437	17	304	5	353.110000000000014	RUB	2025-04-11 08:00:59	processing
440	107	332	3	310.579999999999984	USD	2025-04-17 19:27:01	completed
438	552	-1	1	107.319999999999993	USD	2026-04-28 05:36:27	processing
441	454	27	2	337.089999999999975	EUR	2026-01-26 02:15:26	cancelled
439	415	137	3	271.089999999999975	EUR	2025-06-16 15:02:20	cancelled
442	230	222	2	438.819999999999993	EUR	2026-02-09 15:59:48	completed
444	565	410	2	425.470000000000027	RUB	2025-05-30 11:56:15	processing
443	13	425	5	246.800000000000011	EUR	2025-07-02 16:02:46	processing
446	380	79	2	166.879999999999995	EUR	2024-07-09 02:29:35	processing
445	590	270	3	356.310000000000002	EUR	2026-02-18 11:03:07	cancelled
447	138	132	2	399.819999999999993	RUB	2024-06-04 16:01:21	completed
448	520	234	1	405.550000000000011	RUB	2025-04-19 03:20:11	processing
449	357	477	5	412.329999999999984	USD	2024-07-31 06:08:40	cancelled
450	589	67	4	253.599999999999994	EUR	2024-05-31 21:00:43	completed
452	699	29	3	289.180000000000007	RUB	2025-05-02 08:31:05	processing
451	23	152	1	448.95999999999998	EUR	2026-01-11 00:54:53	completed
455	553	367	1	485.740000000000009	USD	2024-08-17 19:56:18	processing
453	613	463	2	493.240000000000009	USD	2025-07-21 07:05:18	cancelled
456	123	166	1	269.589999999999975	RUB	2024-06-27 20:13:18	processing
454	552	417	2	289.230000000000018	RUB	2025-01-08 13:28:26	completed
457	200	507	2	419.509999999999991	USD	2025-02-06 09:12:15	processing
463	2	29	1	170.159999999999997	EUR	2025-09-28 23:52:28	processing
458	123	397	4	291.259999999999991	RUB	2025-01-16 12:26:40	cancelled
467	40	299	1	405.529999999999973	EUR	2025-06-28 07:08:38	completed
459	391	364	3	99.6599999999999966	EUR	2024-07-22 14:02:49	completed
468	358	198	2	451.110000000000014	EUR	2026-01-08 15:27:32	processing
460	-1	206	1	100.439999999999998	EUR	2024-10-31 08:29:29	completed
472	533	545	5	285.870000000000005	RUB	2024-12-29 07:25:46	processing
461	360	537	3	231.349999999999994	USD	2025-12-11 07:20:39	cancelled
474	642	107	1	250.330000000000013	EUR	2024-09-17 18:27:55	cancelled
462	21	98	5	38.9799999999999969	EUR	2024-08-31 09:01:30	completed
477	657	395	1	33.1300000000000026	EUR	2026-03-27 06:31:54	completed
464	577	511	2	102.359999999999999	RUB	2026-01-06 10:52:42	completed
478	361	183	4	371.879999999999995	RUB	2025-06-04 16:37:08	processing
465	549	182	2	303.860000000000014	RUB	2024-12-02 21:51:22	cancelled
480	328	16	2	289.860000000000014	RUB	2025-11-04 03:05:23	completed
466	-1	32	5	82.9399999999999977	EUR	2025-09-29 10:06:24	processing
481	391	339	3	12.3200000000000003	USD	2025-10-04 07:11:23	completed
469	159	399	4	465.019999999999982	RUB	2025-06-07 05:47:39	cancelled
483	637	-1	4	343.389999999999986	RUB	2024-05-30 23:47:26	cancelled
470	120	503	2	189.189999999999998	USD	2025-01-27 19:24:41	completed
488	263	292	4	149.560000000000002	EUR	2026-02-23 12:10:36	processing
471	0	-1	4	407.339999999999975	RUB	2026-02-03 22:33:35	completed
489	268	510	2	475.600000000000023	RUB	2024-09-28 18:19:43	completed
473	404	203	3	166.960000000000008	EUR	2026-03-15 00:57:18	cancelled
492	147	216	5	385.730000000000018	USD	2025-12-03 03:30:59	processing
475	575	57	4	496.220000000000027	EUR	2025-07-21 15:14:59	processing
496	617	59	2	278.089999999999975	EUR	2025-09-28 17:55:52	completed
476	43	556	5	376.449999999999989	RUB	2025-09-07 06:10:12	completed
497	-1	330	1	313.110000000000014	USD	2025-04-26 20:45:02	cancelled
479	380	227	2	58.3400000000000034	USD	2025-03-21 01:49:33	processing
499	397	578	2	383.470000000000027	USD	2025-08-15 13:41:54	processing
482	400	-1	4	31.9299999999999997	USD	2025-01-23 22:06:10	completed
503	294	377	4	499.579999999999984	USD	2024-11-25 16:12:59	processing
484	210	426	3	210.509999999999991	USD	2025-06-10 06:28:46	cancelled
504	22	555	1	235.370000000000005	RUB	2025-03-18 12:30:07	completed
485	387	-1	4	134.180000000000007	USD	2025-05-17 12:50:32	processing
507	-1	-1	2	288.509999999999991	RUB	2026-01-20 05:29:54	cancelled
486	0	73	2	334.850000000000023	USD	2024-07-23 07:40:02	processing
510	205	443	2	333.230000000000018	RUB	2024-06-22 22:27:45	completed
487	118	336	4	42.5900000000000034	RUB	2024-10-19 22:53:44	completed
511	0	577	5	336.829999999999984	EUR	2026-03-08 08:04:01	completed
490	131	39	4	63.5799999999999983	USD	2024-09-21 09:36:19	cancelled
517	311	546	2	90	USD	2026-02-18 07:07:34	processing
491	189	380	1	128.460000000000008	RUB	2024-12-14 16:37:29	cancelled
518	420	256	4	352.930000000000007	EUR	2024-06-14 04:42:03	completed
493	0	180	2	177.259999999999991	EUR	\N	cancelled
521	586	353	4	473.839999999999975	RUB	2025-01-16 01:10:03	cancelled
494	474	518	4	196.219999999999999	EUR	2026-01-07 10:33:47	completed
523	114	300	2	481.170000000000016	EUR	2025-06-10 05:59:22	processing
495	231	72	4	22.3999999999999986	EUR	2026-03-03 01:52:52	completed
527	280	565	4	333.110000000000014	EUR	2025-03-10 09:44:44	completed
498	40	577	2	12.8900000000000006	USD	2025-10-14 11:30:50	completed
528	134	310	1	369.970000000000027	USD	2025-11-14 05:42:45	cancelled
500	0	396	4	469.230000000000018	RUB	2025-01-03 19:25:25	cancelled
529	205	385	1	350.689999999999998	EUR	2024-10-28 18:48:41	cancelled
501	-1	257	2	344.610000000000014	RUB	2025-09-25 01:15:16	cancelled
532	327	249	1	407.269999999999982	USD	2024-07-13 20:40:29	completed
502	652	230	2	232.569999999999993	EUR	2024-11-25 01:45:07	completed
534	14	-1	5	44.490000000000002	RUB	2026-04-09 23:16:20	cancelled
505	412	428	2	471.519999999999982	EUR	2024-12-07 02:39:32	cancelled
536	84	239	1	11.8800000000000008	RUB	2024-07-09 13:23:08	completed
506	464	409	3	175.52000000000001	RUB	2024-09-13 02:37:26	completed
538	-1	454	5	433.850000000000023	USD	2025-12-03 00:11:36	completed
508	475	219	4	193.659999999999997	EUR	2026-02-11 21:14:42	cancelled
540	-1	234	2	101.650000000000006	EUR	2025-09-20 07:21:58	completed
509	145	423	4	157.159999999999997	RUB	2025-11-22 20:08:50	completed
542	437	258	2	269.970000000000027	RUB	2025-12-21 19:54:49	cancelled
512	657	480	2	83.8299999999999983	EUR	2026-03-27 02:29:39	completed
544	82	91	4	15.8800000000000008	RUB	2026-03-31 22:06:52	cancelled
513	134	544	5	467.180000000000007	RUB	2024-05-27 14:51:43	processing
545	603	583	5	342.319999999999993	USD	2026-01-04 05:37:27	cancelled
514	644	55	1	52.0200000000000031	USD	2026-05-18 12:10:53	cancelled
546	-1	501	4	191.52000000000001	EUR	2025-08-26 05:48:34	cancelled
515	93	315	2	374.360000000000014	USD	2025-09-25 15:17:28	completed
547	560	362	5	93.5699999999999932	RUB	2024-06-30 15:26:30	cancelled
516	372	180	4	242.789999999999992	RUB	2026-04-14 04:04:52	cancelled
549	146	391	1	437.949999999999989	EUR	2024-08-15 02:45:01	processing
519	680	391	1	380.279999999999973	USD	2025-09-07 04:14:58	cancelled
551	17	402	3	106.900000000000006	EUR	2026-05-08 03:59:50	completed
520	389	452	5	347.180000000000007	EUR	2025-03-25 19:11:46	processing
552	311	-1	3	121.590000000000003	EUR	2025-03-02 19:07:25	processing
522	88	404	2	315.779999999999973	RUB	2026-02-22 10:17:49	completed
553	512	62	2	248.800000000000011	RUB	2025-09-15 18:40:28	cancelled
524	86	428	4	17.8200000000000003	RUB	2025-10-18 14:56:54	completed
554	109	241	4	307.829999999999984	USD	2025-06-01 19:47:12	processing
525	374	502	3	491.199999999999989	USD	2024-12-09 04:01:49	cancelled
557	350	65	2	191.090000000000003	EUR	2025-12-16 08:12:51	completed
526	171	346	3	138.930000000000007	EUR	2024-07-18 17:00:22	completed
559	288	330	3	352.180000000000007	USD	2025-09-15 05:10:04	processing
530	376	136	4	209.530000000000001	EUR	2025-02-23 09:30:43	cancelled
561	482	-1	1	198.22999999999999	USD	2025-10-25 13:12:58	cancelled
531	-1	87	3	140.669999999999987	EUR	2026-02-09 18:37:19	processing
562	84	198	3	42.7899999999999991	EUR	2025-01-10 18:26:28	cancelled
533	182	10	2	391.649999999999977	USD	2026-04-21 00:06:51	processing
566	303	290	2	266.519999999999982	RUB	2025-01-10 11:11:50	completed
535	647	143	1	310.160000000000025	USD	2025-01-03 01:01:30	completed
567	386	148	1	156.110000000000014	USD	2024-11-20 19:29:59	cancelled
537	52	508	5	104.390000000000001	USD	2025-08-29 04:58:20	processing
568	0	152	4	48.5700000000000003	EUR	2024-08-27 03:47:47	cancelled
539	0	590	2	139	RUB	2024-10-02 23:24:52	completed
569	641	281	4	381.649999999999977	USD	2024-09-15 02:40:41	cancelled
541	405	293	5	212.02000000000001	RUB	2026-01-14 12:15:20	completed
570	283	331	3	89.8199999999999932	USD	2024-10-04 12:22:10	completed
543	166	-1	3	452.319999999999993	USD	2024-08-31 13:01:48	cancelled
571	127	385	4	190.719999999999999	EUR	2024-08-24 12:43:59	processing
548	477	464	4	237.180000000000007	EUR	2026-02-16 16:37:36	completed
573	290	136	1	442.800000000000011	USD	2025-01-30 15:24:11	cancelled
550	153	223	2	84.0100000000000051	USD	\N	completed
574	66	241	1	266.160000000000025	RUB	2026-02-07 04:35:54	completed
555	507	163	1	478.860000000000014	RUB	2024-07-26 09:29:02	cancelled
578	54	239	4	30.7699999999999996	USD	2024-09-26 19:07:13	completed
556	646	543	5	69.7099999999999937	USD	2024-06-03 06:38:09	cancelled
579	141	505	4	19.4400000000000013	EUR	2025-11-03 01:52:31	completed
558	458	-1	3	347.259999999999991	EUR	2025-06-08 18:13:38	cancelled
583	398	335	5	135.580000000000013	USD	2024-10-15 10:35:18	cancelled
560	587	501	5	308.600000000000023	USD	2025-12-11 12:25:01	processing
585	210	205	1	373.980000000000018	USD	2024-09-21 14:53:48	processing
563	-1	-1	1	242.139999999999986	USD	2025-04-11 19:24:21	completed
587	664	318	3	116.230000000000004	USD	2025-01-17 23:47:28	completed
564	336	328	5	81.5999999999999943	EUR	2025-12-23 05:46:57	cancelled
588	222	398	2	254.800000000000011	RUB	2025-09-20 22:01:04	processing
565	322	-1	2	479.29000000000002	RUB	2025-04-29 04:26:27	completed
589	336	575	2	461.199999999999989	EUR	2025-01-31 08:21:16	processing
572	27	36	4	97.2199999999999989	RUB	2024-06-09 08:38:27	processing
591	635	456	3	465.779999999999973	EUR	\N	cancelled
575	369	505	4	178.349999999999994	USD	2024-12-24 06:16:42	cancelled
592	-1	196	1	190.340000000000003	RUB	2026-02-16 12:06:53	cancelled
576	559	92	4	350.350000000000023	RUB	2025-06-25 12:39:27	completed
593	382	123	1	155.759999999999991	USD	2026-01-11 11:57:19	cancelled
577	460	572	3	121.420000000000002	USD	2025-11-17 04:00:02	completed
595	0	571	2	233.069999999999993	RUB	2025-06-11 09:31:40	cancelled
580	686	37	1	29.6600000000000001	RUB	2025-11-07 10:39:50	completed
596	0	221	1	368.399999999999977	USD	2025-01-31 05:29:22	completed
581	236	522	1	294.980000000000018	EUR	\N	completed
597	408	423	4	221.919999999999987	EUR	\N	completed
582	407	384	5	147.889999999999986	RUB	2024-06-28 07:56:18	processing
598	14	289	1	480.120000000000005	EUR	2024-07-20 17:53:35	processing
584	403	525	1	228.319999999999993	RUB	2025-01-06 18:15:25	cancelled
599	491	241	3	481.95999999999998	USD	2025-08-23 09:29:12	processing
586	306	475	5	410.75	EUR	2024-09-22 19:16:13	completed
602	468	565	3	332.70999999999998	EUR	2025-10-18 21:05:00	processing
590	293	1	2	48.0600000000000023	USD	2024-06-04 00:07:34	completed
605	89	478	3	463.110000000000014	RUB	2025-05-01 22:32:45	cancelled
594	146	32	2	68.9599999999999937	RUB	2025-02-09 21:31:07	cancelled
606	553	149	1	178.289999999999992	RUB	2025-05-05 21:11:10	processing
600	459	573	1	438.029999999999973	EUR	2024-07-07 14:26:58	processing
608	-1	43	1	495.350000000000023	RUB	2025-11-01 02:47:01	processing
601	501	-1	1	150.389999999999986	USD	2025-11-19 02:59:51	cancelled
609	107	233	5	335.670000000000016	USD	2025-06-29 07:44:34	processing
603	150	382	4	95.2399999999999949	EUR	2025-03-03 19:37:16	cancelled
614	555	303	2	21.5199999999999996	USD	2024-10-29 10:39:31	completed
604	356	369	4	341.100000000000023	EUR	2024-12-18 23:40:55	cancelled
615	213	122	1	42.8400000000000034	EUR	2024-09-26 03:59:58	cancelled
607	350	143	2	427.04000000000002	RUB	2024-09-11 00:25:10	completed
619	552	503	5	313.910000000000025	EUR	2024-11-09 00:38:26	completed
610	-1	562	3	368.610000000000014	EUR	2024-11-17 19:35:42	cancelled
621	252	346	1	232.800000000000011	RUB	2025-01-28 17:02:53	completed
611	536	109	5	182.060000000000002	EUR	2025-06-24 14:31:06	completed
623	629	29	2	300.779999999999973	RUB	\N	processing
612	656	111	2	360.939999999999998	RUB	2025-11-04 09:51:24	cancelled
624	456	549	3	351.589999999999975	EUR	2026-05-12 18:48:52	processing
613	148	311	3	128.5	EUR	2025-03-24 14:19:52	completed
625	0	301	5	250.639999999999986	EUR	2025-10-13 06:44:24	completed
616	367	384	5	157.110000000000014	EUR	\N	completed
627	498	310	2	388.509999999999991	USD	2025-08-19 15:49:14	completed
617	312	43	4	321.259999999999991	RUB	2025-10-27 01:52:41	processing
629	169	509	5	285.759999999999991	EUR	2025-09-18 07:00:44	cancelled
618	504	485	3	25.2100000000000009	RUB	2026-05-22 12:16:39	cancelled
630	-1	429	3	321.069999999999993	USD	2026-05-20 01:17:09	cancelled
620	0	95	1	242.689999999999998	RUB	2024-12-25 10:46:33	completed
632	367	124	2	454.240000000000009	USD	2025-05-22 12:28:26	completed
622	619	463	3	280.79000000000002	RUB	2026-04-30 09:32:01	completed
633	166	383	2	228.590000000000003	RUB	2025-11-07 10:36:22	processing
626	41	204	1	346.54000000000002	USD	2024-11-26 11:07:19	cancelled
636	116	328	5	14.3399999999999999	USD	2025-06-23 17:54:14	completed
628	229	119	4	122.079999999999998	EUR	2024-06-16 21:07:22	completed
637	492	102	4	244.349999999999994	USD	2026-05-03 15:52:01	completed
631	35	270	4	42.7999999999999972	USD	2024-08-09 19:58:52	processing
638	398	523	1	81.5999999999999943	USD	2024-06-29 04:45:34	completed
634	270	574	2	295.240000000000009	USD	2025-04-04 00:45:17	completed
639	70	-1	1	287.420000000000016	USD	2026-05-15 09:16:08	cancelled
635	238	523	4	15.4800000000000004	USD	2025-01-25 16:10:01	completed
641	0	231	3	201.47999999999999	RUB	2025-09-11 08:52:23	processing
640	641	44	3	209.129999999999995	EUR	2025-02-12 07:54:12	cancelled
642	131	162	5	445.480000000000018	RUB	2025-12-29 08:42:14	completed
648	502	-1	5	319.370000000000005	EUR	2025-04-22 16:03:12	cancelled
643	614	428	1	222.039999999999992	USD	2024-06-23 01:41:42	completed
649	278	246	2	163.400000000000006	EUR	2024-08-22 18:51:11	processing
644	576	379	2	388.730000000000018	USD	2024-06-02 00:02:46	cancelled
650	196	286	3	263.660000000000025	EUR	2025-10-27 01:40:39	cancelled
645	403	-1	3	158.710000000000008	RUB	2025-05-15 18:31:43	cancelled
651	613	303	5	446.370000000000005	USD	2025-05-21 06:14:51	completed
646	316	-1	4	199.189999999999998	RUB	2026-05-20 21:35:10	processing
652	-1	596	5	167.360000000000014	EUR	2026-05-20 13:26:07	processing
647	574	94	5	77.2600000000000051	EUR	2026-04-26 21:43:09	processing
655	278	74	3	81.7099999999999937	RUB	2024-08-17 08:34:55	cancelled
653	178	-1	3	322.910000000000025	USD	2025-07-25 09:03:33	processing
656	128	261	4	11.5999999999999996	USD	2025-04-06 23:23:11	cancelled
654	346	496	4	193.75	EUR	2024-06-06 04:48:33	processing
657	466	204	3	260.449999999999989	EUR	2025-05-08 16:00:21	cancelled
659	321	43	3	382.45999999999998	USD	2024-06-26 18:51:58	completed
658	53	448	4	301.680000000000007	EUR	2025-06-17 08:19:24	cancelled
660	285	434	2	394.100000000000023	RUB	2026-02-22 06:26:13	completed
662	441	566	5	289.600000000000023	EUR	2026-01-17 23:26:36	cancelled
661	41	284	1	64.5999999999999943	RUB	2024-05-31 05:15:51	cancelled
663	243	393	3	383.550000000000011	USD	2025-04-30 07:01:42	completed
665	128	170	2	128.590000000000003	RUB	2025-02-11 23:02:59	completed
664	555	277	1	289.910000000000025	RUB	2025-06-09 16:59:41	cancelled
667	219	154	4	359.089999999999975	EUR	2024-07-25 21:05:02	processing
666	226	396	3	223.240000000000009	RUB	\N	cancelled
668	394	211	1	275.220000000000027	EUR	2025-08-22 01:23:05	processing
670	398	-1	3	80.8100000000000023	USD	2024-05-26 22:14:52	processing
669	504	520	3	167.819999999999993	EUR	2024-06-03 21:07:34	processing
671	700	415	2	116.780000000000001	EUR	2026-05-13 20:10:59	cancelled
674	354	92	4	364.850000000000023	EUR	\N	cancelled
672	255	25	4	304.20999999999998	EUR	2024-10-10 14:44:10	processing
676	661	374	2	424.490000000000009	EUR	2025-07-18 13:06:29	completed
673	577	399	4	359.399999999999977	USD	2024-10-02 21:19:33	processing
680	587	434	2	151.240000000000009	EUR	2026-02-01 08:19:05	completed
675	262	225	3	244.47999999999999	USD	2026-03-14 16:37:23	processing
681	0	104	5	359.139999999999986	USD	2024-11-20 17:23:00	cancelled
677	235	52	1	311.569999999999993	RUB	2025-10-10 12:20:00	cancelled
682	184	184	5	382.819999999999993	RUB	2026-01-31 17:24:40	completed
678	82	286	2	153.639999999999986	EUR	2025-10-31 13:58:42	completed
683	547	279	1	169.47999999999999	USD	2026-01-22 09:55:27	processing
679	235	-1	1	123.590000000000003	USD	2026-03-30 11:43:19	completed
685	136	474	3	291.189999999999998	EUR	2026-03-18 16:09:20	completed
684	22	481	4	76.1299999999999955	USD	2025-06-13 22:05:15	completed
686	466	44	2	89.4200000000000017	RUB	2025-12-03 13:25:40	completed
688	555	363	4	481.430000000000007	RUB	2024-08-31 09:51:18	processing
687	387	405	5	401.430000000000007	RUB	2026-04-11 23:00:17	processing
691	619	499	3	193.080000000000013	EUR	2025-01-31 23:34:54	completed
689	592	171	3	266.5	EUR	2024-10-23 18:27:58	processing
692	17	144	2	230.469999999999999	RUB	2024-06-23 19:05:44	processing
690	512	306	1	303.899999999999977	EUR	2026-05-05 23:28:08	completed
696	670	565	3	183.840000000000003	RUB	2025-07-16 23:02:26	cancelled
693	310	499	2	452.800000000000011	EUR	2024-08-04 15:45:42	cancelled
697	42	199	4	43.2000000000000028	EUR	2025-08-19 11:07:14	cancelled
694	478	53	2	237.02000000000001	EUR	2026-03-16 07:15:52	completed
700	472	600	3	34.9500000000000028	RUB	2025-01-31 11:26:48	completed
695	150	477	3	193.280000000000001	EUR	2025-04-20 13:36:56	cancelled
701	449	580	5	27.7199999999999989	RUB	2024-08-14 00:27:24	processing
698	519	277	2	374.730000000000018	RUB	2024-09-12 10:15:50	completed
702	69	451	4	171.77000000000001	RUB	2025-07-05 17:34:46	processing
699	26	343	3	21.8299999999999983	EUR	2025-07-10 06:58:06	processing
703	-1	283	2	55.6599999999999966	EUR	2025-06-06 16:04:58	cancelled
704	0	199	2	105.299999999999997	RUB	2025-03-09 19:48:46	cancelled
705	156	168	2	10.2799999999999994	USD	2025-01-12 02:06:40	completed
706	272	506	2	239.469999999999999	USD	2025-04-02 00:14:03	completed
708	591	540	3	319.449999999999989	EUR	2026-03-19 01:02:38	completed
707	82	481	3	312.230000000000018	EUR	2024-12-31 18:19:55	cancelled
709	684	252	5	344.470000000000027	RUB	2025-10-14 23:53:09	completed
712	255	372	1	351.720000000000027	RUB	2025-01-25 21:19:00	cancelled
710	23	415	5	157.280000000000001	RUB	2026-03-31 00:25:11	completed
714	68	158	1	223.460000000000008	EUR	2025-05-03 02:09:45	cancelled
711	606	229	1	413.79000000000002	RUB	2026-03-07 03:46:09	completed
716	406	169	2	150.370000000000005	RUB	2025-07-09 22:19:07	cancelled
713	410	493	1	128.819999999999993	RUB	2025-03-16 06:22:56	processing
717	164	9	1	59.3200000000000003	USD	2026-05-22 00:47:50	completed
715	485	499	3	67.9300000000000068	USD	2026-02-02 13:45:24	cancelled
718	554	483	2	496	USD	2024-11-15 13:22:44	completed
720	586	597	3	171.77000000000001	USD	2025-08-17 22:23:41	completed
719	34	366	3	342.579999999999984	RUB	2024-06-02 02:11:46	processing
721	41	503	2	396.879999999999995	EUR	2024-08-28 09:30:41	completed
722	274	292	5	45.1199999999999974	RUB	2025-04-14 13:20:31	completed
723	67	528	2	325.300000000000011	RUB	2024-12-01 21:59:26	completed
724	509	167	1	202.759999999999991	EUR	2024-08-10 17:49:44	processing
725	485	411	5	160.139999999999986	RUB	2025-09-05 20:00:02	cancelled
728	-1	494	3	293.839999999999975	RUB	2024-06-05 21:56:08	cancelled
726	241	153	3	113.170000000000002	EUR	2026-02-16 03:22:16	processing
732	335	189	3	479.449999999999989	RUB	2026-03-22 19:26:53	completed
727	0	130	1	82.3599999999999994	EUR	2024-07-02 05:57:50	completed
734	144	185	3	454.579999999999984	RUB	2024-08-23 20:52:03	cancelled
729	420	215	5	367.399999999999977	EUR	2026-01-02 21:25:48	cancelled
735	40	346	3	402.100000000000023	EUR	2026-02-17 09:59:57	completed
730	0	33	2	179.090000000000003	USD	2026-04-29 02:53:32	cancelled
736	108	341	5	108.840000000000003	USD	2026-04-29 13:39:39	processing
731	399	461	4	394.029999999999973	EUR	2025-05-07 18:31:30	completed
737	675	-1	3	270.129999999999995	RUB	2025-08-25 04:23:35	processing
733	169	152	4	439.009999999999991	EUR	2025-08-07 15:12:22	completed
739	298	418	1	149.400000000000006	USD	2024-11-04 21:07:02	processing
738	627	-1	1	232.930000000000007	RUB	2024-10-09 11:55:54	processing
740	643	586	4	465.230000000000018	RUB	2026-01-30 21:29:18	completed
741	323	40	3	157.139999999999986	RUB	2024-11-11 05:09:43	completed
743	461	549	1	479.730000000000018	EUR	\N	processing
742	685	42	3	12.0999999999999996	USD	2024-09-26 13:22:59	completed
745	595	399	3	392.04000000000002	USD	2025-02-19 09:47:10	processing
744	0	53	3	386.759999999999991	RUB	2024-07-31 08:56:37	cancelled
748	674	168	2	453.920000000000016	USD	2025-12-17 15:47:22	cancelled
746	-1	82	2	16.9600000000000009	EUR	2025-09-09 01:47:11	cancelled
758	464	347	1	493.949999999999989	EUR	2024-10-13 17:13:32	cancelled
747	663	265	1	73.6400000000000006	RUB	2025-11-15 02:59:42	completed
759	8	-1	1	75.7000000000000028	USD	2025-04-30 03:40:43	processing
749	100	71	5	348.860000000000014	RUB	2025-04-08 19:43:24	completed
760	575	349	4	252.22999999999999	RUB	2025-03-18 10:06:36	completed
750	160	277	1	477.259999999999991	USD	2025-12-20 19:25:41	completed
763	157	77	1	487.810000000000002	EUR	2025-01-29 08:27:16	cancelled
751	117	477	5	385.339999999999975	RUB	2026-04-13 20:29:50	processing
764	316	190	1	490.810000000000002	EUR	2025-02-25 07:13:26	processing
752	126	362	1	184.569999999999993	USD	2026-01-30 11:50:39	completed
766	98	591	3	445.319999999999993	USD	2025-02-16 05:40:09	completed
753	398	89	3	365.399999999999977	RUB	2026-01-06 19:14:24	completed
767	597	555	3	162.629999999999995	RUB	2024-12-08 00:13:35	completed
754	167	360	5	105.140000000000001	RUB	2024-09-09 21:11:53	completed
768	-1	305	5	155.629999999999995	RUB	2025-09-27 16:28:37	completed
755	349	413	4	60.75	RUB	2024-12-18 16:31:54	completed
769	414	276	4	55.5499999999999972	EUR	2025-10-08 09:20:32	processing
756	172	233	5	376.389999999999986	USD	2025-06-23 02:09:42	processing
773	482	522	2	371.550000000000011	RUB	2025-02-05 14:28:00	completed
757	507	43	3	324.839999999999975	USD	2025-11-03 04:59:54	completed
774	0	193	3	292.579999999999984	RUB	2024-07-15 12:55:30	cancelled
761	640	436	3	130.560000000000002	RUB	2024-09-11 03:43:14	cancelled
776	353	276	4	456.269999999999982	EUR	2025-09-18 06:49:35	completed
762	40	265	3	335.759999999999991	USD	2024-12-08 18:10:28	cancelled
780	48	116	2	482.95999999999998	EUR	2024-09-16 01:02:56	processing
765	96	372	5	303.779999999999973	USD	2024-11-14 00:45:32	completed
782	148	421	1	435.70999999999998	EUR	2025-07-13 13:24:27	cancelled
770	54	44	5	11.9600000000000009	EUR	2024-11-24 15:27:52	cancelled
784	362	448	2	250.060000000000002	EUR	2025-02-14 00:37:22	completed
771	370	254	2	299.519999999999982	RUB	2025-12-03 14:00:11	completed
786	297	182	3	78.9399999999999977	EUR	2025-07-02 08:40:31	cancelled
772	343	-1	5	353.339999999999975	USD	2025-12-11 03:06:29	completed
789	492	498	1	392.689999999999998	RUB	2024-09-25 22:13:42	cancelled
775	561	541	5	336.769999999999982	USD	2026-04-27 10:27:29	cancelled
790	225	380	2	63.8100000000000023	RUB	2025-02-24 16:22:44	processing
777	632	510	4	134.949999999999989	RUB	2025-11-30 05:22:11	completed
791	261	414	5	401.740000000000009	RUB	2026-04-08 05:52:38	completed
778	118	189	3	348.740000000000009	RUB	2024-07-02 10:30:37	processing
793	570	509	5	461.699999999999989	RUB	2026-02-01 01:30:17	processing
779	595	256	2	358.420000000000016	USD	2026-05-18 09:54:09	processing
795	199	-1	4	133.069999999999993	EUR	2025-06-11 11:45:45	completed
781	3	212	1	212.539999999999992	EUR	2025-09-19 16:05:11	cancelled
796	644	99	5	286.95999999999998	EUR	2025-01-05 14:35:25	cancelled
783	676	212	2	430.300000000000011	USD	2024-07-14 18:51:02	cancelled
797	484	366	3	32.4399999999999977	EUR	2026-04-24 13:16:04	cancelled
785	0	470	1	392.879999999999995	USD	2025-02-13 05:04:03	processing
799	579	548	1	110.430000000000007	EUR	2025-12-17 18:49:56	processing
787	15	311	1	297.379999999999995	EUR	2024-07-27 19:24:57	processing
804	-1	222	1	463.850000000000023	EUR	2025-04-26 10:43:03	cancelled
788	230	277	3	421.339999999999975	EUR	2024-06-21 01:10:03	completed
807	100	240	3	104.349999999999994	USD	2025-04-25 00:43:04	processing
792	65	251	2	450.399999999999977	EUR	2026-02-21 16:10:02	processing
811	0	112	5	95.7999999999999972	EUR	2025-11-28 09:55:27	completed
794	4	2	5	215.669999999999987	EUR	\N	cancelled
812	162	171	1	222.960000000000008	RUB	2025-07-06 17:38:30	cancelled
798	247	79	4	479.180000000000007	USD	2026-03-13 23:58:48	completed
813	-1	600	5	475.480000000000018	RUB	2025-12-05 14:23:39	cancelled
800	75	227	5	226.22999999999999	USD	2024-12-20 17:59:47	processing
816	21	596	5	237.789999999999992	USD	2024-07-17 15:16:50	completed
801	220	419	3	15.7300000000000004	RUB	2024-11-26 16:53:13	completed
818	405	552	2	35.8900000000000006	USD	2024-12-17 17:02:42	completed
802	288	-1	2	55.8100000000000023	USD	2024-10-18 09:51:20	completed
820	566	563	1	137.22999999999999	EUR	2025-05-15 00:28:19	completed
803	96	46	5	375.740000000000009	USD	2026-01-19 05:25:17	cancelled
822	152	472	5	49.2800000000000011	EUR	2025-12-27 11:35:07	completed
805	339	1	2	463.160000000000025	EUR	2025-08-04 20:22:52	cancelled
823	698	28	1	26.2199999999999989	USD	2025-10-06 05:05:06	processing
806	-1	28	4	282.579999999999984	USD	2025-09-01 06:20:51	processing
824	0	600	1	50.9799999999999969	USD	2025-07-15 15:29:35	completed
808	47	472	2	106.849999999999994	EUR	2025-07-19 05:02:48	completed
825	85	381	1	225.099999999999994	RUB	2026-03-26 00:08:34	completed
809	678	210	1	67.7600000000000051	RUB	2025-09-23 15:27:18	cancelled
828	559	503	5	274.610000000000014	EUR	2025-02-18 01:54:55	processing
810	643	163	4	85.4300000000000068	USD	2025-04-07 16:59:47	cancelled
829	79	322	3	255.689999999999998	USD	2024-12-14 06:43:03	cancelled
814	464	460	5	333.649999999999977	USD	2024-08-13 22:15:27	cancelled
830	0	3	1	31.629999999999999	USD	2025-09-27 00:26:44	processing
815	177	220	3	164.710000000000008	RUB	2025-05-04 19:13:26	processing
834	0	247	4	35.990000000000002	USD	2025-08-09 17:34:11	cancelled
817	-1	574	5	475.29000000000002	USD	2026-01-02 01:44:12	cancelled
835	617	-1	5	183.990000000000009	USD	2025-04-24 05:59:23	processing
819	130	248	5	276.399999999999977	USD	2024-10-28 22:33:31	processing
836	539	402	3	402.980000000000018	USD	2026-05-18 01:53:43	cancelled
821	0	92	2	78.4599999999999937	USD	2025-02-07 07:49:49	processing
837	542	-1	5	371.870000000000005	EUR	2025-04-22 00:21:06	processing
826	646	389	2	494.319999999999993	EUR	2025-04-17 08:34:31	processing
838	265	255	5	474.740000000000009	EUR	2026-05-11 20:40:05	processing
827	118	164	3	378.740000000000009	EUR	2025-10-26 23:56:08	completed
839	199	275	5	327.389999999999986	EUR	2024-11-22 16:00:48	completed
831	268	529	3	53.4600000000000009	RUB	2026-04-15 08:43:57	cancelled
840	159	175	4	313.350000000000023	EUR	2024-09-17 20:19:08	processing
832	543	276	1	125.540000000000006	USD	2025-05-19 19:44:56	processing
843	85	400	4	152.900000000000006	RUB	2025-11-16 07:43:07	completed
833	234	591	1	189.439999999999998	USD	2024-07-21 23:55:00	cancelled
845	235	197	5	344.759999999999991	EUR	2024-12-08 03:00:20	processing
841	586	22	3	209.740000000000009	USD	2026-03-21 08:49:38	completed
846	24	298	3	211.47999999999999	EUR	2025-08-28 00:14:23	processing
842	430	318	5	221.139999999999986	USD	2024-08-14 03:02:45	cancelled
848	248	340	2	416.899999999999977	EUR	2025-11-11 18:09:33	processing
844	364	192	3	434.470000000000027	USD	2025-03-26 13:01:18	cancelled
855	41	518	1	478.54000000000002	RUB	2024-12-16 19:13:02	cancelled
847	590	112	1	388.300000000000011	RUB	2025-11-12 11:33:41	cancelled
856	336	538	5	430.610000000000014	RUB	2024-06-27 09:03:08	completed
849	138	39	1	340.100000000000023	EUR	2025-05-02 16:52:55	cancelled
857	11	-1	1	498.660000000000025	USD	2025-08-07 08:54:22	completed
850	-1	214	3	127.019999999999996	USD	2025-06-12 13:09:56	cancelled
860	-1	377	5	343.259999999999991	EUR	2025-04-28 07:05:10	processing
851	199	405	3	442.910000000000025	USD	2024-10-24 14:50:45	processing
861	355	539	3	305.810000000000002	USD	2025-12-13 21:25:28	processing
852	228	466	1	56.3400000000000034	RUB	2025-12-25 10:50:05	processing
865	79	418	3	73.730000000000004	RUB	2025-10-20 21:34:14	processing
853	478	247	5	33.6799999999999997	USD	2024-09-25 06:29:39	processing
866	44	439	3	126.450000000000003	EUR	2025-04-22 15:45:31	cancelled
854	94	331	2	76.0100000000000051	RUB	2025-06-11 11:15:14	completed
868	57	91	4	204.939999999999998	RUB	2024-08-17 09:02:01	completed
858	343	14	2	420.420000000000016	RUB	2025-07-06 17:56:37	completed
870	224	564	1	410.519999999999982	RUB	2026-03-19 23:12:04	completed
859	-1	-1	4	139.300000000000011	EUR	2025-10-31 09:41:40	completed
877	595	464	3	291.300000000000011	USD	2026-03-22 07:49:21	cancelled
862	589	489	2	123.359999999999999	RUB	2026-01-18 11:03:21	cancelled
879	640	-1	3	416.839999999999975	RUB	2025-06-16 01:54:49	processing
863	28	162	4	105.409999999999997	RUB	2024-11-05 03:28:58	completed
882	0	180	3	289.050000000000011	USD	2024-07-16 14:09:01	completed
864	622	346	2	231.129999999999995	EUR	2026-03-08 08:00:05	cancelled
883	111	441	2	154.27000000000001	USD	2025-09-28 03:14:20	cancelled
867	48	44	2	218.990000000000009	USD	2026-03-05 23:06:40	completed
886	222	334	2	264.800000000000011	USD	2024-11-26 10:10:27	processing
869	396	103	3	470.75	USD	2024-07-13 14:51:37	completed
889	121	31	5	308.899999999999977	EUR	2024-08-31 20:25:12	processing
871	447	147	4	217.990000000000009	RUB	2025-02-21 05:05:28	processing
890	151	273	5	341.509999999999991	EUR	2024-08-04 16:08:24	completed
872	216	119	3	377.339999999999975	USD	2025-04-08 22:16:53	completed
894	153	-1	3	426.379999999999995	EUR	2024-09-11 22:55:03	completed
873	312	351	5	492.720000000000027	USD	\N	cancelled
900	454	287	1	367.689999999999998	USD	2025-11-11 22:58:12	cancelled
874	244	140	5	370.95999999999998	RUB	2025-09-27 21:16:37	cancelled
901	18	60	5	147.939999999999998	USD	2025-01-20 06:05:43	processing
875	48	105	5	364.689999999999998	USD	2025-10-02 22:03:02	processing
903	20	394	4	365.240000000000009	EUR	2025-03-22 10:38:14	completed
876	380	378	5	412.910000000000025	RUB	2024-06-01 18:40:17	processing
904	165	24	1	386.870000000000005	EUR	2025-04-19 08:12:33	cancelled
878	597	-1	5	356.019999999999982	RUB	2025-12-22 11:59:03	cancelled
905	537	238	2	107.239999999999995	EUR	2025-12-04 08:42:18	completed
880	-1	303	4	53.9299999999999997	RUB	2024-10-01 01:17:06	completed
906	136	112	2	109.280000000000001	EUR	2025-07-20 09:36:09	cancelled
881	549	579	5	131.620000000000005	EUR	2025-12-12 15:57:41	completed
907	558	105	2	426.279999999999973	USD	2026-03-01 13:46:33	completed
884	578	572	4	314.889999999999986	USD	2024-08-26 21:03:41	cancelled
908	618	526	2	377.670000000000016	USD	2025-03-29 07:49:55	processing
885	159	453	4	486.449999999999989	USD	2026-04-24 04:41:19	completed
909	326	125	5	488.449999999999989	EUR	2025-03-20 04:05:57	completed
887	679	142	2	450.279999999999973	RUB	2025-05-20 00:06:53	processing
915	604	176	2	137.939999999999998	EUR	2025-01-16 03:11:05	processing
888	575	418	3	415.730000000000018	EUR	2025-10-09 18:24:16	processing
916	560	238	5	224.590000000000003	EUR	2025-11-23 11:46:15	processing
891	564	16	4	318.870000000000005	USD	2025-08-04 03:53:51	processing
918	347	-1	1	251.47999999999999	RUB	2026-01-05 17:15:11	processing
892	494	322	2	385.579999999999984	RUB	2024-08-01 16:29:46	processing
922	691	553	3	17.2699999999999996	EUR	2024-11-14 02:45:31	cancelled
893	345	409	3	423.220000000000027	EUR	2026-03-05 06:12:34	processing
924	585	571	4	379.930000000000007	USD	2025-06-26 06:00:33	processing
895	31	527	2	10.4800000000000004	RUB	2024-06-29 05:13:53	cancelled
927	-1	257	4	487.75	RUB	2024-07-28 02:50:13	processing
896	615	397	1	499.240000000000009	USD	2025-03-25 14:38:45	processing
928	299	-1	5	175.47999999999999	RUB	2025-09-18 10:58:43	processing
897	207	50	5	174.069999999999993	USD	2026-01-21 09:03:07	completed
930	469	94	1	350.689999999999998	EUR	2026-02-19 16:33:32	cancelled
898	385	-1	3	49.25	RUB	2025-01-28 03:52:47	completed
933	-1	394	4	309.110000000000014	EUR	2025-09-03 21:53:38	processing
899	330	201	2	432.819999999999993	RUB	2025-01-03 16:16:59	processing
935	328	326	1	397.360000000000014	RUB	2025-10-11 04:05:43	processing
902	460	141	4	338.980000000000018	RUB	2025-07-20 03:23:27	cancelled
937	680	340	4	196.659999999999997	RUB	2024-09-30 16:00:21	processing
910	224	-1	5	155.400000000000006	EUR	2025-07-02 17:01:09	completed
939	351	472	2	467.769999999999982	EUR	2024-08-01 13:28:11	processing
911	-1	302	3	33.4099999999999966	EUR	2025-11-08 23:12:52	processing
941	137	200	3	396.870000000000005	USD	2025-10-05 19:27:36	processing
912	45	243	3	149.530000000000001	USD	2026-01-19 23:33:35	cancelled
943	546	399	4	97.1700000000000017	EUR	2026-05-02 09:39:41	completed
913	210	146	4	240.5	USD	2024-10-15 23:55:47	cancelled
944	590	352	2	435.480000000000018	USD	2025-07-31 01:42:53	processing
914	512	95	2	46.8400000000000034	USD	2025-08-19 20:23:00	cancelled
946	-1	573	4	264.279999999999973	EUR	2025-03-28 04:41:51	cancelled
917	249	419	2	276.319999999999993	EUR	2025-11-25 10:39:22	completed
948	314	116	5	413.920000000000016	USD	2025-05-13 07:01:10	cancelled
919	-1	63	1	232.25	RUB	2024-08-04 05:36:31	cancelled
950	276	91	3	112.989999999999995	EUR	2025-10-06 13:02:45	cancelled
920	509	374	2	431.449999999999989	USD	2026-03-21 12:07:35	completed
952	635	100	4	366.639999999999986	RUB	2024-12-15 11:19:18	completed
921	386	358	2	98.4200000000000017	RUB	2025-03-27 22:54:20	cancelled
954	659	182	1	27.2399999999999984	EUR	2025-03-14 18:48:39	cancelled
923	108	179	2	368.920000000000016	RUB	2026-05-06 23:12:27	completed
959	287	346	4	355.990000000000009	RUB	2024-10-05 14:01:19	processing
925	548	296	4	315.480000000000018	RUB	2024-07-19 07:20:57	processing
960	686	325	5	216.759999999999991	EUR	2025-03-27 12:21:18	processing
926	17	-1	1	426.930000000000007	USD	2025-08-07 12:11:10	processing
961	629	85	3	479.420000000000016	USD	2025-08-25 08:48:14	processing
929	567	559	3	179.919999999999987	RUB	2025-07-16 17:05:55	processing
964	119	349	1	112.090000000000003	EUR	2025-06-07 14:55:03	cancelled
931	184	553	4	201.340000000000003	USD	2025-09-13 22:24:40	processing
965	35	103	4	282.220000000000027	USD	2024-12-22 13:41:39	cancelled
932	0	-1	3	196.419999999999987	USD	2025-09-14 16:16:30	completed
966	311	-1	5	197.699999999999989	RUB	2026-02-02 09:47:05	processing
934	154	158	4	257.839999999999975	RUB	2024-05-26 19:01:23	completed
967	503	452	2	217.310000000000002	RUB	2025-10-03 23:08:29	processing
936	0	276	2	190.650000000000006	RUB	2026-02-18 17:46:11	completed
969	295	557	5	117.030000000000001	USD	2025-05-23 23:59:39	completed
938	468	181	1	92.2800000000000011	RUB	2025-05-21 00:13:26	processing
971	313	251	1	443.889999999999986	RUB	2026-04-21 11:19:54	cancelled
940	404	253	5	154.139999999999986	RUB	2024-09-02 14:44:35	processing
972	269	546	5	236.960000000000008	USD	2025-09-01 13:57:29	completed
942	587	336	2	137.759999999999991	RUB	2024-06-14 13:29:12	completed
974	476	496	3	285.399999999999977	EUR	2025-12-24 08:08:16	completed
945	623	109	2	431.620000000000005	RUB	2025-12-22 15:54:28	processing
977	563	65	1	326.259999999999991	USD	2025-10-05 23:48:55	cancelled
947	17	8	3	414.180000000000007	USD	2025-08-14 06:32:23	completed
981	656	333	2	125.859999999999999	USD	2025-08-06 22:51:56	processing
949	614	596	5	418.180000000000007	EUR	2024-08-02 10:44:44	completed
982	373	209	5	429.29000000000002	RUB	2024-08-12 09:23:09	cancelled
951	301	178	3	109.129999999999995	USD	2025-10-12 04:00:23	cancelled
984	505	585	3	131.099999999999994	USD	2025-04-08 07:24:44	cancelled
953	437	154	1	480.300000000000011	EUR	2025-10-12 04:26:11	processing
985	268	120	4	309.490000000000009	RUB	2026-02-24 02:37:03	completed
955	393	485	1	351.079999999999984	RUB	2025-07-09 06:05:30	processing
987	451	480	2	336.689999999999998	RUB	2025-12-21 22:08:23	processing
956	62	133	4	13.3000000000000007	EUR	2026-03-16 08:55:38	completed
990	-1	272	2	28.4499999999999993	USD	2026-04-26 20:04:53	processing
957	527	339	3	207.069999999999993	USD	2024-06-30 16:22:01	processing
991	501	583	4	264.129999999999995	RUB	2025-10-03 17:08:42	cancelled
958	439	552	5	258.160000000000025	EUR	2025-07-27 22:37:38	cancelled
993	653	310	1	108.980000000000004	EUR	2026-05-05 07:06:27	completed
962	439	160	1	442.420000000000016	USD	\N	cancelled
994	398	69	5	167.159999999999997	EUR	2025-12-24 01:02:05	cancelled
963	382	135	2	45.6499999999999986	USD	2025-07-07 09:28:30	processing
996	659	25	5	377.149999999999977	RUB	2026-05-03 18:01:38	completed
968	300	172	1	73.5699999999999932	RUB	2024-08-18 20:26:23	cancelled
998	591	96	2	346.519999999999982	EUR	2026-01-06 20:28:54	processing
970	137	8	2	307.220000000000027	RUB	2025-09-13 17:06:06	processing
1001	118	413	1	66.8100000000000023	EUR	2026-02-10 07:31:42	completed
973	483	359	4	96.7000000000000028	USD	2025-06-03 04:26:34	cancelled
1002	133	140	5	363.620000000000005	EUR	2025-01-20 17:41:32	processing
975	389	93	1	169.460000000000008	RUB	2024-06-13 14:02:26	processing
1004	-1	214	2	221.409999999999997	EUR	2025-05-29 20:37:07	processing
976	686	402	5	128.129999999999995	USD	2025-10-02 14:32:30	completed
1005	14	154	3	390.560000000000002	USD	2024-07-27 04:40:49	cancelled
978	-1	597	2	463.639999999999986	RUB	2024-12-12 23:59:32	completed
1007	346	-1	3	491.170000000000016	USD	2026-03-15 09:37:24	cancelled
979	30	220	5	478.04000000000002	RUB	2024-06-21 11:06:16	processing
1010	354	235	4	413.509999999999991	USD	2024-07-02 22:10:03	cancelled
980	422	600	4	401.70999999999998	RUB	2026-01-22 00:27:01	completed
1012	315	160	1	137.090000000000003	USD	2025-03-10 03:27:19	completed
983	570	475	1	249.659999999999997	RUB	2024-08-27 02:24:42	processing
1014	237	454	2	303.54000000000002	USD	2026-05-20 16:16:56	processing
986	458	585	5	225.009999999999991	USD	2025-08-30 17:12:19	completed
1016	289	163	1	177.77000000000001	EUR	2025-09-27 11:13:16	processing
988	510	532	3	77.75	RUB	2024-11-26 15:18:11	completed
1018	631	463	4	286.569999999999993	RUB	2025-06-27 13:02:53	cancelled
989	134	407	1	76.0100000000000051	EUR	2024-10-14 15:21:29	processing
1020	292	141	2	133.129999999999995	USD	2025-06-19 13:23:57	cancelled
992	358	190	3	337	EUR	2025-09-20 04:53:29	completed
1021	473	527	5	39.1099999999999994	USD	2024-06-22 03:47:55	completed
995	167	24	5	450.279999999999973	USD	2025-09-10 04:39:16	completed
1025	-1	521	1	237.090000000000003	USD	2025-02-06 01:41:22	completed
997	311	202	5	104.5	RUB	2025-02-11 07:13:23	completed
1026	419	82	4	359.180000000000007	EUR	2025-08-28 17:47:48	completed
999	118	213	2	368.560000000000002	USD	2025-03-06 14:24:30	completed
1028	117	545	5	223.199999999999989	EUR	\N	processing
1000	121	143	4	210.949999999999989	RUB	2025-04-01 13:56:00	completed
1030	124	451	2	307.410000000000025	USD	2026-04-07 08:14:51	cancelled
1003	352	-1	4	466.879999999999995	USD	2025-12-24 07:55:07	processing
1032	247	273	4	19.3000000000000007	USD	2025-11-29 23:04:13	cancelled
1006	181	538	5	344.689999999999998	RUB	2025-04-27 19:37:07	completed
1033	425	70	3	317.149999999999977	USD	2025-02-01 05:32:51	completed
1008	385	359	5	104.890000000000001	EUR	2025-12-20 08:05:31	processing
1034	52	39	4	70.9200000000000017	EUR	2025-07-08 07:45:33	completed
1009	390	583	1	404.629999999999995	USD	2024-12-26 15:19:45	processing
1037	0	305	5	28.5700000000000003	RUB	2025-04-20 09:43:45	processing
1011	122	376	3	279.350000000000023	RUB	2025-12-24 13:08:32	cancelled
1038	613	505	4	393.829999999999984	RUB	2026-05-21 15:26:19	processing
1013	145	166	4	70.3299999999999983	RUB	2026-04-08 01:02:26	cancelled
1039	230	425	5	225.120000000000005	USD	2025-02-02 20:10:39	cancelled
1015	-1	134	5	20.9699999999999989	USD	2025-08-20 20:05:12	completed
1040	618	153	4	454.95999999999998	USD	2024-11-24 09:23:05	completed
1017	647	128	3	25.870000000000001	USD	2025-12-10 17:09:32	completed
1041	497	239	4	289.800000000000011	USD	2025-02-26 07:23:26	completed
1019	434	357	1	191.740000000000009	RUB	2025-01-18 04:51:55	cancelled
1043	583	271	4	405.439999999999998	USD	2025-03-26 00:50:30	completed
1022	40	461	4	281.379999999999995	USD	2026-03-14 05:46:24	cancelled
1052	64	485	1	215.210000000000008	EUR	2025-05-12 08:19:06	processing
1023	283	558	2	217.659999999999997	USD	2024-10-22 23:41:40	completed
1053	96	307	2	196.319999999999993	USD	2025-05-07 03:49:57	processing
1024	530	-1	3	229.400000000000006	USD	2025-01-09 23:13:27	completed
1054	413	512	1	467.730000000000018	RUB	2026-03-22 13:18:44	processing
1027	295	411	3	251.099999999999994	USD	2024-11-12 08:58:56	completed
1055	605	155	4	284.25	RUB	2024-10-01 07:52:11	cancelled
1029	693	31	4	302.120000000000005	EUR	2024-07-28 10:43:18	completed
1056	-1	274	4	335.649999999999977	USD	2024-06-06 03:05:37	completed
1031	448	66	2	48.6799999999999997	RUB	2024-07-24 12:34:40	processing
1058	116	500	5	324.740000000000009	USD	2024-07-13 23:50:56	cancelled
1035	671	577	5	43.2899999999999991	RUB	2024-08-31 02:14:43	processing
1059	691	387	5	119.819999999999993	RUB	2024-11-02 06:59:33	cancelled
1036	-1	68	1	164.370000000000005	RUB	2025-02-17 00:25:49	cancelled
1060	110	47	4	99.0499999999999972	RUB	2025-01-07 20:10:37	processing
1042	331	297	5	338.170000000000016	RUB	2026-01-20 16:02:13	processing
1061	432	255	5	194.389999999999986	RUB	2024-12-15 11:07:08	processing
1044	442	53	2	22.8900000000000006	EUR	2024-07-06 03:28:28	processing
1062	272	156	3	232	EUR	2024-10-11 20:13:46	completed
1045	472	57	2	61.7899999999999991	EUR	2025-12-18 19:57:50	completed
1069	418	192	4	448.279999999999973	EUR	2026-02-01 08:15:30	completed
1046	677	86	3	56.5900000000000034	RUB	\N	completed
1070	45	23	5	56.25	EUR	2026-02-25 10:08:08	completed
1047	379	599	5	261.350000000000023	RUB	2024-08-13 02:39:28	cancelled
1072	100	29	2	351.54000000000002	EUR	2025-04-06 03:17:32	processing
1048	151	551	4	481.629999999999995	RUB	2025-03-22 04:05:06	processing
1075	555	149	4	236.25	RUB	2025-06-29 09:19:19	completed
1049	641	560	5	24.9600000000000009	USD	2024-08-26 11:26:53	cancelled
1076	279	232	5	425.420000000000016	USD	2026-01-16 08:10:48	cancelled
1050	267	535	1	231.129999999999995	EUR	2026-04-23 09:21:08	processing
1078	680	406	2	352.449999999999989	RUB	2024-12-21 18:52:52	processing
1051	239	553	5	193.159999999999997	USD	2026-04-18 23:23:18	completed
1085	389	309	5	331.470000000000027	RUB	2026-05-02 18:23:33	completed
1057	603	595	3	453.310000000000002	USD	2025-02-01 01:02:58	cancelled
1086	306	385	2	33.009999999999998	EUR	2025-07-28 22:41:45	processing
1063	0	365	1	199.110000000000014	USD	2026-01-01 14:28:01	processing
1087	281	510	5	310.560000000000002	EUR	2025-06-15 05:35:10	cancelled
1064	249	515	5	277.889999999999986	USD	2024-06-28 11:40:03	processing
1088	52	323	2	17.0300000000000011	EUR	2025-03-08 12:25:00	cancelled
1065	228	447	5	121.700000000000003	USD	2025-02-06 02:35:51	completed
1090	327	436	5	404.579999999999984	USD	2024-07-06 13:20:08	completed
1066	265	70	5	228.139999999999986	RUB	2026-04-01 03:23:13	cancelled
1091	249	-1	4	439.180000000000007	USD	2025-07-03 05:15:31	completed
1067	23	-1	3	46.1899999999999977	USD	2024-09-10 01:10:47	processing
1092	429	-1	1	204.280000000000001	EUR	2024-08-03 18:33:02	processing
1068	255	210	5	323.649999999999977	USD	2025-10-17 07:23:18	processing
1093	356	122	4	88.5300000000000011	USD	2024-07-30 15:51:34	completed
1071	369	128	3	252.840000000000003	EUR	2025-12-09 07:54:12	processing
1094	156	486	4	219.810000000000002	EUR	2024-05-27 09:02:57	cancelled
1073	427	67	4	449.319999999999993	RUB	2026-05-10 05:01:40	processing
1095	411	81	1	201.169999999999987	USD	2025-03-24 11:17:16	completed
1074	130	43	5	378.970000000000027	RUB	2024-09-06 15:57:17	processing
1096	288	258	3	456.25	RUB	2025-02-21 01:39:43	processing
1077	638	433	4	474.120000000000005	RUB	2025-10-25 14:21:31	processing
1097	530	16	1	382.639999999999986	RUB	2024-09-13 17:26:36	completed
1079	634	93	5	196.77000000000001	EUR	2025-10-31 07:18:09	cancelled
1099	82	280	3	227.599999999999994	USD	2024-08-01 23:32:52	cancelled
1080	349	139	1	64.2199999999999989	RUB	2025-01-24 14:43:20	processing
1100	139	436	3	427.839999999999975	RUB	2025-12-28 04:17:26	completed
1081	614	391	4	497.399999999999977	USD	2024-06-22 09:11:06	processing
1103	568	527	2	190.560000000000002	EUR	2025-11-01 10:33:12	completed
1082	46	64	1	217.02000000000001	RUB	2026-04-27 09:55:30	completed
1104	318	371	2	256.699999999999989	EUR	2025-01-23 18:51:03	cancelled
1083	611	255	4	111.5	EUR	2025-03-18 05:07:35	cancelled
1105	0	293	3	159.699999999999989	EUR	2025-03-24 15:30:55	processing
1084	-1	-1	5	137.349999999999994	EUR	2025-06-02 20:38:05	completed
1106	479	115	2	424.300000000000011	USD	2024-06-11 20:53:41	completed
1089	373	462	5	447.310000000000002	RUB	2024-10-21 12:53:37	cancelled
1111	487	-1	5	39.7800000000000011	USD	\N	cancelled
1098	486	131	4	358.370000000000005	RUB	2025-02-09 07:18:17	completed
1112	253	236	2	26.2699999999999996	RUB	2026-04-10 14:46:21	cancelled
1101	151	235	1	109.909999999999997	EUR	2024-10-12 23:22:19	processing
1113	-1	339	3	315.819999999999993	USD	2025-12-06 20:01:43	completed
1102	491	50	5	367.449999999999989	RUB	2025-11-19 08:12:59	cancelled
1114	0	406	1	262.199999999999989	RUB	2024-11-21 02:01:19	cancelled
1107	199	-1	4	149.879999999999995	RUB	2026-03-14 15:39:54	processing
1115	486	177	1	422.850000000000023	EUR	2025-07-22 16:25:49	cancelled
1108	-1	462	5	369.389999999999986	USD	2025-12-31 11:56:38	cancelled
1116	261	55	3	138.210000000000008	EUR	2024-06-15 00:19:50	processing
1109	408	171	3	326.079999999999984	RUB	2024-08-03 02:27:12	cancelled
1121	314	108	5	354.509999999999991	EUR	2025-05-14 00:03:38	cancelled
1110	0	174	5	274.060000000000002	RUB	2025-01-08 12:53:21	completed
1122	461	-1	2	27.8500000000000014	USD	2024-06-10 09:04:48	processing
1117	216	223	1	242.800000000000011	RUB	2024-07-23 17:33:24	cancelled
1124	461	116	5	398.25	USD	2026-04-04 03:00:49	processing
1118	-1	127	3	128.050000000000011	RUB	2025-06-04 06:25:14	completed
1125	676	216	2	472.410000000000025	RUB	2025-03-04 11:16:27	completed
1119	550	396	3	438.329999999999984	RUB	2025-11-05 13:15:38	processing
1126	530	172	5	282.949999999999989	USD	2025-08-12 17:16:34	completed
1120	582	-1	5	262.100000000000023	USD	2024-12-12 18:32:49	completed
1128	-1	521	4	66.1599999999999966	USD	2025-07-25 07:08:17	processing
1123	391	232	2	453.230000000000018	RUB	2025-11-26 01:26:07	processing
1130	86	64	4	400.45999999999998	EUR	2024-06-08 21:10:24	processing
1127	0	17	2	122.709999999999994	USD	2026-03-07 00:44:43	completed
1132	523	142	3	216.360000000000014	RUB	2025-11-30 06:25:14	completed
1129	612	12	4	360.279999999999973	USD	2024-11-11 22:13:51	processing
1134	4	187	1	233.949999999999989	EUR	2025-04-21 11:10:08	completed
1131	241	88	3	328.439999999999998	RUB	2024-07-09 02:47:20	processing
1136	77	400	1	223.599999999999994	RUB	2024-09-03 19:08:10	cancelled
1133	323	101	5	165.030000000000001	RUB	2024-09-03 09:37:09	completed
1137	276	89	4	458.910000000000025	EUR	\N	processing
1135	379	389	3	476.720000000000027	RUB	2025-02-26 21:52:54	cancelled
1140	536	430	5	382.5	EUR	2025-08-26 14:34:25	processing
1138	93	458	2	493.519999999999982	USD	2025-11-05 07:01:48	processing
1142	164	444	1	268.699999999999989	RUB	2024-07-31 21:53:17	processing
1139	332	481	5	141.740000000000009	RUB	2025-11-16 13:38:53	completed
1143	569	497	1	241.509999999999991	RUB	2025-08-04 17:46:43	processing
1141	208	-1	5	365.550000000000011	RUB	2024-09-02 05:33:05	cancelled
1144	75	465	5	220.090000000000003	EUR	2025-03-01 18:47:50	completed
1147	573	567	1	158.340000000000003	USD	2026-05-12 23:24:13	completed
1145	584	90	5	126.010000000000005	USD	2026-05-05 07:39:57	completed
1151	661	142	5	359.259999999999991	EUR	2024-10-05 06:16:14	cancelled
1146	442	535	3	232.72999999999999	RUB	2025-09-01 23:56:15	processing
1152	273	77	4	173.789999999999992	RUB	2025-02-06 04:35:34	cancelled
1148	586	344	1	394.139999999999986	EUR	2024-12-27 00:47:36	processing
1154	108	327	3	192.699999999999989	USD	2025-08-20 08:54:15	cancelled
1149	322	93	4	233.889999999999986	RUB	2025-12-08 20:59:05	processing
1156	-1	225	1	41.0499999999999972	EUR	2025-12-27 17:40:44	processing
1150	142	555	2	394.189999999999998	USD	2025-08-19 05:19:01	processing
1158	182	287	5	170.77000000000001	RUB	2024-06-16 17:58:12	completed
1153	55	273	3	363.29000000000002	EUR	2025-09-07 10:02:12	completed
1161	494	94	5	324.329999999999984	USD	2025-10-13 21:59:25	completed
1155	518	509	2	71.9000000000000057	EUR	2025-08-07 03:44:08	completed
1164	584	-1	4	44.7299999999999969	EUR	2024-06-10 19:10:40	cancelled
1157	351	286	4	94.1200000000000045	USD	2025-11-04 15:01:05	cancelled
1165	0	89	3	453.95999999999998	RUB	2024-06-19 18:38:58	processing
1159	60	269	5	99.5600000000000023	RUB	2026-04-03 19:31:19	processing
1167	535	353	5	114.540000000000006	EUR	2024-08-30 05:41:08	completed
1160	464	383	4	45.5200000000000031	RUB	2025-07-11 19:17:27	completed
1170	219	47	1	27.4100000000000001	EUR	2026-02-25 10:40:32	completed
1162	589	89	2	423.480000000000018	USD	\N	cancelled
1172	304	248	3	224.550000000000011	RUB	2024-06-19 02:27:30	cancelled
1163	191	452	1	374.5	USD	2025-07-04 16:31:03	completed
1174	440	307	2	494.970000000000027	EUR	2026-01-19 22:43:28	processing
1166	588	145	3	352.569999999999993	USD	2024-10-19 08:24:52	processing
1178	407	342	1	301.089999999999975	RUB	2025-11-18 02:52:05	cancelled
1168	610	91	1	212.580000000000013	RUB	2026-05-03 12:10:11	processing
1179	0	-1	3	368	RUB	2025-11-02 19:11:51	completed
1169	-1	552	4	109.069999999999993	EUR	2026-02-03 10:59:34	completed
1181	616	456	3	404.670000000000016	RUB	\N	processing
1171	361	71	4	118.670000000000002	USD	2025-06-21 02:53:48	cancelled
1182	399	-1	2	320.579999999999984	EUR	2024-07-10 05:33:32	cancelled
1173	156	40	3	489.720000000000027	EUR	2025-04-15 06:52:56	processing
1183	240	182	3	352.329999999999984	USD	2026-04-16 01:41:40	completed
1175	516	392	2	165.780000000000001	USD	2024-06-18 07:07:28	processing
1184	85	366	3	394.620000000000005	RUB	2024-07-12 22:59:06	completed
1176	306	457	1	172.120000000000005	USD	2024-12-01 09:59:14	cancelled
1185	11	346	1	48.6799999999999997	USD	2026-01-22 13:05:54	completed
1177	284	82	4	313.740000000000009	EUR	2024-06-06 10:47:58	cancelled
1188	454	363	4	301.529999999999973	USD	2025-09-14 22:40:29	processing
1180	240	398	1	236.719999999999999	RUB	2026-05-18 18:06:53	completed
1189	605	50	2	336.550000000000011	USD	2025-06-20 09:34:36	completed
1186	-1	-1	3	483.639999999999986	RUB	2026-05-24 07:08:36	cancelled
1190	403	13	2	485.220000000000027	RUB	2025-12-22 07:47:52	completed
1187	451	505	1	224.650000000000006	USD	2025-10-07 14:05:34	completed
1195	371	592	4	482.240000000000009	RUB	2025-08-04 02:45:44	completed
1191	-1	220	3	180.620000000000005	USD	2024-08-12 07:21:38	cancelled
1197	450	274	2	498.100000000000023	RUB	2024-10-07 02:29:27	processing
1192	47	308	3	41.5600000000000023	RUB	2024-10-12 10:06:51	processing
1198	697	296	2	334.480000000000018	RUB	2025-03-31 06:21:29	cancelled
1193	629	179	3	441.449999999999989	RUB	2026-02-07 07:43:28	processing
1199	595	503	2	20.0500000000000007	EUR	2026-04-05 13:51:16	cancelled
1194	368	151	3	346.149999999999977	EUR	2024-07-14 18:30:30	completed
1200	387	165	3	170.759999999999991	USD	2025-06-21 19:11:34	processing
1196	0	397	5	38.8100000000000023	RUB	2026-03-09 12:42:55	processing
-1	-1	-1	0	0	Unknown	\N	Unknown
\.


--
-- TOC entry 2540 (class 0 OID 49538)
-- Dependencies: 286
-- Data for Name: payments; Type: TABLE DATA; Schema: dds; Owner: gpadmin
--

COPY dds.payments (payment_id, order_id, payment_method, amount, currency, payment_timestamp) FROM stdin;
2	941	bank_transfer	407.420000000000016	USD	2024-12-15 23:01:24
1	778	bank_transfer	\N	EUR	2025-04-14 23:23:52
3	1173	paypal	1754.70000000000005	USD	2025-05-03 14:55:30
5	864	card	2366.61999999999989	EUR	2025-06-18 21:21:20
4	143	card	2372.03999999999996	RUB	2026-02-05 00:19:38
11	493	\N	519.110000000000014	RUB	2026-04-05 05:14:09
6	1139	\N	747.970000000000027	RUB	2025-02-03 15:11:50
12	290	\N	2416.23999999999978	EUR	\N
7	239	card	\N	EUR	2026-01-01 19:45:57
14	187	bank_transfer	\N	USD	2026-04-22 23:43:11
8	14	bank_transfer	1189.8900000000001	RUB	2025-05-05 22:59:37
15	388	\N	692.440000000000055	RUB	\N
9	685	\N	1016.84000000000003	EUR	2025-01-18 04:06:47
17	1174	\N	2722.57000000000016	RUB	2025-12-27 15:25:25
10	-1	\N	2574.48999999999978	EUR	2026-02-22 05:19:19
20	964	paypal	1773.84999999999991	RUB	2026-04-18 18:50:53
13	949	card	1074.08999999999992	RUB	2025-01-07 20:58:25
23	1192	\N	2937.69000000000005	USD	2025-08-20 09:24:08
16	351	card	2873.15999999999985	EUR	2025-06-15 23:48:07
25	977	paypal	306	USD	2024-10-09 08:22:51
18	218	card	32.740000000000002	RUB	2025-10-17 19:21:28
26	1100	paypal	180.840000000000003	RUB	2024-10-14 12:24:00
19	1128	card	1320.8599999999999	RUB	2026-01-24 15:22:18
30	27	paypal	50.4200000000000017	USD	2025-06-23 16:01:32
21	104	bank_transfer	2078.38000000000011	USD	2025-09-23 21:42:47
31	306	paypal	1909.45000000000005	USD	2025-12-18 04:57:11
22	443	card	1446.68000000000006	RUB	2024-07-18 23:21:20
35	-1	paypal	2953.40000000000009	EUR	2025-11-08 18:01:05
24	637	card	2415.03999999999996	RUB	2026-03-08 22:16:13
36	197	paypal	1381.61999999999989	USD	2025-06-05 04:43:10
27	319	card	2781.32999999999993	EUR	2024-06-03 07:38:28
38	152	\N	2054.26000000000022	EUR	2024-10-10 20:08:34
28	433	paypal	284.269999999999982	RUB	2025-03-20 01:06:42
40	1109	bank_transfer	2833.44999999999982	USD	2025-01-15 17:59:28
29	738	paypal	2583.55999999999995	RUB	2026-02-16 04:26:00
44	1049	\N	2107.26999999999998	EUR	2026-01-06 00:59:45
32	261	card	409.139999999999986	USD	2025-10-09 13:32:24
46	403	bank_transfer	127.810000000000002	RUB	2025-10-28 02:28:11
33	268	card	1131.32999999999993	EUR	2026-05-08 21:31:05
47	705	card	2315.23000000000002	EUR	2024-10-20 08:20:31
34	404	card	1019.69000000000005	RUB	2025-09-23 11:17:29
48	266	paypal	1948.73000000000002	EUR	2024-12-08 17:01:45
37	-1	card	2308.36000000000013	EUR	2024-07-28 14:15:10
49	606	paypal	421.379999999999995	EUR	2024-12-14 17:02:33
39	326	paypal	1146.79999999999995	USD	2025-05-15 02:28:16
50	704	bank_transfer	665	EUR	2026-04-22 22:31:10
41	167	paypal	1867.8599999999999	USD	2025-12-25 13:45:44
52	-1	card	2210.15999999999985	RUB	2025-10-15 02:47:41
42	832	bank_transfer	\N	EUR	2025-11-06 01:02:23
56	484	paypal	2669.11000000000013	USD	2024-12-08 22:08:43
43	84	\N	2527.48000000000002	USD	2025-11-20 00:26:28
57	494	card	797.009999999999991	USD	2026-01-14 10:59:05
45	522	bank_transfer	1097.77999999999997	RUB	2025-06-14 09:43:41
61	688	paypal	2142.07999999999993	EUR	2025-10-03 07:14:06
51	1052	card	2027.04999999999995	RUB	2025-01-11 10:26:59
63	131	\N	2794.96000000000004	USD	2025-06-27 03:01:10
53	638	card	1875.86999999999989	RUB	2024-07-10 20:15:09
64	585	bank_transfer	2719.7199999999998	USD	2026-03-16 09:38:30
54	412	bank_transfer	1810.33999999999992	USD	2024-06-17 00:06:44
68	566	paypal	356.269999999999982	USD	\N
55	577	\N	2664.34000000000015	USD	2025-11-20 03:29:14
69	545	paypal	1116.47000000000003	EUR	2026-04-20 18:25:06
58	1023	\N	2125.09000000000015	USD	2026-04-27 09:27:34
71	239	bank_transfer	2382.05999999999995	EUR	2025-01-06 10:44:08
59	957	\N	1134.1099999999999	RUB	2026-01-16 07:43:35
72	928	\N	2660.67000000000007	USD	2025-11-01 06:30:06
60	929	\N	1699.86999999999989	RUB	2025-08-03 09:21:52
74	1088	bank_transfer	1943.94000000000005	USD	2024-11-30 23:04:18
62	555	\N	2901.82000000000016	EUR	2026-05-05 01:49:12
76	429	bank_transfer	2750.13000000000011	RUB	2026-03-03 08:59:52
65	-1	bank_transfer	1615.75	RUB	2026-05-12 00:42:23
78	1021	card	815.840000000000032	USD	2025-03-24 04:13:47
66	-1	paypal	280.860000000000014	EUR	2024-08-02 07:40:39
79	52	\N	1501.72000000000003	EUR	2026-03-29 15:46:34
67	619	\N	2363.84999999999991	USD	2025-01-22 03:21:59
83	753	bank_transfer	2444.73999999999978	RUB	2025-11-01 12:38:56
70	543	paypal	385.170000000000016	USD	2025-03-01 02:53:57
85	655	\N	550.980000000000018	RUB	2025-02-15 00:56:17
73	38	card	1980.20000000000005	RUB	2026-05-18 04:03:38
86	-1	bank_transfer	2543.11000000000013	USD	2025-05-23 10:41:24
75	1125	\N	443.420000000000016	USD	2026-02-20 20:26:08
87	446	\N	2903.63000000000011	RUB	2024-07-09 03:52:49
77	1036	\N	852.490000000000009	EUR	2024-09-08 22:03:27
88	337	card	2422.25	USD	2025-01-06 06:40:00
80	911	\N	2628.42999999999984	EUR	2025-02-06 20:18:39
89	316	\N	382.439999999999998	USD	2026-05-07 00:05:00
81	833	paypal	413.529999999999973	USD	2025-07-02 21:33:06
91	722	paypal	1045.02999999999997	USD	2024-08-31 03:52:43
82	96	bank_transfer	1414.73000000000002	USD	2026-04-26 15:25:23
95	717	card	405.019999999999982	EUR	2025-04-23 23:47:18
84	312	\N	1567.04999999999995	RUB	2024-09-22 21:58:55
96	941	card	1203.34999999999991	RUB	2024-09-10 05:45:15
90	1179	\N	2721.32000000000016	USD	2025-01-07 01:34:02
98	320	\N	1155.77999999999997	USD	2024-08-28 02:33:07
92	907	paypal	462.110000000000014	RUB	2025-04-18 20:02:47
105	1160	paypal	2991.4699999999998	RUB	2025-01-19 17:34:16
93	357	card	1855.52999999999997	EUR	2025-08-14 09:54:38
106	378	paypal	2450.75	RUB	2025-02-17 02:57:11
94	455	bank_transfer	1103.5	USD	2024-12-23 18:22:35
107	-1	bank_transfer	2875.90000000000009	USD	2025-12-21 20:03:34
97	248	paypal	578.559999999999945	USD	2025-04-26 21:24:40
111	664	paypal	2850.34000000000015	USD	2026-03-10 15:59:42
99	1134	paypal	1075.57999999999993	RUB	2025-05-30 06:15:36
114	976	card	1108.81999999999994	EUR	2024-11-02 05:37:40
100	184	\N	2039.75999999999999	RUB	2026-01-19 07:26:45
116	159	bank_transfer	277.699999999999989	EUR	2025-07-26 12:23:57
101	537	bank_transfer	2385.38999999999987	EUR	2024-08-27 23:41:32
119	38	bank_transfer	199.389999999999986	USD	2025-11-10 23:54:22
102	269	paypal	1445.8599999999999	USD	2024-08-21 17:56:48
121	151	paypal	425.149999999999977	RUB	2025-10-25 12:11:16
103	313	paypal	2939.44000000000005	USD	2026-03-11 12:31:32
122	-1	\N	746.080000000000041	EUR	2025-01-23 14:06:26
104	-1	bank_transfer	2760.53999999999996	EUR	2024-09-19 00:34:28
123	1160	\N	1605.29999999999995	USD	2026-03-08 07:57:27
108	981	paypal	1127.33999999999992	USD	2026-04-26 04:10:48
124	474	card	241.099999999999994	RUB	2024-10-25 16:35:25
109	813	\N	2568.15000000000009	EUR	2026-01-16 18:03:29
125	798	card	2955.57000000000016	EUR	2025-03-29 21:12:47
110	646	paypal	331.529999999999973	RUB	2025-03-10 18:25:03
128	674	bank_transfer	363.560000000000002	USD	2024-09-04 23:57:32
112	358	\N	2667.67000000000007	RUB	2025-01-29 08:06:20
132	983	card	1697.8599999999999	RUB	2025-08-20 21:10:37
113	470	\N	190.849999999999994	RUB	2026-01-24 08:23:56
134	822	bank_transfer	941.379999999999995	RUB	2025-07-12 14:51:33
115	-1	card	968.889999999999986	EUR	2024-12-04 18:10:32
135	183	\N	1354.51999999999998	USD	2026-01-22 00:38:43
117	188	\N	\N	RUB	2025-03-09 23:15:50
136	70	bank_transfer	1169.25999999999999	EUR	2024-09-12 11:05:51
118	1018	bank_transfer	2954.59999999999991	USD	2025-01-04 02:53:17
137	452	\N	118.420000000000002	USD	2025-01-15 22:32:55
120	-1	\N	1315.09999999999991	USD	\N
138	1158	\N	132.150000000000006	RUB	2025-07-05 08:20:47
126	1096	\N	2878.25	RUB	2025-11-10 10:03:20
144	891	paypal	1192.53999999999996	EUR	2025-06-01 23:44:30
127	426	bank_transfer	1643.20000000000005	USD	2026-01-23 16:42:21
148	584	paypal	2835.34999999999991	RUB	2024-08-18 04:52:31
129	1185	bank_transfer	112.010000000000005	USD	2025-08-23 18:18:34
149	1077	paypal	2645.13000000000011	USD	2025-01-05 04:27:18
130	-1	card	714.860000000000014	EUR	2025-12-13 16:01:58
150	263	\N	689.100000000000023	RUB	2024-11-09 20:20:03
131	775	bank_transfer	2529.65000000000009	EUR	2024-06-02 14:21:44
152	1170	\N	762.549999999999955	USD	\N
133	951	\N	168.830000000000013	EUR	2025-01-18 18:29:37
154	588	\N	918.049999999999955	EUR	2025-02-04 00:41:20
139	1159	bank_transfer	575.690000000000055	USD	2025-11-12 06:33:14
155	258	card	1023.29999999999995	USD	2024-06-13 09:49:06
140	102	bank_transfer	1716.53999999999996	RUB	2025-07-01 09:27:35
157	57	paypal	462.180000000000007	RUB	2026-05-20 02:52:51
141	226	paypal	\N	RUB	2025-04-25 04:13:36
158	418	\N	2626.42999999999984	EUR	2025-07-01 22:22:58
142	614	paypal	500.079999999999984	USD	2024-07-26 23:44:28
159	-1	\N	2578.25	USD	2025-07-11 03:01:04
143	-1	bank_transfer	2562.90999999999985	RUB	2024-08-05 22:08:15
160	966	card	1005.69000000000005	RUB	2025-11-15 14:06:24
145	599	paypal	2917.67999999999984	EUR	2024-09-29 15:42:23
161	1175	paypal	2820.96000000000004	USD	2025-09-16 18:56:55
146	626	card	2132.92999999999984	EUR	2025-03-20 16:24:24
162	532	bank_transfer	798.049999999999955	EUR	2024-11-09 13:38:20
147	-1	paypal	1716.76999999999998	RUB	2025-03-18 02:46:58
166	39	bank_transfer	565.669999999999959	USD	2025-06-19 18:02:25
151	1092	bank_transfer	2806.82999999999993	USD	2024-06-06 09:13:54
167	812	card	1996.58999999999992	USD	2024-10-25 07:29:03
153	89	\N	202.389999999999986	EUR	2025-11-27 06:34:52
168	643	paypal	1665.46000000000004	RUB	2025-01-12 12:27:02
156	624	\N	50.2800000000000011	USD	2025-04-09 00:35:26
169	103	paypal	2583.86000000000013	RUB	2025-08-21 08:42:01
163	1111	bank_transfer	1175.90000000000009	USD	2025-04-08 00:31:01
170	586	card	287.220000000000027	EUR	2025-11-21 04:53:16
164	835	paypal	2657.34999999999991	RUB	2026-04-21 04:50:10
171	653	card	805.220000000000027	USD	2025-01-30 22:32:35
165	635	\N	2227.76999999999998	EUR	2025-10-28 19:56:57
172	97	paypal	700.580000000000041	USD	2024-08-08 12:51:52
176	221	paypal	68.4000000000000057	USD	2024-10-24 07:15:22
173	801	bank_transfer	2448.90000000000009	USD	2025-09-22 00:32:14
177	520	\N	2635.88999999999987	EUR	2026-01-27 09:09:28
174	327	paypal	1356.40000000000009	USD	2025-02-20 10:29:14
180	117	paypal	1837.68000000000006	EUR	2025-12-08 08:43:56
175	479	card	417.759999999999991	USD	2025-07-05 03:30:58
182	350	paypal	1753.52999999999997	USD	2025-05-16 21:56:16
178	877	\N	1334.09999999999991	EUR	2026-03-01 01:12:12
183	270	card	666.019999999999982	USD	2025-06-17 12:41:16
179	291	\N	\N	RUB	2025-05-17 15:12:18
185	272	bank_transfer	1373.56999999999994	USD	2025-08-12 14:10:03
181	355	paypal	1932.43000000000006	RUB	2024-11-09 12:11:52
187	209	\N	2651.63000000000011	RUB	2025-09-08 20:13:05
184	1191	card	1629.75	USD	2025-12-06 06:17:59
190	903	paypal	1092.08999999999992	RUB	2025-08-16 12:34:43
186	848	bank_transfer	2645.61999999999989	RUB	2024-11-21 09:01:49
192	703	\N	963.639999999999986	EUR	2025-09-21 20:25:20
188	848	card	1915.47000000000003	RUB	2024-09-05 20:37:21
193	1039	paypal	2279.57999999999993	USD	2026-01-18 02:36:55
189	541	card	2364.25	EUR	2024-11-09 11:15:54
195	1088	\N	407.370000000000005	RUB	2024-08-11 00:02:27
191	132	paypal	1418.09999999999991	USD	2026-03-26 14:26:05
197	152	\N	1850.28999999999996	USD	2025-12-06 02:07:11
194	157	paypal	1466.69000000000005	USD	2024-08-31 06:16:55
198	-1	paypal	2591.59999999999991	RUB	2025-11-23 06:39:12
196	1133	\N	145.050000000000011	RUB	2025-03-31 20:10:54
203	657	bank_transfer	450.139999999999986	RUB	2025-04-30 11:45:19
199	-1	bank_transfer	470.129999999999995	RUB	2025-11-26 19:41:56
205	603	bank_transfer	1627.94000000000005	EUR	2025-11-05 23:54:16
200	225	\N	1077.77999999999997	USD	2024-10-05 03:16:24
207	952	card	1805.68000000000006	USD	\N
201	795	bank_transfer	534.539999999999964	USD	2025-12-19 23:25:09
209	918	\N	1843.99000000000001	EUR	2024-10-06 20:47:27
202	739	bank_transfer	676.529999999999973	USD	2024-07-07 13:56:12
211	478	bank_transfer	2843.92999999999984	USD	2024-08-28 23:31:29
204	400	card	2639.63000000000011	RUB	2024-11-28 17:05:29
215	841	paypal	1785.74000000000001	USD	2025-01-14 13:39:58
206	1063	\N	2634.07999999999993	RUB	2025-01-02 00:16:44
218	369	card	2483.4699999999998	EUR	2025-12-14 09:26:01
208	1040	bank_transfer	50.7700000000000031	USD	2025-11-07 18:48:22
219	1054	card	1143.41000000000008	RUB	2026-04-30 12:33:45
210	-1	paypal	1879.25999999999999	USD	2025-10-24 10:35:08
223	607	card	2850.2800000000002	RUB	2024-08-18 22:43:56
212	350	paypal	1368	EUR	2024-09-18 15:01:42
224	855	\N	1130.01999999999998	EUR	2024-07-31 01:53:30
213	818	bank_transfer	\N	RUB	2024-05-27 10:00:18
225	225	bank_transfer	\N	EUR	2025-08-31 18:13:59
214	756	paypal	269.470000000000027	USD	2025-10-25 05:38:47
229	818	bank_transfer	2880.09000000000015	RUB	2026-05-17 15:36:52
216	1192	\N	471.870000000000005	USD	2025-05-11 06:32:30
230	607	paypal	373.879999999999995	USD	2024-07-31 11:09:59
217	316	\N	1318.96000000000004	USD	2024-10-16 00:03:48
233	231	bank_transfer	1842.97000000000003	RUB	2025-08-10 00:27:44
220	220	paypal	2013.08999999999992	RUB	2024-11-25 10:42:17
236	408	card	2078.15000000000009	RUB	2024-07-25 16:23:36
221	1176	paypal	1624.16000000000008	RUB	2024-12-12 20:14:11
237	865	\N	1657.67000000000007	USD	2024-11-25 00:31:31
222	363	paypal	2569.51000000000022	USD	2025-01-10 00:09:54
239	397	\N	2810.01000000000022	USD	2024-06-02 01:50:02
226	626	paypal	1677.69000000000005	RUB	2025-07-18 19:49:55
241	4	bank_transfer	747.92999999999995	RUB	2026-05-06 22:57:52
227	1030	\N	22.8599999999999994	EUR	2026-04-26 03:22:46
244	894	paypal	2098.57000000000016	USD	2026-01-20 16:02:24
228	1067	bank_transfer	1922.07999999999993	RUB	2025-09-29 06:17:48
246	991	\N	2373.01999999999998	RUB	2025-01-17 01:21:42
231	297	paypal	1839.32999999999993	USD	2025-04-22 04:33:59
247	-1	\N	268.240000000000009	USD	2026-02-08 01:50:24
232	94	bank_transfer	\N	USD	2024-07-11 14:46:17
251	130	\N	2695.17999999999984	EUR	2026-04-22 13:47:33
234	230	card	1467.07999999999993	EUR	2026-03-10 21:13:58
252	41	\N	2130.57999999999993	EUR	2025-04-13 10:18:06
235	833	bank_transfer	2590.84999999999991	RUB	2025-07-12 00:55:26
256	1031	card	1344.8900000000001	EUR	2025-02-10 19:48:45
238	128	card	2217.75	EUR	2025-08-17 03:15:04
257	506	bank_transfer	2910.40999999999985	EUR	2024-11-18 15:32:51
240	669	paypal	\N	EUR	2024-11-25 16:21:53
258	309	\N	1989.00999999999999	EUR	2024-08-12 16:09:29
242	-1	paypal	2073.55999999999995	RUB	2024-10-30 20:55:28
260	663	\N	2612.23999999999978	USD	2024-09-08 06:16:10
243	924	\N	2339.48999999999978	RUB	2025-08-26 00:00:36
261	333	bank_transfer	937.980000000000018	EUR	2024-11-30 04:50:10
245	1028	\N	548.389999999999986	RUB	2024-10-05 13:55:20
262	19	\N	686.080000000000041	RUB	2025-12-09 23:01:37
248	625	card	1205	USD	2026-03-30 16:55:17
263	47	\N	907.629999999999995	EUR	2025-02-28 03:48:29
249	322	paypal	2919.98000000000002	USD	2025-08-18 02:22:51
266	1020	bank_transfer	2349.90000000000009	RUB	2025-09-09 15:29:12
250	1041	paypal	2156.34999999999991	EUR	2025-09-25 04:13:57
267	831	bank_transfer	1068.78999999999996	USD	2025-03-28 01:16:41
253	-1	bank_transfer	1489.16000000000008	RUB	2025-07-03 21:34:22
270	219	\N	1208.02999999999997	EUR	2026-01-25 20:35:17
254	1071	card	517.799999999999955	RUB	2026-03-31 15:44:34
272	21	bank_transfer	516.659999999999968	USD	2025-01-18 06:33:41
255	261	\N	2443.38999999999987	RUB	2026-05-14 00:05:51
274	126	card	136.469999999999999	RUB	2026-02-05 20:18:16
259	788	paypal	1118.54999999999995	RUB	2024-11-06 00:02:46
275	1066	card	553.840000000000032	USD	2024-11-23 10:33:59
264	867	bank_transfer	1889.66000000000008	USD	2025-10-20 02:47:56
279	759	card	63.4200000000000017	USD	2026-05-01 16:58:24
265	45	card	2298.11999999999989	RUB	2025-06-25 17:51:25
282	1158	paypal	1174.46000000000004	EUR	2026-01-16 11:55:39
268	1033	bank_transfer	2861.75	USD	2026-01-28 19:18:10
285	72	card	1426.86999999999989	USD	2026-04-18 22:27:47
269	1063	bank_transfer	1244.6400000000001	USD	2024-08-24 16:53:00
286	252	card	1900.45000000000005	USD	2026-05-08 16:04:07
271	648	card	2333.69000000000005	RUB	2025-12-02 18:06:19
287	517	paypal	828.720000000000027	RUB	2025-08-01 05:05:57
273	817	paypal	372.439999999999998	EUR	2025-11-08 09:45:15
288	703	\N	1794.00999999999999	RUB	2025-05-09 13:03:36
276	390	card	21.620000000000001	EUR	2026-02-15 08:12:53
290	663	bank_transfer	1145.93000000000006	RUB	2025-06-17 06:39:04
277	486	\N	1457.75	EUR	2026-01-23 15:23:47
291	872	paypal	1800.11999999999989	USD	2024-06-17 00:43:25
278	712	\N	2503.55000000000018	USD	2024-08-24 22:08:31
294	591	bank_transfer	935.759999999999991	EUR	2024-12-27 11:18:36
280	800	\N	21.879999999999999	USD	2025-03-10 16:20:49
295	198	paypal	1799.92000000000007	RUB	2024-08-09 18:34:18
281	417	card	1784.68000000000006	EUR	2024-12-24 06:53:40
296	281	bank_transfer	\N	EUR	2026-01-01 13:04:22
283	603	\N	2936.67000000000007	EUR	2025-05-25 08:21:25
298	188	card	2228.25	RUB	2025-08-08 15:09:20
284	40	card	1717.05999999999995	RUB	2026-03-21 02:51:44
299	294	\N	2341.82000000000016	EUR	2025-06-10 20:34:27
289	338	bank_transfer	2709.11000000000013	USD	2024-09-16 09:32:36
301	1135	bank_transfer	1052.58999999999992	USD	2024-10-03 14:36:47
292	680	paypal	2818.03999999999996	USD	2025-03-27 11:22:04
304	689	card	1117.36999999999989	RUB	2025-02-18 20:40:36
293	61	bank_transfer	2796.9699999999998	EUR	2026-03-24 23:33:10
308	1170	\N	374.870000000000005	USD	2026-02-17 19:06:12
297	-1	card	2191.38999999999987	USD	2025-09-14 13:56:45
309	76	bank_transfer	794.669999999999959	USD	2024-12-04 03:07:55
300	1118	paypal	488.019999999999982	RUB	2025-05-25 17:55:57
310	256	paypal	1475.22000000000003	EUR	2025-09-13 04:32:01
302	710	paypal	559.220000000000027	RUB	2024-06-05 20:46:11
311	491	paypal	267.769999999999982	EUR	2025-05-04 13:52:10
303	1029	bank_transfer	2580.4699999999998	EUR	2025-11-17 06:02:02
312	359	card	2810.28999999999996	EUR	2025-10-14 21:01:49
305	190	bank_transfer	2558	EUR	2026-03-14 12:59:03
315	436	bank_transfer	2080.69999999999982	RUB	2026-02-25 13:44:19
306	750	paypal	1373.24000000000001	EUR	2024-09-01 13:22:22
319	-1	card	1149.11999999999989	EUR	2026-02-23 21:48:45
307	606	card	2321.67999999999984	EUR	2025-01-07 19:36:48
320	-1	bank_transfer	688.960000000000036	EUR	2026-01-23 12:47:16
313	20	bank_transfer	2387.32000000000016	RUB	2026-05-11 10:23:56
322	76	card	1770.86999999999989	USD	2024-12-21 20:23:03
314	372	card	1315.69000000000005	EUR	2026-01-12 19:20:42
325	1070	bank_transfer	2118.73000000000002	EUR	2025-01-09 11:50:36
316	103	card	694.75	RUB	2024-10-07 06:51:16
326	1054	bank_transfer	527.200000000000045	RUB	2025-03-28 23:39:11
317	980	paypal	1702.27999999999997	EUR	2026-03-14 22:40:09
329	1062	card	2135.73999999999978	RUB	2024-07-06 21:31:24
318	982	\N	852.059999999999945	RUB	2025-12-01 08:41:52
331	-1	card	1625.66000000000008	USD	2024-11-04 05:43:57
321	700	card	1894.73000000000002	RUB	2026-04-21 07:13:14
333	613	bank_transfer	62.8800000000000026	EUR	2025-11-16 04:39:25
323	1183	card	1606.15000000000009	RUB	2025-05-03 07:59:20
334	423	\N	2436.44000000000005	EUR	2025-03-05 12:36:52
324	698	paypal	2719.63999999999987	USD	2025-03-26 06:24:35
335	1072	card	2286.44000000000005	USD	2024-07-10 09:13:41
327	938	bank_transfer	2258.23000000000002	EUR	2025-05-02 16:59:28
338	24	card	257.759999999999991	RUB	2025-12-01 07:02:13
328	1005	bank_transfer	528.67999999999995	RUB	2025-11-15 19:47:38
341	184	bank_transfer	1763.90000000000009	RUB	2025-12-02 07:17:35
330	1196	\N	173	RUB	2024-11-28 03:17:01
344	1091	paypal	738.57000000000005	RUB	\N
332	926	card	911.730000000000018	EUR	2026-02-14 09:42:31
345	646	bank_transfer	2954.57999999999993	USD	2024-07-21 16:02:13
336	1082	bank_transfer	563.029999999999973	EUR	2024-09-09 03:33:01
346	1088	bank_transfer	745.17999999999995	RUB	2025-04-18 08:56:24
337	504	\N	2549.78999999999996	RUB	2025-10-21 14:50:39
348	945	paypal	201.77000000000001	EUR	2026-04-15 04:07:19
339	1174	paypal	2388.88000000000011	USD	2024-07-07 06:57:57
350	162	paypal	1149.75999999999999	RUB	2026-01-22 23:59:52
340	303	\N	1346.98000000000002	EUR	2025-08-15 01:40:19
352	-1	bank_transfer	741.139999999999986	RUB	2026-03-09 17:19:16
342	952	card	1523.69000000000005	RUB	2025-07-04 06:41:09
354	177	bank_transfer	1905.95000000000005	EUR	2025-09-24 05:19:16
343	249	card	968.879999999999995	RUB	2025-07-25 17:45:02
355	381	bank_transfer	2464.82999999999993	EUR	2025-12-15 09:50:09
347	88	bank_transfer	2396.84999999999991	EUR	2026-05-09 17:38:47
356	505	\N	2373.76000000000022	RUB	2024-09-26 10:59:25
349	1088	\N	227.639999999999986	USD	2026-04-04 14:29:32
358	-1	\N	561.5	RUB	2026-01-20 19:40:20
351	503	paypal	1059.05999999999995	EUR	2025-11-04 02:25:38
360	845	card	264.980000000000018	USD	2024-07-24 05:44:50
353	882	card	978.840000000000032	EUR	2025-12-25 11:55:43
361	663	paypal	2682.03999999999996	EUR	2025-01-27 13:29:05
357	492	\N	1848.05999999999995	EUR	2025-01-05 09:34:57
362	839	bank_transfer	1615.52999999999997	USD	2025-11-17 07:35:15
359	605	paypal	\N	RUB	2025-05-04 22:33:29
363	1148	card	2926.42999999999984	USD	2025-12-01 22:22:30
365	210	bank_transfer	1278.22000000000003	RUB	2024-11-27 09:33:54
364	997	\N	1481.44000000000005	USD	2026-02-08 01:12:21
368	-1	card	1495.99000000000001	RUB	2024-06-03 23:09:51
366	1186	paypal	792.309999999999945	RUB	2024-06-26 18:18:51
372	1133	card	2667.0300000000002	USD	2025-05-24 01:15:14
367	844	card	964.629999999999995	EUR	2025-05-07 07:39:55
375	1049	paypal	1654.16000000000008	RUB	2025-06-02 19:12:47
369	570	\N	537.629999999999995	EUR	2026-02-14 11:15:52
376	921	card	717.42999999999995	EUR	2026-01-07 12:29:15
370	486	bank_transfer	2616.07999999999993	RUB	2025-11-23 00:09:59
377	-1	card	300.990000000000009	EUR	2025-04-10 21:28:14
371	253	\N	2250.88000000000011	EUR	2024-12-03 22:25:08
378	48	paypal	595.139999999999986	RUB	2025-05-17 22:46:34
373	72	paypal	2277.5300000000002	EUR	2025-06-17 08:14:33
380	477	card	222.099999999999994	RUB	2025-10-12 13:02:54
374	134	\N	2842.38999999999987	USD	2025-05-26 13:17:44
382	1014	bank_transfer	2278.73000000000002	USD	2026-03-02 07:48:16
379	342	card	400.589999999999975	EUR	2026-02-03 20:11:46
384	-1	paypal	1871.72000000000003	USD	2025-02-03 19:21:51
381	275	card	123.849999999999994	EUR	2025-06-02 13:08:53
385	-1	\N	2256.94999999999982	USD	2024-08-12 12:42:45
383	492	card	1703.77999999999997	USD	2026-04-28 15:04:42
386	1177	\N	2238.34000000000015	USD	2024-12-12 18:58:37
389	73	paypal	317.04000000000002	EUR	2026-03-17 06:25:49
387	612	paypal	566.330000000000041	USD	2025-04-29 20:47:24
390	441	card	1160.05999999999995	EUR	2025-10-05 00:36:02
388	439	paypal	883.049999999999955	EUR	2024-10-11 16:58:02
391	348	card	55.759999999999998	USD	2025-03-17 04:31:13
392	485	\N	2341.5300000000002	EUR	2024-12-20 19:57:33
393	839	card	2169.90000000000009	USD	2026-03-12 17:31:47
396	71	\N	664.240000000000009	USD	2025-04-10 00:59:11
394	123	card	1030.1099999999999	EUR	2025-02-01 23:27:24
398	1016	paypal	1537.75999999999999	USD	2024-12-01 17:17:20
395	26	card	745.32000000000005	EUR	2025-09-22 10:19:47
399	573	\N	377.449999999999989	USD	2024-07-22 08:56:54
397	780	card	497.54000000000002	RUB	2024-06-06 20:26:42
400	141	\N	2996.40000000000009	USD	2025-04-11 20:59:11
403	371	paypal	296.670000000000016	RUB	2025-01-10 20:46:45
401	297	paypal	1375.26999999999998	EUR	2025-01-27 18:02:47
404	35	bank_transfer	824.240000000000009	EUR	2024-09-04 04:55:54
402	377	bank_transfer	893.539999999999964	USD	2024-09-27 07:52:44
406	-1	bank_transfer	87.3599999999999994	EUR	2024-09-12 16:37:49
405	370	\N	2230.88999999999987	RUB	2025-04-14 17:08:18
410	655	card	411.610000000000014	USD	2025-02-12 11:28:37
407	162	\N	301.230000000000018	RUB	2026-05-22 06:06:58
412	1053	\N	1447.32999999999993	USD	2026-01-01 09:57:40
408	275	bank_transfer	2458.65999999999985	EUR	2026-04-14 01:43:11
414	898	card	1379.44000000000005	RUB	2024-08-18 17:02:22
409	230	\N	2484.94000000000005	USD	2026-05-20 18:52:21
415	1162	paypal	346.420000000000016	USD	2025-01-04 16:24:10
411	585	\N	2420.15999999999985	EUR	2025-03-21 21:37:52
416	1084	paypal	1322.80999999999995	EUR	2026-04-30 16:57:11
413	20	bank_transfer	657.399999999999977	EUR	2025-10-24 05:51:56
418	920	card	850.240000000000009	RUB	2024-06-12 19:43:40
417	405	bank_transfer	1831.63000000000011	USD	2026-02-17 10:08:14
421	304	card	613.919999999999959	EUR	2025-04-28 13:24:05
419	841	bank_transfer	490.009999999999991	EUR	2026-03-31 07:13:19
422	447	card	\N	USD	2024-09-21 15:00:18
420	345	card	1306.45000000000005	USD	2025-11-14 21:03:45
424	1058	card	733.029999999999973	USD	\N
423	598	\N	81.4500000000000028	EUR	2025-04-12 10:49:31
425	1188	card	771.330000000000041	EUR	\N
427	1192	\N	1493.52999999999997	RUB	2025-10-29 22:32:59
426	482	paypal	1711.79999999999995	RUB	2025-12-16 17:06:38
430	48	bank_transfer	2999.92999999999984	RUB	2024-09-21 01:19:30
428	690	bank_transfer	2154.76000000000022	RUB	\N
431	501	\N	672.970000000000027	USD	2025-03-29 08:21:21
429	1122	\N	2967.19999999999982	EUR	2024-06-11 02:30:57
432	190	bank_transfer	2790.11999999999989	RUB	2025-05-31 02:22:39
435	842	card	626.289999999999964	EUR	2025-10-05 16:14:27
433	633	paypal	792.230000000000018	USD	2026-05-07 13:09:50
436	513	bank_transfer	978.519999999999982	RUB	2025-08-29 01:35:33
434	25	card	583.559999999999945	EUR	2025-03-19 01:12:53
437	905	paypal	2673.90000000000009	RUB	2025-04-01 22:26:59
440	592	card	683.029999999999973	USD	2026-02-20 22:48:57
438	33	paypal	179.930000000000007	RUB	2025-05-24 11:56:33
441	710	card	2883.69999999999982	EUR	2026-03-28 15:45:22
439	312	paypal	2314.57000000000016	RUB	2025-06-03 09:32:55
442	466	bank_transfer	801	RUB	2024-10-21 03:09:24
444	194	paypal	71.8400000000000034	RUB	2026-04-22 09:29:26
443	456	bank_transfer	2913.40000000000009	EUR	2024-07-08 08:24:05
446	1157	card	546.529999999999973	EUR	2025-06-25 05:34:52
445	858	card	2109.63000000000011	RUB	2025-06-05 00:02:49
447	65	card	2003.3599999999999	EUR	2025-04-03 23:21:27
448	837	card	1812.80999999999995	USD	2024-12-05 19:54:45
449	939	card	274.050000000000011	USD	2024-11-28 09:51:21
450	411	paypal	287.399999999999977	RUB	2025-09-17 07:04:03
452	767	card	107.510000000000005	EUR	2024-09-15 18:23:53
451	719	card	2210.32000000000016	USD	2026-01-11 04:04:17
455	785	card	1268.50999999999999	USD	2025-07-19 13:34:44
453	530	bank_transfer	2211.57999999999993	EUR	2024-11-22 11:15:13
456	1023	paypal	1873.68000000000006	RUB	\N
454	364	paypal	2181.71000000000004	EUR	2025-08-13 21:25:43
457	717	\N	941.200000000000045	USD	2024-11-11 08:54:41
463	970	\N	2571.65000000000009	USD	2026-04-24 13:22:57
458	651	card	1483.68000000000006	RUB	2026-04-07 12:45:24
467	775	paypal	179.870000000000005	USD	2025-04-20 10:17:19
459	376	\N	2044.57999999999993	EUR	2024-06-10 18:58:23
468	518	bank_transfer	469.430000000000007	USD	2024-12-19 18:12:54
460	794	bank_transfer	2960.86000000000013	RUB	2024-10-26 02:43:07
472	-1	bank_transfer	1298.51999999999998	RUB	2025-09-27 08:35:49
461	566	card	2353.84999999999991	RUB	2024-10-27 22:43:03
474	830	bank_transfer	2408.07999999999993	USD	2026-03-01 23:49:19
462	1118	\N	2640.38000000000011	RUB	2025-06-06 21:19:26
477	823	card	575.730000000000018	EUR	2026-02-19 20:43:04
464	741	card	1993.93000000000006	USD	2025-11-12 13:18:02
478	491	\N	1841.68000000000006	USD	2026-04-05 19:26:56
465	622	\N	1250.08999999999992	EUR	2026-02-25 13:44:11
480	216	\N	623.850000000000023	RUB	2025-06-02 02:43:59
466	557	paypal	2921.19000000000005	EUR	2026-01-03 08:13:47
481	102	card	2487.65000000000009	USD	2025-07-07 02:53:37
469	819	bank_transfer	1083.6099999999999	EUR	2025-11-23 06:40:59
483	203	\N	737.289999999999964	RUB	2024-07-29 08:06:35
470	-1	\N	1935.59999999999991	USD	2024-10-18 17:34:22
488	968	paypal	1026.33999999999992	RUB	2024-08-15 16:31:12
471	511	card	1649.17000000000007	RUB	2025-01-06 10:30:25
489	8	\N	1594.88000000000011	USD	2025-04-22 12:41:48
473	133	bank_transfer	2625.80999999999995	RUB	2024-06-30 22:05:07
492	416	\N	1420.54999999999995	EUR	2024-08-13 00:12:28
475	90	paypal	1055	USD	2025-11-25 04:34:32
496	348	bank_transfer	1407.25999999999999	RUB	2026-03-20 05:34:03
476	572	card	499.769999999999982	RUB	2024-10-08 20:10:56
497	437	\N	2607.01999999999998	USD	2024-09-22 04:19:08
479	789	card	319.430000000000007	USD	2025-09-13 00:37:18
499	934	bank_transfer	2013.28999999999996	EUR	2025-06-10 01:17:50
482	610	\N	2426.61000000000013	USD	\N
503	405	bank_transfer	236.639999999999986	USD	\N
484	-1	\N	1673.23000000000002	USD	2024-06-12 01:45:23
504	529	paypal	2938.09000000000015	EUR	2025-04-16 18:30:07
485	-1	card	2286.4699999999998	RUB	2025-05-22 23:24:42
507	-1	card	50.4500000000000028	USD	2024-12-25 14:48:31
486	956	bank_transfer	1531.82999999999993	EUR	2025-10-17 00:54:16
510	-1	bank_transfer	886.590000000000032	USD	2024-08-26 08:28:35
487	897	bank_transfer	2765.36999999999989	USD	2025-11-15 04:44:47
511	35	card	943.379999999999995	EUR	\N
490	465	\N	2342.57999999999993	USD	2026-04-05 00:19:48
517	94	\N	1099.59999999999991	USD	2024-10-07 16:24:37
491	1049	card	2837.57000000000016	RUB	2024-07-24 13:05:18
518	600	\N	696.710000000000036	RUB	2025-03-07 13:05:27
493	994	bank_transfer	1453.74000000000001	USD	2025-11-27 14:12:27
521	540	\N	2484.19000000000005	RUB	2026-03-10 08:26:29
494	218	card	140.150000000000006	USD	2025-01-18 02:25:43
523	33	paypal	1470.28999999999996	EUR	2024-12-28 19:10:30
495	1125	bank_transfer	2398.84000000000015	EUR	2025-08-19 07:05:42
527	854	\N	1558.25999999999999	EUR	2024-06-09 16:21:30
498	78	\N	503.560000000000002	RUB	2025-06-20 10:18:35
528	424	paypal	425.600000000000023	EUR	2025-09-26 03:29:47
500	731	card	\N	EUR	2025-06-17 10:28:20
529	693	paypal	2837.86999999999989	RUB	2025-12-05 23:45:41
501	747	paypal	1866.83999999999992	USD	2025-11-30 12:00:31
532	540	\N	175.310000000000002	RUB	2026-01-19 03:26:02
502	611	paypal	979.129999999999995	EUR	2025-07-11 19:23:07
534	-1	paypal	37.9600000000000009	EUR	2025-10-08 08:25:38
505	-1	paypal	2548.63000000000011	RUB	2026-02-08 02:24:25
536	659	\N	2855.59999999999991	EUR	2024-06-05 15:47:57
506	136	paypal	428.120000000000005	USD	2026-03-18 04:45:51
538	158	card	1030.22000000000003	USD	2025-11-02 22:14:28
508	755	card	962.850000000000023	EUR	2025-05-17 12:52:05
540	423	paypal	2583.73000000000002	USD	2025-06-11 00:04:45
509	1127	\N	1439.28999999999996	RUB	2025-06-25 19:35:35
542	1004	\N	2289.5	RUB	2025-06-19 02:54:01
512	319	\N	2738.01000000000022	RUB	2025-09-17 15:03:42
544	550	\N	1858.02999999999997	RUB	2024-09-29 01:45:44
513	251	bank_transfer	2464.38000000000011	EUR	2025-10-25 05:06:43
545	213	\N	1669.30999999999995	RUB	2025-12-18 23:10:47
514	228	paypal	755.409999999999968	RUB	2025-04-28 02:59:42
546	384	card	43.4299999999999997	USD	2024-05-26 13:10:27
515	675	card	2315.88000000000011	USD	2024-05-27 22:04:56
547	1126	card	2245.69000000000005	USD	2025-07-29 08:00:34
516	1038	card	717.950000000000045	EUR	2025-11-12 07:50:30
549	147	\N	2489.90000000000009	EUR	2024-06-11 05:18:55
519	948	\N	2530.88000000000011	USD	2025-06-22 18:34:15
551	23	card	1348.02999999999997	EUR	2025-09-21 11:23:04
520	944	paypal	129.300000000000011	USD	2025-07-19 21:10:23
552	940	paypal	1758.24000000000001	EUR	2025-08-24 16:25:15
522	126	paypal	2984.82999999999993	USD	2026-04-27 07:30:25
553	232	\N	2752.11999999999989	USD	2024-12-12 15:12:54
524	665	\N	903.590000000000032	RUB	2024-07-25 02:52:48
554	495	card	1698.33999999999992	RUB	2024-06-27 01:44:16
525	681	bank_transfer	559.580000000000041	EUR	2026-04-05 02:38:56
557	261	\N	2102.65999999999985	RUB	2024-07-23 07:50:32
526	924	paypal	2062.05000000000018	RUB	2026-01-12 22:05:31
559	98	bank_transfer	371.259999999999991	RUB	2025-11-14 21:26:52
530	284	bank_transfer	1654.5	RUB	2024-05-31 15:14:50
561	341	bank_transfer	1944.73000000000002	EUR	2025-08-20 14:12:05
531	1033	\N	393.629999999999995	RUB	2025-04-03 13:53:12
562	-1	bank_transfer	2932.15000000000009	USD	2024-12-30 13:56:25
533	759	paypal	2044.68000000000006	EUR	2024-10-24 20:51:40
566	761	bank_transfer	158.439999999999998	USD	2026-01-16 11:34:15
535	671	\N	616.039999999999964	EUR	2025-04-01 19:00:41
567	71	paypal	1866.70000000000005	USD	2025-08-30 03:06:19
537	949	\N	192.159999999999997	RUB	2025-02-08 22:18:11
568	423	paypal	2698.2800000000002	USD	2026-04-17 09:52:17
539	371	\N	2496.90000000000009	USD	2024-11-09 09:22:42
569	316	bank_transfer	2873.07000000000016	RUB	2025-03-13 10:40:12
541	988	card	2124.38000000000011	USD	2025-11-21 10:19:47
570	233	paypal	2419.9699999999998	EUR	2025-05-22 08:12:21
543	118	bank_transfer	379.660000000000025	USD	2024-09-29 10:09:43
571	69	paypal	865.370000000000005	EUR	2024-06-18 00:29:09
548	815	bank_transfer	2990.71000000000004	EUR	2026-04-17 21:12:38
573	333	bank_transfer	597.049999999999955	USD	2025-06-30 10:40:53
550	165	\N	2652.94000000000005	USD	2024-06-03 00:36:05
574	15	card	1194.46000000000004	EUR	2024-12-13 17:38:06
555	666	bank_transfer	682.42999999999995	USD	2026-01-11 04:48:55
578	293	paypal	1811.41000000000008	EUR	2025-11-03 16:03:00
556	1127	bank_transfer	485.699999999999989	USD	2024-10-19 03:46:59
579	-1	bank_transfer	1216.44000000000005	EUR	2025-07-13 21:36:29
558	179	paypal	490.850000000000023	RUB	2026-03-25 16:43:55
583	868	bank_transfer	1129.68000000000006	EUR	2024-12-03 13:01:06
560	860	\N	2454.9699999999998	EUR	2025-01-18 05:22:40
585	-1	\N	326.600000000000023	USD	2025-03-20 15:17:26
563	891	bank_transfer	\N	USD	2025-02-16 16:18:19
587	282	bank_transfer	2230.63999999999987	USD	2025-03-25 12:28:22
564	846	card	1267.71000000000004	USD	2025-08-26 07:24:27
588	472	bank_transfer	589.330000000000041	EUR	2024-07-09 12:33:54
565	212	paypal	\N	RUB	2024-06-29 18:26:48
589	286	card	49.6000000000000014	RUB	2026-04-19 14:37:17
572	584	paypal	1751.06999999999994	RUB	2026-01-09 08:20:07
591	955	paypal	2753.63000000000011	EUR	2024-07-11 03:03:49
575	473	card	1701.71000000000004	USD	2024-08-11 22:22:23
592	192	paypal	2083.42000000000007	RUB	2025-01-21 06:53:10
576	186	paypal	2498.32999999999993	RUB	2025-12-30 17:31:43
593	1106	card	2459.53999999999996	RUB	2025-02-10 09:04:47
577	805	bank_transfer	191.449999999999989	RUB	2025-09-03 18:09:54
595	1177	paypal	143.509999999999991	USD	2026-03-25 12:19:54
580	-1	bank_transfer	496.95999999999998	RUB	2024-11-22 22:03:17
596	1144	\N	2644.26999999999998	EUR	2025-06-09 06:08:20
581	-1	card	296.860000000000014	RUB	2024-11-24 07:50:22
597	340	bank_transfer	303.920000000000016	EUR	2024-07-28 02:38:48
582	470	card	414.670000000000016	EUR	2025-10-19 15:09:44
598	564	card	2154.90999999999985	RUB	2025-02-17 15:35:39
584	817	bank_transfer	969.139999999999986	EUR	2025-04-26 00:16:55
599	1080	paypal	1013.96000000000004	RUB	2024-11-11 00:14:19
586	1170	paypal	1356.74000000000001	RUB	2024-11-20 09:38:09
602	625	paypal	393.480000000000018	RUB	2025-06-18 12:38:17
590	102	\N	1926.74000000000001	EUR	2024-10-21 10:34:38
605	831	paypal	566.389999999999986	EUR	2026-04-07 15:49:15
594	1112	\N	557.389999999999986	EUR	\N
606	516	paypal	1352.72000000000003	RUB	2025-04-10 14:40:54
600	896	\N	1633.63000000000011	USD	2024-08-31 16:13:27
608	24	card	279.819999999999993	RUB	2024-12-23 22:54:26
601	546	\N	1225.5	EUR	2024-11-24 09:26:11
609	909	card	2112.44999999999982	USD	2024-06-14 15:05:06
603	1200	\N	2627.19000000000005	USD	2025-06-24 16:45:53
614	456	\N	2512.32999999999993	USD	2024-08-08 23:54:39
604	18	card	1675.24000000000001	RUB	2026-01-17 03:53:20
615	1084	paypal	2090.59000000000015	EUR	2025-10-28 15:09:22
607	333	paypal	57.8800000000000026	EUR	2025-12-10 07:55:45
619	556	\N	1725.88000000000011	USD	2026-03-27 11:58:25
610	702	card	\N	RUB	2026-03-29 04:34:03
621	235	card	2949.46000000000004	RUB	2025-11-07 23:45:07
611	584	card	1096.69000000000005	USD	2025-09-27 22:30:58
623	715	bank_transfer	428.910000000000025	EUR	2025-08-20 18:20:15
612	173	paypal	2157.19000000000005	USD	2025-08-12 12:27:43
624	951	\N	366.589999999999975	RUB	2024-10-20 04:15:48
613	276	paypal	1124.78999999999996	EUR	2025-04-21 10:21:50
625	861	card	2686.38000000000011	EUR	2024-10-02 05:12:27
616	820	card	1467.83999999999992	RUB	2025-09-10 08:27:14
627	143	\N	2924.53999999999996	EUR	2024-07-06 14:17:39
617	893	paypal	2250.11999999999989	EUR	2025-02-20 13:49:26
629	375	card	1866.76999999999998	USD	2024-06-21 04:31:36
618	725	card	858.509999999999991	USD	2024-08-30 11:25:12
630	548	card	875.350000000000023	EUR	2025-01-16 17:36:01
620	457	card	1345.18000000000006	USD	2025-01-17 11:31:49
632	23	paypal	2475.26999999999998	EUR	2025-07-03 12:50:21
622	191	\N	2811.82999999999993	EUR	2025-09-30 13:30:04
633	462	\N	2624.96000000000004	USD	2026-03-12 17:45:51
626	599	paypal	2578.78999999999996	RUB	2025-05-09 16:25:58
636	641	\N	1029.93000000000006	RUB	2025-08-02 18:53:57
628	41	card	2577.88000000000011	EUR	2026-01-20 19:11:06
637	571	paypal	2831.94999999999982	EUR	2024-09-06 05:53:04
631	687	paypal	521.289999999999964	RUB	2026-01-24 04:37:23
638	67	paypal	2345.09000000000015	EUR	2024-08-19 18:17:58
634	958	paypal	1265.70000000000005	USD	2025-10-29 01:20:35
639	625	\N	1610.22000000000003	RUB	2024-10-30 06:14:27
635	25	card	1556.83999999999992	RUB	2024-06-05 10:26:23
641	169	\N	652.590000000000032	RUB	2024-10-07 05:13:30
640	934	bank_transfer	1912.56999999999994	EUR	2024-06-28 19:24:42
642	849	\N	2889.80000000000018	USD	2025-10-10 17:30:21
648	547	\N	2700.28999999999996	RUB	2025-02-07 13:45:24
643	1134	card	2044.72000000000003	EUR	2024-06-08 06:35:56
649	902	paypal	1537.40000000000009	USD	2025-10-21 09:04:00
644	764	card	1984.18000000000006	USD	2024-11-19 23:01:19
650	247	paypal	2455.92000000000007	USD	2025-10-25 09:39:12
645	1182	card	464.480000000000018	USD	2026-02-10 13:05:59
651	974	bank_transfer	2209.98999999999978	USD	2025-05-02 15:49:53
646	931	\N	2335.67000000000007	USD	2024-07-21 01:28:07
652	1039	\N	1850.6400000000001	EUR	2024-08-08 19:26:19
647	878	card	884.370000000000005	EUR	2026-03-15 18:14:38
655	661	card	91.730000000000004	RUB	2025-01-13 19:59:37
653	96	\N	669.730000000000018	EUR	2026-05-23 11:13:17
656	242	\N	1917.67000000000007	USD	2025-04-01 16:25:50
654	347	\N	2259.26000000000022	EUR	2025-04-24 11:31:58
657	160	\N	801.840000000000032	RUB	2026-04-04 18:41:30
659	31	\N	1218.6099999999999	USD	2025-12-30 14:42:50
658	383	card	2175.40000000000009	USD	2024-08-22 06:53:38
660	1043	card	2831.65000000000009	RUB	2025-02-05 09:02:21
662	418	paypal	478.680000000000007	EUR	2025-10-11 23:09:38
661	1005	card	2985.69000000000005	RUB	2024-07-15 11:35:00
663	1094	\N	289.5	EUR	2024-07-25 23:53:50
665	481	card	2159.5300000000002	RUB	2025-03-18 23:38:33
664	324	card	1840.01999999999998	USD	2024-07-03 21:39:45
667	858	\N	861.190000000000055	USD	2024-10-06 18:49:34
666	-1	card	2317.82999999999993	USD	2024-11-02 12:56:40
668	697	\N	2981.76999999999998	USD	2025-08-31 00:14:35
670	503	card	1693.00999999999999	RUB	2025-07-29 04:40:40
669	333	bank_transfer	25.9400000000000013	USD	2024-09-03 04:29:29
671	155	\N	457.160000000000025	RUB	2024-07-04 06:47:49
674	107	card	1592.55999999999995	EUR	2024-12-22 19:21:47
672	12	\N	1625.55999999999995	RUB	2025-01-12 18:57:18
676	235	\N	24.3900000000000006	USD	2026-01-09 03:34:48
673	234	bank_transfer	1143.18000000000006	RUB	2024-12-25 02:06:40
680	1127	paypal	467.660000000000025	RUB	2025-07-10 12:28:15
675	291	card	1958.46000000000004	EUR	2025-12-22 00:49:03
681	1079	bank_transfer	2612.94999999999982	USD	2025-03-03 02:47:25
677	612	card	2812.01000000000022	EUR	2024-12-06 19:33:28
682	1040	bank_transfer	\N	RUB	2024-08-08 22:23:10
678	1105	card	2641.90999999999985	RUB	2024-09-08 14:17:13
683	182	card	567.879999999999995	EUR	2025-10-01 01:16:09
679	931	paypal	1929.04999999999995	EUR	2026-04-09 04:35:06
685	32	card	531.039999999999964	RUB	2024-08-23 06:15:05
684	231	\N	1628.71000000000004	USD	2025-12-22 07:35:07
686	935	card	\N	RUB	2025-12-08 05:46:51
688	-1	paypal	822.580000000000041	RUB	2024-09-01 10:10:20
687	399	bank_transfer	2277.07999999999993	EUR	2025-10-05 03:08:03
691	39	card	1979.74000000000001	USD	2026-05-11 21:02:35
689	993	card	774.17999999999995	USD	2025-10-17 20:45:22
692	375	bank_transfer	2871.34000000000015	RUB	2024-11-19 17:49:39
690	293	bank_transfer	552.360000000000014	USD	2025-12-29 10:50:50
696	1027	card	1077.48000000000002	RUB	2024-09-05 17:38:04
693	121	paypal	1365.01999999999998	RUB	2025-06-15 05:52:36
697	571	card	1607.71000000000004	USD	2026-04-27 18:09:45
694	602	paypal	1142.63000000000011	EUR	\N
700	312	paypal	1120.93000000000006	USD	2026-05-16 08:22:12
695	632	card	968.370000000000005	EUR	2026-04-20 20:40:14
701	950	\N	707.850000000000023	EUR	2025-08-18 18:56:13
698	1045	paypal	2623.63999999999987	USD	2026-04-27 18:01:28
702	1162	\N	1764.22000000000003	RUB	2025-03-04 21:57:12
699	1021	paypal	1069.78999999999996	RUB	2024-08-15 23:06:18
703	526	paypal	2717.13999999999987	RUB	2025-04-21 14:12:37
704	1155	paypal	1582.81999999999994	USD	2025-05-05 01:27:08
705	1166	\N	1163.81999999999994	USD	2025-08-09 14:53:53
706	-1	paypal	583.649999999999977	RUB	2025-11-02 10:54:38
708	819	\N	975.440000000000055	RUB	2026-05-15 02:44:40
707	1123	paypal	2746.13999999999987	USD	2025-03-09 23:04:23
709	889	card	1496.3900000000001	EUR	2026-05-04 01:08:47
712	61	card	272.220000000000027	USD	2025-05-19 08:44:05
710	1072	bank_transfer	381.829999999999984	RUB	2024-08-14 13:01:40
714	625	paypal	2523.42999999999984	USD	2026-02-17 23:02:04
711	1082	paypal	2443.0300000000002	RUB	2025-01-07 00:44:23
716	659	paypal	69.7099999999999937	RUB	2024-06-10 21:10:36
713	956	\N	882.990000000000009	USD	2025-12-09 08:40:51
717	-1	\N	2533.98000000000002	RUB	2024-08-09 19:01:27
715	446	bank_transfer	2614.73000000000002	USD	2026-03-23 05:38:01
718	278	bank_transfer	995.129999999999995	USD	2024-12-20 23:04:07
720	993	\N	1023.75999999999999	EUR	2024-10-08 19:55:09
719	114	paypal	1001.92999999999995	USD	2025-10-01 23:05:07
721	535	\N	1833.72000000000003	USD	2025-04-15 05:15:40
722	1117	card	2747.80999999999995	RUB	2025-06-15 22:15:19
723	9	card	2963.46000000000004	EUR	2025-12-05 08:55:57
724	919	\N	1983.47000000000003	EUR	2024-07-05 04:09:45
725	984	paypal	319.5	RUB	2026-01-01 09:32:51
728	-1	bank_transfer	2893.80999999999995	EUR	2024-06-03 09:29:19
726	14	bank_transfer	2747.75	USD	2024-06-12 17:43:12
732	83	paypal	610.860000000000014	EUR	2025-04-12 04:23:46
727	335	bank_transfer	2390.30000000000018	USD	2026-03-28 04:34:17
734	1011	\N	874.100000000000023	USD	2025-12-13 11:48:47
729	403	paypal	308.860000000000014	USD	2025-07-30 02:20:35
735	264	paypal	1342.92000000000007	EUR	2025-07-28 00:50:25
730	859	card	1499.05999999999995	RUB	2024-10-02 18:38:35
736	964	\N	2959.61000000000013	EUR	2025-09-11 21:34:28
731	684	card	2290.15000000000009	RUB	2024-07-09 13:39:31
737	966	card	247.120000000000005	RUB	2026-05-07 11:23:59
733	636	bank_transfer	2200.65000000000009	EUR	2025-10-15 18:44:37
739	549	bank_transfer	516.049999999999955	EUR	2025-08-04 02:05:46
738	990	paypal	1680.94000000000005	RUB	2025-07-02 01:06:15
740	151	bank_transfer	593.909999999999968	RUB	2025-06-08 12:39:20
741	196	bank_transfer	24.3399999999999999	EUR	2026-04-24 11:22:32
743	1008	\N	2005.8900000000001	USD	2025-12-13 11:09:35
742	750	paypal	796.5	RUB	2024-06-05 04:07:35
745	38	paypal	2680.51000000000022	RUB	2024-09-12 16:09:28
744	26	bank_transfer	\N	EUR	2025-08-27 03:25:32
748	571	card	1127.80999999999995	RUB	2025-08-24 11:20:27
746	167	card	2770.90000000000009	RUB	2024-11-03 01:03:59
758	1149	card	306.819999999999993	EUR	2025-02-20 10:50:41
747	82	paypal	642.840000000000032	RUB	2025-09-30 20:32:45
759	245	card	505.769999999999982	RUB	2025-09-15 19:49:19
749	659	paypal	1345.54999999999995	RUB	2025-01-21 04:20:17
760	326	paypal	1975.47000000000003	USD	2025-08-03 14:19:42
750	579	\N	2099.48999999999978	RUB	2025-06-02 03:09:19
763	403	card	2043.1099999999999	EUR	2024-10-09 16:01:39
751	702	\N	1808.93000000000006	USD	2025-09-04 07:25:49
764	-1	bank_transfer	2257.13000000000011	RUB	2026-05-19 03:47:37
752	960	bank_transfer	616.259999999999991	EUR	2024-06-03 00:45:06
766	1181	\N	414.170000000000016	USD	2025-01-14 04:26:04
753	110	\N	2553.01000000000022	EUR	2025-11-26 03:04:31
767	788	card	1102.6400000000001	RUB	2025-06-08 23:48:36
754	990	card	146.860000000000014	RUB	2024-06-17 02:26:10
768	1138	\N	\N	USD	2025-07-01 23:54:52
755	-1	card	521.200000000000045	RUB	2025-08-30 00:48:38
769	678	card	663.919999999999959	EUR	2025-10-14 15:33:33
756	578	paypal	2520.51000000000022	USD	2025-10-20 07:53:34
773	486	card	150.530000000000001	USD	2026-04-13 09:50:56
757	799	\N	293.79000000000002	USD	2024-07-24 03:25:31
774	324	paypal	1107.21000000000004	EUR	2025-10-27 00:06:31
761	15	\N	954.350000000000023	EUR	2025-11-12 07:39:46
776	86	card	1731.94000000000005	RUB	2025-04-29 23:22:12
762	984	card	2856.88000000000011	RUB	2025-08-07 20:08:27
780	-1	card	690.879999999999995	RUB	2024-08-01 14:23:31
765	996	\N	746.759999999999991	EUR	2025-12-13 02:09:35
782	816	\N	2661.2199999999998	USD	2025-02-13 13:09:06
770	18	bank_transfer	724.779999999999973	USD	2025-04-03 23:46:18
784	779	card	1857.25999999999999	USD	2025-03-21 20:33:22
771	-1	\N	405.20999999999998	EUR	2025-04-22 14:23:21
786	316	\N	1280.71000000000004	EUR	2024-07-04 00:27:44
772	23	paypal	2515.51000000000022	RUB	2026-01-09 08:28:55
789	867	\N	706.590000000000032	USD	2024-07-29 03:45:42
775	751	paypal	2275.78999999999996	USD	2026-01-06 23:29:44
790	1172	card	961.779999999999973	EUR	2026-02-16 17:21:24
777	950	bank_transfer	2155.48999999999978	EUR	2024-07-01 07:46:52
791	503	bank_transfer	404.269999999999982	EUR	2025-08-13 12:13:25
778	560	paypal	2804.65000000000009	USD	2026-05-05 22:05:01
793	958	card	309.279999999999973	EUR	2024-09-20 04:46:27
779	577	bank_transfer	970.690000000000055	EUR	2024-12-09 06:47:58
795	829	paypal	2893.98000000000002	EUR	2025-01-07 20:04:56
781	1085	paypal	1653.1099999999999	EUR	2025-10-26 12:41:48
796	399	bank_transfer	1003.69000000000005	RUB	2025-12-03 21:37:30
783	306	card	2603.5300000000002	EUR	2024-07-04 07:22:19
797	943	\N	1829.67000000000007	RUB	2024-09-25 05:49:09
785	286	bank_transfer	2909.13000000000011	RUB	2024-07-24 13:40:44
799	182	bank_transfer	2088.30999999999995	USD	2025-11-15 10:37:42
787	129	bank_transfer	67.7900000000000063	RUB	2025-07-08 18:51:30
804	943	\N	735.419999999999959	RUB	2025-03-16 09:42:58
788	9	card	1108.19000000000005	EUR	2025-02-15 21:25:28
807	45	card	439.259999999999991	EUR	2024-08-25 06:03:33
792	542	bank_transfer	1338.17000000000007	USD	2024-06-19 03:06:27
811	673	bank_transfer	1460.15000000000009	RUB	2024-10-19 06:12:08
794	164	\N	2173.59000000000015	EUR	2025-04-20 20:35:27
812	907	bank_transfer	1039.45000000000005	EUR	2025-08-31 17:52:30
798	381	paypal	2865.44000000000005	RUB	2025-10-25 07:16:42
813	1129	paypal	1713.80999999999995	USD	2025-08-05 23:53:40
800	381	paypal	2569.51000000000022	USD	2024-10-22 12:21:40
816	155	\N	1488.43000000000006	RUB	2025-09-19 01:22:21
801	389	paypal	1818.33999999999992	RUB	2026-02-24 08:14:07
818	425	bank_transfer	1444.8599999999999	USD	2026-04-11 08:42:58
802	273	paypal	2125.2800000000002	RUB	2025-10-03 13:49:16
820	174	card	1520.20000000000005	RUB	2024-12-31 17:06:30
803	382	paypal	2994.90999999999985	EUR	2024-07-03 12:10:44
822	752	paypal	75.1400000000000006	EUR	2024-06-24 01:44:55
805	900	\N	2581.21000000000004	USD	2024-10-29 11:50:07
823	5	\N	1371.25999999999999	USD	2024-09-03 02:16:23
806	1096	bank_transfer	1873.41000000000008	RUB	2026-03-03 03:55:58
824	391	bank_transfer	61.1000000000000014	RUB	2025-05-09 05:39:52
808	387	paypal	\N	USD	2025-11-13 02:52:25
825	538	\N	2543.90999999999985	RUB	2024-12-07 18:51:36
809	609	\N	1558.47000000000003	RUB	2024-07-30 09:38:39
828	-1	card	1731.46000000000004	EUR	2026-05-16 17:20:32
810	-1	card	230.389999999999986	RUB	2026-01-25 16:07:29
829	-1	bank_transfer	1804.25	EUR	2025-05-30 11:22:12
814	583	paypal	107.769999999999996	USD	2025-01-30 12:38:05
830	426	paypal	62.3299999999999983	EUR	2024-12-03 02:58:15
815	-1	paypal	2026.83999999999992	USD	2024-11-29 11:38:40
834	923	\N	\N	RUB	2025-02-21 11:47:36
817	823	bank_transfer	1528.56999999999994	RUB	2024-09-28 21:13:39
835	396	bank_transfer	2103.05999999999995	EUR	2024-05-24 10:14:41
819	642	paypal	729.360000000000014	RUB	2024-09-23 08:55:20
836	331	bank_transfer	914.509999999999991	EUR	2026-03-09 00:24:06
821	271	\N	1429.28999999999996	EUR	2025-04-06 13:48:08
837	132	paypal	2151.09000000000015	USD	2025-04-20 09:57:38
826	-1	\N	231.5	RUB	2025-10-03 07:08:55
838	990	card	630.990000000000009	EUR	2025-03-31 22:46:56
827	-1	\N	1766.86999999999989	RUB	2025-09-12 23:15:04
839	795	card	1978.65000000000009	EUR	2025-06-23 02:08:06
831	270	paypal	2329.73000000000002	RUB	2025-05-14 14:31:10
840	524	bank_transfer	2098.63000000000011	EUR	2025-06-12 10:40:30
832	322	card	786.629999999999995	RUB	2025-07-09 22:01:57
843	1110	paypal	2329.63000000000011	USD	2025-06-24 09:53:01
833	1152	bank_transfer	2603.73000000000002	USD	2024-10-04 17:10:50
845	289	\N	171.069999999999993	USD	2025-11-05 19:39:36
841	1099	bank_transfer	931.720000000000027	EUR	2026-03-09 06:54:53
846	661	bank_transfer	1164.8900000000001	EUR	2025-03-11 18:16:52
842	909	bank_transfer	93.0100000000000051	RUB	2024-08-24 23:11:29
848	672	bank_transfer	2003.22000000000003	EUR	2025-08-30 06:33:39
844	413	\N	2571.82000000000016	USD	2026-02-17 23:55:23
855	963	card	1547.42000000000007	RUB	2024-07-08 01:40:49
847	569	bank_transfer	2202.7199999999998	EUR	2024-11-15 04:09:11
856	398	card	\N	RUB	2024-09-04 10:47:33
849	964	\N	1069.15000000000009	EUR	2025-06-20 10:23:03
857	435	\N	908.92999999999995	USD	2025-03-07 12:32:31
850	692	\N	37.0499999999999972	RUB	2025-12-12 03:55:53
860	136	\N	\N	RUB	2024-06-10 06:57:55
851	147	\N	2570.38999999999987	EUR	2026-01-15 01:15:41
861	1180	\N	1464.68000000000006	USD	2026-02-23 01:38:48
852	526	bank_transfer	1071.6400000000001	EUR	2024-09-18 10:29:34
865	457	bank_transfer	\N	RUB	2026-01-21 09:27:18
853	607	card	224.759999999999991	USD	2025-05-18 19:47:21
866	1124	card	76.1400000000000006	USD	2025-09-04 10:06:13
854	833	\N	2408.98999999999978	USD	2024-08-12 09:34:38
868	478	card	458.470000000000027	EUR	2025-03-17 05:26:41
858	100	paypal	536.610000000000014	USD	2024-08-10 23:59:01
870	640	paypal	\N	USD	2024-08-07 03:26:23
859	142	paypal	2949.69999999999982	EUR	2024-07-10 21:13:47
877	-1	bank_transfer	2215.75	USD	2024-08-31 08:18:05
862	551	card	2525.2800000000002	USD	2025-01-09 01:59:57
879	787	\N	2550.92999999999984	USD	2024-11-03 02:47:28
863	612	bank_transfer	1100.48000000000002	USD	2024-10-30 01:37:30
882	782	bank_transfer	1511.95000000000005	EUR	2025-11-16 22:23:21
864	1008	bank_transfer	1402.83999999999992	RUB	2025-05-18 14:58:55
883	48	\N	1698.11999999999989	USD	2025-12-16 16:24:01
867	-1	bank_transfer	1980.43000000000006	EUR	2026-01-26 18:38:24
886	878	bank_transfer	1425.15000000000009	EUR	2025-06-24 07:04:08
869	681	bank_transfer	2735.82000000000016	RUB	2025-02-02 12:09:48
889	1017	bank_transfer	793.279999999999973	EUR	2026-04-06 17:08:23
871	942	\N	697.529999999999973	EUR	2024-10-16 21:19:56
890	1116	card	623.519999999999982	EUR	2026-03-29 02:53:18
872	233	bank_transfer	1607.11999999999989	USD	2024-11-19 04:42:55
894	35	\N	631.980000000000018	EUR	2025-02-09 16:43:56
873	1071	paypal	1550.19000000000005	USD	2026-03-20 07:17:01
900	301	paypal	160.280000000000001	EUR	2026-05-16 14:26:18
874	-1	bank_transfer	31.0100000000000016	RUB	2024-06-28 19:18:17
901	1048	\N	1668.76999999999998	RUB	2026-04-04 00:36:07
875	567	card	1569.59999999999991	RUB	2024-05-26 14:51:24
903	848	paypal	1273.75	USD	2025-03-31 01:01:57
876	345	\N	1272.45000000000005	USD	2025-05-22 12:28:58
904	998	\N	1028.19000000000005	USD	\N
878	1058	paypal	1388.54999999999995	USD	2026-04-16 02:04:49
905	447	card	2224.40999999999985	EUR	2026-05-07 13:28:42
880	178	bank_transfer	2533.40000000000009	USD	2024-06-17 12:00:35
906	652	\N	1001.22000000000003	RUB	2025-03-09 08:42:34
881	185	\N	2945.53999999999996	RUB	2024-08-17 13:58:12
907	1075	\N	2717.09999999999991	RUB	2025-01-25 18:06:40
884	971	card	721.990000000000009	EUR	2025-04-23 09:41:18
908	561	bank_transfer	1818.44000000000005	EUR	2025-07-23 22:42:05
885	311	paypal	1881.52999999999997	USD	2025-08-23 08:26:05
909	429	card	153.240000000000009	USD	2024-07-31 23:16:08
887	918	card	2621.30000000000018	RUB	2025-02-22 13:26:14
915	969	bank_transfer	1290.52999999999997	USD	2025-04-04 04:01:21
888	915	bank_transfer	2667.94000000000005	RUB	2025-03-19 14:47:00
916	867	\N	2746.63999999999987	EUR	2026-02-21 15:04:37
891	1195	card	2251.86000000000013	EUR	2024-11-09 01:51:44
918	244	bank_transfer	671.519999999999982	RUB	2026-01-14 05:11:36
892	757	\N	1492.46000000000004	USD	2025-11-10 22:53:19
922	465	paypal	1992.43000000000006	USD	2024-10-28 11:59:30
893	1128	\N	1226.8599999999999	EUR	2025-08-20 07:00:16
924	1195	\N	1053.94000000000005	EUR	2024-07-09 16:58:36
895	223	paypal	256.240000000000009	USD	2026-04-03 03:21:02
927	549	card	864.639999999999986	EUR	2025-08-02 12:23:04
896	-1	bank_transfer	2808.25	RUB	2025-10-13 08:21:19
928	331	paypal	\N	USD	\N
897	317	\N	282.879999999999995	RUB	2025-06-30 05:29:37
930	983	\N	699.220000000000027	RUB	2025-03-26 04:10:00
898	55	\N	2356.73000000000002	USD	2026-02-24 07:21:12
933	413	card	1227.09999999999991	USD	2024-07-29 16:54:43
899	-1	card	2747.92000000000007	USD	2025-12-19 04:22:37
935	852	\N	2461.13000000000011	EUR	2024-10-03 06:57:25
902	497	bank_transfer	925.289999999999964	USD	2024-10-02 12:05:34
937	808	paypal	\N	EUR	2024-10-09 15:58:16
910	106	card	947.860000000000014	USD	2025-06-20 22:11:27
939	1115	card	2102.86999999999989	USD	2025-12-10 11:01:01
911	101	paypal	2809.90000000000009	EUR	2024-11-17 13:57:07
941	972	\N	1474.90000000000009	RUB	\N
912	806	card	1616.54999999999995	RUB	2026-01-08 16:24:09
943	718	card	895.419999999999959	EUR	2025-06-16 12:46:28
913	923	\N	131.669999999999987	RUB	2026-02-16 17:02:12
944	630	paypal	926.059999999999945	EUR	2024-09-23 07:55:34
914	620	bank_transfer	179.240000000000009	EUR	2025-01-11 04:18:43
946	731	\N	670.190000000000055	RUB	2026-01-06 04:41:33
917	276	bank_transfer	2446.92000000000007	EUR	2025-11-30 10:24:14
948	190	bank_transfer	1327.24000000000001	RUB	2025-08-09 15:30:57
919	329	paypal	2835.80999999999995	RUB	2026-02-15 22:23:52
950	131	paypal	2918.94999999999982	EUR	2025-05-07 04:21:35
920	1146	paypal	1328.75999999999999	RUB	2025-01-24 22:13:01
952	1173	card	439.230000000000018	EUR	2025-12-24 21:41:33
921	1146	bank_transfer	132.47999999999999	RUB	2025-02-17 10:42:48
954	988	bank_transfer	1146.34999999999991	RUB	2024-09-19 12:10:09
923	764	card	914.259999999999991	RUB	2024-08-17 00:05:23
959	984	paypal	173.759999999999991	USD	2025-04-07 09:36:55
925	598	\N	91.4200000000000017	EUR	2024-11-10 23:02:32
960	133	bank_transfer	949.82000000000005	USD	2024-08-20 12:48:45
926	708	bank_transfer	2132.88000000000011	RUB	2026-01-12 20:00:41
961	213	card	1310.74000000000001	EUR	2024-07-25 23:13:13
929	148	bank_transfer	1550.58999999999992	USD	2025-07-01 20:31:36
964	877	paypal	1934.09999999999991	USD	\N
931	1152	paypal	2670.28999999999996	RUB	2024-09-13 01:31:01
965	540	paypal	2775	RUB	2024-11-17 06:22:16
932	264	paypal	1470.81999999999994	RUB	2025-02-22 02:21:41
966	379	paypal	\N	USD	2025-09-15 15:53:01
934	61	\N	1285.75999999999999	RUB	2026-02-27 16:42:49
967	687	card	571.360000000000014	RUB	2025-04-09 02:57:23
936	851	\N	1389.84999999999991	EUR	2025-03-22 15:43:54
969	76	card	2369.01999999999998	EUR	2026-04-13 17:57:24
938	263	paypal	538.210000000000036	RUB	2024-06-07 10:53:10
971	422	paypal	2949.65000000000009	USD	2025-12-15 15:23:29
940	868	paypal	2700.94000000000005	EUR	2025-12-12 02:09:49
972	655	paypal	424.339999999999975	RUB	2026-02-09 15:04:48
942	827	card	235.060000000000002	EUR	2026-01-20 03:32:55
974	95	card	102.040000000000006	USD	2026-03-17 03:59:51
945	1003	paypal	2444.40000000000009	EUR	2025-03-02 20:05:36
977	844	bank_transfer	491.810000000000002	EUR	2024-07-30 00:10:23
947	375	\N	1908.44000000000005	RUB	2024-09-19 14:44:49
981	-1	paypal	1323.04999999999995	EUR	2024-11-22 04:00:05
949	1122	bank_transfer	154.039999999999992	USD	2025-06-03 21:54:45
982	364	\N	1992.38000000000011	USD	2024-07-18 18:57:41
951	1126	\N	2342.86999999999989	EUR	2024-09-14 05:05:55
984	548	\N	1125.3599999999999	EUR	2026-02-15 11:53:37
953	518	bank_transfer	1417.08999999999992	EUR	2025-06-06 00:34:48
985	1047	card	2882.11000000000013	RUB	2026-01-30 13:45:56
955	534	\N	2491.78999999999996	RUB	2025-08-07 02:13:00
987	327	bank_transfer	762.659999999999968	EUR	2025-12-29 23:40:42
956	131	paypal	1560.82999999999993	RUB	2025-05-23 01:25:22
990	695	paypal	2290.42999999999984	USD	2024-10-07 20:11:46
957	500	\N	\N	EUR	2025-10-31 13:34:40
991	796	\N	883.120000000000005	RUB	2025-10-15 16:24:17
958	107	bank_transfer	1958.88000000000011	RUB	2024-08-10 11:29:05
993	-1	paypal	2099.57000000000016	EUR	2024-12-27 15:44:57
962	93	\N	2399.32999999999993	RUB	2024-10-19 05:08:49
994	1124	bank_transfer	828.92999999999995	RUB	2025-09-01 11:47:58
963	931	card	1583.02999999999997	EUR	2024-11-07 23:39:02
996	-1	paypal	2197.57000000000016	RUB	2024-11-18 14:46:55
968	196	card	992.789999999999964	EUR	2025-11-04 05:50:52
998	171	card	1076.3599999999999	EUR	2026-02-06 19:58:41
970	291	card	244.659999999999997	USD	2025-05-03 00:03:31
973	774	paypal	408.870000000000005	RUB	2025-05-02 14:08:42
975	458	card	2279.32999999999993	USD	2026-02-17 14:22:37
976	776	card	698.919999999999959	USD	2026-04-17 05:39:36
978	612	bank_transfer	396.199999999999989	RUB	2025-01-07 14:03:22
979	1196	\N	1339.29999999999995	EUR	2025-09-22 02:14:23
980	1195	bank_transfer	596.110000000000014	USD	2026-05-13 21:58:10
983	364	\N	1081.50999999999999	EUR	2024-08-22 11:23:48
986	969	bank_transfer	2750.03999999999996	USD	2025-04-24 11:14:44
988	807	\N	2336.80999999999995	RUB	2024-05-27 21:42:12
989	1189	\N	966.990000000000009	USD	2025-05-25 21:54:04
992	321	\N	469.189999999999998	RUB	2024-10-27 03:37:01
995	846	card	2252.26999999999998	EUR	2026-03-14 23:21:26
997	159	\N	1833.08999999999992	USD	2025-04-01 13:07:32
999	946	card	2692.86999999999989	USD	2025-09-27 12:40:55
1000	268	\N	749.629999999999995	USD	2025-11-10 20:11:27
\.


--
-- TOC entry 2542 (class 0 OID 49550)
-- Dependencies: 288
-- Data for Name: products; Type: TABLE DATA; Schema: dds; Owner: gpadmin
--

COPY dds.products (product_id, product_name, category, price, currency, is_active) FROM stdin;
2	Набор	Books	114.790000000000006	EUR	t
1	Господь	Home	54.4699999999999989	USD	f
3	Вздрагивать	Electronics	49.9799999999999969	RUB	f
5	Фонарик	Clothing	798.129999999999995	EUR	t
4	Фонарик	Electronics	392.930000000000007	RUB	f
11	Правый	Books	831.960000000000036	USD	t
6	Холодно	Sports	572.879999999999995	USD	t
12	Ответить	Home	1665.41000000000008	RUB	f
7	Порядок	Clothing	1457.06999999999994	EUR	t
14	Построить	Electronics	603.840000000000032	RUB	f
8	Академик	Clothing	1612.31999999999994	USD	t
15	Падать	Books	837.230000000000018	USD	t
9	Куча	Sports	291.560000000000002	EUR	t
17	Боец	Clothing	1164.23000000000002	RUB	t
10	Чем	Electronics	1866.6400000000001	EUR	f
20	Приятель	Home	548.980000000000018	USD	f
13	Совещание	Electronics	990.730000000000018	USD	f
23	Кпсс	Sports	546.559999999999945	RUB	f
16	Исполнять	Sports	1530.6099999999999	RUB	f
25	Услать	Books	683.919999999999959	RUB	t
18	Лететь   	Home	749.539999999999964	USD	t
26	Рай	Sports	1663.99000000000001	RUB	t
19	Конструкция	Home	296.54000000000002	USD	t
30	Интернет	Books	1714.34999999999991	USD	t
21	Исследование	Books	586.870000000000005	RUB	t
31	Дыхание	Electronics	1962.30999999999995	USD	t
22	Равнодушный	Home	1530.55999999999995	EUR	f
35	Витрина	Home	373.639999999999986	RUB	f
24	Неожиданно	Home	\N	EUR	f
36	Конференция	Sports	707.649999999999977	USD	t
27	Чувство	Books	837.610000000000014	USD	f
38	Близко	Electronics	1928.71000000000004	RUB	t
28	Около	Clothing	699.67999999999995	RUB	f
40	Сверкать	Home	882.129999999999995	EUR	f
29	Сынок	Electronics	348.550000000000011	USD	t
44	Сверкающий	Clothing	1375.66000000000008	EUR	f
32	Господь	Electronics	1550.50999999999999	USD	t
46	Армейский	Electronics	362.699999999999989	EUR	f
33	Выкинуть	Home	940.82000000000005	RUB	t
47	Зато	Clothing	1047.71000000000004	EUR	t
34	Очко	Books	1510.32999999999993	RUB	t
48	Зачем	Home	1484.16000000000008	USD	f
37	Избегать   	Books	202.719999999999999	RUB	t
49	Поколение	Books	404.529999999999973	EUR	f
39	Собеседник	Clothing	1848.83999999999992	EUR	t
50	Сынок	Home	560.639999999999986	RUB	f
41	Свежий	Home	432.480000000000018	USD	f
52	Приходить	Clothing	299.009999999999991	EUR	t
42	Сходить	Home	225.080000000000013	RUB	t
56	Спорт	Home	407.850000000000023	RUB	f
43	Отъезд	Clothing	169.080000000000013	RUB	f
57	Пища   	Electronics	1619.92000000000007	EUR	t
45	Достоинство	Clothing	381.629999999999995	RUB	f
61	Заработать	Clothing	1321.8599999999999	RUB	t
51	Заплакать	Clothing	715.409999999999968	RUB	f
63	Ломать	Sports	1534.1099999999999	USD	t
53	Славный	Electronics	1258.59999999999991	USD	f
64	Неудобно	Electronics	1674.68000000000006	RUB	f
54	Штаб	Home	1357.81999999999994	USD	f
68	Цепочка	Clothing	924.509999999999991	EUR	t
55	Жидкий	Sports	1245.81999999999994	EUR	f
69	Страсть	Clothing	1393.44000000000005	RUB	f
58	Рабочий	Clothing	770.340000000000032	USD	t
71	Радость	Sports	1008.01999999999998	EUR	f
59	Сверкать	Books	357.850000000000023	EUR	f
72	Подробность	Electronics	1939.00999999999999	RUB	t
60	Трясти	Electronics	273.300000000000011	RUB	f
74	Ручей	Home	1436.82999999999993	USD	f
62	Отражение	Clothing	1015.84000000000003	RUB	f
76	Грустный	Clothing	868.659999999999968	EUR	f
65	Доставать	Clothing	764.240000000000009	EUR	t
78	Сохранять	Clothing	429.839999999999975	EUR	f
66	Интернет	Sports	1324.17000000000007	USD	t
79	Тусклый	Books	1869.59999999999991	EUR	f
67	Налоговый	Sports	1738.53999999999996	EUR	t
83	Поставить	Home	480.769999999999982	EUR	f
70	Ленинград	Books	648.230000000000018	EUR	f
85	Число	Home	\N	RUB	t
73	Правление	Clothing	578.269999999999982	USD	t
86	Ответить	Electronics	1290.36999999999989	USD	t
75	Головной	Home	857.080000000000041	RUB	f
87	Подробность	Clothing	631.240000000000009	EUR	t
77	Соответствие	Sports	1344.75999999999999	USD	f
88	Экзамен	Books	796.809999999999945	USD	t
80	Растеряться	Home	299.75	EUR	f
89	Успокоиться	Sports	1046.30999999999995	EUR	f
81	Поговорить	Books	640.710000000000036	EUR	f
91	Медицина	Books	1612.65000000000009	USD	t
82	При	Sports	1648.29999999999995	USD	f
95	Оборот	Sports	1432.75999999999999	USD	t
84	Аж	Electronics	1121.84999999999991	USD	t
96	Передо	Sports	1382.91000000000008	EUR	f
90	Выбирать	Home	1769.71000000000004	EUR	f
98	Покидать	Clothing	1716.00999999999999	EUR	f
92	Команда	Home	354.430000000000007	RUB	t
105	Нажать	Home	1583.07999999999993	EUR	t
93	Девка	Home	983.269999999999982	RUB	f
106	Князь	Books	226.099999999999994	RUB	f
94	Оборот	Books	952.330000000000041	EUR	f
107	Да	Books	1586.31999999999994	EUR	t
97	Цель	Electronics	1279.70000000000005	RUB	t
111	Идея	Clothing	400.54000000000002	RUB	f
99	Заложить	Books	185.050000000000011	USD	f
114	Покидать	Home	241.430000000000007	EUR	f
100	Добиться	Clothing	1264.54999999999995	USD	f
116	Порода	Home	839.57000000000005	EUR	t
101	Ставить	Clothing	1733.55999999999995	RUB	f
119	Равнодушный	Home	1428.1099999999999	USD	t
102	Карман	Electronics	1853.3599999999999	USD	f
121	Второй	Clothing	15.6999999999999993	RUB	f
103	Близко	Sports	1015.13999999999999	RUB	f
122	Отметить	Books	268.819999999999993	EUR	t
104	Конференция	Books	\N	RUB	f
123	Достоинство	Books	1009.97000000000003	USD	f
108	Рабочий	Books	1376.5	USD	f
124	Народ	Home	1421.96000000000004	USD	t
109	Правый	Sports	738.360000000000014	USD	t
125	Вскакивать	Home	1000.92999999999995	EUR	f
110	Миллиард	Books	1896.48000000000002	USD	f
128	Носок	Electronics	111.180000000000007	EUR	f
112	Настать	Books	1202.77999999999997	RUB	t
132	Лапа	Electronics	1128.68000000000006	RUB	t
113	Недостаток	Clothing	33.1599999999999966	RUB	f
134	Написать	Home	572.139999999999986	RUB	t
115	Дрогнуть	Books	767.240000000000009	EUR	t
135	Торговля	Clothing	1674.76999999999998	EUR	f
117	Промолчать	Clothing	1237.26999999999998	USD	t
136	Потрясти	Sports	\N	EUR	f
118	Опасность	Clothing	940.419999999999959	RUB	t
137	Сомнительный	Sports	1895.09999999999991	USD	t
120	Военный	Clothing	1116.21000000000004	EUR	t
138	Бегать	Electronics	1727.24000000000001	RUB	t
126	Некоторый	Home	1806.06999999999994	RUB	f
144	Гулять	Clothing	1771.40000000000009	USD	f
127	Карман	Clothing	874.370000000000005	USD	f
148	Горький	Books	1968.45000000000005	RUB	f
129	Салон	Clothing	331.29000000000002	USD	f
149	Грустный	Electronics	594.490000000000009	RUB	t
130	Ныне	Clothing	716.259999999999991	USD	t
150	Выраженный	Sports	1023.75	EUR	f
131	Ботинок	Books	251.689999999999998	USD	f
152	Жить	Electronics	363.20999999999998	EUR	f
133	Дурацкий	Electronics	835.759999999999991	EUR	t
154	Висеть	Books	685.960000000000036	USD	t
139	Совет	Home	1096.57999999999993	USD	t
155	Тюрьма	Electronics	1495.31999999999994	EUR	t
140	Ход	Books	1930.26999999999998	USD	f
157	Бегать	Clothing	1738.22000000000003	EUR	f
141	Вскакивать	Books	1560.08999999999992	USD	f
158	Магазин	Home	1382.86999999999989	USD	t
142	Трубка	Home	984.240000000000009	RUB	t
159	Темнеть	Books	274.550000000000011	USD	t
143	Рис	Books	721.289999999999964	EUR	f
160	Жестокий	Sports	964.830000000000041	USD	t
145	Сопровождаться	Clothing	1622.93000000000006	USD	t
161	Место	Electronics	605.330000000000041	USD	t
146	Пятеро	Books	1029.11999999999989	EUR	t
162	Головной	Clothing	1805.31999999999994	EUR	t
147	Порт	Clothing	584.950000000000045	EUR	t
166	Ботинок	Clothing	802.360000000000014	USD	t
151	Совет	Electronics	513.450000000000045	RUB	f
167	Премьера	Electronics	1058.98000000000002	EUR	f
153	Предоставить	Clothing	631.32000000000005	RUB	f
168	Возбуждение	Home	1778.83999999999992	EUR	f
156	Аллея	Clothing	16.6600000000000001	EUR	f
169	Низкий	Home	46.509999999999998	EUR	t
163	Темнеть	Sports	1720.28999999999996	EUR	t
170	Непривычный	Sports	1017.73000000000002	RUB	f
164	Призыв	Clothing	671.029999999999973	EUR	f
171	Угроза	Clothing	266.660000000000025	RUB	f
165	Валюта	Home	1475.47000000000003	USD	f
172	Налево	Sports	1592.97000000000003	USD	f
176	Эпоха	Electronics	353.560000000000002	EUR	f
173	Коробка	Books	1382.94000000000005	USD	t
177	Песенка	Clothing	232.370000000000005	EUR	f
174	Вариант	Clothing	1213.47000000000003	EUR	t
180	Выражаться	Electronics	1853.63000000000011	USD	t
175	Очко   	Home	422.819999999999993	EUR	t
182	Темнеть	Sports	318.279999999999973	EUR	t
178	Похороны	Sports	1570.84999999999991	EUR	t
183	Очутиться	Electronics	312.819999999999993	USD	f
179	Гулять	Electronics	1707.54999999999995	RUB	t
185	Жестокий	Clothing	1012.51999999999998	EUR	t
181	Цель	Electronics	1648.09999999999991	USD	f
187	Научить	Sports	829.75	RUB	f
184	Жить   	Clothing	1939.43000000000006	EUR	f
190	Результат	Sports	1519.58999999999992	USD	f
186	Отражение	Books	307.45999999999998	USD	f
192	Порядок	Sports	\N	RUB	t
188	Вытаскивать	Sports	1887.75999999999999	USD	t
193	Вообще	Sports	1402.08999999999992	RUB	f
189	Новый	Clothing	679.919999999999959	USD	f
195	Четко	Books	173.139999999999986	RUB	f
191	Цвет	Home	841.509999999999991	RUB	f
197	Четко	Home	51.7299999999999969	USD	f
194	Кольцо	Clothing	1396.45000000000005	USD	f
198	Волк	Electronics	1454.3900000000001	EUR	f
196	Дружно	Home	431.399999999999977	RUB	t
203	Спичка	Clothing	1646.56999999999994	EUR	t
199	Конференция	Electronics	1255.83999999999992	EUR	f
205	Успокоиться	Sports	741.740000000000009	EUR	f
200	Академик	Books	\N	RUB	t
207	Плясать	Clothing	1648.5	USD	t
201	Изредка	Sports	703.919999999999959	RUB	t
209	Запретить	Electronics	1843.78999999999996	USD	f
202	Войти	Home	1430.13000000000011	RUB	t
211	Порог	Books	610	RUB	f
204	Тысяча	Books	189.039999999999992	EUR	t
215	Рассуждение	Clothing	1525.08999999999992	RUB	f
206	Перебивать	Clothing	1170.69000000000005	RUB	f
218	Домашний	Electronics	1473.15000000000009	RUB	f
208	Цвет	Books	1390.47000000000003	RUB	f
219	Стакан	Books	1124.27999999999997	RUB	t
210	Девка	Home	1145.67000000000007	EUR	f
223	Полностью	Electronics	806.590000000000032	EUR	f
212	Цвет	Books	102.060000000000002	USD	f
224	Пасть	Clothing	\N	EUR	t
213	Похороны	Electronics	9.16000000000000014	EUR	f
225	Сходить	Books	233.719999999999999	USD	f
214	Рай	Clothing	1148.25	EUR	t
229	Возмутиться	Sports	483.050000000000011	RUB	f
216	Бак	Sports	302.220000000000027	RUB	f
230	Военный	Sports	1898.97000000000003	EUR	t
217	Советовать	Electronics	777.529999999999973	RUB	f
233	Спалить	Books	894.730000000000018	EUR	t
220	Горький	Sports	1914.79999999999995	USD	t
236	Степь	Sports	6.08000000000000007	EUR	f
221	Изображать	Home	1318.22000000000003	USD	t
237	Палата	Sports	1998.49000000000001	EUR	t
222	Выдержать	Electronics	1660.23000000000002	RUB	f
239	Посидеть	Clothing	1661.83999999999992	USD	f
226	Головка	Books	1537.76999999999998	USD	f
241	Академик	Sports	1326.24000000000001	EUR	t
227	Радость	Electronics	367.009999999999991	EUR	t
244	Товар	Electronics	1575.67000000000007	RUB	f
228	Конструкция	Electronics	828.580000000000041	USD	t
246	Вытаскивать	Electronics	358.490000000000009	USD	f
231	Призыв	Electronics	970.919999999999959	EUR	t
247	Уточнить   	Electronics	744.110000000000014	EUR	f
232	Скользить	Home	496.399999999999977	RUB	f
251	Свежий	Sports	345.100000000000023	RUB	t
234	Ломать	Sports	1565.1400000000001	EUR	t
252	Прелесть	Home	135.389999999999986	RUB	t
235	Издали	Home	7	RUB	t
256	Вперед	Electronics	1361.95000000000005	RUB	t
238	Руководитель	Electronics	327.029999999999973	EUR	t
257	Затянуться	Home	98.6899999999999977	USD	f
240	Эффект	Clothing	1768.44000000000005	EUR	t
258	Развитый	Electronics	393.240000000000009	RUB	t
242	Один	Sports	1828.47000000000003	EUR	t
260	Один	Electronics	661.799999999999955	EUR	f
243	Наткнуться	Clothing	1803.38000000000011	EUR	t
261	Доставать	Home	1617.07999999999993	EUR	t
245	Заплакать	Sports	1346.13000000000011	EUR	f
262	Фонарик	Electronics	220.139999999999986	EUR	t
248	Изменение	Books	387.069999999999993	USD	f
263	Монета	Electronics	1887.38000000000011	RUB	f
249	Пасть	Sports	1934.75999999999999	USD	t
266	Полоска	Electronics	606.42999999999995	RUB	t
250	О	Home	396.189999999999998	RUB	f
267	Смеяться	Clothing	593.360000000000014	USD	t
253	Ход	Electronics	1762.59999999999991	RUB	f
270	Один   	Electronics	1177.69000000000005	RUB	t
254	Дьявол   	Clothing	1362.96000000000004	RUB	t
272	Соответствие	Electronics	1450.61999999999989	USD	t
255	Снимать	Clothing	1708.45000000000005	EUR	t
274	Лететь	Home	299.079999999999984	USD	t
259	Экзамен	Books	1956.29999999999995	USD	t
275	Выражение	Electronics	119.349999999999994	EUR	f
264	Пол	Electronics	1159.97000000000003	EUR	f
279	Снимать	Electronics	328.75	EUR	t
265	Полюбить	Electronics	1780.72000000000003	EUR	t
282	Избегать	Home	414.610000000000014	USD	t
268	Кольцо	Sports	909.559999999999945	RUB	t
285	Сходить	Books	1439.07999999999993	USD	t
269	Очередной	Clothing	682.529999999999973	RUB	f
286	Наткнуться	Books	356.269999999999982	EUR	t
271	Заведение	Home	1809.22000000000003	EUR	f
287	Возмутиться	Home	680.07000000000005	EUR	t
273	Посвятить	Home	626.779999999999973	EUR	t
288	Изменение	Clothing	1882.61999999999989	RUB	t
276	Четыре	Electronics	394.839999999999975	EUR	t
290	Нервно	Books	1390.24000000000001	USD	t
277	Помимо	Sports	1337.38000000000011	RUB	f
291	Написать	Books	1709.59999999999991	USD	f
278	Чувство	Home	1704.75999999999999	EUR	f
294	Бочок	Clothing	1503.8599999999999	RUB	f
280	Оборот	Clothing	1840.30999999999995	RUB	t
295	Исследование	Clothing	362.100000000000023	RUB	f
281	Бровь	Home	481.839999999999975	RUB	f
296	Бегать	Sports	950.149999999999977	RUB	t
283	Изба	Clothing	718.980000000000018	USD	f
298	Левый	Home	615.470000000000027	EUR	t
284	Стакан	Books	\N	USD	f
299	Приличный	Home	272.990000000000009	USD	t
289	Следовательно	Books	241.389999999999986	USD	f
301	Житель	Electronics	738.190000000000055	USD	f
292	Второй	Clothing	1746.33999999999992	USD	t
304	Вздрогнуть	Home	1094.31999999999994	EUR	f
293	Нажать	Books	1570.41000000000008	RUB	f
308	Сутки	Sports	457.720000000000027	RUB	f
297	Бровь	Books	418.360000000000014	EUR	t
309	Армейский	Home	1446.41000000000008	USD	f
300	Хотеть	Clothing	933.17999999999995	EUR	f
310	Четко	Clothing	1541.41000000000008	RUB	t
302	Редактор	Electronics	471.410000000000025	EUR	t
311	Выраженный	Electronics	752.529999999999973	EUR	f
303	Находить	Electronics	1572.81999999999994	EUR	t
312	Провал	Clothing	682.950000000000045	RUB	f
305	Металл	Sports	385.329999999999984	EUR	t
315	Палец	Books	412.389999999999986	EUR	t
306	Проход	Clothing	1541.29999999999995	EUR	t
319	Вообще	Home	585.759999999999991	RUB	t
307	Важный	Books	946.649999999999977	EUR	t
320	Роса	Books	347.79000000000002	USD	t
313	Факультет	Books	\N	USD	f
322	Терапия	Books	622.970000000000027	RUB	f
314	Господь	Sports	1138.53999999999996	EUR	f
325	Плод	Sports	1821.04999999999995	USD	t
316	Функция	Home	661.039999999999964	USD	t
326	Скользить	Home	579.379999999999995	EUR	t
317	Художественный	Sports	213.099999999999994	EUR	t
329	Развернуться	Sports	483.189999999999998	EUR	t
318	Терапия	Home	377.449999999999989	USD	t
331	Уточнить	Home	1990.66000000000008	EUR	f
321	Вытаскивать	Books	1075.22000000000003	USD	t
333	Устройство	Clothing	765.409999999999968	USD	t
323	Услать	Home	1177.04999999999995	USD	t
334	Прошептать	Clothing	504.95999999999998	EUR	f
324	Одиннадцать	Sports	1982.21000000000004	USD	f
335	Степь	Clothing	141.129999999999995	USD	f
327	Смертельный	Clothing	833.029999999999973	EUR	f
338	Какой	Books	1356.38000000000011	RUB	t
328	Дьявол	Clothing	1822.1099999999999	RUB	t
341	Задержать	Books	1535.3900000000001	USD	t
330	Песня	Clothing	1397.59999999999991	EUR	t
344	Табак	Home	92.7999999999999972	RUB	t
332	Цель	Electronics	333.850000000000023	USD	f
345	Тюрьма	Clothing	1251.22000000000003	USD	t
336	Деньги	Electronics	1641.75	RUB	t
346	Умолять	Clothing	431.490000000000009	RUB	f
337	Провал	Books	358.589999999999975	USD	t
348	Граница	Sports	92.6599999999999966	EUR	t
339	Выраженный	Electronics	1785.91000000000008	RUB	t
350	Возмутиться	Clothing	1918.26999999999998	RUB	t
340	Постоянный	Electronics	784.279999999999973	USD	f
352	Важный	Clothing	\N	EUR	t
342	Песенка   	Books	\N	RUB	t
354	Расстегнуть	Sports	621.149999999999977	USD	t
343	Экзамен	Books	445.029999999999973	RUB	t
355	Сохранять	Clothing	279.420000000000016	USD	t
347	Витрина	Home	28.8999999999999986	RUB	f
356	Спасть	Clothing	479.939999999999998	RUB	f
349	Сомнительный	Sports	1426.5	USD	f
358	Наслаждение	Home	1297.84999999999991	EUR	t
351	Парень	Home	667.42999999999995	RUB	f
360	Холодно	Clothing	1218.08999999999992	RUB	t
353	Применяться   	Electronics	1009.32000000000005	RUB	t
361	Манера	Electronics	133.909999999999997	RUB	t
357	Упорно	Electronics	272.860000000000014	RUB	f
362	Свежий	Sports	1876.8599999999999	USD	t
359	Войти	Books	415.610000000000014	RUB	t
363	Хотеть	Books	1017.30999999999995	RUB	t
365	Помимо	Clothing	1935.6099999999999	USD	f
364	Беспомощный	Home	493.629999999999995	RUB	f
368	Неожиданный	Sports	1708.80999999999995	RUB	t
366	Спасть	Sports	799.5	RUB	f
372	Функция	Home	985.450000000000045	EUR	f
367	Юный	Electronics	1521.84999999999991	EUR	f
375	Трубка	Electronics	1021.66999999999996	RUB	f
369	Изба	Home	1107.94000000000005	EUR	f
376	Песенка	Electronics	1853.40000000000009	EUR	t
370	Гулять	Books	753.419999999999959	RUB	f
377	Умолять	Clothing	1396.46000000000004	RUB	t
371	Необычный   	Sports	395.449999999999989	RUB	f
378	Пересечь	Books	512.299999999999955	USD	t
373	Демократия	Electronics	619.080000000000041	USD	f
380	Сынок	Clothing	1039.48000000000002	EUR	f
374	Сбросить	Home	1864.59999999999991	RUB	f
382	Спешить	Electronics	1506.16000000000008	RUB	f
379	Господь	Clothing	1543.08999999999992	RUB	t
384	Гулять	Electronics	17.8099999999999987	USD	f
381	Рот	Sports	1003.78999999999996	EUR	f
385	Космос	Books	1052.29999999999995	USD	f
383	Стакан	Clothing	1629.38000000000011	RUB	f
386	Зато	Sports	376.870000000000005	USD	f
389	Зачем	Electronics	164.219999999999999	EUR	t
387	Остановить	Books	1136.34999999999991	USD	f
390	Правление	Electronics	1173.3599999999999	USD	t
388	Сходить	Sports	1965.98000000000002	USD	t
391	Полюбить	Electronics	535.830000000000041	USD	t
392	Сохранять	Home	\N	EUR	f
393	Сверкать	Home	1515.03999999999996	EUR	t
396	Банда	Books	56.2299999999999969	EUR	f
394	Желание	Electronics	1882.27999999999997	EUR	f
398	Провинция	Home	11.2400000000000002	USD	f
395	Райком	Clothing	\N	RUB	t
399	Запеть	Clothing	1747.5	USD	f
397	Ягода	Clothing	1238.6099999999999	RUB	t
400	Багровый	Clothing	803.330000000000041	EUR	t
403	Фонарик	Sports	1793.33999999999992	USD	t
401	Слать	Books	1469.88000000000011	RUB	t
404	Космос	Electronics	427.220000000000027	USD	f
402	Виднеться	Sports	260.079999999999984	EUR	t
406	Беспомощный	Electronics	444.649999999999977	RUB	t
405	Холодно	Home	\N	EUR	f
410	Решетка	Electronics	683.769999999999982	RUB	f
407	Мусор	Home	1845.8599999999999	USD	t
412	Нажать	Clothing	1182.17000000000007	EUR	f
408	Бак	Clothing	1289.75	RUB	f
414	Анализ	Home	\N	USD	f
409	Призыв	Electronics	1617.84999999999991	USD	t
415	Расстегнуть	Sports	1675.25	EUR	t
411	Мелочь	Electronics	259.199999999999989	EUR	t
416	Разуметься	Electronics	1495.38000000000011	RUB	f
413	Бетонный	Sports	1596.04999999999995	RUB	t
418	Господь	Home	992.580000000000041	USD	t
417	Аж	Sports	621.240000000000009	EUR	t
421	Реклама	Clothing	678.129999999999995	EUR	t
419	Рабочий	Electronics	1696.90000000000009	USD	f
422	Деньги	Books	1058.04999999999995	RUB	f
420	Строительство	Books	1456.15000000000009	USD	f
424	Постоянный	Clothing	917.779999999999973	EUR	t
423	Факультет	Electronics	199.150000000000006	RUB	f
425	Возмутиться	Electronics	423.480000000000018	EUR	t
427	Четко	Books	1852.33999999999992	USD	t
426	Функция	Clothing	1358.24000000000001	RUB	t
430	Стакан	Electronics	1307.32999999999993	EUR	f
428	Пробовать	Books	1960.65000000000009	RUB	f
431	Господь	Electronics	554.059999999999945	USD	t
429	Граница	Home	493.779999999999973	RUB	t
432	Дорогой	Books	248.490000000000009	USD	f
435	Еврейский	Books	131.680000000000007	EUR	t
433	Слишком	Books	551.080000000000041	EUR	f
436	Плясать	Sports	790.620000000000005	EUR	t
434	Пасть	Books	1999.91000000000008	USD	f
437	Налево	Electronics	1040.21000000000004	USD	t
440	Сходить	Sports	1703.6400000000001	EUR	f
438	Направо	Sports	365.430000000000007	EUR	f
441	Совещание	Electronics	1932.72000000000003	USD	f
439	Зато	Books	250.47999999999999	USD	f
442	Кпсс	Home	97.0999999999999943	RUB	f
444	Изучить	Electronics	1377.42000000000007	USD	t
443	Слать	Home	284.009999999999991	RUB	t
446	Чем	Clothing	1185.6099999999999	USD	f
445	Пища	Sports	602.919999999999959	RUB	t
447	Зато	Clothing	525.049999999999955	USD	f
448	Мелькнуть	Books	1354.67000000000007	USD	f
449	Пастух	Home	1990.74000000000001	RUB	t
450	Сынок	Clothing	842.269999999999982	EUR	t
452	Упорно	Home	136.590000000000003	EUR	t
451	Плод	Sports	1928.22000000000003	USD	f
455	Освобождение	Home	1179.71000000000004	RUB	f
453	Кузнец   	Clothing	1738.36999999999989	USD	f
456	Крыса	Books	1105.32999999999993	EUR	f
454	Снимать	Sports	1903.80999999999995	RUB	f
457	Строительство	Sports	365.439999999999998	RUB	f
463	Выражаться	Electronics	1271.18000000000006	USD	t
458	Прелесть   	Sports	956.340000000000032	RUB	t
467	Дыхание	Sports	1406.67000000000007	RUB	t
459	Сохранять	Home	1316.83999999999992	USD	f
468	Возбуждение	Sports	1216.71000000000004	USD	t
460	Ручей	Clothing	1416.47000000000003	USD	f
472	Болото	Sports	438.839999999999975	USD	f
461	Изображать	Home	1972.55999999999995	EUR	t
474	Рот   	Books	660.460000000000036	EUR	f
462	Миллиард	Clothing	613.850000000000023	EUR	t
477	Инвалид	Books	793.740000000000009	RUB	f
464	Холодно	Electronics	173.75	EUR	t
478	Дальний	Books	221.849999999999994	USD	f
465	Предоставить	Sports	961.909999999999968	RUB	t
480	Бегать	Home	573.379999999999995	USD	t
466	Дремать	Electronics	813.919999999999959	RUB	f
481	Куча	Home	1334.07999999999993	USD	f
469	Конференция	Electronics	154.870000000000005	EUR	f
483	Развернуться	Clothing	1006.21000000000004	USD	t
470	Вздрогнуть	Books	761.289999999999964	RUB	t
488	Кожа	Electronics	1334.32999999999993	RUB	t
471	Налоговый	Electronics	583.67999999999995	RUB	f
489	Ответить	Books	381.389999999999986	USD	t
473	Очко	Electronics	1785.52999999999997	RUB	f
492	Передо	Clothing	1401.81999999999994	EUR	t
475	Деньги	Sports	22.6799999999999997	RUB	t
496	Ярко	Clothing	1817.42000000000007	EUR	f
476	Боец   	Home	824.379999999999995	USD	f
497	Заработать   	Sports	612.190000000000055	USD	f
479	Приличный	Books	\N	USD	t
499	Казнь	Electronics	480.310000000000002	USD	t
482	Бетонный	Books	980.690000000000055	EUR	f
503	Ведь	Sports	839.330000000000041	EUR	f
484	Приходить	Home	1915.56999999999994	RUB	t
504	Передо	Electronics	899.720000000000027	EUR	f
485	Войти	Home	1535.93000000000006	EUR	t
507	Запустить	Sports	1482.73000000000002	USD	t
486	Разводить	Clothing	871.490000000000009	USD	t
510	Смелый	Sports	1758.91000000000008	EUR	f
487	Даль	Electronics	1459.84999999999991	EUR	t
511	Возможно	Electronics	1705.69000000000005	USD	t
490	Выразить	Books	268.930000000000007	EUR	t
517	Ставить	Sports	357.589999999999975	USD	f
491	Выкинуть	Clothing	1234.84999999999991	RUB	f
518	Висеть	Sports	1891.57999999999993	RUB	t
493	Вздрагивать	Home	1022.17999999999995	EUR	f
521	Один	Books	191.909999999999997	USD	f
494	Бегать	Electronics	1886.27999999999997	USD	t
523	Ученый	Books	1635.91000000000008	USD	f
495	Пол	Home	6.07000000000000028	EUR	f
527	Провинция	Sports	1541.38000000000011	USD	t
498	Сомнительный	Sports	724.330000000000041	RUB	f
528	Покидать	Home	1915.45000000000005	RUB	t
500	Роса	Books	1260.97000000000003	USD	f
529	Направо	Clothing	408.629999999999995	USD	f
501	Научить	Home	1851.36999999999989	EUR	f
532	Провал	Clothing	287.95999999999998	EUR	t
502	Плясать	Electronics	1979.33999999999992	USD	t
534	Провинция	Home	986.17999999999995	EUR	t
505	Школьный	Books	1049.91000000000008	RUB	f
536	Коллектив	Clothing	360.25	USD	f
506	Уточнить	Sports	1394.93000000000006	USD	t
538	Поймать	Electronics	1866.09999999999991	USD	t
508	Анализ	Clothing	878.299999999999955	EUR	f
540	Мальчишка	Home	1630.23000000000002	USD	t
509	Мучительно	Sports	\N	RUB	t
542	Да	Home	850.539999999999964	USD	t
512	Сбросить	Books	96	EUR	t
544	Беспомощный	Sports	772.330000000000041	RUB	t
513	Четыре	Books	544.519999999999982	USD	t
545	Вообще   	Electronics	1407.67000000000007	EUR	f
514	Неправда	Home	7.79000000000000004	EUR	t
546	Эпоха	Home	1915.44000000000005	EUR	t
515	Увеличиваться	Books	1893.11999999999989	EUR	f
547	Металл	Clothing	592.919999999999959	USD	t
516	Виднеться	Home	652.649999999999977	USD	f
549	Неудобно	Electronics	1393.75999999999999	RUB	t
519	Плод	Sports	1634.6099999999999	RUB	f
551	Ломать	Clothing	162.590000000000003	USD	t
520	Радость	Home	315.5	USD	f
552	Набор	Home	942.17999999999995	EUR	f
522	Кожа	Home	1886.99000000000001	USD	t
553	Пространство	Electronics	1446.5	EUR	t
524	Беспомощный	Electronics	494.279999999999973	RUB	t
554	Теория	Books	316	RUB	t
525	Коммунизм	Clothing	1454.90000000000009	EUR	t
557	Зима	Books	1946.38000000000011	RUB	t
526	Точно	Electronics	\N	USD	t
559	Ребятишки	Clothing	1634.02999999999997	EUR	t
530	Командующий	Home	666.850000000000023	RUB	t
561	Помолчать	Electronics	160.22999999999999	USD	f
531	Страсть	Electronics	47.3100000000000023	RUB	f
562	Освобождение	Electronics	329.70999999999998	EUR	t
533	Передо	Clothing	709.850000000000023	RUB	t
566	Передо	Books	632.370000000000005	RUB	t
535	Заявление	Electronics	1233.31999999999994	USD	t
567	Ручей	Sports	665.980000000000018	USD	t
537	Пропадать	Home	1251.3900000000001	EUR	f
568	Сохранять	Electronics	1176.42000000000007	EUR	t
539	Отдел	Clothing	1556.68000000000006	RUB	f
569	Хлеб	Electronics	307.319999999999993	RUB	t
541	Командование	Home	649.490000000000009	EUR	f
570	Выраженный	Books	1769.38000000000011	RUB	f
543	Разнообразный	Clothing	769.450000000000045	RUB	t
571	Спорт	Sports	897.720000000000027	EUR	t
548	Сомнительный	Books	1656.5	EUR	t
573	Второй	Electronics	1916.24000000000001	USD	t
550	Изменение	Books	956.269999999999982	EUR	t
574	Забирать	Electronics	1533.79999999999995	EUR	t
555	Кидать	Clothing	26.6799999999999997	RUB	f
578	Второй	Sports	83.9899999999999949	RUB	t
556	Трубка	Clothing	1838.70000000000005	USD	f
579	Написать	Home	884.450000000000045	EUR	t
558	Тусклый	Sports	803.799999999999955	RUB	t
583	Волк	Clothing	1748.95000000000005	RUB	f
560	Упор	Home	114.069999999999993	USD	t
585	Упорно	Sports	806.029999999999973	EUR	t
563	Непривычный	Home	1105.61999999999989	USD	t
587	Сходить	Sports	1897.31999999999994	USD	f
564	Беспомощный	Home	1129.66000000000008	USD	f
588	Теория	Clothing	129.490000000000009	USD	t
565	Редактор	Clothing	21.9200000000000017	RUB	t
589	Лететь	Clothing	\N	EUR	f
572	Близко	Books	1781.91000000000008	RUB	t
591	Изображать	Books	1748.18000000000006	RUB	f
575	Социалистический	Electronics	912.340000000000032	EUR	f
592	Июнь	Clothing	372.240000000000009	EUR	f
576	Цепочка	Clothing	709.970000000000027	EUR	f
593	Прежде	Clothing	333.240000000000009	RUB	t
577	Призыв	Books	1957.07999999999993	USD	f
595	Невозможно	Sports	1124.00999999999999	RUB	t
580	Неожиданный	Electronics	1365.99000000000001	RUB	t
596	Житель	Home	650.850000000000023	USD	t
581	За	Electronics	1483.38000000000011	USD	t
597	Сынок	Home	1793.51999999999998	USD	f
582	Песня	Electronics	584.870000000000005	USD	f
598	Точно	Books	529.289999999999964	RUB	f
584	Висеть	Clothing	222.689999999999998	EUR	t
599	Премьера	Books	1279.6400000000001	EUR	t
586	Пространство	Electronics	1406.06999999999994	RUB	t
590	Еврейский	Clothing	1273.20000000000005	USD	f
594	Ленинград	Sports	1931.34999999999991	EUR	t
600	Пасть	Books	1203.88000000000011	RUB	t
-1	Unknown	Unknown	\N	\N	f
\.


--
-- TOC entry 2532 (class 0 OID 49469)
-- Dependencies: 273
-- Data for Name: dim_customer; Type: TABLE DATA; Schema: dim; Owner: gpadmin
--

COPY dim.dim_customer (customer_id, name, email, phone, city, registration_date) FROM stdin;
6	Варвара Степановна Шилова	aksenovkazimir@rao.biz	+79298471886	п. Карпинск	2025-06-15
2	Егоров Тихон Федосеевич	serafim_1986@gmail.com	\N	п. Мостовской	2024-07-21
16	Марфа Вячеславовна Павлова	leonti1997@yahoo.com	+79721802072	с. Яшкуль	2023-07-28
3	Зыков Вацлав Алексеевич	fharitonova@gmail.com	+79749621470	ст. Луга	2024-06-15
18	Жданова Екатерина Александровна	sazonovharlampi@zao.edu	+79965953266	\N	2026-03-05
4	Савельева Юлия Кузьминична	odintsovgerman@ignatev.biz	\N	п. Воскресенск	2025-03-28
21	Авдеев Ермолай Аверьянович	kovalevairaida@arhipov.info	\N	клх Хасан	2024-10-05
7	Гедеон Феофанович Андреев	belovemmanuil@hotmail.com	\N	п. Руза	2023-06-08
22	Шарапов Фрол Ааронович	sisoevgennadi@yahoo.com	+79867699222	п. Ессентуки	2024-05-04
8	Орехова Ангелина Дмитриевна	nonna_92@hotmail.com	+79993631208	клх Красная Поляна	2025-03-05
29	Комиссарова Варвара Рудольфовна	anikeisaev@yandex.ru	+79626713347	клх Алексин	2023-09-08
9	София Константиновна Полякова	lavrnekrasov@yahoo.com	\N	с. Петушки	2024-12-16
32	Рогов Никанор Венедиктович	anzhela_1976@teterina.com	\N	д. Оленегорск (Якут.)	2023-08-01
10	Евдокия Аркадьевна Ларионова	elise1970@gmail.com	+79282116655	г. Бийск	2025-09-21
33	Рюрик Бенедиктович Борисов	fekla_1996@gmail.com	+79123940587	п. Каменск-Уральский	2025-06-23
13	Мирослав Гертрудович Виноградов	\N	+79119778234	г. Чита	2023-08-26
39	Тихон Тихонович Романов	pgorbacheva@rambler.ru	+79225221332	п. Златоуст	2024-01-28
19	Руслан Антонович Попов	fedoseevsilanti@mjasnikova.biz	+79594768704	д. Стрежевой	2026-03-06
41	Таисия Геннадиевна Котова	kornilovmodest@antonov.info	+79207371533	клх Сладково	2024-05-11
24	Носкова Нонна Петровна	apollinari24@mail.ru	\N	г. Усть-Кулом	2026-04-07
43	Борислав Харлампьевич Евдокимов	dkudrjavtsev@mail.ru	+79554535065	к. Ачхой Мартан	2023-05-26
27	Сорокин Автоном Давыдович	uljanbikov@yahoo.com	\N	к. Нефтекамск	2025-09-01
55	Евдокимова Наталья Робертовна	fevronija1984@sistemni.edu	+79355501946	г. Тихвин	2026-03-06
28	Быков Ульян Филиппович	viktorin78@hotmail.com	+79087091896	ст. Уренгой	2024-12-01
59	Щукин Матвей Тимурович	amos_1991@glenkor.org	+79718197581	г. Чебаркуль	2025-02-16
34	Януарий Игнатович Русаков	loginovfeliks@yahoo.com	+79770530217	ст. Онега	2025-08-10
65	Кулакова Эмилия Александровна	modest2009@gmail.com	+79396899658	д. Теберда	2024-07-18
37	Тимофеева Ульяна Степановна	evdokimovaanastasija@yandex.ru	+79391541578	к. Шелехов	2025-07-06
66	Горбунов Ипполит Бенедиктович	blohinafevronija@zao.info	+79864929067	клх Хасавюрт	2023-06-09
42	Марина Валериевна Журавлева	anisim1994@npo.net	+79029635852	с. Сальск	2024-12-11
73	Лапина Зинаида Анатольевна	oabramova@oao.ru	\N	к. Енисейск	2025-02-24
45	Клавдий Дмитриевич Калашников	kabanovvadim@ao.ru	\N	к. Сунтар	2024-01-03
77	Иван Еремеевич Потапов	\N	+79932503106	с. Волгодонск	2025-12-31
51	Евдокимова Раиса Руслановна	nikonovamarfa@gmail.com	\N	к. Москва, МГУ	2024-07-12
82	Светлана Леонидовна Беляева	terentevmefodi@rao.org	+79637599912	с. Долинск	2024-06-03
53	Леонтий Игоревич Якушев	zinovevanani@hotmail.com	\N	г. Губаха	2024-04-30
84	Антонова Галина Борисовна	uosipova@yahoo.com	\N	п. Надым	2024-11-28
54	Рябова Милица Константиновна	ermola36@ooo.ru	\N	с. Чикола	2025-02-04
90	Молчанов Милий Данилович	spiridon_1973@gmail.com	\N	с. Каменск-Шахтинский	2023-12-04
58	Самсонов Юлий Терентьевич	braginmaksim@zao.edu	+79418744974	клх Северо-Курильск	2023-07-01
93	Беляева Агата Петровна	kapustinavera@gmail.com	+79126128312	п. Александровск-Сахалинский	2023-09-27
60	Ольга Кузьминична Голубева	leonid64@gmail.com	+79690147183	к. Малая Вишера	2025-07-27
100	Евдокимов Владислав Евстигнеевич	sigizmund1996@ao.biz	\N	к. Соль-Илецк	2026-01-04
62	Ефимов Савва Гурьевич	\N	+79804258674	клх Норильск	2024-05-05
109	Кузьмина Лукия Сергеевна	nikandrvolkov@hotmail.com	+79651831074	к. Щельяюр	2023-05-26
67	Роман Дмитриевич Якушев	kapiton28@kordiant.edu	\N	клх Ирбит	\N
112	Викентий Ефимович Жуков	bronislav87@yandex.ru	+79275919523	ст. Фатеж	2024-12-01
70	Герман Викторович Гусев	germankabanov@zao.com	+79727249558	п. Кыштым	\N
115	Савельев Никита Григорьевич	lazargorbachev@ip.ru	+79251064359	г. Буденновск	2025-03-17
75	Измаил Аксёнович Устинов	aleksandrovaviktorija@yandex.ru	+79296889215	д. Салават	2024-03-15
118	Кириллова Пелагея Наумовна	fedotovilarion@ao.org	+79106323670	ст. Ардон	2023-11-11
80	Прасковья Станиславовна Рябова	marfa_1993@rao.info	\N	ст. Североуральск	2026-04-13
129	Давыд Бориславович Кулагин	kozlovsilanti@zao.biz	\N	д. Крымск	2025-09-25
81	Пономарева Валентина Олеговна	stepanovajulija@aksenov.ru	+79077242236	г. Ведено	2025-02-12
130	Иван Венедиктович Горбунов	ermakovavarvara@td.ru	\N	клх Звенигород	2024-01-14
92	Журавлева Фаина Борисовна	rusakovjan@hotmail.com	+79749740261	с. Минусинск	2025-09-15
133	Гришин Аполлон Елизарович	fokafomichev@gmail.com	\N	д. Быково (метеост.)	2023-06-22
94	Сила Арсеньевич Воронов	rkulakov@ip.ru	\N	ст. Красноуфимск	2026-04-05
139	Лора Ильинична Голубева	gusevaelizaveta@rao.net	+79053256086	г. Верещагино (Перм.)	\N
97	Кира Аркадьевна Трофимова	denis2006@softline.com	+79708817958	ст. Каргасок	2025-05-17
140	Гаврилова Регина Яковлевна	kornil_32@bank.net	+79412221073	с. Чулым	2025-05-08
99	Полякова Ия Георгиевна	hpanov@yandex.ru	\N	\N	2025-08-29
142	Вишнякова Алла Матвеевна	ilarionershov@oao.ru	+79546876191	п. Асино	2025-09-09
101	Анатолий Эдуардович Шашков	apollon_70@yandex.ru	\N	г. Новомосковск	2026-02-24
143	Доброслав Бенедиктович Петухов	prohorjakushev@yahoo.com	\N	п. Томари	2024-09-25
102	Дроздов Валерий Егорович	faina_2025@ip.com	\N	клх Обнинск	2024-08-21
145	Лидия Ниловна Пономарева	kovalevajulija@rambler.ru	+79994575492	с. Березники	2026-04-12
103	Мирослав Валерьевич Марков	\N	+79816440738	с. Томари	2023-10-12
153	Одинцова Агата Олеговна	filatovstojan@yahoo.com	+79717945946	клх Шатой	2024-09-28
104	Вышеслав Геннадиевич Нестеров	valerija2017@yahoo.com	+79402482554	г. Киренск	2025-05-08
156	Муравьева Лукия Федоровна	anatoli_63@zao.org	\N	п. Ханты-Мансийск	2026-04-27
108	Калинин Константин Эдгарович	ivan65@nezavisimaja.net	+79617199615	клх Иваново	2025-01-03
165	Кондратьев Лука Борисович	braginvarlaam@rambler.ru	\N	г. Дивногорск	2026-04-29
110	Никифорова Лидия Наумовна	\N	\N	п. Томари	2025-07-19
183	Каллистрат Венедиктович Королев	evdokimfokin@mail.ru	\N	п. Миасс	2025-10-20
113	Калашников Эмиль Авдеевич	fedosi_02@npo.com	\N	г. Находка	2024-01-17
187	Филатова Олимпиада Афанасьевна	gavrilovasinklitikija@novartis.ru	+79441087900	клх Тутаев	2024-05-12
117	Клавдия Натановна Устинова	shilovalukija@rao.com	\N	к. Красноуральск	2024-07-03
190	Шашкова Анжелика Кузьминична	mokeershov@hotmail.com	+79210777576	ст. Ершов	2024-06-14
120	Тамара Наумовна Тимофеева	milen1989@mail.ru	+79296225446	д. Камень-на-Оби	2025-03-16
192	Афанасьев Савва Тимурович	natannikitin@mail.ru	+79721421320	ст. Каменск-Шахтинский	2024-10-17
126	Владимир Аверьянович Родионов	ignati_02@rambler.ru	+79965580338	г. Диксон	2025-10-10
198	Дорофеев Лукьян Ермолаевич	izot2004@oao.ru	+79422240582	ст. Суздаль	2024-08-31
127	Рюрик Исидорович Алексеев	agafon05@minudobrenija.net	+79628530544	ст. Южноуральск	2024-06-03
203	Антонов Никандр Валерьянович	demjan2018@rambler.ru	+79650967273	клх Дзержинск	2023-07-09
131	Беляева Оксана Семеновна	gordeevaevdokija@rambler.ru	+79603102938	с. Нарьян-Мар	2025-06-20
205	Кириллова Марина Григорьевна	milenshchukin@blinov.edu	+79875903641	с. Армавир	2025-08-13
141	Викторин Елисеевич Якушев	\N	+79894807263	г. Верхний Тагил	2023-08-22
209	Александра Алексеевна Филатова	fedoseevleonti@gmail.com	\N	с. Миллерово	2023-07-07
146	Баранова Антонина Эдуардовна	ribakovvalentin@npo.net	\N	д. Батайск	2026-01-24
211	Кондратий Владиленович Комаров	dementi_2006@yandex.ru	+79741139461	к. Туапсе	2024-10-26
147	Викентий Игнатьевич Смирнов	andreevapraskovja@ooo.info	+79992303073	ст. Поронайск	2026-03-20
225	Галкин Вадим Артемьевич	moiseevfoka@bss.org	\N	с. Ирбит	2024-02-02
151	Иван Денисович Богданов	milan2004@yandex.ru	\N	к. Тымовское	2023-09-27
229	Комарова Нонна Павловна	gordeevmodest@yandex.ru	+79490483627	к. Юрьевец (Иван.)	2025-11-23
163	Сидорова Агафья Юльевна	upetrov@rambler.ru	\N	с. Губаха	2023-07-22
230	Панфилова Алина Георгиевна	anatoli_32@oao.edu	\N	г. Поронайск	2023-06-30
164	Владимиров Тихон Геннадиевич	nikandr1993@yahoo.com	+79035241660	\N	2025-08-12
237	Януарий Бенедиктович Егоров	emeljanovlavr@rao.ru	+79936895083	клх Адыгейск	2023-09-25
176	Валентина Егоровна Николаева	moiseevstojan@yandex.ru	\N	к. Чебаркуль	2024-07-15
239	Галактион Адамович Колобов	lsilina@rambler.ru	\N	с. Карпинск	2026-02-13
177	Филарет Ермолаевич Фадеев	qmaksimova@npo.info	\N	с. Верещагино (Перм.)	2025-05-28
247	Пелагея Рубеновна Комиссарова	sofongavrilov@zao.net	+79746936347	к. Лысьва	2024-04-25
180	Макар Глебович Федосеев	valerjantrofimov@hotmail.com	\N	с. Чусовой	2023-09-10
251	Кир Гурьевич Сергеев	aleksandrovladislav@moskovski.org	+79489636644	\N	2025-11-07
182	Устин Игнатьевич Титов	vkrilov@hotmail.com	\N	п. Орел	2025-06-26
260	Артемьев Селиван Феофанович	kirillovzosima@rao.org	+79150270803	д. Майкоп	2023-06-27
185	Тимофеев Феофан Елисеевич	dorlov@yandex.ru	+79908179132	ст. Дно	2026-03-22
261	Мясников Анатолий Ильясович	shcherbakovanaina@gmail.com	+79787096051	д. Выборг	2025-09-21
193	Ия Кузьминична Веселова	margarita_1986@yahoo.com	\N	с. Сибай	2025-06-29
266	Максимов Ефрем Харлампович	feraponteliseev@ao.com	+79614137833	к. Лодейное Поле	2026-02-11
195	Данилов Селиверст Артемьевич	kulakovstojan@mail.ru	+79428118701	к. Соль-Илецк	2026-03-31
275	Варвара Кирилловна Архипова	fade36@oao.com	+79685240944	г. Шатой	2025-02-08
197	Константинова Тамара Павловна	emmanuilzhukov@yahoo.com	\N	г. Ангарск	2025-04-10
5	София Тимофеевна Михеева	selivan_1979@ao.ru	+79206468299	г. Уренгой	2026-01-17
207	Лукина Любовь Геннадиевна	kozlovlavrenti@ao.info	\N	к. Буденновск	2025-04-24
14	г-н Волков Фирс Алексеевич	artem1973@ooo.ru	+79320452650	ст. Верхний Тагил	2024-04-12
215	Януарий Адамович Селезнев	timur20@ip.org	\N	ст. Карпинск	2023-07-13
15	Прокофий Владиленович Уваров	solovevfrol@rambler.ru	+79348059918	ст. Южно-Курильск	2023-11-12
218	Устин Феликсович Алексеев	kalashnikovanaina@yahoo.com	+79899371401	\N	2025-04-28
20	Королева Олимпиада Владимировна	igormamontov@mail.ru	\N	п. Касимов	2024-05-26
219	Сазонова Наталья Сергеевна	taisija_1976@krokus.info	+79772095246	д. Туапсе	2023-11-02
23	Валерия Афанасьевна Беспалова	ladislav_2007@kirillov.net	\N	клх Саратов	2024-12-08
1	Мишин Емельян Валерьевич	mechislav_37@hotmail.com	\N	п. Печора	2024-05-31
38	Фомин Сильвестр Афанасьевич	vitali2015@yahoo.com	+79852055581	клх Сорочинск	2024-09-17
11	Зыкова Глафира Геннадиевна	silagushchin@mail.ru	\N	клх Печора	2025-08-20
40	Абрамов Кирилл Григорьевич	vsevolodkalashnikov@rambler.ru	+79921907485	с. Новый Уренгой	2025-12-11
12	Геннадий Матвеевич Цветков	\N	+79413140753	п. Борзя	2024-09-09
44	Александр Ефремович Сафонов	velimir_94@mosmetrostro.ru	+79737507241	с. Калининград	2024-09-03
17	Сазонов Ипат Адамович	kirill_2014@evdokimov.edu	+79213717787	с. Кемерово	2026-02-17
46	Ефрем Федосьевич Бирюков	shirjaevmark@rambler.ru	+79376672634	к. Нефтеюганск	2024-05-27
25	Трофимов Максим Игнатьевич	januari_2015@aviakompanija.biz	\N	клх Невьянск	2026-03-04
49	Лукия Александровна Красильникова	lmelnikova@yahoo.com	+79817345221	к. Александровск-Сахалинский	2025-09-14
26	Фортунат Гавриилович Гордеев	askoldlitkin@yahoo.com	\N	г. Верхнее Пенжино	2025-09-03
52	Емельянов Симон Виленович	dkudrjavtseva@ooo.edu	\N	с. Казань	2025-06-25
30	Наталья Ждановна Тарасова	oktjabrina_84@rambler.ru	\N	клх Санкт-Петербург	2025-11-15
56	Евгения Тимуровна Князева	rusakovparfen@yandex.ru	+79882563718	с. Саранск	2024-06-22
31	Боброва Светлана Николаевна	lavrmartinov@ip.org	+79121757837	к. Пермь	2024-07-23
68	Юрий Захарьевич Мартынов	chernovanadezhda@zao.info	\N	к. Бодайбо	2024-02-28
35	Эрнст Филиппович Игнатов	kkapustin@gmail.com	\N	клх Ноябрьск	2024-08-07
69	Оксана Вадимовна Фомина	galkinkliment@simonov.info	\N	д. Кажим	2025-04-27
36	Устин Егорович Сафонов	\N	+79948228268	к. Санкт-Петербург	2023-09-29
72	Ангелина Афанасьевна Павлова	zabramov@yandex.ru	+79436398872	ст. Вуктыл	2025-06-04
47	Иосиф Глебович Мамонтов	tverdislav1979@mail.ru	+79308071259	к. Каспийск	2025-10-23
76	Воробьева Евпраксия Архиповна	vorobevgalaktion@oao.edu	+79894027897	клх Беломорск	2024-09-01
48	Олимпиада Геннадьевна Гаврилова	evdokimtsvetkov@egorova.com	+79474765466	с. Тотьма	2025-11-12
78	Марфа Константиновна Лаврентьева	spartak19@yandex.ru	+79472949775	г. Тихорецк	2024-01-27
50	Мишина Антонина Макаровна	ivanna25@gmail.com	\N	к. Соловки	2023-09-23
83	Кудряшов Кузьма Юльевич	gromovamaja@zao.org	+79098033943	клх Змеиногорск	2024-11-04
57	Петр Жоресович Брагин	kapitonvorobev@sds-ugol.edu	+79919909014	г. Мостовской	2024-05-20
85	Чеслав Демидович Рыбаков	ekononov@rambler.ru	\N	п. Певек	2024-10-29
61	Рыбакова Евдокия Матвеевна	rjurikovchinnikov@hotmail.com	+79227268503	д. Аргаяш	2025-08-15
88	Коновалова Прасковья Макаровна	burovsimon@oao.com	+79194872482	с. Губкин	2026-02-06
63	Силина Октябрина Матвеевна	selivanermakov@mail.ru	\N	с. Шелагонцы	2026-04-11
89	тов. Миронов Евграф Ефимович	makarovefim@yandex.ru	\N	д. Петухово	2026-02-18
64	Клавдия Никифоровна Самойлова	ktretjakova@ao.info	+79803079055	г. Комсомольск-на-Амуре	2025-10-07
96	Мария Игоревна Архипова	sokrat_52@npo.biz	\N	к. Асино	2024-04-06
71	  ivan IVANOV 	jakub2021@rao.net	+79277403790	ст. Тамбов	2023-08-24
106	Кабанова Ия Феликсовна	komarovavarvara@npo.org	+79169625036	клх Курильск	2025-02-20
74	Станимир Феликсович Брагин	kuznetsovalora@mail.ru	\N	ст. Игнашино	2024-06-15
111	Фаина Антоновна Фомина	pgorbacheva@gmail.com	\N	д. Тулун	2023-12-10
79	Фомичев Митофан Матвеевич	tatjana03@yandex.ru	\N	к. Оймякон	2023-09-17
121	Нинель Романовна Якушева	taras1997@rambler.ru	+79169058236	клх Новая Игирма	2024-11-28
86	Всеслав Иосифович Кондратьев	milan_1978@ooo.org	\N	клх Бавлы	2026-02-03
125	Горшкова Евпраксия Мироновна	pankrat1974@rambler.ru	\N	ст. Холмогоры	2025-06-21
87	Майя Юльевна Горшкова	petrovvarfolome@npo.edu	\N	г. Терскол	2023-06-29
128	Козлова Наина Тарасовна	beljaevprokl@ip.org	\N	ст. Кяхта	2025-12-12
91	Пестов Гурий Валерьянович	avksenti2010@detski.info	+79474637858	д. Салехард	2025-12-20
137	Куликов Матвей Терентьевич	alla_79@ip.biz	\N	д. Гремячинск (Бурят.)	2025-03-24
95	Фадеева Вероника Валериевна	osip1980@gmail.com	\N	д. Вязьма	2024-05-04
138	Максимильян Филимонович Сидоров	sofon2009@hotmail.com	\N	с. Гремячинск (Бурят.)	2023-07-24
98	Ульяна Константиновна Одинцова	mamontovippolit@yahoo.com	+79995201550	г. Курск	2025-08-27
148	Регина Львовна Голубева	viktorin_2008@rambler.ru	+79677944609	д. Каргополь	2025-08-13
105	Ксения Мироновна Кабанова	gmartinova@yandex.ru	\N	п. Сковородино	2024-12-27
149	Лукьян Борисович Исаков	kasjan_28@nordgold.biz	+79893027458	г. Туруханск	2024-03-30
107	Авдеева Клавдия Юльевна	dementi1997@gmail.com	\N	ст. Азов (Рост.)	2023-11-09
150	Влас Харитонович Пахомов	psavina@rambler.ru	+79869533218	к. Егорьевск	2023-10-28
114	Егорова Вероника Алексеевна	kapustinparfen@mail.ru	+79014945047	п. Териберка	2025-12-03
155	Соловьева София Мироновна	moise46@ooo.info	\N	клх Адлер	2025-10-29
116	Блохина Марфа Васильевна	sidor1990@ip.org	+79237691219	п. Иркутск	2025-03-05
157	Людмила Олеговна Копылова	ladimirdoronin@hotmail.com	+79147709679	д. Поронайск	2024-10-05
119	Зосима Федосеевич Матвеев	kapiton_48@yandex.ru	+79918532650	д. Диксон	2025-06-21
158	Фадей Германович Ильин	alekseevgeorgi@npo.org	\N	п. Октябрьское (Хант.)	2024-10-16
122	Сафонов Анатолий Богданович	foma75@bikov.info	+79158435089	ст. Мостовской	2026-01-19
160	Мартынова Дарья Альбертовна	naum_72@ip.edu	+79573397840	д. Камышин	2024-02-15
123	Максим Даниилович Стрелков	gorshkovviktorin@yandex.ru	+79384659715	к. Тверь	2025-12-10
162	Прокофий Эдгардович Носков	ljubim2001@ao.edu	+79268438908	д. Арзамас	2023-10-22
124	Филатова Кира Львовна	birjukovpantelemon@hotmail.com	+79511365210	клх Бреды	2026-04-08
166	Владимир Викентьевич Данилов	ipat_77@gureva.ru	+79978227067	г. Стерлитамак	\N
132	Зиновьев Август Ярославович	sokrat1975@kuzmin.net	+79644685429	г. Котельнич	2024-07-25
167	Баранов Кир Венедиктович	\N	\N	д. Верещагино (Перм.)	2023-10-19
134	Аникита Геннадиевич Соколов	ermola_2018@mail.ru	+79890626742	д. Саранск	2026-01-24
168	Фортунат Терентьевич Денисов	fedoseevnifont@mail.ru	+79581642473	клх Петрозаводск	2023-11-18
135	Прохор Жоресович Овчинников	darja_70@npo.org	+79376908532	с. Сарапул	2025-10-09
169	Лукин Прокофий Юльевич	leonti_1986@npo.org	+79447286055	к. Октябрьское (Челяб.)	2025-06-12
136	Пелагея Станиславовна Александрова	samson2025@yahoo.com	\N	г. Якша	2024-07-28
172	Архипов Аггей Игнатьевич	kirill85@hotmail.com	+79694469232	д. Нижневартовск	2026-01-07
144	Таисия Филипповна Кузьмина	dbikov@evon.info	\N	с. Воскресенск	2025-10-02
174	Регина Эдуардовна Архипова	lidija_88@ooo.com	+79553388913	д. Воркута	2024-08-26
152	Сидорова Дарья Рубеновна	pestovkallistrat@yandex.ru	+79415985367	с. Старая Русса	2026-04-23
181	Ирина Архиповна Власова	sharovratmir@reno.com	+79568811983	п. Смоленск	2024-10-14
154	Зыкова Анастасия Захаровна	petrsharapov@semenova.net	+79625711790	ст. Иркутск	2026-05-11
184	Юлий Александрович Крылов	alla_68@yahoo.com	+79373045064	п. Ейск	2024-06-21
159	Регина Владимировна Борисова	vsemil96@mail.ru	+79391163514	п. Поярково	2024-07-01
186	Ираклий Васильевич Ефремов	fokinazhanna@ip.biz	+79530452018	п. Югорск	2024-06-20
161	Фаина Альбертовна Мамонтова	evstafi1982@ao.ru	\N	ст. Норильск	2023-11-16
191	Иванова Анна Вениаминовна	zuevaljudmila@gmail.com	\N	ст. Южноуральск	2025-12-26
170	Алевтина Натановна Ермакова	maslovtit@rao.biz	+79021833792	д. Малгобек	2024-11-14
194	Александра Натановна Тихонова	shirjaevostromir@yahoo.com	\N	с. Пушкинские Горы	2023-07-13
171	Пономарев Бажен Артемьевич	aristarh25@mail.ru	+79258906986	клх Кизилюрт	2026-01-09
199	  ivan IVANOV 	strelkovdobroslav@oao.edu	+79637119396	г. Туруханск	2023-10-29
173	Матвей Алексеевич Игнатьев	jakushevmarian@zhukov.info	+79315081566	с. Старый Оскол	2026-04-10
200	Агата Богдановна Пестова	bolshakovvissarion@mail.ru	\N	к. Томпа	2023-06-24
175	Зыков Иннокентий Игнатьевич	pankrati_96@oao.ru	+79955078872	с. Аргаяш	2025-10-22
201	Гремислав Игнатович Прохоров	bespalovmechislav@sidorova.com	+79414838889	ст. Брянск	2025-08-03
178	Кузнецов Матвей Афанасьевич	afanasevaekaterina@yandex.ru	+79476642996	к. Кемерово	2024-11-06
202	Комиссарова Наталья Даниловна	\N	+79853514394	д. Ейск	2026-01-02
179	Кулагин Эммануил Егорович	agapmamontov@oao.info	\N	ст. Добрянка	2025-03-18
204	Вероника Афанасьевна Иванова	milenveselov@rosteh.info	\N	клх Омск	2025-10-05
188	Кузьмина Таисия Кузьминична	savelisorokin@gmail.com	+79597967654	г. Кыштым	2023-08-17
206	Аггей Ааронович Ковалев	ljudmila_1981@rambler.ru	\N	д. Кимры	2025-03-29
189	Надежда Ниловна Соболева	savelevjan@ao.org	+79556141725	к. Железногорск(Курск.)	2024-07-01
208	Агафья Болеславовна Суханова	panfilsorokin@yahoo.com	+79162598077	ст. Сортавала	2024-12-29
196	Конон Терентьевич Селезнев	mitofan_1982@ao.ru	\N	с. Коломна	2024-09-27
212	Олимпиада Святославовна Сысоева	lev2014@gmail.com	+79615766024	к. Санкт-Петербург	2026-01-05
210	Вадим Ефремович Пономарев	glafira_2000@yahoo.com	+79868909792	клх Ребриха	2025-01-23
213	Лапин Твердислав Ефстафьевич	valerjangorbachev@ooo.ru	+79275354619	д. Нижний Новгород	2024-08-26
214	Потапов Ермил Демидович	simonovaevfrosinija@ooo.biz	\N	к. Верхний Уфалей	2023-09-09
217	Кира Тарасовна Веселова	dorofeevparfen@hotmail.com	+79836873978	п. Каменномостский	2024-02-27
216	Игорь Тихонович Емельянов	avdeevalora@rao.info	+79169587940	с. Игнашино	2024-03-05
279	Пелагея Александровна Голубева	pankrat1985@hotmail.com	+79783993370	г. Буйнакск	2026-02-26
220	Викторин Феофанович Хохлов	varvara_40@startteh.edu	+79502533479	ст. Канск	2026-02-20
282	Моисеева Таисия Андреевна	kirillovarkadi@a-ol.info	\N	д. Рославль	2023-10-01
221	Сигизмунд Изотович Стрелков	pshubin@gmail.com	\N	клх Надым	2024-01-10
287	Анжела Никифоровна Мельникова	isa_69@ip.biz	+79762418359	клх Неплюевка	2025-04-02
226	Аполлинарий Гаврилович Силин	egor_2016@ip.org	+79753703117	ст. Стерлитамак	2024-03-30
290	Фролова Иванна Оскаровна	kondratibaranov@rambler.ru	\N	п. Сусуман	2023-07-09
227	Савина Алла Вениаминовна	vladlenuvarov@zao.net	\N	д. Приозерск	2024-09-07
291	Игнатьев Симон Гаврилович	antonina_85@ip.biz	+79121559383	п. Апрелевка	2024-01-05
228	Емельян Тарасович Аксенов	ermolagordeev@hotmail.com	\N	к. Курганинск	2024-03-07
294	Аким Жоресович Орехов	julichernov@npo.net	+79884598890	к. Мурманск	2024-03-04
223	Бирюков Дорофей Трофимович	fedorovairina@npo.org	+79344374884	д. Азов (Рост.)	2025-12-27
296	Гурьев Порфирий Гертрудович	andreevpetr@ooo.ru	+79657952227	г. Александровск-Сахалинский	2024-06-28
224	Элеонора Наумовна Кондратьева	sharapovanani@rao.biz	+79736665942	д. Поронайск	2025-10-30
299	Олимпиада Валериевна Никифорова	potap71@oao.net	+79524033772	д. Шахты	2025-11-05
233	Лукия Олеговна Суворова	belozerovartemi@es.edu	\N	с. Клин	\N
304	Киселева Анжела Мироновна	florentin2025@gmail.com	\N	\N	2023-12-31
236	Марина Валентиновна Котова	rgorshkova@gmail.com	+79233291033	ст. Медногорск	2025-03-16
308	Олег Игоревич Нестеров	nadezhda_1973@oao.info	+79178702585	п. Дербент	2024-03-14
241	Гордеева Лариса Антоновна	valerjanfomichev@rosbank.net	+79603857319	ст. Пятигорск	2025-08-03
309	Трифон Ермилович Панов	dementevigor@gmail.com	+79692156071	д. Коломна	2025-11-18
244	Зиновьев Сергей Ефимьевич	pankrati05@npo.info	\N	к. Шерегеш	2024-12-19
310	Анжела Оскаровна Большакова	polina_1995@yahoo.com	+79383107687	п. Черкесск	2024-11-04
246	Доронина Лидия Наумовна	pankrat1991@sitnikova.net	+79608795036	\N	2025-04-18
322	Никифор Валерианович Прохоров	ilja68@yahoo.com	+79862338680	п. Середниково	2023-08-05
252	Чернов Мокей Тихонович	\N	\N	к. Цимлянск	2024-04-17
331	Иванов Варлаам Тихонович	rfomichev@promsvjazbank.biz	\N	клх Минусинск	2024-12-30
256	Степанова Антонина Оскаровна	prokofi_85@yahoo.com	\N	клх Октябрьское (Хант.)	2026-03-20
333	Медведев Леон Викторович	nikifor_1997@npo.org	+79908138715	к. Абакан	2024-09-08
257	Любовь Сергеевна Лаврентьева	naum24@peterburgski.ru	+79510564546	г. Нижневартовск	2026-04-25
334	Антонина Олеговна Соловьева	qisakov@npo.com	\N	клх Рославль	2024-07-28
258	Артемьева Акулина Робертовна	borisovdenis@gmail.com	\N	клх Салехард	2025-07-15
335	Вера Васильевна Лапина	nikon2025@gmail.com	+79311966923	клх Оха	2025-03-29
262	Козлов Владислав Эдгардович	nonna43@oao.ru	+79552909784	г. Псков	2025-12-20
338	Дмитриева Елена Валериевна	romanovgostomisl@rambler.ru	+79216876560	с. Каргополь	\N
263	Марк Гертрудович Комаров	sazonovsofron@hotmail.com	+79088087644	с. Лянтор	2024-03-09
355	Зайцев Михаил Терентьевич	kondrat_2023@rao.net	+79446595822	к. Джубга	2023-12-09
267	Воронцова Ангелина Никифоровна	popovaviktorija@rambler.ru	+79296311802	д. Казань	2023-10-23
356	Зиновьева Нинель Федоровна	evgraf92@rambler.ru	\N	ст. Крымск	2025-02-10
270	Евпраксия Афанасьевна Турова	ustinovapollon@yahoo.com	\N	ст. Кимры	2025-08-31
358	Натан Августович Денисов	akulina_27@ohk.info	\N	к. Энгельс	2026-03-09
272	Шилов Лазарь Ярославович	agafon_1972@rambler.ru	+79780839406	ст. Юрюзань	2026-04-19
360	Щукина Вера Антоновна	dobroslavkudrjashov@rambler.ru	+79644476518	г. Касимов	2023-08-13
274	Власов Варфоломей Елисеевич	lev_93@zao.info	\N	с. Воткинск	2025-08-01
363	Мир Архипович Котов	morozovuljan@blinov.edu	\N	д. Иваново	2025-10-05
285	Лихачева Элеонора Захаровна	parfen_1973@mostotrest.ru	+79377940931	д. Азов (Рост.)	2024-05-05
367	Третьякова Анжела Григорьевна	ibolshakova@yahoo.com	\N	к. Адыгейск	2023-07-21
286	Нинель Семеновна Зайцева	kshirjaev@gmail.com	+79107882750	д. Новомосковск	2024-01-01
369	Корнил Бенедиктович Агафонов	fekla_68@rambler.ru	+79450535448	д. Ряжск	2026-04-01
288	Герасимова Виктория Оскаровна	kondrat1993@yahoo.com	+79525749126	п. Кострома	2024-01-31
370	Кудрявцев Вадим Иларионович	kornilovuljan@mail.ru	\N	д. Омск	2025-12-16
295	Уваров Исай Викторович	admitriev@npo.org	\N	г. Цимлянск	2023-06-02
379	Федот Терентьевич Сысоев	ddementeva@rambler.ru	\N	к. Яхрома	2025-05-06
298	Юдин Ефрем Федосьевич	gleb1974@messojahaneftegaz.biz	+79432557724	п. Йошкар-Ола	2024-12-02
381	Евгения Аркадьевна Воронова	morozovsofron@gmail.com	+79398299245	п. Верхнее Пенжино	2025-12-12
301	Носова Полина Натановна	\N	+79437981615	с. Шенкурск	2024-07-02
383	Панкратий Тихонович Фокин	proklandreev@hotmail.com	+79116076355	к. Губкин	2023-07-22
311	Марина Игоревна Горбачева	pankrat_2002@yandex.ru	+79076248559	к. Долинск	2025-01-24
390	Мария Антоновна Кудрявцева	avdeevaninel@oao.info	\N	к. Быково (метеост.)	2024-03-30
312	Нинель Филипповна Некрасова	agata_1971@oao.info	+79924291998	\N	2025-11-17
394	Маргарита Тимуровна Зыкова	sergeevauljana@ip.ru	+79680202067	ст. Шарья	\N
315	Рябов Филимон Якубович	gushchinernest@oao.org	+79218181642	с. Павловская	2026-04-01
395	Денис Иосифович Васильев	mironovaskold@zao.biz	+79004427929	п. Беломорск	2025-07-17
319	Лидия Рудольфовна Гаврилова	ikotov@gmail.com	+79031521039	д. Пинега	2023-08-21
403	Изяслав Ильясович Савин	\N	\N	ст. Благовещенск (Амур.)	2024-06-15
320	Гаврилов Творимир Адамович	baranovorest@yandex.ru	\N	д. Рубцовск	2023-10-24
406	Воронцова Акулина Валериевна	kiselevapraskovja@yandex.ru	+79053773200	к. Обоянь	2023-09-30
325	Софон Еремеевич Чернов	birjukovljubosmisl@rambler.ru	\N	п. Тырныауз	2025-06-15
412	Сигизмунд Давидович Артемьев	dmitrikudrjavtsev@hotmail.com	\N	клх Дербент	2023-05-28
326	Сила Тимурович Смирнов	danila71@hotmail.com	+79161669421	г. Волгоград	\N
415	Муравьева Агата Антоновна	lturova@rambler.ru	+79304384516	п. Бугуруслан	2026-03-31
329	Богдан Филиппович Захаров	seliverstsharov@hotmail.com	\N	г. Мончегорск	2025-11-26
416	Оксана Аскольдовна Игнатьева	serafim2015@vinogradov.com	+79476944168	д. Избербаш	2026-02-18
341	Орлова Синклитикия Эльдаровна	aleksandra62@gmail.com	+79839575663	к. Буденновск	2023-09-01
418	Комаров Егор Валентинович	jaropolk_91@yandex.ru	\N	п. Глазов	2026-02-11
344	Панфилова Алина Эльдаровна	gromovharlampi@yahoo.com	+79901108031	ст. Хасан	2025-09-02
421	Регина Феликсовна Морозова	koshelevjuvenali@yahoo.com	\N	с. Кропоткин (Краснод.)	2025-01-30
345	Коновалов Максимильян Иосипович	svjatoslav_13@oao.ru	+79457051399	с. Белокуриха	2024-01-31
422	Селиван Виленович Сазонов	mili_2010@rambler.ru	\N	ст. Елатьма	2024-06-13
346	Козлова Регина Ниловна	evse_1996@gmail.com	+79870161616	д. Наро-Фоминск	2024-09-09
428	Туров Моисей Ильясович	bikovalarisa@ooo.edu	\N	ст. Сусуман	2023-07-28
348	Горбунов Радим Гертрудович	karl07@rambler.ru	\N	клх Нефтекамск	2023-11-23
435	Нина Игоревна Лаврентьева	fedot_2017@hotmail.com	+79778371032	с. Сасово	2026-04-25
350	Евсеева Феврония Рубеновна	azari_83@npo.net	+79714609188	с. Двинской	2024-03-08
436	Гаврилова Маргарита Алексеевна	timur_1981@sibirskaja.info	+79356694326	с. Соловки	2023-12-14
352	Эмилия Егоровна Емельянова	afanasevjuli@gazprom.edu	+79783269182	ст. Мыс Шмидта	2026-01-21
437	Пелагея Святославовна Яковлева	prokltretjakov@ooo.ru	\N	с. Юрюзань	2025-07-24
354	Кононов Никон Харламович	kirill53@mail.ru	\N	г. Катав-Ивановск	2025-01-04
446	Белоусов Артемий Якубович	averjanbeljaev@yandex.ru	+79244432632	д. Нязепетровск	2025-09-08
361	Горшков Устин Изотович	uljana_14@ooo.org	\N	п. Темрюк	2023-11-04
447	Харлампий Ефимьевич Панов	julija_1990@kuznetsova.org	+79688722430	г. Урай	2024-11-01
362	Лариса Станиславовна Моисеева	emilprohorov@rao.com	+79047907058	клх Лысьва	2023-12-05
449	Евгения Васильевна Кузнецова	kallistrat_2012@ip.org	+79316730716	г. Краснокамск	2025-02-23
364	Василиса Валериевна Сергеева	ilja_2006@rambler.ru	+79499387663	ст. Сунтар	2025-10-17
452	Герасимов Боян Бориславович	varlaammorozov@gromova.net	\N	г. Яр-Сале	2025-02-16
366	Зинаида Вячеславовна Симонова	maslovboleslav@gmail.com	\N	п. Приозерск	2024-03-28
459	Варвара Святославовна Галкина	silinaksenija@aleksandrov.ru	\N	п. Курумкан	2023-09-20
371	Януарий Федосеевич Антонов	naum_50@maksidom.ru	+79653538609	г. Абакан	2024-02-28
461	Виноградова Валентина Тарасовна	kazakovkondrat@gmail.com	+79504727411	г. Шарья	2025-07-27
373	Любовь Сергеевна Кулагина	kovalevafanasi@yandeks.ru	+79322638422	п. Якша	2025-10-10
462	Колобов Ладислав Демидович	nifont1973@chernov.info	\N	п. Петропавловск-Камчатский	2025-03-31
374	Емельянов Григорий Валерианович	nadezhda_65@npo.info	\N	с. Асбест	2023-07-22
464	Платон Денисович Родионов	bogdanovaninel@mail.ru	\N	к. Кашхатау	2024-03-22
389	Кузьма Юлианович Фомин	radim07@rambler.ru	+79329730298	с. Качканар	2023-12-07
465	Голубева Людмила Константиновна	savvaseleznev@yandex.ru	+79293663355	д. Андреаполь	2025-02-12
391	Василиса Валентиновна Князева	danila_29@zao.org	+79192403553	клх Бологое	2024-07-28
466	Синклитикия Вениаминовна Яковлева	zinaida06@hotmail.com	\N	\N	2024-11-12
393	Бирюкова Агафья Ждановна	kotovjulian@rambler.ru	+79978923183	г. Красногорск (Моск.)	2026-04-04
469	Князева Вероника Ивановна	evgeniuvarov@yahoo.com	\N	д. Нефедова	2025-04-13
397	Виктор Борисович Устинов	xkarpova@rao.edu	+79674456597	к. Солнечногорск	2024-09-11
471	Антонина Федоровна Жукова	vladislavsokolov@mail.ru	\N	п. Истра	2025-02-25
404	Дмитрий Егорович Чернов	galaktion1994@ao.info	\N	с. Талдом	2024-07-04
479	Евфросиния Матвеевна Андреева	avgust_2012@yandex.ru	+79438994061	п. Ноябрьск	2023-06-27
410	Мельникова Лукия Филипповна	emeljan1983@oao.biz	+79978422280	клх Черусти	2023-06-30
482	Федор Эдгарович Лобанов	valerjan55@hotmail.com	\N	г. Кировск (Мурм.)	2026-01-26
414	Севастьян Арсенович Харитонов	faina13@yandex.ru	+79658111412	д. Нерчинск	2024-02-28
486	Соболева Олимпиада Михайловна	radovan_99@zao.edu	+79013069476	г. Апшеронск	2023-09-17
424	Полякова Алина Семеновна	ytretjakov@rambler.ru	\N	клх Ржев	2024-10-03
222	Артемьева Полина Руслановна	\N	\N	с. Бузулук	2025-12-29
425	Григорьева Евдокия Аскольдовна	rodion39@nikolaeva.edu	+79653901994	клх Великий Устюг	2025-05-07
232	тов. Бирюков Харлампий Адамович	januaribolshakov@yahoo.com	+79086167773	к. Саранск	2025-03-08
426	Дементий Ильясович Козлов	evdokimpanfilov@hotmail.com	\N	г. Махачкала	2024-05-07
234	Харитонова Алла Оскаровна	artemi_95@rao.biz	+79407245006	п. Находка	2024-09-09
429	Александр Артурович Никитин	\N	+79716354624	\N	2026-02-01
235	Фомичева Ольга Вячеславовна	ljubomir_87@yahoo.com	+79708881871	ст. Гдов	2026-03-22
438	Сократ Гурьевич Копылов	dementi_1976@hotmail.com	\N	к. Гремячинск (Бурят.)	2023-07-25
238	Фомин Гордей Жоресович	jan89@zao.net	+79285234845	г. Яшалта	2025-12-31
439	Филарет Алексеевич Наумов	hristofor24@mail.ru	\N	д. Кондопога	2024-07-29
245	Ия Кирилловна Киселева	sofija1998@rao.ru	\N	г. Балашиха	2025-10-21
231	Сысоев Куприян Федотович	emmanuil_1973@rao.edu	\N	д. Надым	2023-10-12
253	Турова Иванна Кузьминична	dementi69@mail.ru	+79159877461	с. Колпашево	2025-03-10
240	Зуев Афанасий Гертрудович	kuzminamvrosi@gmail.com	\N	д. Кырен	2024-03-19
254	Измаил Ермолаевич Аксенов	ponomarevaagafja@gmail.com	+79426164289	к. Усть-Илимск	2025-07-13
242	Никифоров Афанасий Игоревич	nsisoev@yandex.ru	+79909602544	д. Амурск	2024-03-19
259	Белова Маргарита Геннадьевна	kiselevvseslav@hotmail.com	\N	ст. Одинцово	2025-03-09
243	Харитон Федотович Фомин	vasilevanani@ip.org	+79817865301	п. Кош-Агач	2024-09-07
264	Сергеев Любосмысл Ярославович	gmaslova@mail.ru	\N	к. Нурлат	2025-07-26
248	Тихонова Александра Станиславовна	juri_2012@mail.ru	+79776914430	п. Кизляр	2024-11-23
265	Мария Сергеевна Лыткина	drozdovfeofan@vertoleti.edu	+79640942859	п. Кыштым	2026-03-12
249	Семенова Феврония Тимуровна	vasilevmoke@npo.edu	+79773430762	ст. Новая Игирма	2024-06-23
268	Гущина Жанна Александровна	\N	\N	д. Туапсе	2025-06-14
250	Семенов Станимир Давыдович	nifonttitov@gmail.com	+79717490982	клх Пушкино (Моск.)	2024-01-14
269	Синклитикия Захаровна Никонова	zharitonov@rambler.ru	\N	ст. Карабудахкент	2024-11-07
255	Марфа Семеновна Кузьмина	mihe91@rao.info	+79921505800	д. Чулым	2023-06-08
271	Анжелика Николаевна Елисеева	fomichevpavel@rambler.ru	+79314335845	с. Березники	2024-11-08
276	Якушева Вера Ильинична	amos_1992@hotmail.com	\N	п. Новороссийск	2025-04-05
273	Дьячкова Вероника Натановна	efremovkonon@ip.ru	\N	п. Плес	2025-05-22
277	Казимир Устинович Маслов	andron1972@zao.org	\N	к. Морозовск	2025-08-06
281	Артем Дорофеевич Герасимов	semen_2008@oao.info	+79943497632	п. Усть-Катав	2025-11-08
278	Раиса Вадимовна Юдина	ljudmila2008@zao.ru	+79729667145	г. Верхний Уфалей	2025-11-29
284	Маргарита Григорьевна Носкова	rodionovluchezar@ooo.edu	+79491291025	д. Усмань	2024-02-03
280	Васильев Всеволод Анатольевич	afinogen46@poljakov.com	+79748143863	к. Арзамас	2023-11-23
292	Савин Добромысл Иосифович	potap40@gmail.com	+79058786679	к. Ревда (Сверд.)	2024-02-05
283	Николаева Прасковья Дмитриевна	evdokija94@zao.com	+79417509245	ст. Серафимович	2026-05-04
300	Соболева Элеонора Мироновна	evdokija_2010@yandex.ru	+79275393773	клх Джубга	2024-10-19
289	Голубев Сергей Егорович	jsitnikova@yandex.ru	\N	клх Углич	2024-06-05
302	Зыкова Кира Ниловна	adrian97@zao.biz	+79947198944	с. Ангарск	2025-11-04
293	Милица Дмитриевна Осипова	paramon17@oao.net	+79573695421	с. Кетченеры	2024-06-07
307	Маргарита Болеславовна Некрасова	afanasevaagafja@yandex.ru	+79564593790	д. Нефтекамск	2025-11-26
297	Ангелина Кирилловна Князева	simonlitkin@rambler.ru	+79817626034	ст. Буйнакск	2023-08-21
314	Крюков Тихон Александрович	ernest52@gmail.com	+79454810443	п. Адлер	2025-07-24
303	Карл Афанасьевич Зиновьев	dorofe82@mail.ru	+79321845795	клх Бомнак	2024-01-15
316	Рябов Константин Даниилович	fadeevsevastjan@rao.com	\N	к. Ишим	2024-01-14
305	Мефодий Изотович Буров	uljan2014@hotmail.com	+79746891707	ст. Кинешма	2025-01-12
317	Прокл Васильевич Абрамов	seliverst_00@yahoo.com	+79013598909	г. Темрюк	2025-02-12
306	Кондрат Захарьевич Никитин	radovan62@zao.net	+79394666352	ст. Ямбург	2026-05-20
318	Быкова Иванна Юрьевна	kolesnikovakim@ooo.ru	+79840725996	п. Руза	2023-06-22
313	Емельян Витальевич Александров	prokl98@npo.edu	\N	ст. Шахты	2025-08-22
321	  ivan IVANOV 	\N	+79047285340	к. Кажим	2023-10-25
330	Харлампий Германович Васильев	novikovatatjana@yandex.ru	+79280236885	д. Ангарск	2024-10-15
323	Рогова Полина Максимовна	eduard2016@yandex.ru	+79924274419	к. Когалым	2024-03-01
337	Иосиф Георгиевич Силин	mishinmihail@yandex.ru	+79069226321	к. Каменск-Уральский	2025-09-06
324	Авдей Валерьевич Лазарев	viktorin_28@rambler.ru	\N	клх Екатеринбург	2024-01-06
343	Волков Вышеслав Эдгарович	ivanna_62@rao.org	+79506467254	г. Тольятти	2025-10-01
327	Пахом Ефремович Щукин	ribakovnifont@kulikov.edu	\N	к. Тихорецк	2024-02-18
349	Алла Ивановна Маркова	mina1983@npo.info	+79786356993	д. Новомичуринск	2023-05-26
328	Вячеслав Аксёнович Зимин	filipp1988@oao.biz	\N	ст. Волгоград	2024-04-13
351	Евлампий Чеславович Уваров	\N	\N	ст. Тайшет	2023-11-06
332	Петров Харитон Давидович	pavel2000@ooo.com	+79156485536	с. Котельнич	2024-02-27
357	Цветкова Майя Олеговна	gromovkazimir@oao.edu	+79701955386	д. Александровск-Сахалинский	2025-08-27
336	Яковлев Святополк Августович	petuhovselivan@oao.org	+79884412594	\N	2025-08-13
365	Горшкова Алевтина Геннадьевна	foti2022@zao.biz	\N	ст. Андреаполь	2024-07-02
339	Глафира Натановна Миронова	narkis_53@mail.ru	\N	с. Моздок	2024-09-23
375	Глафира Григорьевна Одинцова	galina65@yandex.ru	\N	г. Абакан	2026-04-05
340	Беспалов Тит Юлианович	skolobova@yandex.ru	+79071894559	п. Оренбург	2023-05-31
376	Гордеева Анна Натановна	umorozov@ooo.net	+79222973517	п. Пятигорск	2024-05-22
342	Людмила Николаевна Селиверстова	rozhkovalora@drozdova.org	+79027984900	ст. Луга	2023-06-18
377	Ирина Макаровна Тимофеева	svjatoslav_75@oao.biz	\N	клх Красная Поляна	2024-08-17
347	Денис Феофанович Дроздов	samsonovfilipp@yahoo.com	+79365887237	д. Юровск	2024-11-09
378	Феврония Афанасьевна Кулагина	ribakovamarina@mail.ru	+79934671611	с. Октябрьское (Хант.)	2026-05-23
353	Ларионов Степан Ерофеевич	\N	+79217512195	д. Набережные Челны	2024-10-03
380	Надежда Степановна Зуева	tihonovataisija@yahoo.com	+79928389318	п. Новосибирск	2026-01-07
359	Нестерова Милица Эльдаровна	antonin96@rao.edu	+79421875543	\N	2025-04-11
384	Кузьмина Галина Тарасовна	romanovanadezhda@rambler.ru	\N	г. Андреаполь	2025-08-25
368	  ivan IVANOV 	svjatopolk_88@ip.info	\N	д. Иркутск	2023-12-03
385	Комиссаров Кирилл Измаилович	varfolome_20@npo.info	\N	к. Канск	2025-01-10
372	Елизавета Болеславовна Фомичева	uljana2015@rti.org	\N	д. Терней	2026-05-16
387	Алина Рубеновна Романова	anatoli_1977@gmail.com	\N	ст. Якутск	2025-10-04
382	Тимофеева Валерия Никифоровна	bojanaleksandrov@ao.net	+79627588309	к. Медногорск	2026-05-07
388	Исаева Юлия Степановна	alina2014@yahoo.com	+79929278133	к. Челябинск	2025-11-23
386	Белоусова Вероника Болеславовна	anikitakuznetsov@yahoo.com	\N	п. Качканар	2026-01-10
392	Лукьян Анатольевич Киселев	alekseevajulija@metallotorg.ru	+79768443155	с. Минусинск	2023-09-27
396	Валерия Рубеновна Логинова	nikolaevazari@hotmail.com	\N	с. Ржев	2024-08-26
398	Шашков Чеслав Ярославович	\N	\N	д. Партизанск	2025-05-24
399	Шестаков Доброслав Теймуразович	hristoforzuev@ip.biz	\N	п. Саратов	2026-05-07
402	Гедеон Евстигнеевич Васильев	spartak_2003@ip.info	\N	г. Осташков	2026-02-08
400	Вера Кузьминична Котова	cponomareva@oao.edu	+79740613153	г. Кущевская	2025-09-19
409	Наина Валентиновна Красильникова	kuzma_1994@ikea.net	+79537643124	п. Урус-Мартан	2026-02-19
401	Аполлон Жанович Носков	seliverst1990@hotmail.com	+79009990686	клх Темрюк	2026-01-21
413	Логинов Олег Игоревич	dveselov@hotmail.com	\N	клх Урюпинск	2023-09-10
405	Мельникова Александра Анатольевна	burovfilimon@yahoo.com	+79971499471	п. Соликамск	2026-05-14
420	Элеонора Тарасовна Сергеева	evlasova@ao.net	\N	ст. Владимир	2023-09-10
407	Логинова Анастасия Кирилловна	zoja2011@rao.info	\N	г. Петрозаводск	2025-05-21
423	Устинова Клавдия Вячеславовна	visheslav2011@yahoo.com	+79957513948	г. Славгород	2025-09-19
408	Рубен Ефимьевич Лазарев	samolovatatjana@mail.ru	\N	клх Кандалакша	2023-11-21
430	Тетерин Радим Феофанович	ermakovisidor@rao.info	+79286665729	ст. Екатеринбург	2024-08-08
411	Громова Олимпиада Геннадиевна	qjudin@zao.biz	+79121265692	\N	2024-09-23
431	Тимофеева Таисия Семеновна	foka2004@npo.ru	\N	клх Гремячинск (Перм.)	2024-06-02
417	г-н Матвеев Творимир Гертрудович	maksimkabanov@hotmail.com	+79886812783	г. Каменск-Уральский	2025-08-28
432	Бобров Георгий Гавриилович	smirnovvenedikt@mail.ru	+79602659666	д. Горячинск	2024-12-02
419	Федосеева Галина Ильинична	emeljanovaelizaveta@gmail.com	+79797147094	\N	2023-06-09
434	Лукия Борисовна Рожкова	iosif_1997@npo.ru	\N	к. Рыльск	2024-04-27
427	Шилова Октябрина Леоновна	zhukovaakulina@mail.ru	+79946669037	г. Торжок	2024-10-29
441	Кудрявцев Антип Бенедиктович	\N	\N	с. Ямбург	2024-02-22
433	Ширяев Ян Арсеньевич	valerinazarov@samsonova.com	+79484966397	к. Юровск	2025-05-21
442	Миронов Ярослав Евстигнеевич	filippovevdokim@rao.edu	\N	с. Гаврилов-Ям	2024-02-17
440	Ипатий Артёмович Стрелков	beljaevavalentina@gmail.com	\N	д. Когалым	2023-12-20
445	Игнатова Наталья Леоновна	silanti_70@oao.net	+79165092727	к. Кизляр	2023-09-25
443	Михеева Марфа Федоровна	rjabovrjurik@zao.ru	+79218917878	к. Верхнее Пенжино	2025-02-22
448	Абрамов Владимир Матвеевич	dvlasov@mail.ru	+79736456606	клх Яхрома	2023-12-08
451	Севастьян Адрианович Сорокин	zahar_2010@ip.edu	+79268665437	клх Аргаяш	2024-12-01
450	Агата Робертовна Бобылева	platon69@mail.ru	\N	к. Тикси	2024-10-21
453	Октябрина Андреевна Орехова	efrembeljaev@hotmail.com	+79269173782	г. Великие Луки	2025-09-12
454	Михей Вилорович Большаков	epifanshilov@poljakov.net	+79665200007	к. Токсово	2024-07-03
463	Милица Степановна Федорова	elizarabramov@yandex.ru	\N	ст. Вязьма	2023-08-27
488	Мечислав Егорович Лыткин	dgolubev@gmail.com	+79016499677	п. Кущевская	2023-06-29
467	Павлов Ювеналий Венедиктович	sazonovaalla@gmail.com	+79175503139	с. Юрюзань	2025-03-07
492	Мельникова Майя Аскольдовна	sharapovanike@rao.info	+79587976885	г. Карабулак	\N
491	Соколова Глафира Максимовна	zbolshakova@yandex.ru	+79689328342	с. Магнитогорск	2025-08-05
497	Ратмир Бориславович Калинин	bogdan2007@ao.ru	\N	п. Обоянь	2025-02-20
494	Кабанов Арсений Власович	slarionova@oao.org	+79431778032	к. Сызрань	2025-10-30
499	Орлова Ольга Владимировна	lebedevanisim@aktsionerni.ru	\N	д. Ачхой Мартан	2025-08-14
495	Панова Евдокия Федоровна	sergeevvaleri@rao.net	+79246103540	г. Новгород Великий	2023-12-02
503	Котова Лора Максимовна	isa1984@ao.edu	+79596291839	с. Томари	2023-11-17
500	Рогов Христофор Гаврилович	fedotgrishin@yahoo.com	+79407407714	с. Уварово	2025-05-11
504	Анна Феликсовна Гришина	xkostin@hotmail.com	\N	д. Саянск	2025-08-03
501	Наум Денисович Шубин	kalashnikovkapiton@rao.info	+79368397022	г. Вендинга	2025-09-01
518	Павел Захарьевич Матвеев	simonsubbotin@vladimirova.com	+79990084878	п. Архыз	2025-05-30
502	Дарья Степановна Турова	egor_30@zao.biz	+79140809604	к. Курильск	2024-01-28
444	Роман Яковлевич Власов	ostap2017@ip.org	+79455491430	к. Муром	2025-03-17
505	Никандр Бенедиктович Тимофеев	timofeevvladlen@ooo.ru	+79051227475	клх Абинск	2026-04-17
455	Тамара Вячеславовна Кузьмина	haritonovapollon@porshe.info	+79328216558	г. Гаврилов-Ям	2025-11-24
509	Татьяна Леоновна Логинова	moke58@goznak.org	+79613791169	д. Петропавловск-Камчатский	2025-05-06
456	Аполлон Иларионович Кононов	bobilevmitofan@velesstro.edu	\N	д. Белогорск (Амур.)	2026-04-11
512	Агата Руслановна Горшкова	tustinov@rambler.ru	+79426324454	с. Меренга	2023-07-13
457	Гущина Акулина Константиновна	naumovafekla@ao.com	+79994127280	г. Светлогорск (Калин.)	2025-05-08
522	Иванна Эдуардовна Осипова	hohlovemeljan@mail.ru	+79897377234	с. Балашиха	\N
458	  ivan IVANOV 	gshashkov@rambler.ru	+79210917183	с. Аршан (Бурят.)	2023-12-04
525	Красильникова Синклитикия Святославовна	ananinikiforov@yandex.ru	+79832850970	г. Соловки	2024-05-21
460	Анисим Георгиевич Трофимов	oksana2021@gmail.com	\N	с. Дно	2025-05-20
530	Ия Артемовна Самойлова	juri_1997@npo.biz	\N	клх Нефтеюганск	2025-10-03
470	Лукина Майя Васильевна	bronislav_92@hotmail.com	\N	п. Нефтекамск	2026-02-28
531	Галина Сергеевна Рябова	lev_1986@ip.edu	\N	к. Северодвинск	2025-01-11
473	Гаврилова Валентина Макаровна	\N	\N	п. Ведено	2024-07-30
533	Олимпий Анатольевич Кузнецов	birjukovterenti@yahoo.com	\N	ст. Нязепетровск	2025-07-30
475	Акулина Яковлевна Панфилова	ivanovaoktjabrina@pochta.ru	\N	д. Бавлы	2024-01-03
539	Новикова Надежда Вадимовна	ershovbronislav@yandex.ru	+79753621656	п. Чегем	2024-09-09
476	Павлов Милен Авдеевич	bojan2003@oao.com	+79246408985	ст. Катайск	2025-04-19
541	Боброва Светлана Ильинична	tpestov@zhuravleva.info	\N	ст. Охотск	2024-07-15
484	Фомичева Фёкла Игоревна	\N	\N	г. Шамары	2026-05-02
548	Вениамин Венедиктович Пестов	\N	+79612750316	п. Мыс Шмидта	2024-10-30
485	Игнатова Агафья Егоровна	mihail55@ip.org	+79787717646	д. Буденновск	2023-07-30
556	Давыд Дорофеевич Абрамов	nikanor_2002@yahoo.com	\N	с. Елабуга	2025-12-25
487	Ефрем Ефимьевич Абрамов	fsharov@anisimova.net	\N	к. Нижний Новгород	2026-02-14
558	Вадим Ильич Сазонов	georgi2014@ooo.edu	\N	г. Усть-Калманка	2023-06-12
490	Андреев Влас Давидович	vladilen_2002@yandex.ru	\N	к. Архыз	2025-05-05
560	Никонов Федот Гурьевич	jaropolkkozlov@kolesnikova.com	+79260971128	ст. Волхов	2026-01-26
493	Селиверст Глебович Кудрявцев	kozlovaekaterina@ao.biz	+79246885603	клх Юрьевец (Иван.)	\N
564	Мирослав Геннадиевич Лаврентьев	aksenovsavva@zao.edu	\N	с. Воскресенск	2023-08-15
498	Ангелина Семеновна Жданова	tsoloveva@sovkomflot.net	\N	к. Красновишерск	2026-03-19
565	Федорова Олимпиада Валериевна	milan_1981@mail.ru	+79994660711	клх Междуреченский	2024-11-20
506	Марфа Львовна Петрова	\N	+79359334721	п. Улан-Удэ	2024-04-13
572	Константин Дорофеевич Фадеев	guljaevantip@ao.org	+79524106691	\N	2023-09-14
508	Крюков Амос Геннадиевич	burovradim@gk.info	+79628936720	ст. Льгов	2023-09-08
576	Вишнякова Лариса Романовна	dmitrieliseev@knjazeva.biz	+79995469480	к. Юровск	2023-11-08
513	Сысоева Майя Феликсовна	varlaam1987@npo.ru	+79191869359	д. Черемхово	2024-09-30
580	Денис Адамович Гришин	gerasim2018@gmail.com	\N	д. Карабудахкент	2025-07-02
514	Елисеев Фома Ильич	budimir_84@ip.info	\N	г. Сосновый Бор	2025-02-06
582	Светлана Яковлевна Кабанова	ermola86@ooo.info	\N	д. Гатчина	2023-06-08
515	Юрий Фадеевич Блинов	abramovaraisa@npo.ru	\N	п. Надым	2025-01-04
584	Азарий Иларионович Кузнецов	mihe82@gmail.com	\N	с. Лодейное Поле	2025-09-12
516	Валентина Эльдаровна Артемьева	samolovanaina@yandex.ru	+79517169553	д. Междуреченский	2024-09-10
586	  ivan IVANOV 	gerasim2017@rambler.ru	\N	клх Сунтар	2026-05-16
519	Голубев Селиверст Ерофеевич	rodionovratibor@mail.ru	\N	г. Ирбит	2026-02-26
594	Мясникова Зоя Константиновна	panfilovalidija@fmsm.biz	+79910316138	д. Озеры	2024-09-16
520	Екатерина Афанасьевна Воробьева	mir_1998@oao.org	+79820916739	клх Данков	2023-06-18
601	Киселев Изяслав Анатольевич	skoshelev@rambler.ru	+79266919752	д. Борзя	2024-02-27
524	Панфил Ааронович Буров	radovan_86@yandex.ru	+79634806999	с. Павловский Посад	2024-03-03
603	Феоктист Игнатьевич Кудряшов	beljakovkondrat@slavneft.biz	\N	к. Ярославль	2026-04-23
526	Баранов Мартьян Харитонович	olimpi_1974@rambler.ru	+79824790131	ст. Тутончаны	2024-11-16
607	Фёкла Олеговна Жукова	dobroslav60@yandex.ru	+79357867151	\N	2025-12-04
535	Регина Аркадьевна Федорова	popovauljana@npo.com	+79406994931	д. Находка	2024-05-29
610	Сазонов Лазарь Феодосьевич	olimpi_04@yandex.ru	\N	п. Верхотурье	2023-08-29
537	Зоя Валентиновна Федосеева	\N	+79415199251	к. Листвянка (Иркут.)	2025-04-29
611	Морозова Евпраксия Робертовна	ershovamarija@hotmail.com	\N	к. Богучар	2026-01-04
543	Соловьев Олимпий Анисимович	karp_52@mail.ru	+79599299989	п. Терскол	2025-05-07
612	Гаврила Иосифович Ефремов	radislav15@yandex.ru	\N	клх Ангарск	2024-07-24
550	Журавлева Вера Феликсовна	vsidorova@mail.ru	+79776938677	клх Магас	2026-04-11
613	Беляев Федот Трофимович	mir_86@ip.biz	+79990831766	ст. Кашира	2025-08-08
555	Федоров Никита Вячеславович	kulaginselivan@gmail.com	+79951508061	ст. Тулпан	2026-04-10
620	Ипатий Якубович Емельянов	solomon_13@hotmail.com	\N	клх Ачинск	2024-02-11
563	Князева Иванна Эльдаровна	fedot91@kononov.ru	+79499247875	\N	2025-12-15
622	Анжела Макаровна Костина	zatsevafevronija@yahoo.com	\N	д. Тутаев	2025-03-08
575	Натан Дорофеевич Белоусов	makar_1997@prohorova.com	+79243311462	к. Владимир	2024-10-12
631	Павлов Иннокентий Артурович	januari1984@gmail.com	+79618853630	с. Ямбург	2024-12-05
577	Сысоева Алина Олеговна	sinklitikija50@gmail.com	\N	клх Гдов	2025-10-27
634	Соловьева Иванна Семеновна	blinovaaleksandra@gmail.com	+79616290544	с. Лабинск	2024-08-17
581	Иванна Егоровна Гуляева	borislav72@trofimova.ru	\N	д. Оленегорск (Якут.)	2023-09-17
640	Никифор Артёмович Стрелков	jaropolk1972@zao.info	\N	к. Хужир	2025-09-17
590	Кира Аскольдовна Силина	lavrenti52@ao.edu	+79207884688	г. Кизилюрт	2023-08-04
651	Адам Абрамович Чернов	noskovgennadi@ip.biz	+79234490716	ст. Артем	2024-02-23
600	Денисова Майя Тарасовна	lavr12@mishina.ru	+79996206898	д. Калевала	2024-08-12
655	Мартынова Акулина Юрьевна	marian_2008@vinogradova.net	+79430156867	д. Тавда	2026-03-28
604	Фаина Тарасовна Воронцова	rjabovaanzhela@rambler.ru	+79324945099	д. Краснокамск	2025-08-03
656	Беспалов Самуил Феликсович	german50@yandex.ru	+79109616847	к. Адыгейск	2026-03-15
616	Аникей Ермилович Сергеев	borislav98@mail.ru	\N	п. Котельнич	2025-12-07
663	Тимофеева Феврония Ниловна	ljubomir34@rao.org	+79255365396	с. Бугуруслан	2024-03-09
617	Анна Филипповна Ефимова	safonovipati@oao.ru	\N	к. Батайск	2026-01-15
664	Мартьян Антонович Колобов	valentin22@rao.info	\N	ст. Хужир	2025-07-05
618	Мирослав Трофимович Ефремов	mir1989@rambler.ru	\N	клх Белый Яр (Томск.)	2023-07-10
670	Эмилия Ждановна Громова	qkononova@yahoo.com	\N	к. Яр-Сале	2025-09-18
626	Константин Эдгардович Анисимов	zodintsova@yahoo.com	+79755039050	д. Неплюевка	2026-05-11
671	Иванов Бажен Абрамович	ipati_2016@hotmail.com	\N	г. Гаврилов-Ям	2025-02-02
628	Маслов Спиридон Марсович	sofija_2018@yandex.ru	\N	г. Диксон	2025-02-06
672	Дарья Георгиевна Петрова	kostinaekaterina@gmail.com	+79066503230	с. Тимашевск	\N
635	Суворова Лукия Ниловна	vasilisa52@suhanova.info	+79037931259	д. Красноуфимск	2026-05-16
673	Василиса Святославовна Григорьева	vladimirovvseslav@rao.biz	+79802178290	г. Аргаяш	2026-01-30
648	Зимин Захар Вячеславович	petrovapelageja@konar.biz	+79316290643	г. Яхрома	2025-01-04
675	Гришин Ладислав Бориславович	burovgerman@ooo.edu	+79401026552	п. Нарткала	2025-10-03
649	Агафья Олеговна Кабанова	shilovcheslav@mail.ru	\N	к. Приозерск	2023-11-28
677	Авдей Феодосьевич Ковалев	lavrenti2008@ip.info	+79377183091	п. Валаам	2025-06-11
650	Владилен Арсенович Виноградов	nikolaevolimpi@lanit.edu	\N	к. Апшеронск	2023-11-05
678	Большаков Всеволод Иосифович	denisovizot@yandex.ru	+79666003785	к. Новороссийка	2024-12-14
652	Алина Геннадьевна Сысоева	evstigne2014@zao.biz	+79078296722	к. Кош-Агач	2025-04-03
691	Полина Харитоновна Гришина	kostinatatjana@yandex.ru	+79223951923	к. Зарайск	2024-12-15
657	Моисеев Радован Валерьянович	jdavidova@gmail.com	+79137459855	клх Минеральные Воды	2025-09-29
700	Михеев Тимофей Даниилович	\N	\N	д. Объячево	2025-10-10
658	Боян Бориславович Пономарев	olimpi2021@npo.info	\N	к. Барнаул	2024-03-22
468	Абрамов Чеслав Валерьевич	rusakovataisija@natsionalnaja.org	\N	к. Новый Уренгой	2025-11-12
662	Радим Фадеевич Буров	sofonkomissarov@npo.net	\N	с. Ростов	2025-02-21
472	Дьячков Корнил Устинович	nadezhda81@mail.ru	+79527152884	к. Россошь	2025-09-22
666	Дементьева Евдокия Святославовна	vmaksimova@rao.biz	+79007756709	д. Карталы	2024-07-26
474	Тетерина Оксана Руслановна	karpovaninel@npo.ru	\N	клх Санкт-Петербург	2025-12-28
679	  ivan IVANOV 	petremeljanov@rambler.ru	+79466271010	к. Раменское	2024-04-09
477	Петр Яковлевич Жданов	jakov_34@zao.info	+79796065791	ст. Объячево	2026-03-29
684	г-н Дроздов Станимир Бориславович	slobanov@zao.com	\N	к. Ногинск (Моск.)	2026-05-11
478	Фаина Евгеньевна Брагина	cefimova@lokoteh.net	+79941420660	г. Снежинск	2023-06-03
688	Терентьев Венедикт Аксёнович	djachkovaraisa@ooo.net	+79754672588	клх Шереметьево	2024-11-28
480	Шаров Мина Якубович	ustin_09@ao.biz	\N	д. Можга	2025-02-20
692	Наталья Анатольевна Сысоева	bshirjaev@ooo.com	+79673532691	к. Вязьма	2026-03-17
481	Панфил Борисович Фокин	larionovfortunat@yandex.ru	\N	п. Астрахань	2025-02-21
696	Щукина Ульяна Валентиновна	\N	+79853042013	д. Волгоград	2025-05-30
483	Леонид Зиновьевич Михайлов	kudrjashovrjurik@ooo.biz	+79859910144	клх Тымовское	2023-09-16
697	Давыдов Фрол Адамович	evdokim_58@ip.com	+79334783336	клх Абинск	2024-07-29
489	Олимпий Аверьянович Ковалев	evstafimjasnikov@ooo.edu	\N	\N	2023-06-07
-1	Unknown	\N	\N	Unknown	\N
496	Щукина Жанна Дмитриевна	radovan_44@ip.biz	+79382281482	ст. Яшалта	2024-01-10
521	Клавдия Семеновна Суханова	ljudmila1989@yahoo.com	\N	п. Тобольск	2023-08-13
507	Варвара Николаевна Сорокина	martjan2014@oao.edu	+79697787747	п. Сосногорск	2024-07-28
532	Прохорова Ия Васильевна	filatovpankrati@oao.biz	+79828745466	клх Киров (Вятка)	2024-07-23
510	Рубен Витальевич Федосеев	blohinasinklitikija@filatov.com	+79692181541	с. Биробиджан	2023-07-14
534	Козлова Оксана Васильевна	nina_72@ip.biz	+79172167429	к. Курчатов	2024-12-19
511	Шарапов Парамон Давыдович	uignatov@rambler.ru	+79559350437	п. Усть-Ишим	\N
536	Власова Любовь Александровна	valentin_51@oao.com	\N	ст. Костомукша	2024-01-19
517	Велимир Викентьевич Миронов	sharapovaemilija@hotmail.com	\N	\N	2023-07-07
538	Стрелкова Ульяна Валентиновна	konstantinovfoma@npo.info	\N	п. Южноуральск	2023-09-04
523	  ivan IVANOV 	kirillovkapiton@ao.ru	\N	п. Нальчик	2024-05-15
540	Анисимова Акулина Архиповна	veniamin2012@hotmail.com	+79387541399	клх Набережные Челны	2026-02-18
527	Быков Ратмир Чеславович	taisija_1989@yahoo.com	\N	с. Ржев	2026-02-27
542	Мясников Федор Федосеевич	kasjan_1986@hotmail.com	+79296445934	клх Кириши	2023-12-05
528	Харитонова Оксана Матвеевна	simon1990@bank.biz	+79271992483	г. Ковров	2024-04-03
544	Воронцова Полина Никифоровна	sila1981@npo.ru	+79706019487	с. Кедровый	2024-06-03
529	Агата Григорьевна Некрасова	\N	+79466177523	п. Нижневартовск	2026-02-27
545	Нинель Альбертовна Веселова	vasilevvitali@rambler.ru	+79419655762	д. Лысьва	2025-07-09
546	Цветков Вышеслав Марсович	petrovmir@gmail.com	+79229703585	клх Адыгейск	2026-03-08
547	Панфилова Синклитикия Васильевна	pbogdanova@npo.com	+79639695468	г. Камышлов	2025-10-22
551	Вера Викторовна Щукина	vladimirovefrem@gmail.com	\N	г. Верхнее Пенжино	2023-12-13
549	Морозова Валентина Архиповна	merkushevaninel@yahoo.com	+79466964139	к. Губкинский	2024-04-07
554	Герасимов Лонгин Данилович	ogrigorev@yahoo.com	+79238462628	ст. Устюжна	2023-11-26
552	  ivan IVANOV 	osip1973@ooo.biz	\N	с. Сусуман	2026-04-11
557	Осипова Мария Владимировна	kornilovsilvestr@rambler.ru	\N	п. Шадринск	2024-04-03
553	Василий Гурьевич Никонов	konstantinovanaina@oao.biz	\N	к. Обоянь	2023-06-10
561	Владилен Феликсович Горбачев	zahar51@yahoo.com	+79683163679	д. Череповец	2023-08-14
559	Любовь Афанасьевна Харитонова	andronmjasnikov@zao.net	+79472944000	к. Ижевск	2025-02-16
571	Рожкова Марина Феликсовна	vlasovamarija@ooo.net	+79197713683	д. Минусинск	2025-07-18
562	Лидия Наумовна Федорова	pestovaveronika@tsvetkov.net	\N	ст. Катайск	2024-07-06
573	Вероника Макаровна Тарасова	konon76@hotmail.com	+79657518717	к. Тарко-Сале	2024-09-30
566	Эрнест Адрианович Родионов	kazakovisidor@hotmail.com	\N	к. Серпухов	2023-12-22
574	Савельева Алла Макаровна	borisovgalaktion@ao.com	\N	п. Каневская	2025-06-20
567	Будимир Елизарович Вишняков	kudrjashovsidor@rao.info	\N	ст. Устюжна	2023-06-10
578	Виссарион Витальевич Иванов	nalekseev@ershova.com	\N	к. Нарьян-Мар	2023-10-22
568	Агафья Ниловна Беспалова	pelageja_2007@yahoo.com	\N	к. Котлас	2024-02-15
583	Комиссарова София Альбертовна	epifan89@ip.info	\N	ст. Талдом	2025-04-05
569	Галина Эдуардовна Бобылева	jfilatova@gmail.com	+79774376779	д. Холмогоры	2024-12-03
585	Устинова Алла Петровна	matveevevdokim@hotmail.com	\N	п. Тикси	2025-10-13
570	Кириллова Ангелина Альбертовна	jakushevrodion@mail.ru	\N	к. Мытищи	2024-06-28
587	Самсонов Всеслав Георгиевич	xmakarova@hotmail.com	\N	п. Змеиногорск	2025-02-15
579	Селиверстов Селиверст Александрович	andreevfortunat@adidas.net	+79045543743	ст. Ербогачен	2023-06-01
589	Кулагина Лидия Филипповна	kirill1984@maslov.org	+79039428930	ст. Усть-Калманка	2024-11-13
588	Корнилов Кир Данилович	zatsevmaksim@mail.ru	+79262758762	клх Видное	2025-12-31
595	Цветкова Синклитикия Захаровна	komarovaklavdija@yandex.ru	+79534445451	к. Кировск (Ленин.)	2024-01-09
591	Карпова Евдокия Андреевна	filimon83@mail.ru	+79804592121	к. Казань	2025-12-19
596	Марфа Юльевна Денисова	ljubosmisl_05@npo.ru	\N	д. Александров	2026-01-12
592	Князева Любовь Ждановна	fedotovmilen@mail.ru	\N	г. Ельня	2024-07-05
599	Марфа Федоровна Емельянова	izmailvladimirov@mail.ru	\N	г. Люберцы	2025-08-05
593	тов. Лапина Таисия Архиповна	vsemilsharov@mail.ru	\N	клх Курильск	2025-07-05
605	Воронцова Жанна Игоревна	afinogenmedvedev@ooo.net	+79365196671	ст. Химки	2026-01-25
597	Орехов Андрей Димитриевич	gromovgavrila@oao.edu	+79358406707	к. Пинега	2026-02-07
608	Беляков Чеслав Архипович	feofan_52@gmail.com	\N	п. Витим	2023-12-10
598	Евграф Ааронович Молчанов	osipovgostomisl@ao.net	+79544053844	ст. Джубга	2024-10-05
614	Тарасов Орест Евсеевич	ilinasvetlana@yandex.ru	+79248779766	с. Ангарск	2025-10-06
602	Милица Антоновна Степанова	lkabanov@rambler.ru	+79033471933	г. Волхов	2025-02-18
615	Екатерина Аркадьевна Турова	panfilovelizar@ao.info	+79420989391	к. Сургут (Хант.)	2023-10-05
606	Афанасьева Василиса Романовна	saveli84@hotmail.com	\N	ст. Ардон	2025-05-11
619	Зиновий Ааронович Матвеев	zhdanovlazar@yandex.ru	\N	г. Анадырь	2025-07-10
609	Колесников Емельян Владиславович	simon14@rambler.ru	\N	п. Курганинск	2024-08-08
624	Фомичева София Харитоновна	dmitri_40@ooo.net	+79656583196	г. Хоста	2023-12-26
621	Муравьев Владислав Устинович	kimbolshakov@rao.com	+79768895851	ст. Приозерск	2025-03-14
625	Федорова Светлана Антоновна	igormatveev@oao.biz	+79967522662	д. Ельня	2025-04-17
623	Горбунов Глеб Ааронович	florentin_2005@gmail.com	\N	клх Середниково	2024-03-23
627	Игнатьева Таисия Вячеславовна	blohinazinaida@gmail.com	+79202107025	с. Камышин	2026-01-22
630	Регина Святославовна Субботина	vladislav1999@npo.edu	\N	с. Нарьян-Мар	2024-06-19
629	Фаина Ильинична Коновалова	bespalovaeleonora@ao.edu	\N	п. Шали	2025-01-02
638	Антонина Ниловна Богданова	\N	+79397034107	с. Александров	2024-12-30
632	Елена Кирилловна Федосеева	loginovaija@ao.ru	\N	с. Новороссийка	2024-01-05
642	Оксана Алексеевна Степанова	faina19@ooo.info	+79569355272	д. Красная Поляна	2025-07-22
633	Медведева Екатерина Эльдаровна	ignatovfeoktist@yandex.ru	+79578958595	к. Кинешма	2025-07-06
643	Фирс Аверьянович Агафонов	ignatiromanov@gmail.com	\N	ст. Биробиджан	2024-02-17
636	Лора Матвеевна Маркова	amosustinov@npo.edu	+79520507291	клх Тула	2024-08-02
644	Лебедев Мечислав Ерофеевич	modestkulakov@npo.edu	+79953479685	ст. Улан-Удэ	2025-09-14
637	Юлий Владленович Кузнецов	novikovnikita@rao.ru	+79353814211	п. Соль-Илецк	2025-04-25
646	Евгения Станиславовна Жданова	shestakovaelizaveta@yandex.ru	+79241341389	ст. Тавда	2025-01-25
639	Таисия Максимовна Горбачева	janbaranov@zao.biz	+79199577362	с. Кулунда	2026-03-26
647	Харитонова Таисия Алексеевна	filaret47@oao.org	\N	ст. Тутончаны	2025-06-25
641	Фаина Болеславовна Пахомова	isakovkliment@zao.com	\N	\N	2024-11-22
659	Петр Васильевич Зуев	ekulikov@npo.biz	+79571161453	с. Можайск	2026-04-25
645	Дарья Федоровна Константинова	tit1973@rao.org	+79861081811	к. Оренбург	2023-10-14
660	Харитонов Владимир Эдуардович	apollinari_97@ooo.org	+79665699678	к. Мичуринск	2025-05-05
653	Октябрина Степановна Силина	julian_29@mironov.ru	\N	ст. Беломорск	\N
667	Аникей Даниилович Филиппов	miheevvarlaam@ignatov.biz	+79985879826	с. Кулунда	2025-03-27
654	Щербакова Светлана Рубеновна	noskovvisheslav@yahoo.com	\N	п. Темрюк	\N
668	Агафонов Роман Феоктистович	milan1982@mail.ru	+79770086298	г. Волхов	2024-12-18
661	  ivan IVANOV 	karp_07@oao.com	+79753011714	клх Баргузин	2025-06-21
669	Константинов Евдоким Антонович	viktorija_48@zao.ru	\N	с. Кирово-Чепецк	2024-02-23
665	Мария Захаровна Лукина	evstafi2011@gorshkov.edu	\N	с. Выборг	2024-08-15
674	Дмитрий Филатович Степанов	mefodi1990@hotmail.com	\N	к. Обоянь	2024-04-01
676	Павлов Измаил Виленович	glafira1994@yahoo.com	+79048088217	г. Тавда	2026-01-13
683	Гаврилов Ладислав Афанасьевич	juri2013@yandex.ru	+79497959196	п. Муром	2023-09-15
680	Валентина Борисовна Бирюкова	sevastjanblohin@kmr.ru	+79787564180	ст. Бузулук	2024-08-21
694	Лора Яковлевна Сысоева	arhipovfoti@oao.org	+79896428066	г. Ясный (Оренб.)	2024-06-07
681	Феликс Ермилович Сидоров	karl57@ip.info	+79106711198	клх Щелково	2026-04-29
695	Татьяна Тимуровна Шестакова	azarikrjukov@ooo.info	+79614804616	г. Жиганск	2026-02-14
682	Гришина Наина Богдановна	prohorovelizar@yahoo.com	+79097420069	п. Краснодар	2024-05-16
699	Бобылева Нонна Ниловна	drogov@ooo.com	\N	к. Валдай	2024-03-28
685	Комиссаров Карп Димитриевич	kolesnikovanani@egorova.com	+79666208705	с. Териберка	2025-04-18
686	Быкова София Болеславовна	zhanna_11@yandex.ru	+79119149420	с. Фатеж	2023-10-16
687	Тетерина Мария Ждановна	evgenija1997@rao.edu	\N	д. Балтийск	2023-11-03
689	Игнатьев Леон Валерьевич	gorbachevairina@mail.ru	\N	к. Владикавказ	2023-07-30
690	Некрасов Ладимир Ильясович	dementevljubomir@ip.edu	\N	клх Кызыл	2024-11-24
693	Белозеров Агафон Филимонович	sidor_61@yahoo.com	+79692211324	г. Арсеньев	2025-07-25
698	Сократ Владиславович Мельников	mishinignati@general.edu	\N	п. Качканар	\N
\.


--
-- TOC entry 2534 (class 0 OID 49481)
-- Dependencies: 275
-- Data for Name: dim_date; Type: TABLE DATA; Schema: dim; Owner: gpadmin
--

COPY dim.dim_date (date_id, year, month, day, quarter, year_month) FROM stdin;
2024-09-25	2024	9	25	3	2024-09
2025-11-12	2025	11	12	4	2025-11
2025-11-06	2025	11	6	4	2025-11
2025-02-03	2025	2	3	1	2025-02
2026-04-26	2026	4	26	2	2026-04
2025-09-15	2025	9	15	3	2025-09
2024-11-15	2024	11	15	4	2024-11
2024-10-10	2024	10	10	4	2024-10
2026-01-13	2026	1	13	1	2026-01
2025-06-03	2025	6	3	2	2025-06
2024-11-09	2024	11	9	4	2024-11
2025-02-28	2025	2	28	1	2025-02
2024-07-18	2024	7	18	3	2024-07
2025-12-22	2025	12	22	4	2025-12
2025-08-10	2025	8	10	3	2025-08
2025-04-08	2025	4	8	2	2025-04
2025-04-06	2025	4	6	2	2025-04
2024-08-15	2024	8	15	3	2024-08
2025-06-27	2025	6	27	2	2025-06
2024-06-30	2024	6	30	2	2024-06
2025-08-07	2025	8	7	3	2025-08
2024-11-13	2024	11	13	4	2024-11
2024-11-19	2024	11	19	4	2024-11
2024-08-13	2024	8	13	3	2024-08
2024-11-30	2024	11	30	4	2024-11
2025-03-07	2025	3	7	1	2025-03
2025-09-02	2025	9	2	3	2025-09
2025-05-09	2025	5	9	2	2025-05
2025-08-09	2025	8	9	3	2025-08
2024-07-26	2024	7	26	3	2024-07
2025-12-18	2025	12	18	4	2025-12
2026-05-13	2026	5	13	2	2026-05
2026-02-25	2026	2	25	1	2026-02
2024-05-26	2024	5	26	2	2024-05
2025-04-25	2025	4	25	2	2025-04
2024-10-12	2024	10	12	4	2024-10
2024-11-06	2024	11	6	4	2024-11
2025-08-02	2025	8	2	3	2025-08
2025-04-14	2025	4	14	2	2025-04
2024-07-12	2024	7	12	3	2024-07
2024-11-20	2024	11	20	4	2024-11
2024-08-18	2024	8	18	3	2024-08
2024-12-16	2024	12	16	4	2024-12
2026-03-09	2026	3	9	1	2026-03
2025-12-01	2025	12	1	4	2025-12
2025-09-07	2025	9	7	3	2025-09
2026-03-24	2026	3	24	1	2026-03
2024-08-03	2024	8	3	3	2024-08
2026-05-04	2026	5	4	2	2026-05
2024-12-23	2024	12	23	4	2024-12
2024-08-22	2024	8	22	3	2024-08
2026-05-08	2026	5	8	2	2026-05
2025-09-14	2025	9	14	3	2025-09
2025-04-04	2025	4	4	2	2025-04
2024-11-11	2024	11	11	4	2024-11
2025-10-25	2025	10	25	4	2025-10
2025-03-15	2025	3	15	1	2025-03
2025-06-19	2025	6	19	2	2025-06
2025-01-17	2025	1	17	1	2025-01
2024-06-12	2024	6	12	2	2024-06
2026-01-18	2026	1	18	1	2026-01
2024-12-12	2024	12	12	4	2024-12
2025-06-16	2025	6	16	2	2025-06
2025-12-21	2025	12	21	4	2025-12
2024-07-28	2024	7	28	3	2024-07
2024-09-22	2024	9	22	3	2024-09
2026-03-08	2026	3	8	1	2026-03
2025-02-02	2025	2	2	1	2025-02
2025-01-12	2025	1	12	1	2025-01
2025-12-04	2025	12	4	4	2025-12
2024-06-08	2024	6	8	2	2024-06
2025-03-26	2025	3	26	1	2025-03
2025-01-16	2025	1	16	1	2025-01
2026-03-30	2026	3	30	1	2026-03
2025-01-15	2025	1	15	1	2025-01
2026-01-07	2026	1	7	1	2026-01
2024-08-11	2024	8	11	3	2024-08
2025-04-12	2025	4	12	2	2025-04
2025-08-21	2025	8	21	3	2025-08
2025-08-08	2025	8	8	3	2025-08
2024-12-09	2024	12	9	4	2024-12
2024-10-08	2024	10	8	4	2024-10
2025-09-01	2025	9	1	3	2025-09
2025-05-15	2025	5	15	2	2025-05
2026-04-05	2026	4	5	2	2026-04
2024-11-10	2024	11	10	4	2024-11
2024-06-24	2024	6	24	2	2024-06
2025-07-20	2025	7	20	3	2025-07
2024-10-29	2024	10	29	4	2024-10
2026-02-17	2026	2	17	1	2026-02
2025-11-13	2025	11	13	4	2025-11
2026-04-23	2026	4	23	2	2026-04
2025-11-03	2025	11	3	4	2025-11
2025-06-17	2025	6	17	2	2025-06
2025-01-31	2025	1	31	1	2025-01
2026-01-04	2026	1	4	1	2026-01
2025-02-24	2025	2	24	1	2025-02
2024-12-10	2024	12	10	4	2024-12
2025-02-09	2025	2	9	1	2025-02
2025-05-16	2025	5	16	2	2025-05
2026-03-17	2026	3	17	1	2026-03
2025-11-01	2025	11	1	4	2025-11
2025-01-08	2025	1	8	1	2025-01
2024-12-31	2024	12	31	4	2024-12
2024-07-24	2024	7	24	3	2024-07
2024-09-05	2024	9	5	3	2024-09
2024-06-04	2024	6	4	2	2024-06
2024-10-31	2024	10	31	4	2024-10
2025-06-02	2025	6	2	2	2025-06
2024-10-16	2024	10	16	4	2024-10
2025-08-31	2025	8	31	3	2025-08
2025-09-25	2025	9	25	3	2025-09
2026-04-10	2026	4	10	2	2026-04
2025-01-26	2025	1	26	1	2025-01
2025-02-05	2025	2	5	1	2025-02
2024-07-15	2024	7	15	3	2024-07
2025-01-01	2025	1	1	1	2025-01
2024-08-07	2024	8	7	3	2024-08
2025-03-12	2025	3	12	1	2025-03
2024-09-18	2024	9	18	3	2024-09
2026-01-23	2026	1	23	1	2026-01
2025-04-02	2025	4	2	2	2025-04
2025-02-25	2025	2	25	1	2025-02
2025-01-05	2025	1	5	1	2025-01
2024-07-09	2024	7	9	3	2024-07
2024-08-31	2024	8	31	3	2024-08
2025-05-28	2025	5	28	2	2025-05
2025-07-15	2025	7	15	3	2025-07
2024-06-26	2024	6	26	2	2024-06
2025-09-24	2025	9	24	3	2025-09
2025-05-11	2025	5	11	2	2025-05
2025-03-24	2025	3	24	1	2025-03
2026-01-11	2026	1	11	1	2026-01
2025-12-05	2025	12	5	4	2025-12
2024-10-09	2024	10	9	4	2024-10
2024-10-07	2024	10	7	4	2024-10
2024-06-19	2024	6	19	2	2024-06
2024-07-02	2024	7	2	3	2024-07
2025-09-06	2025	9	6	3	2025-09
2025-09-16	2025	9	16	3	2025-09
2025-10-08	2025	10	8	4	2025-10
2025-03-04	2025	3	4	1	2025-03
2025-05-18	2025	5	18	2	2025-05
2026-05-11	2026	5	11	2	2026-05
2025-03-18	2025	3	18	1	2025-03
2025-07-31	2025	7	31	3	2025-07
2025-08-24	2025	8	24	3	2025-08
2026-01-17	2026	1	17	1	2026-01
2024-06-06	2024	6	6	2	2024-06
2024-06-27	2024	6	27	2	2024-06
2025-02-23	2025	2	23	1	2025-02
2025-10-29	2025	10	29	4	2025-10
2026-04-11	2026	4	11	2	2026-04
2025-01-29	2025	1	29	1	2025-01
2025-06-30	2025	6	30	2	2025-06
2026-03-26	2026	3	26	1	2026-03
2026-01-31	2026	1	31	1	2026-01
2025-05-26	2025	5	26	2	2025-05
2024-08-16	2024	8	16	3	2024-08
2025-01-27	2025	1	27	1	2025-01
2025-09-17	2025	9	17	3	2025-09
2025-02-27	2025	2	27	1	2025-02
2026-05-16	2026	5	16	2	2026-05
2025-08-26	2025	8	26	3	2025-08
2024-11-12	2024	11	12	4	2024-11
2026-04-14	2026	4	14	2	2026-04
2024-11-28	2024	11	28	4	2024-11
2026-03-14	2026	3	14	1	2026-03
2025-02-12	2025	2	12	1	2025-02
2026-03-25	2026	3	25	1	2026-03
2024-12-18	2024	12	18	4	2024-12
2024-08-29	2024	8	29	3	2024-08
2025-02-13	2025	2	13	1	2025-02
2024-07-19	2024	7	19	3	2024-07
2024-07-14	2024	7	14	3	2024-07
2024-10-21	2024	10	21	4	2024-10
2025-07-10	2025	7	10	3	2025-07
2025-10-18	2025	10	18	4	2025-10
2025-07-17	2025	7	17	3	2025-07
2026-03-01	2026	3	1	1	2026-03
2024-10-06	2024	10	6	4	2024-10
2024-10-03	2024	10	3	4	2024-10
2025-02-07	2025	2	7	1	2025-02
2024-08-30	2024	8	30	3	2024-08
2026-03-23	2026	3	23	1	2026-03
2025-05-24	2025	5	24	2	2025-05
2025-07-08	2025	7	8	3	2025-07
2025-07-18	2025	7	18	3	2025-07
2024-06-15	2024	6	15	2	2024-06
2024-12-22	2024	12	22	4	2024-12
2025-12-16	2025	12	16	4	2025-12
2024-09-15	2024	9	15	3	2024-09
2024-09-26	2024	9	26	3	2024-09
2024-09-14	2024	9	14	3	2024-09
2025-10-06	2025	10	6	4	2025-10
2025-07-30	2025	7	30	3	2025-07
2025-05-10	2025	5	10	2	2025-05
2024-05-27	2024	5	27	2	2024-05
2024-11-29	2024	11	29	4	2024-11
2026-01-14	2026	1	14	1	2026-01
2024-12-13	2024	12	13	4	2024-12
2024-12-27	2024	12	27	4	2024-12
2025-02-06	2025	2	6	1	2025-02
2025-08-04	2025	8	4	3	2025-08
2025-03-13	2025	3	13	1	2025-03
2026-01-20	2026	1	20	1	2026-01
2024-07-17	2024	7	17	3	2024-07
2026-01-05	2026	1	5	1	2026-01
2025-10-24	2025	10	24	4	2025-10
2024-05-29	2024	5	29	2	2024-05
2025-04-16	2025	4	16	2	2025-04
2024-07-10	2024	7	10	3	2024-07
2024-11-07	2024	11	7	4	2024-11
2024-10-13	2024	10	13	4	2024-10
2026-05-17	2026	5	17	2	2026-05
2025-09-04	2025	9	4	3	2025-09
2025-05-29	2025	5	29	2	2025-05
2025-01-20	2025	1	20	1	2025-01
2025-05-31	2025	5	31	2	2025-05
2025-10-28	2025	10	28	4	2025-10
2025-05-25	2025	5	25	2	2025-05
2024-10-25	2024	10	25	4	2024-10
2026-04-08	2026	4	8	2	2026-04
2024-05-31	2024	5	31	2	2024-05
2025-02-22	2025	2	22	1	2025-02
2024-11-23	2024	11	23	4	2024-11
2025-04-18	2025	4	18	2	2025-04
2024-10-02	2024	10	2	4	2024-10
2024-12-14	2024	12	14	4	2024-12
2025-01-19	2025	1	19	1	2025-01
2026-05-14	2026	5	14	2	2026-05
2026-02-24	2026	2	24	1	2026-02
2025-08-30	2025	8	30	3	2025-08
2024-12-30	2024	12	30	4	2024-12
2025-02-26	2025	2	26	1	2025-02
2024-08-02	2024	8	2	3	2024-08
2026-02-11	2026	2	11	1	2026-02
2026-05-21	2026	5	21	2	2026-05
2024-08-17	2024	8	17	3	2024-08
2025-02-11	2025	2	11	1	2025-02
2025-08-29	2025	8	29	3	2025-08
2024-07-16	2024	7	16	3	2024-07
2025-11-25	2025	11	25	4	2025-11
2025-08-18	2025	8	18	3	2025-08
2025-08-16	2025	8	16	3	2025-08
2025-03-05	2025	3	5	1	2025-03
2025-10-12	2025	10	12	4	2025-10
2025-01-06	2025	1	6	1	2025-01
2025-12-02	2025	12	2	4	2025-12
2024-08-19	2024	8	19	3	2024-08
2025-11-22	2025	11	22	4	2025-11
2026-02-15	2026	2	15	1	2026-02
2024-12-07	2024	12	7	4	2024-12
2024-11-04	2024	11	4	4	2024-11
2025-02-18	2025	2	18	1	2025-02
2026-02-26	2026	2	26	1	2026-02
2025-02-19	2025	2	19	1	2025-02
2024-11-17	2024	11	17	4	2024-11
2025-04-11	2025	4	11	2	2025-04
2024-07-07	2024	7	7	3	2024-07
2024-11-22	2024	11	22	4	2024-11
2025-05-20	2025	5	20	2	2025-05
2025-12-23	2025	12	23	4	2025-12
2026-02-27	2026	2	27	1	2026-02
2025-10-27	2025	10	27	4	2025-10
2024-07-11	2024	7	11	3	2024-07
2026-04-13	2026	4	13	2	2026-04
2024-09-23	2024	9	23	3	2024-09
2025-05-13	2025	5	13	2	2025-05
2026-05-19	2026	5	19	2	2026-05
2024-08-01	2024	8	1	3	2024-08
2025-05-03	2025	5	3	2	2025-05
2025-09-30	2025	9	30	3	2025-09
2025-09-28	2025	9	28	3	2025-09
2025-07-26	2025	7	26	3	2025-07
2024-05-24	2024	5	24	2	2024-05
2026-04-18	2026	4	18	2	2026-04
2026-05-10	2026	5	10	2	2026-05
2025-10-16	2025	10	16	4	2025-10
2026-04-17	2026	4	17	2	2026-04
2024-06-23	2024	6	23	2	2024-06
2024-07-13	2024	7	13	3	2024-07
2026-03-13	2026	3	13	1	2026-03
2025-11-07	2025	11	7	4	2025-11
2025-08-06	2025	8	6	3	2025-08
2026-03-31	2026	3	31	1	2026-03
2024-09-03	2024	9	3	3	2024-09
2024-12-20	2024	12	20	4	2024-12
2025-10-04	2025	10	4	4	2025-10
2025-01-14	2025	1	14	1	2025-01
2025-01-09	2025	1	9	1	2025-01
2025-07-14	2025	7	14	3	2025-07
2025-11-21	2025	11	21	4	2025-11
2025-04-09	2025	4	9	2	2025-04
2024-06-16	2024	6	16	2	2024-06
2026-01-01	2026	1	1	1	2026-01
2026-01-21	2026	1	21	1	2026-01
2024-12-24	2024	12	24	4	2024-12
2026-01-22	2026	1	22	1	2026-01
2025-06-21	2025	6	21	2	2025-06
2025-06-12	2025	6	12	2	2025-06
2025-05-12	2025	5	12	2	2025-05
2024-09-19	2024	9	19	3	2024-09
2025-09-03	2025	9	3	3	2025-09
2024-10-26	2024	10	26	4	2024-10
2025-10-19	2025	10	19	4	2025-10
2025-02-08	2025	2	8	1	2025-02
2024-12-28	2024	12	28	4	2024-12
2026-05-02	2026	5	2	2	2026-05
2024-09-02	2024	9	2	3	2024-09
2025-12-14	2025	12	14	4	2025-12
2026-02-02	2026	2	2	1	2026-02
2026-03-21	2026	3	21	1	2026-03
2024-12-25	2024	12	25	4	2024-12
2025-07-25	2025	7	25	3	2025-07
2024-10-20	2024	10	20	4	2024-10
2024-10-14	2024	10	14	4	2024-10
2025-12-25	2025	12	25	4	2025-12
2024-11-25	2024	11	25	4	2024-11
2024-11-26	2024	11	26	4	2024-11
2025-11-24	2025	11	24	4	2025-11
2026-05-15	2026	5	15	2	2026-05
2024-06-21	2024	6	21	2	2024-06
2025-08-28	2025	8	28	3	2025-08
2025-01-11	2025	1	11	1	2025-01
2024-08-24	2024	8	24	3	2024-08
2024-05-30	2024	5	30	2	2024-05
2025-11-27	2025	11	27	4	2025-11
2026-02-08	2026	2	8	1	2026-02
2024-10-05	2024	10	5	4	2024-10
2025-05-08	2025	5	8	2	2025-05
2025-04-15	2025	4	15	2	2025-04
2025-08-20	2025	8	20	3	2025-08
2025-04-28	2025	4	28	2	2025-04
2025-11-18	2025	11	18	4	2025-11
2024-07-30	2024	7	30	3	2024-07
2025-06-26	2025	6	26	2	2025-06
2026-03-27	2026	3	27	1	2026-03
2025-08-17	2025	8	17	3	2025-08
2025-07-11	2025	7	11	3	2025-07
2024-10-28	2024	10	28	4	2024-10
2025-04-21	2025	4	21	2	2025-04
2025-05-17	2025	5	17	2	2025-05
2026-04-27	2026	4	27	2	2026-04
2025-10-14	2025	10	14	4	2025-10
2025-07-16	2025	7	16	3	2025-07
2026-02-06	2026	2	6	1	2026-02
2025-04-05	2025	4	5	2	2025-04
2025-09-08	2025	9	8	3	2025-09
2025-04-01	2025	4	1	2	2025-04
2025-04-07	2025	4	7	2	2025-04
2024-10-30	2024	10	30	4	2024-10
2025-10-01	2025	10	1	4	2025-10
2026-04-20	2026	4	20	2	2026-04
2025-11-10	2025	11	10	4	2025-11
2026-03-19	2026	3	19	1	2026-03
2025-03-10	2025	3	10	1	2025-03
2026-03-15	2026	3	15	1	2026-03
2025-09-23	2025	9	23	3	2025-09
2024-11-16	2024	11	16	4	2024-11
2024-12-21	2024	12	21	4	2024-12
2026-02-14	2026	2	14	1	2026-02
2024-08-21	2024	8	21	3	2024-08
2024-11-03	2024	11	3	4	2024-11
2025-01-21	2025	1	21	1	2025-01
2024-09-16	2024	9	16	3	2024-09
2025-12-28	2025	12	28	4	2025-12
2024-10-01	2024	10	1	4	2024-10
2026-02-16	2026	2	16	1	2026-02
2024-11-24	2024	11	24	4	2024-11
2025-09-12	2025	9	12	3	2025-09
2026-05-12	2026	5	12	2	2026-05
2024-12-19	2024	12	19	4	2024-12
2024-10-27	2024	10	27	4	2024-10
2024-08-06	2024	8	6	3	2024-08
2026-03-22	2026	3	22	1	2026-03
2025-03-14	2025	3	14	1	2025-03
2024-10-19	2024	10	19	4	2024-10
2024-11-14	2024	11	14	4	2024-11
2025-04-22	2025	4	22	2	2025-04
2026-03-06	2026	3	6	1	2026-03
2026-03-18	2026	3	18	1	2026-03
2025-11-29	2025	11	29	4	2025-11
2026-05-18	2026	5	18	2	2026-05
2025-10-09	2025	10	9	4	2025-10
2025-09-26	2025	9	26	3	2025-09
2025-08-27	2025	8	27	3	2025-08
2025-07-05	2025	7	5	3	2025-07
2024-09-08	2024	9	8	3	2024-09
2024-12-04	2024	12	4	4	2024-12
2025-10-10	2025	10	10	4	2025-10
2024-11-01	2024	11	1	4	2024-11
2025-11-30	2025	11	30	4	2025-11
2026-01-30	2026	1	30	1	2026-01
2025-07-27	2025	7	27	3	2025-07
2025-01-30	2025	1	30	1	2025-01
2025-09-10	2025	9	10	3	2025-09
2025-06-08	2025	6	8	2	2025-06
2024-08-23	2024	8	23	3	2024-08
2024-09-24	2024	9	24	3	2024-09
2024-06-17	2024	6	17	2	2024-06
2025-04-03	2025	4	3	2	2025-04
2024-11-18	2024	11	18	4	2024-11
2026-04-24	2026	4	24	2	2026-04
2025-05-01	2025	5	1	2	2025-05
2026-05-23	2026	5	23	2	2026-05
2024-11-21	2024	11	21	4	2024-11
2026-03-05	2026	3	5	1	2026-03
2025-12-11	2025	12	11	4	2025-12
2026-04-22	2026	4	22	2	2026-04
2025-03-02	2025	3	2	1	2025-03
2025-10-26	2025	10	26	4	2025-10
2025-06-01	2025	6	1	2	2025-06
2025-12-10	2025	12	10	4	2025-12
2024-09-07	2024	9	7	3	2024-09
2025-10-13	2025	10	13	4	2025-10
2024-10-23	2024	10	23	4	2024-10
2025-09-09	2025	9	9	3	2025-09
2025-09-05	2025	9	5	3	2025-09
2025-05-14	2025	5	14	2	2025-05
2025-10-11	2025	10	11	4	2025-10
2025-05-22	2025	5	22	2	2025-05
2025-07-07	2025	7	7	3	2025-07
2026-01-09	2026	1	9	1	2026-01
2024-07-22	2024	7	22	3	2024-07
2025-04-26	2025	4	26	2	2025-04
2024-11-08	2024	11	8	4	2024-11
2025-06-20	2025	6	20	2	2025-06
2025-08-22	2025	8	22	3	2025-08
2025-08-03	2025	8	3	3	2025-08
2026-04-21	2026	4	21	2	2026-04
2025-06-22	2025	6	22	2	2025-06
2024-08-09	2024	8	9	3	2024-08
2025-01-22	2025	1	22	1	2025-01
2024-08-27	2024	8	27	3	2024-08
2024-10-24	2024	10	24	4	2024-10
2025-11-16	2025	11	16	4	2025-11
2024-08-10	2024	8	10	3	2024-08
2025-11-04	2025	11	4	4	2025-11
2024-12-11	2024	12	11	4	2024-12
2026-03-10	2026	3	10	1	2026-03
2024-06-25	2024	6	25	2	2024-06
2024-07-31	2024	7	31	3	2024-07
2025-12-09	2025	12	9	4	2025-12
2026-04-28	2026	4	28	2	2026-04
2025-07-06	2025	7	6	3	2025-07
2025-01-07	2025	1	7	1	2025-01
2025-06-13	2025	6	13	2	2025-06
2024-09-09	2024	9	9	3	2024-09
2025-04-27	2025	4	27	2	2025-04
2025-11-08	2025	11	8	4	2025-11
2026-01-29	2026	1	29	1	2026-01
2025-09-18	2025	9	18	3	2025-09
2024-07-27	2024	7	27	3	2024-07
2026-01-25	2026	1	25	1	2026-01
2025-07-24	2025	7	24	3	2025-07
2026-01-19	2026	1	19	1	2026-01
2025-11-05	2025	11	5	4	2025-11
2025-03-23	2025	3	23	1	2025-03
2025-10-20	2025	10	20	4	2025-10
2025-07-01	2025	7	1	3	2025-07
2026-02-21	2026	2	21	1	2026-02
2024-06-22	2024	6	22	2	2024-06
2025-03-17	2025	3	17	1	2025-03
2024-06-11	2024	6	11	2	2024-06
2025-03-09	2025	3	9	1	2025-03
2024-08-08	2024	8	8	3	2024-08
2024-12-05	2024	12	5	4	2024-12
2025-07-09	2025	7	9	3	2025-07
2026-04-15	2026	4	15	2	2026-04
2025-08-15	2025	8	15	3	2025-08
2025-12-31	2025	12	31	4	2025-12
2024-09-01	2024	9	1	3	2024-09
2026-03-03	2026	3	3	1	2026-03
2026-01-26	2026	1	26	1	2026-01
2025-01-02	2025	1	2	1	2025-01
2026-02-18	2026	2	18	1	2026-02
2024-10-15	2024	10	15	4	2024-10
2025-09-21	2025	9	21	3	2025-09
2026-02-10	2026	2	10	1	2026-02
2026-05-01	2026	5	1	2	2026-05
2025-07-19	2025	7	19	3	2025-07
2026-04-07	2026	4	7	2	2026-04
2024-12-02	2024	12	2	4	2024-12
2026-04-09	2026	4	9	2	2026-04
2025-04-17	2025	4	17	2	2025-04
2024-08-04	2024	8	4	3	2024-08
2026-02-12	2026	2	12	1	2026-02
2025-06-11	2025	6	11	2	2025-06
2025-08-12	2025	8	12	3	2025-08
2025-10-22	2025	10	22	4	2025-10
2025-07-29	2025	7	29	3	2025-07
2026-04-29	2026	4	29	2	2026-04
2024-07-03	2024	7	3	3	2024-07
2024-10-04	2024	10	4	4	2024-10
2025-06-09	2025	6	9	2	2025-06
2024-06-05	2024	6	5	2	2024-06
2025-10-15	2025	10	15	4	2025-10
2026-05-22	2026	5	22	2	2026-05
2025-12-06	2025	12	6	4	2025-12
2026-02-22	2026	2	22	1	2026-02
2025-12-29	2025	12	29	4	2025-12
2025-06-14	2025	6	14	2	2025-06
2025-02-04	2025	2	4	1	2025-02
2025-08-23	2025	8	23	3	2025-08
2025-05-19	2025	5	19	2	2025-05
2025-07-03	2025	7	3	3	2025-07
2026-02-23	2026	2	23	1	2026-02
2025-06-04	2025	6	4	2	2025-06
2024-12-26	2024	12	26	4	2024-12
2025-03-03	2025	3	3	1	2025-03
2024-07-04	2024	7	4	3	2024-07
2026-04-16	2026	4	16	2	2026-04
2026-02-07	2026	2	7	1	2026-02
2025-09-27	2025	9	27	3	2025-09
2024-06-13	2024	6	13	2	2024-06
2025-07-23	2025	7	23	3	2025-07
2025-04-24	2025	4	24	2	2025-04
2025-01-04	2025	1	4	1	2025-01
2025-11-14	2025	11	14	4	2025-11
2025-01-10	2025	1	10	1	2025-01
2024-06-03	2024	6	3	2	2024-06
2026-04-02	2026	4	2	2	2026-04
2025-06-15	2025	6	15	2	2025-06
2024-12-03	2024	12	3	4	2024-12
2026-03-02	2026	3	2	1	2026-03
2024-09-21	2024	9	21	3	2024-09
2025-02-17	2025	2	17	1	2025-02
2025-01-24	2025	1	24	1	2025-01
2026-03-12	2026	3	12	1	2026-03
2024-06-28	2024	6	28	2	2024-06
2024-11-27	2024	11	27	4	2024-11
2025-10-05	2025	10	5	4	2025-10
2026-05-07	2026	5	7	2	2026-05
2025-09-19	2025	9	19	3	2025-09
2026-01-06	2026	1	6	1	2026-01
2024-09-04	2024	9	4	3	2024-09
2025-04-13	2025	4	13	2	2025-04
2025-01-03	2025	1	3	1	2025-01
2024-09-20	2024	9	20	3	2024-09
2025-06-28	2025	6	28	2	2025-06
2025-07-22	2025	7	22	3	2025-07
2026-04-12	2026	4	12	2	2026-04
2026-04-06	2026	4	6	2	2026-04
2025-03-21	2025	3	21	1	2025-03
2025-10-03	2025	10	3	4	2025-10
2025-03-20	2025	3	20	1	2025-03
2024-12-08	2024	12	8	4	2024-12
2024-07-21	2024	7	21	3	2024-07
2025-07-28	2025	7	28	3	2025-07
2025-01-23	2025	1	23	1	2025-01
2025-10-21	2025	10	21	4	2025-10
2025-02-21	2025	2	21	1	2025-02
2025-01-18	2025	1	18	1	2025-01
2025-04-23	2025	4	23	2	2025-04
2024-09-17	2024	9	17	3	2024-09
2025-03-19	2025	3	19	1	2025-03
2026-04-30	2026	4	30	2	2026-04
2025-11-11	2025	11	11	4	2025-11
2024-06-02	2024	6	2	2	2024-06
2025-12-12	2025	12	12	4	2025-12
2026-02-05	2026	2	5	1	2026-02
2024-07-20	2024	7	20	3	2024-07
2025-10-17	2025	10	17	4	2025-10
2026-03-29	2026	3	29	1	2026-03
2024-06-01	2024	6	1	2	2024-06
2025-02-15	2025	2	15	1	2025-02
2025-04-10	2025	4	10	2	2025-04
2024-07-05	2024	7	5	3	2024-07
2025-07-13	2025	7	13	3	2025-07
2025-01-13	2025	1	13	1	2025-01
2026-01-27	2026	1	27	1	2026-01
2026-01-03	2026	1	3	1	2026-01
2024-05-25	2024	5	25	2	2024-05
2025-07-21	2025	7	21	3	2025-07
2025-05-05	2025	5	5	2	2025-05
2026-03-04	2026	3	4	1	2026-03
2025-10-02	2025	10	2	4	2025-10
2026-01-12	2026	1	12	1	2026-01
2024-08-14	2024	8	14	3	2024-08
2026-01-10	2026	1	10	1	2026-01
2024-07-06	2024	7	6	3	2024-07
2025-05-02	2025	5	2	2	2025-05
2025-07-02	2025	7	2	3	2025-07
2026-03-11	2026	3	11	1	2026-03
2025-06-24	2025	6	24	2	2025-06
2024-06-07	2024	6	7	2	2024-06
2024-05-28	2024	5	28	2	2024-05
2026-04-01	2026	4	1	2	2026-04
2025-08-19	2025	8	19	3	2025-08
2025-12-27	2025	12	27	4	2025-12
2025-09-22	2025	9	22	3	2025-09
2025-10-07	2025	10	7	4	2025-10
2025-06-06	2025	6	6	2	2025-06
2025-05-21	2025	5	21	2	2025-05
2025-12-19	2025	12	19	4	2025-12
2025-04-19	2025	4	19	2	2025-04
2024-06-10	2024	6	10	2	2024-06
2024-07-29	2024	7	29	3	2024-07
2025-03-08	2025	3	8	1	2025-03
2025-12-20	2025	12	20	4	2025-12
2026-05-24	2026	5	24	2	2026-05
2024-08-12	2024	8	12	3	2024-08
2026-01-08	2026	1	8	1	2026-01
2025-09-11	2025	9	11	3	2025-09
2025-11-02	2025	11	2	4	2025-11
2026-03-20	2026	3	20	1	2026-03
2024-12-01	2024	12	1	4	2024-12
2024-11-05	2024	11	5	4	2024-11
2025-09-20	2025	9	20	3	2025-09
2026-02-19	2026	2	19	1	2026-02
2024-09-11	2024	9	11	3	2024-09
2026-04-03	2026	4	3	2	2026-04
2025-06-10	2025	6	10	2	2025-06
2026-01-24	2026	1	24	1	2026-01
2024-07-01	2024	7	1	3	2024-07
2024-12-29	2024	12	29	4	2024-12
2025-02-14	2025	2	14	1	2025-02
2025-08-14	2025	8	14	3	2025-08
2025-10-31	2025	10	31	4	2025-10
2025-09-13	2025	9	13	3	2025-09
2025-08-05	2025	8	5	3	2025-08
2025-12-15	2025	12	15	4	2025-12
2024-06-14	2024	6	14	2	2024-06
2024-06-18	2024	6	18	2	2024-06
2025-07-12	2025	7	12	3	2025-07
2026-03-16	2026	3	16	1	2026-03
2026-05-05	2026	5	5	2	2026-05
2025-12-03	2025	12	3	4	2025-12
2025-12-24	2025	12	24	4	2025-12
2025-02-01	2025	2	1	1	2025-02
2025-03-25	2025	3	25	1	2025-03
2025-06-05	2025	6	5	2	2025-06
2024-09-06	2024	9	6	3	2024-09
2025-10-30	2025	10	30	4	2025-10
2024-10-22	2024	10	22	4	2024-10
2025-03-30	2025	3	30	1	2025-03
2026-05-03	2026	5	3	2	2026-05
2026-05-20	2026	5	20	2	2026-05
2026-02-09	2026	2	9	1	2026-02
2024-12-06	2024	12	6	4	2024-12
2025-01-25	2025	1	25	1	2025-01
2024-09-12	2024	9	12	3	2024-09
2024-08-25	2024	8	25	3	2024-08
2026-02-13	2026	2	13	1	2026-02
2025-08-13	2025	8	13	3	2025-08
2025-10-23	2025	10	23	4	2025-10
2025-03-01	2025	3	1	1	2025-03
2024-09-13	2024	9	13	3	2024-09
2025-08-11	2025	8	11	3	2025-08
2026-02-28	2026	2	28	1	2026-02
2024-08-20	2024	8	20	3	2024-08
2025-12-26	2025	12	26	4	2025-12
2025-11-17	2025	11	17	4	2025-11
2026-01-16	2026	1	16	1	2026-01
2025-05-07	2025	5	7	2	2025-05
2025-11-09	2025	11	9	4	2025-11
2026-05-09	2026	5	9	2	2026-05
2026-02-03	2026	2	3	1	2026-02
2024-08-05	2024	8	5	3	2024-08
2025-11-23	2025	11	23	4	2025-11
2025-03-11	2025	3	11	1	2025-03
2026-01-02	2026	1	2	1	2026-01
2024-07-23	2024	7	23	3	2024-07
2024-09-10	2024	9	10	3	2024-09
2025-12-08	2025	12	8	4	2025-12
2024-07-25	2024	7	25	3	2024-07
2024-08-26	2024	8	26	3	2024-08
2024-09-28	2024	9	28	3	2024-09
2026-05-06	2026	5	6	2	2026-05
2024-11-02	2024	11	2	4	2024-11
2025-02-10	2025	2	10	1	2025-02
2025-12-17	2025	12	17	4	2025-12
2024-07-08	2024	7	8	3	2024-07
2025-05-30	2025	5	30	2	2025-05
2025-12-13	2025	12	13	4	2025-12
2024-12-15	2024	12	15	4	2024-12
2024-06-09	2024	6	9	2	2024-06
2025-12-07	2025	12	7	4	2025-12
2025-06-23	2025	6	23	2	2025-06
2026-03-07	2026	3	7	1	2026-03
2025-05-06	2025	5	6	2	2025-05
2024-10-11	2024	10	11	4	2024-10
2026-03-28	2026	3	28	1	2026-03
2025-03-31	2025	3	31	1	2025-03
2025-06-18	2025	6	18	2	2025-06
2024-10-18	2024	10	18	4	2024-10
2025-02-20	2025	2	20	1	2025-02
2025-11-28	2025	11	28	4	2025-11
2026-02-01	2026	2	1	1	2026-02
2026-01-15	2026	1	15	1	2026-01
2024-06-20	2024	6	20	2	2024-06
2025-08-01	2025	8	1	3	2025-08
2025-01-28	2025	1	28	1	2025-01
2025-07-04	2025	7	4	3	2025-07
2025-04-29	2025	4	29	2	2025-04
2025-03-27	2025	3	27	1	2025-03
2026-01-28	2026	1	28	1	2026-01
2025-03-22	2025	3	22	1	2025-03
2024-09-30	2024	9	30	3	2024-09
2025-12-30	2025	12	30	4	2025-12
2025-11-19	2025	11	19	4	2025-11
2025-05-04	2025	5	4	2	2025-05
2025-03-06	2025	3	6	1	2025-03
2025-08-25	2025	8	25	3	2025-08
2025-09-29	2025	9	29	3	2025-09
2025-04-20	2025	4	20	2	2025-04
2024-09-29	2024	9	29	3	2024-09
2025-03-29	2025	3	29	1	2025-03
2025-11-20	2025	11	20	4	2025-11
2025-11-26	2025	11	26	4	2025-11
2024-08-28	2024	8	28	3	2024-08
2025-03-16	2025	3	16	1	2025-03
2025-02-16	2025	2	16	1	2025-02
2026-04-19	2026	4	19	2	2026-04
2025-11-15	2025	11	15	4	2025-11
2024-09-27	2024	9	27	3	2024-09
2025-03-28	2025	3	28	1	2025-03
2025-06-29	2025	6	29	2	2025-06
2024-06-29	2024	6	29	2	2024-06
2025-05-23	2025	5	23	2	2025-05
2026-02-20	2026	2	20	1	2026-02
2026-04-04	2026	4	4	2	2026-04
2025-06-25	2025	6	25	2	2025-06
2024-12-17	2024	12	17	4	2024-12
2025-06-07	2025	6	7	2	2025-06
2025-04-30	2025	4	30	2	2025-04
\.


--
-- TOC entry 2533 (class 0 OID 49475)
-- Dependencies: 274
-- Data for Name: dim_product; Type: TABLE DATA; Schema: dim; Owner: gpadmin
--

COPY dim.dim_product (product_id, name, category, price, currency, is_active) FROM stdin;
2	Набор	Books	114.790000000000006	EUR	t
6	Холодно	Sports	572.879999999999995	USD	t
3	Вздрагивать	Electronics	49.9799999999999969	RUB	f
7	Порядок	Clothing	1457.06999999999994	EUR	t
4	Фонарик	Electronics	392.930000000000007	RUB	f
9	Куча	Sports	291.560000000000002	EUR	t
8	Академик	Clothing	1612.31999999999994	USD	t
18	Лететь   	Home	749.539999999999964	USD	t
10	Чем	Electronics	1866.6400000000001	EUR	f
22	Равнодушный	Home	1530.55999999999995	EUR	f
13	Совещание	Electronics	990.730000000000018	USD	f
24	Неожиданно	Home	\N	EUR	f
16	Исполнять	Sports	1530.6099999999999	RUB	f
28	Около	Clothing	699.67999999999995	RUB	f
19	Конструкция	Home	296.54000000000002	USD	t
29	Сынок	Electronics	348.550000000000011	USD	t
21	Исследование	Books	586.870000000000005	RUB	t
34	Очко	Books	1510.32999999999993	RUB	t
27	Чувство	Books	837.610000000000014	USD	f
37	Избегать   	Books	202.719999999999999	RUB	t
32	Господь	Electronics	1550.50999999999999	USD	t
39	Собеседник	Clothing	1848.83999999999992	EUR	t
33	Выкинуть	Home	940.82000000000005	RUB	t
43	Отъезд	Clothing	169.080000000000013	RUB	f
41	Свежий	Home	432.480000000000018	USD	f
51	Заплакать	Clothing	715.409999999999968	RUB	f
42	Сходить	Home	225.080000000000013	RUB	t
55	Жидкий	Sports	1245.81999999999994	EUR	f
45	Достоинство	Clothing	381.629999999999995	RUB	f
58	Рабочий	Clothing	770.340000000000032	USD	t
53	Славный	Electronics	1258.59999999999991	USD	f
60	Трясти	Electronics	273.300000000000011	RUB	f
54	Штаб	Home	1357.81999999999994	USD	f
67	Налоговый	Sports	1738.53999999999996	EUR	t
59	Сверкать	Books	357.850000000000023	EUR	f
77	Соответствие	Sports	1344.75999999999999	USD	f
62	Отражение	Clothing	1015.84000000000003	RUB	f
90	Выбирать	Home	1769.71000000000004	EUR	f
65	Доставать	Clothing	764.240000000000009	EUR	t
93	Девка	Home	983.269999999999982	RUB	f
66	Интернет	Sports	1324.17000000000007	USD	t
94	Оборот	Books	952.330000000000041	EUR	f
70	Ленинград	Books	648.230000000000018	EUR	f
99	Заложить	Books	185.050000000000011	USD	f
73	Правление	Clothing	578.269999999999982	USD	t
101	Ставить	Clothing	1733.55999999999995	RUB	f
75	Головной	Home	857.080000000000041	RUB	f
102	Карман	Electronics	1853.3599999999999	USD	f
80	Растеряться	Home	299.75	EUR	f
103	Близко	Sports	1015.13999999999999	RUB	f
81	Поговорить	Books	640.710000000000036	EUR	f
104	Конференция	Books	\N	RUB	f
82	При	Sports	1648.29999999999995	USD	f
108	Рабочий	Books	1376.5	USD	f
84	Аж	Electronics	1121.84999999999991	USD	t
110	Миллиард	Books	1896.48000000000002	USD	f
92	Команда	Home	354.430000000000007	RUB	t
112	Настать	Books	1202.77999999999997	RUB	t
97	Цель	Electronics	1279.70000000000005	RUB	t
113	Недостаток	Clothing	33.1599999999999966	RUB	f
100	Добиться	Clothing	1264.54999999999995	USD	f
118	Опасность	Clothing	940.419999999999959	RUB	t
109	Правый	Sports	738.360000000000014	USD	t
120	Военный	Clothing	1116.21000000000004	EUR	t
115	Дрогнуть	Books	767.240000000000009	EUR	t
127	Карман	Clothing	874.370000000000005	USD	f
117	Промолчать	Clothing	1237.26999999999998	USD	t
131	Ботинок	Books	251.689999999999998	USD	f
126	Некоторый	Home	1806.06999999999994	RUB	f
139	Совет	Home	1096.57999999999993	USD	t
129	Салон	Clothing	331.29000000000002	USD	f
141	Вскакивать	Books	1560.08999999999992	USD	f
130	Ныне	Clothing	716.259999999999991	USD	t
142	Трубка	Home	984.240000000000009	RUB	t
133	Дурацкий	Electronics	835.759999999999991	EUR	t
146	Пятеро	Books	1029.11999999999989	EUR	t
140	Ход	Books	1930.26999999999998	USD	f
147	Порт	Clothing	584.950000000000045	EUR	t
143	Рис	Books	721.289999999999964	EUR	f
151	Совет	Electronics	513.450000000000045	RUB	f
145	Сопровождаться	Clothing	1622.93000000000006	USD	t
153	Предоставить	Clothing	631.32000000000005	RUB	f
156	Аллея	Clothing	16.6600000000000001	EUR	f
164	Призыв	Clothing	671.029999999999973	EUR	f
163	Темнеть	Sports	1720.28999999999996	EUR	t
176	Эпоха	Electronics	353.560000000000002	EUR	f
165	Валюта	Home	1475.47000000000003	USD	f
180	Выражаться	Electronics	1853.63000000000011	USD	t
177	Песенка	Clothing	232.370000000000005	EUR	f
182	Темнеть	Sports	318.279999999999973	EUR	t
190	Результат	Sports	1519.58999999999992	USD	f
183	Очутиться	Electronics	312.819999999999993	USD	f
193	Вообще	Sports	1402.08999999999992	RUB	f
185	Жестокий	Clothing	1012.51999999999998	EUR	t
207	Плясать	Clothing	1648.5	USD	t
187	Научить	Sports	829.75	RUB	f
209	Запретить	Electronics	1843.78999999999996	USD	f
192	Порядок	Sports	\N	RUB	t
211	Порог	Books	610	RUB	f
195	Четко	Books	173.139999999999986	RUB	f
215	Рассуждение	Clothing	1525.08999999999992	RUB	f
197	Четко	Home	51.7299999999999969	USD	f
223	Полностью	Electronics	806.590000000000032	EUR	f
198	Волк	Electronics	1454.3900000000001	EUR	f
229	Возмутиться	Sports	483.050000000000011	RUB	f
203	Спичка	Clothing	1646.56999999999994	EUR	t
230	Военный	Sports	1898.97000000000003	EUR	t
205	Успокоиться	Sports	741.740000000000009	EUR	f
233	Спалить	Books	894.730000000000018	EUR	t
218	Домашний	Electronics	1473.15000000000009	RUB	f
236	Степь	Sports	6.08000000000000007	EUR	f
219	Стакан	Books	1124.27999999999997	RUB	t
237	Палата	Sports	1998.49000000000001	EUR	t
224	Пасть	Clothing	\N	EUR	t
241	Академик	Sports	1326.24000000000001	EUR	t
225	Сходить	Books	233.719999999999999	USD	f
247	Уточнить   	Electronics	744.110000000000014	EUR	f
239	Посидеть	Clothing	1661.83999999999992	USD	f
257	Затянуться	Home	98.6899999999999977	USD	f
244	Товар	Electronics	1575.67000000000007	RUB	f
260	Один	Electronics	661.799999999999955	EUR	f
246	Вытаскивать	Electronics	358.490000000000009	USD	f
261	Доставать	Home	1617.07999999999993	EUR	t
251	Свежий	Sports	345.100000000000023	RUB	t
262	Фонарик	Electronics	220.139999999999986	EUR	t
252	Прелесть	Home	135.389999999999986	RUB	t
270	Один   	Electronics	1177.69000000000005	RUB	t
256	Вперед	Electronics	1361.95000000000005	RUB	t
275	Выражение	Electronics	119.349999999999994	EUR	f
258	Развитый	Electronics	393.240000000000009	RUB	t
279	Снимать	Electronics	328.75	EUR	t
263	Монета	Electronics	1887.38000000000011	RUB	f
282	Избегать	Home	414.610000000000014	USD	t
266	Полоска	Electronics	606.42999999999995	RUB	t
286	Наткнуться	Books	356.269999999999982	EUR	t
267	Смеяться	Clothing	593.360000000000014	USD	t
288	Изменение	Clothing	1882.61999999999989	RUB	t
272	Соответствие	Electronics	1450.61999999999989	USD	t
290	Нервно	Books	1390.24000000000001	USD	t
274	Лететь	Home	299.079999999999984	USD	t
291	Написать	Books	1709.59999999999991	USD	f
285	Сходить	Books	1439.07999999999993	USD	t
296	Бегать	Sports	950.149999999999977	RUB	t
287	Возмутиться	Home	680.07000000000005	EUR	t
298	Левый	Home	615.470000000000027	EUR	t
294	Бочок	Clothing	1503.8599999999999	RUB	f
301	Житель	Electronics	738.190000000000055	USD	f
295	Исследование	Clothing	362.100000000000023	RUB	f
304	Вздрогнуть	Home	1094.31999999999994	EUR	f
299	Приличный	Home	272.990000000000009	USD	t
311	Выраженный	Electronics	752.529999999999973	EUR	f
308	Сутки	Sports	457.720000000000027	RUB	f
315	Палец	Books	412.389999999999986	EUR	t
309	Армейский	Home	1446.41000000000008	USD	f
319	Вообще	Home	585.759999999999991	RUB	t
310	Четко	Clothing	1541.41000000000008	RUB	t
322	Терапия	Books	622.970000000000027	RUB	f
312	Провал	Clothing	682.950000000000045	RUB	f
326	Скользить	Home	579.379999999999995	EUR	t
320	Роса	Books	347.79000000000002	USD	t
345	Тюрьма	Clothing	1251.22000000000003	USD	t
325	Плод	Sports	1821.04999999999995	USD	t
350	Возмутиться	Clothing	1918.26999999999998	RUB	t
329	Развернуться	Sports	483.189999999999998	EUR	t
354	Расстегнуть	Sports	621.149999999999977	USD	t
331	Уточнить	Home	1990.66000000000008	EUR	f
363	Хотеть	Books	1017.30999999999995	RUB	t
333	Устройство	Clothing	765.409999999999968	USD	t
364	Беспомощный	Home	493.629999999999995	RUB	f
334	Прошептать	Clothing	504.95999999999998	EUR	f
366	Спасть	Sports	799.5	RUB	f
335	Степь	Clothing	141.129999999999995	USD	f
370	Гулять	Books	753.419999999999959	RUB	f
338	Какой	Books	1356.38000000000011	RUB	t
373	Демократия	Electronics	619.080000000000041	USD	f
341	Задержать	Books	1535.3900000000001	USD	t
374	Сбросить	Home	1864.59999999999991	RUB	f
344	Табак	Home	92.7999999999999972	RUB	t
381	Рот	Sports	1003.78999999999996	EUR	f
346	Умолять	Clothing	431.490000000000009	RUB	f
389	Зачем	Electronics	164.219999999999999	EUR	t
348	Граница	Sports	92.6599999999999966	EUR	t
390	Правление	Electronics	1173.3599999999999	USD	t
352	Важный	Clothing	\N	EUR	t
391	Полюбить	Electronics	535.830000000000041	USD	t
355	Сохранять	Clothing	279.420000000000016	USD	t
393	Сверкать	Home	1515.03999999999996	EUR	t
356	Спасть	Clothing	479.939999999999998	RUB	f
395	Райком	Clothing	\N	RUB	t
358	Наслаждение	Home	1297.84999999999991	EUR	t
406	Беспомощный	Electronics	444.649999999999977	RUB	t
360	Холодно	Clothing	1218.08999999999992	RUB	t
410	Решетка	Electronics	683.769999999999982	RUB	f
361	Манера	Electronics	133.909999999999997	RUB	t
412	Нажать	Clothing	1182.17000000000007	EUR	f
362	Свежий	Sports	1876.8599999999999	USD	t
418	Господь	Home	992.580000000000041	USD	t
367	Юный	Electronics	1521.84999999999991	EUR	f
421	Реклама	Clothing	678.129999999999995	EUR	t
369	Изба	Home	1107.94000000000005	EUR	f
429	Граница	Home	493.779999999999973	RUB	t
371	Необычный   	Sports	395.449999999999989	RUB	f
444	Изучить	Electronics	1377.42000000000007	USD	t
379	Господь	Clothing	1543.08999999999992	RUB	t
446	Чем	Clothing	1185.6099999999999	USD	f
383	Стакан	Clothing	1629.38000000000011	RUB	f
447	Зато	Clothing	525.049999999999955	USD	f
394	Желание	Electronics	1882.27999999999997	EUR	f
452	Упорно	Home	136.590000000000003	EUR	t
397	Ягода	Clothing	1238.6099999999999	RUB	t
459	Сохранять	Home	1316.83999999999992	USD	f
403	Фонарик	Sports	1793.33999999999992	USD	t
461	Изображать	Home	1972.55999999999995	EUR	t
404	Космос	Electronics	427.220000000000027	USD	f
462	Миллиард	Clothing	613.850000000000023	EUR	t
414	Анализ	Home	\N	USD	f
465	Предоставить	Sports	961.909999999999968	RUB	t
415	Расстегнуть	Sports	1675.25	EUR	t
469	Конференция	Electronics	154.870000000000005	EUR	f
416	Разуметься	Electronics	1495.38000000000011	RUB	f
475	Деньги	Sports	22.6799999999999997	RUB	t
422	Деньги	Books	1058.04999999999995	RUB	f
476	Боец   	Home	824.379999999999995	USD	f
424	Постоянный	Clothing	917.779999999999973	EUR	t
479	Приличный	Books	\N	USD	t
425	Возмутиться	Electronics	423.480000000000018	EUR	t
482	Бетонный	Books	980.690000000000055	EUR	f
426	Функция	Clothing	1358.24000000000001	RUB	t
485	Войти	Home	1535.93000000000006	EUR	t
428	Пробовать	Books	1960.65000000000009	RUB	f
487	Даль	Electronics	1459.84999999999991	EUR	t
435	Еврейский	Books	131.680000000000007	EUR	t
491	Выкинуть	Clothing	1234.84999999999991	RUB	f
436	Плясать	Sports	790.620000000000005	EUR	t
494	Бегать	Electronics	1886.27999999999997	USD	t
437	Налево	Electronics	1040.21000000000004	USD	t
495	Пол	Home	6.07000000000000028	EUR	f
438	Направо	Sports	365.430000000000007	EUR	f
498	Сомнительный	Sports	724.330000000000041	RUB	f
439	Зато	Books	250.47999999999999	USD	f
501	Научить	Home	1851.36999999999989	EUR	f
449	Пастух	Home	1990.74000000000001	RUB	t
505	Школьный	Books	1049.91000000000008	RUB	f
455	Освобождение	Home	1179.71000000000004	RUB	f
506	Уточнить	Sports	1394.93000000000006	USD	t
456	Крыса	Books	1105.32999999999993	EUR	f
508	Анализ	Clothing	878.299999999999955	EUR	f
457	Строительство	Sports	365.439999999999998	RUB	f
509	Мучительно	Sports	\N	RUB	t
458	Прелесть   	Sports	956.340000000000032	RUB	t
513	Четыре	Books	544.519999999999982	USD	t
460	Ручей	Clothing	1416.47000000000003	USD	f
514	Неправда	Home	7.79000000000000004	EUR	t
464	Холодно	Electronics	173.75	EUR	t
515	Увеличиваться	Books	1893.11999999999989	EUR	f
466	Дремать	Electronics	813.919999999999959	RUB	f
516	Виднеться	Home	652.649999999999977	USD	f
470	Вздрогнуть	Books	761.289999999999964	RUB	t
519	Плод	Sports	1634.6099999999999	RUB	f
471	Налоговый	Electronics	583.67999999999995	RUB	f
520	Радость	Home	315.5	USD	f
473	Очко	Electronics	1785.52999999999997	RUB	f
526	Точно	Electronics	\N	USD	t
484	Приходить	Home	1915.56999999999994	RUB	t
530	Командующий	Home	666.850000000000023	RUB	t
486	Разводить	Clothing	871.490000000000009	USD	t
533	Передо	Clothing	709.850000000000023	RUB	t
490	Выразить	Books	268.930000000000007	EUR	t
541	Командование	Home	649.490000000000009	EUR	f
493	Вздрагивать	Home	1022.17999999999995	EUR	f
1	Господь	Home	54.4699999999999989	USD	f
500	Роса	Books	1260.97000000000003	USD	f
11	Правый	Books	831.960000000000036	USD	t
5	Фонарик	Clothing	798.129999999999995	EUR	t
14	Построить	Electronics	603.840000000000032	RUB	f
12	Ответить	Home	1665.41000000000008	RUB	f
20	Приятель	Home	548.980000000000018	USD	f
15	Падать	Books	837.230000000000018	USD	t
25	Услать	Books	683.919999999999959	RUB	t
17	Боец	Clothing	1164.23000000000002	RUB	t
26	Рай	Sports	1663.99000000000001	RUB	t
23	Кпсс	Sports	546.559999999999945	RUB	f
31	Дыхание	Electronics	1962.30999999999995	USD	t
30	Интернет	Books	1714.34999999999991	USD	t
35	Витрина	Home	373.639999999999986	RUB	f
38	Близко	Electronics	1928.71000000000004	RUB	t
36	Конференция	Sports	707.649999999999977	USD	t
44	Сверкающий	Clothing	1375.66000000000008	EUR	f
40	Сверкать	Home	882.129999999999995	EUR	f
56	Спорт	Home	407.850000000000023	RUB	f
46	Армейский	Electronics	362.699999999999989	EUR	f
69	Страсть	Clothing	1393.44000000000005	RUB	f
47	Зато	Clothing	1047.71000000000004	EUR	t
72	Подробность	Electronics	1939.00999999999999	RUB	t
48	Зачем	Home	1484.16000000000008	USD	f
74	Ручей	Home	1436.82999999999993	USD	f
49	Поколение	Books	404.529999999999973	EUR	f
76	Грустный	Clothing	868.659999999999968	EUR	f
50	Сынок	Home	560.639999999999986	RUB	f
78	Сохранять	Clothing	429.839999999999975	EUR	f
52	Приходить	Clothing	299.009999999999991	EUR	t
85	Число	Home	\N	RUB	t
57	Пища   	Electronics	1619.92000000000007	EUR	t
86	Ответить	Electronics	1290.36999999999989	USD	t
61	Заработать	Clothing	1321.8599999999999	RUB	t
87	Подробность	Clothing	631.240000000000009	EUR	t
63	Ломать	Sports	1534.1099999999999	USD	t
88	Экзамен	Books	796.809999999999945	USD	t
64	Неудобно	Electronics	1674.68000000000006	RUB	f
89	Успокоиться	Sports	1046.30999999999995	EUR	f
68	Цепочка	Clothing	924.509999999999991	EUR	t
91	Медицина	Books	1612.65000000000009	USD	t
71	Радость	Sports	1008.01999999999998	EUR	f
95	Оборот	Sports	1432.75999999999999	USD	t
79	Тусклый	Books	1869.59999999999991	EUR	f
96	Передо	Sports	1382.91000000000008	EUR	f
83	Поставить	Home	480.769999999999982	EUR	f
105	Нажать	Home	1583.07999999999993	EUR	t
98	Покидать	Clothing	1716.00999999999999	EUR	f
111	Идея	Clothing	400.54000000000002	RUB	f
106	Князь	Books	226.099999999999994	RUB	f
116	Порода	Home	839.57000000000005	EUR	t
107	Да	Books	1586.31999999999994	EUR	t
119	Равнодушный	Home	1428.1099999999999	USD	t
114	Покидать	Home	241.430000000000007	EUR	f
134	Написать	Home	572.139999999999986	RUB	t
121	Второй	Clothing	15.6999999999999993	RUB	f
136	Потрясти	Sports	\N	EUR	f
122	Отметить	Books	268.819999999999993	EUR	t
150	Выраженный	Sports	1023.75	EUR	f
123	Достоинство	Books	1009.97000000000003	USD	f
154	Висеть	Books	685.960000000000036	USD	t
124	Народ	Home	1421.96000000000004	USD	t
155	Тюрьма	Electronics	1495.31999999999994	EUR	t
125	Вскакивать	Home	1000.92999999999995	EUR	f
157	Бегать	Clothing	1738.22000000000003	EUR	f
128	Носок	Electronics	111.180000000000007	EUR	f
161	Место	Electronics	605.330000000000041	USD	t
132	Лапа	Electronics	1128.68000000000006	RUB	t
166	Ботинок	Clothing	802.360000000000014	USD	t
135	Торговля	Clothing	1674.76999999999998	EUR	f
167	Премьера	Electronics	1058.98000000000002	EUR	f
137	Сомнительный	Sports	1895.09999999999991	USD	t
168	Возбуждение	Home	1778.83999999999992	EUR	f
138	Бегать	Electronics	1727.24000000000001	RUB	t
169	Низкий	Home	46.509999999999998	EUR	t
144	Гулять	Clothing	1771.40000000000009	USD	f
171	Угроза	Clothing	266.660000000000025	RUB	f
148	Горький	Books	1968.45000000000005	RUB	f
174	Вариант	Clothing	1213.47000000000003	EUR	t
149	Грустный	Electronics	594.490000000000009	RUB	t
179	Гулять	Electronics	1707.54999999999995	RUB	t
152	Жить	Electronics	363.20999999999998	EUR	f
181	Цель	Electronics	1648.09999999999991	USD	f
158	Магазин	Home	1382.86999999999989	USD	t
184	Жить   	Clothing	1939.43000000000006	EUR	f
159	Темнеть	Books	274.550000000000011	USD	t
186	Отражение	Books	307.45999999999998	USD	f
160	Жестокий	Sports	964.830000000000041	USD	t
189	Новый	Clothing	679.919999999999959	USD	f
162	Головной	Clothing	1805.31999999999994	EUR	t
191	Цвет	Home	841.509999999999991	RUB	f
170	Непривычный	Sports	1017.73000000000002	RUB	f
194	Кольцо	Clothing	1396.45000000000005	USD	f
172	Налево	Sports	1592.97000000000003	USD	f
202	Войти	Home	1430.13000000000011	RUB	t
173	Коробка	Books	1382.94000000000005	USD	t
204	Тысяча	Books	189.039999999999992	EUR	t
175	Очко   	Home	422.819999999999993	EUR	t
206	Перебивать	Clothing	1170.69000000000005	RUB	f
178	Похороны	Sports	1570.84999999999991	EUR	t
212	Цвет	Books	102.060000000000002	USD	f
188	Вытаскивать	Sports	1887.75999999999999	USD	t
213	Похороны	Electronics	9.16000000000000014	EUR	f
196	Дружно	Home	431.399999999999977	RUB	t
220	Горький	Sports	1914.79999999999995	USD	t
199	Конференция	Electronics	1255.83999999999992	EUR	f
222	Выдержать	Electronics	1660.23000000000002	RUB	f
200	Академик	Books	\N	RUB	t
228	Конструкция	Electronics	828.580000000000041	USD	t
201	Изредка	Sports	703.919999999999959	RUB	t
231	Призыв	Electronics	970.919999999999959	EUR	t
208	Цвет	Books	1390.47000000000003	RUB	f
238	Руководитель	Electronics	327.029999999999973	EUR	t
210	Девка	Home	1145.67000000000007	EUR	f
240	Эффект	Clothing	1768.44000000000005	EUR	t
214	Рай	Clothing	1148.25	EUR	t
245	Заплакать	Sports	1346.13000000000011	EUR	f
216	Бак	Sports	302.220000000000027	RUB	f
248	Изменение	Books	387.069999999999993	USD	f
217	Советовать	Electronics	777.529999999999973	RUB	f
249	Пасть	Sports	1934.75999999999999	USD	t
221	Изображать	Home	1318.22000000000003	USD	t
250	О	Home	396.189999999999998	RUB	f
226	Головка	Books	1537.76999999999998	USD	f
253	Ход	Electronics	1762.59999999999991	RUB	f
227	Радость	Electronics	367.009999999999991	EUR	t
254	Дьявол   	Clothing	1362.96000000000004	RUB	t
232	Скользить	Home	496.399999999999977	RUB	f
255	Снимать	Clothing	1708.45000000000005	EUR	t
234	Ломать	Sports	1565.1400000000001	EUR	t
259	Экзамен	Books	1956.29999999999995	USD	t
235	Издали	Home	7	RUB	t
264	Пол	Electronics	1159.97000000000003	EUR	f
242	Один	Sports	1828.47000000000003	EUR	t
268	Кольцо	Sports	909.559999999999945	RUB	t
243	Наткнуться	Clothing	1803.38000000000011	EUR	t
269	Очередной	Clothing	682.529999999999973	RUB	f
265	Полюбить	Electronics	1780.72000000000003	EUR	t
271	Заведение	Home	1809.22000000000003	EUR	f
273	Посвятить	Home	626.779999999999973	EUR	t
276	Четыре	Electronics	394.839999999999975	EUR	t
277	Помимо	Sports	1337.38000000000011	RUB	f
283	Изба	Clothing	718.980000000000018	USD	f
278	Чувство	Home	1704.75999999999999	EUR	f
284	Стакан	Books	\N	USD	f
280	Оборот	Clothing	1840.30999999999995	RUB	t
292	Второй	Clothing	1746.33999999999992	USD	t
281	Бровь	Home	481.839999999999975	RUB	f
300	Хотеть	Clothing	933.17999999999995	EUR	f
289	Следовательно	Books	241.389999999999986	USD	f
302	Редактор	Electronics	471.410000000000025	EUR	t
293	Нажать	Books	1570.41000000000008	RUB	f
306	Проход	Clothing	1541.29999999999995	EUR	t
297	Бровь	Books	418.360000000000014	EUR	t
313	Факультет	Books	\N	USD	f
303	Находить	Electronics	1572.81999999999994	EUR	t
316	Функция	Home	661.039999999999964	USD	t
305	Металл	Sports	385.329999999999984	EUR	t
323	Услать	Home	1177.04999999999995	USD	t
307	Важный	Books	946.649999999999977	EUR	t
324	Одиннадцать	Sports	1982.21000000000004	USD	f
314	Господь	Sports	1138.53999999999996	EUR	f
327	Смертельный	Clothing	833.029999999999973	EUR	f
317	Художественный	Sports	213.099999999999994	EUR	t
328	Дьявол	Clothing	1822.1099999999999	RUB	t
318	Терапия	Home	377.449999999999989	USD	t
336	Деньги	Electronics	1641.75	RUB	t
321	Вытаскивать	Books	1075.22000000000003	USD	t
339	Выраженный	Electronics	1785.91000000000008	RUB	t
330	Песня	Clothing	1397.59999999999991	EUR	t
340	Постоянный	Electronics	784.279999999999973	USD	f
332	Цель	Electronics	333.850000000000023	USD	f
347	Витрина	Home	28.8999999999999986	RUB	f
337	Провал	Books	358.589999999999975	USD	t
351	Парень	Home	667.42999999999995	RUB	f
342	Песенка   	Books	\N	RUB	t
353	Применяться   	Electronics	1009.32000000000005	RUB	t
343	Экзамен	Books	445.029999999999973	RUB	t
357	Упорно	Electronics	272.860000000000014	RUB	f
349	Сомнительный	Sports	1426.5	USD	f
359	Войти	Books	415.610000000000014	RUB	t
368	Неожиданный	Sports	1708.80999999999995	RUB	t
365	Помимо	Clothing	1935.6099999999999	USD	f
372	Функция	Home	985.450000000000045	EUR	f
375	Трубка	Electronics	1021.66999999999996	RUB	f
376	Песенка	Electronics	1853.40000000000009	EUR	t
377	Умолять	Clothing	1396.46000000000004	RUB	t
380	Сынок	Clothing	1039.48000000000002	EUR	f
378	Пересечь	Books	512.299999999999955	USD	t
382	Спешить	Electronics	1506.16000000000008	RUB	f
387	Остановить	Books	1136.34999999999991	USD	f
384	Гулять	Electronics	17.8099999999999987	USD	f
392	Сохранять	Home	\N	EUR	f
385	Космос	Books	1052.29999999999995	USD	f
398	Провинция	Home	11.2400000000000002	USD	f
386	Зато	Sports	376.870000000000005	USD	f
399	Запеть	Clothing	1747.5	USD	f
388	Сходить	Sports	1965.98000000000002	USD	t
400	Багровый	Clothing	803.330000000000041	EUR	t
396	Банда	Books	56.2299999999999969	EUR	f
402	Виднеться	Sports	260.079999999999984	EUR	t
401	Слать	Books	1469.88000000000011	RUB	t
407	Мусор	Home	1845.8599999999999	USD	t
405	Холодно	Home	\N	EUR	f
408	Бак	Clothing	1289.75	RUB	f
409	Призыв	Electronics	1617.84999999999991	USD	t
413	Бетонный	Sports	1596.04999999999995	RUB	t
411	Мелочь	Electronics	259.199999999999989	EUR	t
417	Аж	Sports	621.240000000000009	EUR	t
420	Строительство	Books	1456.15000000000009	USD	f
419	Рабочий	Electronics	1696.90000000000009	USD	f
430	Стакан	Electronics	1307.32999999999993	EUR	f
423	Факультет	Electronics	199.150000000000006	RUB	f
432	Дорогой	Books	248.490000000000009	USD	f
427	Четко	Books	1852.33999999999992	USD	t
440	Сходить	Sports	1703.6400000000001	EUR	f
431	Господь	Electronics	554.059999999999945	USD	t
443	Слать	Home	284.009999999999991	RUB	t
433	Слишком	Books	551.080000000000041	EUR	f
453	Кузнец   	Clothing	1738.36999999999989	USD	f
434	Пасть	Books	1999.91000000000008	USD	f
454	Снимать	Sports	1903.80999999999995	RUB	f
441	Совещание	Electronics	1932.72000000000003	USD	f
474	Рот   	Books	660.460000000000036	EUR	f
442	Кпсс	Home	97.0999999999999943	RUB	f
481	Куча	Home	1334.07999999999993	USD	f
445	Пища	Sports	602.919999999999959	RUB	t
497	Заработать   	Sports	612.190000000000055	USD	f
448	Мелькнуть	Books	1354.67000000000007	USD	f
499	Казнь	Electronics	480.310000000000002	USD	t
450	Сынок	Clothing	842.269999999999982	EUR	t
503	Ведь	Sports	839.330000000000041	EUR	f
451	Плод	Sports	1928.22000000000003	USD	f
504	Передо	Electronics	899.720000000000027	EUR	f
463	Выражаться	Electronics	1271.18000000000006	USD	t
507	Запустить	Sports	1482.73000000000002	USD	t
467	Дыхание	Sports	1406.67000000000007	RUB	t
517	Ставить	Sports	357.589999999999975	USD	f
468	Возбуждение	Sports	1216.71000000000004	USD	t
518	Висеть	Sports	1891.57999999999993	RUB	t
472	Болото	Sports	438.839999999999975	USD	f
521	Один	Books	191.909999999999997	USD	f
477	Инвалид	Books	793.740000000000009	RUB	f
529	Направо	Clothing	408.629999999999995	USD	f
478	Дальний	Books	221.849999999999994	USD	f
536	Коллектив	Clothing	360.25	USD	f
480	Бегать	Home	573.379999999999995	USD	t
538	Поймать	Electronics	1866.09999999999991	USD	t
483	Развернуться	Clothing	1006.21000000000004	USD	t
540	Мальчишка	Home	1630.23000000000002	USD	t
488	Кожа	Electronics	1334.32999999999993	RUB	t
545	Вообще   	Electronics	1407.67000000000007	EUR	f
489	Ответить	Books	381.389999999999986	USD	t
547	Металл	Clothing	592.919999999999959	USD	t
492	Передо	Clothing	1401.81999999999994	EUR	t
552	Набор	Home	942.17999999999995	EUR	f
496	Ярко	Clothing	1817.42000000000007	EUR	f
553	Пространство	Electronics	1446.5	EUR	t
510	Смелый	Sports	1758.91000000000008	EUR	f
554	Теория	Books	316	RUB	t
511	Возможно	Electronics	1705.69000000000005	USD	t
559	Ребятишки	Clothing	1634.02999999999997	EUR	t
523	Ученый	Books	1635.91000000000008	USD	f
566	Передо	Books	632.370000000000005	RUB	t
527	Провинция	Sports	1541.38000000000011	USD	t
570	Выраженный	Books	1769.38000000000011	RUB	f
528	Покидать	Home	1915.45000000000005	RUB	t
571	Спорт	Sports	897.720000000000027	EUR	t
532	Провал	Clothing	287.95999999999998	EUR	t
574	Забирать	Electronics	1533.79999999999995	EUR	t
534	Провинция	Home	986.17999999999995	EUR	t
579	Написать	Home	884.450000000000045	EUR	t
542	Да	Home	850.539999999999964	USD	t
588	Теория	Clothing	129.490000000000009	USD	t
544	Беспомощный	Sports	772.330000000000041	RUB	t
556	Трубка	Clothing	1838.70000000000005	USD	f
502	Плясать	Electronics	1979.33999999999992	USD	t
560	Упор	Home	114.069999999999993	USD	t
512	Сбросить	Books	96	EUR	t
563	Непривычный	Home	1105.61999999999989	USD	t
522	Кожа	Home	1886.99000000000001	USD	t
564	Беспомощный	Home	1129.66000000000008	USD	f
524	Беспомощный	Electronics	494.279999999999973	RUB	t
565	Редактор	Clothing	21.9200000000000017	RUB	t
525	Коммунизм	Clothing	1454.90000000000009	EUR	t
572	Близко	Books	1781.91000000000008	RUB	t
531	Страсть	Electronics	47.3100000000000023	RUB	f
575	Социалистический	Electronics	912.340000000000032	EUR	f
535	Заявление	Electronics	1233.31999999999994	USD	t
576	Цепочка	Clothing	709.970000000000027	EUR	f
537	Пропадать	Home	1251.3900000000001	EUR	f
580	Неожиданный	Electronics	1365.99000000000001	RUB	t
539	Отдел	Clothing	1556.68000000000006	RUB	f
581	За	Electronics	1483.38000000000011	USD	t
543	Разнообразный	Clothing	769.450000000000045	RUB	t
584	Висеть	Clothing	222.689999999999998	EUR	t
548	Сомнительный	Books	1656.5	EUR	t
586	Пространство	Electronics	1406.06999999999994	RUB	t
550	Изменение	Books	956.269999999999982	EUR	t
590	Еврейский	Clothing	1273.20000000000005	USD	f
555	Кидать	Clothing	26.6799999999999997	RUB	f
594	Ленинград	Sports	1931.34999999999991	EUR	t
558	Тусклый	Sports	803.799999999999955	RUB	t
600	Пасть	Books	1203.88000000000011	RUB	t
577	Призыв	Books	1957.07999999999993	USD	f
589	Лететь	Clothing	\N	EUR	f
582	Песня	Electronics	584.870000000000005	USD	f
592	Июнь	Clothing	372.240000000000009	EUR	f
-1	Unknown	Unknown	\N	\N	f
596	Житель	Home	650.850000000000023	USD	t
546	Эпоха	Home	1915.44000000000005	EUR	t
597	Сынок	Home	1793.51999999999998	USD	f
549	Неудобно	Electronics	1393.75999999999999	RUB	t
551	Ломать	Clothing	162.590000000000003	USD	t
557	Зима	Books	1946.38000000000011	RUB	t
561	Помолчать	Electronics	160.22999999999999	USD	f
562	Освобождение	Electronics	329.70999999999998	EUR	t
567	Ручей	Sports	665.980000000000018	USD	t
568	Сохранять	Electronics	1176.42000000000007	EUR	t
569	Хлеб	Electronics	307.319999999999993	RUB	t
573	Второй	Electronics	1916.24000000000001	USD	t
578	Второй	Sports	83.9899999999999949	RUB	t
583	Волк	Clothing	1748.95000000000005	RUB	f
585	Упорно	Sports	806.029999999999973	EUR	t
587	Сходить	Sports	1897.31999999999994	USD	f
591	Изображать	Books	1748.18000000000006	RUB	f
593	Прежде	Clothing	333.240000000000009	RUB	t
595	Невозможно	Sports	1124.00999999999999	RUB	t
598	Точно	Books	529.289999999999964	RUB	f
599	Премьера	Books	1279.6400000000001	EUR	t
\.


--
-- TOC entry 2536 (class 0 OID 49493)
-- Dependencies: 277
-- Data for Name: fact_events; Type: TABLE DATA; Schema: fact; Owner: gpadmin
--

COPY fact.fact_events (date_id, event_id, customer_id, event_type, event_timestamp, product_id) FROM stdin;
2025-02-16	3	570	login	2025-02-16 21:53:55	588
2025-11-30	2	550	login	2025-11-30 00:01:33	20
2025-07-12	4	213	view	2025-07-12 08:14:08	408
2025-09-16	6	407	purchase	2025-09-16 03:22:28	593
2025-12-19	7	649	purchase	2025-12-19 00:43:43	416
2025-08-19	8	211	click	2025-08-19 00:00:37	472
2025-09-11	9	143	logout	2025-09-11 03:25:39	-1
2024-10-25	10	646	view	2024-10-25 05:32:16	587
\N	16	111	logout	\N	411
2026-02-24	13	472	login	2026-02-24 06:50:07	27
2025-07-17	18	35	view	2025-07-17 12:46:22	238
2025-04-30	19	279	click	2025-04-30 21:23:00	430
2025-08-06	21	547	purchase	2025-08-06 10:01:35	577
2025-12-21	29	414	view	2025-12-21 15:16:26	75
2025-11-24	22	559	purchase	2025-11-24 21:01:34	64
2025-05-12	33	436	login	2025-05-12 05:14:11	99
2024-07-23	24	76	logout	2024-07-23 17:52:12	411
2025-06-29	37	-1	purchase	2025-06-29 07:09:59	17
2024-06-23	27	672	click	2024-06-23 06:44:36	40
2025-05-16	41	648	click	2025-05-16 22:32:18	77
2025-07-22	28	155	login	2025-07-22 02:25:51	122
2026-02-12	51	353	purchase	2026-02-12 04:31:22	509
2024-11-04	32	160	click	2024-11-04 15:02:32	77
2025-09-26	54	598	logout	2025-09-26 12:02:47	539
2025-03-18	34	498	logout	2025-03-18 12:01:58	557
2024-11-24	55	368	logout	2024-11-24 22:10:22	584
2025-03-26	39	166	logout	2025-03-26 03:32:01	91
2025-06-16	60	467	login	2025-06-16 06:21:19	371
2024-11-20	42	623	login	2024-11-20 18:16:28	523
2024-11-09	62	-1	view	2024-11-09 21:14:10	282
2026-04-17	43	378	purchase	2026-04-17 01:31:12	193
2026-05-16	67	61	view	2026-05-16 05:34:03	550
2025-07-29	45	39	login	2025-07-29 01:51:50	114
2024-08-28	70	144	logout	2024-08-28 06:45:43	180
2025-03-22	53	290	view	2025-03-22 10:28:31	478
2026-03-26	75	119	view	2026-03-26 20:55:00	253
2025-06-06	58	680	click	2025-06-06 16:21:47	517
2024-12-20	77	150	logout	2024-12-20 00:32:57	8
2025-10-04	59	304	click	2025-10-04 20:23:25	89
2026-04-15	80	131	view	2026-04-15 22:15:07	25
2025-06-11	65	42	logout	2025-06-11 18:31:24	106
2024-10-02	82	249	logout	2024-10-02 08:03:46	130
2026-05-23	66	-1	login	2026-05-23 23:17:14	-1
2025-05-02	84	295	login	2025-05-02 05:21:19	295
\N	73	606	view	\N	95
2024-11-21	97	157	logout	2024-11-21 14:32:15	387
2025-06-13	81	308	purchase	2025-06-13 00:37:43	338
2026-05-15	99	247	purchase	2026-05-15 00:05:23	45
2025-07-01	90	228	logout	2025-07-01 03:43:23	456
2024-06-12	101	229	logout	2024-06-12 14:10:17	-1
2025-02-23	92	611	purchase	2025-02-23 07:17:55	566
2024-09-01	104	629	logout	2024-09-01 17:49:37	303
2024-07-10	93	331	login	2024-07-10 03:08:37	-1
2025-12-06	109	-1	view	2025-12-06 19:55:09	351
2025-05-03	94	586	view	2025-05-03 08:36:36	285
2025-11-16	118	620	click	2025-11-16 22:25:13	-1
2024-10-28	100	85	click	2024-10-28 11:35:19	96
\N	120	161	click	\N	90
2025-07-13	102	566	purchase	2025-07-13 10:30:45	21
2024-10-26	130	-1	purchase	2024-10-26 00:47:48	386
2025-02-01	103	525	login	2025-02-01 22:06:59	-1
2024-09-16	140	511	login	2024-09-16 11:56:41	349
2025-02-07	108	-1	view	2025-02-07 08:25:42	466
2025-08-06	142	69	logout	2025-08-06 22:19:02	89
2024-08-10	110	253	login	2024-08-10 23:12:17	336
\N	146	561	login	\N	-1
2024-07-26	112	30	login	2024-07-26 19:13:49	388
2025-11-26	151	510	purchase	2025-11-26 07:27:02	-1
2025-04-27	113	16	click	2025-04-27 09:42:38	63
2026-05-08	156	515	login	2026-05-08 16:12:11	130
2024-11-16	115	636	logout	2024-11-16 23:51:55	186
2024-08-06	163	456	click	2024-08-06 23:43:34	378
2025-05-20	117	538	view	2025-05-20 14:25:32	144
2025-02-22	164	66	login	2025-02-22 04:12:08	287
2025-05-05	126	8	view	2025-05-05 21:25:18	600
2025-01-25	176	142	logout	2025-01-25 22:43:27	448
2025-11-22	127	50	click	2025-11-22 12:02:08	217
2025-05-06	177	673	view	2025-05-06 18:44:25	201
2024-11-28	129	619	view	2024-11-28 15:36:34	189
2024-07-13	183	249	click	2024-07-13 00:28:09	582
2024-10-01	131	150	purchase	2024-10-01 07:18:44	288
2025-06-19	187	437	view	2025-06-19 05:00:21	142
2025-04-01	133	615	login	2025-04-01 09:47:00	-1
2024-10-07	190	557	click	2024-10-07 00:19:49	463
2025-05-13	139	201	view	2025-05-13 15:29:15	463
2025-12-13	205	339	view	2025-12-13 00:24:07	223
2026-03-08	141	60	login	2026-03-08 00:11:12	429
2024-10-22	211	673	logout	2024-10-22 15:02:26	573
2025-10-20	143	-1	login	2025-10-20 11:39:58	417
2025-07-10	215	482	login	2025-07-10 17:50:06	594
2025-12-13	145	252	view	2025-12-13 22:39:24	-1
2025-07-19	219	69	login	2025-07-19 10:35:46	154
2026-03-17	147	490	click	2026-03-17 05:37:31	139
2025-01-07	223	344	view	2025-01-07 11:55:04	553
2025-10-18	153	465	click	2025-10-18 21:16:03	551
2026-02-08	224	275	login	2026-02-08 13:35:36	-1
2025-04-03	165	324	click	2025-04-03 01:58:44	255
2026-01-23	233	496	login	2026-01-23 02:59:45	119
2025-01-28	180	141	logout	2025-01-28 04:12:58	54
2025-08-19	236	-1	logout	2025-08-19 14:44:21	454
2025-01-13	182	138	login	2025-01-13 04:03:51	148
2024-05-29	237	85	view	2024-05-29 11:07:19	286
\N	185	500	login	\N	202
2025-08-08	241	124	logout	2025-08-08 17:08:17	111
2026-05-01	192	171	logout	2026-05-01 07:53:23	511
2026-01-22	246	-1	click	2026-01-22 18:34:32	289
2025-08-12	193	-1	view	2025-08-12 16:20:47	391
2025-03-05	257	613	logout	2025-03-05 21:30:38	209
2026-01-08	195	446	logout	2026-01-08 17:08:25	576
2026-03-18	258	226	logout	2026-03-18 20:47:27	212
2024-07-10	197	117	click	2024-07-10 00:46:30	379
2025-11-16	260	291	login	2025-11-16 11:39:54	259
2025-08-24	198	96	click	2025-08-24 06:44:19	1
2025-06-16	262	397	click	2025-06-16 15:16:04	24
2024-08-24	203	63	purchase	2024-08-24 05:30:53	357
2025-04-04	263	213	login	2025-04-04 13:51:22	418
2025-11-18	207	202	view	2025-11-18 20:44:37	413
2025-07-27	270	287	click	2025-07-27 15:06:12	118
2025-08-25	209	499	login	2025-08-25 23:24:44	37
2025-09-19	272	241	login	2025-09-19 22:34:47	223
2025-07-05	218	550	click	2025-07-05 21:49:54	553
2026-03-28	282	525	view	2026-03-28 08:14:49	141
\N	225	-1	click	\N	528
2025-07-20	285	356	click	2025-07-20 19:39:05	91
2025-03-12	229	531	purchase	2025-03-12 05:58:39	245
2025-04-07	294	222	click	2025-04-07 04:56:55	539
2025-08-18	230	5	login	2025-08-18 22:08:06	8
2025-11-25	295	681	view	2025-11-25 10:42:03	407
2025-05-09	239	358	login	2025-05-09 22:08:34	458
2025-11-10	296	656	login	2025-11-10 00:49:39	163
2026-02-06	244	625	login	2026-02-06 19:31:55	241
2025-08-30	298	12	click	2025-08-30 21:47:31	407
2025-04-15	247	142	login	2025-04-15 12:31:19	374
2025-07-12	299	88	purchase	2025-07-12 15:44:10	564
2024-09-07	251	-1	click	2024-09-07 16:52:42	117
2025-09-06	301	475	logout	2025-09-06 20:11:56	326
2024-12-09	252	343	logout	2024-12-09 01:28:03	337
2025-05-13	304	508	view	2025-05-13 01:33:42	193
2026-02-08	256	-1	purchase	2026-02-08 09:50:58	345
2025-09-23	308	597	view	2025-09-23 22:05:09	143
2024-09-22	261	394	logout	2024-09-22 08:01:18	-1
2024-09-20	309	605	purchase	2024-09-20 01:41:13	360
2025-05-19	266	686	view	2025-05-19 16:10:22	36
2024-10-08	310	96	login	2024-10-08 02:03:03	117
\N	267	-1	click	\N	401
2025-01-16	311	316	view	2025-01-16 18:20:42	370
2025-10-17	274	60	view	2025-10-17 00:23:58	539
2025-01-04	312	-1	logout	2025-01-04 06:24:54	277
2025-02-06	275	610	view	2025-02-06 06:29:46	534
2025-06-25	315	51	view	2025-06-25 06:10:29	-1
2025-09-02	279	700	click	2025-09-02 22:30:13	269
2024-11-03	320	166	click	2024-11-03 06:26:15	216
2026-04-01	286	38	logout	2026-04-01 01:25:09	251
2025-05-06	326	507	view	2025-05-06 19:03:54	284
2025-12-17	287	9	login	2025-12-17 03:45:14	208
2024-08-20	331	288	login	2024-08-20 00:29:06	550
2026-02-26	288	620	logout	2026-02-26 12:14:37	143
2024-08-06	334	576	click	2024-08-06 10:59:26	362
2024-06-29	290	684	click	2024-06-29 22:43:42	418
2025-03-15	335	671	login	2025-03-15 19:08:06	427
2025-02-06	291	365	view	2025-02-06 10:55:58	498
\N	338	485	login	\N	521
2026-04-09	319	412	logout	2026-04-09 22:09:29	186
2025-12-05	344	475	view	2025-12-05 03:12:54	202
2025-12-30	322	14	login	2025-12-30 03:42:11	21
2026-02-22	345	288	logout	2026-02-22 21:44:45	581
2024-10-07	325	481	purchase	2024-10-07 07:19:51	335
2025-02-07	348	683	view	2025-02-07 11:23:57	30
2026-03-26	329	556	click	2026-03-26 13:13:45	312
2024-12-27	350	113	click	2024-12-27 01:36:29	5
2024-08-26	333	204	purchase	2024-08-26 00:34:59	304
2024-07-18	356	673	view	2024-07-18 10:10:22	171
2025-11-25	341	612	logout	2025-11-25 03:57:19	25
2026-01-25	358	565	login	2026-01-25 19:49:13	353
2025-07-10	346	47	login	2025-07-10 16:53:43	502
2025-12-11	360	542	purchase	2025-12-11 14:15:59	351
2025-04-10	352	97	purchase	2025-04-10 16:27:13	67
2024-11-29	364	321	click	2024-11-29 01:34:49	33
2024-10-28	354	230	logout	2024-10-28 22:10:29	339
2025-11-22	370	30	logout	2025-11-22 10:47:23	453
2026-03-10	355	193	view	2026-03-10 07:26:38	245
2026-02-06	373	-1	click	2026-02-06 08:39:27	-1
2024-12-27	361	83	login	2024-12-27 17:26:08	-1
2025-05-19	374	345	login	2025-05-19 07:58:26	61
2025-01-13	362	641	click	2025-01-13 23:41:51	81
2025-11-26	381	623	login	2025-11-26 04:50:32	48
2025-02-14	363	489	purchase	2025-02-14 15:13:23	367
2026-04-01	389	681	login	2026-04-01 05:42:19	110
2025-02-16	366	426	click	2025-02-16 02:01:12	395
2025-09-05	390	-1	click	2025-09-05 01:57:28	118
2026-05-10	367	98	click	2026-05-10 02:27:48	326
2025-06-09	391	690	logout	2025-06-09 21:40:52	348
2024-12-04	369	436	view	2024-12-04 23:47:54	435
2024-11-30	393	115	click	2024-11-30 01:42:58	86
2024-12-09	371	402	logout	2024-12-09 12:35:10	61
2026-03-20	395	160	logout	2026-03-20 05:08:00	407
2025-06-04	379	40	purchase	2025-06-04 17:34:18	93
2025-12-09	403	219	purchase	2025-12-09 02:03:27	57
2025-10-25	383	110	click	2025-10-25 11:32:25	380
2025-07-20	404	175	logout	2025-07-20 19:26:08	407
2025-07-02	394	55	login	2025-07-02 14:16:04	-1
2025-05-19	406	-1	purchase	2025-05-19 19:41:50	471
2024-10-13	397	446	view	2024-10-13 02:42:44	368
2025-01-13	412	-1	click	2025-01-13 17:16:51	561
2025-10-30	410	177	purchase	2025-10-30 01:22:38	251
2025-08-17	414	202	view	2025-08-17 17:27:43	397
2024-07-09	416	244	view	2024-07-09 18:34:46	491
2026-02-20	415	536	login	2026-02-20 17:48:03	10
2024-11-21	418	607	login	2024-11-21 10:08:59	189
2024-07-18	424	83	logout	2024-07-18 18:06:17	-1
2026-05-17	421	468	click	2026-05-17 00:39:57	374
2024-12-06	425	272	purchase	2024-12-06 18:59:35	373
2025-03-31	422	29	logout	2025-03-31 11:39:19	329
2025-01-10	426	431	click	2025-01-10 10:15:52	353
2025-11-14	435	223	purchase	2025-11-14 23:05:44	71
2025-03-29	428	439	click	2025-03-29 12:07:31	120
2024-10-24	436	310	login	2024-10-24 23:21:58	181
2026-01-06	429	-1	logout	2026-01-06 01:40:40	145
\N	444	387	click	\N	285
\N	437	507	click	\N	114
2025-01-29	446	412	view	2025-01-29 15:56:54	591
2025-10-12	438	74	login	2025-10-12 07:45:34	306
\N	452	492	click	\N	550
2024-12-31	439	179	view	2024-12-31 01:26:27	303
2025-04-04	455	539	logout	2025-04-04 04:43:37	591
2025-05-18	447	186	click	2025-05-18 19:28:49	-1
2024-07-21	456	489	logout	2024-07-21 09:35:53	-1
2025-01-14	449	393	click	2025-01-14 03:03:08	45
2024-11-20	457	615	click	2024-11-20 19:02:16	139
2025-03-30	458	110	view	2025-03-30 09:27:16	420
2025-09-21	459	344	purchase	2025-09-21 21:03:45	98
2026-03-20	462	417	view	2026-03-20 05:08:42	205
2025-05-17	460	567	view	2025-05-17 21:00:27	10
2024-06-08	465	106	purchase	2024-06-08 12:12:04	224
2026-04-22	461	444	click	2026-04-22 23:49:12	321
2025-10-25	469	213	view	2025-10-25 20:27:50	437
2026-03-05	464	361	click	2026-03-05 11:30:25	425
2024-12-10	470	506	click	2024-12-10 03:13:11	228
2024-11-01	466	500	logout	2024-11-01 11:56:56	588
2025-07-31	471	-1	view	2025-07-31 10:53:56	248
2026-04-27	473	38	view	2026-04-27 08:09:02	-1
2026-02-24	475	381	purchase	2026-02-24 00:17:11	350
2024-09-16	476	-1	click	2024-09-16 01:11:30	-1
2025-06-15	479	351	purchase	2025-06-15 07:35:43	-1
2025-10-02	485	101	logout	2025-10-02 05:37:49	240
2026-02-09	482	184	view	2026-02-09 17:04:17	187
2024-05-30	491	576	logout	2024-05-30 17:19:07	181
2026-01-02	484	405	logout	2026-01-02 10:30:51	265
2026-01-19	493	337	view	2026-01-19 08:46:53	521
2024-11-26	486	97	click	2024-11-26 19:16:22	-1
2025-05-02	498	662	purchase	2025-05-02 06:16:10	-1
2025-01-24	487	-1	login	2025-01-24 09:58:33	534
2025-04-20	502	103	purchase	2025-04-20 15:21:01	173
2025-01-07	490	552	purchase	2025-01-07 01:32:51	33
\N	508	345	purchase	\N	590
2026-02-19	494	66	click	2026-02-19 05:06:05	-1
2024-07-26	509	292	login	2024-07-26 12:22:49	-1
2025-08-01	495	482	login	2025-08-01 03:14:31	490
\N	513	395	view	\N	205
2024-12-28	500	422	click	2024-12-28 08:17:39	241
2025-10-15	515	608	view	2025-10-15 22:59:00	179
2025-02-26	501	445	view	2025-02-26 13:03:42	558
2025-11-09	516	248	login	2025-11-09 08:18:21	434
\N	505	251	purchase	\N	-1
2026-03-23	519	67	logout	2026-03-23 09:00:00	197
2025-05-24	506	316	purchase	2025-05-24 05:46:23	94
2025-10-10	531	649	logout	2025-10-10 19:05:21	383
2026-04-15	512	96	logout	2026-04-15 17:25:01	184
2025-04-16	533	255	logout	2025-04-16 17:46:47	433
2025-02-03	514	326	logout	2025-02-03 08:52:24	592
2024-11-08	535	415	purchase	2024-11-08 22:46:56	563
2025-05-12	520	624	logout	2025-05-12 23:28:26	313
2026-01-19	537	349	logout	2026-01-19 07:20:00	467
2025-03-21	522	435	logout	2025-03-21 00:18:17	277
\N	543	451	view	\N	221
2026-01-02	524	620	click	2026-01-02 16:15:11	484
2025-06-13	556	552	login	2025-06-13 01:25:37	177
2026-03-23	525	380	logout	2026-03-23 15:57:53	-1
2025-08-10	560	688	purchase	2025-08-10 05:57:34	227
2026-03-13	526	261	logout	2026-03-13 03:56:21	371
2024-06-25	564	302	logout	2024-06-25 19:45:38	151
2025-08-14	530	592	click	2025-08-14 14:47:26	573
2025-08-02	565	-1	purchase	2025-08-02 14:29:47	487
2024-11-13	539	661	login	2024-11-13 21:32:07	445
2024-09-04	575	456	view	2024-09-04 13:37:45	568
2024-10-21	541	-1	view	2024-10-21 05:38:02	23
2025-09-20	576	620	login	2025-09-20 03:25:22	508
2026-01-20	548	268	click	2026-01-20 06:09:20	213
2025-05-09	577	384	purchase	2025-05-09 05:33:57	293
2024-06-01	550	20	purchase	2024-06-01 15:17:02	18
2024-07-23	580	246	login	2024-07-23 02:09:15	487
2026-03-24	555	308	click	2026-03-24 07:52:53	247
2024-10-15	582	432	view	2024-10-15 03:38:35	456
2025-07-05	558	645	click	2025-07-05 21:38:55	295
2024-10-20	584	213	click	2024-10-20 08:15:13	-1
2024-08-27	563	87	logout	2024-08-27 06:17:04	2
2025-08-04	590	422	view	2025-08-04 06:47:24	14
2025-04-04	572	460	view	2025-04-04 20:26:01	309
2025-07-30	594	-1	logout	2025-07-30 18:22:08	409
\N	581	-1	click	\N	492
2025-10-05	600	598	login	2025-10-05 05:15:47	151
2026-04-04	586	35	purchase	2026-04-04 17:52:48	519
2025-12-12	607	548	click	2025-12-12 03:02:23	57
2025-12-06	601	-1	purchase	2025-12-06 07:38:41	378
2025-09-09	612	-1	purchase	2025-09-09 15:41:51	289
2026-03-09	603	540	view	2026-03-09 16:49:32	169
2025-04-03	5	202	purchase	2025-04-03 12:11:22	453
\N	604	-1	click	\N	185
2026-01-05	12	186	login	2026-01-05 11:55:07	581
2025-06-23	1	483	view	2025-06-23 18:40:09	281
2026-01-14	14	422	logout	2026-01-14 09:38:05	337
2026-03-15	11	269	view	2026-03-15 11:17:56	113
2024-08-07	15	226	view	2024-08-07 00:54:45	399
2024-07-06	17	-1	logout	2024-07-06 19:51:55	600
2025-05-18	20	494	click	2025-05-18 07:42:20	281
2025-11-17	30	636	click	2025-11-17 13:12:55	125
2024-07-20	23	73	login	2024-07-20 19:21:47	39
2026-05-15	31	206	purchase	2026-05-15 15:57:41	268
2025-02-17	25	11	logout	2025-02-17 20:02:38	-1
2026-05-03	40	297	click	2026-05-03 12:29:43	471
2024-09-11	26	679	view	2024-09-11 09:56:23	320
2025-08-23	46	674	view	2025-08-23 21:51:31	294
2025-07-20	35	392	purchase	2025-07-20 14:23:44	102
2024-12-04	49	224	login	2024-12-04 07:32:59	444
2026-01-15	36	-1	login	2026-01-15 20:18:11	139
2025-05-28	61	415	purchase	2025-05-28 16:05:21	9
2025-05-24	38	139	login	2025-05-24 03:41:19	5
2025-07-21	64	522	login	2025-07-21 01:05:00	267
2025-08-09	44	620	logout	2025-08-09 16:28:40	82
2026-03-01	68	-1	login	2026-03-01 10:15:48	514
2026-05-15	47	174	click	2026-05-15 02:49:11	291
2025-06-16	69	-1	purchase	2025-06-16 04:47:23	166
2025-11-20	48	50	click	2025-11-20 11:18:35	344
2024-09-16	72	335	logout	2024-09-16 17:05:11	-1
2024-09-14	50	678	view	2024-09-14 06:58:56	260
2026-02-13	78	448	purchase	2026-02-13 23:01:02	570
2025-11-13	52	320	view	2025-11-13 01:08:20	373
2025-01-12	83	523	view	2025-01-12 15:07:13	269
2026-05-09	56	613	view	2026-05-09 23:05:26	109
2024-08-18	87	228	login	2024-08-18 21:46:47	573
2025-10-14	57	606	purchase	2025-10-14 03:59:33	357
2026-05-10	89	476	view	2026-05-10 08:27:12	100
2024-07-15	63	114	view	2024-07-15 20:40:33	388
2026-01-16	105	276	login	2026-01-16 16:29:31	185
2025-11-10	71	570	view	2025-11-10 09:47:00	483
2024-08-23	111	548	login	2024-08-23 13:48:34	599
2025-11-07	74	40	logout	2025-11-07 05:54:10	-1
2025-03-14	114	245	click	2025-03-14 17:44:05	148
2025-05-30	76	356	purchase	2025-05-30 15:15:57	454
2026-04-08	116	228	purchase	2026-04-08 23:05:26	143
2024-07-26	79	42	login	2024-07-26 21:20:08	30
2025-12-19	119	615	click	2025-12-19 22:48:34	303
2025-09-14	85	644	view	2025-09-14 04:47:41	523
2026-05-09	121	418	click	2026-05-09 13:31:37	368
2025-08-28	86	691	logout	2025-08-28 15:16:21	395
2025-11-29	123	619	view	2025-11-29 09:58:51	130
2024-06-04	88	658	view	2024-06-04 02:23:30	233
2025-03-25	134	147	purchase	2025-03-25 00:57:54	353
2025-06-19	91	257	click	2025-06-19 07:29:42	413
2026-03-08	136	85	login	2026-03-08 19:57:10	548
2025-03-16	95	192	view	2025-03-16 05:18:29	-1
2025-05-20	137	78	login	2025-05-20 17:20:34	295
2024-09-09	96	441	view	2024-09-09 08:15:19	368
2026-03-22	144	679	logout	2026-03-22 10:51:53	136
2026-01-18	98	69	login	2026-01-18 10:19:32	471
2024-11-08	148	155	login	2024-11-08 01:57:45	365
2025-10-31	106	331	view	2025-10-31 19:35:39	189
2024-06-25	149	600	click	2024-06-25 22:08:56	530
2024-07-19	107	247	purchase	2024-07-19 15:29:32	309
2024-08-23	150	-1	logout	2024-08-23 07:48:43	226
2024-11-22	122	-1	click	2024-11-22 00:57:54	392
2026-04-21	154	579	click	2026-04-21 14:41:13	75
2025-10-27	124	364	click	2025-10-27 03:33:02	237
2025-03-23	155	213	login	2025-03-23 09:54:21	-1
2026-02-26	125	601	view	2026-02-26 08:47:23	367
2024-10-20	157	491	logout	2024-10-20 14:54:40	106
2026-05-16	128	383	login	2026-05-16 21:39:52	87
2024-09-30	158	503	click	2024-09-30 14:13:48	509
2025-12-27	132	-1	logout	2025-12-27 04:27:55	363
2026-03-31	160	216	click	2026-03-31 22:58:08	101
2024-09-25	135	-1	click	2024-09-25 10:47:48	240
2025-12-11	162	168	login	2025-12-11 04:02:26	442
2025-12-31	138	251	view	2025-12-31 04:19:41	362
2025-09-12	168	524	login	2025-09-12 02:20:14	286
\N	152	320	view	\N	251
2024-07-12	169	592	purchase	2024-07-12 12:15:40	23
2024-12-22	159	423	view	2024-12-22 02:12:45	350
2026-04-04	170	315	click	2026-04-04 21:51:14	424
2026-02-11	161	282	view	2026-02-11 05:56:41	362
2025-12-15	173	432	login	2025-12-15 02:54:50	505
2025-12-25	166	501	purchase	2025-12-25 09:06:32	322
2024-09-04	178	300	login	2024-09-04 01:17:32	7
2026-04-03	167	396	login	2026-04-03 05:18:24	452
2026-02-01	186	417	click	2026-02-01 10:50:39	533
2026-01-16	171	593	logout	2026-01-16 12:44:18	393
2026-03-28	189	300	purchase	2026-03-28 00:55:23	260
2025-02-17	172	547	view	2025-02-17 09:30:03	56
2024-09-01	191	692	view	2024-09-01 20:46:40	522
2025-10-09	174	184	click	2025-10-09 16:35:58	23
2025-03-22	194	9	purchase	2025-03-22 05:57:04	293
2024-10-16	175	629	click	2024-10-16 17:38:57	276
2026-01-20	196	380	purchase	2026-01-20 22:42:59	54
2024-12-08	179	294	login	2024-12-08 22:53:02	475
2024-11-22	199	80	purchase	2024-11-22 21:00:15	113
2024-12-20	181	-1	click	2024-12-20 20:15:50	543
2026-03-23	201	554	click	2026-03-23 21:50:45	522
2024-09-06	184	-1	purchase	2024-09-06 08:59:35	405
2024-06-09	204	416	logout	2024-06-09 23:59:10	219
2025-04-17	188	-1	view	2025-04-17 06:57:03	531
2026-03-11	208	529	login	2026-03-11 13:07:23	113
2026-02-07	200	487	logout	2026-02-07 19:59:19	62
2026-02-18	210	94	logout	2026-02-18 08:53:37	474
2024-06-13	202	591	view	2024-06-13 23:02:31	70
2026-03-04	213	96	logout	2026-03-04 09:23:26	435
2025-03-06	206	489	purchase	2025-03-06 23:32:06	52
2026-02-05	214	530	view	2026-02-05 04:57:02	585
2025-09-03	212	662	login	2025-09-03 22:26:56	447
2025-03-28	217	488	purchase	2025-03-28 10:01:04	341
2025-06-04	216	-1	click	2025-06-04 17:17:12	68
2026-03-07	221	593	logout	2026-03-07 13:10:23	164
2026-05-04	220	559	purchase	2026-05-04 11:21:54	254
2025-01-07	222	398	click	2025-01-07 16:39:49	494
2024-07-01	226	350	login	2024-07-01 10:55:56	394
2024-10-16	227	441	click	2024-10-16 01:03:52	72
2024-09-12	228	654	view	2024-09-12 08:47:21	129
2025-10-26	232	655	click	2025-10-26 16:26:32	171
2025-08-08	231	549	login	2025-08-08 18:07:44	9
2026-02-28	235	132	login	2026-02-28 20:41:19	400
2025-09-04	234	124	logout	2025-09-04 09:02:35	327
2024-08-14	248	201	logout	2024-08-14 06:20:58	187
2026-01-20	238	145	purchase	2026-01-20 01:17:01	54
2025-09-22	249	131	logout	2025-09-22 20:32:39	265
2025-08-28	240	481	logout	2025-08-28 20:07:58	438
2024-10-06	250	250	view	2024-10-06 20:34:48	371
2025-08-13	242	386	logout	2025-08-13 22:56:07	409
2026-01-24	254	-1	click	2026-01-24 18:20:18	32
2025-02-17	243	413	login	2025-02-17 13:33:07	-1
2024-08-15	273	391	click	2024-08-15 16:20:48	92
\N	245	200	purchase	\N	-1
2024-12-22	276	117	purchase	2024-12-22 22:06:44	545
2025-10-21	253	39	view	2025-10-21 10:30:40	407
2025-05-26	278	67	logout	2025-05-26 15:37:11	-1
2025-03-04	255	-1	login	2025-03-04 06:26:57	586
2025-07-10	280	-1	login	2025-07-10 23:44:56	91
2025-05-04	259	367	view	2025-05-04 08:10:46	111
2025-12-14	281	249	login	2025-12-14 13:11:42	26
2025-12-01	264	434	logout	2025-12-01 13:47:26	403
2025-05-16	284	311	purchase	2025-05-16 22:08:11	4
2025-11-12	265	552	logout	2025-11-12 00:37:29	511
2024-08-15	302	580	click	2024-08-15 18:20:17	-1
2025-09-05	268	681	purchase	2025-09-05 00:56:30	387
\N	305	571	logout	\N	31
\N	269	18	logout	\N	347
2024-08-22	306	75	purchase	2024-08-22 06:51:23	452
2026-04-17	271	411	click	2026-04-17 14:39:51	203
2025-10-18	313	609	click	2025-10-18 14:49:27	458
2024-08-20	277	46	click	2024-08-20 15:09:26	286
2025-07-05	316	-1	view	2025-07-05 09:35:25	154
2025-09-30	283	691	logout	2025-09-30 10:58:58	586
2026-02-03	318	-1	purchase	2026-02-03 16:05:27	24
2024-10-06	289	97	view	2024-10-06 09:18:51	144
2025-04-20	324	143	logout	2025-04-20 21:52:40	245
2024-06-09	292	438	view	2024-06-09 01:40:52	491
2026-01-30	330	260	click	2026-01-30 16:05:16	68
2025-02-26	293	408	click	2025-02-26 21:32:00	556
2025-10-09	336	507	login	2025-10-09 13:00:37	531
2025-07-06	297	189	login	2025-07-06 17:06:19	528
2024-06-27	337	321	view	2024-06-27 17:38:38	472
2025-03-25	300	657	logout	2025-03-25 19:57:34	1
2026-02-28	339	624	click	2026-02-28 22:58:57	419
2025-11-17	303	489	click	2025-11-17 02:28:11	-1
2026-04-13	340	625	purchase	2026-04-13 11:41:31	441
2026-02-10	307	112	login	2026-02-10 14:04:34	565
2024-09-07	347	146	logout	2024-09-07 07:00:49	354
2025-02-19	314	575	login	2025-02-19 21:44:37	475
2024-05-26	353	143	logout	2024-05-26 09:41:43	239
2025-09-14	317	349	view	2025-09-14 05:03:08	401
2025-08-08	365	428	click	2025-08-08 16:37:06	111
2024-08-28	321	122	view	2024-08-28 17:37:17	43
2025-10-04	368	488	login	2025-10-04 00:35:42	171
2025-06-28	323	140	click	2025-06-28 04:19:15	434
2024-12-01	372	435	view	2024-12-01 22:40:52	442
2024-07-07	327	313	logout	2024-07-07 15:10:57	418
2025-01-27	375	319	purchase	2025-01-27 01:00:26	-1
2026-03-20	328	695	login	2026-03-20 05:13:14	390
2025-02-14	378	288	logout	2025-02-14 06:37:36	544
2025-12-20	332	679	purchase	2025-12-20 17:30:26	527
2025-08-10	380	674	click	2025-08-10 09:51:22	379
2026-03-06	342	-1	purchase	2026-03-06 15:54:56	370
2024-06-03	385	113	purchase	2024-06-03 06:57:05	293
2025-02-13	343	-1	click	2025-02-13 14:56:32	411
2024-06-16	386	644	view	2024-06-16 14:34:48	208
2025-11-27	349	65	purchase	2025-11-27 13:52:14	360
2025-07-23	388	231	view	2025-07-23 15:12:55	161
2026-04-16	351	308	view	2026-04-16 15:03:54	576
2025-02-01	392	66	click	2025-02-01 10:23:49	522
2026-05-04	357	411	login	2026-05-04 00:25:09	153
2025-05-31	396	581	purchase	2025-05-31 15:21:53	472
2026-01-10	359	114	logout	2026-01-10 05:15:15	229
2024-08-18	398	141	login	2024-08-18 02:15:11	453
2026-03-14	376	553	click	2026-03-14 15:01:50	429
2024-12-08	400	383	view	2024-12-08 04:11:52	326
2025-09-29	377	452	view	2025-09-29 17:19:20	221
2025-01-15	402	534	login	2025-01-15 09:45:20	36
2026-03-27	382	696	click	2026-03-27 18:08:36	244
2025-02-04	405	49	view	2025-02-04 00:15:21	-1
2026-03-17	384	453	click	2026-03-17 04:48:30	66
2026-03-10	408	246	logout	2026-03-10 21:54:49	46
2025-04-10	387	663	login	2025-04-10 13:47:08	382
2025-04-08	409	78	logout	2025-04-08 02:12:54	458
2026-01-09	399	659	logout	2026-01-09 10:34:34	83
2025-12-05	411	288	view	2025-12-05 10:19:12	164
\N	401	-1	click	\N	387
2025-05-15	413	174	click	2025-05-15 16:34:08	564
2025-03-17	407	696	view	2025-03-17 18:46:15	150
\N	417	252	logout	\N	523
2025-03-10	419	48	purchase	2025-03-10 20:51:24	264
\N	423	107	login	\N	381
2025-12-03	420	-1	view	2025-12-03 20:08:18	10
2026-01-13	430	436	purchase	2026-01-13 10:45:00	138
2026-02-18	427	347	view	2026-02-18 13:14:03	465
2024-08-09	432	557	view	2024-08-09 11:32:34	507
2025-07-25	431	412	login	2025-07-25 17:27:21	452
2025-05-25	433	213	click	2025-05-25 04:29:56	538
2025-08-25	434	490	view	2025-08-25 02:36:42	144
2026-04-02	440	524	logout	2026-04-02 10:44:50	545
2026-03-16	441	432	login	2026-03-16 17:46:55	28
2025-07-22	442	257	login	2025-07-22 14:49:30	579
2024-11-19	448	117	click	2024-11-19 16:34:26	60
2025-02-19	443	397	login	2025-02-19 14:53:19	222
2025-04-26	450	271	click	2025-04-26 21:08:47	84
2025-11-14	445	555	logout	2025-11-14 12:06:23	234
2024-09-10	451	557	click	2024-09-10 23:26:25	288
2025-02-17	453	117	logout	2025-02-17 13:38:42	411
2026-03-11	467	217	logout	2026-03-11 21:04:29	600
2024-06-04	454	668	login	2024-06-04 04:32:58	459
2024-09-25	468	55	click	2024-09-25 22:43:18	117
2024-08-09	463	97	login	2024-08-09 18:33:56	376
2026-01-04	472	79	logout	2026-01-04 20:41:59	593
2025-01-22	474	58	click	2025-01-22 10:41:18	303
2025-05-17	478	224	click	2025-05-17 02:47:09	330
2025-12-11	477	562	view	2025-12-11 03:51:24	286
2025-03-20	488	678	logout	2025-03-20 05:18:19	-1
2024-12-16	480	-1	purchase	2024-12-16 06:11:43	69
2026-02-14	489	439	purchase	2026-02-14 12:57:03	594
2024-11-12	481	645	purchase	2024-11-12 09:49:20	432
2025-10-27	496	-1	login	2025-10-27 09:44:07	301
2025-10-22	483	-1	view	2025-10-22 23:21:25	556
2025-02-27	497	12	click	2025-02-27 05:32:16	176
2024-09-18	492	-1	login	2024-09-18 23:06:23	193
2025-04-18	504	160	view	2025-04-18 03:46:53	287
2026-02-16	499	538	click	2026-02-16 18:56:41	63
2024-11-08	510	553	view	2024-11-08 20:35:22	479
2025-07-27	503	304	logout	2025-07-27 06:27:57	278
2025-07-30	517	615	click	2025-07-30 20:58:32	240
2026-01-26	507	121	logout	2026-01-26 04:13:11	67
2024-09-20	518	238	view	2024-09-20 12:09:19	96
2024-10-19	511	40	click	2024-10-19 14:15:02	333
2025-05-07	521	130	click	2025-05-07 21:29:38	388
2025-08-06	523	420	purchase	2025-08-06 03:30:01	552
2024-12-21	528	393	click	2024-12-21 14:05:33	352
2026-04-17	527	295	click	2026-04-17 15:13:46	181
2025-06-29	534	291	purchase	2025-06-29 21:32:12	482
2025-06-24	529	22	click	2025-06-24 20:12:53	23
2026-01-15	536	536	view	2026-01-15 18:44:25	-1
2025-01-10	532	624	login	2025-01-10 19:54:33	9
2025-04-22	540	441	logout	2025-04-22 21:25:16	265
2024-11-29	538	218	purchase	2024-11-29 08:16:33	-1
2025-06-27	546	1	view	2025-06-27 20:19:00	518
2024-10-19	542	444	view	2024-10-19 16:39:25	-1
2025-12-17	549	377	login	2025-12-17 00:53:04	336
2025-12-07	544	537	login	2025-12-07 08:35:55	402
2026-01-27	552	235	purchase	2026-01-27 01:54:01	271
2025-08-13	545	492	login	2025-08-13 12:36:38	334
2025-09-29	554	602	purchase	2025-09-29 09:20:15	128
2025-12-10	547	433	view	2025-12-10 13:34:48	300
\N	561	20	view	\N	82
2024-09-06	551	662	login	2024-09-06 07:28:59	591
2025-08-29	567	53	login	2025-08-29 02:48:49	312
2026-03-13	553	183	login	2026-03-13 15:49:25	550
2024-08-28	568	697	logout	2024-08-28 11:32:45	521
2026-05-21	557	386	purchase	2026-05-21 05:20:55	74
2024-11-10	571	451	view	2024-11-10 12:11:23	49
2024-06-08	559	587	login	2024-06-08 02:07:00	54
2025-04-23	573	287	login	2025-04-23 08:58:30	439
2026-03-09	562	145	logout	2026-03-09 05:53:42	342
2025-10-16	583	360	view	2025-10-16 15:38:02	483
2025-02-26	566	50	login	2025-02-26 14:24:19	151
2025-07-09	588	251	purchase	2025-07-09 19:29:35	433
2024-10-28	569	613	click	2024-10-28 20:17:16	551
2025-12-28	591	38	view	2025-12-28 07:49:22	585
2026-05-16	570	74	click	2026-05-16 00:46:08	380
2025-07-17	592	81	click	2025-07-17 07:28:11	599
2026-03-28	574	178	click	2026-03-28 11:21:53	402
2025-01-16	593	682	login	2025-01-16 04:06:11	-1
2024-08-28	578	515	click	2024-08-28 15:33:45	195
2025-02-17	598	460	view	2025-02-17 04:11:33	419
2025-05-25	579	457	purchase	2025-05-25 12:25:04	29
2026-04-14	599	524	view	2026-04-14 07:44:29	473
2026-01-24	585	60	view	2026-01-24 21:07:14	285
2025-12-09	602	414	logout	2025-12-09 04:10:46	18
2026-03-06	587	154	purchase	2026-03-06 05:18:09	352
2025-01-27	605	589	login	2025-01-27 10:22:20	293
2025-09-23	589	375	click	2025-09-23 09:15:57	134
2026-01-29	608	364	view	2026-01-29 07:08:58	386
2025-07-05	595	322	view	2025-07-05 22:37:39	326
2025-02-27	614	517	click	2025-02-27 04:50:49	85
2025-09-18	596	515	login	2025-09-18 19:12:35	284
2025-08-17	615	551	login	2025-08-17 02:30:04	509
2025-12-08	597	412	purchase	2025-12-08 06:21:12	482
2024-11-07	619	326	view	2024-11-07 14:41:18	-1
2024-08-20	606	18	login	2024-08-20 07:13:05	-1
2024-10-25	613	-1	click	2024-10-25 15:26:53	232
2024-12-23	610	219	view	2024-12-23 21:17:27	513
2025-01-05	616	491	click	2025-01-05 09:09:50	209
2026-02-05	611	348	login	2026-02-05 16:36:12	310
\N	617	376	click	\N	364
2024-06-07	618	527	purchase	2024-06-07 03:29:51	429
2025-01-29	620	540	purchase	2025-01-29 09:49:14	122
2024-08-27	628	546	purchase	2024-08-27 00:33:57	194
2026-02-03	622	635	logout	2026-02-03 13:47:45	78
2025-12-04	634	303	view	2025-12-04 20:29:23	86
2025-07-14	626	602	logout	2025-07-14 07:36:44	586
2025-12-07	635	341	purchase	2025-12-07 22:39:57	56
2025-06-11	631	589	click	2025-06-11 14:19:57	54
2025-09-09	649	649	purchase	2025-09-09 12:23:36	412
2025-11-10	640	-1	purchase	2025-11-10 06:58:35	311
2025-11-30	651	391	view	2025-11-30 21:24:21	-1
2024-06-10	648	428	click	2024-06-10 22:06:36	86
2025-03-21	656	-1	login	2025-03-21 11:52:45	274
2024-09-19	650	175	login	2024-09-19 13:00:10	583
2025-09-26	658	196	view	2025-09-26 07:48:02	359
2024-06-09	652	278	view	2024-06-09 18:09:55	12
2024-08-13	662	45	view	2024-08-13 14:33:52	187
2025-12-30	655	565	view	2025-12-30 10:21:35	162
2025-03-25	666	650	logout	2025-03-25 21:20:32	447
2025-05-26	657	573	login	2025-05-26 08:50:30	261
2024-08-01	670	454	login	2024-08-01 14:05:29	-1
2026-01-01	663	-1	purchase	2026-01-01 08:15:03	489
2026-01-03	671	639	view	2026-01-03 13:39:04	54
2025-04-09	664	270	login	2025-04-09 13:44:52	-1
2024-10-23	672	427	click	2024-10-23 17:29:43	24
2024-09-27	673	91	click	2024-09-27 21:25:37	10
\N	675	82	logout	\N	522
2026-04-26	678	173	logout	2026-04-26 21:20:09	76
2025-07-21	677	534	purchase	2025-07-21 19:48:59	574
2025-06-21	684	262	logout	2025-06-21 07:24:30	-1
2025-05-13	679	604	view	2025-05-13 04:30:09	577
2025-01-27	688	539	logout	2025-01-27 01:57:48	114
2025-03-13	691	-1	login	2025-03-13 03:06:16	420
2024-12-25	692	655	view	2024-12-25 06:00:57	409
2025-09-13	697	516	login	2025-09-13 05:28:59	469
2025-05-25	696	331	purchase	2025-05-25 08:50:06	163
2024-11-06	701	505	purchase	2024-11-06 16:41:55	-1
2025-12-08	700	124	view	2025-12-08 11:44:34	-1
2025-11-26	703	657	view	2025-11-26 00:49:57	452
2024-06-26	702	417	purchase	2024-06-26 02:32:21	367
2025-01-11	709	555	click	2025-01-11 14:39:14	-1
2025-03-04	705	52	click	2025-03-04 10:20:51	517
2025-12-12	710	172	login	2025-12-12 22:49:22	582
2024-12-07	708	177	click	2024-12-07 20:01:08	288
2026-02-09	713	9	click	2026-02-09 15:50:49	567
2025-10-31	711	644	purchase	2025-10-31 11:54:48	51
2025-03-26	721	640	view	2025-03-26 15:17:23	157
2024-12-15	715	248	logout	2024-12-15 09:05:20	498
2025-11-02	725	571	view	2025-11-02 11:13:50	465
2025-01-18	720	645	click	2025-01-18 11:34:54	307
2026-05-11	726	349	logout	2026-05-11 12:29:54	163
2025-03-29	723	700	logout	2025-03-29 16:43:01	44
2025-04-09	727	396	purchase	2025-04-09 14:15:33	-1
2026-03-20	729	3	logout	2026-03-20 19:34:29	23
2025-01-17	733	694	purchase	2025-01-17 22:36:13	315
2025-09-08	730	493	view	2025-09-08 11:58:50	577
2026-03-05	738	359	purchase	2026-03-05 09:23:53	38
2025-01-01	731	-1	view	2025-01-01 22:00:18	67
2025-09-08	741	228	login	2025-09-08 18:39:43	505
2025-03-15	749	-1	click	2025-03-15 07:09:40	375
2024-08-07	742	105	login	2024-08-07 10:21:00	179
2024-11-10	753	682	click	2024-11-10 04:35:38	550
2025-08-09	744	56	click	2025-08-09 14:12:21	116
2024-09-27	755	353	logout	2024-09-27 14:36:17	500
2024-12-25	746	53	view	2024-12-25 03:31:23	342
2026-03-28	761	456	view	2026-03-28 02:26:58	505
2025-05-31	747	659	login	2025-05-31 20:31:14	295
2024-11-04	762	686	click	2024-11-04 04:50:38	128
2025-09-06	750	480	purchase	2025-09-06 02:47:41	107
2025-08-19	765	-1	view	2025-08-19 05:10:28	27
2025-10-11	751	229	login	2025-10-11 20:06:58	403
2024-07-28	770	557	logout	2024-07-28 18:54:18	542
2025-10-17	752	547	purchase	2025-10-17 11:51:16	-1
2024-08-13	771	321	view	2024-08-13 11:57:05	160
2025-02-06	754	376	purchase	2025-02-06 09:39:35	597
2025-01-16	772	113	purchase	2025-01-16 11:11:43	243
2026-01-25	756	371	view	2026-01-25 13:09:34	413
2026-02-14	775	246	purchase	2026-02-14 18:05:37	-1
2025-08-07	757	46	logout	2025-08-07 23:18:56	269
2025-08-03	778	237	view	2025-08-03 20:08:13	-1
2026-04-13	777	547	purchase	2026-04-13 07:11:38	219
2024-09-04	781	443	click	2024-09-04 02:49:18	582
2024-05-28	779	8	click	2024-05-28 04:59:12	480
2025-01-28	785	373	login	2025-01-28 14:13:50	575
2024-06-07	783	533	click	2024-06-07 16:25:49	12
2025-01-15	787	186	login	2025-01-15 17:04:53	483
2024-09-12	788	606	view	2024-09-12 06:02:07	519
2026-03-19	794	314	purchase	2026-03-19 12:02:18	271
2026-02-13	792	387	view	2026-02-13 09:26:44	560
2026-04-20	800	103	click	2026-04-20 23:41:12	440
2024-05-25	798	88	login	2024-05-25 20:56:57	19
2024-06-12	802	509	purchase	2024-06-12 19:49:59	138
2025-06-26	801	526	view	2025-06-26 01:44:04	287
2025-07-19	803	-1	view	2025-07-19 19:19:28	535
2025-04-15	805	100	login	2025-04-15 23:59:48	213
2025-12-23	806	-1	view	2025-12-23 19:55:27	405
2026-03-09	808	11	login	2026-03-09 20:35:37	557
2025-09-29	810	-1	login	2025-09-29 15:43:25	68
2026-01-19	809	243	login	2026-01-19 20:11:34	-1
2025-08-24	814	228	click	2025-08-24 12:07:12	305
2024-07-20	815	671	login	2024-07-20 03:07:47	440
2024-07-31	833	588	purchase	2024-07-31 14:15:47	167
2025-02-21	817	38	click	2025-02-21 10:46:17	21
2024-06-09	842	650	logout	2024-06-09 08:08:34	245
2026-04-24	819	34	login	2026-04-24 18:15:25	235
2025-06-07	844	465	login	2025-06-07 23:53:47	447
2025-10-13	821	462	view	2025-10-13 17:43:25	383
2025-06-23	849	431	login	2025-06-23 15:27:33	512
2024-09-02	826	176	view	2024-09-02 16:44:27	116
2025-02-23	850	271	purchase	2025-02-23 03:33:59	1
2025-05-10	827	434	view	2025-05-10 17:20:16	523
2025-06-01	854	297	view	2025-06-01 01:58:22	598
2025-03-16	831	419	click	2025-03-16 01:02:30	335
2024-11-20	859	156	logout	2024-11-20 08:08:08	520
2025-12-04	832	87	purchase	2025-12-04 16:48:58	387
\N	862	542	login	\N	445
2026-01-01	841	5	login	2026-01-01 13:41:30	238
2024-06-20	863	389	logout	2024-06-20 23:29:18	418
2025-11-24	847	693	click	2025-11-24 16:57:38	484
2024-06-15	867	584	login	2024-06-15 00:51:50	229
2025-02-19	851	310	logout	2025-02-19 14:27:24	-1
2025-07-07	872	295	click	2025-07-07 00:20:45	248
2024-11-29	852	311	login	2024-11-29 19:36:02	223
2025-06-14	873	54	click	2025-06-14 14:06:25	236
2026-01-26	853	120	purchase	2026-01-26 03:38:11	350
2024-09-15	875	387	purchase	2024-09-15 23:50:03	3
2026-03-07	858	429	click	2026-03-07 23:38:06	467
2024-11-24	878	313	logout	2024-11-24 15:21:50	494
2025-09-02	864	70	click	2025-09-02 04:21:17	562
2024-07-09	880	260	logout	2024-07-09 12:04:28	545
2025-07-05	869	72	view	2025-07-05 15:05:37	449
2025-01-07	881	491	purchase	2025-01-07 00:59:26	120
2026-04-19	871	430	view	2026-04-19 17:41:15	172
2025-12-10	895	118	click	2025-12-10 12:45:08	188
2025-11-20	874	259	view	2025-11-20 08:49:32	29
2025-09-22	896	555	view	2025-09-22 05:41:03	20
2025-09-05	876	409	click	2025-09-05 06:56:25	449
2025-08-27	897	332	view	2025-08-27 01:20:33	500
2025-04-20	884	7	login	2025-04-20 10:43:23	310
2025-11-05	898	320	view	2025-11-05 17:56:40	22
2025-07-17	885	136	view	2025-07-17 11:52:21	435
2025-10-04	912	351	view	2025-10-04 11:26:15	472
2026-03-16	887	696	click	2026-03-16 17:33:22	134
2026-01-12	913	8	view	2026-01-12 18:01:31	580
2024-07-10	888	173	view	2024-07-10 02:50:00	36
2025-06-08	917	130	click	2025-06-08 03:29:44	461
2024-07-15	891	484	login	2024-07-15 22:31:09	532
2024-12-19	920	352	purchase	2024-12-19 18:59:14	128
2024-10-04	892	509	view	2024-10-04 09:02:40	162
2025-08-07	923	343	login	2025-08-07 18:25:46	114
2024-12-11	893	318	login	2024-12-11 22:00:15	116
2025-01-31	925	244	click	2025-01-31 04:32:27	355
2024-06-16	899	151	view	2024-06-16 20:48:53	501
2024-08-11	926	616	logout	2024-08-11 22:56:53	72
2024-07-02	902	57	purchase	2024-07-02 17:42:53	135
2026-02-14	931	474	click	2026-02-14 22:36:57	386
2025-04-14	910	266	logout	2025-04-14 11:04:50	138
2024-11-25	936	596	view	2024-11-25 16:42:01	52
2025-06-30	911	411	purchase	2025-06-30 12:22:45	545
2026-02-16	938	495	login	2026-02-16 21:44:04	172
2025-07-22	914	443	login	2025-07-22 00:44:07	29
2024-07-06	940	609	view	2024-07-06 19:07:01	-1
2025-01-20	919	489	logout	2025-01-20 10:20:25	106
2025-03-18	942	645	view	2025-03-18 15:50:08	152
2025-07-14	921	80	click	2025-07-14 14:41:10	455
\N	951	362	logout	\N	173
2026-04-08	929	492	purchase	2026-04-08 17:07:52	314
2024-08-15	956	417	purchase	2024-08-15 23:10:51	463
2026-03-31	932	371	purchase	2026-03-31 02:04:06	315
2025-07-13	963	218	logout	2025-07-13 05:27:26	356
2026-03-12	934	586	click	2026-03-12 06:07:46	547
2025-07-27	970	-1	click	2025-07-27 03:04:17	236
2024-10-06	945	432	view	2024-10-06 09:32:25	-1
2024-07-25	973	500	purchase	2024-07-25 23:05:40	333
2026-01-25	947	223	logout	2026-01-25 00:14:59	280
2025-04-18	976	664	purchase	2025-04-18 01:42:43	403
2024-10-24	949	653	purchase	2024-10-24 04:07:42	426
2025-06-21	978	382	click	2025-06-21 12:41:32	523
2026-03-21	953	-1	login	2026-03-21 04:35:51	44
2025-08-01	979	37	logout	2025-08-01 02:17:59	94
2025-06-19	955	39	view	2025-06-19 15:45:37	465
2024-06-11	980	256	purchase	2024-06-11 21:04:07	358
2026-03-26	957	516	purchase	2026-03-26 07:46:42	54
2024-12-21	986	441	login	2024-12-21 16:41:40	77
2026-04-19	958	-1	click	2026-04-19 14:48:25	128
2024-11-10	988	244	view	2024-11-10 06:35:55	1
\N	962	-1	logout	\N	328
2025-08-17	995	99	click	2025-08-17 06:06:37	498
2024-08-18	968	434	click	2024-08-18 11:29:25	488
2024-11-25	999	485	purchase	2024-11-25 20:05:13	362
2025-06-28	975	650	view	2025-06-28 16:01:00	156
2024-06-29	1006	431	login	2024-06-29 16:28:17	30
2026-01-10	983	322	view	2026-01-10 08:18:34	402
2025-06-19	1009	355	logout	2025-06-19 04:39:30	422
2026-02-11	989	470	view	2026-02-11 19:48:02	297
2026-04-11	1011	-1	login	2026-04-11 02:55:07	528
2025-12-01	992	80	click	2025-12-01 14:10:37	433
2024-12-26	1013	346	view	2024-12-26 23:35:08	312
2025-06-12	997	-1	login	2025-06-12 19:42:25	396
\N	1019	-1	click	\N	205
2026-01-21	1000	431	view	2026-01-21 21:25:36	-1
2025-12-13	1023	269	click	2025-12-13 03:57:30	298
2025-12-07	1003	-1	login	2025-12-07 04:30:31	500
2024-12-13	1029	14	purchase	2024-12-13 18:42:15	226
2025-01-02	1008	613	logout	2025-01-02 21:39:52	262
2025-06-22	1031	229	logout	2025-06-22 03:32:16	232
2024-08-26	1015	412	purchase	2024-08-26 21:53:06	92
2024-08-17	1036	161	click	2024-08-17 21:22:50	336
2024-09-08	1017	17	click	2024-09-08 07:26:37	355
2024-07-26	1045	498	view	2024-07-26 19:30:00	391
2025-11-23	1022	493	view	2025-11-23 19:22:22	148
2024-08-18	1057	631	purchase	2024-08-18 13:17:07	388
2024-09-06	1024	346	view	2024-09-06 18:40:15	303
2025-05-20	1063	161	view	2025-05-20 03:01:14	-1
2024-08-26	1027	508	login	2024-08-26 13:18:21	523
2026-02-22	1064	-1	purchase	2026-02-22 00:39:02	515
2025-09-18	1035	-1	view	2025-09-18 00:29:32	387
2025-03-05	1065	370	logout	2025-03-05 01:12:30	49
2025-05-20	1042	13	login	2025-05-20 13:01:35	45
2025-03-07	1071	466	view	2025-03-07 20:55:15	461
2025-01-17	1044	594	logout	2025-01-17 13:48:07	283
2025-07-04	1077	360	view	2025-07-04 23:41:31	570
2025-06-15	1046	199	purchase	2025-06-15 01:20:05	401
2026-01-27	1079	-1	logout	2026-01-27 01:57:52	341
2025-11-07	1047	627	logout	2025-11-07 13:44:52	289
2025-01-18	1080	303	view	2025-01-18 00:16:53	232
2025-02-02	1048	311	view	2025-02-02 00:31:28	266
\N	1081	-1	purchase	\N	288
2025-09-07	1049	-1	purchase	2025-09-07 23:18:38	403
2025-08-26	1082	452	logout	2025-08-26 21:19:50	-1
2026-01-20	1050	196	click	2026-01-20 08:35:40	241
2025-08-21	1083	308	login	2025-08-21 18:03:23	598
2025-08-17	1051	474	purchase	2025-08-17 22:54:09	76
2025-05-11	1084	532	logout	2025-05-11 21:16:53	72
2024-11-29	1066	396	purchase	2024-11-29 16:36:20	516
2026-04-09	1098	319	logout	2026-04-09 01:01:25	394
\N	1067	470	view	\N	108
2024-06-07	1101	242	login	2024-06-07 14:20:18	582
2025-08-17	1068	269	purchase	2025-08-17 01:22:45	400
2025-11-22	1102	311	click	2025-11-22 18:57:56	508
2025-08-14	1073	-1	click	2025-08-14 00:48:21	110
2025-08-30	1107	248	click	2025-08-30 00:46:33	494
2025-01-09	1074	-1	logout	2025-01-09 08:56:12	191
2026-04-19	1108	624	view	2026-04-19 23:45:01	375
2025-02-18	1089	38	view	2025-02-18 00:50:30	76
2026-02-03	1109	373	view	2026-02-03 14:52:07	235
2025-08-23	1117	-1	view	2025-08-23 22:04:45	405
2025-12-18	1110	328	click	2025-12-18 07:45:39	125
2025-10-30	1118	408	logout	2025-10-30 07:31:03	371
2026-03-27	1127	53	logout	2026-03-27 07:33:19	490
2025-03-05	1119	330	view	2025-03-05 22:14:01	-1
2024-12-28	1133	22	view	2024-12-28 22:12:53	408
\N	1120	178	view	\N	83
2024-09-18	1135	643	click	2024-09-18 13:21:24	160
2026-02-21	1123	198	purchase	2026-02-21 21:34:26	-1
2024-11-19	1138	625	login	2024-11-19 18:56:59	445
2024-07-19	1129	682	view	2024-07-19 21:03:31	478
2025-09-13	1147	645	logout	2025-09-13 18:33:16	116
2024-05-31	1131	325	view	2024-05-31 19:22:49	130
2026-03-29	1152	-1	login	2026-03-29 17:56:55	-1
2024-08-11	1139	-1	click	2024-08-11 02:40:47	592
2025-09-12	1154	17	purchase	2025-09-12 14:16:27	242
2025-04-07	1141	352	logout	2025-04-07 19:05:02	412
2024-10-28	1158	638	logout	2024-10-28 10:52:58	502
2026-03-24	1151	609	view	2026-03-24 09:41:21	398
2025-12-23	1165	403	login	2025-12-23 07:29:22	107
2024-10-16	1156	405	click	2024-10-16 22:44:43	332
2025-08-07	1170	143	click	2025-08-07 16:43:54	176
2025-08-27	1161	324	view	2025-08-27 19:01:58	150
2025-06-19	1172	538	click	2025-06-19 22:22:56	236
2024-11-27	1164	13	logout	2024-11-27 22:30:25	364
2025-12-01	1179	-1	purchase	2025-12-01 15:24:44	20
2024-09-20	1167	211	view	2024-09-20 06:44:44	371
2024-10-05	1183	14	view	2024-10-05 00:38:42	138
\N	1174	558	click	\N	137
2026-02-09	1185	-1	click	2026-02-09 01:13:01	146
2026-04-03	1178	215	purchase	2026-04-03 17:20:07	-1
2026-03-24	1189	-1	view	2026-03-24 02:42:48	437
2025-10-05	1181	634	logout	2025-10-05 22:31:20	132
2024-08-15	1195	338	view	2024-08-15 21:11:04	307
2026-01-16	1182	132	click	2026-01-16 02:24:02	49
2025-03-29	1198	-1	view	2025-03-29 04:01:52	418
2025-10-28	1184	133	view	2025-10-28 01:44:02	542
2025-05-16	1199	631	login	2025-05-16 19:59:54	200
2024-10-04	1188	-1	logout	2024-10-04 16:07:40	426
2025-09-29	1206	110	purchase	2025-09-29 18:24:11	333
2024-08-24	1190	627	logout	2024-08-24 09:32:32	313
2025-04-17	1208	457	logout	2025-04-17 22:59:57	412
2025-12-26	1197	-1	click	2025-12-26 06:04:32	122
\N	1211	547	logout	\N	-1
2024-06-12	1200	126	click	2024-06-12 00:10:58	382
2024-11-25	1215	47	purchase	2024-11-25 12:33:56	454
\N	1220	700	login	\N	584
2024-11-14	1221	366	logout	2024-11-14 03:11:32	40
2025-06-01	1222	112	click	2025-06-01 12:29:59	211
2025-01-19	1225	444	view	2025-01-19 07:25:14	520
2026-02-22	1237	627	purchase	2026-02-22 05:10:29	321
2024-12-08	1226	651	logout	2024-12-08 16:49:31	233
2024-10-10	1243	256	logout	2024-10-10 22:29:58	-1
2026-01-10	624	370	view	2026-01-10 06:06:21	354
2025-02-06	609	34	purchase	2025-02-06 06:43:33	250
2026-04-07	627	94	view	2026-04-07 22:38:39	201
2025-03-08	621	501	purchase	2025-03-08 17:01:33	-1
2024-06-13	629	266	logout	2024-06-13 06:01:32	178
2024-12-22	623	175	logout	2024-12-22 20:56:27	339
2025-11-11	632	602	view	2025-11-11 18:44:49	528
2024-10-03	625	636	logout	2024-10-03 09:19:32	100
2025-10-12	633	322	click	2025-10-12 17:00:34	90
2024-08-31	630	320	view	2024-08-31 09:00:33	379
2025-06-13	636	65	view	2025-06-13 07:39:52	315
2025-11-01	638	49	login	2025-11-01 20:28:43	563
2025-01-05	637	-1	login	2025-01-05 00:32:44	103
2024-07-08	639	311	purchase	2024-07-08 21:11:49	417
2025-03-25	641	123	click	2025-03-25 04:36:00	101
2025-02-07	643	274	view	2025-02-07 10:05:28	85
2026-03-21	642	145	logout	2026-03-21 03:30:42	-1
2026-05-19	645	-1	login	2026-05-19 17:24:34	96
\N	644	633	view	\N	108
2025-03-29	647	681	view	2025-03-29 02:11:04	145
2026-01-30	646	18	logout	2026-01-30 16:42:35	164
2024-12-01	659	91	click	2024-12-01 17:19:23	46
2025-09-30	653	354	click	2025-09-30 01:43:19	-1
2025-10-01	667	402	purchase	2025-10-01 14:41:56	97
2024-08-07	654	649	purchase	2024-08-07 07:29:07	136
2025-03-17	669	226	login	2025-03-17 14:55:16	523
2024-07-12	660	340	logout	2024-07-12 02:22:45	24
2025-02-12	674	287	logout	2025-02-12 03:02:56	458
2024-08-17	661	-1	logout	2024-08-17 17:04:20	390
2025-12-31	682	419	view	2025-12-31 13:29:30	340
\N	665	350	logout	\N	86
2025-12-18	683	-1	login	2025-12-18 15:29:09	570
2024-07-22	668	399	purchase	2024-07-22 15:53:54	138
2025-04-03	685	542	login	2025-04-03 12:50:01	340
2024-07-23	676	18	view	2024-07-23 23:55:21	263
2026-04-02	686	390	click	2026-04-02 23:21:05	171
2025-08-22	680	-1	purchase	2025-08-22 08:24:18	452
2024-08-16	689	540	click	2024-08-16 12:41:53	43
2026-03-31	681	132	logout	2026-03-31 01:52:17	96
2026-05-05	690	448	logout	2026-05-05 15:48:54	549
2026-03-08	687	377	logout	2026-03-08 11:37:47	163
2024-06-19	693	286	logout	2024-06-19 13:11:25	276
2026-02-22	695	82	click	2026-02-22 07:38:42	490
2024-08-18	694	288	logout	2024-08-18 07:20:42	151
2026-03-18	698	284	view	2026-03-18 08:59:13	299
2025-07-01	699	540	click	2025-07-01 04:43:40	331
2024-07-27	706	189	view	2024-07-27 15:25:45	197
2024-10-14	704	543	click	2024-10-14 02:58:08	9
2024-11-20	712	85	logout	2024-11-20 00:50:58	282
2025-06-08	707	39	purchase	2025-06-08 02:38:19	159
2025-04-10	714	6	purchase	2025-04-10 11:00:12	450
2025-01-31	718	42	login	2025-01-31 18:38:50	274
2024-09-22	716	107	purchase	2024-09-22 00:22:20	427
2026-02-11	724	175	purchase	2026-02-11 15:01:55	223
2025-09-17	717	17	logout	2025-09-17 03:20:16	403
2025-04-01	732	468	purchase	2025-04-01 01:13:26	587
2026-02-13	719	413	click	2026-02-13 02:47:51	50
2025-07-25	734	619	purchase	2025-07-25 10:27:53	103
2025-11-28	722	-1	purchase	2025-11-28 04:28:23	-1
2024-09-01	735	440	logout	2024-09-01 04:13:51	533
2024-11-30	728	380	logout	2024-11-30 22:44:19	405
2026-02-25	736	690	logout	2026-02-25 02:38:22	345
2024-12-22	737	679	purchase	2024-12-22 09:16:44	445
2025-02-07	740	270	click	2025-02-07 16:42:43	314
2025-07-31	739	-1	purchase	2025-07-31 18:57:45	-1
2025-08-23	743	145	logout	2025-08-23 12:11:14	-1
2024-10-20	748	630	click	2024-10-20 04:14:26	269
2025-06-10	745	355	logout	2025-06-10 08:50:51	128
2024-11-10	758	644	click	2024-11-10 02:15:12	245
2024-10-09	760	19	purchase	2024-10-09 17:42:14	-1
2026-03-11	759	219	purchase	2026-03-11 13:35:39	308
2025-08-08	764	531	login	2025-08-08 00:47:55	382
2026-05-16	763	570	purchase	2026-05-16 19:27:59	43
2025-08-03	768	108	view	2025-08-03 13:51:46	472
2025-04-17	766	196	login	2025-04-17 01:46:20	80
2025-04-04	769	587	purchase	2025-04-04 06:11:30	501
2024-08-09	767	472	view	2024-08-09 03:30:28	41
2026-04-24	773	681	logout	2026-04-24 04:13:50	412
2024-07-09	776	418	view	2024-07-09 01:15:47	137
2025-12-14	774	694	click	2025-12-14 21:40:15	499
2025-05-22	782	424	view	2025-05-22 15:02:00	275
2025-11-27	780	318	purchase	2025-11-27 09:42:44	233
2024-10-26	791	78	click	2024-10-26 23:40:31	163
2025-05-29	784	681	login	2025-05-29 15:13:34	234
2024-06-19	793	582	click	2024-06-19 06:51:48	-1
2024-12-02	786	158	view	2024-12-02 10:55:11	351
2025-11-05	797	113	logout	2025-11-05 16:41:02	351
2025-07-11	789	536	logout	2025-07-11 14:22:57	130
2025-07-15	804	250	purchase	2025-07-15 18:30:19	62
2026-05-07	790	689	click	2026-05-07 16:04:58	171
2025-05-29	807	299	login	2025-05-29 10:44:38	587
2024-09-23	795	645	login	2024-09-23 20:08:06	220
2025-04-28	812	289	logout	2025-04-28 01:31:58	51
2025-03-20	796	186	purchase	2025-03-20 15:13:08	79
2024-07-19	816	479	logout	2024-07-19 00:20:45	411
2025-09-21	799	-1	view	2025-09-21 12:17:27	553
2025-03-13	818	397	purchase	2025-03-13 07:17:52	583
2024-05-28	811	652	view	2024-05-28 14:21:29	43
2025-12-06	822	573	click	2025-12-06 20:04:48	558
2025-09-01	813	673	logout	2025-09-01 07:10:06	589
2025-01-11	823	146	login	2025-01-11 03:37:21	474
2025-10-17	820	306	view	2025-10-17 18:13:35	-1
2026-05-04	828	467	purchase	2026-05-04 08:42:14	145
2024-11-03	824	284	purchase	2024-11-03 08:46:14	69
2025-06-14	829	618	purchase	2025-06-14 15:33:58	516
2025-03-12	825	613	login	2025-03-12 01:20:13	350
2024-11-24	834	84	view	2024-11-24 07:49:39	557
2024-08-23	830	306	logout	2024-08-23 04:35:24	5
2025-04-03	836	651	login	2025-04-03 12:55:10	13
2026-04-18	835	251	logout	2026-04-18 09:38:25	526
2024-09-30	837	226	logout	2024-09-30 11:20:08	505
2026-01-19	838	505	login	2026-01-19 19:27:41	197
2026-04-11	839	34	logout	2026-04-11 14:24:22	59
2025-09-03	840	587	click	2025-09-03 05:18:48	392
2025-01-10	843	459	purchase	2025-01-10 09:33:42	571
2025-01-06	845	-1	purchase	2025-01-06 07:45:28	333
2025-10-27	846	672	logout	2025-10-27 00:56:13	466
2024-12-15	861	11	purchase	2024-12-15 09:44:07	390
2025-11-28	848	243	click	2025-11-28 07:23:06	595
2024-12-10	877	551	purchase	2024-12-10 04:24:40	-1
2024-09-16	855	369	purchase	2024-09-16 07:41:20	424
2025-04-05	882	593	logout	2025-04-05 07:20:47	263
2024-12-24	856	121	view	2024-12-24 12:17:31	590
2025-11-06	886	564	login	2025-11-06 22:20:13	29
2026-02-11	857	485	login	2026-02-11 21:01:08	360
2025-11-06	889	96	purchase	2025-11-06 16:59:57	425
2025-06-14	860	346	view	2025-06-14 14:37:46	594
2025-06-30	900	370	purchase	2025-06-30 23:43:46	283
2025-11-20	865	-1	login	2025-11-20 05:00:46	468
2024-08-14	903	478	view	2024-08-14 14:02:46	365
2025-12-22	866	450	login	2025-12-22 08:33:28	211
2024-12-09	904	176	logout	2024-12-09 10:09:02	283
2024-07-04	868	509	click	2024-07-04 08:39:20	455
2025-06-03	905	175	click	2025-06-03 23:01:23	408
2024-12-28	870	245	view	2024-12-28 13:23:06	-1
2025-08-01	915	633	view	2025-08-01 20:01:06	48
2024-12-02	879	-1	view	2024-12-02 06:27:55	272
2024-11-28	916	123	click	2024-11-28 05:37:40	362
2025-09-05	883	171	purchase	2025-09-05 06:38:18	543
2024-10-20	924	318	purchase	2024-10-20 03:13:26	479
2026-04-05	890	214	logout	2026-04-05 21:14:54	553
2026-01-23	930	203	purchase	2026-01-23 09:59:29	-1
2025-03-13	894	486	logout	2025-03-13 23:38:08	308
2025-09-12	935	-1	purchase	2025-09-12 19:53:32	483
2025-02-27	901	543	click	2025-02-27 04:47:55	70
2026-05-23	941	237	view	2026-05-23 16:11:42	275
2026-05-05	906	57	purchase	2026-05-05 22:18:59	556
2024-07-22	944	187	view	2024-07-22 08:12:30	337
2025-06-08	907	194	logout	2025-06-08 12:48:10	520
2025-08-28	946	68	click	2025-08-28 19:44:33	229
2026-04-30	908	506	click	2026-04-30 14:51:38	222
2025-02-16	948	460	click	2025-02-16 03:18:00	552
2025-10-09	909	408	view	2025-10-09 11:37:33	91
2024-07-18	950	-1	login	2024-07-18 02:08:42	85
2026-04-26	918	4	logout	2026-04-26 03:14:12	203
2025-09-19	959	411	logout	2025-09-19 23:50:01	63
2026-01-22	922	86	click	2026-01-22 22:37:32	478
2024-09-30	960	444	purchase	2024-09-30 17:01:27	275
2025-05-25	927	183	logout	2025-05-25 13:59:39	482
2026-02-28	964	179	logout	2026-02-28 15:05:19	343
2024-06-05	928	-1	login	2024-06-05 05:55:32	473
2026-01-09	966	-1	login	2026-01-09 05:25:51	349
2024-07-16	933	229	view	2024-07-16 11:01:30	-1
2025-11-18	967	255	click	2025-11-18 21:04:38	236
2024-09-12	937	582	logout	2024-09-12 22:27:15	363
2025-03-14	971	356	view	2025-03-14 09:40:34	129
2025-10-23	939	416	click	2025-10-23 23:15:33	268
2025-03-25	972	255	purchase	2025-03-25 23:04:50	30
2026-05-06	943	478	view	2026-05-06 20:34:41	189
2026-02-27	974	548	view	2026-02-27 19:26:40	274
2026-03-02	952	171	click	2026-03-02 01:56:10	477
2024-09-14	977	313	logout	2024-09-14 19:32:15	381
2025-09-30	954	-1	logout	2025-09-30 07:24:39	589
2024-12-17	982	71	login	2024-12-17 08:22:32	510
2024-08-08	961	585	click	2024-08-08 00:30:59	237
2025-11-16	984	443	click	2025-11-16 01:30:37	-1
2025-07-06	965	468	logout	2025-07-06 17:51:57	227
2025-10-16	987	688	logout	2025-10-16 09:56:44	443
2024-09-09	969	-1	logout	2024-09-09 11:00:26	196
2024-08-17	990	158	logout	2024-08-17 23:00:11	395
2024-05-24	981	-1	purchase	2024-05-24 17:26:05	261
2025-06-12	991	513	login	2025-06-12 23:25:28	472
2025-07-25	985	666	purchase	2025-07-25 10:26:35	18
2026-04-19	993	25	logout	2026-04-19 12:30:20	-1
2025-02-18	994	39	view	2025-02-18 17:51:54	428
2026-03-12	996	526	logout	2026-03-12 18:52:02	-1
2024-08-30	1002	571	click	2024-08-30 00:37:57	181
2025-05-04	998	249	view	2025-05-04 20:52:05	521
2025-11-05	1004	161	logout	2025-11-05 04:44:29	298
2026-02-22	1001	37	login	2026-02-22 05:20:32	410
2025-10-21	1005	459	click	2025-10-21 21:53:41	361
2026-02-02	1007	547	login	2026-02-02 11:00:40	533
2024-07-04	1014	363	purchase	2024-07-04 00:19:16	375
2026-04-16	1010	473	purchase	2026-04-16 22:52:24	270
2025-12-10	1018	439	click	2025-12-10 14:32:59	481
2025-05-29	1012	-1	purchase	2025-05-29 22:06:57	575
2024-12-22	1020	102	logout	2024-12-22 10:42:01	-1
2025-08-27	1016	516	login	2025-08-27 17:21:21	151
2024-07-06	1021	165	view	2024-07-06 09:05:15	561
2026-01-22	1026	682	logout	2026-01-22 01:23:38	582
2025-11-13	1025	605	logout	2025-11-13 11:57:24	38
2025-11-07	1028	490	login	2025-11-07 10:15:55	220
2025-11-29	1034	424	click	2025-11-29 12:55:26	509
2025-04-07	1030	688	view	2025-04-07 15:12:50	299
2025-10-02	1037	648	view	2025-10-02 02:19:27	256
2024-06-07	1032	19	purchase	2024-06-07 18:34:28	582
2025-05-09	1043	-1	view	2025-05-09 02:29:46	223
2026-05-21	1033	580	login	2026-05-21 17:52:17	278
2025-10-30	1052	113	view	2025-10-30 19:30:37	390
2025-02-19	1038	39	purchase	2025-02-19 19:51:34	392
2025-09-26	1055	7	view	2025-09-26 05:52:01	95
2024-09-14	1039	480	view	2024-09-14 06:25:52	81
2026-05-19	1056	514	view	2026-05-19 12:56:32	595
2024-09-12	1040	676	logout	2024-09-12 08:29:23	269
2025-11-20	1058	674	click	2025-11-20 08:42:43	498
2024-06-13	1041	105	click	2024-06-13 04:00:40	520
2024-12-25	1060	226	purchase	2024-12-25 02:11:03	72
2024-10-09	1053	696	logout	2024-10-09 15:20:51	270
2024-09-25	1061	529	logout	2024-09-25 19:12:08	320
2025-08-11	1054	125	click	2025-08-11 20:43:06	419
2024-12-12	1069	279	click	2024-12-12 23:22:58	157
2025-12-23	1059	420	click	2025-12-23 06:49:50	47
2024-08-28	1072	272	logout	2024-08-28 09:34:54	538
2025-07-12	1062	10	purchase	2025-07-12 15:59:15	238
2025-11-01	1075	646	purchase	2025-11-01 18:35:41	395
2024-12-16	1070	469	login	2024-12-16 12:14:16	56
2024-10-19	1076	18	login	2024-10-19 22:11:28	462
2025-08-13	1086	26	login	2025-08-13 06:52:37	5
2024-07-28	1078	47	login	2024-07-28 18:47:30	38
2024-08-10	1087	74	click	2024-08-10 14:56:48	321
2025-06-30	1085	-1	click	2025-06-30 18:48:01	110
2025-10-31	1088	588	logout	2025-10-31 01:03:15	207
2024-12-20	1090	453	login	2024-12-20 06:32:19	38
2025-09-06	1093	434	click	2025-09-06 13:12:52	532
2026-03-01	1091	285	click	2026-03-01 07:47:42	275
2024-07-03	1096	492	view	2024-07-03 16:48:09	240
2025-12-11	1092	294	purchase	2025-12-11 20:22:14	-1
2024-10-02	1097	369	view	2024-10-02 22:02:22	57
2026-02-24	1094	311	login	2026-02-24 20:47:07	351
2024-05-24	1099	642	purchase	2024-05-24 14:49:26	396
2026-03-20	1095	384	click	2026-03-20 16:20:28	112
2024-05-25	1103	-1	click	2024-05-25 05:56:35	574
2024-11-07	1100	-1	logout	2024-11-07 20:05:38	468
2025-01-13	1104	358	login	2025-01-13 08:07:35	250
2024-09-07	1106	567	view	2024-09-07 09:06:54	81
2025-10-31	1105	637	login	2025-10-31 02:58:01	398
2025-11-02	1112	571	purchase	2025-11-02 21:39:54	403
2025-09-12	1111	398	view	2025-09-12 04:34:45	-1
2025-08-30	1113	310	logout	2025-08-30 05:42:40	-1
2024-08-12	1124	642	click	2024-08-12 02:19:52	237
2025-06-13	1114	-1	purchase	2025-06-13 14:53:08	-1
2025-12-03	1130	644	login	2025-12-03 22:48:51	372
\N	1115	662	login	\N	237
2025-08-12	1134	295	login	2025-08-12 01:09:22	-1
2024-09-29	1116	614	purchase	2024-09-29 22:26:13	487
2025-08-24	1140	683	logout	2025-08-24 07:18:33	184
2025-11-16	1121	114	view	2025-11-16 21:29:54	335
2025-01-17	1144	582	click	2025-01-17 06:15:35	321
2025-12-19	1122	435	view	2025-12-19 01:30:45	471
2025-06-11	1146	309	purchase	2025-06-11 06:30:29	255
2026-04-04	1125	2	logout	2026-04-04 08:22:39	198
\N	1149	-1	logout	\N	576
2025-11-03	1126	544	login	2025-11-03 13:12:49	-1
2024-11-22	1162	261	purchase	2024-11-22 01:21:45	76
2026-03-10	1128	131	click	2026-03-10 04:48:53	271
2025-12-25	1175	7	login	2025-12-25 09:58:03	564
2026-01-14	1132	74	logout	2026-01-14 09:26:06	144
2024-07-15	1176	303	login	2024-07-15 03:41:39	72
2026-04-19	1136	195	view	2026-04-19 04:02:57	447
2025-01-28	1180	19	view	2025-01-28 12:48:00	118
2024-09-30	1137	623	logout	2024-09-30 23:18:24	-1
2024-11-06	1186	656	login	2024-11-06 14:58:53	210
2026-03-12	1142	466	click	2026-03-12 19:28:22	-1
2026-04-13	1187	589	login	2026-04-13 17:02:32	145
2024-08-11	1143	247	purchase	2024-08-11 16:56:41	-1
\N	1193	401	login	\N	560
2024-07-27	1145	190	login	2024-07-27 10:50:46	265
2024-08-09	1201	164	click	2024-08-09 21:21:43	566
2024-07-27	1148	119	click	2024-07-27 11:08:51	437
2026-03-14	1203	664	purchase	2026-03-14 11:11:09	278
2025-02-21	1150	512	purchase	2025-02-21 09:52:30	357
2025-08-27	1204	59	purchase	2025-08-27 21:24:37	415
2026-05-14	1153	54	purchase	2026-05-14 17:53:42	156
2025-05-11	1205	179	click	2025-05-11 08:45:27	48
2025-11-12	1155	480	login	2025-11-12 22:48:23	407
2024-10-22	1207	328	login	2024-10-22 12:43:30	475
2026-05-11	1157	521	logout	2026-05-11 15:19:52	180
2025-10-05	1212	483	logout	2025-10-05 14:14:43	317
2024-07-26	1159	480	login	2024-07-26 02:55:36	585
2024-10-07	1216	329	logout	2024-10-07 18:32:20	91
2025-12-11	1160	201	purchase	2025-12-11 02:29:35	593
2024-10-31	1218	-1	purchase	2024-10-31 11:40:57	479
2025-09-29	1163	66	click	2025-09-29 14:53:19	467
2025-02-11	1219	422	login	2025-02-11 19:56:54	333
2024-08-22	1166	106	logout	2024-08-22 21:59:46	165
2024-10-23	1224	-1	logout	2024-10-23 13:41:11	470
2025-06-15	1168	408	view	2025-06-15 18:31:46	521
2024-08-18	1229	592	logout	2024-08-18 20:49:29	108
2026-04-21	1169	-1	click	2026-04-21 18:24:46	573
2024-08-17	1230	649	purchase	2024-08-17 04:00:24	50
2024-11-27	1171	-1	login	2024-11-27 12:28:42	535
2026-02-03	1238	474	purchase	2026-02-03 04:13:53	318
2024-10-30	1232	693	click	2024-10-30 04:08:35	575
2025-10-16	1258	323	login	2025-10-16 13:57:02	339
2024-11-29	1233	630	logout	2024-11-29 21:19:32	560
2026-04-13	1260	-1	click	2026-04-13 22:22:08	252
\N	1235	53	logout	\N	5
2025-07-21	1265	76	purchase	2025-07-21 12:30:20	370
2026-05-09	1240	175	click	2026-05-09 05:55:15	352
2025-11-09	1270	158	click	2025-11-09 19:03:41	555
2024-07-15	1241	292	purchase	2024-07-15 10:51:33	364
2025-07-19	1280	410	click	2025-07-19 22:50:42	435
2025-09-01	1242	582	login	2025-09-01 16:02:56	266
2026-04-21	1290	592	logout	2026-04-21 12:39:07	3
2024-08-26	1244	529	logout	2024-08-26 13:51:33	474
2025-03-02	1293	149	login	2025-03-02 17:01:56	287
2025-12-03	1245	621	logout	2025-12-03 06:33:56	373
2025-10-21	1298	82	click	2025-10-21 22:48:24	591
2024-11-12	1247	689	login	2024-11-12 07:06:23	566
2024-10-24	1301	503	logout	2024-10-24 21:05:05	20
2025-04-27	1255	194	logout	2025-04-27 16:06:18	134
2024-08-06	1302	663	purchase	2024-08-06 03:14:48	-1
2026-02-16	1262	338	logout	2026-02-16 03:40:23	366
2025-03-19	1324	492	view	2025-03-19 14:27:01	57
2025-08-02	1266	578	login	2025-08-02 09:04:15	114
2025-09-09	1327	612	click	2025-09-09 12:59:58	301
2026-02-09	1267	164	logout	2026-02-09 02:23:23	-1
2026-03-31	1328	423	view	2026-03-31 10:20:41	69
2024-09-21	1269	429	login	2024-09-21 23:26:42	106
2024-09-08	1329	-1	logout	2024-09-08 12:21:45	53
2024-11-29	1276	552	purchase	2024-11-29 14:10:51	222
2024-10-25	1330	693	view	2024-10-25 04:14:49	371
2024-09-05	1278	591	view	2024-09-05 17:04:36	421
2024-07-01	1335	374	logout	2024-07-01 23:23:37	472
2025-01-24	1282	455	purchase	2025-01-24 17:32:54	411
2025-10-02	1336	691	purchase	2025-10-02 05:55:41	-1
2025-03-24	1287	488	view	2025-03-24 07:59:28	76
2026-05-04	1338	172	login	2026-05-04 19:47:50	-1
2025-12-02	1288	565	click	2025-12-02 14:51:16	237
2026-05-08	1340	415	purchase	2026-05-08 21:04:52	217
2025-04-29	1300	375	purchase	2025-04-29 08:45:01	278
2025-04-20	1346	469	view	2025-04-20 03:06:17	534
2026-03-08	1303	264	purchase	2026-03-08 04:32:01	473
2026-05-07	1352	215	purchase	2026-05-07 05:07:19	325
2025-03-23	1304	223	login	2025-03-23 03:24:26	481
2025-06-13	1375	302	click	2025-06-13 15:35:20	119
2025-01-20	1305	507	logout	2025-01-20 02:52:13	453
2026-04-04	1379	341	view	2026-04-04 19:38:28	596
2026-05-12	1309	157	click	2026-05-12 18:46:10	63
2025-11-10	1383	-1	purchase	2025-11-10 21:39:50	72
2026-02-14	1310	614	click	2026-02-14 20:16:12	73
2025-01-12	1387	31	click	2025-01-12 21:38:38	36
2025-07-24	1312	-1	click	2025-07-24 11:57:40	77
2024-10-16	1391	651	purchase	2024-10-16 06:16:12	361
2025-10-24	1314	-1	logout	2025-10-24 15:40:38	207
2025-12-28	1397	340	login	2025-12-28 13:06:17	444
2025-02-01	1325	483	view	2025-02-01 10:57:12	231
2024-06-26	1402	629	logout	2024-06-26 18:17:47	-1
2025-07-04	1326	435	logout	2025-07-04 05:30:11	454
2024-12-19	1407	94	click	2024-12-19 16:02:58	164
2025-03-14	1333	236	logout	2025-03-14 23:09:47	84
2025-04-28	1411	191	logout	2025-04-28 11:01:06	388
2025-11-08	1334	13	click	2025-11-08 05:08:50	482
2025-05-21	1416	492	login	2025-05-21 06:34:40	133
2024-10-30	1339	265	click	2024-10-30 18:53:05	86
2025-04-28	1419	224	click	2025-04-28 02:00:58	226
2025-11-28	1344	459	view	2025-11-28 02:51:28	386
2025-08-19	1423	298	logout	2025-08-19 14:21:50	229
2026-01-27	1345	5	purchase	2026-01-27 22:23:18	91
2025-09-07	1426	71	logout	2025-09-07 01:51:47	293
2025-08-07	1348	282	logout	2025-08-07 05:27:55	60
2026-03-07	1427	410	login	2026-03-07 19:31:28	401
2025-07-13	1350	291	purchase	2025-07-13 13:14:11	272
2024-07-14	1431	639	click	2024-07-14 08:14:06	-1
2025-02-10	1351	-1	logout	2025-02-10 02:54:50	448
2025-06-08	1435	694	click	2025-06-08 04:18:55	33
2024-11-16	1354	93	view	2024-11-16 01:08:00	531
2025-08-18	1437	61	view	2025-08-18 04:56:24	251
2024-09-15	1356	421	logout	2024-09-15 08:43:06	330
2024-12-28	1440	254	logout	2024-12-28 15:06:15	329
2025-07-08	1358	591	logout	2025-07-08 12:31:07	54
2026-05-14	1451	527	purchase	2026-05-14 12:36:56	573
2025-03-25	1359	675	click	2025-03-25 03:46:52	545
2025-02-10	1452	230	click	2025-02-10 19:31:48	135
2025-11-22	1364	496	logout	2025-11-22 06:54:24	-1
2024-08-19	1464	240	view	2024-08-19 17:59:44	93
2026-03-08	1370	512	view	2026-03-08 16:28:28	353
2025-06-12	1465	181	view	2025-06-12 03:28:00	40
2025-04-09	1371	148	click	2025-04-09 09:06:38	439
\N	1469	158	login	\N	567
2024-11-21	1372	635	logout	2024-11-21 19:51:28	466
2025-05-22	1471	-1	purchase	2025-05-22 23:39:04	376
2025-01-14	1376	626	click	2025-01-14 15:04:27	596
2026-01-07	1478	36	logout	2026-01-07 13:08:42	52
2024-08-13	1399	170	logout	2024-08-13 06:55:56	181
2026-01-02	1479	570	logout	2026-01-02 14:34:53	593
2026-04-22	1400	347	click	2026-04-22 19:14:59	536
2025-07-27	1480	389	purchase	2025-07-27 16:37:34	162
2025-10-01	1403	539	click	2025-10-01 19:17:11	161
2024-11-17	1482	-1	click	2024-11-17 06:14:39	223
2025-04-05	1404	-1	purchase	2025-04-05 17:53:47	37
2024-12-16	1486	496	click	2024-12-16 06:30:01	577
2026-02-12	1406	691	logout	2026-02-12 03:35:58	472
2025-08-06	1495	201	logout	2025-08-06 22:10:48	96
2025-08-16	1408	18	login	2025-08-16 19:55:27	536
2025-10-23	1496	668	view	2025-10-23 22:34:28	451
2025-12-23	1413	460	purchase	2025-12-23 09:17:06	82
2026-05-14	1497	32	logout	2026-05-14 21:57:34	211
2025-08-25	1414	8	logout	2025-08-25 04:18:31	228
2024-10-11	1239	284	view	2024-10-11 23:40:38	596
2024-11-18	1417	464	view	2024-11-18 23:58:28	339
2024-07-26	1249	314	login	2024-07-26 08:45:14	216
2024-06-11	1418	219	purchase	2024-06-11 21:38:31	482
2026-02-11	1253	224	click	2026-02-11 13:00:25	203
2024-09-08	1421	459	view	2024-09-08 18:22:56	168
2025-01-28	1254	-1	purchase	2025-01-28 07:20:41	242
2025-12-04	1422	261	click	2025-12-04 07:54:09	346
2024-08-21	1264	-1	login	2024-08-21 06:06:16	258
2024-12-18	1424	593	login	2024-12-18 15:21:52	301
2024-12-09	1268	96	click	2024-12-09 10:21:31	15
2025-04-02	1425	107	login	2025-04-02 02:32:17	551
2026-04-22	1272	291	purchase	2026-04-22 03:47:36	5
2024-09-09	1432	339	login	2024-09-09 08:30:11	449
2025-01-22	1273	263	purchase	2025-01-22 16:30:14	349
2025-04-11	1434	694	purchase	2025-04-11 20:01:08	-1
2025-07-13	1279	-1	click	2025-07-13 00:43:04	251
2026-03-17	1441	562	view	2026-03-17 16:09:51	18
2026-01-07	1284	25	view	2026-01-07 06:09:12	111
2024-11-07	1442	120	click	2024-11-07 00:37:46	287
2024-08-28	1285	-1	click	2024-08-28 15:49:55	214
2025-06-23	1445	391	login	2025-06-23 02:37:17	377
2026-01-04	1289	603	view	2026-01-04 23:18:58	162
2025-02-22	1453	679	click	2025-02-22 20:57:23	64
2026-01-06	1297	155	logout	2026-01-06 05:01:58	27
2024-08-28	1466	371	click	2024-08-28 12:36:44	586
2026-01-04	1299	567	purchase	2026-01-04 00:09:57	430
2024-08-09	1474	90	click	2024-08-09 00:14:26	132
2024-12-11	1311	-1	login	2024-12-11 00:59:38	449
2026-02-23	1484	97	click	2026-02-23 20:10:07	442
2024-09-19	1316	592	view	2024-09-19 19:50:46	597
2025-06-22	1485	642	view	2025-06-22 04:50:59	71
2025-11-15	1318	137	purchase	2025-11-15 00:53:01	383
2025-08-28	1489	-1	click	2025-08-28 07:09:09	270
2024-09-14	1320	87	view	2024-09-14 04:02:37	570
2024-08-07	1492	60	login	2024-08-07 01:29:46	158
2025-06-28	1321	698	view	2025-06-28 22:09:36	3
2025-06-05	1494	387	click	2025-06-05 08:56:10	27
2025-09-01	1322	-1	view	2025-09-01 09:08:16	410
\N	1498	62	login	\N	354
2024-08-30	1323	498	view	2024-08-30 12:16:46	41
2025-06-04	1173	-1	purchase	2025-06-04 18:26:22	298
2026-04-01	1331	29	view	2026-04-01 23:45:39	153
2024-10-11	1177	448	click	2024-10-11 06:34:05	441
2026-04-12	1337	433	login	2026-04-12 08:34:35	261
2024-05-30	1191	10	view	2024-05-30 17:35:06	286
2026-02-24	1341	452	purchase	2026-02-24 17:17:10	193
2024-12-29	1192	259	view	2024-12-29 15:03:28	447
2024-11-17	1343	434	login	2024-11-17 04:25:17	-1
2024-11-14	1194	295	purchase	2024-11-14 06:58:28	103
2025-04-20	1355	381	view	2025-04-20 01:53:00	257
2026-02-17	1196	147	login	2026-02-17 22:45:23	175
2025-04-17	1361	673	purchase	2025-04-17 06:15:58	-1
2026-03-17	1202	50	logout	2026-03-17 15:08:06	467
2024-09-21	1365	145	purchase	2024-09-21 04:14:51	262
2025-09-15	1209	42	login	2025-09-15 11:10:06	-1
2025-07-02	1366	624	purchase	2025-07-02 20:52:53	396
2024-05-28	1210	20	view	2024-05-28 10:03:03	368
2024-06-13	1368	107	logout	2024-06-13 17:21:59	486
2025-11-15	1213	135	click	2025-11-15 18:31:46	337
2026-04-03	1369	185	login	2026-04-03 02:09:36	188
2025-05-05	1214	-1	purchase	2025-05-05 04:14:23	186
2026-05-07	1373	604	logout	2026-05-07 11:56:35	482
2025-05-07	1217	110	login	2025-05-07 13:49:58	562
2024-08-28	1374	339	purchase	2024-08-28 10:30:43	463
2025-11-01	1223	207	logout	2025-11-01 04:24:16	385
2025-05-15	1380	214	click	2025-05-15 03:31:08	28
2025-09-04	1227	8	login	2025-09-04 05:40:29	109
2025-05-01	1381	114	purchase	2025-05-01 13:37:02	541
2025-05-17	1228	120	logout	2025-05-17 09:38:01	491
2025-06-18	1384	369	login	2025-06-18 20:01:51	136
2025-02-08	1231	226	login	2025-02-08 12:56:15	532
2025-12-29	1392	429	view	2025-12-29 08:43:46	108
2025-06-26	1234	265	logout	2025-06-26 17:37:31	249
2024-11-02	1393	134	click	2024-11-02 04:30:26	15
2024-09-20	1236	482	logout	2024-09-20 05:19:07	597
2026-01-24	1396	80	purchase	2026-01-24 07:32:35	523
2025-10-28	1246	519	login	2025-10-28 09:13:26	229
\N	1412	30	click	\N	495
2025-05-11	1248	74	logout	2025-05-11 09:57:30	224
2024-05-26	1415	273	purchase	2024-05-26 09:59:12	378
2024-09-24	1250	59	view	2024-09-24 13:16:06	478
2025-07-25	1433	-1	login	2025-07-25 00:28:23	245
2024-11-02	1251	477	view	2024-11-02 16:30:09	198
2025-09-01	1438	590	view	2025-09-01 15:39:38	517
2025-08-04	1252	324	view	2025-08-04 19:48:51	548
2026-01-06	1444	503	login	2026-01-06 22:14:34	327
2026-03-15	1256	568	view	2026-03-15 11:27:57	230
2025-09-11	1447	362	purchase	2025-09-11 19:06:44	-1
2025-11-03	1257	90	click	2025-11-03 16:40:29	403
2026-04-04	1449	332	click	2026-04-04 07:02:15	397
2025-01-11	1259	122	login	2025-01-11 16:49:00	-1
2025-11-25	1450	138	view	2025-11-25 00:22:01	308
2025-01-20	1261	275	view	2025-01-20 18:55:19	-1
2026-04-19	1455	168	view	2026-04-19 18:15:59	321
2025-05-31	1263	322	login	2025-05-31 16:02:16	43
2026-01-05	1456	99	logout	2026-01-05 17:15:43	190
2026-02-08	1271	665	view	2026-02-08 21:24:32	304
2025-07-16	1462	177	view	2025-07-16 03:20:08	292
2025-04-07	1274	595	click	2025-04-07 03:16:40	218
2024-05-25	1463	-1	click	2024-05-25 22:59:41	447
2025-01-06	1275	-1	view	2025-01-06 12:54:05	499
2025-01-25	1467	325	view	2025-01-25 17:47:50	290
2025-04-15	1277	238	login	2025-04-15 08:56:51	197
2026-02-23	1468	490	purchase	2026-02-23 16:51:04	243
2026-04-26	1281	-1	click	2026-04-26 04:10:09	578
2025-01-19	1470	609	view	2025-01-19 08:05:25	310
2026-04-06	1283	107	logout	2026-04-06 07:53:04	474
2025-09-11	1472	485	click	2025-09-11 08:18:13	-1
2025-10-17	1286	259	view	2025-10-17 10:40:22	-1
2025-06-01	1473	443	login	2025-06-01 11:25:07	426
2025-07-10	1291	346	login	2025-07-10 23:32:25	178
2025-08-04	1477	41	logout	2025-08-04 19:21:36	574
2024-06-03	1292	428	view	2024-06-03 03:05:32	129
2026-05-20	1481	193	logout	2026-05-20 08:00:46	590
2025-12-31	1294	187	view	2025-12-31 19:54:27	-1
2025-10-15	1487	95	logout	2025-10-15 13:39:04	491
2024-12-27	1295	574	logout	2024-12-27 22:02:32	456
2026-03-20	1488	-1	view	2026-03-20 16:33:44	211
2024-11-26	1296	171	click	2024-11-26 14:13:25	199
2026-01-14	1491	263	login	2026-01-14 16:08:42	354
2024-10-13	1306	4	logout	2024-10-13 09:27:01	326
2024-06-02	1493	367	login	2024-06-02 13:58:00	78
2024-11-17	1307	491	view	2024-11-17 21:51:44	89
2025-06-18	1499	609	login	2025-06-18 21:07:32	407
2025-12-17	1308	146	logout	2025-12-17 14:21:10	465
2024-12-19	1500	407	click	2024-12-19 22:47:33	141
2024-06-05	1313	661	login	2024-06-05 19:36:03	397
2025-08-08	1315	77	login	2025-08-08 14:26:28	484
2024-08-12	1317	537	view	2024-08-12 06:52:48	269
2024-11-10	1319	689	view	2024-11-10 14:48:57	19
2026-04-15	1332	357	logout	2026-04-15 15:11:13	-1
2024-09-03	1342	245	logout	2024-09-03 23:32:34	455
2025-08-24	1347	306	login	2025-08-24 05:31:24	81
2025-12-31	1349	217	purchase	2025-12-31 10:51:51	176
2025-11-28	1353	149	logout	2025-11-28 08:28:09	120
2025-10-15	1357	611	click	2025-10-15 02:37:28	366
2024-07-09	1360	9	view	2024-07-09 23:06:08	152
\N	1362	508	click	\N	340
2025-12-17	1363	304	click	2025-12-17 15:40:57	530
2025-01-22	1367	6	logout	2025-01-22 00:01:39	467
2024-12-27	1377	-1	login	2024-12-27 10:32:12	4
2026-05-21	1378	-1	logout	2026-05-21 20:36:54	465
2025-07-03	1382	294	login	2025-07-03 04:41:36	433
2024-12-18	1385	-1	view	2024-12-18 21:38:18	477
2026-01-05	1386	29	purchase	2026-01-05 15:09:00	531
2026-02-17	1388	135	login	2026-02-17 07:03:16	307
2025-01-22	1389	248	click	2025-01-22 00:54:11	181
2025-09-24	1390	667	login	2025-09-24 10:58:11	424
2026-04-09	1394	504	click	2026-04-09 17:38:18	500
2024-10-05	1395	553	view	2024-10-05 13:26:55	427
2025-10-09	1398	334	purchase	2025-10-09 16:58:03	30
2025-03-16	1401	-1	login	2025-03-16 02:57:25	324
2025-06-04	1405	337	click	2025-06-04 23:30:02	226
2025-10-16	1409	447	click	2025-10-16 20:20:04	493
2026-04-11	1410	559	login	2026-04-11 16:40:43	347
2024-09-03	1420	652	click	2024-09-03 09:22:00	353
2025-08-23	1428	352	view	2025-08-23 05:27:36	286
2024-10-12	1429	528	purchase	2024-10-12 06:50:20	442
2025-10-16	1430	512	click	2025-10-16 20:33:50	183
2025-09-25	1436	500	logout	2025-09-25 02:55:56	212
2025-01-04	1439	511	login	2025-01-04 19:07:49	230
\N	1443	203	login	\N	461
2024-10-26	1446	474	logout	2024-10-26 23:40:56	303
\N	1448	584	purchase	\N	351
2024-11-18	1454	465	logout	2024-11-18 01:25:04	513
2026-01-08	1457	95	purchase	2026-01-08 01:14:23	303
2026-04-07	1458	328	click	2026-04-07 07:33:18	139
2026-04-13	1459	485	logout	2026-04-13 07:27:54	475
2025-02-27	1460	-1	logout	2025-02-27 10:04:00	59
2026-02-22	1461	194	purchase	2026-02-22 11:41:14	248
\N	1475	119	click	\N	170
2026-05-04	1476	635	click	2026-05-04 03:30:22	230
2024-08-11	1483	197	logout	2024-08-11 18:35:07	212
2025-10-16	1490	607	view	2025-10-16 05:03:08	79
\.


--
-- TOC entry 2535 (class 0 OID 49487)
-- Dependencies: 276
-- Data for Name: fact_orders; Type: TABLE DATA; Schema: fact; Owner: gpadmin
--

COPY fact.fact_orders (date_id, order_id, customer_id, product_id, quantity, unit_price, currency, order_timestamp, status) FROM stdin;
2026-02-18	2	467	117	5	218.669999999999987	EUR	2026-02-18 02:28:23	completed
2024-12-12	6	103	217	1	337.180000000000007	EUR	2024-12-12 04:11:41	completed
2025-01-14	3	470	391	5	89.7000000000000028	EUR	2025-01-14 11:22:12	cancelled
2024-12-17	7	466	476	4	475.769999999999982	EUR	2024-12-17 00:16:14	cancelled
2025-05-30	4	676	90	3	354.029999999999973	USD	2025-05-30 03:09:57	completed
2024-12-30	8	661	520	1	470.410000000000025	USD	2024-12-30 16:57:31	cancelled
2025-04-05	9	275	425	4	339.920000000000016	USD	2025-04-05 12:29:27	completed
2026-02-03	16	586	-1	2	491.870000000000005	RUB	2026-02-03 08:08:20	cancelled
2026-01-21	10	0	326	5	411.819999999999993	RUB	2026-01-21 03:56:04	cancelled
2025-01-05	18	676	594	2	317.439999999999998	RUB	2025-01-05 06:00:33	completed
2025-03-06	13	178	130	2	224.330000000000013	USD	2025-03-06 08:09:27	processing
2025-08-02	22	462	581	1	452.779999999999973	RUB	2025-08-02 14:16:29	processing
2025-02-10	19	114	185	1	79.5	EUR	2025-02-10 05:37:05	completed
2025-04-27	24	0	-1	3	464.029999999999973	USD	2025-04-27 12:35:46	completed
2024-07-05	21	76	322	2	346.79000000000002	EUR	2024-07-05 00:20:51	processing
2025-11-04	27	357	447	4	375.149999999999977	EUR	2025-11-04 11:16:05	processing
2024-08-01	33	331	381	2	45.5900000000000034	RUB	2024-08-01 00:19:44	cancelled
2025-01-28	28	410	288	2	346.660000000000025	RUB	2025-01-28 13:48:55	cancelled
2025-07-11	34	149	337	3	347.259999999999991	RUB	2025-07-11 11:43:09	completed
2024-11-19	29	106	500	3	91.1700000000000017	USD	2024-11-19 22:07:32	cancelled
2025-01-25	37	662	202	3	408.560000000000002	USD	2025-01-25 13:47:44	completed
2025-11-07	32	601	118	5	182.599999999999994	USD	2025-11-07 21:59:15	completed
2024-09-01	39	335	590	1	149.669999999999987	RUB	2024-09-01 13:44:00	completed
2024-09-09	45	175	6	3	409.910000000000025	RUB	2024-09-09 14:32:53	processing
2025-11-14	41	346	309	1	416.629999999999995	EUR	2025-11-14 02:44:17	cancelled
2024-09-29	51	676	62	1	46.8200000000000003	EUR	2024-09-29 03:00:53	completed
2025-11-02	42	325	-1	5	389.560000000000002	EUR	2025-11-02 16:21:05	completed
2025-04-25	53	605	465	3	382.639999999999986	EUR	2025-04-25 16:11:52	processing
2026-01-27	43	403	383	4	425.850000000000023	USD	2026-01-27 19:22:46	processing
2026-04-11	54	158	395	2	117.200000000000003	EUR	2026-04-11 01:15:11	cancelled
2024-11-08	55	636	169	2	43.6300000000000026	EUR	2024-11-08 17:22:54	processing
2025-11-30	58	272	407	3	221.419999999999987	USD	2025-11-30 09:39:46	processing
2026-01-12	60	433	-1	2	301.079999999999984	RUB	2026-01-12 10:41:02	cancelled
2025-02-09	59	442	392	3	191.189999999999998	USD	2025-02-09 21:17:00	processing
2024-08-24	65	190	245	4	372.149999999999977	RUB	2024-08-24 01:41:20	completed
2024-09-21	62	37	-1	5	59.509999999999998	USD	2024-09-21 05:17:57	processing
2025-12-07	70	103	559	4	250.419999999999987	EUR	2025-12-07 23:44:17	cancelled
2026-03-17	66	323	14	3	450.939999999999998	USD	2026-03-17 03:15:31	processing
2024-09-15	75	387	540	5	450.620000000000005	EUR	2024-09-15 17:59:26	completed
\N	67	486	10	3	441.819999999999993	USD	\N	processing
2025-10-27	80	499	290	1	232.389999999999986	USD	2025-10-27 08:09:46	processing
2024-11-17	73	0	366	2	333.089999999999975	USD	2024-11-17 05:26:37	cancelled
2025-12-06	82	142	159	5	336.009999999999991	RUB	2025-12-06 12:39:00	completed
2024-06-07	77	0	444	3	418.740000000000009	USD	2024-06-07 11:41:29	cancelled
2026-01-09	90	630	-1	5	260.980000000000018	USD	2026-01-09 02:30:08	processing
2024-12-13	81	127	52	4	182.610000000000014	USD	2024-12-13 14:28:40	cancelled
2025-06-19	92	531	110	1	142.389999999999986	RUB	2025-06-19 13:11:29	cancelled
2024-05-30	84	33	268	4	217.060000000000002	USD	2024-05-30 23:47:50	cancelled
2025-03-03	93	609	125	4	348.389999999999986	USD	2025-03-03 22:04:35	processing
2025-01-14	94	599	148	1	353.769999999999982	RUB	2025-01-14 04:32:14	processing
2025-05-22	97	254	125	5	227.469999999999999	USD	2025-05-22 08:39:11	cancelled
2025-05-09	100	146	560	2	260.639999999999986	RUB	2025-05-09 09:51:28	completed
2024-11-29	99	698	23	1	221.849999999999994	RUB	2024-11-29 18:47:11	completed
2026-05-10	108	484	266	5	389.949999999999989	RUB	2026-05-10 13:46:51	completed
2024-12-06	101	488	377	1	479.949999999999989	EUR	2024-12-06 16:09:32	processing
2026-01-22	109	-1	70	3	296.399999999999977	EUR	2026-01-22 01:29:38	completed
2026-02-25	102	282	152	1	237.340000000000003	EUR	2026-02-25 00:07:38	completed
2025-02-20	110	31	488	1	335.980000000000018	EUR	2025-02-20 16:59:27	cancelled
2025-03-13	103	291	-1	1	294.45999999999998	USD	2025-03-13 00:28:18	cancelled
2025-11-10	115	293	89	4	408.779999999999973	USD	2025-11-10 13:13:15	processing
2024-07-24	104	44	470	2	239.27000000000001	RUB	2024-07-24 16:52:25	cancelled
2026-04-20	117	418	541	3	100.799999999999997	RUB	2026-04-20 23:35:56	cancelled
2025-05-26	112	66	453	1	424.930000000000007	USD	2025-05-26 09:03:41	cancelled
2024-10-10	129	548	397	1	280.720000000000027	USD	2024-10-10 05:33:46	cancelled
\N	113	622	461	2	167.370000000000005	RUB	\N	cancelled
2025-03-15	131	377	-1	1	126.700000000000003	USD	2025-03-15 15:56:30	completed
2025-01-29	118	195	-1	4	255.419999999999987	EUR	2025-01-29 11:54:39	processing
2024-06-30	133	79	-1	3	31.4200000000000017	EUR	2024-06-30 02:15:14	processing
2024-11-10	120	530	339	2	35.2199999999999989	RUB	2024-11-10 02:17:03	completed
\N	140	465	394	1	142.449999999999989	RUB	\N	cancelled
2026-01-05	126	73	491	5	465.389999999999986	RUB	2026-01-05 16:08:09	completed
2025-12-12	151	60	452	5	280.20999999999998	USD	2025-12-12 07:34:25	completed
2025-06-11	127	278	359	4	258.730000000000018	RUB	2025-06-11 06:46:36	cancelled
2026-03-04	156	112	334	5	47.9500000000000028	USD	2026-03-04 14:51:16	processing
2024-07-28	130	-1	121	5	77.5100000000000051	EUR	2024-07-28 03:23:12	processing
2024-07-14	163	53	200	5	226.099999999999994	EUR	2024-07-14 11:16:09	processing
2025-03-12	139	126	451	2	27.5799999999999983	USD	2025-03-12 13:19:35	processing
2024-11-20	164	301	119	3	123.140000000000001	EUR	2024-11-20 00:21:21	processing
2024-11-22	141	87	394	4	252.72999999999999	EUR	2024-11-22 10:03:57	cancelled
2024-11-15	165	247	574	4	187.319999999999993	EUR	2024-11-15 19:59:58	processing
2024-06-21	142	46	313	4	270.920000000000016	RUB	2024-06-21 18:11:12	completed
2024-09-30	176	379	-1	3	224.909999999999997	RUB	2024-09-30 18:11:24	cancelled
2026-01-20	143	555	269	5	379.689999999999998	EUR	2026-01-20 17:47:18	processing
2025-10-30	177	100	594	1	286.420000000000016	RUB	2025-10-30 11:46:58	processing
2026-02-01	145	567	475	3	430.670000000000016	RUB	2026-02-01 16:38:24	cancelled
2025-09-29	180	295	-1	2	151.349999999999994	EUR	2025-09-29 23:52:34	completed
2025-07-30	146	587	479	3	89.6500000000000057	EUR	2025-07-30 06:35:05	processing
2026-01-15	183	27	534	5	218.990000000000009	EUR	2026-01-15 23:42:13	completed
\N	147	244	556	3	51.9099999999999966	USD	\N	cancelled
2025-11-29	185	89	228	1	484.54000000000002	USD	2025-11-29 12:19:55	processing
2024-08-31	153	633	451	1	100.290000000000006	RUB	2024-08-31 00:40:39	processing
2026-02-22	192	0	241	5	196.340000000000003	RUB	2026-02-22 20:57:33	processing
2025-04-08	182	613	7	5	273.579999999999984	USD	2025-04-08 09:35:44	cancelled
2025-10-22	193	358	300	2	440.170000000000016	USD	2025-10-22 22:54:11	processing
2024-09-23	187	76	534	1	222.360000000000014	RUB	2024-09-23 19:47:51	cancelled
2026-03-15	197	132	241	4	304.519999999999982	RUB	2026-03-15 09:35:27	completed
2024-08-15	190	497	91	3	74.5799999999999983	RUB	2024-08-15 06:28:06	processing
2025-06-17	198	298	268	4	39.7899999999999991	EUR	2025-06-17 01:44:38	processing
2025-01-18	195	225	334	3	215.599999999999994	EUR	2025-01-18 13:40:18	completed
2024-08-17	203	567	161	2	187.430000000000007	USD	2024-08-17 22:28:14	processing
2026-04-16	207	0	277	4	331.089999999999975	USD	2026-04-16 19:33:10	completed
2024-06-21	205	567	105	1	424.29000000000002	RUB	2024-06-21 23:12:00	processing
2025-09-26	209	156	320	4	105.200000000000003	RUB	2025-09-26 22:48:33	cancelled
2026-03-20	211	591	575	1	118.900000000000006	EUR	2026-03-20 06:39:06	cancelled
2025-02-03	215	86	145	4	300.769999999999982	USD	2025-02-03 05:15:18	cancelled
2025-03-24	218	417	559	2	379.970000000000027	EUR	2025-03-24 01:55:25	cancelled
2024-08-26	219	321	569	4	357.350000000000023	RUB	2024-08-26 01:23:56	processing
2024-09-03	224	666	381	2	403.379999999999995	RUB	2024-09-03 01:46:21	processing
2026-04-17	223	446	381	3	266.019999999999982	RUB	2026-04-17 17:35:09	processing
2024-12-05	229	15	377	4	296.389999999999986	EUR	2024-12-05 00:47:34	processing
2025-07-06	225	620	139	3	464.269999999999982	RUB	2025-07-06 22:40:26	completed
2024-06-14	230	413	106	2	47.9600000000000009	USD	2024-06-14 23:45:54	processing
2025-01-25	236	403	325	4	183.949999999999989	RUB	2025-01-25 19:01:01	processing
\N	233	485	-1	2	494.649999999999977	USD	\N	completed
2024-09-18	237	81	147	2	473.29000000000002	EUR	2024-09-18 04:11:01	cancelled
2024-10-09	241	453	378	5	162.090000000000003	USD	2024-10-09 20:20:05	cancelled
2026-03-19	239	357	435	4	387.660000000000025	EUR	2026-03-19 16:06:36	completed
2026-04-27	244	483	559	4	95.1500000000000057	RUB	2026-04-27 22:34:06	completed
2025-05-18	247	558	325	5	371.350000000000023	EUR	2025-05-18 00:17:52	processing
2025-07-16	246	430	322	4	322.360000000000014	USD	2025-07-16 07:42:17	completed
2025-08-15	252	475	326	2	367.480000000000018	USD	2025-08-15 11:36:09	processing
2024-11-03	251	281	89	4	288.399999999999977	RUB	2024-11-03 05:18:11	processing
2024-12-28	256	193	271	3	137.080000000000013	EUR	2024-12-28 05:27:39	completed
2025-12-09	260	526	530	4	137.810000000000002	USD	2025-12-09 18:12:37	processing
2025-01-13	257	502	175	5	230.340000000000003	RUB	2025-01-13 09:24:38	completed
2024-08-22	261	647	387	5	168.27000000000001	RUB	2024-08-22 14:33:17	processing
2025-03-18	258	600	356	2	496.939999999999998	EUR	2025-03-18 04:08:39	processing
2024-06-09	267	437	525	4	300.610000000000014	USD	2024-06-09 12:27:40	completed
2024-07-28	262	603	163	1	318.439999999999998	USD	2024-07-28 06:00:50	cancelled
\N	270	406	309	2	108.200000000000003	USD	\N	cancelled
2025-04-23	263	487	314	1	101.680000000000007	EUR	2025-04-23 14:36:41	completed
2026-05-02	275	-1	-1	5	45.1099999999999994	EUR	2026-05-02 22:23:00	completed
2025-11-08	266	495	111	2	383.949999999999989	RUB	2025-11-08 18:40:38	cancelled
2025-12-30	282	0	311	4	217	USD	2025-12-30 22:03:00	cancelled
2025-03-16	272	569	483	4	88.0699999999999932	USD	2025-03-16 22:07:47	processing
2024-08-07	285	8	-1	5	136.340000000000003	RUB	2024-08-07 04:58:00	processing
2024-10-12	274	397	290	2	205.939999999999998	EUR	2024-10-12 11:40:32	processing
2026-04-19	286	466	472	1	69.5600000000000023	EUR	2026-04-19 03:51:00	cancelled
2025-10-17	279	292	184	4	27.0700000000000003	EUR	2025-10-17 03:31:24	completed
2025-09-14	288	556	305	4	18.5799999999999983	EUR	2025-09-14 03:02:19	processing
2025-11-27	287	52	304	3	218.590000000000003	RUB	2025-11-27 14:56:49	completed
2025-03-14	291	470	79	5	288.839999999999975	USD	2025-03-14 05:28:31	cancelled
2025-06-21	290	87	282	2	320.129999999999995	EUR	2025-06-21 03:29:25	cancelled
2026-01-24	296	485	284	3	375.970000000000027	USD	2026-01-24 12:05:25	processing
2024-11-09	294	669	585	4	482.930000000000007	USD	2024-11-09 04:34:29	cancelled
2026-03-29	299	326	295	3	118.319999999999993	RUB	2026-03-29 17:26:48	processing
2025-08-12	295	311	384	2	350.189999999999998	USD	2025-08-12 21:05:17	processing
2024-11-21	315	616	166	5	260.550000000000011	USD	2024-11-21 09:02:00	cancelled
2024-08-20	298	0	-1	2	144.639999999999986	EUR	2024-08-20 10:16:22	processing
2024-11-10	319	251	417	1	376.819999999999993	RUB	2024-11-10 08:53:48	processing
\N	301	488	156	3	166.620000000000005	EUR	\N	cancelled
2024-09-21	320	482	551	4	479.20999999999998	RUB	2024-09-21 11:13:16	completed
2025-04-05	304	299	599	4	24.4899999999999984	RUB	2025-04-05 19:43:06	completed
2026-04-26	322	62	524	1	188.050000000000011	RUB	2026-04-26 06:28:07	processing
2025-06-26	308	419	-1	5	146.650000000000006	EUR	2025-06-26 06:26:09	completed
2024-07-08	325	271	504	1	234.539999999999992	RUB	2024-07-08 11:34:56	completed
2024-09-30	309	681	402	3	256.129999999999995	RUB	2024-09-30 11:56:24	completed
2025-05-15	326	267	265	3	395.810000000000002	RUB	2025-05-15 02:31:04	processing
2024-11-23	310	414	410	4	86.9099999999999966	USD	2024-11-23 04:42:05	cancelled
2024-12-31	329	451	394	2	81.7999999999999972	EUR	2024-12-31 05:39:33	cancelled
2024-07-10	311	4	101	4	331.529999999999973	RUB	2024-07-10 01:16:50	cancelled
2026-01-29	333	174	67	4	449.600000000000023	USD	2026-01-29 06:18:42	cancelled
2024-09-06	312	595	-1	4	102.549999999999997	USD	2024-09-06 02:44:52	completed
2024-11-05	334	231	123	3	308.230000000000018	RUB	2024-11-05 07:28:43	processing
2026-04-21	331	373	175	5	208.860000000000014	RUB	2026-04-21 10:54:11	cancelled
2024-05-31	335	202	234	1	421.589999999999975	RUB	2024-05-31 07:57:22	processing
2024-09-05	338	536	251	2	347.949999999999989	RUB	2024-09-05 02:38:27	completed
2025-05-18	345	278	307	5	246.810000000000002	EUR	2025-05-18 07:28:32	cancelled
2025-03-19	341	250	327	4	58.1499999999999986	USD	2025-03-19 17:25:34	processing
2024-11-08	350	484	159	5	113.040000000000006	RUB	2024-11-08 04:03:27	cancelled
2025-05-02	344	200	417	4	496.199999999999989	EUR	2025-05-02 03:15:54	processing
2025-04-23	355	419	208	4	385.850000000000023	USD	2025-04-23 00:58:45	completed
2025-09-11	346	545	451	5	256.5	RUB	2025-09-11 12:25:21	completed
2024-07-11	356	678	392	3	21.6000000000000014	EUR	2024-07-11 21:38:37	cancelled
2025-11-29	348	443	552	4	177.789999999999992	RUB	2025-11-29 11:19:54	completed
2025-03-11	358	77	482	4	471.329999999999984	RUB	2025-03-11 00:29:53	completed
2025-12-08	352	529	235	4	392.079999999999984	EUR	2025-12-08 03:35:40	cancelled
2024-09-21	362	155	336	5	53.1199999999999974	USD	2024-09-21 10:18:22	processing
2024-12-30	354	323	414	4	383.720000000000027	USD	2024-12-30 14:58:30	completed
\N	366	619	406	1	324.699999999999989	EUR	\N	cancelled
2025-03-16	360	61	292	3	273.569999999999993	EUR	2025-03-16 11:17:52	completed
2024-05-25	371	477	187	2	328.720000000000027	USD	2024-05-25 09:49:13	processing
2025-12-22	361	484	424	3	488.819999999999993	RUB	2025-12-22 17:22:10	completed
2025-09-28	373	7	155	1	120.359999999999999	EUR	2025-09-28 09:39:54	cancelled
2025-11-18	363	560	23	5	410.480000000000018	RUB	2025-11-18 15:27:17	completed
2024-12-31	383	521	410	1	196.210000000000008	EUR	2024-12-31 03:18:39	completed
2025-06-07	364	70	457	3	479.029999999999973	EUR	2025-06-07 03:08:54	processing
2024-06-20	389	685	510	1	395.410000000000025	USD	2024-06-20 23:42:54	completed
2025-12-18	367	50	448	5	193	RUB	2025-12-18 18:39:04	completed
2025-07-29	390	314	27	3	314.740000000000009	USD	2025-07-29 18:43:19	cancelled
2025-05-23	369	69	163	5	392.490000000000009	RUB	2025-05-23 00:36:59	processing
\N	394	618	132	4	240.050000000000011	EUR	\N	cancelled
2026-03-26	370	90	442	2	378.430000000000007	RUB	2026-03-26 19:54:32	cancelled
2024-12-29	397	414	309	2	120.849999999999994	USD	2024-12-29 01:57:27	cancelled
2024-10-26	374	229	206	5	234.300000000000011	RUB	2024-10-26 14:15:25	processing
2024-11-13	406	-1	85	3	231.759999999999991	RUB	2024-11-13 04:33:32	processing
2025-03-26	379	27	450	2	196.400000000000006	EUR	2025-03-26 05:14:05	cancelled
2025-07-14	410	163	156	5	120.870000000000005	RUB	2025-07-14 09:44:10	processing
2025-08-19	381	-1	-1	2	68.980000000000004	EUR	2025-08-19 11:17:48	cancelled
2025-02-20	414	69	249	2	245.659999999999997	USD	2025-02-20 12:21:36	cancelled
2025-06-12	391	30	553	2	457.649999999999977	USD	2025-06-12 10:42:51	cancelled
2025-12-08	421	231	248	5	480.269999999999982	EUR	2025-12-08 13:07:27	processing
2025-03-05	393	68	451	4	429.509999999999991	RUB	2025-03-05 20:27:13	completed
2026-05-17	424	14	-1	2	297.029999999999973	USD	2026-05-17 14:53:41	cancelled
2025-06-28	395	673	585	1	244.120000000000005	RUB	2025-06-28 14:30:24	completed
2025-06-27	425	682	385	4	284.730000000000018	RUB	2025-06-27 07:09:19	processing
2026-01-10	403	346	563	3	405.420000000000016	EUR	2026-01-10 23:31:38	cancelled
2026-01-23	428	404	536	4	427.589999999999975	RUB	2026-01-23 03:25:00	completed
\N	1	380	512	3	256.019999999999982	USD	\N	processing
2025-05-23	14	122	331	3	420.300000000000011	USD	2025-05-23 12:48:47	completed
2025-01-22	5	92	-1	4	60.7999999999999972	RUB	2025-01-22 15:48:14	processing
2024-07-27	17	192	388	3	104.980000000000004	USD	2024-07-27 04:07:00	cancelled
2024-11-12	11	175	198	2	282.310000000000002	EUR	2024-11-12 05:51:09	processing
2024-07-20	20	80	23	2	201.490000000000009	EUR	2024-07-20 09:27:33	cancelled
2025-02-28	12	660	400	5	220.259999999999991	RUB	2025-02-28 18:51:50	processing
2025-06-22	25	0	118	2	115.989999999999995	EUR	2025-06-22 20:48:51	completed
2024-11-07	15	96	557	5	84.9899999999999949	RUB	2024-11-07 14:01:18	completed
2025-09-21	31	205	524	1	230.210000000000008	USD	2025-09-21 11:42:37	cancelled
2025-02-10	23	622	-1	3	496.930000000000007	EUR	2025-02-10 03:12:51	processing
2025-11-19	35	477	291	2	285.199999999999989	EUR	2025-11-19 05:40:49	processing
2026-03-07	26	31	205	2	141.120000000000005	EUR	2026-03-07 09:06:44	completed
2024-09-01	40	473	541	4	28.129999999999999	RUB	2024-09-01 23:29:10	completed
2026-03-30	30	457	393	3	315.230000000000018	RUB	2026-03-30 23:21:33	cancelled
2026-04-29	44	0	447	1	77.980000000000004	EUR	2026-04-29 18:48:16	completed
2025-10-26	36	218	77	3	360.970000000000027	RUB	2025-10-26 17:58:59	processing
2026-04-08	46	54	77	1	33.5200000000000031	EUR	2026-04-08 18:15:53	cancelled
2024-12-15	38	506	176	4	68.4399999999999977	EUR	2024-12-15 07:36:45	processing
2025-12-24	48	472	458	2	378.990000000000009	EUR	2025-12-24 11:10:46	processing
2024-08-30	47	338	142	4	142.259999999999991	USD	2024-08-30 02:42:22	processing
2024-09-21	49	126	330	4	334.019999999999982	EUR	2024-09-21 07:12:23	processing
2025-11-02	50	495	572	3	358.579999999999984	EUR	2025-11-02 18:49:24	completed
2025-01-28	56	315	113	1	82.1700000000000017	USD	2025-01-28 16:51:18	completed
2025-07-15	52	14	349	4	102.079999999999998	USD	2025-07-15 18:11:31	completed
2024-10-02	57	17	464	1	243.360000000000014	RUB	2024-10-02 18:33:27	cancelled
2024-11-28	63	-1	275	2	369.620000000000005	RUB	2024-11-28 15:28:57	cancelled
2026-04-27	61	532	118	2	479.899999999999977	USD	2026-04-27 22:44:37	completed
2025-06-06	69	18	151	2	267.379999999999995	USD	2025-06-06 19:02:27	completed
2024-12-31	64	211	4	3	355.870000000000005	EUR	2024-12-31 08:07:38	completed
2025-10-24	74	32	92	4	186.120000000000005	RUB	2025-10-24 05:32:16	completed
2025-06-15	68	361	113	4	437.879999999999995	EUR	2025-06-15 23:27:33	completed
2025-01-04	78	581	511	3	63.990000000000002	USD	2025-01-04 03:46:58	processing
2024-08-20	71	680	342	1	415.600000000000023	EUR	2024-08-20 05:14:31	processing
2025-12-08	79	151	167	3	315.660000000000025	RUB	2025-12-08 18:52:48	cancelled
2026-03-04	72	680	532	5	247.330000000000013	EUR	2026-03-04 21:26:41	processing
2024-10-04	85	612	205	3	404.149999999999977	USD	2024-10-04 16:12:21	cancelled
2026-01-28	76	272	283	3	201.599999999999994	EUR	2026-01-28 20:44:12	cancelled
2025-10-29	87	559	453	4	57.0600000000000023	RUB	2025-10-29 03:10:32	processing
2025-09-09	83	-1	298	2	221.699999999999989	USD	2025-09-09 04:43:12	completed
2025-05-28	88	321	478	3	239.509999999999991	EUR	2025-05-28 19:49:27	cancelled
2026-03-15	86	139	-1	3	51.9399999999999977	RUB	2026-03-15 17:33:11	cancelled
2026-02-01	96	639	533	1	84.980000000000004	USD	2026-02-01 18:16:17	completed
2025-08-05	89	421	91	1	479.170000000000016	EUR	2025-08-05 17:45:16	completed
2025-03-24	107	-1	496	3	462.5	USD	2025-03-24 02:52:08	cancelled
2025-08-09	91	580	7	4	71.7099999999999937	RUB	2025-08-09 04:22:15	cancelled
2025-03-31	114	137	449	2	105.900000000000006	EUR	2025-03-31 04:56:45	processing
2025-06-02	95	508	7	2	157.439999999999998	EUR	2025-06-02 12:59:28	cancelled
2026-01-13	116	25	6	2	26.2899999999999991	USD	2026-01-13 21:40:34	cancelled
2025-07-23	98	415	267	2	422.439999999999998	RUB	2025-07-23 19:28:34	processing
2026-01-15	123	634	31	1	295.560000000000002	EUR	2026-01-15 10:07:41	completed
2025-07-09	105	10	538	5	113.280000000000001	RUB	2025-07-09 08:11:57	cancelled
2025-05-22	124	347	338	1	78.25	RUB	2025-05-22 13:19:40	processing
2025-02-04	106	526	348	3	331.410000000000025	RUB	2025-02-04 08:04:09	cancelled
2024-06-30	125	64	37	5	453.120000000000005	RUB	2024-06-30 04:32:38	cancelled
2024-08-12	111	238	394	2	61.6599999999999966	USD	2024-08-12 13:11:37	cancelled
2024-07-24	134	251	79	4	244.560000000000002	USD	2024-07-24 18:10:54	completed
2024-11-12	119	142	81	4	438.25	RUB	2024-11-12 23:50:58	completed
2024-07-27	138	287	567	5	122.959999999999994	RUB	2024-07-27 02:02:58	completed
2026-04-27	121	230	70	3	201.310000000000002	EUR	2026-04-27 05:16:40	completed
2025-01-02	152	265	179	4	72.3400000000000034	RUB	2025-01-02 21:37:59	completed
2025-03-21	122	295	320	5	466.589999999999975	RUB	2025-03-21 17:24:27	cancelled
2025-10-07	154	0	264	1	476.329999999999984	EUR	2025-10-07 08:23:37	completed
2025-02-16	128	490	27	2	20.5100000000000016	USD	2025-02-16 17:19:12	completed
2025-11-30	157	381	147	1	324.519999999999982	EUR	2025-11-30 22:33:38	completed
2024-12-07	132	233	256	5	288.339999999999975	USD	2024-12-07 21:59:01	completed
2025-04-18	160	624	353	5	393.899999999999977	RUB	2025-04-18 02:42:29	completed
2025-11-15	135	257	455	3	449.839999999999975	USD	2025-11-15 21:10:09	processing
2026-01-13	162	230	125	5	369.639999999999986	RUB	2026-01-13 00:37:05	processing
2024-12-16	136	310	540	3	435.800000000000011	USD	2024-12-16 14:03:33	cancelled
2025-12-16	169	590	16	2	450.939999999999998	EUR	2025-12-16 11:43:48	completed
2025-11-14	137	327	-1	1	179.849999999999994	EUR	2025-11-14 17:50:07	cancelled
2025-07-02	186	77	526	3	232.199999999999989	RUB	2025-07-02 04:27:43	processing
2026-04-27	144	222	59	5	222.699999999999989	EUR	2026-04-27 02:30:56	completed
2025-01-13	188	195	9	1	475.100000000000023	RUB	2025-01-13 06:57:11	completed
2026-04-16	148	346	257	3	187.22999999999999	RUB	2026-04-16 09:29:43	processing
2025-05-22	189	141	482	2	339.939999999999998	EUR	2025-05-22 19:12:56	completed
2025-12-23	149	0	455	3	419.639999999999986	USD	2025-12-23 08:43:40	cancelled
\N	191	-1	214	1	250.439999999999998	RUB	\N	processing
2025-10-25	150	18	224	3	245.300000000000011	RUB	2025-10-25 02:44:55	cancelled
2024-11-10	196	679	408	3	333.699999999999989	EUR	2024-11-10 12:08:51	processing
2024-06-26	155	695	241	5	361.980000000000018	RUB	2024-06-26 06:58:28	cancelled
2025-12-12	199	326	275	4	205.349999999999994	USD	2025-12-12 08:17:10	cancelled
2026-02-01	158	335	482	4	449.720000000000027	EUR	2026-02-01 06:35:02	cancelled
2024-07-06	201	171	-1	1	474.45999999999998	RUB	2024-07-06 21:06:12	cancelled
2024-09-12	159	0	27	3	465.850000000000023	RUB	2024-09-12 20:13:58	completed
\N	202	133	342	1	403.180000000000007	USD	\N	cancelled
2025-06-10	161	388	81	2	196.72999999999999	RUB	2025-06-10 05:09:07	completed
2024-07-06	204	406	424	2	456.220000000000027	EUR	2024-07-06 17:20:27	completed
2026-01-27	166	79	236	5	122.870000000000005	EUR	2026-01-27 07:15:51	processing
2026-04-01	206	408	-1	3	157.719999999999999	USD	2026-04-01 21:38:04	processing
2025-08-10	167	129	142	4	340.310000000000002	RUB	2025-08-10 23:00:21	processing
2025-07-04	212	495	509	5	129.860000000000014	USD	2025-07-04 22:22:06	processing
2024-10-05	168	267	518	1	49.9399999999999977	EUR	2024-10-05 21:09:23	completed
2024-10-23	213	404	26	1	231.610000000000014	RUB	2024-10-23 14:42:10	cancelled
2024-07-04	170	124	35	4	374	USD	2024-07-04 00:43:16	cancelled
2024-08-29	216	632	506	5	382.680000000000007	USD	2024-08-29 12:33:18	cancelled
2025-10-14	171	25	398	2	262.300000000000011	RUB	2025-10-14 16:25:35	cancelled
2024-06-07	217	422	579	2	27.8900000000000006	RUB	2024-06-07 12:17:40	processing
2025-05-05	172	363	345	2	358.870000000000005	USD	2025-05-05 21:19:11	cancelled
2025-02-27	221	125	508	1	29.1400000000000006	EUR	2025-02-27 04:51:18	completed
2025-08-07	173	606	460	1	46.1400000000000006	EUR	2025-08-07 19:03:56	cancelled
2025-08-26	226	537	482	3	213.990000000000009	USD	2025-08-26 20:29:02	completed
2025-04-13	174	646	138	3	381.25	RUB	2025-04-13 13:02:20	processing
2026-04-06	228	640	354	3	321.810000000000002	USD	2026-04-06 22:52:01	processing
2026-01-30	175	188	-1	5	51.0600000000000023	USD	2026-01-30 17:19:42	processing
2025-07-05	232	393	-1	5	306.339999999999975	RUB	2025-07-05 21:17:33	processing
2026-03-12	178	437	216	2	477.220000000000027	USD	2026-03-12 13:45:39	cancelled
2024-11-05	235	451	247	3	255.180000000000007	USD	2024-11-05 06:23:21	processing
2025-10-25	179	532	170	3	58.740000000000002	EUR	2025-10-25 11:42:13	completed
2024-12-03	242	515	491	1	327.139999999999986	RUB	2024-12-03 04:37:05	cancelled
2025-09-18	181	238	173	2	280.560000000000002	RUB	2025-09-18 07:05:05	completed
2025-01-26	254	-1	136	2	376.230000000000018	RUB	2025-01-26 10:56:07	cancelled
2025-08-02	184	465	506	1	227.759999999999991	EUR	2025-08-02 15:32:50	cancelled
2025-03-29	255	55	424	3	78.8100000000000023	EUR	2025-03-29 22:25:02	completed
2025-10-12	194	497	303	5	184.990000000000009	EUR	2025-10-12 22:32:36	completed
2025-12-22	264	479	-1	4	406.519999999999982	EUR	2025-12-22 02:57:46	processing
2025-08-25	200	-1	227	1	161.169999999999987	EUR	2025-08-25 21:36:30	processing
2024-06-15	265	-1	-1	2	133.759999999999991	EUR	2024-06-15 11:33:33	cancelled
2024-07-14	208	79	555	4	19.879999999999999	RUB	2024-07-14 18:46:24	processing
2024-08-24	268	308	143	5	107.25	RUB	2024-08-24 11:29:22	completed
\N	210	436	271	3	234.860000000000014	USD	\N	processing
2026-04-01	269	680	355	1	161.539999999999992	USD	2026-04-01 17:16:03	cancelled
2024-11-07	214	238	148	1	324.980000000000018	EUR	2024-11-07 03:04:13	processing
2026-01-28	280	408	104	4	405.050000000000011	EUR	2026-01-28 09:06:56	processing
2024-06-03	220	84	166	1	194.090000000000003	USD	2024-06-03 07:51:48	processing
2025-04-23	283	265	344	4	256.009999999999991	EUR	2025-04-23 22:03:33	processing
2025-09-15	222	642	304	5	214.889999999999986	USD	2025-09-15 14:00:09	completed
2024-12-23	284	374	82	4	270.54000000000002	EUR	2024-12-23 22:02:08	completed
2024-08-08	227	6	97	1	273.490000000000009	EUR	2024-08-08 20:07:49	completed
2024-11-17	289	37	255	1	270.319999999999993	EUR	2024-11-17 12:17:24	completed
2025-02-13	231	222	-1	1	72.0900000000000034	RUB	2025-02-13 09:44:40	processing
2025-07-12	293	653	264	1	100.129999999999995	RUB	2025-07-12 13:09:13	processing
2025-05-17	234	147	141	3	48.1199999999999974	USD	2025-05-17 09:16:54	processing
2025-11-17	297	0	6	2	342.319999999999993	EUR	2025-11-17 22:02:44	cancelled
2025-06-21	238	574	446	3	345.829999999999984	RUB	2025-06-21 14:31:01	processing
2025-10-05	300	-1	555	4	321.04000000000002	EUR	2025-10-05 13:34:13	cancelled
2025-06-08	240	632	11	2	197.400000000000006	USD	2025-06-08 09:46:59	completed
2025-12-12	302	511	586	4	135.289999999999992	USD	2025-12-12 16:55:50	completed
2025-01-22	243	45	32	3	316.379999999999995	RUB	2025-01-22 21:58:28	processing
2025-08-13	303	647	379	1	111.700000000000003	RUB	2025-08-13 15:08:24	cancelled
2026-05-07	245	40	135	2	355.759999999999991	USD	2026-05-07 07:48:25	completed
2025-01-30	314	333	24	4	345.339999999999975	EUR	2025-01-30 02:53:28	processing
2025-01-25	248	174	413	3	263.009999999999991	RUB	2025-01-25 03:55:58	cancelled
2025-12-05	316	378	331	4	469.199999999999989	USD	2025-12-05 04:59:49	completed
2024-07-27	249	684	86	5	82.2800000000000011	EUR	2024-07-27 21:24:42	completed
2025-09-29	317	301	-1	5	235.97999999999999	USD	2025-09-29 19:46:51	cancelled
2024-05-26	250	0	4	5	210.530000000000001	RUB	2024-05-26 13:31:05	cancelled
2025-08-12	321	-1	493	5	360.230000000000018	EUR	2025-08-12 12:11:26	processing
2024-09-08	253	642	472	1	116.590000000000003	EUR	2024-09-08 17:33:57	completed
2024-11-14	323	666	594	1	81.5300000000000011	EUR	2024-11-14 05:56:07	completed
2024-07-22	259	699	276	5	280.29000000000002	RUB	2024-07-22 05:57:58	completed
2025-12-23	324	-1	495	3	79.5600000000000023	USD	2025-12-23 17:39:44	completed
2025-06-20	271	83	158	4	54.1799999999999997	USD	2025-06-20 14:34:44	processing
2025-04-30	330	653	13	5	158.449999999999989	RUB	2025-04-30 20:13:55	cancelled
2025-06-01	273	-1	249	4	337.529999999999973	EUR	2025-06-01 05:00:46	completed
2026-04-23	336	208	69	1	476.490000000000009	RUB	2026-04-23 13:41:35	cancelled
2026-03-19	276	228	514	2	190.870000000000005	EUR	2026-03-19 00:01:23	completed
2026-02-08	339	-1	94	5	140.219999999999999	EUR	2026-02-08 16:59:47	processing
2024-09-10	277	626	512	1	326.329999999999984	USD	2024-09-10 11:55:03	completed
2025-09-02	342	75	556	1	243.259999999999991	USD	2025-09-02 05:19:35	processing
2025-09-10	278	46	436	3	198.189999999999998	USD	2025-09-10 18:39:35	completed
2026-03-04	347	187	184	5	240.550000000000011	USD	2026-03-04 07:26:16	completed
\N	281	415	394	3	73.0799999999999983	RUB	\N	processing
2025-05-06	353	484	363	3	81.0400000000000063	EUR	2025-05-06 19:17:35	processing
2026-01-27	292	0	81	1	197.139999999999986	RUB	2026-01-27 07:05:31	cancelled
2024-10-23	357	572	281	2	312.600000000000023	EUR	2024-10-23 05:27:16	completed
2026-01-14	305	640	570	1	378.180000000000007	EUR	2026-01-14 07:40:00	processing
2024-09-25	365	220	266	4	187.47999999999999	USD	2024-09-25 08:03:08	cancelled
2026-02-01	306	503	127	5	74.5300000000000011	RUB	2026-02-01 07:58:13	completed
2025-09-30	368	517	342	5	251.080000000000013	RUB	2025-09-30 10:29:37	processing
2025-02-07	307	406	411	5	151.780000000000001	USD	2025-02-07 09:01:17	processing
2024-08-25	372	590	589	4	445.800000000000011	EUR	2024-08-25 16:12:46	cancelled
2024-11-17	313	142	419	1	303.79000000000002	RUB	2024-11-17 21:29:55	completed
2026-03-07	375	364	212	5	84.7800000000000011	USD	2026-03-07 18:00:56	cancelled
2024-10-31	318	248	340	5	324.279999999999973	RUB	2024-10-31 15:03:24	completed
2024-07-18	376	186	357	1	391.939999999999998	RUB	2024-07-18 15:44:12	completed
2025-11-27	327	282	227	2	265.670000000000016	USD	2025-11-27 20:08:34	cancelled
2025-11-12	378	239	127	3	23.379999999999999	EUR	2025-11-12 06:14:38	cancelled
2025-11-12	328	578	487	2	288.139999999999986	EUR	2025-11-12 11:10:17	processing
2025-06-24	384	364	308	1	222.72999999999999	RUB	2025-06-24 20:15:33	completed
2025-01-16	332	660	497	3	266.439999999999998	EUR	2025-01-16 16:34:01	processing
2025-04-16	386	663	132	2	96.9099999999999966	USD	2025-04-16 02:31:48	processing
2024-11-29	337	567	458	5	437.579999999999984	USD	2024-11-29 00:25:54	processing
2026-03-31	388	633	156	2	95.5699999999999932	RUB	2026-03-31 23:44:25	processing
2025-05-06	340	195	213	2	266.050000000000011	USD	2025-05-06 08:39:08	completed
2024-07-01	392	613	95	1	17.3200000000000003	USD	2024-07-01 16:35:23	cancelled
2025-07-15	343	221	454	1	295.04000000000002	USD	2025-07-15 22:13:46	processing
2025-04-24	396	129	98	2	120.519999999999996	USD	2025-04-24 20:58:29	processing
2026-02-09	349	199	328	2	160.530000000000001	EUR	2026-02-09 01:20:56	processing
2026-04-23	399	433	-1	1	376.490000000000009	EUR	2026-04-23 10:43:59	completed
2025-08-01	351	161	161	2	427.660000000000025	RUB	2025-08-01 02:43:00	cancelled
2025-03-25	402	220	527	4	67.730000000000004	EUR	2025-03-25 06:00:52	cancelled
2026-03-03	359	676	-1	4	132.419999999999987	RUB	2026-03-03 10:39:42	cancelled
2025-07-25	407	187	228	5	105.489999999999995	RUB	2025-07-25 17:57:57	completed
2024-12-28	377	336	435	2	108.829999999999998	USD	2024-12-28 14:26:55	cancelled
2025-09-22	408	204	544	5	392.170000000000016	RUB	2025-09-22 06:41:23	processing
2025-07-23	380	204	519	1	55.5	USD	2025-07-23 02:03:28	processing
2025-08-28	409	49	171	2	349.910000000000025	RUB	2025-08-28 16:00:37	cancelled
2025-09-12	382	325	490	1	401.899999999999977	EUR	2025-09-12 06:13:43	cancelled
2025-02-17	411	625	304	1	479.939999999999998	EUR	2025-02-17 13:01:00	cancelled
2024-12-20	385	-1	282	4	439.20999999999998	USD	2024-12-20 09:45:09	processing
2025-03-17	417	146	319	1	322.009999999999991	RUB	2025-03-17 06:20:48	processing
2025-01-16	387	160	301	1	39.9799999999999969	USD	2025-01-16 21:36:42	cancelled
2025-01-30	419	625	391	3	438.870000000000005	USD	2025-01-30 01:54:30	cancelled
2025-09-28	398	-1	135	5	263.279999999999973	EUR	2025-09-28 06:39:23	cancelled
2025-07-21	427	98	-1	3	294.259999999999991	RUB	2025-07-21 07:00:28	cancelled
\N	400	203	166	1	419.339999999999975	USD	\N	cancelled
2025-04-25	404	680	437	5	138.800000000000011	EUR	2025-04-25 12:30:28	processing
2024-12-27	436	-1	173	4	448.930000000000007	USD	2024-12-27 06:16:13	cancelled
2024-09-02	412	535	308	4	167.740000000000009	RUB	2024-09-02 10:06:07	completed
2025-04-11	437	17	304	5	353.110000000000014	RUB	2025-04-11 08:00:59	processing
2025-04-12	415	164	73	2	131.800000000000011	EUR	2025-04-12 06:09:13	completed
2026-04-28	438	552	-1	1	107.319999999999993	USD	2026-04-28 05:36:27	processing
2025-02-02	416	283	211	5	472.730000000000018	USD	2025-02-02 03:41:55	cancelled
2025-06-16	439	415	137	3	271.089999999999975	EUR	2025-06-16 15:02:20	cancelled
2025-04-05	418	106	128	2	333.610000000000014	EUR	2025-04-05 16:26:16	processing
2024-07-09	446	380	79	2	166.879999999999995	EUR	2024-07-09 02:29:35	processing
2024-12-03	422	507	287	4	37.759999999999998	USD	2024-12-03 23:15:59	processing
2024-07-31	449	357	477	5	412.329999999999984	USD	2024-07-31 06:08:40	cancelled
2025-07-10	426	532	101	1	304.810000000000002	RUB	2025-07-10 14:42:15	processing
2024-06-27	456	123	166	1	269.589999999999975	RUB	2024-06-27 20:13:18	processing
2024-05-30	429	409	222	4	337.839999999999975	USD	2024-05-30 01:37:34	processing
2025-12-11	461	360	537	3	231.349999999999994	USD	2025-12-11 07:20:39	cancelled
2024-06-25	435	93	208	4	323.339999999999975	EUR	2024-06-25 08:33:10	cancelled
2024-08-31	462	21	98	5	38.9799999999999969	EUR	2024-08-31 09:01:30	completed
2025-05-30	444	565	410	2	425.470000000000027	RUB	2025-05-30 11:56:15	processing
2024-12-02	465	549	182	2	303.860000000000014	RUB	2024-12-02 21:51:22	cancelled
2024-06-04	447	138	132	2	399.819999999999993	RUB	2024-06-04 16:01:21	completed
2025-09-29	466	-1	32	5	82.9399999999999977	EUR	2025-09-29 10:06:24	processing
2025-05-02	452	699	29	3	289.180000000000007	RUB	2025-05-02 08:31:05	processing
2025-01-27	470	120	503	2	189.189999999999998	USD	2025-01-27 19:24:41	completed
2024-08-17	455	553	367	1	485.740000000000009	USD	2024-08-17 19:56:18	processing
2026-02-03	471	0	-1	4	407.339999999999975	RUB	2026-02-03 22:33:35	completed
2025-02-06	457	200	507	2	419.509999999999991	USD	2025-02-06 09:12:15	processing
2026-03-15	473	404	203	3	166.960000000000008	EUR	2026-03-15 00:57:18	cancelled
2025-01-16	458	123	397	4	291.259999999999991	RUB	2025-01-16 12:26:40	cancelled
2025-07-21	475	575	57	4	496.220000000000027	EUR	2025-07-21 15:14:59	processing
2024-07-22	459	391	364	3	99.6599999999999966	EUR	2024-07-22 14:02:49	completed
2025-09-07	476	43	556	5	376.449999999999989	RUB	2025-09-07 06:10:12	completed
2024-10-31	460	-1	206	1	100.439999999999998	EUR	2024-10-31 08:29:29	completed
2025-03-21	479	380	227	2	58.3400000000000034	USD	2025-03-21 01:49:33	processing
2026-01-06	464	577	511	2	102.359999999999999	RUB	2026-01-06 10:52:42	completed
2025-01-23	482	400	-1	4	31.9299999999999997	USD	2025-01-23 22:06:10	completed
2025-06-07	469	159	399	4	465.019999999999982	RUB	2025-06-07 05:47:39	cancelled
2025-05-17	485	387	-1	4	134.180000000000007	USD	2025-05-17 12:50:32	processing
2025-06-10	484	210	426	3	210.509999999999991	USD	2025-06-10 06:28:46	cancelled
2024-07-23	486	0	73	2	334.850000000000023	USD	2024-07-23 07:40:02	processing
2024-09-21	490	131	39	4	63.5799999999999983	USD	2024-09-21 09:36:19	cancelled
2024-10-19	487	118	336	4	42.5900000000000034	RUB	2024-10-19 22:53:44	completed
2024-12-14	491	189	380	1	128.460000000000008	RUB	2024-12-14 16:37:29	cancelled
\N	493	0	180	2	177.259999999999991	EUR	\N	cancelled
2026-01-07	494	474	518	4	196.219999999999999	EUR	2026-01-07 10:33:47	completed
2026-03-03	495	231	72	4	22.3999999999999986	EUR	2026-03-03 01:52:52	completed
2025-09-25	501	-1	257	2	344.610000000000014	RUB	2025-09-25 01:15:16	cancelled
2025-10-14	498	40	577	2	12.8900000000000006	USD	2025-10-14 11:30:50	completed
2024-11-25	502	652	230	2	232.569999999999993	EUR	2024-11-25 01:45:07	completed
2025-01-03	500	0	396	4	469.230000000000018	RUB	2025-01-03 19:25:25	cancelled
2024-09-13	506	464	409	3	175.52000000000001	RUB	2024-09-13 02:37:26	completed
2024-12-07	505	412	428	2	471.519999999999982	EUR	2024-12-07 02:39:32	cancelled
2026-02-11	508	475	219	4	193.659999999999997	EUR	2026-02-11 21:14:42	cancelled
2025-11-22	509	145	423	4	157.159999999999997	RUB	2025-11-22 20:08:50	completed
2026-03-27	512	657	480	2	83.8299999999999983	EUR	2026-03-27 02:29:39	completed
2024-05-27	513	134	544	5	467.180000000000007	RUB	2024-05-27 14:51:43	processing
2025-09-25	515	93	315	2	374.360000000000014	USD	2025-09-25 15:17:28	completed
2026-05-18	514	644	55	1	52.0200000000000031	USD	2026-05-18 12:10:53	cancelled
2025-09-07	519	680	391	1	380.279999999999973	USD	2025-09-07 04:14:58	cancelled
2026-04-14	516	372	180	4	242.789999999999992	RUB	2026-04-14 04:04:52	cancelled
2026-02-22	522	88	404	2	315.779999999999973	RUB	2026-02-22 10:17:49	completed
2025-03-25	520	389	452	5	347.180000000000007	EUR	2025-03-25 19:11:46	processing
2024-12-09	525	374	502	3	491.199999999999989	USD	2024-12-09 04:01:49	cancelled
2025-10-18	524	86	428	4	17.8200000000000003	RUB	2025-10-18 14:56:54	completed
2024-07-18	526	171	346	3	138.930000000000007	EUR	2024-07-18 17:00:22	completed
2026-02-09	531	-1	87	3	140.669999999999987	EUR	2026-02-09 18:37:19	processing
2025-02-23	530	376	136	4	209.530000000000001	EUR	2025-02-23 09:30:43	cancelled
2026-04-21	533	182	10	2	391.649999999999977	USD	2026-04-21 00:06:51	processing
2025-01-03	535	647	143	1	310.160000000000025	USD	2025-01-03 01:01:30	completed
2024-10-02	539	0	590	2	139	RUB	2024-10-02 23:24:52	completed
2025-08-29	537	52	508	5	104.390000000000001	USD	2025-08-29 04:58:20	processing
2024-08-31	543	166	-1	3	452.319999999999993	USD	2024-08-31 13:01:48	cancelled
2026-01-14	541	405	293	5	212.02000000000001	RUB	2026-01-14 12:15:20	completed
2026-02-16	548	477	464	4	237.180000000000007	EUR	2026-02-16 16:37:36	completed
2025-06-08	558	458	-1	3	347.259999999999991	EUR	2025-06-08 18:13:38	cancelled
\N	550	153	223	2	84.0100000000000051	USD	\N	completed
2025-12-23	564	336	328	5	81.5999999999999943	EUR	2025-12-23 05:46:57	cancelled
2024-07-26	555	507	163	1	478.860000000000014	RUB	2024-07-26 09:29:02	cancelled
2025-04-29	565	322	-1	2	479.29000000000002	RUB	2025-04-29 04:26:27	completed
2024-06-03	556	646	543	5	69.7099999999999937	USD	2024-06-03 06:38:09	cancelled
2025-11-07	580	686	37	1	29.6600000000000001	RUB	2025-11-07 10:39:50	completed
2025-12-11	560	587	501	5	308.600000000000023	USD	2025-12-11 12:25:01	processing
\N	581	236	522	1	294.980000000000018	EUR	\N	completed
2025-04-11	563	-1	-1	1	242.139999999999986	USD	2025-04-11 19:24:21	completed
2024-06-28	582	407	384	5	147.889999999999986	RUB	2024-06-28 07:56:18	processing
2024-06-09	572	27	36	4	97.2199999999999989	RUB	2024-06-09 08:38:27	processing
2024-09-22	586	306	475	5	410.75	EUR	2024-09-22 19:16:13	completed
2024-12-24	575	369	505	4	178.349999999999994	USD	2024-12-24 06:16:42	cancelled
2025-02-09	594	146	32	2	68.9599999999999937	RUB	2025-02-09 21:31:07	cancelled
2025-06-25	576	559	92	4	350.350000000000023	RUB	2025-06-25 12:39:27	completed
2024-07-07	600	459	573	1	438.029999999999973	EUR	2024-07-07 14:26:58	processing
2025-11-17	577	460	572	3	121.420000000000002	USD	2025-11-17 04:00:02	completed
2025-03-03	603	150	382	4	95.2399999999999949	EUR	2025-03-03 19:37:16	cancelled
2025-01-06	584	403	525	1	228.319999999999993	RUB	2025-01-06 18:15:25	cancelled
2024-12-18	604	356	369	4	341.100000000000023	EUR	2024-12-18 23:40:55	cancelled
2024-06-04	590	293	1	2	48.0600000000000023	USD	2024-06-04 00:07:34	completed
2025-03-24	613	148	311	3	128.5	EUR	2025-03-24 14:19:52	completed
2025-11-19	601	501	-1	1	150.389999999999986	USD	2025-11-19 02:59:51	cancelled
2025-10-27	617	312	43	4	321.259999999999991	RUB	2025-10-27 01:52:41	processing
2024-09-11	607	350	143	2	427.04000000000002	RUB	2024-09-11 00:25:10	completed
2026-05-22	618	504	485	3	25.2100000000000009	RUB	2026-05-22 12:16:39	cancelled
2024-11-17	610	-1	562	3	368.610000000000014	EUR	2024-11-17 19:35:42	cancelled
2024-12-25	620	0	95	1	242.689999999999998	RUB	2024-12-25 10:46:33	completed
2025-06-24	611	536	109	5	182.060000000000002	EUR	2025-06-24 14:31:06	completed
2026-04-30	622	619	463	3	280.79000000000002	RUB	2026-04-30 09:32:01	completed
2025-11-04	612	656	111	2	360.939999999999998	RUB	2025-11-04 09:51:24	cancelled
2024-06-16	628	229	119	4	122.079999999999998	EUR	2024-06-16 21:07:22	completed
\N	616	367	384	5	157.110000000000014	EUR	\N	completed
2025-04-04	634	270	574	2	295.240000000000009	USD	2025-04-04 00:45:17	completed
2024-11-26	626	41	204	1	346.54000000000002	USD	2024-11-26 11:07:19	cancelled
2024-08-22	649	278	246	2	163.400000000000006	EUR	2024-08-22 18:51:11	processing
2024-08-09	631	35	270	4	42.7999999999999972	USD	2024-08-09 19:58:52	processing
2025-10-27	650	196	286	3	263.660000000000025	EUR	2025-10-27 01:40:39	cancelled
2025-01-25	635	238	523	4	15.4800000000000004	USD	2025-01-25 16:10:01	completed
2025-05-21	651	613	303	5	446.370000000000005	USD	2025-05-21 06:14:51	completed
2025-02-12	640	641	44	3	209.129999999999995	EUR	2025-02-12 07:54:12	cancelled
2026-05-20	652	-1	596	5	167.360000000000014	EUR	2026-05-20 13:26:07	processing
2025-04-22	648	502	-1	5	319.370000000000005	EUR	2025-04-22 16:03:12	cancelled
2025-04-06	656	128	261	4	11.5999999999999996	USD	2025-04-06 23:23:11	cancelled
2024-08-17	655	278	74	3	81.7099999999999937	RUB	2024-08-17 08:34:55	cancelled
2025-05-08	657	466	204	3	260.449999999999989	EUR	2025-05-08 16:00:21	cancelled
2025-06-17	658	53	448	4	301.680000000000007	EUR	2025-06-17 08:19:24	cancelled
2025-04-30	663	243	393	3	383.550000000000011	USD	2025-04-30 07:01:42	completed
2026-01-17	662	441	566	5	289.600000000000023	EUR	2026-01-17 23:26:36	cancelled
2024-05-26	670	398	-1	3	80.8100000000000023	USD	2024-05-26 22:14:52	processing
2025-06-09	664	555	277	1	289.910000000000025	RUB	2025-06-09 16:59:41	cancelled
2026-05-13	671	700	415	2	116.780000000000001	EUR	2026-05-13 20:10:59	cancelled
\N	666	226	396	3	223.240000000000009	RUB	\N	cancelled
2024-10-10	672	255	25	4	304.20999999999998	EUR	2024-10-10 14:44:10	processing
2024-10-02	673	577	399	4	359.399999999999977	USD	2024-10-02 21:19:33	processing
2025-10-31	678	82	286	2	153.639999999999986	EUR	2025-10-31 13:58:42	completed
2026-03-14	675	262	225	3	244.47999999999999	USD	2026-03-14 16:37:23	processing
2026-03-30	679	235	-1	1	123.590000000000003	USD	2026-03-30 11:43:19	completed
2025-10-10	677	235	52	1	311.569999999999993	RUB	2025-10-10 12:20:00	cancelled
2025-06-13	684	22	481	4	76.1299999999999955	USD	2025-06-13 22:05:15	completed
2025-07-16	696	670	565	3	183.840000000000003	RUB	2025-07-16 23:02:26	cancelled
2024-08-31	688	555	363	4	481.430000000000007	RUB	2024-08-31 09:51:18	processing
2025-01-31	700	472	600	3	34.9500000000000028	RUB	2025-01-31 11:26:48	completed
2025-01-31	691	619	499	3	193.080000000000013	EUR	2025-01-31 23:34:54	completed
2024-08-14	701	449	580	5	27.7199999999999989	RUB	2024-08-14 00:27:24	processing
2024-06-23	692	17	144	2	230.469999999999999	RUB	2024-06-23 19:05:44	processing
2025-07-05	702	69	451	4	171.77000000000001	RUB	2025-07-05 17:34:46	processing
2025-08-19	697	42	199	4	43.2000000000000028	EUR	2025-08-19 11:07:14	cancelled
2026-03-19	708	591	540	3	319.449999999999989	EUR	2026-03-19 01:02:38	completed
2025-06-06	703	-1	283	2	55.6599999999999966	EUR	2025-06-06 16:04:58	cancelled
2025-03-16	713	410	493	1	128.819999999999993	RUB	2025-03-16 06:22:56	processing
2025-01-12	705	156	168	2	10.2799999999999994	USD	2025-01-12 02:06:40	completed
2026-02-02	715	485	499	3	67.9300000000000068	USD	2026-02-02 13:45:24	cancelled
2025-10-14	709	684	252	5	344.470000000000027	RUB	2025-10-14 23:53:09	completed
2024-08-28	721	41	503	2	396.879999999999995	EUR	2024-08-28 09:30:41	completed
2026-03-31	710	23	415	5	157.280000000000001	RUB	2026-03-31 00:25:11	completed
2024-07-02	727	0	130	1	82.3599999999999994	EUR	2024-07-02 05:57:50	completed
2026-03-07	711	606	229	1	413.79000000000002	RUB	2026-03-07 03:46:09	completed
2025-05-07	731	399	461	4	394.029999999999973	EUR	2025-05-07 18:31:30	completed
2025-08-17	720	586	597	3	171.77000000000001	USD	2025-08-17 22:23:41	completed
2025-08-07	733	169	152	4	439.009999999999991	EUR	2025-08-07 15:12:22	completed
2024-12-01	723	67	528	2	325.300000000000011	RUB	2024-12-01 21:59:26	completed
2024-10-09	738	627	-1	1	232.930000000000007	RUB	2024-10-09 11:55:54	processing
2025-09-05	725	485	411	5	160.139999999999986	RUB	2025-09-05 20:00:02	cancelled
2024-11-11	741	323	40	3	157.139999999999986	RUB	2024-11-11 05:09:43	completed
2026-02-16	726	241	153	3	113.170000000000002	EUR	2026-02-16 03:22:16	processing
2024-09-26	742	685	42	3	12.0999999999999996	USD	2024-09-26 13:22:59	completed
2026-01-02	729	420	215	5	367.399999999999977	EUR	2026-01-02 21:25:48	cancelled
2024-07-31	744	0	53	3	386.759999999999991	RUB	2024-07-31 08:56:37	cancelled
2026-04-29	730	0	33	2	179.090000000000003	USD	2026-04-29 02:53:32	cancelled
2025-09-09	746	-1	82	2	16.9600000000000009	EUR	2025-09-09 01:47:11	cancelled
2026-04-13	751	117	477	5	385.339999999999975	RUB	2026-04-13 20:29:50	processing
2025-11-15	747	663	265	1	73.6400000000000006	RUB	2025-11-15 02:59:42	completed
2026-01-30	752	126	362	1	184.569999999999993	USD	2026-01-30 11:50:39	completed
2025-04-08	749	100	71	5	348.860000000000014	RUB	2025-04-08 19:43:24	completed
2026-01-06	753	398	89	3	365.399999999999977	RUB	2026-01-06 19:14:24	completed
2025-12-20	750	160	277	1	477.259999999999991	USD	2025-12-20 19:25:41	completed
2025-06-23	756	172	233	5	376.389999999999986	USD	2025-06-23 02:09:42	processing
2024-09-09	754	167	360	5	105.140000000000001	RUB	2024-09-09 21:11:53	completed
2024-12-08	762	40	265	3	335.759999999999991	USD	2024-12-08 18:10:28	cancelled
2024-12-18	755	349	413	4	60.75	RUB	2024-12-18 16:31:54	completed
2024-11-14	765	96	372	5	303.779999999999973	USD	2024-11-14 00:45:32	completed
2025-11-03	757	507	43	3	324.839999999999975	USD	2025-11-03 04:59:54	completed
2025-12-03	771	370	254	2	299.519999999999982	RUB	2025-12-03 14:00:11	completed
2024-09-11	761	640	436	3	130.560000000000002	RUB	2024-09-11 03:43:14	cancelled
2024-07-27	787	15	311	1	297.379999999999995	EUR	2024-07-27 19:24:57	processing
2024-11-24	770	54	44	5	11.9600000000000009	EUR	2024-11-24 15:27:52	cancelled
2024-06-21	788	230	277	3	421.339999999999975	EUR	2024-06-21 01:10:03	completed
2025-12-11	772	343	-1	5	353.339999999999975	USD	2025-12-11 03:06:29	completed
2026-02-21	792	65	251	2	450.399999999999977	EUR	2026-02-21 16:10:02	processing
2026-04-27	775	561	541	5	336.769999999999982	USD	2026-04-27 10:27:29	cancelled
2024-12-20	800	75	227	5	226.22999999999999	USD	2024-12-20 17:59:47	processing
2025-11-30	777	632	510	4	134.949999999999989	RUB	2025-11-30 05:22:11	completed
2024-10-18	802	288	-1	2	55.8100000000000023	USD	2024-10-18 09:51:20	completed
2024-07-02	778	118	189	3	348.740000000000009	RUB	2024-07-02 10:30:37	processing
2025-08-04	805	339	1	2	463.160000000000025	EUR	2025-08-04 20:22:52	cancelled
2026-05-18	779	595	256	2	358.420000000000016	USD	2026-05-18 09:54:09	processing
2025-07-19	808	47	472	2	106.849999999999994	EUR	2025-07-19 05:02:48	completed
2025-09-19	781	3	212	1	212.539999999999992	EUR	2025-09-19 16:05:11	cancelled
2025-09-23	809	678	210	1	67.7600000000000051	RUB	2025-09-23 15:27:18	cancelled
2024-07-14	783	676	212	2	430.300000000000011	USD	2024-07-14 18:51:02	cancelled
2025-05-04	815	177	220	3	164.710000000000008	RUB	2025-05-04 19:13:26	processing
2025-02-13	785	0	470	1	392.879999999999995	USD	2025-02-13 05:04:03	processing
2025-04-17	826	646	389	2	494.319999999999993	EUR	2025-04-17 08:34:31	processing
\N	794	4	2	5	215.669999999999987	EUR	\N	cancelled
2026-04-15	831	268	529	3	53.4600000000000009	RUB	2026-04-15 08:43:57	cancelled
2026-03-13	798	247	79	4	479.180000000000007	USD	2026-03-13 23:58:48	completed
2025-05-19	832	543	276	1	125.540000000000006	USD	2025-05-19 19:44:56	processing
2024-11-26	801	220	419	3	15.7300000000000004	RUB	2024-11-26 16:53:13	completed
2024-07-21	833	234	591	1	189.439999999999998	USD	2024-07-21 23:55:00	cancelled
2026-01-19	803	96	46	5	375.740000000000009	USD	2026-01-19 05:25:17	cancelled
2024-10-30	430	0	30	1	153.219999999999999	EUR	2024-10-30 04:04:52	processing
2025-09-01	806	-1	28	4	282.579999999999984	USD	2025-09-01 06:20:51	processing
2024-08-20	433	561	512	3	392.670000000000016	USD	2024-08-20 19:43:46	completed
2025-06-11	401	0	416	3	102	RUB	2025-06-11 00:17:34	cancelled
2024-09-01	434	342	104	2	165.099999999999994	EUR	2024-09-01 07:17:34	processing
2025-10-25	405	27	124	2	487.79000000000002	USD	2025-10-25 02:47:47	processing
2026-02-18	445	590	270	3	356.310000000000002	EUR	2026-02-18 11:03:07	cancelled
2025-09-27	413	77	-1	3	112.290000000000006	RUB	2025-09-27 20:11:37	processing
2024-05-31	450	589	67	4	253.599999999999994	EUR	2024-05-31 21:00:43	completed
2024-11-29	420	116	499	2	439.360000000000014	RUB	2024-11-29 04:07:33	cancelled
2026-01-11	451	23	152	1	448.95999999999998	EUR	2026-01-11 00:54:53	completed
2025-02-14	423	283	366	3	215.629999999999995	EUR	2025-02-14 11:05:55	completed
2025-01-08	454	552	417	2	289.230000000000018	RUB	2025-01-08 13:28:26	completed
2025-05-29	431	468	284	3	182.669999999999987	USD	2025-05-29 10:18:19	cancelled
2025-06-28	467	40	299	1	405.529999999999973	EUR	2025-06-28 07:08:38	completed
2026-05-12	432	49	215	3	386.620000000000005	USD	2026-05-12 03:05:24	processing
2024-12-29	472	533	545	5	285.870000000000005	RUB	2024-12-29 07:25:46	processing
2025-04-17	440	107	332	3	310.579999999999984	USD	2025-04-17 19:27:01	completed
2024-09-17	474	642	107	1	250.330000000000013	EUR	2024-09-17 18:27:55	cancelled
2026-01-26	441	454	27	2	337.089999999999975	EUR	2026-01-26 02:15:26	cancelled
2025-06-04	478	361	183	4	371.879999999999995	RUB	2025-06-04 16:37:08	processing
2026-02-09	442	230	222	2	438.819999999999993	EUR	2026-02-09 15:59:48	completed
2025-11-04	480	328	16	2	289.860000000000014	RUB	2025-11-04 03:05:23	completed
2025-07-02	443	13	425	5	246.800000000000011	EUR	2025-07-02 16:02:46	processing
2024-05-30	483	637	-1	4	343.389999999999986	RUB	2024-05-30 23:47:26	cancelled
2025-04-19	448	520	234	1	405.550000000000011	RUB	2025-04-19 03:20:11	processing
2026-02-23	488	263	292	4	149.560000000000002	EUR	2026-02-23 12:10:36	processing
2025-07-21	453	613	463	2	493.240000000000009	USD	2025-07-21 07:05:18	cancelled
2025-12-03	492	147	216	5	385.730000000000018	USD	2025-12-03 03:30:59	processing
2025-09-28	463	2	29	1	170.159999999999997	EUR	2025-09-28 23:52:28	processing
2025-03-18	504	22	555	1	235.370000000000005	RUB	2025-03-18 12:30:07	completed
2026-01-08	468	358	198	2	451.110000000000014	EUR	2026-01-08 15:27:32	processing
2026-01-20	507	-1	-1	2	288.509999999999991	RUB	2026-01-20 05:29:54	cancelled
2026-03-27	477	657	395	1	33.1300000000000026	EUR	2026-03-27 06:31:54	completed
2024-06-14	518	420	256	4	352.930000000000007	EUR	2024-06-14 04:42:03	completed
2025-10-04	481	391	339	3	12.3200000000000003	USD	2025-10-04 07:11:23	completed
2025-01-16	521	586	353	4	473.839999999999975	RUB	2025-01-16 01:10:03	cancelled
2024-09-28	489	268	510	2	475.600000000000023	RUB	2024-09-28 18:19:43	completed
2025-06-10	523	114	300	2	481.170000000000016	EUR	2025-06-10 05:59:22	processing
2025-09-28	496	617	59	2	278.089999999999975	EUR	2025-09-28 17:55:52	completed
2025-11-14	528	134	310	1	369.970000000000027	USD	2025-11-14 05:42:45	cancelled
2025-04-26	497	-1	330	1	313.110000000000014	USD	2025-04-26 20:45:02	cancelled
2025-08-26	546	-1	501	4	191.52000000000001	EUR	2025-08-26 05:48:34	cancelled
2025-08-15	499	397	578	2	383.470000000000027	USD	2025-08-15 13:41:54	processing
2024-06-30	547	560	362	5	93.5699999999999932	RUB	2024-06-30 15:26:30	cancelled
2024-11-25	503	294	377	4	499.579999999999984	USD	2024-11-25 16:12:59	processing
2024-08-15	549	146	391	1	437.949999999999989	EUR	2024-08-15 02:45:01	processing
2024-06-22	510	205	443	2	333.230000000000018	RUB	2024-06-22 22:27:45	completed
2025-03-02	552	311	-1	3	121.590000000000003	EUR	2025-03-02 19:07:25	processing
2026-03-08	511	0	577	5	336.829999999999984	EUR	2026-03-08 08:04:01	completed
2025-09-15	553	512	62	2	248.800000000000011	RUB	2025-09-15 18:40:28	cancelled
2026-02-18	517	311	546	2	90	USD	2026-02-18 07:07:34	processing
2025-10-25	561	482	-1	1	198.22999999999999	USD	2025-10-25 13:12:58	cancelled
2025-03-10	527	280	565	4	333.110000000000014	EUR	2025-03-10 09:44:44	completed
2025-01-10	562	84	198	3	42.7899999999999991	EUR	2025-01-10 18:26:28	cancelled
2024-10-28	529	205	385	1	350.689999999999998	EUR	2024-10-28 18:48:41	cancelled
2024-11-20	567	386	148	1	156.110000000000014	USD	2024-11-20 19:29:59	cancelled
2024-07-13	532	327	249	1	407.269999999999982	USD	2024-07-13 20:40:29	completed
2024-08-27	568	0	152	4	48.5700000000000003	EUR	2024-08-27 03:47:47	cancelled
2026-04-09	534	14	-1	5	44.490000000000002	RUB	2026-04-09 23:16:20	cancelled
2024-09-15	569	641	281	4	381.649999999999977	USD	2024-09-15 02:40:41	cancelled
2024-07-09	536	84	239	1	11.8800000000000008	RUB	2024-07-09 13:23:08	completed
2026-02-07	574	66	241	1	266.160000000000025	RUB	2026-02-07 04:35:54	completed
2025-12-03	538	-1	454	5	433.850000000000023	USD	2025-12-03 00:11:36	completed
2025-11-03	579	141	505	4	19.4400000000000013	EUR	2025-11-03 01:52:31	completed
2025-09-20	540	-1	234	2	101.650000000000006	EUR	2025-09-20 07:21:58	completed
2024-10-15	583	398	335	5	135.580000000000013	USD	2024-10-15 10:35:18	cancelled
2025-12-21	542	437	258	2	269.970000000000027	RUB	2025-12-21 19:54:49	cancelled
2024-09-21	585	210	205	1	373.980000000000018	USD	2024-09-21 14:53:48	processing
2026-03-31	544	82	91	4	15.8800000000000008	RUB	2026-03-31 22:06:52	cancelled
2025-01-31	589	336	575	2	461.199999999999989	EUR	2025-01-31 08:21:16	processing
2026-01-04	545	603	583	5	342.319999999999993	USD	2026-01-04 05:37:27	cancelled
\N	591	635	456	3	465.779999999999973	EUR	\N	cancelled
2026-05-08	551	17	402	3	106.900000000000006	EUR	2026-05-08 03:59:50	completed
2025-06-11	595	0	571	2	233.069999999999993	RUB	2025-06-11 09:31:40	cancelled
2025-06-01	554	109	241	4	307.829999999999984	USD	2025-06-01 19:47:12	processing
2025-01-31	596	0	221	1	368.399999999999977	USD	2025-01-31 05:29:22	completed
2025-12-16	557	350	65	2	191.090000000000003	EUR	2025-12-16 08:12:51	completed
2024-07-20	598	14	289	1	480.120000000000005	EUR	2024-07-20 17:53:35	processing
2025-09-15	559	288	330	3	352.180000000000007	USD	2025-09-15 05:10:04	processing
2025-08-23	599	491	241	3	481.95999999999998	USD	2025-08-23 09:29:12	processing
2025-01-10	566	303	290	2	266.519999999999982	RUB	2025-01-10 11:11:50	completed
2025-10-18	602	468	565	3	332.70999999999998	EUR	2025-10-18 21:05:00	processing
2024-10-04	570	283	331	3	89.8199999999999932	USD	2024-10-04 12:22:10	completed
2025-05-01	605	89	478	3	463.110000000000014	RUB	2025-05-01 22:32:45	cancelled
2024-08-24	571	127	385	4	190.719999999999999	EUR	2024-08-24 12:43:59	processing
2025-05-05	606	553	149	1	178.289999999999992	RUB	2025-05-05 21:11:10	processing
2025-01-30	573	290	136	1	442.800000000000011	USD	2025-01-30 15:24:11	cancelled
2024-10-29	614	555	303	2	21.5199999999999996	USD	2024-10-29 10:39:31	completed
2024-09-26	578	54	239	4	30.7699999999999996	USD	2024-09-26 19:07:13	completed
\N	623	629	29	2	300.779999999999973	RUB	\N	processing
2025-01-17	587	664	318	3	116.230000000000004	USD	2025-01-17 23:47:28	completed
2025-09-18	629	169	509	5	285.759999999999991	EUR	2025-09-18 07:00:44	cancelled
2025-09-20	588	222	398	2	254.800000000000011	RUB	2025-09-20 22:01:04	processing
2026-05-20	630	-1	429	3	321.069999999999993	USD	2026-05-20 01:17:09	cancelled
2026-02-16	592	-1	196	1	190.340000000000003	RUB	2026-02-16 12:06:53	cancelled
2025-11-07	633	166	383	2	228.590000000000003	RUB	2025-11-07 10:36:22	processing
2026-01-11	593	382	123	1	155.759999999999991	USD	2026-01-11 11:57:19	cancelled
2025-06-23	636	116	328	5	14.3399999999999999	USD	2025-06-23 17:54:14	completed
\N	597	408	423	4	221.919999999999987	EUR	\N	completed
2024-06-29	638	398	523	1	81.5999999999999943	USD	2024-06-29 04:45:34	completed
2025-11-01	608	-1	43	1	495.350000000000023	RUB	2025-11-01 02:47:01	processing
2026-05-15	639	70	-1	1	287.420000000000016	USD	2026-05-15 09:16:08	cancelled
2025-06-29	609	107	233	5	335.670000000000016	USD	2025-06-29 07:44:34	processing
2025-12-29	642	131	162	5	445.480000000000018	RUB	2025-12-29 08:42:14	completed
2024-09-26	615	213	122	1	42.8400000000000034	EUR	2024-09-26 03:59:58	cancelled
2024-06-23	643	614	428	1	222.039999999999992	USD	2024-06-23 01:41:42	completed
2024-11-09	619	552	503	5	313.910000000000025	EUR	2024-11-09 00:38:26	completed
2024-06-02	644	576	379	2	388.730000000000018	USD	2024-06-02 00:02:46	cancelled
2025-01-28	621	252	346	1	232.800000000000011	RUB	2025-01-28 17:02:53	completed
2026-05-20	646	316	-1	4	199.189999999999998	RUB	2026-05-20 21:35:10	processing
2026-05-12	624	456	549	3	351.589999999999975	EUR	2026-05-12 18:48:52	processing
2026-04-26	647	574	94	5	77.2600000000000051	EUR	2026-04-26 21:43:09	processing
2025-10-13	625	0	301	5	250.639999999999986	EUR	2025-10-13 06:44:24	completed
2025-07-25	653	178	-1	3	322.910000000000025	USD	2025-07-25 09:03:33	processing
2025-08-19	627	498	310	2	388.509999999999991	USD	2025-08-19 15:49:14	completed
2024-06-06	654	346	496	4	193.75	EUR	2024-06-06 04:48:33	processing
2025-05-22	632	367	124	2	454.240000000000009	USD	2025-05-22 12:28:26	completed
2024-07-25	667	219	154	4	359.089999999999975	EUR	2024-07-25 21:05:02	processing
2026-05-03	637	492	102	4	244.349999999999994	USD	2026-05-03 15:52:01	completed
2025-08-22	668	394	211	1	275.220000000000027	EUR	2025-08-22 01:23:05	processing
2025-09-11	641	0	231	3	201.47999999999999	RUB	2025-09-11 08:52:23	processing
\N	674	354	92	4	364.850000000000023	EUR	\N	cancelled
2025-05-15	645	403	-1	3	158.710000000000008	RUB	2025-05-15 18:31:43	cancelled
2025-07-18	676	661	374	2	424.490000000000009	EUR	2025-07-18 13:06:29	completed
2024-06-26	659	321	43	3	382.45999999999998	USD	2024-06-26 18:51:58	completed
2026-02-01	680	587	434	2	151.240000000000009	EUR	2026-02-01 08:19:05	completed
2026-02-22	660	285	434	2	394.100000000000023	RUB	2026-02-22 06:26:13	completed
2024-11-20	681	0	104	5	359.139999999999986	USD	2024-11-20 17:23:00	cancelled
2024-05-31	661	41	284	1	64.5999999999999943	RUB	2024-05-31 05:15:51	cancelled
2026-01-22	683	547	279	1	169.47999999999999	USD	2026-01-22 09:55:27	processing
2025-02-11	665	128	170	2	128.590000000000003	RUB	2025-02-11 23:02:59	completed
2025-12-03	686	466	44	2	89.4200000000000017	RUB	2025-12-03 13:25:40	completed
2024-06-03	669	504	520	3	167.819999999999993	EUR	2024-06-03 21:07:34	processing
2026-04-11	687	387	405	5	401.430000000000007	RUB	2026-04-11 23:00:17	processing
2026-01-31	682	184	184	5	382.819999999999993	RUB	2026-01-31 17:24:40	completed
2026-05-05	690	512	306	1	303.899999999999977	EUR	2026-05-05 23:28:08	completed
2026-03-18	685	136	474	3	291.189999999999998	EUR	2026-03-18 16:09:20	completed
2026-03-16	694	478	53	2	237.02000000000001	EUR	2026-03-16 07:15:52	completed
2024-10-23	689	592	171	3	266.5	EUR	2024-10-23 18:27:58	processing
2025-04-20	695	150	477	3	193.280000000000001	EUR	2025-04-20 13:36:56	cancelled
2024-08-04	693	310	499	2	452.800000000000011	EUR	2024-08-04 15:45:42	cancelled
2025-01-25	712	255	372	1	351.720000000000027	RUB	2025-01-25 21:19:00	cancelled
2024-09-12	698	519	277	2	374.730000000000018	RUB	2024-09-12 10:15:50	completed
2025-05-03	714	68	158	1	223.460000000000008	EUR	2025-05-03 02:09:45	cancelled
2025-07-10	699	26	343	3	21.8299999999999983	EUR	2025-07-10 06:58:06	processing
2025-07-09	716	406	169	2	150.370000000000005	RUB	2025-07-09 22:19:07	cancelled
2025-03-09	704	0	199	2	105.299999999999997	RUB	2025-03-09 19:48:46	cancelled
2024-11-15	718	554	483	2	496	USD	2024-11-15 13:22:44	completed
2025-04-02	706	272	506	2	239.469999999999999	USD	2025-04-02 00:14:03	completed
2025-04-14	722	274	292	5	45.1199999999999974	RUB	2025-04-14 13:20:31	completed
2024-12-31	707	82	481	3	312.230000000000018	EUR	2024-12-31 18:19:55	cancelled
2024-06-05	728	-1	494	3	293.839999999999975	RUB	2024-06-05 21:56:08	cancelled
2026-05-22	717	164	9	1	59.3200000000000003	USD	2026-05-22 00:47:50	completed
2026-03-22	732	335	189	3	479.449999999999989	RUB	2026-03-22 19:26:53	completed
2024-06-02	719	34	366	3	342.579999999999984	RUB	2024-06-02 02:11:46	processing
2024-08-23	734	144	185	3	454.579999999999984	RUB	2024-08-23 20:52:03	cancelled
2024-08-10	724	509	167	1	202.759999999999991	EUR	2024-08-10 17:49:44	processing
2026-02-17	735	40	346	3	402.100000000000023	EUR	2026-02-17 09:59:57	completed
\N	743	461	549	1	479.730000000000018	EUR	\N	processing
2026-04-29	736	108	341	5	108.840000000000003	USD	2026-04-29 13:39:39	processing
2024-10-13	758	464	347	1	493.949999999999989	EUR	2024-10-13 17:13:32	cancelled
2025-08-25	737	675	-1	3	270.129999999999995	RUB	2025-08-25 04:23:35	processing
2025-04-30	759	8	-1	1	75.7000000000000028	USD	2025-04-30 03:40:43	processing
2024-11-04	739	298	418	1	149.400000000000006	USD	2024-11-04 21:07:02	processing
2025-03-18	760	575	349	4	252.22999999999999	RUB	2025-03-18 10:06:36	completed
2026-01-30	740	643	586	4	465.230000000000018	RUB	2026-01-30 21:29:18	completed
2025-01-29	763	157	77	1	487.810000000000002	EUR	2025-01-29 08:27:16	cancelled
2025-02-19	745	595	399	3	392.04000000000002	USD	2025-02-19 09:47:10	processing
2025-02-16	766	98	591	3	445.319999999999993	USD	2025-02-16 05:40:09	completed
2025-12-17	748	674	168	2	453.920000000000016	USD	2025-12-17 15:47:22	cancelled
2025-09-27	768	-1	305	5	155.629999999999995	RUB	2025-09-27 16:28:37	completed
2025-02-25	764	316	190	1	490.810000000000002	EUR	2025-02-25 07:13:26	processing
2025-10-08	769	414	276	4	55.5499999999999972	EUR	2025-10-08 09:20:32	processing
2024-12-08	767	597	555	3	162.629999999999995	RUB	2024-12-08 00:13:35	completed
2025-02-05	773	482	522	2	371.550000000000011	RUB	2025-02-05 14:28:00	completed
2024-07-15	774	0	193	3	292.579999999999984	RUB	2024-07-15 12:55:30	cancelled
2024-09-16	780	48	116	2	482.95999999999998	EUR	2024-09-16 01:02:56	processing
2025-09-18	776	353	276	4	456.269999999999982	EUR	2025-09-18 06:49:35	completed
2024-09-25	789	492	498	1	392.689999999999998	RUB	2024-09-25 22:13:42	cancelled
2025-07-13	782	148	421	1	435.70999999999998	EUR	2025-07-13 13:24:27	cancelled
2025-02-24	790	225	380	2	63.8100000000000023	RUB	2025-02-24 16:22:44	processing
2025-02-14	784	362	448	2	250.060000000000002	EUR	2025-02-14 00:37:22	completed
2025-01-05	796	644	99	5	286.95999999999998	EUR	2025-01-05 14:35:25	cancelled
2025-07-02	786	297	182	3	78.9399999999999977	EUR	2025-07-02 08:40:31	cancelled
2025-04-26	804	-1	222	1	463.850000000000023	EUR	2025-04-26 10:43:03	cancelled
2026-04-08	791	261	414	5	401.740000000000009	RUB	2026-04-08 05:52:38	completed
2024-07-17	816	21	596	5	237.789999999999992	USD	2024-07-17 15:16:50	completed
2026-02-01	793	570	509	5	461.699999999999989	RUB	2026-02-01 01:30:17	processing
2025-05-15	820	566	563	1	137.22999999999999	EUR	2025-05-15 00:28:19	completed
2025-06-11	795	199	-1	4	133.069999999999993	EUR	2025-06-11 11:45:45	completed
2025-10-06	823	698	28	1	26.2199999999999989	USD	2025-10-06 05:05:06	processing
2026-04-24	797	484	366	3	32.4399999999999977	EUR	2026-04-24 13:16:04	cancelled
2025-07-15	824	0	600	1	50.9799999999999969	USD	2025-07-15 15:29:35	completed
2025-12-17	799	579	548	1	110.430000000000007	EUR	2025-12-17 18:49:56	processing
2024-12-14	829	79	322	3	255.689999999999998	USD	2024-12-14 06:43:03	cancelled
2025-04-25	807	100	240	3	104.349999999999994	USD	2025-04-25 00:43:04	processing
2025-09-27	830	0	3	1	31.629999999999999	USD	2025-09-27 00:26:44	processing
2025-11-28	811	0	112	5	95.7999999999999972	EUR	2025-11-28 09:55:27	completed
2025-08-09	834	0	247	4	35.990000000000002	USD	2025-08-09 17:34:11	cancelled
2025-07-06	812	162	171	1	222.960000000000008	RUB	2025-07-06 17:38:30	cancelled
2026-05-18	836	539	402	3	402.980000000000018	USD	2026-05-18 01:53:43	cancelled
2025-12-05	813	-1	600	5	475.480000000000018	RUB	2025-12-05 14:23:39	cancelled
2026-05-11	838	265	255	5	474.740000000000009	EUR	2026-05-11 20:40:05	processing
2024-12-17	818	405	552	2	35.8900000000000006	USD	2024-12-17 17:02:42	completed
2024-12-08	845	235	197	5	344.759999999999991	EUR	2024-12-08 03:00:20	processing
2025-12-27	822	152	472	5	49.2800000000000011	EUR	2025-12-27 11:35:07	completed
2024-12-16	855	41	518	1	478.54000000000002	RUB	2024-12-16 19:13:02	cancelled
2025-11-12	847	590	112	1	388.300000000000011	RUB	2025-11-12 11:33:41	cancelled
2025-08-07	857	11	-1	1	498.660000000000025	USD	2025-08-07 08:54:22	completed
2025-05-02	849	138	39	1	340.100000000000023	EUR	2025-05-02 16:52:55	cancelled
2025-04-07	810	643	163	4	85.4300000000000068	USD	2025-04-07 16:59:47	cancelled
2025-06-12	850	-1	214	3	127.019999999999996	USD	2025-06-12 13:09:56	cancelled
2024-08-13	814	464	460	5	333.649999999999977	USD	2024-08-13 22:15:27	cancelled
2025-12-25	852	228	466	1	56.3400000000000034	RUB	2025-12-25 10:50:05	processing
2026-01-02	817	-1	574	5	475.29000000000002	USD	2026-01-02 01:44:12	cancelled
2025-07-06	858	343	14	2	420.420000000000016	RUB	2025-07-06 17:56:37	completed
2024-10-28	819	130	248	5	276.399999999999977	USD	2024-10-28 22:33:31	processing
2025-10-31	859	-1	-1	4	139.300000000000011	EUR	2025-10-31 09:41:40	completed
2025-02-07	821	0	92	2	78.4599999999999937	USD	2025-02-07 07:49:49	processing
2025-02-21	871	447	147	4	217.990000000000009	RUB	2025-02-21 05:05:28	processing
2025-10-26	827	118	164	3	378.740000000000009	EUR	2025-10-26 23:56:08	completed
\N	873	312	351	5	492.720000000000027	USD	\N	cancelled
2026-03-21	841	586	22	3	209.740000000000009	USD	2026-03-21 08:49:38	completed
2025-09-27	874	244	140	5	370.95999999999998	RUB	2025-09-27 21:16:37	cancelled
2024-08-14	842	430	318	5	221.139999999999986	USD	2024-08-14 03:02:45	cancelled
2025-10-02	875	48	105	5	364.689999999999998	USD	2025-10-02 22:03:02	processing
2025-03-26	844	364	192	3	434.470000000000027	USD	2025-03-26 13:01:18	cancelled
2024-06-01	876	380	378	5	412.910000000000025	RUB	2024-06-01 18:40:17	processing
2024-10-24	851	199	405	3	442.910000000000025	USD	2024-10-24 14:50:45	processing
2026-04-24	885	159	453	4	486.449999999999989	USD	2026-04-24 04:41:19	completed
2024-09-25	853	478	247	5	33.6799999999999997	USD	2024-09-25 06:29:39	processing
2025-08-04	891	564	16	4	318.870000000000005	USD	2025-08-04 03:53:51	processing
2025-06-11	854	94	331	2	76.0100000000000051	RUB	2025-06-11 11:15:14	completed
2024-08-01	892	494	322	2	385.579999999999984	RUB	2024-08-01 16:29:46	processing
2026-01-18	862	589	489	2	123.359999999999999	RUB	2026-01-18 11:03:21	cancelled
2026-03-05	893	345	409	3	423.220000000000027	EUR	2026-03-05 06:12:34	processing
2024-11-05	863	28	162	4	105.409999999999997	RUB	2024-11-05 03:28:58	completed
2024-06-29	895	31	527	2	10.4800000000000004	RUB	2024-06-29 05:13:53	cancelled
2026-03-08	864	622	346	2	231.129999999999995	EUR	2026-03-08 08:00:05	cancelled
2025-03-25	896	615	397	1	499.240000000000009	USD	2025-03-25 14:38:45	processing
2026-03-05	867	48	44	2	218.990000000000009	USD	2026-03-05 23:06:40	completed
2025-01-28	898	385	-1	3	49.25	RUB	2025-01-28 03:52:47	completed
2024-07-13	869	396	103	3	470.75	USD	2024-07-13 14:51:37	completed
2025-11-08	911	-1	302	3	33.4099999999999966	EUR	2025-11-08 23:12:52	processing
2025-04-08	872	216	119	3	377.339999999999975	USD	2025-04-08 22:16:53	completed
2024-10-15	913	210	146	4	240.5	USD	2024-10-15 23:55:47	cancelled
2025-12-22	878	597	-1	5	356.019999999999982	RUB	2025-12-22 11:59:03	cancelled
2025-08-19	914	512	95	2	46.8400000000000034	USD	2025-08-19 20:23:00	cancelled
2024-10-01	880	-1	303	4	53.9299999999999997	RUB	2024-10-01 01:17:06	completed
2025-11-25	917	249	419	2	276.319999999999993	EUR	2025-11-25 10:39:22	completed
2025-12-12	881	549	579	5	131.620000000000005	EUR	2025-12-12 15:57:41	completed
2025-03-27	921	386	358	2	98.4200000000000017	RUB	2025-03-27 22:54:20	cancelled
2024-08-26	884	578	572	4	314.889999999999986	USD	2024-08-26 21:03:41	cancelled
2024-07-19	925	548	296	4	315.480000000000018	RUB	2024-07-19 07:20:57	processing
2025-05-20	887	679	142	2	450.279999999999973	RUB	2025-05-20 00:06:53	processing
2025-08-07	926	17	-1	1	426.930000000000007	USD	2025-08-07 12:11:10	processing
2025-10-09	888	575	418	3	415.730000000000018	EUR	2025-10-09 18:24:16	processing
2025-09-13	931	184	553	4	201.340000000000003	USD	2025-09-13 22:24:40	processing
2026-01-21	897	207	50	5	174.069999999999993	USD	2026-01-21 09:03:07	completed
2025-09-14	932	0	-1	3	196.419999999999987	USD	2025-09-14 16:16:30	completed
2025-01-03	899	330	201	2	432.819999999999993	RUB	2025-01-03 16:16:59	processing
2026-02-18	936	0	276	2	190.650000000000006	RUB	2026-02-18 17:46:11	completed
2025-07-20	902	460	141	4	338.980000000000018	RUB	2025-07-20 03:23:27	cancelled
2024-09-02	940	404	253	5	154.139999999999986	RUB	2024-09-02 14:44:35	processing
2025-07-02	910	224	-1	5	155.400000000000006	EUR	2025-07-02 17:01:09	completed
2024-06-14	942	587	336	2	137.759999999999991	RUB	2024-06-14 13:29:12	completed
2026-01-19	912	45	243	3	149.530000000000001	USD	2026-01-19 23:33:35	cancelled
2025-12-22	945	623	109	2	431.620000000000005	RUB	2025-12-22 15:54:28	processing
2024-08-04	919	-1	63	1	232.25	RUB	2024-08-04 05:36:31	cancelled
2025-08-14	947	17	8	3	414.180000000000007	USD	2025-08-14 06:32:23	completed
2026-03-21	920	509	374	2	431.449999999999989	USD	2026-03-21 12:07:35	completed
2025-10-12	951	301	178	3	109.129999999999995	USD	2025-10-12 04:00:23	cancelled
2026-05-06	923	108	179	2	368.920000000000016	RUB	2026-05-06 23:12:27	completed
2025-10-12	953	437	154	1	480.300000000000011	EUR	2025-10-12 04:26:11	processing
2025-07-16	929	567	559	3	179.919999999999987	RUB	2025-07-16 17:05:55	processing
2026-03-16	956	62	133	4	13.3000000000000007	EUR	2026-03-16 08:55:38	completed
2024-05-26	934	154	158	4	257.839999999999975	RUB	2024-05-26 19:01:23	completed
2025-06-03	973	483	359	4	96.7000000000000028	USD	2025-06-03 04:26:34	cancelled
2025-05-21	938	468	181	1	92.2800000000000011	RUB	2025-05-21 00:13:26	processing
2024-06-21	979	30	220	5	478.04000000000002	RUB	2024-06-21 11:06:16	processing
2024-08-02	949	614	596	5	418.180000000000007	EUR	2024-08-02 10:44:44	completed
2026-01-22	980	422	600	4	401.70999999999998	RUB	2026-01-22 00:27:01	completed
2025-07-09	955	393	485	1	351.079999999999984	RUB	2025-07-09 06:05:30	processing
2024-11-26	988	510	532	3	77.75	RUB	2024-11-26 15:18:11	completed
2024-06-30	957	527	339	3	207.069999999999993	USD	2024-06-30 16:22:01	processing
2025-03-06	999	118	213	2	368.560000000000002	USD	2025-03-06 14:24:30	completed
2025-07-27	958	439	552	5	258.160000000000025	EUR	2025-07-27 22:37:38	cancelled
2025-12-24	1003	352	-1	4	466.879999999999995	USD	2025-12-24 07:55:07	processing
\N	962	439	160	1	442.420000000000016	USD	\N	cancelled
2025-04-27	1006	181	538	5	344.689999999999998	RUB	2025-04-27 19:37:07	completed
2025-07-07	963	382	135	2	45.6499999999999986	USD	2025-07-07 09:28:30	processing
2024-12-26	1009	390	583	1	404.629999999999995	USD	2024-12-26 15:19:45	processing
2024-08-18	968	300	172	1	73.5699999999999932	RUB	2024-08-18 20:26:23	cancelled
2025-12-24	1011	122	376	3	279.350000000000023	RUB	2025-12-24 13:08:32	cancelled
2025-09-13	970	137	8	2	307.220000000000027	RUB	2025-09-13 17:06:06	processing
2026-04-08	1013	145	166	4	70.3299999999999983	RUB	2026-04-08 01:02:26	cancelled
2024-06-13	975	389	93	1	169.460000000000008	RUB	2024-06-13 14:02:26	processing
2025-08-20	1015	-1	134	5	20.9699999999999989	USD	2025-08-20 20:05:12	completed
2025-10-02	976	686	402	5	128.129999999999995	USD	2025-10-02 14:32:30	completed
2026-03-14	1022	40	461	4	281.379999999999995	USD	2026-03-14 05:46:24	cancelled
2024-12-12	978	-1	597	2	463.639999999999986	RUB	2024-12-12 23:59:32	completed
2024-10-22	1023	283	558	2	217.659999999999997	USD	2024-10-22 23:41:40	completed
2024-08-27	983	570	475	1	249.659999999999997	RUB	2024-08-27 02:24:42	processing
2024-07-24	1031	448	66	2	48.6799999999999997	RUB	2024-07-24 12:34:40	processing
2025-08-30	986	458	585	5	225.009999999999991	USD	2025-08-30 17:12:19	completed
2024-08-31	1035	671	577	5	43.2899999999999991	RUB	2024-08-31 02:14:43	processing
2024-10-14	989	134	407	1	76.0100000000000051	EUR	2024-10-14 15:21:29	processing
2025-02-17	1036	-1	68	1	164.370000000000005	RUB	2025-02-17 00:25:49	cancelled
2025-09-20	992	358	190	3	337	EUR	2025-09-20 04:53:29	completed
2024-07-06	1044	442	53	2	22.8900000000000006	EUR	2024-07-06 03:28:28	processing
2025-09-10	995	167	24	5	450.279999999999973	USD	2025-09-10 04:39:16	completed
2024-08-13	1047	379	599	5	261.350000000000023	RUB	2024-08-13 02:39:28	cancelled
2025-02-11	997	311	202	5	104.5	RUB	2025-02-11 07:13:23	completed
2025-03-22	1048	151	551	4	481.629999999999995	RUB	2025-03-22 04:05:06	processing
2025-04-01	1000	121	143	4	210.949999999999989	RUB	2025-04-01 13:56:00	completed
2024-08-26	1049	641	560	5	24.9600000000000009	USD	2024-08-26 11:26:53	cancelled
2025-12-20	1008	385	359	5	104.890000000000001	EUR	2025-12-20 08:05:31	processing
2026-01-01	1063	0	365	1	199.110000000000014	USD	2026-01-01 14:28:01	processing
2025-12-10	1017	647	128	3	25.870000000000001	USD	2025-12-10 17:09:32	completed
2024-06-28	1064	249	515	5	277.889999999999986	USD	2024-06-28 11:40:03	processing
2025-01-18	1019	434	357	1	191.740000000000009	RUB	2025-01-18 04:51:55	cancelled
2024-09-10	1067	23	-1	3	46.1899999999999977	USD	2024-09-10 01:10:47	processing
2025-01-09	1024	530	-1	3	229.400000000000006	USD	2025-01-09 23:13:27	completed
2025-10-17	1068	255	210	5	323.649999999999977	USD	2025-10-17 07:23:18	processing
2024-11-12	1027	295	411	3	251.099999999999994	USD	2024-11-12 08:58:56	completed
2025-12-09	1071	369	128	3	252.840000000000003	EUR	2025-12-09 07:54:12	processing
2024-07-28	1029	693	31	4	302.120000000000005	EUR	2024-07-28 10:43:18	completed
2026-05-10	1073	427	67	4	449.319999999999993	RUB	2026-05-10 05:01:40	processing
2026-01-20	1042	331	297	5	338.170000000000016	RUB	2026-01-20 16:02:13	processing
2024-09-06	1074	130	43	5	378.970000000000027	RUB	2024-09-06 15:57:17	processing
2025-12-18	1045	472	57	2	61.7899999999999991	EUR	2025-12-18 19:57:50	completed
2025-10-31	1079	634	93	5	196.77000000000001	EUR	2025-10-31 07:18:09	cancelled
\N	1046	677	86	3	56.5900000000000034	RUB	\N	completed
2024-06-22	1081	614	391	4	497.399999999999977	USD	2024-06-22 09:11:06	processing
2026-04-23	1050	267	535	1	231.129999999999995	EUR	2026-04-23 09:21:08	processing
2026-04-27	1082	46	64	1	217.02000000000001	RUB	2026-04-27 09:55:30	completed
2026-04-18	1051	239	553	5	193.159999999999997	USD	2026-04-18 23:23:18	completed
2025-03-18	1083	611	255	4	111.5	EUR	2025-03-18 05:07:35	cancelled
2025-02-01	1057	603	595	3	453.310000000000002	USD	2025-02-01 01:02:58	cancelled
2025-12-31	1108	-1	462	5	369.389999999999986	USD	2025-12-31 11:56:38	cancelled
2025-02-06	1065	228	447	5	121.700000000000003	USD	2025-02-06 02:35:51	completed
2025-01-08	1110	0	174	5	274.060000000000002	RUB	2025-01-08 12:53:21	completed
2026-04-01	1066	265	70	5	228.139999999999986	RUB	2026-04-01 03:23:13	cancelled
2025-06-04	1118	-1	127	3	128.050000000000011	RUB	2025-06-04 06:25:14	completed
2025-10-25	1077	638	433	4	474.120000000000005	RUB	2025-10-25 14:21:31	processing
2025-11-05	1119	550	396	3	438.329999999999984	RUB	2025-11-05 13:15:38	processing
2025-01-24	1080	349	139	1	64.2199999999999989	RUB	2025-01-24 14:43:20	processing
2024-12-12	1120	582	-1	5	262.100000000000023	USD	2024-12-12 18:32:49	completed
2025-06-02	1084	-1	-1	5	137.349999999999994	EUR	2025-06-02 20:38:05	completed
2025-11-05	1138	93	458	2	493.519999999999982	USD	2025-11-05 07:01:48	processing
2024-10-21	1089	373	462	5	447.310000000000002	RUB	2024-10-21 12:53:37	cancelled
2026-05-12	1147	573	567	1	158.340000000000003	USD	2026-05-12 23:24:13	completed
2025-02-09	1098	486	131	4	358.370000000000005	RUB	2025-02-09 07:18:17	completed
2025-10-13	1161	494	94	5	324.329999999999984	USD	2025-10-13 21:59:25	completed
2024-10-12	1101	151	235	1	109.909999999999997	EUR	2024-10-12 23:22:19	processing
2026-02-25	1170	219	47	1	27.4100000000000001	EUR	2026-02-25 10:40:32	completed
2025-11-19	1102	491	50	5	367.449999999999989	RUB	2025-11-19 08:12:59	cancelled
2024-06-19	1172	304	248	3	224.550000000000011	RUB	2024-06-19 02:27:30	cancelled
2026-03-14	1107	199	-1	4	149.879999999999995	RUB	2026-03-14 15:39:54	processing
2025-11-18	1178	407	342	1	301.089999999999975	RUB	2025-11-18 02:52:05	cancelled
2024-08-03	1109	408	171	3	326.079999999999984	RUB	2024-08-03 02:27:12	cancelled
2025-11-02	1179	0	-1	3	368	RUB	2025-11-02 19:11:51	completed
2024-07-23	1117	216	223	1	242.800000000000011	RUB	2024-07-23 17:33:24	cancelled
2026-04-16	1183	240	182	3	352.329999999999984	USD	2026-04-16 01:41:40	completed
2025-11-26	1123	391	232	2	453.230000000000018	RUB	2025-11-26 01:26:07	processing
2025-12-22	1190	403	13	2	485.220000000000027	RUB	2025-12-22 07:47:52	completed
2026-03-07	1127	0	17	2	122.709999999999994	USD	2026-03-07 00:44:43	completed
2025-08-04	1195	371	592	4	482.240000000000009	RUB	2025-08-04 02:45:44	completed
2024-11-11	1129	612	12	4	360.279999999999973	USD	2024-11-11 22:13:51	processing
2024-10-07	1197	450	274	2	498.100000000000023	RUB	2024-10-07 02:29:27	processing
2024-07-09	1131	241	88	3	328.439999999999998	RUB	2024-07-09 02:47:20	processing
2026-04-05	1199	595	503	2	20.0500000000000007	EUR	2026-04-05 13:51:16	cancelled
2024-09-03	1133	323	101	5	165.030000000000001	RUB	2024-09-03 09:37:09	completed
2026-03-26	825	85	381	1	225.099999999999994	RUB	2026-03-26 00:08:34	completed
2025-02-26	1135	379	389	3	476.720000000000027	RUB	2025-02-26 21:52:54	cancelled
2025-02-18	828	559	503	5	274.610000000000014	EUR	2025-02-18 01:54:55	processing
2025-11-16	1139	332	481	5	141.740000000000009	RUB	2025-11-16 13:38:53	completed
2025-04-24	835	617	-1	5	183.990000000000009	USD	2025-04-24 05:59:23	processing
2024-09-02	1141	208	-1	5	365.550000000000011	RUB	2024-09-02 05:33:05	cancelled
2025-04-22	837	542	-1	5	371.870000000000005	EUR	2025-04-22 00:21:06	processing
2024-10-05	1151	661	142	5	359.259999999999991	EUR	2024-10-05 06:16:14	cancelled
2024-11-22	839	199	275	5	327.389999999999986	EUR	2024-11-22 16:00:48	completed
2025-02-06	1152	273	77	4	173.789999999999992	RUB	2025-02-06 04:35:34	cancelled
2024-09-17	840	159	175	4	313.350000000000023	EUR	2024-09-17 20:19:08	processing
2025-08-20	1154	108	327	3	192.699999999999989	USD	2025-08-20 08:54:15	cancelled
2025-11-16	843	85	400	4	152.900000000000006	RUB	2025-11-16 07:43:07	completed
2025-12-27	1156	-1	225	1	41.0499999999999972	EUR	2025-12-27 17:40:44	processing
2025-08-28	846	24	298	3	211.47999999999999	EUR	2025-08-28 00:14:23	processing
2024-06-16	1158	182	287	5	170.77000000000001	RUB	2024-06-16 17:58:12	completed
2025-11-11	848	248	340	2	416.899999999999977	EUR	2025-11-11 18:09:33	processing
2024-06-10	1164	584	-1	4	44.7299999999999969	EUR	2024-06-10 19:10:40	cancelled
2024-06-27	856	336	538	5	430.610000000000014	RUB	2024-06-27 09:03:08	completed
2024-06-19	1165	0	89	3	453.95999999999998	RUB	2024-06-19 18:38:58	processing
2025-04-28	860	-1	377	5	343.259999999999991	EUR	2025-04-28 07:05:10	processing
2024-08-30	1167	535	353	5	114.540000000000006	EUR	2024-08-30 05:41:08	completed
2025-12-13	861	355	539	3	305.810000000000002	USD	2025-12-13 21:25:28	processing
2026-01-19	1174	440	307	2	494.970000000000027	EUR	2026-01-19 22:43:28	processing
2025-04-22	866	44	439	3	126.450000000000003	EUR	2025-04-22 15:45:31	cancelled
\N	1181	616	456	3	404.670000000000016	RUB	\N	processing
2024-08-17	868	57	91	4	204.939999999999998	RUB	2024-08-17 09:02:01	completed
2024-07-10	1182	399	-1	2	320.579999999999984	EUR	2024-07-10 05:33:32	cancelled
2026-03-22	877	595	464	3	291.300000000000011	USD	2026-03-22 07:49:21	cancelled
2024-07-12	1184	85	366	3	394.620000000000005	RUB	2024-07-12 22:59:06	completed
2025-09-28	883	111	441	2	154.27000000000001	USD	2025-09-28 03:14:20	cancelled
2026-01-22	1185	11	346	1	48.6799999999999997	USD	2026-01-22 13:05:54	completed
2024-08-31	889	121	31	5	308.899999999999977	EUR	2024-08-31 20:25:12	processing
2025-09-14	1188	454	363	4	301.529999999999973	USD	2025-09-14 22:40:29	processing
2025-11-11	900	454	287	1	367.689999999999998	USD	2025-11-11 22:58:12	cancelled
2025-06-20	1189	605	50	2	336.550000000000011	USD	2025-06-20 09:34:36	completed
2025-01-20	901	18	60	5	147.939999999999998	USD	2025-01-20 06:05:43	processing
2025-03-31	1198	697	296	2	334.480000000000018	RUB	2025-03-31 06:21:29	cancelled
2025-03-22	903	20	394	4	365.240000000000009	EUR	2025-03-22 10:38:14	completed
2025-06-21	1200	387	165	3	170.759999999999991	USD	2025-06-21 19:11:34	processing
2025-04-19	904	165	24	1	386.870000000000005	EUR	2025-04-19 08:12:33	cancelled
\N	-1	-1	-1	0	0	Unknown	\N	Unknown
2025-12-04	905	537	238	2	107.239999999999995	EUR	2025-12-04 08:42:18	completed
2025-10-20	865	79	418	3	73.730000000000004	RUB	2025-10-20 21:34:14	processing
2025-07-20	906	136	112	2	109.280000000000001	EUR	2025-07-20 09:36:09	cancelled
2026-03-19	870	224	564	1	410.519999999999982	RUB	2026-03-19 23:12:04	completed
2026-03-01	907	558	105	2	426.279999999999973	USD	2026-03-01 13:46:33	completed
2025-06-16	879	640	-1	3	416.839999999999975	RUB	2025-06-16 01:54:49	processing
2025-03-20	909	326	125	5	488.449999999999989	EUR	2025-03-20 04:05:57	completed
2024-07-16	882	0	180	3	289.050000000000011	USD	2024-07-16 14:09:01	completed
2025-01-16	915	604	176	2	137.939999999999998	EUR	2025-01-16 03:11:05	processing
2024-11-26	886	222	334	2	264.800000000000011	USD	2024-11-26 10:10:27	processing
2024-11-14	922	691	553	3	17.2699999999999996	EUR	2024-11-14 02:45:31	cancelled
2024-08-04	890	151	273	5	341.509999999999991	EUR	2024-08-04 16:08:24	completed
2025-06-26	924	585	571	4	379.930000000000007	USD	2025-06-26 06:00:33	processing
2024-09-11	894	153	-1	3	426.379999999999995	EUR	2024-09-11 22:55:03	completed
2024-07-28	927	-1	257	4	487.75	RUB	2024-07-28 02:50:13	processing
2025-03-29	908	618	526	2	377.670000000000016	USD	2025-03-29 07:49:55	processing
2025-09-18	928	299	-1	5	175.47999999999999	RUB	2025-09-18 10:58:43	processing
2025-11-23	916	560	238	5	224.590000000000003	EUR	2025-11-23 11:46:15	processing
2025-09-03	933	-1	394	4	309.110000000000014	EUR	2025-09-03 21:53:38	processing
2026-01-05	918	347	-1	1	251.47999999999999	RUB	2026-01-05 17:15:11	processing
2025-10-11	935	328	326	1	397.360000000000014	RUB	2025-10-11 04:05:43	processing
2026-02-19	930	469	94	1	350.689999999999998	EUR	2026-02-19 16:33:32	cancelled
2024-09-30	937	680	340	4	196.659999999999997	RUB	2024-09-30 16:00:21	processing
2024-08-01	939	351	472	2	467.769999999999982	EUR	2024-08-01 13:28:11	processing
2025-03-28	946	-1	573	4	264.279999999999973	EUR	2025-03-28 04:41:51	cancelled
2025-10-05	941	137	200	3	396.870000000000005	USD	2025-10-05 19:27:36	processing
2025-05-13	948	314	116	5	413.920000000000016	USD	2025-05-13 07:01:10	cancelled
2026-05-02	943	546	399	4	97.1700000000000017	EUR	2026-05-02 09:39:41	completed
2024-12-15	952	635	100	4	366.639999999999986	RUB	2024-12-15 11:19:18	completed
2025-07-31	944	590	352	2	435.480000000000018	USD	2025-07-31 01:42:53	processing
2025-03-14	954	659	182	1	27.2399999999999984	EUR	2025-03-14 18:48:39	cancelled
2025-10-06	950	276	91	3	112.989999999999995	EUR	2025-10-06 13:02:45	cancelled
2024-10-05	959	287	346	4	355.990000000000009	RUB	2024-10-05 14:01:19	processing
2025-03-27	960	686	325	5	216.759999999999991	EUR	2025-03-27 12:21:18	processing
2025-06-07	964	119	349	1	112.090000000000003	EUR	2025-06-07 14:55:03	cancelled
2025-08-25	961	629	85	3	479.420000000000016	USD	2025-08-25 08:48:14	processing
2024-12-22	965	35	103	4	282.220000000000027	USD	2024-12-22 13:41:39	cancelled
2026-02-02	966	311	-1	5	197.699999999999989	RUB	2026-02-02 09:47:05	processing
2025-10-03	967	503	452	2	217.310000000000002	RUB	2025-10-03 23:08:29	processing
2026-04-21	971	313	251	1	443.889999999999986	RUB	2026-04-21 11:19:54	cancelled
2025-05-23	969	295	557	5	117.030000000000001	USD	2025-05-23 23:59:39	completed
2025-10-05	977	563	65	1	326.259999999999991	USD	2025-10-05 23:48:55	cancelled
2025-09-01	972	269	546	5	236.960000000000008	USD	2025-09-01 13:57:29	completed
2025-08-06	981	656	333	2	125.859999999999999	USD	2025-08-06 22:51:56	processing
2025-12-24	974	476	496	3	285.399999999999977	EUR	2025-12-24 08:08:16	completed
2024-08-12	982	373	209	5	429.29000000000002	RUB	2024-08-12 09:23:09	cancelled
2025-04-08	984	505	585	3	131.099999999999994	USD	2025-04-08 07:24:44	cancelled
2026-02-24	985	268	120	4	309.490000000000009	RUB	2026-02-24 02:37:03	completed
2026-04-26	990	-1	272	2	28.4499999999999993	USD	2026-04-26 20:04:53	processing
2025-12-21	987	451	480	2	336.689999999999998	RUB	2025-12-21 22:08:23	processing
2026-05-05	993	653	310	1	108.980000000000004	EUR	2026-05-05 07:06:27	completed
2025-10-03	991	501	583	4	264.129999999999995	RUB	2025-10-03 17:08:42	cancelled
2026-02-10	1001	118	413	1	66.8100000000000023	EUR	2026-02-10 07:31:42	completed
2025-12-24	994	398	69	5	167.159999999999997	EUR	2025-12-24 01:02:05	cancelled
2025-05-29	1004	-1	214	2	221.409999999999997	EUR	2025-05-29 20:37:07	processing
2026-05-03	996	659	25	5	377.149999999999977	RUB	2026-05-03 18:01:38	completed
2024-07-27	1005	14	154	3	390.560000000000002	USD	2024-07-27 04:40:49	cancelled
2026-01-06	998	591	96	2	346.519999999999982	EUR	2026-01-06 20:28:54	processing
2024-07-02	1010	354	235	4	413.509999999999991	USD	2024-07-02 22:10:03	cancelled
2025-01-20	1002	133	140	5	363.620000000000005	EUR	2025-01-20 17:41:32	processing
2025-03-10	1012	315	160	1	137.090000000000003	USD	2025-03-10 03:27:19	completed
2026-03-15	1007	346	-1	3	491.170000000000016	USD	2026-03-15 09:37:24	cancelled
2026-05-20	1014	237	454	2	303.54000000000002	USD	2026-05-20 16:16:56	processing
2025-06-19	1020	292	141	2	133.129999999999995	USD	2025-06-19 13:23:57	cancelled
2025-09-27	1016	289	163	1	177.77000000000001	EUR	2025-09-27 11:13:16	processing
2024-06-22	1021	473	527	5	39.1099999999999994	USD	2024-06-22 03:47:55	completed
2025-06-27	1018	631	463	4	286.569999999999993	RUB	2025-06-27 13:02:53	cancelled
\N	1028	117	545	5	223.199999999999989	EUR	\N	processing
2025-02-06	1025	-1	521	1	237.090000000000003	USD	2025-02-06 01:41:22	completed
2025-11-29	1032	247	273	4	19.3000000000000007	USD	2025-11-29 23:04:13	cancelled
2025-08-28	1026	419	82	4	359.180000000000007	EUR	2025-08-28 17:47:48	completed
2025-02-01	1033	425	70	3	317.149999999999977	USD	2025-02-01 05:32:51	completed
2026-04-07	1030	124	451	2	307.410000000000025	USD	2026-04-07 08:14:51	cancelled
2026-05-21	1038	613	505	4	393.829999999999984	RUB	2026-05-21 15:26:19	processing
2025-07-08	1034	52	39	4	70.9200000000000017	EUR	2025-07-08 07:45:33	completed
2025-02-02	1039	230	425	5	225.120000000000005	USD	2025-02-02 20:10:39	cancelled
2025-04-20	1037	0	305	5	28.5700000000000003	RUB	2025-04-20 09:43:45	processing
2025-05-12	1052	64	485	1	215.210000000000008	EUR	2025-05-12 08:19:06	processing
2024-11-24	1040	618	153	4	454.95999999999998	USD	2024-11-24 09:23:05	completed
2025-05-07	1053	96	307	2	196.319999999999993	USD	2025-05-07 03:49:57	processing
2025-02-26	1041	497	239	4	289.800000000000011	USD	2025-02-26 07:23:26	completed
2024-06-06	1056	-1	274	4	335.649999999999977	USD	2024-06-06 03:05:37	completed
2025-03-26	1043	583	271	4	405.439999999999998	USD	2025-03-26 00:50:30	completed
2024-07-13	1058	116	500	5	324.740000000000009	USD	2024-07-13 23:50:56	cancelled
2026-03-22	1054	413	512	1	467.730000000000018	RUB	2026-03-22 13:18:44	processing
2026-02-01	1069	418	192	4	448.279999999999973	EUR	2026-02-01 08:15:30	completed
2024-10-01	1055	605	155	4	284.25	RUB	2024-10-01 07:52:11	cancelled
2025-04-06	1072	100	29	2	351.54000000000002	EUR	2025-04-06 03:17:32	processing
2024-11-02	1059	691	387	5	119.819999999999993	RUB	2024-11-02 06:59:33	cancelled
2025-06-29	1075	555	149	4	236.25	RUB	2025-06-29 09:19:19	completed
2025-01-07	1060	110	47	4	99.0499999999999972	RUB	2025-01-07 20:10:37	processing
2024-12-21	1078	680	406	2	352.449999999999989	RUB	2024-12-21 18:52:52	processing
2024-12-15	1061	432	255	5	194.389999999999986	RUB	2024-12-15 11:07:08	processing
2025-07-28	1086	306	385	2	33.009999999999998	EUR	2025-07-28 22:41:45	processing
2024-10-11	1062	272	156	3	232	EUR	2024-10-11 20:13:46	completed
2025-06-15	1087	281	510	5	310.560000000000002	EUR	2025-06-15 05:35:10	cancelled
2026-02-25	1070	45	23	5	56.25	EUR	2026-02-25 10:08:08	completed
2024-07-06	1090	327	436	5	404.579999999999984	USD	2024-07-06 13:20:08	completed
2026-01-16	1076	279	232	5	425.420000000000016	USD	2026-01-16 08:10:48	cancelled
2025-07-03	1091	249	-1	4	439.180000000000007	USD	2025-07-03 05:15:31	completed
2026-05-02	1085	389	309	5	331.470000000000027	RUB	2026-05-02 18:23:33	completed
2024-08-03	1092	429	-1	1	204.280000000000001	EUR	2024-08-03 18:33:02	processing
2025-03-08	1088	52	323	2	17.0300000000000011	EUR	2025-03-08 12:25:00	cancelled
2024-05-27	1094	156	486	4	219.810000000000002	EUR	2024-05-27 09:02:57	cancelled
2024-07-30	1093	356	122	4	88.5300000000000011	USD	2024-07-30 15:51:34	completed
2025-02-21	1096	288	258	3	456.25	RUB	2025-02-21 01:39:43	processing
2025-03-24	1095	411	81	1	201.169999999999987	USD	2025-03-24 11:17:16	completed
2025-01-23	1104	318	371	2	256.699999999999989	EUR	2025-01-23 18:51:03	cancelled
2024-09-13	1097	530	16	1	382.639999999999986	RUB	2024-09-13 17:26:36	completed
2025-03-24	1105	0	293	3	159.699999999999989	EUR	2025-03-24 15:30:55	processing
2024-08-01	1099	82	280	3	227.599999999999994	USD	2024-08-01 23:32:52	cancelled
2024-06-11	1106	479	115	2	424.300000000000011	USD	2024-06-11 20:53:41	completed
2025-12-28	1100	139	436	3	427.839999999999975	RUB	2025-12-28 04:17:26	completed
\N	1111	487	-1	5	39.7800000000000011	USD	\N	cancelled
2025-11-01	1103	568	527	2	190.560000000000002	EUR	2025-11-01 10:33:12	completed
2024-11-21	1114	0	406	1	262.199999999999989	RUB	2024-11-21 02:01:19	cancelled
2026-04-10	1112	253	236	2	26.2699999999999996	RUB	2026-04-10 14:46:21	cancelled
2025-03-04	1125	676	216	2	472.410000000000025	RUB	2025-03-04 11:16:27	completed
2025-12-06	1113	-1	339	3	315.819999999999993	USD	2025-12-06 20:01:43	completed
2025-08-12	1126	530	172	5	282.949999999999989	USD	2025-08-12 17:16:34	completed
2025-07-22	1115	486	177	1	422.850000000000023	EUR	2025-07-22 16:25:49	cancelled
2025-07-25	1128	-1	521	4	66.1599999999999966	USD	2025-07-25 07:08:17	processing
2024-06-15	1116	261	55	3	138.210000000000008	EUR	2024-06-15 00:19:50	processing
2024-09-03	1136	77	400	1	223.599999999999994	RUB	2024-09-03 19:08:10	cancelled
2025-05-14	1121	314	108	5	354.509999999999991	EUR	2025-05-14 00:03:38	cancelled
2025-08-26	1140	536	430	5	382.5	EUR	2025-08-26 14:34:25	processing
2024-06-10	1122	461	-1	2	27.8500000000000014	USD	2024-06-10 09:04:48	processing
2026-05-05	1145	584	90	5	126.010000000000005	USD	2026-05-05 07:39:57	completed
2026-04-04	1124	461	116	5	398.25	USD	2026-04-04 03:00:49	processing
2024-12-27	1148	586	344	1	394.139999999999986	EUR	2024-12-27 00:47:36	processing
2024-06-08	1130	86	64	4	400.45999999999998	EUR	2024-06-08 21:10:24	processing
2025-12-08	1149	322	93	4	233.889999999999986	RUB	2025-12-08 20:59:05	processing
2025-11-30	1132	523	142	3	216.360000000000014	RUB	2025-11-30 06:25:14	completed
2025-09-07	1153	55	273	3	363.29000000000002	EUR	2025-09-07 10:02:12	completed
2025-04-21	1134	4	187	1	233.949999999999989	EUR	2025-04-21 11:10:08	completed
2025-08-07	1155	518	509	2	71.9000000000000057	EUR	2025-08-07 03:44:08	completed
\N	1137	276	89	4	458.910000000000025	EUR	\N	processing
2026-04-03	1159	60	269	5	99.5600000000000023	RUB	2026-04-03 19:31:19	processing
2024-07-31	1142	164	444	1	268.699999999999989	RUB	2024-07-31 21:53:17	processing
\N	1162	589	89	2	423.480000000000018	USD	\N	cancelled
2025-08-04	1143	569	497	1	241.509999999999991	RUB	2025-08-04 17:46:43	processing
2025-07-04	1163	191	452	1	374.5	USD	2025-07-04 16:31:03	completed
2025-03-01	1144	75	465	5	220.090000000000003	EUR	2025-03-01 18:47:50	completed
2024-10-19	1166	588	145	3	352.569999999999993	USD	2024-10-19 08:24:52	processing
2025-09-01	1146	442	535	3	232.72999999999999	RUB	2025-09-01 23:56:15	processing
2026-05-03	1168	610	91	1	212.580000000000013	RUB	2026-05-03 12:10:11	processing
2025-08-19	1150	142	555	2	394.189999999999998	USD	2025-08-19 05:19:01	processing
2025-06-21	1171	361	71	4	118.670000000000002	USD	2025-06-21 02:53:48	cancelled
2025-11-04	1157	351	286	4	94.1200000000000045	USD	2025-11-04 15:01:05	cancelled
2025-04-15	1173	156	40	3	489.720000000000027	EUR	2025-04-15 06:52:56	processing
2025-07-11	1160	464	383	4	45.5200000000000031	RUB	2025-07-11 19:17:27	completed
2026-05-18	1180	240	398	1	236.719999999999999	RUB	2026-05-18 18:06:53	completed
2026-02-03	1169	-1	552	4	109.069999999999993	EUR	2026-02-03 10:59:34	completed
2026-05-24	1186	-1	-1	3	483.639999999999986	RUB	2026-05-24 07:08:36	cancelled
2024-06-18	1175	516	392	2	165.780000000000001	USD	2024-06-18 07:07:28	processing
2024-08-12	1191	-1	220	3	180.620000000000005	USD	2024-08-12 07:21:38	cancelled
2024-12-01	1176	306	457	1	172.120000000000005	USD	2024-12-01 09:59:14	cancelled
2024-10-12	1192	47	308	3	41.5600000000000023	RUB	2024-10-12 10:06:51	processing
2024-06-06	1177	284	82	4	313.740000000000009	EUR	2024-06-06 10:47:58	cancelled
2026-02-07	1193	629	179	3	441.449999999999989	RUB	2026-02-07 07:43:28	processing
2025-10-07	1187	451	505	1	224.650000000000006	USD	2025-10-07 14:05:34	completed
2026-03-09	1196	0	397	5	38.8100000000000023	RUB	2026-03-09 12:42:55	processing
2024-07-14	1194	368	151	3	346.149999999999977	EUR	2024-07-14 18:30:30	completed
\.


--
-- TOC entry 2537 (class 0 OID 49499)
-- Dependencies: 278
-- Data for Name: fact_payments; Type: TABLE DATA; Schema: fact; Owner: gpadmin
--

COPY fact.fact_payments (date_id, payment_id, order_id, payment_method, amount, currency, payment_timestamp) FROM stdin;
2026-01-01	7	239	card	\N	EUR	2026-01-01 19:45:57
2024-12-15	2	941	bank_transfer	407.420000000000016	USD	2024-12-15 23:01:24
2025-05-05	8	14	bank_transfer	1189.8900000000001	RUB	2025-05-05 22:59:37
2025-05-03	3	1173	paypal	1754.70000000000005	USD	2025-05-03 14:55:30
2025-06-15	16	351	card	2873.15999999999985	EUR	2025-06-15 23:48:07
2026-02-05	4	143	card	2372.03999999999996	RUB	2026-02-05 00:19:38
2026-01-24	19	1128	card	1320.8599999999999	RUB	2026-01-24 15:22:18
2025-02-03	6	1139	\N	747.970000000000027	RUB	2025-02-03 15:11:50
2024-06-03	27	319	card	2781.32999999999993	EUR	2024-06-03 07:38:28
2025-01-18	9	685	\N	1016.84000000000003	EUR	2025-01-18 04:06:47
2026-02-16	29	738	paypal	2583.55999999999995	RUB	2026-02-16 04:26:00
2026-02-22	10	-1	\N	2574.48999999999978	EUR	2026-02-22 05:19:19
2025-10-09	32	261	card	409.139999999999986	USD	2025-10-09 13:32:24
2025-01-07	13	949	card	1074.08999999999992	RUB	2025-01-07 20:58:25
2026-05-08	33	268	card	1131.32999999999993	EUR	2026-05-08 21:31:05
2025-10-17	18	218	card	32.740000000000002	RUB	2025-10-17 19:21:28
2025-09-23	34	404	card	1019.69000000000005	RUB	2025-09-23 11:17:29
2025-09-23	21	104	bank_transfer	2078.38000000000011	USD	2025-09-23 21:42:47
2024-07-28	37	-1	card	2308.36000000000013	EUR	2024-07-28 14:15:10
2024-07-18	22	443	card	1446.68000000000006	RUB	2024-07-18 23:21:20
2025-11-06	42	832	bank_transfer	\N	EUR	2025-11-06 01:02:23
2026-03-08	24	637	card	2415.03999999999996	RUB	2026-03-08 22:16:13
2024-07-10	53	638	card	1875.86999999999989	RUB	2024-07-10 20:15:09
2025-03-20	28	433	paypal	284.269999999999982	RUB	2025-03-20 01:06:42
2024-06-17	54	412	bank_transfer	1810.33999999999992	USD	2024-06-17 00:06:44
2025-05-15	39	326	paypal	1146.79999999999995	USD	2025-05-15 02:28:16
2026-04-27	58	1023	\N	2125.09000000000015	USD	2026-04-27 09:27:34
2025-12-25	41	167	paypal	1867.8599999999999	USD	2025-12-25 13:45:44
2026-05-12	65	-1	bank_transfer	1615.75	RUB	2026-05-12 00:42:23
2025-11-20	43	84	\N	2527.48000000000002	USD	2025-11-20 00:26:28
2025-01-22	67	619	\N	2363.84999999999991	USD	2025-01-22 03:21:59
2025-06-14	45	522	bank_transfer	1097.77999999999997	RUB	2025-06-14 09:43:41
2026-05-18	73	38	card	1980.20000000000005	RUB	2026-05-18 04:03:38
2025-01-11	51	1052	card	2027.04999999999995	RUB	2025-01-11 10:26:59
2024-09-08	77	1036	\N	852.490000000000009	EUR	2024-09-08 22:03:27
2025-11-20	55	577	\N	2664.34000000000015	USD	2025-11-20 03:29:14
2025-02-06	80	911	\N	2628.42999999999984	EUR	2025-02-06 20:18:39
2026-01-16	59	957	\N	1134.1099999999999	RUB	2026-01-16 07:43:35
2025-07-02	81	833	paypal	413.529999999999973	USD	2025-07-02 21:33:06
2025-08-03	60	929	\N	1699.86999999999989	RUB	2025-08-03 09:21:52
2024-09-22	84	312	\N	1567.04999999999995	RUB	2024-09-22 21:58:55
2026-05-05	62	555	\N	2901.82000000000016	EUR	2026-05-05 01:49:12
2025-08-14	93	357	card	1855.52999999999997	EUR	2025-08-14 09:54:38
2024-08-02	66	-1	paypal	280.860000000000014	EUR	2024-08-02 07:40:39
2025-05-30	99	1134	paypal	1075.57999999999993	RUB	2025-05-30 06:15:36
2025-03-01	70	543	paypal	385.170000000000016	USD	2025-03-01 02:53:57
2024-08-27	101	537	bank_transfer	2385.38999999999987	EUR	2024-08-27 23:41:32
2026-02-20	75	1125	\N	443.420000000000016	USD	2026-02-20 20:26:08
2024-08-21	102	269	paypal	1445.8599999999999	USD	2024-08-21 17:56:48
2026-04-26	82	96	bank_transfer	1414.73000000000002	USD	2026-04-26 15:25:23
2025-03-10	110	646	paypal	331.529999999999973	RUB	2025-03-10 18:25:03
2025-01-07	90	1179	\N	2721.32000000000016	USD	2025-01-07 01:34:02
2025-01-29	112	358	\N	2667.67000000000007	RUB	2025-01-29 08:06:20
2025-04-18	92	907	paypal	462.110000000000014	RUB	2025-04-18 20:02:47
2026-01-24	113	470	\N	190.849999999999994	RUB	2026-01-24 08:23:56
2024-12-23	94	455	bank_transfer	1103.5	USD	2024-12-23 18:22:35
2024-12-04	115	-1	card	968.889999999999986	EUR	2024-12-04 18:10:32
2025-04-26	97	248	paypal	578.559999999999945	USD	2025-04-26 21:24:40
2026-01-23	127	426	bank_transfer	1643.20000000000005	USD	2026-01-23 16:42:21
2026-01-19	100	184	\N	2039.75999999999999	RUB	2026-01-19 07:26:45
2025-12-13	130	-1	card	714.860000000000014	EUR	2025-12-13 16:01:58
2026-03-11	103	313	paypal	2939.44000000000005	USD	2026-03-11 12:31:32
2024-06-02	131	775	bank_transfer	2529.65000000000009	EUR	2024-06-02 14:21:44
2024-09-19	104	-1	bank_transfer	2760.53999999999996	EUR	2024-09-19 00:34:28
2025-01-18	133	951	\N	168.830000000000013	EUR	2025-01-18 18:29:37
2026-04-26	108	981	paypal	1127.33999999999992	USD	2026-04-26 04:10:48
2025-11-12	139	1159	bank_transfer	575.690000000000055	USD	2025-11-12 06:33:14
2026-01-16	109	813	\N	2568.15000000000009	EUR	2026-01-16 18:03:29
2024-07-26	142	614	paypal	500.079999999999984	USD	2024-07-26 23:44:28
2025-03-09	117	188	\N	\N	RUB	2025-03-09 23:15:50
2024-09-29	145	599	paypal	2917.67999999999984	EUR	2024-09-29 15:42:23
2025-01-04	118	1018	bank_transfer	2954.59999999999991	USD	2025-01-04 02:53:17
2025-11-27	153	89	\N	202.389999999999986	EUR	2025-11-27 06:34:52
\N	120	-1	\N	1315.09999999999991	USD	\N
2025-04-09	156	624	\N	50.2800000000000011	USD	2025-04-09 00:35:26
2025-11-10	126	1096	\N	2878.25	RUB	2025-11-10 10:03:20
2025-04-08	163	1111	bank_transfer	1175.90000000000009	USD	2025-04-08 00:31:01
2025-08-23	129	1185	bank_transfer	112.010000000000005	USD	2025-08-23 18:18:34
2025-10-28	165	635	\N	2227.76999999999998	EUR	2025-10-28 19:56:57
2025-07-01	140	102	bank_transfer	1716.53999999999996	RUB	2025-07-01 09:27:35
2026-01-27	177	520	\N	2635.88999999999987	EUR	2026-01-27 09:09:28
2025-04-25	141	226	paypal	\N	RUB	2025-04-25 04:13:36
2025-05-16	182	350	paypal	1753.52999999999997	USD	2025-05-16 21:56:16
2024-08-05	143	-1	bank_transfer	2562.90999999999985	RUB	2024-08-05 22:08:15
2025-06-17	183	270	card	666.019999999999982	USD	2025-06-17 12:41:16
2025-03-20	146	626	card	2132.92999999999984	EUR	2025-03-20 16:24:24
2025-08-16	190	903	paypal	1092.08999999999992	RUB	2025-08-16 12:34:43
2025-03-18	147	-1	paypal	1716.76999999999998	RUB	2025-03-18 02:46:58
2026-01-18	193	1039	paypal	2279.57999999999993	USD	2026-01-18 02:36:55
2024-06-06	151	1092	bank_transfer	2806.82999999999993	USD	2024-06-06 09:13:54
2025-12-06	197	152	\N	1850.28999999999996	USD	2025-12-06 02:07:11
2026-04-21	164	835	paypal	2657.34999999999991	RUB	2026-04-21 04:50:10
2025-01-14	215	841	paypal	1785.74000000000001	USD	2025-01-14 13:39:58
2024-10-24	176	221	paypal	68.4000000000000057	USD	2024-10-24 07:15:22
2025-12-14	218	369	card	2483.4699999999998	EUR	2025-12-14 09:26:01
2025-12-08	180	117	paypal	1837.68000000000006	EUR	2025-12-08 08:43:56
2024-07-31	224	855	\N	1130.01999999999998	EUR	2024-07-31 01:53:30
2025-08-12	185	272	bank_transfer	1373.56999999999994	USD	2025-08-12 14:10:03
2025-08-31	225	225	bank_transfer	\N	EUR	2025-08-31 18:13:59
2025-09-08	187	209	\N	2651.63000000000011	RUB	2025-09-08 20:13:05
2024-06-02	239	397	\N	2810.01000000000022	USD	2024-06-02 01:50:02
2025-09-21	192	703	\N	963.639999999999986	EUR	2025-09-21 20:25:20
2025-01-17	246	991	\N	2373.01999999999998	RUB	2025-01-17 01:21:42
2024-08-11	195	1088	\N	407.370000000000005	RUB	2024-08-11 00:02:27
2026-02-08	247	-1	\N	268.240000000000009	USD	2026-02-08 01:50:24
2025-11-23	198	-1	paypal	2591.59999999999991	RUB	2025-11-23 06:39:12
2025-02-10	256	1031	card	1344.8900000000001	EUR	2025-02-10 19:48:45
2025-04-30	203	657	bank_transfer	450.139999999999986	RUB	2025-04-30 11:45:19
2024-11-18	257	506	bank_transfer	2910.40999999999985	EUR	2024-11-18 15:32:51
2025-11-05	205	603	bank_transfer	1627.94000000000005	EUR	2025-11-05 23:54:16
2025-09-09	266	1020	bank_transfer	2349.90000000000009	RUB	2025-09-09 15:29:12
\N	207	952	card	1805.68000000000006	USD	\N
2025-03-28	267	831	bank_transfer	1068.78999999999996	USD	2025-03-28 01:16:41
2024-10-06	209	918	\N	1843.99000000000001	EUR	2024-10-06 20:47:27
2026-01-25	270	219	\N	1208.02999999999997	EUR	2026-01-25 20:35:17
2024-08-28	211	478	bank_transfer	2843.92999999999984	USD	2024-08-28 23:31:29
2024-11-23	275	1066	card	553.840000000000032	USD	2024-11-23 10:33:59
2026-04-30	219	1054	card	1143.41000000000008	RUB	2026-04-30 12:33:45
2026-05-01	279	759	card	63.4200000000000017	USD	2026-05-01 16:58:24
2024-08-18	223	607	card	2850.2800000000002	RUB	2024-08-18 22:43:56
2026-01-16	282	1158	paypal	1174.46000000000004	EUR	2026-01-16 11:55:39
2026-05-17	229	818	bank_transfer	2880.09000000000015	RUB	2026-05-17 15:36:52
2025-08-01	287	517	paypal	828.720000000000027	RUB	2025-08-01 05:05:57
2024-07-31	230	607	paypal	373.879999999999995	USD	2024-07-31 11:09:59
2025-05-09	288	703	\N	1794.00999999999999	RUB	2025-05-09 13:03:36
2025-08-10	233	231	bank_transfer	1842.97000000000003	RUB	2025-08-10 00:27:44
2025-06-17	290	663	bank_transfer	1145.93000000000006	RUB	2025-06-17 06:39:04
2024-07-25	236	408	card	2078.15000000000009	RUB	2024-07-25 16:23:36
2024-06-17	291	872	paypal	1800.11999999999989	USD	2024-06-17 00:43:25
2024-11-25	237	865	\N	1657.67000000000007	USD	2024-11-25 00:31:31
2025-06-10	299	294	\N	2341.82000000000016	EUR	2025-06-10 20:34:27
2026-05-06	241	4	bank_transfer	747.92999999999995	RUB	2026-05-06 22:57:52
2024-10-03	301	1135	bank_transfer	1052.58999999999992	USD	2024-10-03 14:36:47
2026-01-20	244	894	paypal	2098.57000000000016	USD	2026-01-20 16:02:24
2024-12-04	309	76	bank_transfer	794.669999999999959	USD	2024-12-04 03:07:55
2026-04-22	251	130	\N	2695.17999999999984	EUR	2026-04-22 13:47:33
2025-09-13	310	256	paypal	1475.22000000000003	EUR	2025-09-13 04:32:01
2025-04-13	252	41	\N	2130.57999999999993	EUR	2025-04-13 10:18:06
2025-10-14	312	359	card	2810.28999999999996	EUR	2025-10-14 21:01:49
2024-08-12	258	309	\N	1989.00999999999999	EUR	2024-08-12 16:09:29
2026-02-25	315	436	bank_transfer	2080.69999999999982	RUB	2026-02-25 13:44:19
2024-09-08	260	663	\N	2612.23999999999978	USD	2024-09-08 06:16:10
2026-02-23	319	-1	card	1149.11999999999989	EUR	2026-02-23 21:48:45
2024-11-30	261	333	bank_transfer	937.980000000000018	EUR	2024-11-30 04:50:10
2024-11-04	331	-1	card	1625.66000000000008	USD	2024-11-04 05:43:57
2025-12-09	262	19	\N	686.080000000000041	RUB	2025-12-09 23:01:37
2025-03-05	334	423	\N	2436.44000000000005	EUR	2025-03-05 12:36:52
2025-02-28	263	47	\N	907.629999999999995	EUR	2025-02-28 03:48:29
2024-07-10	335	1072	card	2286.44000000000005	USD	2024-07-10 09:13:41
2025-01-18	272	21	bank_transfer	516.659999999999968	USD	2025-01-18 06:33:41
2025-12-02	341	184	bank_transfer	1763.90000000000009	RUB	2025-12-02 07:17:35
2026-02-05	274	126	card	136.469999999999999	RUB	2026-02-05 20:18:16
2024-07-21	345	646	bank_transfer	2954.57999999999993	USD	2024-07-21 16:02:13
2026-04-18	285	72	card	1426.86999999999989	USD	2026-04-18 22:27:47
2025-09-24	354	177	bank_transfer	1905.95000000000005	EUR	2025-09-24 05:19:16
2026-05-08	286	252	card	1900.45000000000005	USD	2026-05-08 16:04:07
2025-12-15	355	381	bank_transfer	2464.82999999999993	EUR	2025-12-15 09:50:09
2024-12-27	294	591	bank_transfer	935.759999999999991	EUR	2024-12-27 11:18:36
2024-09-26	356	505	\N	2373.76000000000022	RUB	2024-09-26 10:59:25
2024-08-09	295	198	paypal	1799.92000000000007	RUB	2024-08-09 18:34:18
2025-12-01	363	1148	card	2926.42999999999984	USD	2025-12-01 22:22:30
2026-01-01	296	281	bank_transfer	\N	EUR	2026-01-01 13:04:22
2025-05-26	374	134	\N	2842.38999999999987	USD	2025-05-26 13:17:44
2025-08-08	298	188	card	2228.25	RUB	2025-08-08 15:09:20
2026-02-03	379	342	card	400.589999999999975	EUR	2026-02-03 20:11:46
2025-02-18	304	689	card	1117.36999999999989	RUB	2025-02-18 20:40:36
2025-06-02	381	275	card	123.849999999999994	EUR	2025-06-02 13:08:53
2026-02-17	308	1170	\N	374.870000000000005	USD	2026-02-17 19:06:12
2026-03-17	389	73	paypal	317.04000000000002	EUR	2026-03-17 06:25:49
2025-05-04	311	491	paypal	267.769999999999982	EUR	2025-05-04 13:52:10
2025-03-17	391	348	card	55.759999999999998	USD	2025-03-17 04:31:13
2026-01-23	320	-1	bank_transfer	688.960000000000036	EUR	2026-01-23 12:47:16
2026-03-12	393	839	card	2169.90000000000009	USD	2026-03-12 17:31:47
2024-12-21	322	76	card	1770.86999999999989	USD	2024-12-21 20:23:03
2025-02-01	394	123	card	1030.1099999999999	EUR	2025-02-01 23:27:24
2025-01-09	325	1070	bank_transfer	2118.73000000000002	EUR	2025-01-09 11:50:36
2025-09-22	395	26	card	745.32000000000005	EUR	2025-09-22 10:19:47
2025-03-28	326	1054	bank_transfer	527.200000000000045	RUB	2025-03-28 23:39:11
2024-06-06	397	780	card	497.54000000000002	RUB	2024-06-06 20:26:42
2024-07-06	329	1062	card	2135.73999999999978	RUB	2024-07-06 21:31:24
2025-02-12	410	655	card	411.610000000000014	USD	2025-02-12 11:28:37
2025-11-16	333	613	bank_transfer	62.8800000000000026	EUR	2025-11-16 04:39:25
2026-01-01	412	1053	\N	1447.32999999999993	USD	2026-01-01 09:57:40
2025-12-01	338	24	card	257.759999999999991	RUB	2025-12-01 07:02:13
2024-08-18	414	898	card	1379.44000000000005	RUB	2024-08-18 17:02:22
\N	344	1091	paypal	738.57000000000005	RUB	\N
2025-01-04	415	1162	paypal	346.420000000000016	USD	2025-01-04 16:24:10
2025-04-18	346	1088	bank_transfer	745.17999999999995	RUB	2025-04-18 08:56:24
2024-09-21	422	447	card	\N	USD	2024-09-21 15:00:18
2026-04-15	348	945	paypal	201.77000000000001	EUR	2026-04-15 04:07:19
\N	424	1058	card	733.029999999999973	USD	\N
2026-01-22	350	162	paypal	1149.75999999999999	RUB	2026-01-22 23:59:52
\N	428	690	bank_transfer	2154.76000000000022	RUB	\N
2026-03-09	352	-1	bank_transfer	741.139999999999986	RUB	2026-03-09 17:19:16
2024-06-11	429	1122	\N	2967.19999999999982	EUR	2024-06-11 02:30:57
2026-01-20	358	-1	\N	561.5	RUB	2026-01-20 19:40:20
2025-10-05	435	842	card	626.289999999999964	EUR	2025-10-05 16:14:27
2024-07-24	360	845	card	264.980000000000018	USD	2024-07-24 05:44:50
2025-06-03	439	312	paypal	2314.57000000000016	RUB	2025-06-03 09:32:55
2025-01-27	361	663	paypal	2682.03999999999996	EUR	2025-01-27 13:29:05
2026-04-22	444	194	paypal	71.8400000000000034	RUB	2026-04-22 09:29:26
2025-11-17	362	839	bank_transfer	1615.52999999999997	USD	2025-11-17 07:35:15
2025-06-25	446	1157	card	546.529999999999973	EUR	2025-06-25 05:34:52
2026-02-08	364	997	\N	1481.44000000000005	USD	2026-02-08 01:12:21
2024-11-28	449	939	card	274.050000000000011	USD	2024-11-28 09:51:21
2024-06-26	366	1186	paypal	792.309999999999945	RUB	2024-06-26 18:18:51
2024-11-11	457	717	\N	941.200000000000045	USD	2024-11-11 08:54:41
2025-05-07	367	844	card	964.629999999999995	EUR	2025-05-07 07:39:55
2026-04-07	458	651	card	1483.68000000000006	RUB	2026-04-07 12:45:24
2026-02-14	369	570	\N	537.629999999999995	EUR	2026-02-14 11:15:52
2025-06-06	462	1118	\N	2640.38000000000011	RUB	2025-06-06 21:19:26
2025-11-23	370	486	bank_transfer	2616.07999999999993	RUB	2025-11-23 00:09:59
2026-02-25	465	622	\N	1250.08999999999992	EUR	2026-02-25 13:44:11
2024-12-03	371	253	\N	2250.88000000000011	EUR	2024-12-03 22:25:08
2026-01-03	466	557	paypal	2921.19000000000005	EUR	2026-01-03 08:13:47
2025-06-17	373	72	paypal	2277.5300000000002	EUR	2025-06-17 08:14:33
2025-01-06	471	511	card	1649.17000000000007	RUB	2025-01-06 10:30:25
2026-04-28	383	492	card	1703.77999999999997	USD	2026-04-28 15:04:42
2024-10-08	476	572	card	499.769999999999982	RUB	2024-10-08 20:10:56
2025-10-05	390	441	card	1160.05999999999995	EUR	2025-10-05 00:36:02
2025-09-13	479	789	card	319.430000000000007	USD	2025-09-13 00:37:18
2025-01-10	403	371	paypal	296.670000000000016	RUB	2025-01-10 20:46:45
\N	482	610	\N	2426.61000000000013	USD	\N
2024-09-04	404	35	bank_transfer	824.240000000000009	EUR	2024-09-04 04:55:54
2024-06-12	484	-1	\N	1673.23000000000002	USD	2024-06-12 01:45:23
2024-09-12	406	-1	bank_transfer	87.3599999999999994	EUR	2024-09-12 16:37:49
2025-10-17	486	956	bank_transfer	1531.82999999999993	EUR	2025-10-17 00:54:16
2026-04-30	416	1084	paypal	1322.80999999999995	EUR	2026-04-30 16:57:11
2025-11-15	487	897	bank_transfer	2765.36999999999989	USD	2025-11-15 04:44:47
2024-06-12	418	920	card	850.240000000000009	RUB	2024-06-12 19:43:40
2026-04-05	490	465	\N	2342.57999999999993	USD	2026-04-05 00:19:48
2025-04-28	421	304	card	613.919999999999959	EUR	2025-04-28 13:24:05
2024-07-24	491	1049	card	2837.57000000000016	RUB	2024-07-24 13:05:18
\N	425	1188	card	771.330000000000041	EUR	\N
2025-11-27	493	994	bank_transfer	1453.74000000000001	USD	2025-11-27 14:12:27
2025-12-16	426	482	paypal	1711.79999999999995	RUB	2025-12-16 17:06:38
2025-01-18	494	218	card	140.150000000000006	USD	2025-01-18 02:25:43
2025-08-29	436	513	bank_transfer	978.519999999999982	RUB	2025-08-29 01:35:33
2025-08-19	495	1125	bank_transfer	2398.84000000000015	EUR	2025-08-19 07:05:42
2025-04-01	437	905	paypal	2673.90000000000009	RUB	2025-04-01 22:26:59
2026-02-08	505	-1	paypal	2548.63000000000011	RUB	2026-02-08 02:24:25
2025-05-24	438	33	paypal	179.930000000000007	RUB	2025-05-24 11:56:33
2025-09-17	512	319	\N	2738.01000000000022	RUB	2025-09-17 15:03:42
2025-04-03	447	65	card	2003.3599999999999	EUR	2025-04-03 23:21:27
2025-10-25	513	251	bank_transfer	2464.38000000000011	EUR	2025-10-25 05:06:43
2024-09-15	452	767	card	107.510000000000005	EUR	2024-09-15 18:23:53
2025-11-12	516	1038	card	717.950000000000045	EUR	2025-11-12 07:50:30
2025-07-19	455	785	card	1268.50999999999999	USD	2025-07-19 13:34:44
2025-06-22	519	948	\N	2530.88000000000011	USD	2025-06-22 18:34:15
\N	456	1023	paypal	1873.68000000000006	RUB	\N
2024-07-25	524	665	\N	903.590000000000032	RUB	2024-07-25 02:52:48
2024-06-10	459	376	\N	2044.57999999999993	EUR	2024-06-10 18:58:23
2026-04-05	525	681	bank_transfer	559.580000000000041	EUR	2026-04-05 02:38:56
2024-10-26	460	794	bank_transfer	2960.86000000000013	RUB	2024-10-26 02:43:07
2026-01-12	526	924	paypal	2062.05000000000018	RUB	2026-01-12 22:05:31
2024-10-27	461	566	card	2353.84999999999991	RUB	2024-10-27 22:43:03
2024-05-31	530	284	bank_transfer	1654.5	RUB	2024-05-31 15:14:50
2025-11-12	464	741	card	1993.93000000000006	USD	2025-11-12 13:18:02
2025-04-03	531	1033	\N	393.629999999999995	RUB	2025-04-03 13:53:12
2025-11-23	469	819	bank_transfer	1083.6099999999999	EUR	2025-11-23 06:40:59
2024-10-24	533	759	paypal	2044.68000000000006	EUR	2024-10-24 20:51:40
2024-10-18	470	-1	\N	1935.59999999999991	USD	2024-10-18 17:34:22
2024-09-29	543	118	bank_transfer	379.660000000000025	USD	2024-09-29 10:09:43
2024-06-30	473	133	bank_transfer	2625.80999999999995	RUB	2024-06-30 22:05:07
2026-01-11	555	666	bank_transfer	682.42999999999995	USD	2026-01-11 04:48:55
2025-11-25	475	90	paypal	1055	USD	2025-11-25 04:34:32
2026-03-25	558	179	paypal	490.850000000000023	RUB	2026-03-25 16:43:55
2025-05-22	485	-1	card	2286.4699999999998	RUB	2025-05-22 23:24:42
2025-02-16	563	891	bank_transfer	\N	USD	2025-02-16 16:18:19
2025-06-20	498	78	\N	503.560000000000002	RUB	2025-06-20 10:18:35
2026-01-09	572	584	paypal	1751.06999999999994	RUB	2026-01-09 08:20:07
2025-06-17	500	731	card	\N	EUR	2025-06-17 10:28:20
2025-04-14	1	778	bank_transfer	\N	EUR	2025-04-14 23:23:52
2025-06-18	5	864	card	2366.61999999999989	EUR	2025-06-18 21:21:20
2026-04-05	11	493	\N	519.110000000000014	RUB	2026-04-05 05:14:09
\N	12	290	\N	2416.23999999999978	EUR	\N
2024-10-14	26	1100	paypal	180.840000000000003	RUB	2024-10-14 12:24:00
2026-04-22	14	187	bank_transfer	\N	USD	2026-04-22 23:43:11
2025-06-23	30	27	paypal	50.4200000000000017	USD	2025-06-23 16:01:32
\N	15	388	\N	692.440000000000055	RUB	\N
2024-10-10	38	152	\N	2054.26000000000022	EUR	2024-10-10 20:08:34
2025-12-27	17	1174	\N	2722.57000000000016	RUB	2025-12-27 15:25:25
2025-01-15	40	1109	bank_transfer	2833.44999999999982	USD	2025-01-15 17:59:28
2026-04-18	20	964	paypal	1773.84999999999991	RUB	2026-04-18 18:50:53
2026-01-06	44	1049	\N	2107.26999999999998	EUR	2026-01-06 00:59:45
2025-08-20	23	1192	\N	2937.69000000000005	USD	2025-08-20 09:24:08
2024-12-08	48	266	paypal	1948.73000000000002	EUR	2024-12-08 17:01:45
2024-10-09	25	977	paypal	306	USD	2024-10-09 08:22:51
2026-04-22	50	704	bank_transfer	665	EUR	2026-04-22 22:31:10
2025-12-18	31	306	paypal	1909.45000000000005	USD	2025-12-18 04:57:11
2024-12-08	56	484	paypal	2669.11000000000013	USD	2024-12-08 22:08:43
2025-11-08	35	-1	paypal	2953.40000000000009	EUR	2025-11-08 18:01:05
2026-03-16	64	585	bank_transfer	2719.7199999999998	USD	2026-03-16 09:38:30
2025-06-05	36	197	paypal	1381.61999999999989	USD	2025-06-05 04:43:10
\N	68	566	paypal	356.269999999999982	USD	\N
2025-10-28	46	403	bank_transfer	127.810000000000002	RUB	2025-10-28 02:28:11
2025-01-06	71	239	bank_transfer	2382.05999999999995	EUR	2025-01-06 10:44:08
2024-10-20	47	705	card	2315.23000000000002	EUR	2024-10-20 08:20:31
2025-11-01	72	928	\N	2660.67000000000007	USD	2025-11-01 06:30:06
2024-12-14	49	606	paypal	421.379999999999995	EUR	2024-12-14 17:02:33
2025-11-01	83	753	bank_transfer	2444.73999999999978	RUB	2025-11-01 12:38:56
2025-10-15	52	-1	card	2210.15999999999985	RUB	2025-10-15 02:47:41
2025-05-23	86	-1	bank_transfer	2543.11000000000013	USD	2025-05-23 10:41:24
2026-01-14	57	494	card	797.009999999999991	USD	2026-01-14 10:59:05
2024-07-09	87	446	\N	2903.63000000000011	RUB	2024-07-09 03:52:49
2025-10-03	61	688	paypal	2142.07999999999993	EUR	2025-10-03 07:14:06
2026-05-07	89	316	\N	382.439999999999998	USD	2026-05-07 00:05:00
2025-06-27	63	131	\N	2794.96000000000004	USD	2025-06-27 03:01:10
2025-04-23	95	717	card	405.019999999999982	EUR	2025-04-23 23:47:18
2026-04-20	69	545	paypal	1116.47000000000003	EUR	2026-04-20 18:25:06
2025-01-19	105	1160	paypal	2991.4699999999998	RUB	2025-01-19 17:34:16
2024-11-30	74	1088	bank_transfer	1943.94000000000005	USD	2024-11-30 23:04:18
2025-02-17	106	378	paypal	2450.75	RUB	2025-02-17 02:57:11
2026-03-03	76	429	bank_transfer	2750.13000000000011	RUB	2026-03-03 08:59:52
2024-11-02	114	976	card	1108.81999999999994	EUR	2024-11-02 05:37:40
2025-03-24	78	1021	card	815.840000000000032	USD	2025-03-24 04:13:47
2025-07-26	116	159	bank_transfer	277.699999999999989	EUR	2025-07-26 12:23:57
2026-03-29	79	52	\N	1501.72000000000003	EUR	2026-03-29 15:46:34
2025-01-23	122	-1	\N	746.080000000000041	EUR	2025-01-23 14:06:26
2025-02-15	85	655	\N	550.980000000000018	RUB	2025-02-15 00:56:17
2026-03-08	123	1160	\N	1605.29999999999995	USD	2026-03-08 07:57:27
2025-01-06	88	337	card	2422.25	USD	2025-01-06 06:40:00
2024-10-25	124	474	card	241.099999999999994	RUB	2024-10-25 16:35:25
2024-08-31	91	722	paypal	1045.02999999999997	USD	2024-08-31 03:52:43
2024-09-04	128	674	bank_transfer	363.560000000000002	USD	2024-09-04 23:57:32
2024-09-10	96	941	card	1203.34999999999991	RUB	2024-09-10 05:45:15
2025-07-12	134	822	bank_transfer	941.379999999999995	RUB	2025-07-12 14:51:33
2024-08-28	98	320	\N	1155.77999999999997	USD	2024-08-28 02:33:07
2026-01-22	135	183	\N	1354.51999999999998	USD	2026-01-22 00:38:43
2025-12-21	107	-1	bank_transfer	2875.90000000000009	USD	2025-12-21 20:03:34
2025-01-15	137	452	\N	118.420000000000002	USD	2025-01-15 22:32:55
2026-03-10	111	664	paypal	2850.34000000000015	USD	2026-03-10 15:59:42
2025-07-05	138	1158	\N	132.150000000000006	RUB	2025-07-05 08:20:47
2025-11-10	119	38	bank_transfer	199.389999999999986	USD	2025-11-10 23:54:22
2025-06-01	144	891	paypal	1192.53999999999996	EUR	2025-06-01 23:44:30
2025-10-25	121	151	paypal	425.149999999999977	RUB	2025-10-25 12:11:16
2025-01-05	149	1077	paypal	2645.13000000000011	USD	2025-01-05 04:27:18
2025-03-29	125	798	card	2955.57000000000016	EUR	2025-03-29 21:12:47
2025-02-04	154	588	\N	918.049999999999955	EUR	2025-02-04 00:41:20
2025-08-20	132	983	card	1697.8599999999999	RUB	2025-08-20 21:10:37
2024-06-13	155	258	card	1023.29999999999995	USD	2024-06-13 09:49:06
2024-09-12	136	70	bank_transfer	1169.25999999999999	EUR	2024-09-12 11:05:51
2026-05-20	157	57	paypal	462.180000000000007	RUB	2026-05-20 02:52:51
2024-08-18	148	584	paypal	2835.34999999999991	RUB	2024-08-18 04:52:31
2025-07-11	159	-1	\N	2578.25	USD	2025-07-11 03:01:04
2024-11-09	150	263	\N	689.100000000000023	RUB	2024-11-09 20:20:03
2024-10-25	167	812	card	1996.58999999999992	USD	2024-10-25 07:29:03
\N	152	1170	\N	762.549999999999955	USD	\N
2025-01-12	168	643	paypal	1665.46000000000004	RUB	2025-01-12 12:27:02
2025-07-01	158	418	\N	2626.42999999999984	EUR	2025-07-01 22:22:58
2025-08-21	169	103	paypal	2583.86000000000013	RUB	2025-08-21 08:42:01
2025-11-15	160	966	card	1005.69000000000005	RUB	2025-11-15 14:06:24
2025-11-21	170	586	card	287.220000000000027	EUR	2025-11-21 04:53:16
2025-09-16	161	1175	paypal	2820.96000000000004	USD	2025-09-16 18:56:55
2025-01-30	171	653	card	805.220000000000027	USD	2025-01-30 22:32:35
2024-11-09	162	532	bank_transfer	798.049999999999955	EUR	2024-11-09 13:38:20
2025-09-22	173	801	bank_transfer	2448.90000000000009	USD	2025-09-22 00:32:14
2025-06-19	166	39	bank_transfer	565.669999999999959	USD	2025-06-19 18:02:25
2025-02-20	174	327	paypal	1356.40000000000009	USD	2025-02-20 10:29:14
2024-08-08	172	97	paypal	700.580000000000041	USD	2024-08-08 12:51:52
2025-07-05	175	479	card	417.759999999999991	USD	2025-07-05 03:30:58
2026-03-01	178	877	\N	1334.09999999999991	EUR	2026-03-01 01:12:12
2025-12-06	184	1191	card	1629.75	USD	2025-12-06 06:17:59
2025-05-17	179	291	\N	\N	RUB	2025-05-17 15:12:18
2024-09-05	188	848	card	1915.47000000000003	RUB	2024-09-05 20:37:21
2024-11-09	181	355	paypal	1932.43000000000006	RUB	2024-11-09 12:11:52
2024-11-09	189	541	card	2364.25	EUR	2024-11-09 11:15:54
2024-11-21	186	848	bank_transfer	2645.61999999999989	RUB	2024-11-21 09:01:49
2024-08-31	194	157	paypal	1466.69000000000005	USD	2024-08-31 06:16:55
2026-03-26	191	132	paypal	1418.09999999999991	USD	2026-03-26 14:26:05
2025-11-26	199	-1	bank_transfer	470.129999999999995	RUB	2025-11-26 19:41:56
2025-03-31	196	1133	\N	145.050000000000011	RUB	2025-03-31 20:10:54
2024-10-05	200	225	\N	1077.77999999999997	USD	2024-10-05 03:16:24
2025-10-24	210	-1	paypal	1879.25999999999999	USD	2025-10-24 10:35:08
2025-12-19	201	795	bank_transfer	534.539999999999964	USD	2025-12-19 23:25:09
2024-05-27	213	818	bank_transfer	\N	RUB	2024-05-27 10:00:18
2024-07-07	202	739	bank_transfer	676.529999999999973	USD	2024-07-07 13:56:12
2025-05-11	216	1192	\N	471.870000000000005	USD	2025-05-11 06:32:30
2024-11-28	204	400	card	2639.63000000000011	RUB	2024-11-28 17:05:29
2024-10-16	217	316	\N	1318.96000000000004	USD	2024-10-16 00:03:48
2025-01-02	206	1063	\N	2634.07999999999993	RUB	2025-01-02 00:16:44
2024-12-12	221	1176	paypal	1624.16000000000008	RUB	2024-12-12 20:14:11
2025-11-07	208	1040	bank_transfer	50.7700000000000031	USD	2025-11-07 18:48:22
2025-01-10	222	363	paypal	2569.51000000000022	USD	2025-01-10 00:09:54
2024-09-18	212	350	paypal	1368	EUR	2024-09-18 15:01:42
2026-04-26	227	1030	\N	22.8599999999999994	EUR	2026-04-26 03:22:46
2025-10-25	214	756	paypal	269.470000000000027	USD	2025-10-25 05:38:47
2025-09-29	228	1067	bank_transfer	1922.07999999999993	RUB	2025-09-29 06:17:48
2024-11-25	220	220	paypal	2013.08999999999992	RUB	2024-11-25 10:42:17
2025-04-22	231	297	paypal	1839.32999999999993	USD	2025-04-22 04:33:59
2025-07-18	226	626	paypal	1677.69000000000005	RUB	2025-07-18 19:49:55
2024-07-11	232	94	bank_transfer	\N	USD	2024-07-11 14:46:17
2026-03-10	234	230	card	1467.07999999999993	EUR	2026-03-10 21:13:58
2024-10-30	242	-1	paypal	2073.55999999999995	RUB	2024-10-30 20:55:28
2025-07-12	235	833	bank_transfer	2590.84999999999991	RUB	2025-07-12 00:55:26
2026-03-30	248	625	card	1205	USD	2026-03-30 16:55:17
2025-08-17	238	128	card	2217.75	EUR	2025-08-17 03:15:04
2025-09-25	250	1041	paypal	2156.34999999999991	EUR	2025-09-25 04:13:57
2024-11-25	240	669	paypal	\N	EUR	2024-11-25 16:21:53
2025-07-03	253	-1	bank_transfer	1489.16000000000008	RUB	2025-07-03 21:34:22
2025-08-26	243	924	\N	2339.48999999999978	RUB	2025-08-26 00:00:36
2024-11-06	259	788	paypal	1118.54999999999995	RUB	2024-11-06 00:02:46
2024-10-05	245	1028	\N	548.389999999999986	RUB	2024-10-05 13:55:20
2025-10-20	264	867	bank_transfer	1889.66000000000008	USD	2025-10-20 02:47:56
2025-08-18	249	322	paypal	2919.98000000000002	USD	2025-08-18 02:22:51
2026-01-28	268	1033	bank_transfer	2861.75	USD	2026-01-28 19:18:10
2026-03-31	254	1071	card	517.799999999999955	RUB	2026-03-31 15:44:34
2024-08-24	278	712	\N	2503.55000000000018	USD	2024-08-24 22:08:31
2026-05-14	255	261	\N	2443.38999999999987	RUB	2026-05-14 00:05:51
2024-12-24	281	417	card	1784.68000000000006	EUR	2024-12-24 06:53:40
2025-06-25	265	45	card	2298.11999999999989	RUB	2025-06-25 17:51:25
2026-03-21	284	40	card	1717.05999999999995	RUB	2026-03-21 02:51:44
2024-08-24	269	1063	bank_transfer	1244.6400000000001	USD	2024-08-24 16:53:00
2025-03-27	292	680	paypal	2818.03999999999996	USD	2025-03-27 11:22:04
2025-12-02	271	648	card	2333.69000000000005	RUB	2025-12-02 18:06:19
2025-09-14	297	-1	card	2191.38999999999987	USD	2025-09-14 13:56:45
2025-11-08	273	817	paypal	372.439999999999998	EUR	2025-11-08 09:45:15
2025-11-17	303	1029	bank_transfer	2580.4699999999998	EUR	2025-11-17 06:02:02
2026-02-15	276	390	card	21.620000000000001	EUR	2026-02-15 08:12:53
2024-09-01	306	750	paypal	1373.24000000000001	EUR	2024-09-01 13:22:22
2026-01-23	277	486	\N	1457.75	EUR	2026-01-23 15:23:47
2025-01-07	307	606	card	2321.67999999999984	EUR	2025-01-07 19:36:48
2025-03-10	280	800	\N	21.879999999999999	USD	2025-03-10 16:20:49
2026-05-11	313	20	bank_transfer	2387.32000000000016	RUB	2026-05-11 10:23:56
2025-05-25	283	603	\N	2936.67000000000007	EUR	2025-05-25 08:21:25
2025-12-01	318	982	\N	852.059999999999945	RUB	2025-12-01 08:41:52
2024-09-16	289	338	bank_transfer	2709.11000000000013	USD	2024-09-16 09:32:36
2025-03-26	324	698	paypal	2719.63999999999987	USD	2025-03-26 06:24:35
2026-03-24	293	61	bank_transfer	2796.9699999999998	EUR	2026-03-24 23:33:10
2025-05-02	327	938	bank_transfer	2258.23000000000002	EUR	2025-05-02 16:59:28
2025-05-25	300	1118	paypal	488.019999999999982	RUB	2025-05-25 17:55:57
2025-11-15	328	1005	bank_transfer	528.67999999999995	RUB	2025-11-15 19:47:38
2024-06-05	302	710	paypal	559.220000000000027	RUB	2024-06-05 20:46:11
2026-02-14	332	926	card	911.730000000000018	EUR	2026-02-14 09:42:31
2026-03-14	305	190	bank_transfer	2558	EUR	2026-03-14 12:59:03
2024-09-09	336	1082	bank_transfer	563.029999999999973	EUR	2024-09-09 03:33:01
2026-01-12	314	372	card	1315.69000000000005	EUR	2026-01-12 19:20:42
2025-10-21	337	504	\N	2549.78999999999996	RUB	2025-10-21 14:50:39
2024-10-07	316	103	card	694.75	RUB	2024-10-07 06:51:16
2024-07-07	339	1174	paypal	2388.88000000000011	USD	2024-07-07 06:57:57
2026-03-14	317	980	paypal	1702.27999999999997	EUR	2026-03-14 22:40:09
2025-08-15	340	303	\N	1346.98000000000002	EUR	2025-08-15 01:40:19
2026-04-21	321	700	card	1894.73000000000002	RUB	2026-04-21 07:13:14
2026-05-09	347	88	bank_transfer	2396.84999999999991	EUR	2026-05-09 17:38:47
2025-05-03	323	1183	card	1606.15000000000009	RUB	2025-05-03 07:59:20
2026-04-04	349	1088	\N	227.639999999999986	USD	2026-04-04 14:29:32
2024-11-28	330	1196	\N	173	RUB	2024-11-28 03:17:01
2025-11-04	351	503	paypal	1059.05999999999995	EUR	2025-11-04 02:25:38
2025-07-04	342	952	card	1523.69000000000005	RUB	2025-07-04 06:41:09
2025-12-25	353	882	card	978.840000000000032	EUR	2025-12-25 11:55:43
2025-07-25	343	249	card	968.879999999999995	RUB	2025-07-25 17:45:02
2025-05-04	359	605	paypal	\N	RUB	2025-05-04 22:33:29
2025-01-05	357	492	\N	1848.05999999999995	EUR	2025-01-05 09:34:57
2024-11-27	365	210	bank_transfer	1278.22000000000003	RUB	2024-11-27 09:33:54
2024-06-03	368	-1	card	1495.99000000000001	RUB	2024-06-03 23:09:51
2025-05-24	372	1133	card	2667.0300000000002	USD	2025-05-24 01:15:14
2025-06-02	375	1049	paypal	1654.16000000000008	RUB	2025-06-02 19:12:47
2026-01-07	376	921	card	717.42999999999995	EUR	2026-01-07 12:29:15
2025-04-10	377	-1	card	300.990000000000009	EUR	2025-04-10 21:28:14
2026-03-02	382	1014	bank_transfer	2278.73000000000002	USD	2026-03-02 07:48:16
2025-05-17	378	48	paypal	595.139999999999986	RUB	2025-05-17 22:46:34
2024-10-11	388	439	paypal	883.049999999999955	EUR	2024-10-11 16:58:02
2025-10-12	380	477	card	222.099999999999994	RUB	2025-10-12 13:02:54
2024-12-20	392	485	\N	2341.5300000000002	EUR	2024-12-20 19:57:33
2025-02-03	384	-1	paypal	1871.72000000000003	USD	2025-02-03 19:21:51
2025-04-11	400	141	\N	2996.40000000000009	USD	2025-04-11 20:59:11
2024-08-12	385	-1	\N	2256.94999999999982	USD	2024-08-12 12:42:45
2025-01-27	401	297	paypal	1375.26999999999998	EUR	2025-01-27 18:02:47
2024-12-12	386	1177	\N	2238.34000000000015	USD	2024-12-12 18:58:37
2024-09-27	402	377	bank_transfer	893.539999999999964	USD	2024-09-27 07:52:44
2025-04-29	387	612	paypal	566.330000000000041	USD	2025-04-29 20:47:24
2025-04-14	405	370	\N	2230.88999999999987	RUB	2025-04-14 17:08:18
2025-04-10	396	71	\N	664.240000000000009	USD	2025-04-10 00:59:11
2026-05-22	407	162	\N	301.230000000000018	RUB	2026-05-22 06:06:58
2024-12-01	398	1016	paypal	1537.75999999999999	USD	2024-12-01 17:17:20
2026-04-14	408	275	bank_transfer	2458.65999999999985	EUR	2026-04-14 01:43:11
2024-07-22	399	573	\N	377.449999999999989	USD	2024-07-22 08:56:54
2026-05-20	409	230	\N	2484.94000000000005	USD	2026-05-20 18:52:21
2025-03-21	411	585	\N	2420.15999999999985	EUR	2025-03-21 21:37:52
2026-03-31	419	841	bank_transfer	490.009999999999991	EUR	2026-03-31 07:13:19
2025-10-24	413	20	bank_transfer	657.399999999999977	EUR	2025-10-24 05:51:56
2025-11-14	420	345	card	1306.45000000000005	USD	2025-11-14 21:03:45
2026-02-17	417	405	bank_transfer	1831.63000000000011	USD	2026-02-17 10:08:14
2025-04-12	423	598	\N	81.4500000000000028	EUR	2025-04-12 10:49:31
2025-10-29	427	1192	\N	1493.52999999999997	RUB	2025-10-29 22:32:59
2024-09-21	430	48	bank_transfer	2999.92999999999984	RUB	2024-09-21 01:19:30
2025-03-29	431	501	\N	672.970000000000027	USD	2025-03-29 08:21:21
2025-05-31	432	190	bank_transfer	2790.11999999999989	RUB	2025-05-31 02:22:39
2026-05-07	433	633	paypal	792.230000000000018	USD	2026-05-07 13:09:50
2026-02-20	440	592	card	683.029999999999973	USD	2026-02-20 22:48:57
2025-03-19	434	25	card	583.559999999999945	EUR	2025-03-19 01:12:53
2024-10-21	442	466	bank_transfer	801	RUB	2024-10-21 03:09:24
2026-03-28	441	710	card	2883.69999999999982	EUR	2026-03-28 15:45:22
2024-07-08	443	456	bank_transfer	2913.40000000000009	EUR	2024-07-08 08:24:05
2024-12-05	448	837	card	1812.80999999999995	USD	2024-12-05 19:54:45
2025-06-05	445	858	card	2109.63000000000011	RUB	2025-06-05 00:02:49
2026-01-11	451	719	card	2210.32000000000016	USD	2026-01-11 04:04:17
2025-09-17	450	411	paypal	287.399999999999977	RUB	2025-09-17 07:04:03
2026-04-24	463	970	\N	2571.65000000000009	USD	2026-04-24 13:22:57
2024-11-22	453	530	bank_transfer	2211.57999999999993	EUR	2024-11-22 11:15:13
2026-03-01	474	830	bank_transfer	2408.07999999999993	USD	2026-03-01 23:49:19
2025-08-13	454	364	paypal	2181.71000000000004	EUR	2025-08-13 21:25:43
2026-02-19	477	823	card	575.730000000000018	EUR	2026-02-19 20:43:04
2025-04-20	467	775	paypal	179.870000000000005	USD	2025-04-20 10:17:19
2026-04-05	478	491	\N	1841.68000000000006	USD	2026-04-05 19:26:56
2024-12-19	468	518	bank_transfer	469.430000000000007	USD	2024-12-19 18:12:54
2025-06-02	480	216	\N	623.850000000000023	RUB	2025-06-02 02:43:59
2025-09-27	472	-1	bank_transfer	1298.51999999999998	RUB	2025-09-27 08:35:49
2024-07-29	483	203	\N	737.289999999999964	RUB	2024-07-29 08:06:35
2025-07-07	481	102	card	2487.65000000000009	USD	2025-07-07 02:53:37
2024-08-15	488	968	paypal	1026.33999999999992	RUB	2024-08-15 16:31:12
2025-04-22	489	8	\N	1594.88000000000011	USD	2025-04-22 12:41:48
2024-08-13	492	416	\N	1420.54999999999995	EUR	2024-08-13 00:12:28
2026-03-20	496	348	bank_transfer	1407.25999999999999	RUB	2026-03-20 05:34:03
2024-09-22	497	437	\N	2607.01999999999998	USD	2024-09-22 04:19:08
\N	503	405	bank_transfer	236.639999999999986	USD	\N
2025-06-10	499	934	bank_transfer	2013.28999999999996	EUR	2025-06-10 01:17:50
2024-12-25	507	-1	card	50.4500000000000028	USD	2024-12-25 14:48:31
2025-04-16	504	529	paypal	2938.09000000000015	EUR	2025-04-16 18:30:07
2024-08-26	510	-1	bank_transfer	886.590000000000032	USD	2024-08-26 08:28:35
\N	511	35	card	943.379999999999995	EUR	\N
2024-12-28	523	33	paypal	1470.28999999999996	EUR	2024-12-28 19:10:30
2024-10-07	517	94	\N	1099.59999999999991	USD	2024-10-07 16:24:37
2024-06-09	527	854	\N	1558.25999999999999	EUR	2024-06-09 16:21:30
2025-03-07	518	600	\N	696.710000000000036	RUB	2025-03-07 13:05:27
2025-12-05	529	693	paypal	2837.86999999999989	RUB	2025-12-05 23:45:41
2026-03-10	521	540	\N	2484.19000000000005	RUB	2026-03-10 08:26:29
2026-01-19	532	540	\N	175.310000000000002	RUB	2026-01-19 03:26:02
2025-09-26	528	424	paypal	425.600000000000023	EUR	2025-09-26 03:29:47
2025-10-08	534	-1	paypal	37.9600000000000009	EUR	2025-10-08 08:25:38
2024-06-05	536	659	\N	2855.59999999999991	EUR	2024-06-05 15:47:57
2025-11-02	538	158	card	1030.22000000000003	USD	2025-11-02 22:14:28
2024-09-29	544	550	\N	1858.02999999999997	RUB	2024-09-29 01:45:44
2025-06-11	540	423	paypal	2583.73000000000002	USD	2025-06-11 00:04:45
2025-09-21	551	23	card	1348.02999999999997	EUR	2025-09-21 11:23:04
2025-06-19	542	1004	\N	2289.5	RUB	2025-06-19 02:54:01
2024-12-12	553	232	\N	2752.11999999999989	USD	2024-12-12 15:12:54
2025-12-18	545	213	\N	1669.30999999999995	RUB	2025-12-18 23:10:47
2024-12-30	562	-1	bank_transfer	2932.15000000000009	USD	2024-12-30 13:56:25
2024-05-26	546	384	card	43.4299999999999997	USD	2024-05-26 13:10:27
2026-01-16	566	761	bank_transfer	158.439999999999998	USD	2026-01-16 11:34:15
2025-07-29	547	1126	card	2245.69000000000005	USD	2025-07-29 08:00:34
2025-03-13	569	316	bank_transfer	2873.07000000000016	RUB	2025-03-13 10:40:12
2025-11-30	501	747	paypal	1866.83999999999992	USD	2025-11-30 12:00:31
2025-05-22	570	233	paypal	2419.9699999999998	EUR	2025-05-22 08:12:21
2025-07-11	502	611	paypal	979.129999999999995	EUR	2025-07-11 19:23:07
2024-08-11	575	473	card	1701.71000000000004	USD	2024-08-11 22:22:23
2026-03-18	506	136	paypal	428.120000000000005	USD	2026-03-18 04:45:51
2025-12-30	576	186	paypal	2498.32999999999993	RUB	2025-12-30 17:31:43
2025-05-17	508	755	card	962.850000000000023	EUR	2025-05-17 12:52:05
2025-09-03	577	805	bank_transfer	191.449999999999989	RUB	2025-09-03 18:09:54
2025-06-25	509	1127	\N	1439.28999999999996	RUB	2025-06-25 19:35:35
2024-11-24	581	-1	card	296.860000000000014	RUB	2024-11-24 07:50:22
2025-04-28	514	228	paypal	755.409999999999968	RUB	2025-04-28 02:59:42
2025-10-19	582	470	card	414.670000000000016	EUR	2025-10-19 15:09:44
2024-05-27	515	675	card	2315.88000000000011	USD	2024-05-27 22:04:56
2024-11-20	586	1170	paypal	1356.74000000000001	RUB	2024-11-20 09:38:09
2025-07-19	520	944	paypal	129.300000000000011	USD	2025-07-19 21:10:23
2024-08-31	600	896	\N	1633.63000000000011	USD	2024-08-31 16:13:27
2026-04-27	522	126	paypal	2984.82999999999993	USD	2026-04-27 07:30:25
2026-01-17	604	18	card	1675.24000000000001	RUB	2026-01-17 03:53:20
2025-04-01	535	671	\N	616.039999999999964	EUR	2025-04-01 19:00:41
2026-03-29	610	702	card	\N	RUB	2026-03-29 04:34:03
2025-02-08	537	949	\N	192.159999999999997	RUB	2025-02-08 22:18:11
2025-09-10	616	820	card	1467.83999999999992	RUB	2025-09-10 08:27:14
2024-11-09	539	371	\N	2496.90000000000009	USD	2024-11-09 09:22:42
2024-08-30	618	725	card	858.509999999999991	USD	2024-08-30 11:25:12
2025-11-21	541	988	card	2124.38000000000011	USD	2025-11-21 10:19:47
2026-01-20	628	41	card	2577.88000000000011	EUR	2026-01-20 19:11:06
2026-04-17	548	815	bank_transfer	2990.71000000000004	EUR	2026-04-17 21:12:38
2024-06-28	640	934	bank_transfer	1912.56999999999994	EUR	2024-06-28 19:24:42
2024-06-03	550	165	\N	2652.94000000000005	USD	2024-06-03 00:36:05
2025-10-21	649	902	paypal	1537.40000000000009	USD	2025-10-21 09:04:00
2024-10-19	556	1127	bank_transfer	485.699999999999989	USD	2024-10-19 03:46:59
2025-05-02	651	974	bank_transfer	2209.98999999999978	USD	2025-05-02 15:49:53
2025-01-18	560	860	\N	2454.9699999999998	EUR	2025-01-18 05:22:40
2025-04-01	656	242	\N	1917.67000000000007	USD	2025-04-01 16:25:50
2025-08-26	564	846	card	1267.71000000000004	USD	2025-08-26 07:24:27
2026-04-04	657	160	\N	801.840000000000032	RUB	2026-04-04 18:41:30
2024-06-29	565	212	paypal	\N	RUB	2024-06-29 18:26:48
2024-11-02	666	-1	card	2317.82999999999993	USD	2024-11-02 12:56:40
2024-11-22	580	-1	bank_transfer	496.95999999999998	RUB	2024-11-22 22:03:17
2024-12-06	677	612	card	2812.01000000000022	EUR	2024-12-06 19:33:28
2025-04-26	584	817	bank_transfer	969.139999999999986	EUR	2025-04-26 00:16:55
2024-09-08	678	1105	card	2641.90999999999985	RUB	2024-09-08 14:17:13
2024-10-21	590	102	\N	1926.74000000000001	EUR	2024-10-21 10:34:38
2024-09-01	688	-1	paypal	822.580000000000041	RUB	2024-09-01 10:10:20
\N	594	1112	\N	557.389999999999986	EUR	\N
2026-05-16	700	312	paypal	1120.93000000000006	USD	2026-05-16 08:22:12
2024-11-24	601	546	\N	1225.5	EUR	2024-11-24 09:26:11
2025-08-18	701	950	\N	707.850000000000023	EUR	2025-08-18 18:56:13
2025-06-24	603	1200	\N	2627.19000000000005	USD	2025-06-24 16:45:53
2025-03-04	702	1162	\N	1764.22000000000003	RUB	2025-03-04 21:57:12
2025-12-10	607	333	paypal	57.8800000000000026	EUR	2025-12-10 07:55:45
2025-04-21	703	526	paypal	2717.13999999999987	RUB	2025-04-21 14:12:37
2025-09-27	611	584	card	1096.69000000000005	USD	2025-09-27 22:30:58
2025-08-09	705	1166	\N	1163.81999999999994	USD	2025-08-09 14:53:53
2025-08-12	612	173	paypal	2157.19000000000005	USD	2025-08-12 12:27:43
2026-05-15	708	819	\N	975.440000000000055	RUB	2026-05-15 02:44:40
2025-04-21	613	276	paypal	1124.78999999999996	EUR	2025-04-21 10:21:50
2024-08-14	710	1072	bank_transfer	381.829999999999984	RUB	2024-08-14 13:01:40
2025-02-20	617	893	paypal	2250.11999999999989	EUR	2025-02-20 13:49:26
2025-12-09	713	956	\N	882.990000000000009	USD	2025-12-09 08:40:51
2025-01-17	620	457	card	1345.18000000000006	USD	2025-01-17 11:31:49
2026-03-23	715	446	bank_transfer	2614.73000000000002	USD	2026-03-23 05:38:01
2025-09-30	622	191	\N	2811.82999999999993	EUR	2025-09-30 13:30:04
2024-10-08	720	993	\N	1023.75999999999999	EUR	2024-10-08 19:55:09
2025-05-09	626	599	paypal	2578.78999999999996	RUB	2025-05-09 16:25:58
2024-06-12	726	14	bank_transfer	2747.75	USD	2024-06-12 17:43:12
2026-01-24	631	687	paypal	521.289999999999964	RUB	2026-01-24 04:37:23
2025-07-30	729	403	paypal	308.860000000000014	USD	2025-07-30 02:20:35
2025-10-29	634	958	paypal	1265.70000000000005	USD	2025-10-29 01:20:35
2024-10-02	730	859	card	1499.05999999999995	RUB	2024-10-02 18:38:35
2024-06-05	635	25	card	1556.83999999999992	RUB	2024-06-05 10:26:23
2024-07-09	731	684	card	2290.15000000000009	RUB	2024-07-09 13:39:31
2025-02-07	648	547	\N	2700.28999999999996	RUB	2025-02-07 13:45:24
2025-08-27	744	26	bank_transfer	\N	EUR	2025-08-27 03:25:32
2025-10-25	650	247	paypal	2455.92000000000007	USD	2025-10-25 09:39:12
2024-11-03	746	167	card	2770.90000000000009	RUB	2024-11-03 01:03:59
2024-08-08	652	1039	\N	1850.6400000000001	EUR	2024-08-08 19:26:19
2025-09-04	751	702	\N	1808.93000000000006	USD	2025-09-04 07:25:49
2025-01-13	655	661	card	91.730000000000004	RUB	2025-01-13 19:59:37
2024-06-03	752	960	bank_transfer	616.259999999999991	EUR	2024-06-03 00:45:06
2024-08-22	658	383	card	2175.40000000000009	USD	2024-08-22 06:53:38
2025-10-20	756	578	paypal	2520.51000000000022	USD	2025-10-20 07:53:34
2025-10-11	662	418	paypal	478.680000000000007	EUR	2025-10-11 23:09:38
2025-04-22	771	-1	\N	405.20999999999998	EUR	2025-04-22 14:23:21
2024-07-25	663	1094	\N	289.5	EUR	2024-07-25 23:53:50
2026-05-05	778	560	paypal	2804.65000000000009	USD	2026-05-05 22:05:01
2024-07-03	664	324	card	1840.01999999999998	USD	2024-07-03 21:39:45
2024-12-09	779	577	bank_transfer	970.690000000000055	EUR	2024-12-09 06:47:58
2025-07-29	670	503	card	1693.00999999999999	RUB	2025-07-29 04:40:40
2025-10-26	781	1085	paypal	1653.1099999999999	EUR	2025-10-26 12:41:48
2024-07-04	671	155	\N	457.160000000000025	RUB	2024-07-04 06:47:49
2025-07-08	787	129	bank_transfer	67.7900000000000063	RUB	2025-07-08 18:51:30
2025-01-12	672	12	\N	1625.55999999999995	RUB	2025-01-12 18:57:18
2024-06-19	792	542	bank_transfer	1338.17000000000007	USD	2024-06-19 03:06:27
2024-12-25	673	234	bank_transfer	1143.18000000000006	RUB	2024-12-25 02:06:40
2025-10-25	798	381	paypal	2865.44000000000005	RUB	2025-10-25 07:16:42
2025-12-22	675	291	card	1958.46000000000004	EUR	2025-12-22 00:49:03
2024-10-22	800	381	paypal	2569.51000000000022	USD	2024-10-22 12:21:40
2026-04-09	679	931	paypal	1929.04999999999995	EUR	2026-04-09 04:35:06
2026-03-03	806	1096	bank_transfer	1873.41000000000008	RUB	2026-03-03 03:55:58
2025-12-22	684	231	\N	1628.71000000000004	USD	2025-12-22 07:35:07
2025-11-13	808	387	paypal	\N	USD	2025-11-13 02:52:25
2026-05-11	691	39	card	1979.74000000000001	USD	2026-05-11 21:02:35
2026-01-25	810	-1	card	230.389999999999986	RUB	2026-01-25 16:07:29
2024-11-19	692	375	bank_transfer	2871.34000000000015	RUB	2024-11-19 17:49:39
2024-11-29	815	-1	paypal	2026.83999999999992	USD	2024-11-29 11:38:40
2024-09-05	696	1027	card	1077.48000000000002	RUB	2024-09-05 17:38:04
2024-09-28	817	823	bank_transfer	1528.56999999999994	RUB	2024-09-28 21:13:39
2026-04-27	697	571	card	1607.71000000000004	USD	2026-04-27 18:09:45
2024-09-23	819	642	paypal	729.360000000000014	RUB	2024-09-23 08:55:20
2026-05-04	709	889	card	1496.3900000000001	EUR	2026-05-04 01:08:47
2025-04-06	821	271	\N	1429.28999999999996	EUR	2025-04-06 13:48:08
2025-01-07	711	1082	paypal	2443.0300000000002	RUB	2025-01-07 00:44:23
2024-10-04	833	1152	bank_transfer	2603.73000000000002	USD	2024-10-04 17:10:50
2025-04-15	721	535	\N	1833.72000000000003	USD	2025-04-15 05:15:40
2026-03-09	841	1099	bank_transfer	931.720000000000027	EUR	2026-03-09 06:54:53
2025-12-05	723	9	card	2963.46000000000004	EUR	2025-12-05 08:55:57
2026-02-17	844	413	\N	2571.82000000000016	USD	2026-02-17 23:55:23
2026-01-01	725	984	paypal	319.5	RUB	2026-01-01 09:32:51
2024-11-15	847	569	bank_transfer	2202.7199999999998	EUR	2024-11-15 04:09:11
2026-03-28	727	335	bank_transfer	2390.30000000000018	USD	2026-03-28 04:34:17
2025-05-18	853	607	card	224.759999999999991	USD	2025-05-18 19:47:21
2025-10-15	733	636	bank_transfer	2200.65000000000009	EUR	2025-10-15 18:44:37
2024-08-12	854	833	\N	2408.98999999999978	USD	2024-08-12 09:34:38
2025-07-02	738	990	paypal	1680.94000000000005	RUB	2025-07-02 01:06:15
2024-08-10	858	100	paypal	536.610000000000014	USD	2024-08-10 23:59:01
2026-04-24	741	196	bank_transfer	24.3399999999999999	EUR	2026-04-24 11:22:32
2025-01-09	862	551	card	2525.2800000000002	USD	2025-01-09 01:59:57
2024-06-05	742	750	paypal	796.5	RUB	2024-06-05 04:07:35
2025-05-18	864	1008	bank_transfer	1402.83999999999992	RUB	2025-05-18 14:58:55
2025-09-30	747	82	paypal	642.840000000000032	RUB	2025-09-30 20:32:45
2025-02-02	869	681	bank_transfer	2735.82000000000016	RUB	2025-02-02 12:09:48
2025-01-21	749	659	paypal	1345.54999999999995	RUB	2025-01-21 04:20:17
2024-10-16	871	942	\N	697.529999999999973	EUR	2024-10-16 21:19:56
2025-06-02	750	579	\N	2099.48999999999978	RUB	2025-06-02 03:09:19
2026-03-20	873	1071	paypal	1550.19000000000005	USD	2026-03-20 07:17:01
2025-11-26	753	110	\N	2553.01000000000022	EUR	2025-11-26 03:04:31
2024-06-28	874	-1	bank_transfer	31.0100000000000016	RUB	2024-06-28 19:18:17
2024-06-17	754	990	card	146.860000000000014	RUB	2024-06-17 02:26:10
2024-05-26	875	567	card	1569.59999999999991	RUB	2024-05-26 14:51:24
2025-08-30	755	-1	card	521.200000000000045	RUB	2025-08-30 00:48:38
2025-05-22	876	345	\N	1272.45000000000005	USD	2025-05-22 12:28:58
2024-07-24	757	799	\N	293.79000000000002	USD	2024-07-24 03:25:31
2026-04-16	878	1058	paypal	1388.54999999999995	USD	2026-04-16 02:04:49
2025-11-12	761	15	\N	954.350000000000023	EUR	2025-11-12 07:39:46
2024-06-17	880	178	bank_transfer	2533.40000000000009	USD	2024-06-17 12:00:35
2025-08-07	762	984	card	2856.88000000000011	RUB	2025-08-07 20:08:27
2024-08-17	881	185	\N	2945.53999999999996	RUB	2024-08-17 13:58:12
2025-12-13	765	996	\N	746.759999999999991	EUR	2025-12-13 02:09:35
2025-04-23	884	971	card	721.990000000000009	EUR	2025-04-23 09:41:18
2025-04-03	770	18	bank_transfer	724.779999999999973	USD	2025-04-03 23:46:18
2025-08-20	893	1128	\N	1226.8599999999999	EUR	2025-08-20 07:00:16
2026-01-09	772	23	paypal	2515.51000000000022	RUB	2026-01-09 08:28:55
2025-10-13	896	-1	bank_transfer	2808.25	RUB	2025-10-13 08:21:19
2026-01-06	775	751	paypal	2275.78999999999996	USD	2026-01-06 23:29:44
2026-02-24	898	55	\N	2356.73000000000002	USD	2026-02-24 07:21:12
2024-07-01	777	950	bank_transfer	2155.48999999999978	EUR	2024-07-01 07:46:52
2024-10-02	902	497	bank_transfer	925.289999999999964	USD	2024-10-02 12:05:34
2024-07-04	783	306	card	2603.5300000000002	EUR	2024-07-04 07:22:19
2026-01-08	912	806	card	1616.54999999999995	RUB	2026-01-08 16:24:09
2024-07-24	785	286	bank_transfer	2909.13000000000011	RUB	2024-07-24 13:40:44
2026-02-16	913	923	\N	131.669999999999987	RUB	2026-02-16 17:02:12
2025-02-15	788	9	card	1108.19000000000005	EUR	2025-02-15 21:25:28
2025-11-30	917	276	bank_transfer	2446.92000000000007	EUR	2025-11-30 10:24:14
2025-04-20	794	164	\N	2173.59000000000015	EUR	2025-04-20 20:35:27
2026-02-15	919	329	paypal	2835.80999999999995	RUB	2026-02-15 22:23:52
2026-02-24	801	389	paypal	1818.33999999999992	RUB	2026-02-24 08:14:07
2025-02-17	921	1146	bank_transfer	132.47999999999999	RUB	2025-02-17 10:42:48
2025-10-03	802	273	paypal	2125.2800000000002	RUB	2025-10-03 13:49:16
2024-08-17	923	764	card	914.259999999999991	RUB	2024-08-17 00:05:23
2024-07-03	803	382	paypal	2994.90999999999985	EUR	2024-07-03 12:10:44
2024-11-10	925	598	\N	91.4200000000000017	EUR	2024-11-10 23:02:32
2024-10-29	805	900	\N	2581.21000000000004	USD	2024-10-29 11:50:07
2026-01-12	926	708	bank_transfer	2132.88000000000011	RUB	2026-01-12 20:00:41
2024-07-30	809	609	\N	1558.47000000000003	RUB	2024-07-30 09:38:39
2025-06-03	949	1122	bank_transfer	154.039999999999992	USD	2025-06-03 21:54:45
2025-01-30	814	583	paypal	107.769999999999996	USD	2025-01-30 12:38:05
2024-09-14	951	1126	\N	2342.86999999999989	EUR	2024-09-14 05:05:55
2025-10-03	826	-1	\N	231.5	RUB	2025-10-03 07:08:55
2025-08-07	955	534	\N	2491.78999999999996	RUB	2025-08-07 02:13:00
2025-09-12	827	-1	\N	1766.86999999999989	RUB	2025-09-12 23:15:04
2025-05-23	956	131	paypal	1560.82999999999993	RUB	2025-05-23 01:25:22
2025-05-14	831	270	paypal	2329.73000000000002	RUB	2025-05-14 14:31:10
2024-08-10	958	107	bank_transfer	1958.88000000000011	RUB	2024-08-10 11:29:05
2025-07-09	832	322	card	786.629999999999995	RUB	2025-07-09 22:01:57
2024-10-19	962	93	\N	2399.32999999999993	RUB	2024-10-19 05:08:49
2024-08-24	842	909	bank_transfer	93.0100000000000051	RUB	2024-08-24 23:11:29
2025-05-02	973	774	paypal	408.870000000000005	RUB	2025-05-02 14:08:42
2025-06-20	849	964	\N	1069.15000000000009	EUR	2025-06-20 10:23:03
2025-01-07	978	612	bank_transfer	396.199999999999989	RUB	2025-01-07 14:03:22
2025-12-12	850	692	\N	37.0499999999999972	RUB	2025-12-12 03:55:53
2026-05-13	980	1195	bank_transfer	596.110000000000014	USD	2026-05-13 21:58:10
2026-01-15	851	147	\N	2570.38999999999987	EUR	2026-01-15 01:15:41
2024-08-22	983	364	\N	1081.50999999999999	EUR	2024-08-22 11:23:48
2024-09-18	852	526	bank_transfer	1071.6400000000001	EUR	2024-09-18 10:29:34
2025-04-24	986	969	bank_transfer	2750.03999999999996	USD	2025-04-24 11:14:44
2024-07-10	859	142	paypal	2949.69999999999982	EUR	2024-07-10 21:13:47
2024-05-27	988	807	\N	2336.80999999999995	RUB	2024-05-27 21:42:12
2024-10-30	863	612	bank_transfer	1100.48000000000002	USD	2024-10-30 01:37:30
2025-04-01	997	159	\N	1833.08999999999992	USD	2025-04-01 13:07:32
2026-01-26	867	-1	bank_transfer	1980.43000000000006	EUR	2026-01-26 18:38:24
2025-09-27	999	946	card	2692.86999999999989	USD	2025-09-27 12:40:55
2024-11-19	872	233	bank_transfer	1607.11999999999989	USD	2024-11-19 04:42:55
2024-06-18	571	69	paypal	865.370000000000005	EUR	2024-06-18 00:29:09
2025-08-23	885	311	paypal	1881.52999999999997	USD	2025-08-23 08:26:05
2025-06-30	573	333	bank_transfer	597.049999999999955	USD	2025-06-30 10:40:53
2025-02-22	887	918	card	2621.30000000000018	RUB	2025-02-22 13:26:14
2024-12-13	574	15	card	1194.46000000000004	EUR	2024-12-13 17:38:06
2025-03-19	888	915	bank_transfer	2667.94000000000005	RUB	2025-03-19 14:47:00
2024-12-03	583	868	bank_transfer	1129.68000000000006	EUR	2024-12-03 13:01:06
2024-11-09	891	1195	card	2251.86000000000013	EUR	2024-11-09 01:51:44
2025-03-20	585	-1	\N	326.600000000000023	USD	2025-03-20 15:17:26
2025-11-10	892	757	\N	1492.46000000000004	USD	2025-11-10 22:53:19
2025-03-25	587	282	bank_transfer	2230.63999999999987	USD	2025-03-25 12:28:22
2026-04-03	895	223	paypal	256.240000000000009	USD	2026-04-03 03:21:02
2025-01-21	592	192	paypal	2083.42000000000007	RUB	2025-01-21 06:53:10
2025-06-30	897	317	\N	282.879999999999995	RUB	2025-06-30 05:29:37
2025-02-10	593	1106	card	2459.53999999999996	RUB	2025-02-10 09:04:47
2025-12-19	899	-1	card	2747.92000000000007	USD	2025-12-19 04:22:37
2025-06-09	596	1144	\N	2644.26999999999998	EUR	2025-06-09 06:08:20
2025-06-20	910	106	card	947.860000000000014	USD	2025-06-20 22:11:27
2024-07-28	597	340	bank_transfer	303.920000000000016	EUR	2024-07-28 02:38:48
2024-11-17	911	101	paypal	2809.90000000000009	EUR	2024-11-17 13:57:07
2025-02-17	598	564	card	2154.90999999999985	RUB	2025-02-17 15:35:39
2025-01-11	914	620	bank_transfer	179.240000000000009	EUR	2025-01-11 04:18:43
2025-06-18	602	625	paypal	393.480000000000018	RUB	2025-06-18 12:38:17
2025-01-24	920	1146	paypal	1328.75999999999999	RUB	2025-01-24 22:13:01
2026-04-07	605	831	paypal	566.389999999999986	EUR	2026-04-07 15:49:15
2025-07-01	929	148	bank_transfer	1550.58999999999992	USD	2025-07-01 20:31:36
2024-12-23	608	24	card	279.819999999999993	RUB	2024-12-23 22:54:26
2024-09-13	931	1152	paypal	2670.28999999999996	RUB	2024-09-13 01:31:01
2026-03-12	633	462	\N	2624.96000000000004	USD	2026-03-12 17:45:51
2025-02-22	932	264	paypal	1470.81999999999994	RUB	2025-02-22 02:21:41
2025-08-02	636	641	\N	1029.93000000000006	RUB	2025-08-02 18:53:57
2026-02-27	934	61	\N	1285.75999999999999	RUB	2026-02-27 16:42:49
2024-10-30	639	625	\N	1610.22000000000003	RUB	2024-10-30 06:14:27
2025-03-22	936	851	\N	1389.84999999999991	EUR	2025-03-22 15:43:54
2024-10-07	641	169	\N	652.590000000000032	RUB	2024-10-07 05:13:30
2024-06-07	938	263	paypal	538.210000000000036	RUB	2024-06-07 10:53:10
2025-10-10	642	849	\N	2889.80000000000018	USD	2025-10-10 17:30:21
2025-12-12	940	868	paypal	2700.94000000000005	EUR	2025-12-12 02:09:49
2026-02-10	645	1182	card	464.480000000000018	USD	2026-02-10 13:05:59
2026-01-20	942	827	card	235.060000000000002	EUR	2026-01-20 03:32:55
2026-05-23	653	96	\N	669.730000000000018	EUR	2026-05-23 11:13:17
2025-03-02	945	1003	paypal	2444.40000000000009	EUR	2025-03-02 20:05:36
2025-12-30	659	31	\N	1218.6099999999999	USD	2025-12-30 14:42:50
2024-09-19	947	375	\N	1908.44000000000005	RUB	2024-09-19 14:44:49
2025-03-18	665	481	card	2159.5300000000002	RUB	2025-03-18 23:38:33
2025-06-06	953	518	bank_transfer	1417.08999999999992	EUR	2025-06-06 00:34:48
2024-12-22	674	107	card	1592.55999999999995	EUR	2024-12-22 19:21:47
2025-10-31	957	500	\N	\N	EUR	2025-10-31 13:34:40
2026-01-09	676	235	\N	24.3900000000000006	USD	2026-01-09 03:34:48
2024-11-07	963	931	card	1583.02999999999997	EUR	2024-11-07 23:39:02
2025-07-10	680	1127	paypal	467.660000000000025	RUB	2025-07-10 12:28:15
2025-11-04	968	196	card	992.789999999999964	EUR	2025-11-04 05:50:52
2025-10-01	683	182	card	567.879999999999995	EUR	2025-10-01 01:16:09
2025-05-03	970	291	card	244.659999999999997	USD	2025-05-03 00:03:31
2024-08-23	685	32	card	531.039999999999964	RUB	2024-08-23 06:15:05
2026-02-17	975	458	card	2279.32999999999993	USD	2026-02-17 14:22:37
2025-12-08	686	935	card	\N	RUB	2025-12-08 05:46:51
2026-04-17	976	776	card	698.919999999999959	USD	2026-04-17 05:39:36
2025-06-15	693	121	paypal	1365.01999999999998	RUB	2025-06-15 05:52:36
2025-09-22	979	1196	\N	1339.29999999999995	EUR	2025-09-22 02:14:23
\N	694	602	paypal	1142.63000000000011	EUR	\N
2025-05-25	989	1189	\N	966.990000000000009	USD	2025-05-25 21:54:04
2026-04-20	695	632	card	968.370000000000005	EUR	2026-04-20 20:40:14
2024-10-27	992	321	\N	469.189999999999998	RUB	2024-10-27 03:37:01
2026-04-27	698	1045	paypal	2623.63999999999987	USD	2026-04-27 18:01:28
2026-03-14	995	846	card	2252.26999999999998	EUR	2026-03-14 23:21:26
2025-05-05	704	1155	paypal	1582.81999999999994	USD	2025-05-05 01:27:08
2025-11-10	1000	268	\N	749.629999999999995	USD	2025-11-10 20:11:27
2025-11-02	706	-1	paypal	583.649999999999977	RUB	2025-11-02 10:54:38
2024-06-11	549	147	\N	2489.90000000000009	EUR	2024-06-11 05:18:55
2025-03-09	707	1123	paypal	2746.13999999999987	USD	2025-03-09 23:04:23
2025-08-24	552	940	paypal	1758.24000000000001	EUR	2025-08-24 16:25:15
2025-05-19	712	61	card	272.220000000000027	USD	2025-05-19 08:44:05
2024-06-27	554	495	card	1698.33999999999992	RUB	2024-06-27 01:44:16
2024-12-20	718	278	bank_transfer	995.129999999999995	USD	2024-12-20 23:04:07
2024-07-23	557	261	\N	2102.65999999999985	RUB	2024-07-23 07:50:32
2025-06-15	722	1117	card	2747.80999999999995	RUB	2025-06-15 22:15:19
2025-11-14	559	98	bank_transfer	371.259999999999991	RUB	2025-11-14 21:26:52
2024-07-05	724	919	\N	1983.47000000000003	EUR	2024-07-05 04:09:45
2025-08-20	561	341	bank_transfer	1944.73000000000002	EUR	2025-08-20 14:12:05
2025-07-28	735	264	paypal	1342.92000000000007	EUR	2025-07-28 00:50:25
2025-08-30	567	71	paypal	1866.70000000000005	USD	2025-08-30 03:06:19
2025-09-15	759	245	card	505.769999999999982	RUB	2025-09-15 19:49:19
2026-04-17	568	423	paypal	2698.2800000000002	USD	2026-04-17 09:52:17
2024-10-09	763	403	card	2043.1099999999999	EUR	2024-10-09 16:01:39
2025-11-03	578	293	paypal	1811.41000000000008	EUR	2025-11-03 16:03:00
2026-05-19	764	-1	bank_transfer	2257.13000000000011	RUB	2026-05-19 03:47:37
2025-07-13	579	-1	bank_transfer	1216.44000000000005	EUR	2025-07-13 21:36:29
2025-06-08	767	788	card	1102.6400000000001	RUB	2025-06-08 23:48:36
2024-07-09	588	472	bank_transfer	589.330000000000041	EUR	2024-07-09 12:33:54
2025-10-14	769	678	card	663.919999999999959	EUR	2025-10-14 15:33:33
2026-04-19	589	286	card	49.6000000000000014	RUB	2026-04-19 14:37:17
2026-04-13	773	486	card	150.530000000000001	USD	2026-04-13 09:50:56
2024-07-11	591	955	paypal	2753.63000000000011	EUR	2024-07-11 03:03:49
2025-04-29	776	86	card	1731.94000000000005	RUB	2025-04-29 23:22:12
2026-03-25	595	1177	paypal	143.509999999999991	USD	2026-03-25 12:19:54
2025-02-13	782	816	\N	2661.2199999999998	USD	2025-02-13 13:09:06
2024-11-11	599	1080	paypal	1013.96000000000004	RUB	2024-11-11 00:14:19
2024-07-04	786	316	\N	1280.71000000000004	EUR	2024-07-04 00:27:44
2025-04-10	606	516	paypal	1352.72000000000003	RUB	2025-04-10 14:40:54
2024-07-29	789	867	\N	706.590000000000032	USD	2024-07-29 03:45:42
2024-06-14	609	909	card	2112.44999999999982	USD	2024-06-14 15:05:06
2025-08-13	791	503	bank_transfer	404.269999999999982	EUR	2025-08-13 12:13:25
2024-08-08	614	456	\N	2512.32999999999993	USD	2024-08-08 23:54:39
2024-09-20	793	958	card	309.279999999999973	EUR	2024-09-20 04:46:27
2025-10-28	615	1084	paypal	2090.59000000000015	EUR	2025-10-28 15:09:22
2025-01-07	795	829	paypal	2893.98000000000002	EUR	2025-01-07 20:04:56
2026-03-27	619	556	\N	1725.88000000000011	USD	2026-03-27 11:58:25
2025-03-16	804	943	\N	735.419999999999959	RUB	2025-03-16 09:42:58
2025-11-07	621	235	card	2949.46000000000004	RUB	2025-11-07 23:45:07
2024-10-19	811	673	bank_transfer	1460.15000000000009	RUB	2024-10-19 06:12:08
2025-08-20	623	715	bank_transfer	428.910000000000025	EUR	2025-08-20 18:20:15
2025-08-05	813	1129	paypal	1713.80999999999995	USD	2025-08-05 23:53:40
2024-10-20	624	951	\N	366.589999999999975	RUB	2024-10-20 04:15:48
2024-09-03	823	5	\N	1371.25999999999999	USD	2024-09-03 02:16:23
2024-10-02	625	861	card	2686.38000000000011	EUR	2024-10-02 05:12:27
2025-05-09	824	391	bank_transfer	61.1000000000000014	RUB	2025-05-09 05:39:52
2024-07-06	627	143	\N	2924.53999999999996	EUR	2024-07-06 14:17:39
2024-12-07	825	538	\N	2543.90999999999985	RUB	2024-12-07 18:51:36
2024-06-21	629	375	card	1866.76999999999998	USD	2024-06-21 04:31:36
2025-05-30	829	-1	bank_transfer	1804.25	EUR	2025-05-30 11:22:12
2025-01-16	630	548	card	875.350000000000023	EUR	2025-01-16 17:36:01
2025-02-21	834	923	\N	\N	RUB	2025-02-21 11:47:36
2025-07-03	632	23	paypal	2475.26999999999998	EUR	2025-07-03 12:50:21
2026-03-09	836	331	bank_transfer	914.509999999999991	EUR	2026-03-09 00:24:06
2024-09-06	637	571	paypal	2831.94999999999982	EUR	2024-09-06 05:53:04
2025-04-20	837	132	paypal	2151.09000000000015	USD	2025-04-20 09:57:38
2024-08-19	638	67	paypal	2345.09000000000015	EUR	2024-08-19 18:17:58
2025-03-31	838	990	card	630.990000000000009	EUR	2025-03-31 22:46:56
2024-06-08	643	1134	card	2044.72000000000003	EUR	2024-06-08 06:35:56
2025-06-23	839	795	card	1978.65000000000009	EUR	2025-06-23 02:08:06
2024-11-19	644	764	card	1984.18000000000006	USD	2024-11-19 23:01:19
2025-06-12	840	524	bank_transfer	2098.63000000000011	EUR	2025-06-12 10:40:30
2024-07-21	646	931	\N	2335.67000000000007	USD	2024-07-21 01:28:07
2025-06-24	843	1110	paypal	2329.63000000000011	USD	2025-06-24 09:53:01
2026-03-15	647	878	card	884.370000000000005	EUR	2026-03-15 18:14:38
2025-11-05	845	289	\N	171.069999999999993	USD	2025-11-05 19:39:36
2025-04-24	654	347	\N	2259.26000000000022	EUR	2025-04-24 11:31:58
2025-08-30	848	672	bank_transfer	2003.22000000000003	EUR	2025-08-30 06:33:39
2025-02-05	660	1043	card	2831.65000000000009	RUB	2025-02-05 09:02:21
2024-06-10	860	136	\N	\N	RUB	2024-06-10 06:57:55
2024-07-15	661	1005	card	2985.69000000000005	RUB	2024-07-15 11:35:00
2026-02-23	861	1180	\N	1464.68000000000006	USD	2026-02-23 01:38:48
2024-10-06	667	858	\N	861.190000000000055	USD	2024-10-06 18:49:34
2025-03-17	868	478	card	458.470000000000027	EUR	2025-03-17 05:26:41
2025-08-31	668	697	\N	2981.76999999999998	USD	2025-08-31 00:14:35
2025-11-16	882	782	bank_transfer	1511.95000000000005	EUR	2025-11-16 22:23:21
2024-09-03	669	333	bank_transfer	25.9400000000000013	USD	2024-09-03 04:29:29
2026-04-06	889	1017	bank_transfer	793.279999999999973	EUR	2026-04-06 17:08:23
2025-03-03	681	1079	bank_transfer	2612.94999999999982	USD	2025-03-03 02:47:25
2025-03-31	903	848	paypal	1273.75	USD	2025-03-31 01:01:57
2024-08-08	682	1040	bank_transfer	\N	RUB	2024-08-08 22:23:10
2026-05-07	905	447	card	2224.40999999999985	EUR	2026-05-07 13:28:42
2025-10-05	687	399	bank_transfer	2277.07999999999993	EUR	2025-10-05 03:08:03
2025-03-09	906	652	\N	1001.22000000000003	RUB	2025-03-09 08:42:34
2025-10-17	689	993	card	774.17999999999995	USD	2025-10-17 20:45:22
2025-01-25	907	1075	\N	2717.09999999999991	RUB	2025-01-25 18:06:40
2025-12-29	690	293	bank_transfer	552.360000000000014	USD	2025-12-29 10:50:50
2025-07-23	908	561	bank_transfer	1818.44000000000005	EUR	2025-07-23 22:42:05
2024-08-15	699	1021	paypal	1069.78999999999996	RUB	2024-08-15 23:06:18
2024-07-31	909	429	card	153.240000000000009	USD	2024-07-31 23:16:08
2026-02-17	714	625	paypal	2523.42999999999984	USD	2026-02-17 23:02:04
2025-04-04	915	969	bank_transfer	1290.52999999999997	USD	2025-04-04 04:01:21
2024-06-10	716	659	paypal	69.7099999999999937	RUB	2024-06-10 21:10:36
2026-02-21	916	867	\N	2746.63999999999987	EUR	2026-02-21 15:04:37
2024-08-09	717	-1	\N	2533.98000000000002	RUB	2024-08-09 19:01:27
2026-01-14	918	244	bank_transfer	671.519999999999982	RUB	2026-01-14 05:11:36
2025-10-01	719	114	paypal	1001.92999999999995	USD	2025-10-01 23:05:07
2024-07-09	924	1195	\N	1053.94000000000005	EUR	2024-07-09 16:58:36
2024-06-03	728	-1	bank_transfer	2893.80999999999995	EUR	2024-06-03 09:29:19
\N	928	331	paypal	\N	USD	\N
2025-04-12	732	83	paypal	610.860000000000014	EUR	2025-04-12 04:23:46
2024-07-29	933	413	card	1227.09999999999991	USD	2024-07-29 16:54:43
2025-12-13	734	1011	\N	874.100000000000023	USD	2025-12-13 11:48:47
2025-06-16	943	718	card	895.419999999999959	EUR	2025-06-16 12:46:28
2025-09-11	736	964	\N	2959.61000000000013	EUR	2025-09-11 21:34:28
2025-08-09	948	190	bank_transfer	1327.24000000000001	RUB	2025-08-09 15:30:57
2026-05-07	737	966	card	247.120000000000005	RUB	2026-05-07 11:23:59
2025-05-07	950	131	paypal	2918.94999999999982	EUR	2025-05-07 04:21:35
2025-08-04	739	549	bank_transfer	516.049999999999955	EUR	2025-08-04 02:05:46
2025-12-24	952	1173	card	439.230000000000018	EUR	2025-12-24 21:41:33
2025-06-08	740	151	bank_transfer	593.909999999999968	RUB	2025-06-08 12:39:20
2024-09-19	954	988	bank_transfer	1146.34999999999991	RUB	2024-09-19 12:10:09
2025-12-13	743	1008	\N	2005.8900000000001	USD	2025-12-13 11:09:35
\N	964	877	paypal	1934.09999999999991	USD	\N
2024-09-12	745	38	paypal	2680.51000000000022	RUB	2024-09-12 16:09:28
2024-11-22	981	-1	paypal	1323.04999999999995	EUR	2024-11-22 04:00:05
2025-08-24	748	571	card	1127.80999999999995	RUB	2025-08-24 11:20:27
2026-02-15	984	548	\N	1125.3599999999999	EUR	2026-02-15 11:53:37
2025-02-20	758	1149	card	306.819999999999993	EUR	2025-02-20 10:50:41
2026-01-30	985	1047	card	2882.11000000000013	RUB	2026-01-30 13:45:56
2025-08-03	760	326	paypal	1975.47000000000003	USD	2025-08-03 14:19:42
2024-10-07	990	695	paypal	2290.42999999999984	USD	2024-10-07 20:11:46
2025-01-14	766	1181	\N	414.170000000000016	USD	2025-01-14 04:26:04
2025-10-15	991	796	\N	883.120000000000005	RUB	2025-10-15 16:24:17
2025-07-01	768	1138	\N	\N	USD	2025-07-01 23:54:52
2026-02-06	998	171	card	1076.3599999999999	EUR	2026-02-06 19:58:41
2025-10-27	774	324	paypal	1107.21000000000004	EUR	2025-10-27 00:06:31
2024-08-01	780	-1	card	690.879999999999995	RUB	2024-08-01 14:23:31
2025-03-21	784	779	card	1857.25999999999999	USD	2025-03-21 20:33:22
2026-02-16	790	1172	card	961.779999999999973	EUR	2026-02-16 17:21:24
2025-12-03	796	399	bank_transfer	1003.69000000000005	RUB	2025-12-03 21:37:30
2024-09-25	797	943	\N	1829.67000000000007	RUB	2024-09-25 05:49:09
2025-11-15	799	182	bank_transfer	2088.30999999999995	USD	2025-11-15 10:37:42
2024-08-25	807	45	card	439.259999999999991	EUR	2024-08-25 06:03:33
2025-08-31	812	907	bank_transfer	1039.45000000000005	EUR	2025-08-31 17:52:30
2025-09-19	816	155	\N	1488.43000000000006	RUB	2025-09-19 01:22:21
2026-04-11	818	425	bank_transfer	1444.8599999999999	USD	2026-04-11 08:42:58
2024-12-31	820	174	card	1520.20000000000005	RUB	2024-12-31 17:06:30
2024-06-24	822	752	paypal	75.1400000000000006	EUR	2024-06-24 01:44:55
2026-05-16	828	-1	card	1731.46000000000004	EUR	2026-05-16 17:20:32
2024-12-03	830	426	paypal	62.3299999999999983	EUR	2024-12-03 02:58:15
2024-05-24	835	396	bank_transfer	2103.05999999999995	EUR	2024-05-24 10:14:41
2025-03-11	846	661	bank_transfer	1164.8900000000001	EUR	2025-03-11 18:16:52
2024-07-08	855	963	card	1547.42000000000007	RUB	2024-07-08 01:40:49
2024-09-04	856	398	card	\N	RUB	2024-09-04 10:47:33
2025-03-07	857	435	\N	908.92999999999995	USD	2025-03-07 12:32:31
2026-01-21	865	457	bank_transfer	\N	RUB	2026-01-21 09:27:18
2025-09-04	866	1124	card	76.1400000000000006	USD	2025-09-04 10:06:13
2024-08-07	870	640	paypal	\N	USD	2024-08-07 03:26:23
2024-08-31	877	-1	bank_transfer	2215.75	USD	2024-08-31 08:18:05
2024-11-03	879	787	\N	2550.92999999999984	USD	2024-11-03 02:47:28
2025-12-16	883	48	\N	1698.11999999999989	USD	2025-12-16 16:24:01
2025-06-24	886	878	bank_transfer	1425.15000000000009	EUR	2025-06-24 07:04:08
2026-03-29	890	1116	card	623.519999999999982	EUR	2026-03-29 02:53:18
2025-02-09	894	35	\N	631.980000000000018	EUR	2025-02-09 16:43:56
2026-05-16	900	301	paypal	160.280000000000001	EUR	2026-05-16 14:26:18
2026-04-04	901	1048	\N	1668.76999999999998	RUB	2026-04-04 00:36:07
\N	904	998	\N	1028.19000000000005	USD	\N
2024-10-28	922	465	paypal	1992.43000000000006	USD	2024-10-28 11:59:30
2025-08-02	927	549	card	864.639999999999986	EUR	2025-08-02 12:23:04
2025-03-26	930	983	\N	699.220000000000027	RUB	2025-03-26 04:10:00
2024-10-03	935	852	\N	2461.13000000000011	EUR	2024-10-03 06:57:25
2024-10-09	937	808	paypal	\N	EUR	2024-10-09 15:58:16
2025-12-10	939	1115	card	2102.86999999999989	USD	2025-12-10 11:01:01
\N	941	972	\N	1474.90000000000009	RUB	\N
2024-09-23	944	630	paypal	926.059999999999945	EUR	2024-09-23 07:55:34
2026-01-06	946	731	\N	670.190000000000055	RUB	2026-01-06 04:41:33
2025-04-07	959	984	paypal	173.759999999999991	USD	2025-04-07 09:36:55
2024-08-20	960	133	bank_transfer	949.82000000000005	USD	2024-08-20 12:48:45
2024-07-25	961	213	card	1310.74000000000001	EUR	2024-07-25 23:13:13
2024-11-17	965	540	paypal	2775	RUB	2024-11-17 06:22:16
2025-09-15	966	379	paypal	\N	USD	2025-09-15 15:53:01
2025-04-09	967	687	card	571.360000000000014	RUB	2025-04-09 02:57:23
2026-04-13	969	76	card	2369.01999999999998	EUR	2026-04-13 17:57:24
2025-12-15	971	422	paypal	2949.65000000000009	USD	2025-12-15 15:23:29
2026-02-09	972	655	paypal	424.339999999999975	RUB	2026-02-09 15:04:48
2026-03-17	974	95	card	102.040000000000006	USD	2026-03-17 03:59:51
2024-07-30	977	844	bank_transfer	491.810000000000002	EUR	2024-07-30 00:10:23
2024-07-18	982	364	\N	1992.38000000000011	USD	2024-07-18 18:57:41
2025-12-29	987	327	bank_transfer	762.659999999999968	EUR	2025-12-29 23:40:42
2024-12-27	993	-1	paypal	2099.57000000000016	EUR	2024-12-27 15:44:57
2025-09-01	994	1124	bank_transfer	828.92999999999995	RUB	2025-09-01 11:47:58
2024-11-18	996	-1	paypal	2197.57000000000016	RUB	2024-11-18 14:46:55
\.


-- Completed on 2026-06-16 19:54:05

--
-- PostgreSQL database dump complete
--

