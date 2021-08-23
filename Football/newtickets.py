import pandas as pd
import random

person = pd.read_csv('person.csv')

events = pd.read_csv('events.csv').dropna(how='all')

events[['EvtID', 'ticketID', 'Type', 'SecurityGuardTeam', 'Person', 'Gate',
       'Softdrink', 'Beer', 'Hotdog', 'Book', 'Seat', 'Seat.1', 'Seat.2',
       'date']]

sold = pd.melt(events[['Seat', 'Seat.1', 'Seat.2', 'date','Person']],['date','Person']).dropna()

seats = [f'{g}{n}' for g in 'ABCDEFGH' for n in range(1,21)]

dates = list(sold['date'].unique())

dates += ['1-Feb','2-Feb','3-Feb','4-Feb','5-Feb','6-Feb','7-Feb','8-Feb','9-Feb','10-Feb','11-Feb','12-Feb','13-Feb',
        '14-Feb','15-Feb','16-Feb','17-Feb','18-Feb','19-Feb','20-Feb','21-Feb','22-Feb','23-Feb']

bookings = []
for day in dates:
    goodguys = person.query('commit.isna()')['Name'].unique()
    goodguys = [guy for guy in goodguys if guy not in sold.loc[sold['date']==day,'Person'].unique()]
    random.shuffle(goodguys)
    goodguys[3] = None
    for gate in  'ABCDEFGH':
        seats = [f'{gate}{n}' for n in range(1,21)]
        seats = [seat for seat in seats if seat not in sold.query('date == @day')['value'].unique()]
        for guy in goodguys:
            pick = random.randint(0,4)
            for p in range(pick):
                bookings.append({'name':guy,'seat':seats.pop(0),'date':day})
                if len(seats) == 0:
                    break
            if len(seats) == 0:
                break


seatsdf = pd.DataFrame(bookings).dropna(subset=['name'])

sold = sold[['date','Person','value']]
sold.columns = ['date','name','seat']


seatsdf = pd.concat([seatsdf, sold])
seatsdf['ticketkey'] = seatsdf['date'] + seatsdf['name']
idx = list(seatsdf['ticketkey'].unique())
seatsdf['ticketid'] = seatsdf['ticketkey'].apply(lambda x: idx.index(x))
seatsdf['Month'] = seatsdf['date'].apply(lambda x: x[-3:])

seatsdf.to_csv('ticket.csv', index=0)

events['ticketkey'] = events['date'] + events['Person']

events = events.merge(seatsdf[['ticketkey','ticketid']].drop_duplicates(), on='ticketkey', how='left')

events.to_csv('events.csv', index=0)

productA = pd.melt(events[['ticketid','Softdrink','Beer', 'Hotdog', 'Book']], 'ticketid').dropna(how='any')[['ticketid','value']].rename(columns={'value':'product'})

productB = []
for tkt in seatsdf['ticketid'].unique():
    if tkt in productA['ticketid'].unique():
        continue
    if random.random() > 0.3:
        productB.append({'ticketid':tkt,'product':'Softdrink'})
    if random.random() > 0.6:
        productB.append({'ticketid':tkt,'product':'Beer'})
    if random.random() > 0.4:
        productB.append({'ticketid':tkt,'product':'Hotdog'})
    if random.random() > 0.7:
        productB.append({'ticketid':tkt,'product':'Book'})

productdf = pd.DataFrame(productB)
productdf = pd.concat([productdf, productA])

productdf.to_csv('sideproduct.csv', index=0)









