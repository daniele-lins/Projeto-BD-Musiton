-- 1. Quais são os 10 ouvintes com o maior número de conexões (seguindo e seguidores combinados)?
CREATE MATERIALIZED VIEW mv_top_ouvintes_conexoes AS
SELECT
    o.ID_Perfil,
    o.Nome_Ouvinte,
    (p.Num_Seguindo + p.Num_Seguidores) AS Total_Conexoes
FROM
    Ouvinte o
JOIN
    Perfil p ON o.ID_Perfil = p.ID_Perfil
ORDER BY
    Total_Conexoes DESC
LIMIT 10;

-- 2. Qual é a distribuição de ouvintes por tipo de plano?
CREATE OR REPLACE PROCEDURE sp_distribuicao_ouvintes_tipo_plano()
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT Tipo_Plano, COUNT(*) AS Total_Ouvintes
    FROM Ouvinte
    GROUP BY Tipo_Plano
    ORDER BY Total_Ouvintes DESC;
END;
$$;

-- 3. Quais categorias têm o maior número de mídias associadas?
CREATE MATERIALIZED VIEW mv_categorias_mais_midias AS
SELECT
    c.ID_Categoria,
    c.Nome_Categoria,
    COUNT(cm.ID_Midia) AS Total_Midias
FROM
    Categoria c
LEFT JOIN
    Categoria_Midia cm ON c.ID_Categoria = cm.ID_Categoria
GROUP BY
    c.ID_Categoria, c.Nome_Categoria
ORDER BY
    Total_Midias DESC;

-- 4. Quais são os 5 álbuns mais recentes (baseado na data de lançamento) que não são singles?
CREATE MATERIALIZED VIEW mv_albuns_mais_recentes AS
SELECT
    ID_Album,
    Nome_Album,
    Data_Lancamento_Album
FROM
    Album
WHERE
    Single = FALSE
ORDER BY
    Data_Lancamento_Album DESC
LIMIT 5;

-- 5. Qual é a média de idade dos ouvintes por tipo de plano?
CREATE OR REPLACE PROCEDURE sp_media_idade_ouvintes()
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT
        Tipo_Plano,
        AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, Data_Nascimento_Ouvinte))) AS Media_Idade
    FROM
        Ouvinte
    GROUP BY
        Tipo_Plano
    ORDER BY
        Media_Idade DESC;
END;
$$;

-- 6. Quais artistas têm mais de 5 álbuns e quais desses álbuns possuem mais de 10 mídias?
CREATE MATERIALIZED VIEW mv_artistas_mais_albuns AS
SELECT
    a.ID_Perfil,
    a.Nome_Artista,
    COUNT(al.ID_Album) AS Total_Albuns
FROM
    Artista a
JOIN
    Album al ON a.ID_Perfil = al.ID_Album
GROUP BY
    a.ID_Perfil, a.Nome_Artista
HAVING
    COUNT(al.ID_Album) > 5;

CREATE MATERIALIZED VIEW mv_albuns_mais_midias AS
SELECT
    ID_Album,
    COUNT(ID_Midia) AS Total_Midias
FROM
    Midia
GROUP BY
    ID_Album
HAVING
    COUNT(ID_Midia) > 10;

-- 7. Quais mídias foram lançadas nos últimos 30 dias e receberam mais de 100 interações (curtir)?
CREATE MATERIALIZED VIEW mv_midias_recentes_interacoes AS
SELECT
    m.ID_Midia,
    m.Nome_Midia,
    COUNT(pm.ID_Perfil) AS Total_Interacoes
FROM
    Midia m
LEFT JOIN
    Perfil_Midia pm ON m.ID_Midia = pm.ID_Midia AND pm.Tipo_Relacao = 'curtir'
WHERE
    m.Data_Lancamento_Midia >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY
    m.ID_Midia, m.Nome_Midia
HAVING
    COUNT(pm.ID_Perfil) > 100;

-- 8. Qual é a proporção de artistas verificados em relação ao total de artistas cadastrados?
CREATE OR REPLACE PROCEDURE sp_proporcao_artistas_verificados()
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT
        (COUNT(CASE WHEN Verificado = TRUE THEN 1 END) * 100.0) / COUNT(*) AS Proporcao_Verificados
    FROM
        Artista;
END;
$$;

-- 9. Quais mídias pertencem a categorias com mais de 100 mídias associadas?
CREATE MATERIALIZED VIEW mv_midias_em_categorias_populares AS
SELECT
    cm.ID_Midia,
    cm.ID_Categoria,
    c.Nome_Categoria
FROM
    Categoria_Midia cm
JOIN
    Categoria c ON cm.ID_Categoria = c.ID_Categoria
WHERE
    c.Num_Midias > 100;

-- 10. Quais conexões foram transformadas de 'seguir' para 'bloquear' no último mês?
CREATE OR REPLACE PROCEDURE sp_conexoes_transformadas()
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT
        ID_Perfil_1,
        ID_Perfil_2,
        'seguir' AS Antigo_Tipo,
        'bloquear' AS Novo_Tipo,
        NOW() AS Data_Alteracao
    FROM
        Conexao
    WHERE
        Tipo_Conexao = 'bloquear'
        AND Tipo_Conexao != 'seguir'
        AND EXTRACT(MONTH FROM NOW()) = EXTRACT(MONTH FROM CURRENT_DATE);
END;
$$;

-- Comandos de Visualização para cada pergunta, respectivamente:
-- 1.
SELECT * FROM mv_top_ouvintes_conexoes;

-- 2.
CALL sp_distribuicao_ouvintes_tipo_plano();

-- 3.
SELECT * FROM mv_categorias_mais_midias;

-- 4.
SELECT * FROM mv_albuns_mais_recentes;

-- 5.
CALL sp_media_idade_ouvintes();

-- 6.
-- a.
SELECT * FROM mv_artistas_mais_albuns;
-- b.
SELECT * FROM mv_albuns_mais_midias;

-- 7.
SELECT * FROM mv_midias_recentes_interacoes;

-- 8.
CALL sp_proporcao_artistas_verificados();

-- 9.
SELECT * FROM mv_midias_em_categorias_populares;

-- 10.
CALL sp_conexoes_transformadas();