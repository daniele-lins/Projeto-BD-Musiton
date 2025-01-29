-- OBS: Rode as queries uma por uma e após ter construido e populado o banco de dados

-- INÍCIO DA TRANSAÇÃO
BEGIN TRANSACTION;

--1 Adicionar um ouvinte
INSERT INTO Perfil (Apelido, Bio)
VALUES ('Apelido 201', 'Amo música.');
INSERT INTO Ouvinte (ID_Perfil, Nome_Ouvinte, Email_Ouvinte, Data_Nascimento_Ouvinte)
VALUES (201, 'Ouvinte 101', 'ouvinte101@email.com', '2000-01-01');

--2 Adicionar um artista
INSERT INTO Perfil (Apelido, Bio)
VALUES ('Apelido 202', 'Amo música também.');
INSERT INTO Artista (ID_Perfil, Nome_Artista, Email_Artista, Data_Nascimento_Artista)
VALUES (202, 'Artista 101', 'artista101@email.com', '2000-01-01');

--3 Adicionar uma categoria
INSERT INTO Categoria (Nome_Categoria)
VALUES ('Categoria 101');

--4 Adicionar um álbum
INSERT INTO Album (Nome_Album, Data_Lancamento_Album)
VALUES ('Álbum 101', '2025-01-01');

--5 Adicionar uma mídia
INSERT INTO Midia (ID_Album, Nome_Midia, Tipo_Midia, Data_Lancamento_Midia)
VALUES (101, 'Mídia 101', 'música', '2025-01-01');

--6 Seguir um usuário
INSERT INTO Conexao (ID_Perfil_1, ID_Perfil_2, Tipo_Conexao)
VALUES (201, 202, 'seguir');

--7 Bloquear um usuário
INSERT INTO Conexao (ID_Perfil_1, ID_Perfil_2, Tipo_Conexao)
VALUES (199, 201, 'bloquear');

--8 Adicionar uma mídia a uma categoria
INSERT INTO Categoria_Midia (ID_Categoria, ID_Midia)
VALUES (101, 101);

--9 Curtir uma mídia
INSERT INTO Perfil_Midia (ID_Perfil, ID_Midia, Tipo_Relacao)
VALUES (102, 3, 'curtir');

--10 Bloquear uma mídia
INSERT INTO Perfil_Midia (ID_Perfil, ID_Midia, Tipo_Relacao)
VALUES (102, 4, 'bloquear');

--11 Adicionar a autoria de uma música a um artista
INSERT INTO Perfil_Midia (ID_Perfil, ID_Midia, Tipo_Relacao)
VALUES (1, 2, 'lançar');

-- DELETES:

--1 Tirar a autoria de um artista a uma música
DELETE FROM Perfil_Midia
WHERE ID_Perfil = 1 AND ID_Midia = 2 AND Tipo_Relacao = 'lançar';

--2 Desbloquear uma mídia
DELETE FROM Perfil_Midia
WHERE ID_Perfil = 102 AND ID_Midia = 4 AND Tipo_Relacao = 'bloquear';

--3 Descurtir uma mídia
DELETE FROM Perfil_Midia
WHERE ID_Perfil = 102 AND ID_Midia = 3 AND Tipo_Relacao = 'curtir';

--4 Remover uma mídia de uma categoria
DELETE FROM Categoria_Midia
WHERE ID_Categoria = 101 AND ID_Midia = 101;

--5 Desbloquear um usuário
DELETE FROM Conexao
WHERE ID_Perfil_1 = 199 AND ID_Perfil_2 = 201 AND Tipo_Conexao = 'bloquear';

--6 Deixar de seguir um usuário
DELETE FROM Conexao
WHERE ID_Perfil_1 = 201 AND ID_Perfil_2 = 202 AND Tipo_Conexao = 'seguir';

--7 Deletar uma mídia
DELETE FROM Midia
WHERE ID_Midia = 101;

--8 Deletar um álbum inteiro
DELETE FROM Album
WHERE ID_Album = 101;

--9 Deletar uma categoria
DELETE FROM Categoria
WHERE ID_Categoria = 101;

--10 Deletar um artista
DELETE FROM Artista
WHERE ID_Perfil = 202;

--11 Deletar um ouvinte
DELETE FROM Ouvinte
WHERE ID_Perfil = 201;

-- ALTERS:

--1 Alterar apelido e bio de um perfil
UPDATE Perfil 
SET Apelido = 'NovoApelido', Bio = 'Nova descrição do perfil' 
WHERE ID_Perfil = 1;

--2 Alterar nome e data de lançamento de um álbum
UPDATE Album 
SET Nome_Album = 'Novo Nome do Álbum', Data_Lancamento_Album = '2025-05-01' 
WHERE ID_Album = 1;

--3 Alterar nome de uma categoria
UPDATE Categoria 
SET Nome_Categoria = 'Novo Nome da Categoria' 
WHERE ID_Categoria = 1;

--4 Alterar nome e e-mail de um artista
UPDATE Artista 
SET Nome_Artista = 'Novo Nome do Artista', Email_Artista = 'novoemail@exemplo.com' 
WHERE ID_Perfil = 1;

--5 Tornar um artista verificado
UPDATE Artista 
SET Verificado = TRUE 
WHERE ID_Perfil = 1;

--6 Alterar nome e plano de um ouvinte
UPDATE Ouvinte 
SET Nome_Ouvinte = 'Novo Nome do Ouvinte', Tipo_Plano = 'pro' 
WHERE ID_Perfil = 101;

--7 Alterar nome e tipo de uma mídia
UPDATE Midia 
SET Nome_Midia = 'Novo Nome da Mídia', Tipo_Midia = 'podcast' 
WHERE ID_Midia = 1;

--8 Alterar data de lançamento e letra de uma mídia
UPDATE Midia 
SET Data_Lancamento_Midia = '2025-06-01', Letra = 'Nova letra da música ou podcast' 
WHERE ID_Midia = 1;

-- COMMIT
COMMIT;

--BUSCAS:

-- Buscar um perfil pelo ID
SELECT * FROM Perfil WHERE ID_Perfil = 20;

-- Buscar um perfil pelo apelido
SELECT * FROM Perfil WHERE Apelido LIKE '%Apelido 20%';

-- Buscar um álbum pelo ID
SELECT * FROM Album WHERE ID_Album = 20;

-- Buscar um álbum pelo nome
SELECT * FROM Album WHERE Nome_Album LIKE '%Álbum 20%';

-- Buscar as conexões de um perfil pelos ID's
SELECT c.*, p1.Apelido AS Apelido_Perfil_1, p2.Apelido AS Apelido_Perfil_2
FROM Conexao c
JOIN Perfil p1 ON c.ID_Perfil_1 = p1.ID_Perfil
JOIN Perfil p2 ON c.ID_Perfil_2 = p2.ID_Perfil
WHERE c.ID_Perfil_1 = 20 OR c.ID_Perfil_2 = 20;

-- Buscar as conexões de um perfil pelos apelidos
SELECT  p1.Apelido AS Perfil_1_Apelido, p2.Apelido AS Perfil_2_Apelido, c.Tipo_Conexao
FROM Conexao c
JOIN Perfil p1 ON c.ID_Perfil_1 = p1.ID_Perfil
JOIN Perfil p2 ON c.ID_Perfil_2 = p2.ID_Perfil
WHERE p1.Apelido LIKE '%Apelido 20%' OR p2.Apelido LIKE '%Apelido 20%';

-- Buscar uma mídia pelo ID
SELECT * FROM Midia WHERE ID_Midia = 20;

-- Buscar uma mídia pelo nome
SELECT * FROM Midia WHERE Nome_Midia LIKE '%Mídia 20%';

-- Buscar a quantidade de curtidas de uma música
SELECT COUNT(*) AS Curtidas
FROM Perfil_Midia
WHERE ID_Midia = 1 AND Tipo_Relacao = 'curtir';

-- Buscar categorias de uma mídia
SELECT Categoria.Nome_Categoria
FROM Categoria
JOIN Categoria_Midia ON Categoria.ID_Categoria = Categoria_Midia.ID_Categoria
WHERE Categoria_Midia.ID_Midia = 1;

-- Buscar mídias de uma categoria pelo ID
SELECT Midia.Nome_Midia
FROM Midia
JOIN Categoria_Midia ON Midia.ID_Midia = Categoria_Midia.ID_Midia
WHERE Categoria_Midia.ID_Categoria = 1;

-- Buscar mídias curtidas de um ouvinte pelo ID
SELECT m.Nome_Midia
FROM Midia m
JOIN Perfil_Midia pm ON m.ID_Midia = pm.ID_Midia
WHERE pm.ID_Perfil = 105 AND pm.Tipo_Relacao = 'curtir';

-- Buscar mídias bloqueadas por um ouvinte pelo ID
SELECT m.Nome_Midia
FROM Midia m
JOIN Perfil_Midia pm ON m.ID_Midia = pm.ID_Midia
WHERE pm.ID_Perfil = 105 AND pm.Tipo_Relacao = 'bloquear';

-- Buscar mídias lançadas por um artista pelo ID
SELECT m.Nome_Midia
FROM Midia m
JOIN Album a ON m.ID_Album = a.ID_Album
JOIN Artista ar ON a.ID_Album = ar.ID_Perfil
WHERE ar.ID_Perfil = 5;

-- Buscar todas as mídias de um artista pelo apelido
SELECT m.Nome_Midia, p.Apelido AS Apelido_Artista
FROM Midia m
JOIN Album a ON m.ID_Album = a.ID_Album
JOIN Artista ar ON a.ID_Album = ar.ID_Perfil
JOIN Perfil p ON ar.ID_Perfil = p.ID_Perfil
WHERE p.Apelido LIKE '%Apelido 5%';

-- Buscar "mutuals" de um perfil pelos IDs
SELECT p.Apelido
FROM Perfil p
JOIN Conexao c1 ON p.ID_Perfil = c1.ID_Perfil_2
JOIN Conexao c2 ON p.ID_Perfil = c2.ID_Perfil_1
WHERE c1.ID_Perfil_1 = 5 AND c2.ID_Perfil_2 = 6;

-- Buscar "mutuals" de um perfil pelos apelidos
SELECT p.Apelido
FROM Perfil p
JOIN Conexao c1 ON p.ID_Perfil = c1.ID_Perfil_2
JOIN Conexao c2 ON p.ID_Perfil = c2.ID_Perfil_1
JOIN Perfil p1 ON c1.ID_Perfil_1 = p1.ID_Perfil
JOIN Perfil p2 ON c2.ID_Perfil_2 = p2.ID_Perfil
WHERE p1.Apelido LIKE '%Apelido 5%' AND p2.Apelido LIKE '%Apelido 5%';

-- Buscar as mídias curtidas em comum entre dois perfis pelos IDs
SELECT m.Nome_Midia
FROM Midia m
JOIN Perfil_Midia pm1 ON m.ID_Midia = pm1.ID_Midia
JOIN Perfil_Midia pm2 ON m.ID_Midia = pm2.ID_Midia
WHERE pm1.ID_Perfil = 105 AND pm2.ID_Perfil = 106 AND pm1.Tipo_Relacao = 'curtir' AND pm2.Tipo_Relacao = 'curtir';

-- Buscar as mídias curtidas em comum entre dois perfis pelos apelidos
SELECT m.Nome_Midia
FROM Midia m
JOIN Perfil_Midia pm1 ON m.ID_Midia = pm1.ID_Midia
JOIN Perfil_Midia pm2 ON m.ID_Midia = pm2.ID_Midia
JOIN Perfil p1 ON pm1.ID_Perfil = p1.ID_Perfil
JOIN Perfil p2 ON pm2.ID_Perfil = p2.ID_Perfil
WHERE p1.Apelido LIKE '%Apelido 105%' AND p2.Apelido LIKE '%Apelido 106%' 
  AND pm1.Tipo_Relacao = 'curtir' AND pm2.Tipo_Relacao = 'curtir';

-- Buscar todos os álbuns de um artista pelo ID
SELECT a.Nome_Album
FROM Album a
JOIN Artista ar ON a.ID_Album = ar.ID_Perfil
WHERE ar.ID_Perfil = 10; 

-- Buscar todos os álbuns de um artista pelo apelido
SELECT a.Nome_Album
FROM Album a
JOIN Artista ar ON a.ID_Album = ar.ID_Perfil
JOIN Perfil p ON ar.ID_Perfil = p.ID_Perfil
WHERE p.Apelido LIKE '%Apelido 10%';

-- Buscar as 5 categorias mais curtidas de um ouvinte em um determinado período pelo ID
SELECT c.Nome_Categoria, COUNT(*) AS Curtidas
FROM Categoria c
JOIN Categoria_Midia cm ON c.ID_Categoria = cm.ID_Categoria
JOIN Perfil_Midia pm ON cm.ID_Midia = pm.ID_Midia
WHERE pm.ID_Perfil = 105
  AND pm.Tipo_Relacao = 'curtir'
  AND pm.Data_Curtida BETWEEN '2024-01-01' AND '2025-12-31'
GROUP BY c.Nome_Categoria
ORDER BY Curtidas DESC
LIMIT 5;

-- Buscar as 5 categorias mais curtidas de um ouvinte em um determinado período pelo apelido
SELECT c.Nome_Categoria, COUNT(*) AS num_curtidas
FROM Perfil_Midia pm
JOIN Midia m ON pm.ID_Midia = m.ID_Midia
JOIN Categoria_Midia cm ON m.ID_Midia = cm.ID_Midia
JOIN Categoria c ON cm.ID_Categoria = c.ID_Categoria
JOIN Ouvinte o ON pm.ID_Perfil = o.ID_Perfil
JOIN Perfil p ON o.ID_Perfil = p.ID_Perfil
WHERE p.Apelido LIKE '%Apelido 150%'
  AND pm.Tipo_Relacao = 'curtir'
  AND m.Data_Lancamento_Midia BETWEEN '2024-01-01' AND '2025-12-31'
GROUP BY c.Nome_Categoria
ORDER BY num_curtidas DESC
LIMIT 5;

-- Buscar as 5 categorias mais lançadas de um artista em um determinado período pelo ID
SELECT c.Nome_Categoria, COUNT(m.ID_Midia) AS Num_Midias
FROM Categoria c
JOIN Categoria_Midia cm ON c.ID_Categoria = cm.ID_Categoria
JOIN Midia m ON cm.ID_Midia = m.ID_Midia
JOIN Album a ON m.ID_Album = a.ID_Album
JOIN Artista ar ON a.ID_Album = ar.ID_Perfil
WHERE ar.ID_Perfil = 50 
AND m.Data_Lancamento_Midia BETWEEN '2024-01-01' AND '2025-12-31'
GROUP BY c.Nome_Categoria
ORDER BY Num_Midias DESC
LIMIT 5;

-- Buscar as 5 categorias mais lançadas de um artista em um determinado período pelo apelido
SELECT c.Nome_Categoria, COUNT(m.ID_Midia) AS Num_Midias
FROM Categoria c
JOIN Categoria_Midia cm ON c.ID_Categoria = cm.ID_Categoria
JOIN Midia m ON cm.ID_Midia = m.ID_Midia
JOIN Album a ON m.ID_Album = a.ID_Album
JOIN Artista ar ON a.ID_Album = ar.ID_Perfil
JOIN Perfil p ON ar.ID_Perfil = p.ID_Perfil
WHERE p.Apelido LIKE '%Apelido 50%'
AND m.Data_Lancamento_Midia BETWEEN '2024-01-01' AND '2025-12-31'
GROUP BY c.Nome_Categoria
ORDER BY Num_Midias DESC
LIMIT 5;

-- Buscar os 5 artistas mais curtidos de um ouvinte em um determinado período pelo ID
SELECT ar.Nome_Artista, COUNT(pm.ID_Midia) AS Num_Curtidas
FROM Perfil_Midia pm
JOIN Midia m ON pm.ID_Midia = m.ID_Midia
JOIN Album a ON m.ID_Album = a.ID_Album
JOIN Artista ar ON a.ID_Album = ar.ID_Perfil
WHERE pm.ID_Perfil = 150
AND pm.Tipo_Relacao = 'curtir'
AND m.Data_Lancamento_Midia BETWEEN '2024-01-01' AND '2025-12-31'
GROUP BY ar.Nome_Artista
ORDER BY Num_Curtidas DESC
LIMIT 5;

-- Buscar os 5 artistas mais curtidos de um ouvinte em um determinado período pelo apelido
SELECT ar.Nome_Artista, COUNT(pm.ID_Midia) AS Num_Curtidas
FROM Perfil_Midia pm
JOIN Midia m ON pm.ID_Midia = m.ID_Midia
JOIN Album a ON m.ID_Album = a.ID_Album
JOIN Artista ar ON a.ID_Album = ar.ID_Perfil
JOIN Perfil p ON pm.ID_Perfil = p.ID_Perfil
WHERE p.Apelido LIKE '%Apelido 150%'
AND pm.Tipo_Relacao = 'curtir'
AND m.Data_Lancamento_Midia BETWEEN '2024-01-01' AND '2025-12-31'
GROUP BY ar.Nome_Artista
ORDER BY Num_Curtidas DESC
LIMIT 5;

-- MATERIALIZED VIEWS

--1 Top 10 mídias mais curtidas
CREATE MATERIALIZED VIEW Top10MidiasCurtidas AS
SELECT 
    m.Nome_Midia, 
    COUNT(pm.ID_Perfil) AS Total_Curtidas
FROM 
    Midia m
JOIN 
    Perfil_Midia pm ON m.ID_Midia = pm.ID_Midia
WHERE 
    pm.Tipo_Relacao = 'curtir'
GROUP BY 
    m.Nome_Midia;
-- Criando um índice para melhorar a consulta futura
CREATE INDEX idx_top10_midia_curtidas ON Top10MidiasCurtidas (Total_Curtidas DESC);

-- Visualizar MV
SELECT * 
FROM Top10MidiasCurtidas
ORDER BY Total_Curtidas DESC
LIMIT 10;

--2 Top 10 artistas com mais curtidas totais
CREATE MATERIALIZED VIEW artistas_com_mais_curtidas AS
SELECT
    a.ID_Perfil AS ID_Artista,
    a.Nome_Artista,
    COUNT(pm.ID_Midia) AS Curtidas
FROM
    Artista a
JOIN
    Perfil_Midia pm ON a.ID_Perfil = pm.ID_Perfil
JOIN
    Midia m ON pm.ID_Midia = m.ID_Midia
JOIN
    Album al ON m.ID_Album = al.ID_Album
WHERE
    pm.Tipo_Relacao = 'curtir'
GROUP BY
    a.ID_Perfil, a.Nome_Artista
ORDER BY
    Curtidas DESC
LIMIT 10;

-- STORED PROCEDURES

--1 Última curtida de um ouvinte específico
CREATE OR REPLACE PROCEDURE obter_ultima_curtida_perfil(p_ID_Perfil INT)
LANGUAGE plpgsql
AS $$
DECLARE
    r_result RECORD;
BEGIN
    -- Consulta para pegar a última curtida do perfil
    FOR r_result IN
        SELECT 
            m.ID_Midia,
            m.Nome_Midia,
            a.Nome_Album,
            p.Apelido AS Apelido_Perfil
        FROM 
            Perfil_Midia pm
        JOIN 
            Midia m ON pm.ID_Midia = m.ID_Midia
        JOIN 
            Album a ON m.ID_Album = a.ID_Album
        JOIN 
            Perfil p ON pm.ID_Perfil = p.ID_Perfil
        WHERE 
            pm.ID_Perfil = p_ID_Perfil AND pm.Tipo_Relacao = 'curtir'
        ORDER BY 
            pm.ID_Midia DESC
        LIMIT 1
    LOOP
        -- Exibe o resultado da última curtida
        RAISE NOTICE 'ID_Midia: %, Nome_Midia: %, Nome_Album: %, Apelido: %', 
            r_result.ID_Midia, r_result.Nome_Midia, r_result.Nome_Album, r_result.Apelido_Perfil;
    END LOOP;
END;
$$;

-- Chamar a procedure
CALL obter_ultima_curtida_perfil(180);

--2 Posição de um artista específico no ranking global de curtidas
CREATE OR REPLACE PROCEDURE buscar_posicao_ranking_artista(
    p_id_artista INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ranking_posicao INT;
BEGIN
    -- Calcular a posição do artista no ranking com base no total de curtidas
    WITH Ranking AS (
        SELECT
            A.ID_Perfil,
            A.Nome_Artista,
            SUM(CASE WHEN PM.Tipo_Relacao = 'curtir' THEN 1 ELSE 0 END) AS Total_Curtidas
        FROM
            Artista A
        JOIN
            Perfil_Midia PM ON A.ID_Perfil = PM.ID_Perfil
        JOIN
            Midia M ON PM.ID_Midia = M.ID_Midia
        GROUP BY
            A.ID_Perfil, A.Nome_Artista
        ORDER BY
            Total_Curtidas DESC
    )
    -- Encontrar a posição do artista no ranking
    SELECT COUNT(*) + 1 INTO v_ranking_posicao
    FROM Ranking
    WHERE Total_Curtidas > (
        SELECT SUM(CASE WHEN PM.Tipo_Relacao = 'curtir' THEN 1 ELSE 0 END)
        FROM Perfil_Midia PM
        WHERE PM.ID_Perfil = p_id_artista
    );
    
    -- Exibir a posição no ranking
    RAISE NOTICE 'A posição do artista é: %', v_ranking_posicao;
END;
$$;

-- Chamar procedure
CALL buscar_posicao_ranking_artista(18); 