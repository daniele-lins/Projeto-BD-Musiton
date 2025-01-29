import os

# Função que apaga o banco de dados e seus arquivos csv:
def apagar():
    # Apagar o banco de dados
    if os.path.exists('musiton.db'):
        os.remove('musiton.db')
    if os.path.exists('musiton.db-wal'):
        os.remove('musiton.db-wal')
    
    # Apagar os arquivos csv
    if os.path.exists('Perfil.csv'):
        os.remove('Perfil.csv')
    if os.path.exists('Autenticacao.csv'):
        os.remove('Autenticacao.csv')
    if os.path.exists('Album.csv'):
        os.remove('Album.csv')
    if os.path.exists('Categoria.csv'):
        os.remove('Categoria.csv')
    if os.path.exists('Artista.csv'):
        os.remove('Artista.csv')
    if os.path.exists('Ouvinte.csv'):
        os.remove('Ouvinte.csv')
    if os.path.exists('Midia.csv'):
        os.remove('Midia.csv')
    if os.path.exists('Categoria_Midia.csv'):
        os.remove('Categoria_Midia.csv')
    if os.path.exists('Perfil_Midia.csv'):
        os.remove('Perfil_Midia.csv')
    if os.path.exists('Conexao.csv'):
        os.remove('Conexao.csv')
    if os.path.exists('baseline.csv'):
        os.remove('baseline.csv')
    if os.path.exists('melhoria_performance.csv'):
        os.remove('melhoria_performance.csv')
    
    print('Banco de dados apagado com sucesso!')

apagar()