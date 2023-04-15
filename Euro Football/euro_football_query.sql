-- What are the different leagues available and where are they from?
select c.id,
l.name as leagueName,
c.name as countryName
from league l
join country c on c.id=l.id
group by c.name,l.name
order by c.name


-- Teams in different leagues
select 
country_league_table.countryname,
league_teams_table.LeagueName,
league_teams_table.Teamintheleague from (
select
l.name as LeagueName,
t.team_long_name as TeamInTheLeague
from league l 
join match m on l.country_id=m.country_id
join team t on  m.home_team_api_id=t.team_api_id
group by l.name,t.team_long_name) league_teams_table join (select c.id,
l.name as leagueName,
c.name as countryName
from league l
join country c on c.id=l.id
group by c.name,l.name) country_league_table on league_teams_table.leaguename=country_league_table.leaguename


-- Player information
select 
pa.player_api_id as Player_api_id,
p.player_name as Player_Name, 
strftime('%d-%m-%Y',p.birthday) as DOB,
max(p.height) as Height,
max(p.weight) as Weight,
max(pa.overall_rating) as Rating,
max(pa.potential) as Potenital,
pa.preferred_foot as Preferred_Foot,
pa.attacking_work_rate as Attacking_Work_Rate,
pa.defensive_work_rate as Defensive_Work_Rate
from player p 
join player_attributes pa on p.player_api_id=pa.player_api_id and p.player_fifa_api_id=pa.player_fifa_api_id
group by p.player_name


-- Goals scored by home team vs away team Season on Season
select
at_table.season,
at_table.leaguename,
ht_table.HT_goals as Home_Team_Goals,
at_table.AT_goals as Away_Team_Goals
from (
select 
b.season,
b.leaguename,
sum(home_team_goal) as HT_goals
from (
select
a.match_api_id,
a.countryname,
a.leaguename,
ht.team_long_name as Home_Team_Long_Name,
ht.team_short_name as Home_Team_Short_Name,
at.team_long_name as Away_Team_Long_Name,
at.team_short_name as Away_Team_Short_Name,
a.season,
strftime('%d-%m-%Y',a.date) as Date,
a.stage,
a.home_team_goal,
a.away_team_goal,
case 
when a.home_team_goal - a.away_team_goal > 0 then ht.team_short_name
when a.home_team_goal - a.away_team_goal < 0 then at.team_short_name else 'Tie' end as Match_Winner
from (
select 
match_api_id,
country_team_league_table.countryname,
country_team_league_table.leaguename,
home_team_goal,
away_team_goal,
season,
date,
stage
from match m 
join team t on t.team_api_id=m.home_team_api_id or t.team_api_id=m.away_team_api_id
join (select 
country_league_table.countryname,
league_teams_table.LeagueName,
league_teams_table.Teamintheleague from (
select
l.name as LeagueName,
t.team_long_name as TeamInTheLeague
from league l 
join match m on l.country_id=m.country_id
join team t on  m.home_team_api_id=t.team_api_id
group by l.name,t.team_long_name) league_teams_table join (select c.id,
l.name as leagueName,
c.name as countryName
from league l
join country c on c.id=l.id
group by c.name,l.name) country_league_table on league_teams_table.leaguename=country_league_table.leaguename) country_team_league_table on t.team_long_name=country_team_league_table.teamintheleague
group by match_api_id ) a join (select  
match_api_id,
home_team_api_id,
team_long_name,
team_short_name
from match m
join team t on t.team_api_id=m.home_team_api_id
group by match_api_id) ht on a.match_api_id=ht.match_api_id 
join (select  
match_api_id,
away_team_api_id,
team_long_name,
team_short_name
from match m
join team t on t.team_api_id=m.away_team_api_id
group by match_api_id) at on a.match_api_id=at.match_api_id) b

group by b.season,b.leaguename ) ht_table join 
(select 
b.season,
b.leaguename,
sum(away_team_goal) as AT_goals
from (
select
a.match_api_id,
a.countryname,
a.leaguename,
ht.team_long_name as Home_Team_Long_Name,
ht.team_short_name as Home_Team_Short_Name,
at.team_long_name as Away_Team_Long_Name,
at.team_short_name as Away_Team_Short_Name,
a.season,
strftime('%d-%m-%Y',a.date) as Date,
a.stage,
a.home_team_goal,
a.away_team_goal,
case 
when a.home_team_goal - a.away_team_goal > 0 then ht.team_short_name
when a.home_team_goal - a.away_team_goal < 0 then at.team_short_name else 'Tie' end as Match_Winner
from (
select 
match_api_id,
country_team_league_table.countryname,
country_team_league_table.leaguename,
home_team_goal,
away_team_goal,
season,
date,
stage
from match m 
join team t on t.team_api_id=m.home_team_api_id or t.team_api_id=m.away_team_api_id
join (select 
country_league_table.countryname,
league_teams_table.LeagueName,
league_teams_table.Teamintheleague from (
select
l.name as LeagueName,
t.team_long_name as TeamInTheLeague
from league l 
join match m on l.country_id=m.country_id
join team t on  m.home_team_api_id=t.team_api_id
group by l.name,t.team_long_name) league_teams_table join (select c.id,
l.name as leagueName,
c.name as countryName
from league l
join country c on c.id=l.id
group by c.name,l.name) country_league_table on league_teams_table.leaguename=country_league_table.leaguename) country_team_league_table on t.team_long_name=country_team_league_table.teamintheleague
group by match_api_id ) a join (select  
match_api_id,
home_team_api_id,
team_long_name,
team_short_name
from match m
join team t on t.team_api_id=m.home_team_api_id
group by match_api_id) ht on a.match_api_id=ht.match_api_id 
join (select  
match_api_id,
away_team_api_id,
team_long_name,
team_short_name
from match m
join team t on t.team_api_id=m.away_team_api_id
group by match_api_id) at on a.match_api_id=at.match_api_id) b

group by b.season,b.leaguename) at_Table on ht_table.leaguename=at_table.leaguename and ht_table.season=at_table.season

-- Matches won each season
with cte as(
select 
a.season,a.match_winner,count(a.match_winner) as Number_of_Wins
from (
select
a.match_api_id,
a.countryname,
a.leaguename,
ht.team_long_name as Home_Team_Long_Name,
ht.team_short_name as Home_Team_Short_Name,
at.team_long_name as Away_Team_Long_Name,
at.team_short_name as Away_Team_Short_Name,
a.season,
strftime('%d-%m-%Y',a.date) as Date,
a.stage,
a.home_team_goal,
a.away_team_goal,
case 
when a.home_team_goal - a.away_team_goal > 0 then ht.team_long_name
when a.home_team_goal - a.away_team_goal < 0 then at.team_long_name else 'Tie' end as Match_Winner
from (
select 
match_api_id,
country_team_league_table.countryname,
country_team_league_table.leaguename,
home_team_goal,
away_team_goal,
season,
date,
stage
from match m 
join team t on t.team_api_id=m.home_team_api_id or t.team_api_id=m.away_team_api_id
join (select 
country_league_table.countryname,
league_teams_table.LeagueName,
league_teams_table.Teamintheleague from (
select
l.name as LeagueName,
t.team_long_name as TeamInTheLeague
from league l 
join match m on l.country_id=m.country_id
join team t on  m.home_team_api_id=t.team_api_id
group by l.name,t.team_long_name) league_teams_table join (select c.id,
l.name as leagueName,
c.name as countryName
from league l
join country c on c.id=l.id
group by c.name,l.name) country_league_table on league_teams_table.leaguename=country_league_table.leaguename) country_team_league_table on t.team_long_name=country_team_league_table.teamintheleague
group by match_api_id ) a join (select  
match_api_id,
home_team_api_id,
team_long_name,
team_short_name
from match m
join team t on t.team_api_id=m.home_team_api_id
group by match_api_id) ht on a.match_api_id=ht.match_api_id 
join (select  
match_api_id,
away_team_api_id,
team_long_name,
team_short_name
from match m
join team t on t.team_api_id=m.away_team_api_id
group by match_api_id) at on a.match_api_id=at.match_api_id) a
group by a.season,a.match_winner
order by Number_of_Wins desc
)

select * from cte where match_winner not in ("Tie")


-- Most Successfull Teams of all time
select * from (
select 
a.team,
sum(a.total_games) as "Total Games Played",
sum(a.wins) as "Total Wins",
100*round(round(a.wins,2)/round(a.total_games,2),4) as Win_Percentage from
(select 
total_matches.season,
total_matches.team,
Total_games_played_for_the_season as total_games,
win_matches.number_of_wins as wins
from (
select 
ht.season as Season,
ht.team as Team ,
ht.home_games_played,
at.away_games_played,
ht.home_games_played + at.away_games_played as Total_games_played_for_the_season
from (
select b.season as Season,b.home_team_long_name as Team ,count(b.match_api_id) as home_games_played from (
select
a.match_api_id,
a.countryname,
a.leaguename,
ht.team_long_name as Home_Team_Long_Name,
ht.team_short_name as Home_Team_Short_Name,
at.team_long_name as Away_Team_Long_Name,
at.team_short_name as Away_Team_Short_Name,
a.season,
strftime('%d-%m-%Y',a.date) as Date,
a.stage,
a.home_team_goal,
a.away_team_goal,
case 
when a.home_team_goal - a.away_team_goal > 0 then ht.team_short_name
when a.home_team_goal - a.away_team_goal < 0 then at.team_short_name else 'Tie' end as Match_Winner
from (
select 
match_api_id,
country_team_league_table.countryname,
country_team_league_table.leaguename,
home_team_goal,
away_team_goal,
season,
date,
stage
from match m 
join team t on t.team_api_id=m.home_team_api_id or t.team_api_id=m.away_team_api_id
join (select 
country_league_table.countryname,
league_teams_table.LeagueName,
league_teams_table.Teamintheleague from (
select
l.name as LeagueName,
t.team_long_name as TeamInTheLeague
from league l 
join match m on l.country_id=m.country_id
join team t on  m.home_team_api_id=t.team_api_id
group by l.name,t.team_long_name) league_teams_table join (select c.id,
l.name as leagueName,
c.name as countryName
from league l
join country c on c.id=l.id
group by c.name,l.name) country_league_table on league_teams_table.leaguename=country_league_table.leaguename) country_team_league_table on t.team_long_name=country_team_league_table.teamintheleague
group by match_api_id ) a join (select  
match_api_id,
home_team_api_id,
team_long_name,
team_short_name
from match m
join team t on t.team_api_id=m.home_team_api_id
group by match_api_id) ht on a.match_api_id=ht.match_api_id 
join (select  
match_api_id,
away_team_api_id,
team_long_name,
team_short_name
from match m
join team t on t.team_api_id=m.away_team_api_id
group by match_api_id) at on a.match_api_id=at.match_api_id ) b
group by b.season,b.home_team_long_name ) ht
join (select b.season as Season,b.away_team_long_name as team,count(b.match_api_id) as away_games_played from (
select
a.match_api_id,
a.countryname,
a.leaguename,
ht.team_long_name as Home_Team_Long_Name,
ht.team_short_name as Home_Team_Short_Name,
at.team_long_name as Away_Team_Long_Name,
at.team_short_name as Away_Team_Short_Name,
a.season,
strftime('%d-%m-%Y',a.date) as Date,
a.stage,
a.home_team_goal,
a.away_team_goal,
case 
when a.home_team_goal - a.away_team_goal > 0 then ht.team_short_name
when a.home_team_goal - a.away_team_goal < 0 then at.team_short_name else 'Tie' end as Match_Winner
from (
select 
match_api_id,
country_team_league_table.countryname,
country_team_league_table.leaguename,
home_team_goal,
away_team_goal,
season,
date,
stage
from match m 
join team t on t.team_api_id=m.home_team_api_id or t.team_api_id=m.away_team_api_id
join (select 
country_league_table.countryname,
league_teams_table.LeagueName,
league_teams_table.Teamintheleague from (
select
l.name as LeagueName,
t.team_long_name as TeamInTheLeague
from league l 
join match m on l.country_id=m.country_id
join team t on  m.home_team_api_id=t.team_api_id
group by l.name,t.team_long_name) league_teams_table join (select c.id,
l.name as leagueName,
c.name as countryName
from league l
join country c on c.id=l.id
group by c.name,l.name) country_league_table on league_teams_table.leaguename=country_league_table.leaguename) country_team_league_table on t.team_long_name=country_team_league_table.teamintheleague
group by match_api_id ) a join (select  
match_api_id,
home_team_api_id,
team_long_name,
team_short_name
from match m
join team t on t.team_api_id=m.home_team_api_id
group by match_api_id) ht on a.match_api_id=ht.match_api_id 
join (select  
match_api_id,
away_team_api_id,
team_long_name,
team_short_name
from match m
join team t on t.team_api_id=m.away_team_api_id
group by match_api_id) at on a.match_api_id=at.match_api_id ) b
group by b.season,b.home_team_long_name) at on ht.season=at.season and ht.team=at.team ) total_matches join 
(select 
a.season,a.match_winner,count(a.match_winner) as Number_of_Wins
from (
select
a.match_api_id,
a.countryname,
a.leaguename,
ht.team_long_name as Home_Team_Long_Name,
ht.team_short_name as Home_Team_Short_Name,
at.team_long_name as Away_Team_Long_Name,
at.team_short_name as Away_Team_Short_Name,
a.season,
strftime('%d-%m-%Y',a.date) as Date,
a.stage,
a.home_team_goal,
a.away_team_goal,
case 
when a.home_team_goal - a.away_team_goal > 0 then ht.team_long_name
when a.home_team_goal - a.away_team_goal < 0 then at.team_long_name else 'Tie' end as Match_Winner
from (
select 
match_api_id,
country_team_league_table.countryname,
country_team_league_table.leaguename,
home_team_goal,
away_team_goal,
season,
date,
stage
from match m 
join team t on t.team_api_id=m.home_team_api_id or t.team_api_id=m.away_team_api_id
join (select 
country_league_table.countryname,
league_teams_table.LeagueName,
league_teams_table.Teamintheleague from (
select
l.name as LeagueName,
t.team_long_name as TeamInTheLeague
from league l 
join match m on l.country_id=m.country_id
join team t on  m.home_team_api_id=t.team_api_id
group by l.name,t.team_long_name) league_teams_table join (select c.id,
l.name as leagueName,
c.name as countryName
from league l
join country c on c.id=l.id
group by c.name,l.name) country_league_table on league_teams_table.leaguename=country_league_table.leaguename) country_team_league_table on t.team_long_name=country_team_league_table.teamintheleague
group by match_api_id ) a join (select  
match_api_id,
home_team_api_id,
team_long_name,
team_short_name
from match m
join team t on t.team_api_id=m.home_team_api_id
group by match_api_id) ht on a.match_api_id=ht.match_api_id 
join (select  
match_api_id,
away_team_api_id,
team_long_name,
team_short_name
from match m
join team t on t.team_api_id=m.away_team_api_id
group by match_api_id) at on a.match_api_id=at.match_api_id) a
group by a.season,a.match_winner) win_matches on total_matches.team=win_matches.match_winner) a
group by a.team)b
group by b.team
order by b.win_percentage desc
