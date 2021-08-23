load csv with headers from 'https://github.com/rel8edto/PublicDatasets/raw/main/Football/seat.csv' as line with distinct line.Gate as gatename merge (g:Gate {name:gatename});
// create constraint on (g:Gate) assert g.name is unique;
load csv with headers from 'https://github.com/rel8edto/PublicDatasets/raw/main/Football/seat.csv' as line with line.SeatsID as seatid, line.Price as price, line.Seat as seatname merge (s:Seat {seatid:seatid, price:price,  name:seatname});
// create constraint on (s:Seat) assert s.seatid is unique;
load csv with headers from 'https://github.com/rel8edto/PublicDatasets/raw/main/Football/seat.csv' as line with line.Section as section merge (sc:Section {name:section});
// create constraint on (sc:Section) assert sc.name is unique;

load csv with headers from 'https://github.com/rel8edto/PublicDatasets/raw/main/Football/seat.csv' as line match (s:Seat), (g:Gate) where s.seatid = line.SeatsID and g.name = line.Gate merge (s)-[:LOCATED_IN]->(g);

load csv with headers from 'https://github.com/rel8edto/PublicDatasets/raw/main/Football/seat.csv' as line match (s:Seat), (sc:Section) where s.seatid = line.SeatsID and sc.name = line.Section merge (s)-[:LOCATED_IN]->(sc);

load csv with headers from 'https://github.com/rel8edto/PublicDatasets/raw/main/Football/ticket.csv' as line with distinct line.ticketid as ticketid, line.date as dt,line.Month as month merge (t:Ticket {ticketID:ticketid, date:dt, month:month});
// create constraint on (t:Ticket) assert t.ticketID is unique;

load csv with headers from 'https://github.com/rel8edto/PublicDatasets/raw/main/Football/ticket.csv' as line match (t:Ticket) ,(s:Seat) where t.ticketID = line.ticketid and s.name = line.seat merge (t)-[:BOOKED]->(s); 

load csv with headers from 'https://github.com/rel8edto/PublicDatasets/raw/main/Football/sideproduct.csv' as line with distinct line.product as product merge (p:Product {name:product});
// create constraint on (p:Product) assert p.name is unique;
load csv with headers from 'https://github.com/rel8edto/PublicDatasets/raw/main/Football/sideproduct.csv' as line match(t:Ticket), (p:Product) where  t.ticketID = line.ticketid and p.name = line.product merge (t)-[:PURCHASED]->(p);
load csv with headers from 'https://github.com/rel8edto/PublicDatasets/raw/main/Football/events.csv' as line merge (e:Event {evtID:line.EvtID, evtType:line.Type});
load csv with headers from 'https://github.com/rel8edto/PublicDatasets/raw/main/Football/events.csv' as line with distinct line.SecurityGuardTeam as team merge (s:SecurityGuardTeam {team:team});
// create constraint on (s:SecurityGuardTeam) assert s.team is unique;
load csv with headers from 'https://github.com/rel8edto/PublicDatasets/raw/main/Football/events.csv' as line match (s:SecurityGuardTeam),(e:Event) where s.team = line.SecurityGuardTeam and e.evtID = line.EvtID merge (s)-[:DETECTED]->(e);
load csv with headers from 'https://github.com/rel8edto/PublicDatasets/raw/main/Football/events.csv' as line match (t:Ticket),(e:Event) where t.ticketID = line.ticketid and e.evtID = line.EvtID merge (t)-[:COMMITED]->(e);

load csv with headers from 'https://github.com/rel8edto/PublicDatasets/raw/main/Football/person.csv' as line  merge (p:Person {name:line.Name, age:line.Age});


load csv with headers from 'https://github.com/rel8edto/PublicDatasets/raw/main/Football/ticket.csv' as line match  (p:Person), (t:Ticket) where p.name = line.name and t.ticketID = line.ticketid merge (p)-[:ORDERED]->(t);

match (e:Event)-[r:COMMITED]-(t:Ticket) set t:Marked;
match (t:Ticket) where t.date in ['26-Jan','27-Jan','28-Jan','29-Jan','30-Jan','31-Jan'] detach delete t;

# product map
match (t:Ticket) where t.date in ['26-Jan','27-Jan','28-Jan','29-Jan','30-Jan','31-Jan'] detach delete t;

# person risk
match (t:Ticket)--(p:Person) optional match (t)--(e:Event)  with  distinct p.name as name, count(e) as events, count(t) as tickets with *, toFloat(events)/tickets as risk return * order by risk desc;

# product risk
match (t:Ticket)--(p:Product) optional match (t)--(e:Event)  with  distinct p.name as name, count(e) as events, count(t) as tickets with *, toFloat(events)/tickets as risk return * order by risk desc;

# Seat risk
match (t:Ticket)--(s:Seat) optional match (t)--(e:Event)  with  distinct s.name as name, count(e) as events, count(t) as tickets with *, toFloat(events)/tickets as risk return * order by risk desc;

# Gate risk
