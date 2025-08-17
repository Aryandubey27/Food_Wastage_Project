import pandas as pd
import os

# Define file paths
data_folder = 'Sql_data'  # Assumes CSVs are in a subfolder named 'Sql_data'
output_folder = 'cleaned_data'
files = ['providers_data.csv', 'receivers_data.csv',
         'food_listings_data.csv', 'claims_data.csv']

# Create output directory if it doesn't exist
if not os.path.exists(output_folder):
    os.makedirs(output_folder)

for file_name in files:
    file_path = os.path.join(data_folder, file_name)
    print(f"--- Processing {file_name} ---")

    # Read the data
    df = pd.read_csv(file_path)

    # 1. Check for missing values
    print("Missing values before cleaning:")
    print(df.isnull().sum())
    # For this dataset, no crucial data is missing, but in a real project, you might fill or drop them.

    # 2. Example of data standardization (can be expanded)
    # We can standardize text columns to a consistent case, e.g., Title Case
    for col in df.select_dtypes(include=['object']).columns:
        df[col] = df[col].str.title()

    # 3. Save the cleaned file
    cleaned_file_path = os.path.join(
        output_folder, file_name.replace('.csv', '_cleaned.csv'))
    df.to_csv(cleaned_file_path, index=False)
    print(f"✅ Saved cleaned data to {cleaned_file_path}\n")
