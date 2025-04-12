-- Grupo 4 (fase 3):
-- Ramoni Reus Barros Negreiros - 122210600
-- Livia Carvalho Pereira Buriti - 121111460
-- Anderson Sabino Barboza Silva - 122210263
-- Sara Arianne Monteiro de Siqueira - 121110764
-- Geraldo Sobreira Júnior - 121110381

-- Consulta 1 (Ramoni)
CREATE OR REPLACE PROCEDURE devolver_estoque (
    codigo_ordem_input IN COMPRA_POSSUI_PRODUTO.codigo_produto%TYPE,
    quantidade_compra OUT INT,
    aux OUT INT
) IS

BEGIN
    SELECT quantidade, codigo_produto INTO quantidade_compra, aux
    FROM COMPRA_POSSUI_PRODUTO
    WHERE codigo_ordem_input = codigo_compra;

    UPDATE COMPRA_POSSUI_PRODUTO
    SET QUANTIDADE = 0
    WHERE codigo_ordem_input = codigo_compra;

    UPDATE PROD_ESTOCADO_CENT_DIST
    SET quantidade = quantidade + quantidade_compra
    WHERE aux = codigo_produto;
END;
/


-- Consulta 2 (Sara)
CREATE OR REPLACE FUNCTION get_qtd_prox_vencimento (p_cod IN PROD_ESTOCADO_CENT_DIST.CODIGO_CENTRO_DISTRIBUICAO%TYPE)
RETURN NUMBER
IS
  qtd_prox_venc NUMBER := 0;
BEGIN
  SELECT COUNT(*)
  INTO qtd_prox_venc
  FROM PRODUTO P, PROD_ESTOCADO_CENT_DIST PCDD
  WHERE PCDD.CODIGO_PRODUTO = P.CODIGO
    AND PCDD.CODIGO_CENTRO_DISTRIBUICAO = p_cod
    AND P.DATA_VALIDADE - SYSDATE <= 5;

  RETURN qtd_prox_venc;
END;
/


-- Consulta 3 (Livia)
CREATE OR REPLACE TRIGGER TRG_FORMATA_NOME_FORNECEDOR
BEFORE INSERT OR UPDATE OF NOME ON FORNECEDOR
FOR EACH ROW
BEGIN
    :NEW.NOME := INITCAP(:NEW.NOME);
END;
/


-- Consulta 4 (Anderson)
CREATE OR REPLACE TRIGGER altera_endereco_vazio
BEFORE INSERT ON ENDERECO
FOR EACH ROW
BEGIN
    IF (:NEW.numero IS NULL OR TRIM(:NEW.numero) = '') THEN
        :NEW.numero := 's/n';
    END IF;
END;
/

-- Consulta 5 (Geraldo)
CREATE VIEW VW_FORNECEDORES_CATEGORIA AS
SELECT
    f.NOME AS FORNECEDOR,
    c.NOME AS CATEGORIA,
    COUNT(p.CODIGO) AS QUANTIDADE_PRODUTOS
FROM FORNECEDOR f
JOIN FORNECEDOR_FORNECE_PRODUTO ffp ON f.CODIGO = ffp.CODIGO_FORNECEDOR
JOIN PRODUTO p ON ffp.CODIGO_PRODUTO = p.CODIGO
JOIN CATEGORIA c ON p.CODIGO_CATEGORIA = c.CODIGO
GROUP BY f.NOME, c.NOME;
/


--Consulta 6 (Anderson)
CREATE OR REPLACE PROCEDURE remover_avaliacao_falsa (
    id_produto IN PRODUTO.codigo%TYPE)
IS
BEGIN
    DELETE FROM COMPRA_AVALIA_PRODUTO a
    WHERE a.CODIGO_PRODUTO = id_produto AND a.CODIGO_COMPRA
    IN (
        SELECT o.codigo
        FROM ORDEM_DE_COMPRA o
        WHERE o.status != 'FINALIZADA'
    );
END;
/


-- Consulta 7 (Ramoni)
CREATE OR REPLACE TRIGGER quantidade_negativa
AFTER INSERT OR UPDATE OF quantidade ON COMPRA_POSSUI_PRODUTO
FOR EACH ROW
BEGIN
    IF(:new.quantidade < 0) THEN
     RAISE_APPLICATION_ERROR(-20000, 'Quantidade negativa!');
    END IF;
END;
/


--Consulta 8 (Sara)
CREATE OR REPLACE PROCEDURE decrementar_preco(cod_cat IN CUPOM_RESTRICAO_CATEGORIA.CODIGO_CATEGORIA%TYPE, val_desc IN CUPOM_DE_DESCONTO.DESCONTO%TYPE)
IS
BEGIN
    UPDATE PRODUTO
    SET PRECO = PRECO - val_desc * 0.1 * PRECO

    WHERE CODIGO_CATEGORIA = cod_cat;

END;
/


-- Consulta 9 (Livia)
CREATE OR REPLACE VIEW VIEW_CLIENTE_COMPRAS_FINALIZADAS AS
SELECT 
    c.CODIGO AS CODIGO_CLIENTE,
    c.NOME || ' ' || c.SOBRENOME AS NOME_COMPLETO,
    SUM(cpp.QUANTIDADE * cpp.VALOR_ATUAL) AS VALOR_TOTAL_COMPRAS
FROM CLIENTE c
JOIN ORDEM_DE_COMPRA oc ON c.CODIGO = oc.CODIGO_CLIENTE
JOIN COMPRA_POSSUI_PRODUTO cpp ON oc.CODIGO = cpp.CODIGO_COMPRA
WHERE oc.STATUS = 'FINALIZADA'
GROUP BY c.CODIGO, c.NOME, c.SOBRENOME
ORDER BY VALOR_TOTAL_COMPRAS DESC;
/


-- Consulta 10 (Geraldo)
CREATE OR REPLACE VIEW VW_TRANSPORTADORAS_1M AS
SELECT
    t.NOME AS TRANSPORTADORA,
    SUM(cpp.QUANTIDADE * cpp.VALOR_ATUAL) AS TOTAL_TRANSPORTADO
FROM TRANSPORTADORA t
JOIN ORDEM_DE_COMPRA oc ON t.CODIGO = oc.CODIGO_TRANSPORTADORA
JOIN COMPRA_POSSUI_PRODUTO cpp ON oc.CODIGO = cpp.CODIGO_COMPRA
GROUP BY t.NOME
HAVING SUM(cpp.QUANTIDADE * cpp.VALOR_ATUAL) > 1000000;
/
