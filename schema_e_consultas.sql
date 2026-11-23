-- Sprint Ágil de Refatoração de Banco de Dados | Cenário 13: Pet Shop e Veterinária | SQLite

PRAGMA foreign_keys = ON;

-- ===================== 01 - LEGADO =====================
DROP TABLE IF EXISTS animais_legado;
CREATE TABLE animais_legado (
    id_animal       INTEGER,
    nome_animal     TEXT,
    especie         TEXT,
    raca            TEXT,
    nome_tutor      TEXT,
    cpf_tutor       TEXT,
    telefone_tutor  TEXT,
    vacina1         TEXT,
    data_vacina1    TEXT,
    vacina2         TEXT,
    data_vacina2    TEXT,
    vacina3         TEXT,
    data_vacina3    TEXT,
    banho1_data     TEXT,
    banho1_valor    REAL,
    banho2_data     TEXT,
    banho2_valor    REAL,
    banho3_data     TEXT,
    banho3_valor    REAL
);

INSERT INTO animais_legado VALUES
(1, 'Thor',  'Cachorro', 'Labrador',      'Marina Souza', '111.111.111-11', '(11) 98888-1111',
   'V10', '2025-01-10', 'Antirrábica', '2025-02-15', NULL, NULL,
   '2025-03-01', 60.00, '2025-04-01', 60.00, NULL, NULL),
(2, 'Mel',   'cachorro', 'Poodle',        'Marina Souza', '111.111.111-11', '(11) 98888-1111',
   'V10', '2025-03-05', NULL, NULL, NULL, NULL,
   '2025-03-20', 55.00, NULL, NULL, NULL, NULL),
(3, 'Mimi',  'Gato',     'Siamês',        'Carlos Lima',  '222.222.222-22', '(11) 97777-2222',
   'V4', '2025-02-01', 'Antirrábica', '2025-03-01', 'V4', '2025-08-01',
   '2025-04-10', 45.00, '2025-05-10', 45.00, '2025-06-10', 50.00),
(4, 'Rex',   'Cão',      'Pastor Alemão', 'Ana Paula',    '333.333.333-33', '(11) 96666-3333',
   'V10', '2025-01-20', NULL, NULL, NULL, NULL,
   NULL, NULL, NULL, NULL, NULL, NULL),
(5, 'Luna',  'Gato',     'Persa',         'Carlos Lima',  '222.222.222-22', '(11) 97777-2222',
   'V4', '2025-04-02', NULL, NULL, NULL, NULL,
   '2025-05-02', 48.00, NULL, NULL, NULL, NULL);

-- ===================== 02 - REFATORADO =====================
DROP TABLE IF EXISTS atendimentos_servico;
DROP TABLE IF EXISTS servicos;
DROP TABLE IF EXISTS aplicacoes_vacina;
DROP TABLE IF EXISTS vacinas;
DROP TABLE IF EXISTS animais;
DROP TABLE IF EXISTS tutores;
DROP TABLE IF EXISTS racas;
DROP TABLE IF EXISTS especies;

CREATE TABLE especies (
    id_especie  INTEGER PRIMARY KEY AUTOINCREMENT,
    nome        TEXT NOT NULL UNIQUE
);

CREATE TABLE racas (
    id_raca     INTEGER PRIMARY KEY AUTOINCREMENT,
    id_especie  INTEGER NOT NULL,
    nome        TEXT NOT NULL,
    UNIQUE (id_especie, nome),
    FOREIGN KEY (id_especie) REFERENCES especies(id_especie)
);

CREATE TABLE tutores (
    id_tutor    INTEGER PRIMARY KEY AUTOINCREMENT,
    nome        TEXT NOT NULL,
    cpf         TEXT NOT NULL UNIQUE,
    telefone    TEXT
);

CREATE TABLE animais (
    id_animal   INTEGER PRIMARY KEY AUTOINCREMENT,
    id_tutor    INTEGER NOT NULL,
    id_raca     INTEGER NOT NULL,
    nome        TEXT NOT NULL,
    ativo       INTEGER NOT NULL DEFAULT 1 CHECK (ativo IN (0,1)),
    FOREIGN KEY (id_tutor) REFERENCES tutores(id_tutor),
    FOREIGN KEY (id_raca)  REFERENCES racas(id_raca)
);

CREATE TABLE vacinas (
    id_vacina              INTEGER PRIMARY KEY AUTOINCREMENT,
    nome                   TEXT NOT NULL UNIQUE,
    intervalo_reforco_dias INTEGER CHECK (intervalo_reforco_dias IS NULL OR intervalo_reforco_dias > 0)
);

CREATE TABLE aplicacoes_vacina (
    id_aplicacao    INTEGER PRIMARY KEY AUTOINCREMENT,
    id_animal       INTEGER NOT NULL,
    id_vacina       INTEGER NOT NULL,
    dose_numero     INTEGER NOT NULL DEFAULT 1 CHECK (dose_numero > 0),
    data_aplicacao  TEXT NOT NULL,
    proxima_dose    TEXT,
    UNIQUE (id_animal, id_vacina, dose_numero),
    CHECK (proxima_dose IS NULL OR proxima_dose >= data_aplicacao),
    FOREIGN KEY (id_animal) REFERENCES animais(id_animal),
    FOREIGN KEY (id_vacina) REFERENCES vacinas(id_vacina)
);

CREATE TABLE servicos (
    id_servico   INTEGER PRIMARY KEY AUTOINCREMENT,
    nome         TEXT NOT NULL UNIQUE,
    preco_base   REAL NOT NULL CHECK (preco_base >= 0)
);

CREATE TABLE atendimentos_servico (
    id_atendimento   INTEGER PRIMARY KEY AUTOINCREMENT,
    id_animal        INTEGER NOT NULL,
    id_servico       INTEGER NOT NULL,
    data_atendimento TEXT NOT NULL,
    valor_cobrado    REAL NOT NULL CHECK (valor_cobrado >= 0),
    FOREIGN KEY (id_animal)  REFERENCES animais(id_animal),
    FOREIGN KEY (id_servico) REFERENCES servicos(id_servico)
);

CREATE INDEX idx_animais_tutor      ON animais (id_tutor);
CREATE INDEX idx_animais_nome       ON animais (nome);
CREATE INDEX idx_aplic_animal_data  ON aplicacoes_vacina (id_animal, data_aplicacao);
CREATE INDEX idx_aplic_proxima_dose ON aplicacoes_vacina (proxima_dose);
CREATE INDEX idx_atend_animal_data  ON atendimentos_servico (id_animal, data_atendimento);
CREATE INDEX idx_atend_data         ON atendimentos_servico (data_atendimento);

-- ===================== 03 - MIGRAÇÃO =====================
INSERT INTO especies (nome)
SELECT DISTINCT
    CASE
        WHEN LOWER(especie) IN ('cachorro', 'cão', 'cao') THEN 'Cachorro'
        WHEN LOWER(especie) = 'gato' THEN 'Gato'
        ELSE TRIM(especie)
    END
FROM animais_legado;

INSERT INTO racas (id_especie, nome)
SELECT DISTINCT e.id_especie, TRIM(a.raca)
FROM animais_legado a
JOIN especies e
  ON e.nome = CASE
        WHEN LOWER(a.especie) IN ('cachorro', 'cão', 'cao') THEN 'Cachorro'
        WHEN LOWER(a.especie) = 'gato' THEN 'Gato'
        ELSE TRIM(a.especie)
     END;

INSERT INTO tutores (nome, cpf, telefone)
SELECT DISTINCT nome_tutor, cpf_tutor, telefone_tutor
FROM animais_legado;

INSERT INTO animais (id_animal, id_tutor, id_raca, nome)
SELECT a.id_animal, t.id_tutor, r.id_raca, a.nome_animal
FROM animais_legado a
JOIN tutores t ON t.cpf = a.cpf_tutor
JOIN especies e
  ON e.nome = CASE
        WHEN LOWER(a.especie) IN ('cachorro', 'cão', 'cao') THEN 'Cachorro'
        WHEN LOWER(a.especie) = 'gato' THEN 'Gato'
        ELSE TRIM(a.especie)
     END
JOIN racas r ON r.id_especie = e.id_especie AND r.nome = TRIM(a.raca);

INSERT INTO vacinas (nome, intervalo_reforco_dias)
SELECT nome, NULL FROM (
    SELECT vacina1 AS nome FROM animais_legado
    UNION SELECT vacina2 FROM animais_legado
    UNION SELECT vacina3 FROM animais_legado
)
WHERE nome IS NOT NULL;

UPDATE vacinas SET intervalo_reforco_dias = 365 WHERE nome IN ('V10', 'V4', 'Antirrábica');

INSERT INTO aplicacoes_vacina (id_animal, id_vacina, dose_numero, data_aplicacao, proxima_dose)
SELECT x.id_animal, v.id_vacina,
       ROW_NUMBER() OVER (PARTITION BY x.id_animal, v.id_vacina ORDER BY x.data_aplicacao),
       x.data_aplicacao,
       date(x.data_aplicacao, '+' || v.intervalo_reforco_dias || ' days')
FROM (
    SELECT id_animal, vacina1 AS vacina, data_vacina1 AS data_aplicacao FROM animais_legado WHERE vacina1 IS NOT NULL
    UNION ALL
    SELECT id_animal, vacina2, data_vacina2 FROM animais_legado WHERE vacina2 IS NOT NULL
    UNION ALL
    SELECT id_animal, vacina3, data_vacina3 FROM animais_legado WHERE vacina3 IS NOT NULL
) x
JOIN vacinas v ON v.nome = x.vacina;

INSERT INTO servicos (nome, preco_base) VALUES ('Banho', 55.00);

INSERT INTO atendimentos_servico (id_animal, id_servico, data_atendimento, valor_cobrado)
SELECT x.id_animal, s.id_servico, x.data_banho, x.valor
FROM (
    SELECT id_animal, banho1_data AS data_banho, banho1_valor AS valor FROM animais_legado WHERE banho1_data IS NOT NULL
    UNION ALL
    SELECT id_animal, banho2_data, banho2_valor FROM animais_legado WHERE banho2_data IS NOT NULL
    UNION ALL
    SELECT id_animal, banho3_data, banho3_valor FROM animais_legado WHERE banho3_data IS NOT NULL
) x
JOIN servicos s ON s.nome = 'Banho';

-- ===================== 04 - NOVOS REGISTROS =====================
INSERT INTO tutores (nome, cpf, telefone) VALUES ('Bruno Alves', '444.444.444-44', '(11) 95555-4444');

INSERT INTO racas (id_especie, nome)
SELECT id_especie, 'Golden Retriever' FROM especies WHERE nome = 'Cachorro';

INSERT INTO animais (id_tutor, id_raca, nome)
SELECT t.id_tutor, r.id_raca, 'Bidu'
FROM tutores t, racas r
WHERE t.cpf = '444.444.444-44' AND r.nome = 'Golden Retriever';

INSERT INTO vacinas (nome, intervalo_reforco_dias) VALUES ('Gripe Canina', 365);

INSERT INTO aplicacoes_vacina (id_animal, id_vacina, dose_numero, data_aplicacao, proxima_dose)
SELECT a.id_animal, v.id_vacina, 1, '2025-09-01', '2026-09-01'
FROM animais a, vacinas v
WHERE a.nome = 'Bidu' AND v.nome = 'Gripe Canina';

INSERT INTO aplicacoes_vacina (id_animal, id_vacina, dose_numero, data_aplicacao, proxima_dose)
SELECT a.id_animal, v.id_vacina, 2, '2025-09-10', '2026-09-10'
FROM animais a, vacinas v
WHERE a.nome = 'Thor' AND v.nome = 'V10';

INSERT INTO servicos (nome, preco_base) VALUES ('Tosa', 40.00);

INSERT INTO atendimentos_servico (id_animal, id_servico, data_atendimento, valor_cobrado)
SELECT a.id_animal, s.id_servico, '2025-09-15', 40.00
FROM animais a, servicos s
WHERE a.nome = 'Mel' AND s.nome = 'Tosa';

UPDATE tutores  SET telefone   = '(11) 99999-1111' WHERE cpf  = '111.111.111-11';
UPDATE servicos SET preco_base = 60.00             WHERE nome = 'Banho';

-- ===================== 05 - CONSULTAS (RELATÓRIOS) =====================
-- R1) Carteira de vacinação da Mimi
SELECT a.nome AS animal, v.nome AS vacina, av.dose_numero, av.data_aplicacao, av.proxima_dose
FROM aplicacoes_vacina av
JOIN animais a ON a.id_animal = av.id_animal
JOIN vacinas v ON v.id_vacina = av.id_vacina
WHERE a.nome = 'Mimi'
ORDER BY av.data_aplicacao;

-- R2) Reforços vencidos
SELECT t.nome AS tutor, t.telefone, a.nome AS animal, v.nome AS vacina, av.proxima_dose
FROM aplicacoes_vacina av
JOIN animais a ON a.id_animal = av.id_animal
JOIN tutores t ON t.id_tutor = a.id_tutor
JOIN vacinas v ON v.id_vacina = av.id_vacina
WHERE av.proxima_dose < date('now')
ORDER BY av.proxima_dose;

-- R3) Faturamento por serviço e mês
SELECT s.nome AS servico, strftime('%Y-%m', x.data_atendimento) AS mes,
       COUNT(*) AS qtd, SUM(x.valor_cobrado) AS total
FROM atendimentos_servico x
JOIN servicos s ON s.id_servico = x.id_servico
GROUP BY s.nome, mes
ORDER BY mes, servico;

-- R4) Animais por tutor
SELECT t.nome AS tutor, COUNT(a.id_animal) AS qtd_animais
FROM tutores t LEFT JOIN animais a ON a.id_tutor = t.id_tutor
GROUP BY t.id_tutor, t.nome;
