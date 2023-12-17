import json
import os
import requests

def fetch_species_data(pokemon_number):
    species_url = f"https://pokeapi.co/api/v2/pokemon-species/{pokemon_number}/"
    response = requests.get(species_url)

    if response.status_code == 200:
        species_data = response.json()
        return species_data
    else:
        print(f"Error: Unable to fetch species data for Pokémon {pokemon_number}. Status Code: {response.status_code}")
        return None

def add_flavor_text_entries(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        data = json.load(file)

    # Ensure 'number' key exists in the loaded JSON data, if not add the number by parsing file_path
    if 'number' not in data:
        # Extract the number from the file path
        try:
            file_number = int(file_path.split('\\')[-1].split('.')[0])  # Adjusted to handle Windows paths
            data['number'] = file_number
            print(f"Added 'number' key with value {file_number} to {file_path}")
        except ValueError:
            print(f"Error: Unable to extract number from file path {file_path}. Skipping flavor text entries.")
            return

    # Fetch species data to get flavor text entries
    species_data = fetch_species_data(data['number'])

    if species_data:
        # Get flavor text entries for Scarlet and Violet
        scarlet_entry = next((entry['flavor_text'] for entry in species_data['flavor_text_entries'] if entry['language']['name'] == 'en' and entry['version']['name'] == 'scarlet'), None)
        violet_entry = next((entry['flavor_text'] for entry in species_data['flavor_text_entries'] if entry['language']['name'] == 'en' and entry['version']['name'] == 'violet'), None)

        print(f"Added flavor_text_entries for Scarlet and Violet to {file_path}:")
        # Add flavor_text_entries for Scarlet and Violet if found
        if scarlet_entry is not None:
            data['ScarletEntry'] = scarlet_entry
            print(scarlet_entry)
        if violet_entry is not None:
            data['VioletEntry'] = violet_entry
            print(violet_entry)

        with open(file_path, 'w', encoding='utf-8') as file:
            json.dump(data, file, indent=2, ensure_ascii=False)
    else:
        print(f"Flavor text entries not added. Species data not available for Pokémon {data.get('number', 'Unknown')}.")

def process_pokemon_files(start_index, end_index):
    current_directory = os.getcwd()

    for i in range(start_index, end_index + 1):
        file_name = f"{str(i).zfill(4)}.pkm"
        file_path = os.path.join(current_directory, file_name)

        if os.path.exists(file_path):
            add_flavor_text_entries(file_path)
        else:
            print(f"File {file_name} not found.")

# Example usage:
start_index = 890
end_index = 1017

process_pokemon_files(start_index, end_index)
