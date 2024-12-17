
#https://openf1.org/?python#position

from urllib.request import urlopen
import json

response = urlopen('https://api.openf1.org/v1/sessions?session_type=Race')
session_data = json.loads(response.read().decode('utf-8'))
session_keys_2023 = []
session_keys_2024 = []
for i in range(len(session_data)):
    if(session_data[i]["date_start"].split("-")[0] == "2023"):
        session_keys_2023.append((session_data[i]["session_key"], session_data[i]["session_name"], session_data[i]["circuit_short_name"]))
    else:
        session_keys_2024.append((session_data[i]["session_key"], session_data[i]["session_name"], session_data[i]["circuit_short_name"]))

print("Sessions Keys for", len(session_keys_2023),"Retrieved")
race_results_2023 = []

print("Parcing Session Data")
for i in range(len(session_keys_2023)):
    response = urlopen('https://api.openf1.org/v1/position?session_key=' + str(session_keys_2023[i][0]))
    data = json.loads(response.read().decode('utf-8'))
    finishing_order = [session_keys_2023[i][2] + ":" + session_keys_2023[i][1], []]
    for _ in range(20):
        finishing_order[1].append(None)
    j = len(data) - 1
    while j > -1 and None in finishing_order[1]:
        if finishing_order[1][data[j]["position"] - 1] == None:
            finishing_order[1][data[j]["position"] - 1] = data[j]
        j -= 1
    race_results_2023.append(finishing_order)
    print("Race", i+1, "of", len(session_keys_2023), "Parced")

print("Writing to JSON")
with open("2023_results.json", "w") as outfile:
    json.dump(race_results_2023, outfile, indent=4)

