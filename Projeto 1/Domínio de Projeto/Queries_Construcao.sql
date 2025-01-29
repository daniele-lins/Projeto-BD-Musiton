-- Tabela de Perfis
CREATE TABLE Perfil
(
	ID_Perfil SERIAL PRIMARY KEY,  
	Apelido VARCHAR(255) NOT NULL UNIQUE,  
	Bio VARCHAR(500),  
	Num_Seguindo INT DEFAULT 0,  
	Num_Seguidores INT DEFAULT 0  
);

-- Tabela de Álbum
CREATE TABLE Album
(
	ID_Album SERIAL PRIMARY KEY,  
	Nome_Album VARCHAR(255) NOT NULL,  
	Data_Lancamento_Album DATE NOT NULL,  
	Single BOOLEAN DEFAULT TRUE
);

-- Tabela de Categorias
CREATE TABLE Categoria
(
	ID_Categoria SERIAL PRIMARY KEY,  
	Nome_Categoria VARCHAR(255) NOT NULL UNIQUE,  
	Num_Midias INT DEFAULT 0  
);

-- Tabela de Artistas
CREATE TABLE Artista
(
	ID_Perfil INT PRIMARY KEY,   
	Nome_Artista VARCHAR(255) NOT NULL,  
	Email_Artista VARCHAR(255) NOT NULL UNIQUE,  
	Celular_Artista VARCHAR(20) UNIQUE,  
	Verificado BOOLEAN NOT NULL DEFAULT FALSE,
	Data_Nascimento_Artista DATE NOT NULL,
	FOREIGN KEY (ID_Perfil) REFERENCES Perfil(ID_Perfil)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

-- Tabela de Ouvintes
CREATE TABLE Ouvinte
(
	ID_Perfil INT PRIMARY KEY,    
	Nome_Ouvinte VARCHAR(255) NOT NULL,  
	Email_Ouvinte VARCHAR(255) NOT NULL UNIQUE,  
	Celular_Ouvinte VARCHAR(20) UNIQUE,
	Data_Nascimento_Ouvinte DATE NOT NULL,
	Tipo_Plano VARCHAR(50) NOT NULL DEFAULT 'grátis' CHECK (Tipo_Plano IN ('grátis', 'pro', 'universitário', 'família')),    
	FOREIGN KEY (ID_Perfil) REFERENCES Perfil(ID_Perfil)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

-- Tabela de Conexões
CREATE TABLE Conexao
(
	ID_Perfil_1 INT NOT NULL,  
	ID_Perfil_2 INT NOT NULL,  
	Tipo_Conexao VARCHAR(50) NOT NULL CHECK (Tipo_Conexao IN ('seguir', 'bloquear')),  
	PRIMARY KEY (ID_Perfil_1, ID_Perfil_2),  
	FOREIGN KEY (ID_Perfil_1) REFERENCES Perfil(ID_Perfil)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	FOREIGN KEY (ID_Perfil_2) REFERENCES Perfil(ID_Perfil)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT check_no_self_connection CHECK (ID_Perfil_1 != ID_Perfil_2)  -- Garante que o perfil não se conecte com ele mesmo
);

-- Tabela de Mídia
CREATE TABLE Midia
(
	ID_Midia SERIAL PRIMARY KEY,
	ID_Album INT NOT NULL,
	Nome_Midia VARCHAR(255) NOT NULL,  
	Tipo_Midia VARCHAR(50) NOT NULL CHECK (Tipo_Midia IN ('música', 'podcast')),  
	Data_Lancamento_Midia DATE NOT NULL,  
	Letra TEXT,
	FOREIGN KEY (ID_Album) REFERENCES Album(ID_Album)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

-- Tabela de Categoria_Midia
CREATE TABLE Categoria_Midia
(
	ID_Categoria INT NOT NULL,  
	ID_Midia INT NOT NULL,  
	PRIMARY KEY (ID_Categoria, ID_Midia),  
	FOREIGN KEY (ID_Categoria) REFERENCES Categoria(ID_Categoria)
	ON DELETE CASCADE
	ON UPDATE CASCADE,  
	FOREIGN KEY (ID_Midia) REFERENCES Midia(ID_Midia)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

-- Tabela de Perfil_Midia
CREATE TABLE Perfil_Midia
(
	ID_Perfil INT NOT NULL,  
	ID_Midia INT NOT NULL,  
	Tipo_Relacao VARCHAR(50) NOT NULL CHECK (Tipo_Relacao IN ('curtir', 'bloquear', 'lançar')),  
	PRIMARY KEY (ID_Perfil, ID_Midia),  
	FOREIGN KEY (ID_Perfil) REFERENCES Perfil(ID_Perfil)
	ON DELETE CASCADE
	ON UPDATE CASCADE,  
	FOREIGN KEY (ID_Midia) REFERENCES Midia(ID_Midia)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

-- Garantindo que as PKs auto-incrementáveis comecem sempre do 1
DO $$
BEGIN
	EXECUTE (
    	SELECT string_agg(
        	'ALTER SEQUENCE ' || c.relname || ' RESTART WITH 1;',
        	' '
    	)
    	FROM pg_class c
    	JOIN pg_namespace n ON n.oid = c.relnamespace
    	WHERE c.relkind = 'S' AND n.nspname = 'public'
	);
END $$;

-- Função para atualizar os números de seguidores e seguindo em Perfis
CREATE OR REPLACE FUNCTION atualizar_num_seguindo_seguidores()
RETURNS TRIGGER AS $$
BEGIN
	-- Atualiza o número de seguidores e seguindo na tabela de perfis
	UPDATE Perfil
	SET Num_Seguindo = (SELECT COUNT(*) FROM Conexao WHERE ID_Perfil_1 = NEW.ID_Perfil_1),
    	Num_Seguidores = (SELECT COUNT(*) FROM Conexao WHERE ID_Perfil_2 = NEW.ID_Perfil_2)
	WHERE ID_Perfil = NEW.ID_Perfil_1 OR ID_Perfil = NEW.ID_Perfil_2;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger para adicionar a atualização automática no momento da inserção e deleção de conexões
CREATE TRIGGER trigger_atualizar_conexao
AFTER INSERT OR DELETE ON Conexao
FOR EACH ROW EXECUTE FUNCTION atualizar_num_seguindo_seguidores();

-- Função para atualizar o campo Single no álbum
CREATE OR REPLACE FUNCTION atualizar_single_album()
RETURNS TRIGGER AS $$
BEGIN
	-- Verifica se o álbum tem apenas uma música
	IF (SELECT COUNT(*) FROM Midia WHERE ID_Album = NEW.ID_Album) = 1 THEN
    	-- Se tiver apenas uma música, marca o campo Single como TRUE
    	UPDATE Album
    	SET Single = TRUE
    	WHERE ID_Album = NEW.ID_Album;
	ELSE
    	-- Se tiver mais de uma música, marca o campo Single como FALSE
    	UPDATE Album
    	SET Single = FALSE
    	WHERE ID_Album = NEW.ID_Album;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para verificar a quantidade de músicas ao adicionar uma nova música
CREATE TRIGGER trigger_atualizar_single_album
AFTER INSERT OR DELETE ON Midia
FOR EACH ROW EXECUTE FUNCTION atualizar_single_album();

-- Função para excluir a relação de seguir quando um perfil bloquear outro
CREATE OR REPLACE FUNCTION excluir_relacao_seguir_quando_bloquear()
RETURNS TRIGGER AS $$
BEGIN
	-- Verifica se a conexão existente é do tipo 'seguir'
	IF OLD.Tipo_Conexao = 'seguir' THEN
    	DELETE FROM Conexao
    	WHERE (ID_Perfil_1 = OLD.ID_Perfil_1 AND ID_Perfil_2 = OLD.ID_Perfil_2)
       	OR (ID_Perfil_1 = OLD.ID_Perfil_2 AND ID_Perfil_2 = OLD.ID_Perfil_1);
	END IF;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger para excluir a relação de seguir quando um perfil bloquear outro
CREATE TRIGGER trigger_excluir_seguir_quando_bloquear
AFTER UPDATE ON Conexao
FOR EACH ROW
WHEN (OLD.Tipo_Conexao = 'seguir' AND NEW.Tipo_Conexao = 'bloquear')
EXECUTE FUNCTION excluir_relacao_seguir_quando_bloquear();

-- Função para excluir a relação de curtir quando um perfil bloquear uma mídia
CREATE OR REPLACE FUNCTION excluir_relacao_curtir_quando_bloquear_midia()
RETURNS TRIGGER AS $$
BEGIN
	-- Verifica se a relação de 'curtir' existe
	IF OLD.Tipo_Relacao = 'curtir' THEN
    	DELETE FROM Perfil_Midia
    	WHERE ID_Perfil = OLD.ID_Perfil AND ID_Midia = OLD.ID_Midia;
	END IF;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger para excluir a relação de curtir quando um perfil bloquear uma mídia
CREATE TRIGGER trigger_excluir_curtir_quando_bloquear_midia
AFTER UPDATE ON Perfil_Midia
FOR EACH ROW
WHEN (OLD.Tipo_Relacao = 'curtir' AND NEW.Tipo_Relacao = 'bloquear')
EXECUTE FUNCTION excluir_relacao_curtir_quando_bloquear_midia();

-- Função para garantir que artistas não possam curtir ou bloquear mídia
CREATE OR REPLACE FUNCTION verificar_tipo_perfil_midia()
RETURNS TRIGGER AS $$
BEGIN
	-- Se o perfil for de um artista, impede ações de 'curtir' ou 'bloquear' em mídias
	IF (SELECT EXISTS(SELECT 1 FROM Artista WHERE ID_Perfil = NEW.ID_Perfil)) THEN
    	IF (NEW.Tipo_Relacao IN ('curtir', 'bloquear')) THEN
        	RAISE EXCEPTION 'Artistas não podem curtir ou bloquear mídias';
    	END IF;
	END IF;

	-- Se o perfil for de um ouvinte, impede que ele lance mídia
	IF (SELECT EXISTS(SELECT 1 FROM Ouvinte WHERE ID_Perfil = NEW.ID_Perfil)) THEN
    	IF (NEW.Tipo_Relacao = 'lançar') THEN
        	RAISE EXCEPTION 'Ouvintes não podem lançar mídia';
    	END IF;
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para chamar a função de verificação ao inserir ou atualizar uma relação na tabela Perfil_Midia
CREATE TRIGGER trigger_verificar_tipo_perfil_midia
BEFORE INSERT OR UPDATE ON Perfil_Midia
FOR EACH ROW EXECUTE FUNCTION verificar_tipo_perfil_midia();


-- Populando a tabela Perfil
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..200 LOOP
        INSERT INTO Perfil (Apelido)
        VALUES ('Apelido ' || i);
    END LOOP;
END;
$$;


-- Populando a tabela Album
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO Album (Nome_Album, Data_Lancamento_Album)
        VALUES ('Álbum ' || i, '2025-01-01');
    END LOOP;
END;
$$;

-- Populando a tabela Categoria
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO Categoria (Nome_Categoria)
        VALUES ('Categoria ' || i);
    END LOOP;
END;
$$;

-- Populando a tabela Artista
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO Artista (ID_Perfil, Nome_Artista, Email_Artista, Data_Nascimento_Artista)
        VALUES (i, 'Artista ' || i, 'artista' || i || '@email.com', '2000-01-01');
    END LOOP;
END;
$$;

-- Populando a tabela Ouvinte
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 101..200 LOOP
        INSERT INTO Ouvinte (ID_Perfil, Nome_Ouvinte, Email_Ouvinte, Data_Nascimento_Ouvinte)
        VALUES (i, 'Ouvinte ' || i - 100, 'ouvinte' || i - 100 || '@email.com', '2000-01-01');
    END LOOP;
END;
$$;

-- Populando a tabela Conexao
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..50 LOOP
        INSERT INTO Conexao (ID_Perfil_1, ID_Perfil_2, Tipo_Conexao)
        VALUES (i*2-1, i*2, 'seguir');
    END LOOP;
END;
$$;

-- Populando a tabela Midia
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO Midia (ID_Album, Nome_Midia, Tipo_Midia, Data_Lancamento_Midia)
        VALUES (i, 'Música ' || i, 'música', '2025-01-01');
    END LOOP;
END;
$$;

-- Populando a tabela Categoria_Midia
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO Categoria_Midia (ID_Categoria, ID_Midia)
        VALUES (i, i);
    END LOOP;
END;
$$;

-- Populando a tabela Perfil_Midia
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO Perfil_Midia (ID_Perfil, ID_Midia, Tipo_Relacao)
        VALUES (i, i, 'lançar');
    END LOOP;
END;
$$;

DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 101..200 LOOP
        INSERT INTO Perfil_Midia (ID_Perfil, ID_Midia, Tipo_Relacao)
        VALUES (i, i-100, 'curtir');
    END LOOP;
END;
$$;

