import duckdb
import time

# Se conectar ao banco de dados musiton.db
conn = duckdb.connect('musiton.db')
c = conn.cursor()

# Função para medir o tempo médio de execução de uma query
def medir_tempo_medio(query, repeticoes=50):
    tempos = []
    for _ in range(repeticoes):
        inicio = time.time()
        c.execute(query)
        fim = time.time()
        tempos.append(fim - inicio)
    return sum(tempos) / repeticoes
    
# Lista de queries
queries = [
    "SELECT * FROM Perfil;",
    "SELECT * FROM Perfil WHERE Apelido = 'Apelido1';",
    "SELECT COUNT(*) AS Total_Perfis FROM Perfil;",
    "SELECT * FROM Perfil WHERE Num_Seguidores > 100;",
    "SELECT * FROM Autenticacao WHERE ID_Perfil = 1;",
    "SELECT * FROM Album WHERE Data_Lancamento_Album > '2020-01-01';",
    "SELECT * FROM Album WHERE Single = FALSE;",
    "SELECT * FROM Categoria;",
    "SELECT ID_Categoria, COUNT(ID_Midia) AS Total_Midias FROM Categoria_Midia GROUP BY ID_Categoria;",
    "SELECT * FROM Artista WHERE Verificado = TRUE;",
    "SELECT * FROM Ouvinte WHERE Tipo_Plano = 'pro';",
    "SELECT Tipo_Plano, COUNT(*) AS Total_Ouvintes FROM Ouvinte GROUP BY Tipo_Plano;",
    "SELECT * FROM Conexao WHERE ID_Perfil_1 = 1 OR ID_Perfil_2 = 1;",
    "SELECT * FROM Midia WHERE ID_Album = 5;",
    "SELECT * FROM Midia WHERE Tipo_Midia = 'música' AND Data_Lancamento_Midia BETWEEN '2023-01-01' AND '2023-12-31';",
    "SELECT * FROM Perfil_Midia WHERE ID_Perfil = 2 AND Tipo_Relacao = 'bloquear';",
    "SELECT ID_Perfil, COUNT(*) AS Total_Curtidas FROM Perfil_Midia WHERE Tipo_Relacao = 'curtir' GROUP BY ID_Perfil;",
    "SELECT m.Nome_Midia FROM Midia m JOIN Categoria_Midia cm ON m.ID_Midia = cm.ID_Midia JOIN Categoria c ON cm.ID_Categoria = c.ID_Categoria WHERE c.Nome_Categoria = 'Categoria1';",
    "SELECT * FROM Artista WHERE EXTRACT(MONTH FROM Data_Nascimento_Artista) = 1;",
    "SELECT * FROM Perfil ORDER BY Num_Seguidores DESC LIMIT 5;",
    "SELECT * FROM Album WHERE Data_Lancamento_Album >= CURRENT_DATE - INTERVAL '5 years';",
    "SELECT * FROM Ouvinte WHERE DATE_PART('year', AGE(Data_Nascimento_Ouvinte)) > 25;",
    "SELECT m.* FROM Midia m JOIN Perfil_Midia pm ON m.ID_Midia = pm.ID_Midia JOIN Artista a ON pm.ID_Perfil = a.ID_Perfil WHERE a.Nome_Artista = 'Charles Proctor' AND pm.Tipo_Relacao = 'lançar';",
    "SELECT c1.ID_Perfil_1, c1.ID_Perfil_2 FROM Conexao c1 JOIN Conexao c2 ON c1.ID_Perfil_1 = c2.ID_Perfil_2 AND c1.ID_Perfil_2 = c2.ID_Perfil_1 WHERE c1.Tipo_Conexao = 'seguir';",
    "SELECT * FROM Perfil WHERE Num_Seguindo = 0;",
    "SELECT COUNT(*) AS Total_Artistas FROM Artista;",
    "SELECT m.Nome_Midia, a.Nome_Album FROM Midia m JOIN Album a ON m.ID_Album = a.ID_Album;",
    "SELECT COUNT(m.ID_Midia) AS Total_Midias_Verificadas FROM Midia m JOIN Perfil_Midia pm ON m.ID_Midia = pm.ID_Midia JOIN Artista a ON pm.ID_Perfil = a.ID_Perfil WHERE a.Verificado = TRUE AND pm.Tipo_Relacao = 'lançar';",
    "SELECT * FROM Ouvinte WHERE Celular_Ouvinte IS NOT NULL;",
    "SELECT p1.Apelido AS Seguidor, p2.Apelido AS Seguido FROM Conexao c JOIN Perfil p1 ON c.ID_Perfil_1 = p1.ID_Perfil JOIN Perfil p2 ON c.ID_Perfil_2 = p2.ID_Perfil WHERE c.Tipo_Conexao = 'seguir';"
]

# Medir o tempo de execução de cada query e armazenar os resultados
resultados = []
for i, query in enumerate(queries):
    tempo = medir_tempo_medio(query)
    resultados.append((i + 1, tempo))

# Criar a tabela de baseline e inserir os resultados
c.execute("DROP TABLE IF EXISTS Baseline;")
c.execute("CREATE TABLE Baseline (Query INTEGER PRIMARY KEY, Tempo_Execucao FLOAT);")
c.executemany("INSERT INTO Baseline VALUES (?, ?);", resultados)
conn.commit()

# Função que cria e atualiza o arquivo csv da tabela de baseline
def atualizar_baseline():
    c.execute("SELECT * FROM Baseline;")
    resultados = c.fetchall()
    with open('baseline.csv', 'w') as f:
        f.write('Query,Tempo_Execucao\n')
        for linha in resultados:
            f.write(f'{linha[0]},{linha[1]}\n')

atualizar_baseline()

# Fazer tuning do banco de dados utilizando features do DuckDB
c.execute("SET threads TO 10")  # Paralelismo
c.execute("SET memory_limit TO '2GB'")  # Limitar uso de memória
c.execute("SET enable_object_cache TO TRUE") # Cache de objetos
c.execute("SET default_block_size TO 262144")  # Tamanho do bloco de leitura (256KB)
c.execute("SET force_compression TO 'Auto'")  # Compressão de dados

# Medir o tempo de execução de cada query após o tuning e armazenar os resultados
resultados_apos_tuning = []
for i, query in enumerate(queries):
    tempo = medir_tempo_medio(query)
    resultados_apos_tuning.append((i + 1, tempo))

# Criar a tabela de melhoria de performance e inserir os resultados
c.execute("DROP TABLE IF EXISTS Melhoria_Performance;")
c.execute("CREATE TABLE Melhoria_Performance (Query INTEGER PRIMARY KEY, Tempo_Baseline FLOAT, Tempo_Apos_Tuning FLOAT, Melhoria FLOAT);")

# Calcular a melhoria de performance e inserir os dados na tabela
melhorias = []
for i in range(len(resultados)):
    query_num = resultados[i][0]
    tempo_baseline = resultados[i][1]
    tempo_apos_tuning = resultados_apos_tuning[i][1]
    melhoria = ((tempo_baseline - tempo_apos_tuning) / tempo_baseline) * 100
    melhorias.append(melhoria)
    c.execute("INSERT INTO Melhoria_Performance VALUES (?, ?, ?, ?);", (query_num, tempo_baseline, tempo_apos_tuning, melhoria))

conn.commit()

# Função que cria e atualiza o arquivo csv da tabela de melhoria de performance
def atualizar_melhoria_performance():
    c.execute("SELECT * FROM Melhoria_Performance;")
    resultados = c.fetchall()
    with open('melhoria_performance.csv', 'w') as f:
        f.write('Query,Tempo_Baseline,Tempo_Apos_Tuning,Melhoria\n')
        for linha in resultados:
            f.write(f'{linha[0]},{linha[1]},{linha[2]},{linha[3]}\n')

atualizar_melhoria_performance()

# Calcular e imprimir a média de melhoria de performance
media_melhoria = sum(melhorias) / len(melhorias)
print(f'Média de melhoria de performance: {media_melhoria:.2f}%')

# Fechar a conexão com o banco de dados
conn.close()
