USE master;
GO

-- 1. CRIAR A BASE DE DADOS
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'BD_ADS')
BEGIN
    CREATE DATABASE BD_ADS;
END
GO

USE BD_ADS;
GO

-- 2. CRIAÇÃO DAS TABELAS

-- PAIS ----------------------------------------------------
CREATE TABLE PAIS (
    PaisCod INT IDENTITY(1,1) NOT NULL,
    PaisNome VARCHAR(255) NOT NULL,
    CONSTRAINT pk_PAIS PRIMARY KEY (PaisCod)
);

-- UNIDADE_FEDERATIVA ---------------------------------------
CREATE TABLE UNIDADE_FEDERATIVA (
    UfSigla VARCHAR(2) NOT NULL,
    UfNome VARCHAR(255) NOT NULL,
    PaisCod INT NOT NULL,
    CONSTRAINT pk_UNIDADE_FEDERATIVA PRIMARY KEY (UfSigla),
    CONSTRAINT fk_UNIDADE_FEDERATIVA_PAIS FOREIGN KEY (PaisCod) REFERENCES PAIS (PaisCod)
);

-- CIDADE ----------------------------------------------------
CREATE TABLE CIDADE (
    CidCod INT IDENTITY(1,1) NOT NULL,
    CidNome VARCHAR(255) NOT NULL,
    UfSigla VARCHAR(2) NOT NULL,
    CONSTRAINT pk_CIDADE PRIMARY KEY (CidCod),
    CONSTRAINT fk_CIDADE_UNIDADE_FEDERATIVA FOREIGN KEY (UfSigla) REFERENCES UNIDADE_FEDERATIVA (UfSigla)
);

-- PESSOA ----------------------------------------------------
CREATE TABLE PESSOA (
    PessoaCod INT IDENTITY(1,1) NOT NULL,
    PessoaNome VARCHAR(255) NOT NULL,
    PessoaDataExpCad DATETIME NULL,
    CidCod INT NOT NULL,
    CONSTRAINT pk_PESSOA PRIMARY KEY (PessoaCod),
    CONSTRAINT fk_PESSOA_CIDADE FOREIGN KEY (CidCod) REFERENCES CIDADE (CidCod)
);

-- PRODUTO ----------------------------------------------------
CREATE TABLE PRODUTO (
    ProdCod INT IDENTITY(1,1) NOT NULL,
    ProdNome VARCHAR(255) NOT NULL,
    PessoaCodFornec INT NOT NULL,
    ProdDataValidMax DATETIME NULL,
    CONSTRAINT pk_PRODUTO PRIMARY KEY (ProdCod),
    CONSTRAINT fk_PRODUTO_PESSOA FOREIGN KEY (PessoaCodFornec) REFERENCES PESSOA (PessoaCod)
);

-- PEDIDO ----------------------------------------------------
CREATE TABLE PEDIDO (
    PedidoNum INT IDENTITY(1,1) NOT NULL,
    PedidoDataCad DATETIME NOT NULL,
    PedidoValorTotal DECIMAL(16,2) NOT NULL,
    PessoaCod INT NULL,
    CONSTRAINT PK_PEDIDO PRIMARY KEY (PedidoNum),
    CONSTRAINT FK_PEDIDO_PESSOA FOREIGN KEY (PessoaCod) REFERENCES PESSOA (PessoaCod)
);

-- ITEM_PEDIDO -----------------------------------------------
CREATE TABLE ITEM_PEDIDO (
    PedidoNum INT NOT NULL,
    ItemPedidoSeq INT NOT NULL,
    ItemPedidoValor DECIMAL(16,2) NOT NULL,
    ProdCod INT NOT NULL,
    CONSTRAINT pk_ITEM_PEDIDO PRIMARY KEY (PedidoNum, ItemPedidoSeq),
    CONSTRAINT fk_ITEM_PEDIDO_PEDIDO FOREIGN KEY (PedidoNum) REFERENCES PEDIDO (PedidoNum),
    CONSTRAINT fk_ITEM_PEDIDO_PROD FOREIGN KEY (ProdCod) REFERENCES PRODUTO (ProdCod)
);

-- LOG_PESSOA ------------------------------------------------
CREATE TABLE LOG_PESSOA (
    LogPessoaId INT IDENTITY(1,1) NOT NULL,
    LogPessoaDataHora DATETIME NOT NULL,
    LogPessoaTipoOperacao VARCHAR(500),
    LogPessoaDadoAnterior VARCHAR(500),
    LogPessoaDadoAtual VARCHAR(500),
    PessoaCod INT NULL,
    CONSTRAINT pk_LOG_PESSOA PRIMARY KEY (LogPessoaId),
    CONSTRAINT fk_LOG_PESSOA_PESSOA FOREIGN KEY (PessoaCod) REFERENCES PESSOA (PessoaCod)
);
GO

-- 3. INSERÇÃO DE DADOS

-- Inserindo Países (Forçando IDs do script original)
SET IDENTITY_INSERT PAIS ON;
INSERT INTO PAIS (PaisCod, PaisNome) VALUES 
(1,'BRASIL'), (2,'ESTADOS UNIDOS DA AMÉRICA'), (3,'FRANÇA'), 
(4,'ESPANHA'), (5,'ARGENTINA'), (6,'CHILE');
SET IDENTITY_INSERT PAIS OFF;
INSERT INTO PAIS (PaisNome) VALUES ('PERÚ');

-- Inserindo UFs
INSERT INTO UNIDADE_FEDERATIVA (UfSigla, UfNome, PaisCod) VALUES 
('SP','SÃO PAULO',1), ('RJ','RIO DE JANEIRO',1), 
('PR','PARANÁ',1), ('FL','FLÓRIDA',2);

-- Inserindo Cidades
INSERT INTO CIDADE (CidNome, UfSigla) VALUES 
('SÃO PAULO','SP'), ('SÃO JOSÉ DO RIO PRETO','SP'), 
('RIO DE JANEIRO','RJ'), ('MACAÉ','RJ'), 
('MARINGÁ','PR'), ('SÃO CARLOS','SP'), 
('ARARAQUARA','SP'), ('ORLANDO','FL');

-- Inserindo Pessoas
INSERT INTO PESSOA (PessoaNome, PessoaDataExpCad, CidCod) VALUES 
('FLÁVIO HENRIQUE FERNANDES VOLPON', NULL, 2),
('JOSÉ PAULO DA SILVA', '20190202', 2),
('MARIA APARECIDA DOS SANTOS', '20190303', 3),
('FERNANDO TERCEIRO VASQUEZ', NULL, 4),
('CORAL TINTAS', NULL, 2),
('CIMENTO ITAÚ ', NULL, 1);

-- Inserindo Produtos
INSERT INTO PRODUTO (ProdNome, PessoaCodFornec, ProdDataValidMax) VALUES 
('CIMENTO', 6, NULL),
('LATEX', 5, '20170213');

-- Inserindo Pedidos Iniciais
INSERT INTO PEDIDO (PedidoDataCad, PedidoValorTotal, PessoaCod) VALUES 
(GETDATE()-1, 100.00, 1),
(GETDATE()-4, 300.00, 2),
(GETDATE()+1, 600.00, 1),
(GETDATE()+1, 40.30, 4);

-- Inserindo Itens
INSERT INTO ITEM_PEDIDO (PedidoNum, ItemPedidoSeq, ItemPedidoValor, ProdCod) VALUES 
(1,1,70.00,1), (1,2,30.00,2), (2,1,300.00,1), (3,1,600.00,2), (4,1,40.30,2);

-- Inserindo Pedidos com IDs específicos (conforme final do seu script)
SET IDENTITY_INSERT PEDIDO ON;
INSERT INTO PEDIDO (PedidoNum, PedidoDataCad, PedidoValorTotal, PessoaCod) VALUES 
(5, GETDATE()-40, 56.29, 3),
(6, GETDATE()-30, 200, 2),
(7, GETDATE()-60, 300, 2),
(8, GETDATE()-440, 210, 1),
(9, GETDATE()-400, 80, 1),
(10, GETDATE()-365, 50, 1);
SET IDENTITY_INSERT PEDIDO OFF;

-- Itens adicionais
INSERT INTO ITEM_PEDIDO VALUES (5,1,10.37,1), (5,2,45.92,2), (6,1,170,1), (6,2,30,2),
(7,1,170,1), (7,2,130,2), (8,1,170,1), (8,2,40,2), (9,1,20,1), (9,2,60,2), (10,1,20,1), (10,2,30,2);
GO