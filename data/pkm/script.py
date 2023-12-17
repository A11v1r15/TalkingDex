import argparse
import requests
import json

def fetch_pokemon_data(pokemon_number):
    # URL for fetching Pokémon data by number from PokéAPI
    api_url = f"https://pokeapi.co/api/v2/pokemon/{pokemon_number}/"

    # Make a GET request to the API
    response = requests.get(api_url)

    # Check if the request was successful (status code 200)
    if response.status_code == 200:
        # Parse the JSON response
        pokemon_data = response.json()

        # Fetch additional details from the species endpoint
        species_url = f"https://pokeapi.co/api/v2/pokemon-species/{pokemon_number}/"
        species_response = requests.get(species_url)

        if species_response.status_code == 200:
            species_data = species_response.json()

            # Find the index where the language is "en" in the "genera" field
            category_en_index = next((index for (index, entry) in enumerate(species_data["genera"]) if entry["language"]["name"] == "en"), None)

            # Extract relevant information
            formatted_data = {
                "number": pokemon_number,
                "name": pokemon_data["name"].replace("-", " ").encode('utf-8').decode('unicode-escape').title(),
                "category": species_data["genera"][category_en_index]["genus"].encode('utf-8').decode('unicode-escape').title() if category_en_index is not None else "Unknown",
                "colour": species_data["color"]["name"].title(),
                "height": f"{pokemon_data['height'] / 10:.1f}m",
                "weight": f"{pokemon_data['weight'] / 10:.1f}kg",
                "xpGroup": species_data["growth_rate"]["name"].replace("-", " ").title(),
                "XPYield": pokemon_data["base_experience"],
                "HP": pokemon_data["stats"][0]["base_stat"],
                "Atk": pokemon_data["stats"][1]["base_stat"],
                "Def": pokemon_data["stats"][2]["base_stat"],
                "SpAtk": pokemon_data["stats"][3]["base_stat"],
                "SpDef": pokemon_data["stats"][4]["base_stat"],
                "Speed": pokemon_data["stats"][5]["base_stat"],
                "HPYield": pokemon_data["stats"][0]["effort"],
                "AtkYield": pokemon_data["stats"][1]["effort"],
                "DefYield": pokemon_data["stats"][2]["effort"],
                "SpAtkYield": pokemon_data["stats"][3]["effort"],
                "SpDefYield": pokemon_data["stats"][4]["effort"],
                "SpeedYield": pokemon_data["stats"][5]["effort"],
                "extraMega": False,
                "hasGigantamax": False,
                "hasAlolan": False,
                "hasGalarian": False,
                "hasMega": False,
            }

            return formatted_data
        else:
            print(f"Error: Unable to fetch species data for Pokémon {pokemon_number}. Status Code: {species_response.status_code}")
            return None
    else:
        # Print an error message if the request was not successful
        print(f"Error: Unable to fetch data for Pokémon {pokemon_number}. Status Code: {response.status_code}")
        return None

def save_to_file(pokemon_data, filename):
    with open(filename, "w") as file:
        json.dump(pokemon_data, file, indent=2)
    print(f"Pokemon data saved to {filename}")

def main():
    # Set up command-line argument parser
    parser = argparse.ArgumentParser(description="Fetch Pokémon data from PokéAPI and save it to a file.")
    parser.add_argument("-n", "--number", type=int, help="Pokémon number")
    parser.add_argument("-o", "--output", help="Output filename")

    # Parse command-line arguments
    args = parser.parse_args()

    # Check if the "number" argument is provided
    if args.number is not None:
        # Set the default output filename
        if args.output is None:
            args.output = f"{str(args.number)}.json"

        # Fetch Pokémon data using the provided number
        pokemon_data = fetch_pokemon_data(args.number)

        if pokemon_data:
            # Save the formatted Pokémon data to a file
            save_to_file(pokemon_data, args.output)
    else:
        print("Error: Please provide a Pokémon number using the -n or --number argument.")

if __name__ == "__main__":
    main()
