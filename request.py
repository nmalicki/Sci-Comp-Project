
#https://github.com/swar/nba_api/blob/master/src/nba_api/stats/static/players.py
#https://openf1.org/?python#position
'''
from nba_api.stats.endpoints import playercareerstats

# Nikola Jokić
career = playercareerstats.PlayerCareerStats(player_id='203999') 

# pandas data frames (optional: pip install pandas)
career.get_data_frames()[0]

# json
career.get_json()

# dictionary
career.get_dict()
'''
##############
from nba_api.stats.library.data import players
from nba_api.stats.static.players import _find_players


print(_find_players("Derrick White", players.player_index_full_name, players))