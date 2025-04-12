-- Grupo 4
-- Membros que fizeram o projeto (fase 2):
-- Ramoni Reus Barros Negreiros - 122210600
-- Livia Carvalho Pereira Buriti - 121111460
-- Anderson Sabino Barboza Silva - 122210263
-- Sara Arianne Monteiro de Siqueira - 121110764
-- Geraldo Sobreira Júnior - 121110381


-- Consulta 1
SELECT c.CODIGO,c.NOME || ' ' || c.SOBRENOME AS NOME_COMPLETO, c.DATA_NASCIMENTO, FLOOR(MONTHS_BETWEEN(SYSDATE, c.DATA_NASCIMENTO)/12) AS IDADE
FROM CLIENTE c
WHERE FLOOR(MONTHS_BETWEEN(SYSDATE, c.DATA_NASCIMENTO)/12) > ( SELECT AVG(FLOOR(MONTHS_BETWEEN(SYSDATE, DATA_NASCIMENTO)/12)) FROM CLIENTE)
ORDER BY IDADE DESC;


-- Consulta 2
SELECT CODIGO, DATA_COMPRA 
FROM ORDEM_DE_COMPRA 
WHERE DATA_COMPRA >= ALL
        (SELECT DATA_COMPRA FROM ORDEM_DE_COMPRA)
   OR DATA_COMPRA <= ALL
            (SELECT DATA_COMPRA FROM ORDEM_DE_COMPRA)

--- Consulta 3 
(SELECT DISTINCT f.nome, f.codigo
 FROM FORNECEDOR f, CATEGORIA cat, FORNECEDO_FORNECE_PRODUTO fp, PRODUTO P
 WHERE f.codigo = fp.codigo_fornecedor
      AND fp.codigo_produto = p.codigo
      AND p.codigo_categoria = cat.codigo
      AND cat.nome = 'Material Escolar')

UNION 

(SELECT DISTINCT f.nome, f.codigo
 FROM FORNECEDOR f, CATEGORIA cat, FORNECEDOR_FORNECE_PRODUTO fp, PRODUTO P
 WHERE f.codigo = fp.codigo_fornecedor
      AND fp.codigo_produto = p.codigo
      AND p.codigo_categoria = cat.codigo
      AND cat.nome <> 'Material de Limpeza')
    
--- Consulta 4
SELECT t.nome, t.email
FROM TRANSPORTADORA, ORDEM_DE_COMPRA
WHERE frete >= 50
      AND codigo = codigo_transportadora

-- Consulta 5
SELECT p.NOME AS produto, AVG(ca.NOTA) AS media_nota
FROM ORDEM_DE_COMPRA oc
JOIN COMPRA_POSSUI_PRODUTO cpp ON oc.CODIGO = cpp.CODIGO_COMPRA
JOIN PRODUTO p ON cpp.CODIGO_PRODUTO = p.CODIGO
JOIN COMPRA_AVALIA_PRODUTO ca ON p.CODIGO = ca.CODIGO_PRODUTO AND oc.CODIGO = ca.CODIGO_COMPRA
WHERE EXTRACT(YEAR FROM oc.DATA_COMPRA) = 2024 AND EXTRACT(MONTH FROM oc.DATA_COMPRA) = 1
GROUP BY p.NOME
HAVING AVG(ca.NOTA) > 6
ORDER BY media_nota DESC;


-- Consulta 6
SELECT c.nome as nome_categoria, AVG(p.preco) as media_preco
FROM CATEGORIA c, PRODUTO p
WHERE c.codigo = p.codigo_categoria
GROUP BY c.nome
HAVING AVG(p.preco) > 2000;

--Consulta 7
SELECT TO_CHAR(o.data_compra, 'MM/YYYY') AS data, c.nome AS nome_cliente, COUNT(o.codigo) AS total_ordens 
FROM ORDEM_DE_COMPRA o, CLIENTE c
WHERE o.codigo_cliente = c.codigo and o.status = 'FINALIZADA'
GROUP BY c.nome, TO_CHAR(o.data_compra, 'MM/YYYY')
ORDER BY data, nome_cliente;

-- Consulta 8
SELECT e.CIDADE, AVG(o.VALOR_FRETE) AS Valor_Medio
FROM ORDEM_DE_COMPRA o
JOIN ENDERECO e ON o.CODIGO_ENDERECO = e.CODIGO
GROUP BY e.CIDADE
HAVING COUNT(o.CODIGO) > 10;

-- Consulta 9
SELECT count(DISTINCT o.codigo_transportadora) as STATUS, t.nome
FROM TRANSPORTADORA t LEFT OUTER JOIN ORDEM_DE_COMPRA o
ON  t.codigo = o.codigo_transportadora 
GROUP BY t.nome

-- Consulta 10
SELECT p.CODIGO, p.NOME, COUNT(*) AS Quantidade_Adicoes
FROM CARRINHO_TEM_PRODUTO ctp
JOIN PRODUTO p ON ctp.CODIGO_PRODUTO = p.CODIGO
GROUP BY p.CODIGO, p.NOME
HAVING COUNT(*) > 5;

