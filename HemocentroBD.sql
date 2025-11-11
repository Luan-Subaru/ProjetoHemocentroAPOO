CREATE DATABASE IF NOT EXISTS hemocentro;
USE hemocentro;

-- ======================================================
-- TABELA: DOADOR
-- ======================================================
CREATE TABLE Doador (
    id_doador INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    data_nascimento DATE NOT NULL,
    tipo_sanguineo VARCHAR(3) NOT NULL,
    fator_rh CHAR(1) NOT NULL,
    endereco VARCHAR(150),
    telefone VARCHAR(20),
    email VARCHAR(100)
);

-- ======================================================
-- TABELA: VOTO_AUTO_EXCLUSAO (1:1 com DOADOR)
-- ======================================================
CREATE TABLE VotoAutoExclusao (
    id_voto INT AUTO_INCREMENT PRIMARY KEY,
    id_doador INT NOT NULL,
    data DATE NOT NULL,
    motivo TEXT,
    FOREIGN KEY (id_doador) REFERENCES Doador(id_doador)
        ON DELETE CASCADE
);

-- ======================================================
-- TABELA: AGENDAMENTO (1:N com DOADOR)
-- ======================================================
CREATE TABLE Agendamento (
    id_agendamento INT AUTO_INCREMENT PRIMARY KEY,
    id_doador INT NOT NULL,
    data DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Ativo',
    FOREIGN KEY (id_doador) REFERENCES Doador(id_doador)
        ON DELETE CASCADE
);

-- ======================================================
-- TABELA: ENFERMEIRO
-- ======================================================
CREATE TABLE Enfermeiro (
    id_enfermeiro INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    registro_profissional VARCHAR(50)
);

-- ======================================================
-- TABELA: TRIAGEM (1:N com DOADOR, 1:N com ENFERMEIRO)
-- ======================================================
CREATE TABLE Triagem (
    id_triagem INT AUTO_INCREMENT PRIMARY KEY,
    id_doador INT NOT NULL,
    id_enfermeiro INT NOT NULL,
    data DATE NOT NULL,
    pressao_arterial VARCHAR(15),
    peso FLOAT,
    questionario_saude TEXT,
    observacoes TEXT,
    FOREIGN KEY (id_doador) REFERENCES Doador(id_doador),
    FOREIGN KEY (id_enfermeiro) REFERENCES Enfermeiro(id_enfermeiro)
);

-- ======================================================
-- TABELA: DOACAO (1:N com ENFERMEIRO e DOADOR)
-- ======================================================
CREATE TABLE Doacao (
    id_doacao INT AUTO_INCREMENT PRIMARY KEY,
    id_doador INT NOT NULL,
    id_enfermeiro INT NOT NULL,
    data DATE NOT NULL,
    volume_ml FLOAT,
    FOREIGN KEY (id_doador) REFERENCES Doador(id_doador),
    FOREIGN KEY (id_enfermeiro) REFERENCES Enfermeiro(id_enfermeiro)
);

-- ======================================================
-- TABELA: ESTOQUE_SANGUE
-- ======================================================
CREATE TABLE EstoqueSangue (
    id_estoque INT AUTO_INCREMENT PRIMARY KEY,
    localizacao VARCHAR(100),
    quantidade_total INT DEFAULT 0
);

-- ======================================================
-- TABELA: BOLSA_SANGUE (1:1 com DOACAO, N:1 com ESTOQUE)
-- ======================================================
CREATE TABLE BolsaSangue (
    id_bolsa INT AUTO_INCREMENT PRIMARY KEY,
    id_doacao INT NOT NULL,
    tipo_sanguineo VARCHAR(3) NOT NULL,
    fator_rh CHAR(1) NOT NULL,
    status VARCHAR(20) DEFAULT 'Em análise',
    id_estoque INT,
    FOREIGN KEY (id_doacao) REFERENCES Doacao(id_doacao)
        ON DELETE CASCADE,
    FOREIGN KEY (id_estoque) REFERENCES EstoqueSangue(id_estoque)
        ON DELETE SET NULL
);

-- ======================================================
-- TABELA: PROFISSIONAL_LABORATORIO
-- ======================================================
CREATE TABLE ProfissionalLaboratorio (
    id_profissional INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    registro_profissional VARCHAR(50)
);

-- ======================================================
-- TABELA: EXAME_SOROLOGICO (1:1 com BOLSA_SANGUE)
-- ======================================================
CREATE TABLE ExameSorologico (
    id_exame INT AUTO_INCREMENT PRIMARY KEY,
    id_bolsa INT NOT NULL,
    id_profissional INT NOT NULL,
    data DATE NOT NULL,
    resultado VARCHAR(20),
    FOREIGN KEY (id_bolsa) REFERENCES BolsaSangue(id_bolsa)
        ON DELETE CASCADE,
    FOREIGN KEY (id_profissional) REFERENCES ProfissionalLaboratorio(id_profissional)
);

-- ======================================================
-- TABELA: RELATORIO (gerado por Enfermeiro)
-- ======================================================
CREATE TABLE Relatorio (
    id_relatorio INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(50),
    data_geracao DATE NOT NULL,
    id_enfermeiro INT NULL,
    FOREIGN KEY (id_enfermeiro) REFERENCES Enfermeiro(id_enfermeiro)
        ON DELETE SET NULL
);

-- ======================================================
-- TABELA: GERENTE_HOSPITAL
-- ======================================================
CREATE TABLE GerenteHospital (
    id_gerente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100),
    cargo VARCHAR(50)
);

-- ======================================================
-- DADOS DE EXEMPLO
-- ======================================================

-- DOADORES
INSERT INTO Doador (nome, cpf, data_nascimento, tipo_sanguineo, fator_rh, endereco, telefone, email)
VALUES 
('João Silva', '111.111.111-11', '1990-05-10', 'O', '+', 'Rua A, 123', '11999999999', 'joao@email.com'),
('Maria Souza', '222.222.222-22', '1985-09-15', 'A', '-', 'Rua B, 456', '11988888888', 'maria@email.com');

-- ENFERMEIROS
INSERT INTO Enfermeiro (nome, registro_profissional)
VALUES 
('Carlos Almeida', 'ENF1234'),
('Ana Pereira', 'ENF5678');

-- PROFISSIONAIS DE LABORATÓRIO
INSERT INTO ProfissionalLaboratorio (nome, registro_profissional)
VALUES 
('Paula Ramos', 'LAB987'),
('Rafael Lima', 'LAB654');

-- GERENTES
INSERT INTO GerenteHospital (nome, cargo)
VALUES
('Dr. Marcos', 'Gerente Geral'),
('Dra. Luiza', 'Supervisora Técnica');

-- AGENDAMENTOS
INSERT INTO Agendamento (id_doador, data, status)
VALUES
(1, '2025-10-15', 'Ativo'),
(2, '2025-10-18', 'Ativo');

-- TRIAGENS
INSERT INTO Triagem (id_doador, id_enfermeiro, data, pressao_arterial, peso, questionario_saude, observacoes)
VALUES
(1, 1, '2025-10-10', '120/80', 75.0, 'Sem restrições', 'Apto para doação'),
(2, 2, '2025-10-11', '130/85', 68.5, 'Gripe recente', 'Inapta temporariamente');

-- DOAÇÕES
INSERT INTO Doacao (id_doador, id_enfermeiro, data, volume_ml)
VALUES
(1, 1, '2025-10-12', 450.0);

-- ESTOQUE
INSERT INTO EstoqueSangue (localizacao, quantidade_total)
VALUES
('Setor A - Câmara 1', 10);

-- BOLSAS DE SANGUE (herdando tipo do doador)
INSERT INTO BolsaSangue (id_doacao, tipo_sanguineo, fator_rh, status, id_estoque)
SELECT d.id_doacao, do.tipo_sanguineo, do.fator_rh, 'Em análise', 1
FROM Doacao d
JOIN Doador do ON d.id_doador = do.id_doador
WHERE d.id_doacao = 1;

-- EXAMES SOROLÓGICOS
INSERT INTO ExameSorologico (id_bolsa, id_profissional, data, resultado)
VALUES
(1, 1, '2025-10-13', 'Negativo');

-- RELATÓRIOS
INSERT INTO Relatorio (tipo, data_geracao, id_enfermeiro)
VALUES
('Doações do mês', '2025-10-13', 1);


-- VERIFICAR TABELAS
select * from agendamento;

select * from bolsasangue;

select * from doacao;

select * from doador;

select * from enfermeiro;

select * from estoquesangue;

select * from examessorologico;

select * from gerentehospital;

select * from profissionallaboratorio;

select * from relatorio;

select * from triagem;

select * from votoautoexclusao;