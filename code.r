import pandas as pd

# Example list "game" with 7 lists
game = [
    ["A", "B", "C", "D", "E"],
    ["F", "G", "H", "I", "J", "K"],
    ["L", "M", "N", "O", "P", "", "", ""],
    ["Q", "R", "S", "T", "U", "V", "W", "X"],
    ["Y", "Z", "AA", "BB", "CC", "DD", "EE", "FF"],
    ["GG", "HH", "II", "JJ", "KK"],
    ["LL", "MM", "NN", "OO", "PP", "QQ"]
]

# Find the maximum length of lists in "game"
max_length = max(map(len, game))

# Equalize the length of all lists in "game"
game = [lst + [""] * (max_length - len(lst)) for lst in game]

# Create a DataFrame with dynamic column headers
columns = [f"Col{i+1}" for i in range(max_length)]
df = pd.DataFrame(game, columns=columns)

# Display the resulting DataFrame
print(df)
