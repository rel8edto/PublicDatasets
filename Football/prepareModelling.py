import pandas as pd

df = pd.read_csv('mdollingData.csv')

df

df['target'] = df['eventType'].notna()

for product in ['Softdrink', 'Beer', 'Hotdog', 'Book']:
    df[product] = df['products'].apply(lambda x: product in x)


df.to_csv('mdollingDataOut.csv', index=0)