# Esse script cria um banco de dados com as tabelas necessárias para o projeto Musiton.
import hashlib
import os

import duckdb
from faker import Faker

faker = Faker()

# Se conectar ao banco de dados musiton.db
conn = duckdb.connect('musiton.db')
c = conn.cursor()

# Criar sequências para autoincrementação de IDs
c.execute("CREATE SEQUENCE seq_perfil START 1;")
c.execute("CREATE SEQUENCE seq_album START 1;")
c.execute("CREATE SEQUENCE seq_categoria START 1;")
c.execute("CREATE SEQUENCE seq_midia START 1;")

# Criar tabelas
c.execute('''
    -- Tabela de Perfis
CREATE TABLE Perfil
(
    ID_Perfil INTEGER PRIMARY KEY DEFAULT nextval('seq_perfil'),
    Apelido VARCHAR(255) NOT NULL UNIQUE,
    Bio VARCHAR(500),
    Num_Seguindo INTEGER DEFAULT 0,
    Num_Seguidores INTEGER DEFAULT 0
);
''')

c.execute('''
    -- Tabela de Autenticacao
    CREATE TABLE Autenticacao (
        ID_Perfil INTEGER PRIMARY KEY NOT NULL,
        Senha_Hash VARCHAR(255) NOT NULL,
        Salt VARCHAR(255) NOT NULL,
        FOREIGN KEY (ID_Perfil) REFERENCES Perfil(ID_Perfil)
    );
''')

c.execute('''
    -- Tabela de Álbum
    CREATE TABLE Album (
        ID_Album INTEGER PRIMARY KEY DEFAULT nextval('seq_album'),
        Nome_Album VARCHAR(255) NOT NULL,
        Data_Lancamento_Album DATE NOT NULL,
        Single BOOLEAN DEFAULT TRUE
    );
''')

c.execute('''
    -- Tabela de Categorias
    CREATE TABLE Categoria (
        ID_Categoria INTEGER PRIMARY KEY DEFAULT nextval('seq_categoria'),
        Nome_Categoria VARCHAR(255) NOT NULL UNIQUE,
        Num_Midias INTEGER DEFAULT 0
    );
''')

c.execute('''
    -- Tabela de Artistas
    CREATE TABLE Artista (
        ID_Perfil INTEGER PRIMARY KEY,
        Nome_Artista VARCHAR(255) NOT NULL,
        Email_Artista VARCHAR(255) NOT NULL UNIQUE,
        Celular_Artista VARCHAR(20) UNIQUE,
        Verificado BOOLEAN NOT NULL DEFAULT FALSE,
        Data_Nascimento_Artista DATE NOT NULL,
        FOREIGN KEY (ID_Perfil) REFERENCES Perfil(ID_Perfil)
    );
''')

c.execute('''
    -- Tabela de Ouvintes
    CREATE TABLE Ouvinte (
        ID_Perfil INTEGER PRIMARY KEY,
        Nome_Ouvinte VARCHAR(255) NOT NULL,
        Email_Ouvinte VARCHAR(255) NOT NULL UNIQUE,
        Celular_Ouvinte VARCHAR(20) UNIQUE,
        Data_Nascimento_Ouvinte DATE NOT NULL,
        Tipo_Plano VARCHAR(50) NOT NULL DEFAULT 'grátis' CHECK (Tipo_Plano IN ('grátis', 'pro', 'universitário', 'família')),
        FOREIGN KEY (ID_Perfil) REFERENCES Perfil(ID_Perfil)
    );
''')

c.execute('''
    -- Tabela de Conexões
    CREATE TABLE Conexao (
        ID_Perfil_1 INTEGER NOT NULL,
        ID_Perfil_2 INTEGER NOT NULL,
        Tipo_Conexao VARCHAR(50) NOT NULL CHECK (Tipo_Conexao IN ('seguir', 'bloquear')),
        PRIMARY KEY (ID_Perfil_1, ID_Perfil_2),
        FOREIGN KEY (ID_Perfil_1) REFERENCES Perfil(ID_Perfil),
        FOREIGN KEY (ID_Perfil_2) REFERENCES Perfil(ID_Perfil),
        CONSTRAINT check_no_self_connection CHECK (ID_Perfil_1 != ID_Perfil_2)
    );
''')

c.execute('''
    -- Tabela de Mídia
    CREATE TABLE Midia (
        ID_Midia INTEGER PRIMARY KEY DEFAULT nextval('seq_midia'),
        ID_Album INTEGER NOT NULL,
        Nome_Midia VARCHAR(255) NOT NULL,
        Tipo_Midia VARCHAR(50) NOT NULL CHECK (Tipo_Midia IN ('música', 'podcast')),
        Data_Lancamento_Midia DATE NOT NULL,
        Letra TEXT,
        FOREIGN KEY (ID_Album) REFERENCES Album(ID_Album)
    );
''')

c.execute('''
    -- Tabela de Categoria_Midia
    CREATE TABLE Categoria_Midia (
        ID_Categoria INTEGER NOT NULL,
        ID_Midia INTEGER NOT NULL,
        PRIMARY KEY (ID_Categoria, ID_Midia),
        FOREIGN KEY (ID_Categoria) REFERENCES Categoria(ID_Categoria),
        FOREIGN KEY (ID_Midia) REFERENCES Midia(ID_Midia)
    );
''')

c.execute('''
    -- Tabela de Perfil_Midia
    CREATE TABLE Perfil_Midia (
        ID_Perfil INTEGER NOT NULL,
        ID_Midia INTEGER NOT NULL,
        Tipo_Relacao VARCHAR(50) NOT NULL CHECK (Tipo_Relacao IN ('curtir', 'bloquear', 'lançar')),
        PRIMARY KEY (ID_Perfil, ID_Midia),
        FOREIGN KEY (ID_Perfil) REFERENCES Perfil(ID_Perfil),
        FOREIGN KEY (ID_Midia) REFERENCES Midia(ID_Midia)
    );
''')

# Gerar a função que cria e atualiza os arquivos CSV para cada tabela
def update_csv_files():
    c.execute("COPY Perfil TO 'Perfil.csv' (HEADER);")
    c.execute("COPY Autenticacao TO 'Autenticacao.csv' (HEADER);")
    c.execute("COPY Album TO 'Album.csv' (HEADER);")
    c.execute("COPY Categoria TO 'Categoria.csv' (HEADER);")
    c.execute("COPY Artista TO 'Artista.csv' (HEADER);")
    c.execute("COPY Ouvinte TO 'Ouvinte.csv' (HEADER);")
    c.execute("COPY Midia TO 'Midia.csv' (HEADER);")
    c.execute("COPY Categoria_Midia TO 'Categoria_Midia.csv' (HEADER);")
    c.execute("COPY Perfil_Midia TO 'Perfil_Midia.csv' (HEADER);")
    c.execute("COPY Conexao TO 'Conexao.csv' (HEADER);")

update_csv_files()

# Popular tabelas de perfil e autenticação com 1000 tuplas cada, e as tabelas de artista e ouvinte com 500 tuplas cada (total de tuplas = 2000)
for i in range(1000):
    # Insere o perfil, se o apelido já existir, tenta outro
    apelido = 'Apelido' + str(i+1)
    c.execute(f'''
        INSERT INTO Perfil (Apelido)
        VALUES ('{apelido}');
    ''')

    c.execute(f'''
        INSERT INTO Autenticacao (ID_Perfil, Senha_Hash, Salt)
        VALUES ({i + 1}, '{hashlib.sha256(faker.password().encode() + os.urandom(32)).hexdigest()}', '{os.urandom(32).hex()}');
    ''')

    # Gera emails para artistas e ouvintes
    email = 'perfil' + str(i+1) + '@gmail.com'

    # Se o id do perfil for de 1 a 500, então é um artista, caso contrário é um ouvinte
    if i < 500:
        email = 'perfil' + str(i+1) + '@gmail.com'
        c.execute(f'''
            INSERT INTO Artista (ID_Perfil, Nome_Artista, Email_Artista, Data_Nascimento_Artista)
            VALUES ({i + 1}, '{faker.name()}', '{email}', '{faker.date_of_birth()}');
        ''')
    else:
        c.execute(f'''
            INSERT INTO Ouvinte (ID_Perfil, Nome_Ouvinte, Email_Ouvinte, Data_Nascimento_Ouvinte)
            VALUES ({i + 1}, '{faker.name()}', '{email}', '{faker.date_of_birth()}');
        ''')
    

# Popular tabelas de álbum, categoria, mídia, categoria_midia e perfil_midia com 500 tuplas cada (total de tuplas = 2500)
for i in range(500):
    c.execute(f'''
        INSERT INTO Album (Nome_Album, Data_Lancamento_Album)
        VALUES ('{faker.word()}', '{faker.date_this_decade()}');
    ''')

    categoria = 'Categoria' + str(i+1)
    c.execute(f'''
        INSERT INTO Categoria (Nome_Categoria)
        VALUES ('{categoria}');
    ''')

    c.execute(f'''
        INSERT INTO Midia (ID_Album, Nome_Midia, Tipo_Midia, Data_Lancamento_Midia)
        VALUES ({i + 1}, '{faker.word()}', 'música', '{faker.date_this_decade()}');
    ''')

    c.execute(f'''
        INSERT INTO Categoria_Midia (ID_Categoria, ID_Midia)
        VALUES ({i + 1}, {i + 1});
    ''')

    # Artistas lançam mídias
    c.execute(f'''
        INSERT INTO Perfil_Midia (ID_Perfil, ID_Midia, Tipo_Relacao)
        VALUES ({i + 1}, {i + 1}, 'lançar');
    ''')

    # Ouvintes curtem mídias
    c.execute(f'''
        INSERT INTO Perfil_Midia (ID_Perfil, ID_Midia, Tipo_Relacao)
        VALUES ({i + 501}, {i + 1}, 'curtir');
    ''')

# Popular tabelas de conexao com 1000 tuplas (total de tuplas = 1000)
for _ in range(1000):
    id_perfil_1 = faker.random_int(1, 1000)
    id_perfil_2 = faker.random_int(1, 1000)
        
    # Impedir que um perfil siga a si mesmo
    while id_perfil_1 == id_perfil_2:
        id_perfil_2 = faker.random_int(1, 1000)
        
    # Verificar se a conexão já existe
    c.execute(f'''
        SELECT COUNT(*)
        FROM Conexao
        WHERE (ID_Perfil_1 = {id_perfil_1} AND ID_Perfil_2 = {id_perfil_2} AND Tipo_Conexao = 'seguir');
    ''')
    if c.fetchone()[0] == 0:
        c.execute(f'''
            INSERT INTO Conexao (ID_Perfil_1, ID_Perfil_2, Tipo_Conexao)
            VALUES ({id_perfil_1}, {id_perfil_2}, 'seguir');
        ''')

# Atualizar arquivos CSV
update_csv_files()

# Commit e fechar conexão
conn.commit()
conn.close()