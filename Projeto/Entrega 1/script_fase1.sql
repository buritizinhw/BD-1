-- Membros que fizeram o projeto (fase 1):
-- Ramoni Reus Barros Negreiros - 122210600
-- Livia Carvalho Pereira Buriti - 121111460
-- Anderson Sabino Barboza Silva - 122210263
-- Sara Arianne Monteiro de Siqueira - 121110764
-- Geraldo Sobreira Júnior - 121110381

DROP TABLE HISTORICO_VIZUALIZACAO;
DROP TABLE HISTORICO_ADICAO;
DROP TABLE EMAIL;
DROP TABLE NOTA_FISCAL;
DROP TABLE AVALIACAO_PRODUTO;
DROP TABLE ITEM_DE_PEDIDO;
DROP TABLE ORDEM_COMPRA;
DROP TABLE TRANSPORTADORA;
DROP TABLE INDICACAO;
DROP TABLE TELEFONE_CLIENTE;
DROP TABLE CARRINHO_DE_COMPRAS;
DROP TABLE CUPOM_DE_DESCONTO;
DROP TABLE ITEM_DE_INVENTARIO;
DROP TABLE CENTRO_DE_DISTRIBUICAO;
DROP TABLE PRODUTO;
DROP TABLE FORNECEDOR;
DROP TABLE CLIENTE;
DROP TABLE CATEGORIA;
DROP TABLE ENDERECO;

CREATE TABLE ENDERECO(
    codigo NUMBER GENERATED ALWAYS AS IDENTITY,
    rua VARCHAR(100),
    numero NUMBER(10,0),
    cep VARCHAR(10),
    bairro VARCHAR(100),
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(2) NOT NULL,
    CONSTRAINT pk_endereco PRIMARY KEY(codigo)
);

CREATE TABLE CATEGORIA (
    codigo INT GENERATED ALWAYS AS IDENTITY,
    nome VARCHAR(50) NOT NULL,
    CONSTRAINT pk_categoria PRIMARY KEY (codigo)
);

CREATE TABLE CLIENTE (
    codigo INT GENERATED ALWAYS AS IDENTITY,
    nome VARCHAR(50) NOT NULL,
    sobrenome VARCHAR(50) NOT NULL,
    dataNasc DATE NOT NULL,
    sexo CHAR(1) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    pontos INT DEFAULT 0, 
    id_endereco INT,
    CONSTRAINT pk_cliente PRIMARY KEY (codigo),
    CONSTRAINT fk_cliente_endereco FOREIGN KEY (id_endereco) REFERENCES ENDERECO(codigo)
);

CREATE TABLE FORNECEDOR (
    codigo INT GENERATED ALWAYS AS IDENTITY,
    email VARCHAR(100) NOT NULL UNIQUE,
    nome VARCHAR(50) NOT NULL,
    num_fornecedor CHAR(14),
    id_endereco INT,  -- Updated to reference Endereco
    home_page VARCHAR(100),
    CONSTRAINT pk_fornecedor PRIMARY KEY (codigo),
    CONSTRAINT fk_fornecedor_endereco FOREIGN KEY (id_endereco) REFERENCES ENDERECO(codigo)
);

-- Products depend on categories and possibly suppliers
CREATE TABLE PRODUTO (
    codigo INT GENERATED ALWAYS AS IDENTITY,
    nome VARCHAR(50) NOT NULL,  
    preco NUMBER NOT NULL,  
    descricao CLOB,  
    especificacao CLOB,  
    fotos BLOB, 
    data_fabricacao DATE NOT NULL,  
    data_validade DATE NOT NULL,
    id_categoria INT,
    id_fornecedor INT,
    CONSTRAINT pk_produto PRIMARY KEY (codigo),
    CONSTRAINT fk_categoria FOREIGN KEY (id_categoria) REFERENCES CATEGORIA(codigo),
    CONSTRAINT fk_produto_fornecedor FOREIGN KEY (id_fornecedor) REFERENCES FORNECEDOR(codigo)
);

CREATE TABLE CENTRO_DE_DISTRIBUICAO (
  codigo INT GENERATED ALWAYS AS IDENTITY,
  id_endereco INT,
  nome VARCHAR(20) NOT NULL,
  CONSTRAINT pk_centro_de_distribuicao PRIMARY KEY (codigo),
  CONSTRAINT fk_centro_de_distribuicao FOREIGN KEY (id_endereco) REFERENCES ENDERECO (codigo)
);

CREATE TABLE ITEM_DE_INVENTARIO (
    id_produto INT NOT NULL,
    id_centro_distribuicao INT NOT NULL,
    quantidade INT NOT NULL,
    valor_atual NUMBER(10,2) NOT NULL,
    CONSTRAINT pk_item_de_inventario PRIMARY KEY (id_produto, id_centro_distribuicao),
    CONSTRAINT fk_item_de_inventario_produto FOREIGN KEY (id_produto) REFERENCES PRODUTO (codigo),
    CONSTRAINT fk_item_de_inventario_centro_distribuicao FOREIGN KEY (id_centro_distribuicao) REFERENCES CENTRO_DE_DISTRIBUICAO (codigo)
);


CREATE TABLE CUPOM_DE_DESCONTO(
  codigo INT GENERATED ALWAYS AS IDENTITY,
  cod_categoria INT,
  desconto NUMBER NOT NULL,
  CONSTRAINT pk_cupom_de_desconto PRIMARY KEY (codigo),
  CONSTRAINT fk_cupom_de_desconto FOREIGN KEY (cod_categoria) REFERENCES CATEGORIA (codigo)
);


CREATE TABLE CARRINHO_DE_COMPRAS(
  codigo INT GENERATED ALWAYS AS IDENTITY,
  cod_produto INT,
  id_cupom INT,
  id_cliente INT NOT NULL,
  CONSTRAINT pk_carrinho_de_compras PRIMARY KEY (codigo),
  CONSTRAINT fk_carrinho_de_compras_produto FOREIGN KEY (cod_produto) REFERENCES PRODUTO (codigo),
  CONSTRAINT fk_carrinho_de_compras_cupom FOREIGN KEY (id_cupom) REFERENCES CUPOM_DE_DESCONTO(codigo),
  CONSTRAINT fk_carrinho_de_compras_cliente FOREIGN KEY (id_cliente) REFERENCES CLIENTE (codigo)
);

-- Client phones are next, dependent on clients
CREATE TABLE TELEFONE_CLIENTE (
    id_cliente INT NOT NULL,
    num_cliente VARCHAR(20) NOT NULL,
    CONSTRAINT pk_telefone_cliente PRIMARY KEY (id_cliente, num_cliente),
    CONSTRAINT fk_telefone_cliente FOREIGN KEY (id_cliente) REFERENCES CLIENTE(codigo)
);

-- Indications depend on clients
CREATE TABLE INDICACAO (
    cliente_indicador INT NOT NULL,
    cliente_indicado INT NOT NULL UNIQUE,
    data_indicacao DATE,
    CONSTRAINT pk_indicacao PRIMARY KEY (cliente_indicador, cliente_indicado),
    CONSTRAINT fk_indicador FOREIGN KEY (cliente_indicador) REFERENCES CLIENTE (codigo),
    CONSTRAINT fk_indicado FOREIGN KEY (cliente_indicado) REFERENCES CLIENTE (codigo)
);

-- Transporters also need addresses
CREATE TABLE TRANSPORTADORA (
    codigo INT GENERATED ALWAYS AS IDENTITY,
    nome VARCHAR (255),
    email VARCHAR (255),
    telefone VARCHAR (255),
    sitio VARCHAR (255), -- site is a reserved word in many SQL dialects
    id_endereco INT,     -- Relationship (1:1) with Address
    CONSTRAINT pk_transportadora PRIMARY KEY (codigo),
    CONSTRAINT fk_endereco_transportadora FOREIGN KEY (id_endereco) REFERENCES endereco (codigo)
);

-- Orders depend on clients and transporters
CREATE TABLE ORDEM_COMPRA(
    codigo NUMBER GENERATED ALWAYS AS IDENTITY,
    id_cliente NUMBER NOT NULL,
    id_transportadora NUMBER NOT NULL,
    id_endereco NUMBER,
    data_compra DATE NOT NULL,
    status VARCHAR(50),
    desconto NUMBER(9,2),
    frete NUMBER(9,2),
    CONSTRAINT pk_ordem_compra PRIMARY KEY(codigo),
    CONSTRAINT fk_ordem_cliente FOREIGN KEY(id_cliente) REFERENCES CLIENTE(codigo),
    CONSTRAINT fk_ordem_transportadora FOREIGN KEY(id_transportadora) REFERENCES TRANSPORTADORA(codigo),
    CONSTRAINT fk_ordem_endereco FOREIGN KEY(id_endereco) REFERENCES ENDERECO(codigo)
);

CREATE TABLE ITEM_DE_PEDIDO (
    id_produto INT NOT NULL,
    id_ordem_compra NUMBER NOT NULL,
    quantidade INT NOT NULL,
    valor_atual NUMBER(10,2) NOT NULL,
    CONSTRAINT pk_item_de_pedido PRIMARY KEY (id_produto, id_ordem_compra),
    CONSTRAINT fk_item_de_pedido_produto FOREIGN KEY (id_produto) REFERENCES PRODUTO (codigo),
    CONSTRAINT fk_item_de_pedido_ordem_compra FOREIGN KEY (id_ordem_compra) REFERENCES ORDEM_COMPRA (codigo)
);

CREATE TABLE AVALIACAO_PRODUTO (
    id_produto INT NOT NULL,
    id_ordem_compra NUMBER NOT NULL,
    nota DECIMAL(3,1),
    descricao CLOB,
    CONSTRAINT pk_avaliacao_produto PRIMARY KEY (id_produto, id_ordem_compra),
    CONSTRAINT fk_avaliacao_produto_produto FOREIGN KEY (id_produto) REFERENCES PRODUTO (codigo),
    CONSTRAINT fk_avaliacao_produto_ordem_compra FOREIGN KEY (id_ordem_compra) REFERENCES ORDEM_COMPRA (codigo)
);

-- Invoices depend on orders
CREATE TABLE NOTA_FISCAL(
    codigo NUMBER GENERATED ALWAYS AS IDENTITY,
    id_ordem_compra NUMBER NOT NULL,
    chave_acesso VARCHAR(44) UNIQUE NOT NULL,
    inscricao VARCHAR(50),
    valor_total NUMBER(9,2) NOT NULL,
    serie VARCHAR(20),
    numero VARCHAR(20),
    CONSTRAINT pk_nota_fiscal PRIMARY KEY(codigo),
    CONSTRAINT fk_nota_fiscal FOREIGN KEY(id_ordem_compra) REFERENCES ORDEM_COMPRA(codigo)
);

-- Adjusted Emails table to include interactions
CREATE TABLE EMAIL(
    codigo NUMBER GENERATED ALWAYS AS IDENTITY,
    id_cliente NUMBER NOT NULL,
    conteudo CLOB,
    data_envio DATE NOT NULL,
    assunto VARCHAR(200),
    clicou_no_conteudo CHAR(1) DEFAULT 'N' CHECK (clicou_no_conteudo IN ('Y', 'N')),
    abriu CHAR(1) DEFAULT 'N' CHECK (abriu IN ('Y', 'N')), 
    CONSTRAINT pk_email PRIMARY KEY(codigo),
    CONSTRAINT fk_email_cliente FOREIGN KEY(id_cliente) REFERENCES CLIENTE(codigo)
);

-- History tables depend on products and clients
CREATE TABLE HISTORICO_ADICAO ( 
    codigo INT GENERATED ALWAYS AS IDENTITY,
    data_compra DATE,
    finalizou VARCHAR(255), 
    id_produto INT,         -- Relationship (1:N) with Product
    id_cliente INT,         -- Relationship (1:N) with Client
    CONSTRAINT pk_historico_adicao PRIMARY KEY (codigo),
    CONSTRAINT fk_endereco_adicao FOREIGN KEY (id_produto) REFERENCES PRODUTO (codigo),
    CONSTRAINT fk_cliente_adicao FOREIGN KEY (id_cliente) REFERENCES CLIENTE (codigo)
);

CREATE TABLE HISTORICO_VIZUALIZACAO ( 
    codigo INT GENERATED ALWAYS AS IDENTITY,
    data_compra DATE,
    tempo_permanencia TIMESTAMP,
    id_produto INT,              -- Relationship (1:N) with Product
    id_cliente INT,              -- Relationship (1:N) with Client
    CONSTRAINT pk_historico_vizualizacao PRIMARY KEY (codigo),
    CONSTRAINT fk_endereco_vizualizacao FOREIGN KEY (id_produto) REFERENCES PRODUTO (codigo),
    CONSTRAINT fk_cliente_vizualizacao FOREIGN KEY (id_cliente) REFERENCES CLIENTE (codigo)
);