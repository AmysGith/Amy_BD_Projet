import pandas as pd
import psycopg2

# Connexion PostgreSQL
conn = psycopg2.connect(
    host="localhost",
    database="amy_db_software_bug_tracking_system",
    user="postgres",
    password="EUs4BN%K6cPM",
    port=5432
)

# Récupérer les données de la table project
df = pd.read_sql_query("SELECT * FROM project", conn)



# Créer des colonnes normalisées (enlever espaces et mettre en majuscules)
df['name_normalized'] = df['name'].str.strip().str.upper()
df['client_normalized'] = df['client'].str.strip().str.upper()

# Trouver les doublons sémantiques
duplicates = df.groupby(['name_normalized', 'client_normalized', 'startdate', 'enddate', 'version']).filter(lambda x: len(x) > 1)
duplicates = duplicates.sort_values(['name_normalized', 'client_normalized', 'startdate'])

# Afficher les doublons groupés
print(f"=== TOTAL: {len(duplicates)} lignes en doublon ({len(duplicates)//2} paires) ===\n")

groups = duplicates.groupby(['name_normalized', 'client_normalized', 'startdate', 'enddate', 'version'])
group_num = 1

for (name_norm, client_norm, start, end, ver), group in groups:
    print(f"GROUPE {group_num}:")
    for idx, row in group.iterrows():
        print(f"  Ligne {row['projectid']:>2} : {row['name']:30} | {row['client']:40} | {start} → {end} | v{ver}")
    print()
    group_num += 1


# Fermer la connexion
conn.close()