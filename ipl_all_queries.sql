-- Player TABLE

SELECT * 
FROM Player_Match
					
-- Total Avg runs per ball by match
SELECT innings_no,sum(runs_scored) as Total,round(avg(runs_scored),2) as Average_per_ball
FROM Batsman_Scored
group by innings_no
					
-- Top 10 Matches for Six's hit
SELECT match_id, count(runs_scored) as six from batsman_scored 
where runs_scored= 6
group by match_id
order by six desc limit 10

-- Player Names along with their batting preference
select t_one.player_name,
t_two.player_id,
t_three.batting_hand
from player t_one
join player_match t_two on t_one.player_id = t_two.player_id
join batting_style t_three on t_one.batting_hand = t_three.batting_id

-- Player Name, primary role and batting preference
select * from (
select pm.player_id,
pl.player_name,
count(distinct pm.match_id) as Count_of_Matches,
ro.role_desc as Role_description,
bs.batting_hand as Batting_Style
from player_match pm
join player pl on pm.player_id=pl.player_id
join rolee ro on pm.role_id=ro.role_id
join batting_style bs on pl.batting_hand=bs.batting_id
group by pm.player_id) a
order by a.count_of_matches desc


-- Top Performing Batsmen -> 50's and 100's scored by Player
select 
b.striker,
b.player_name,
sum(b.fifties) as fifties,
sum(b.hundreds) as hundreds from (
select *, 
(case when a.runs >= 50 then 1 else 0 end) as fifties,
(case when a.runs >= 100 then 1 else 0 end) as hundreds from (
select striker,
bs.match_id,
player_name,
byb.innings_no, 
sum(runs_scored) as runs 
from ball_by_ball byb
join batsman_scored bs on byb.match_id=bs.match_id and byb.over_id=bs.over_id and byb.ball_id=bs.ball_id and byb.innings_no= bs.innings_no
join player pl on byb.striker=pl.player_id
group by bs.match_id,
player_name
order by byb.innings_no
) a
order by a.runs desc
)b
group by b.player_name
order by fifties desc , hundreds desc

-- Top Bowling Figures: Bowlers and Highest Wickets

select
a.match_id,
a.bowler,
max(a.wickets) "Max Wickets - 1 Match",
a.runs_given,
max(a.wickets) ||'-'|| a.runs_given AS Best_Bowling_figure

from (
select
wt.match_id,
wt.bowler,
wt.wickets,
rt.runs_given

from
(
select byb.match_id,bowler, count(byb.ball_id) as wickets from 
ball_by_ball byb
join wicket_taken wkt on byb.match_id=wkt.match_id and byb.over_id=wkt.over_id and byb.ball_id=wkt.ball_id and byb.innings_no=wkt.innings_no
group by byb.match_id,bowler
) wt

join 
(select byb.match_id,bowler, sum(runs_scored) as runs_given from 
ball_by_ball byb
join batsman_scored bs on byb.match_id=bs.match_id and byb.over_id=bs.over_id and byb.ball_id=bs.ball_id and byb.innings_no=bs.innings_no
group by bs.match_id,bowler
) rt on rt.match_id=wt.match_id ) a
group by a.bowler
order by a.wickets desc limit 10

-- Bowling Statistics

select
c.bowler,
c.player_name,
c.wickets,
c.economy_rate,
c.bowler_strike_rate,
best_bowling_table.best_bowling_figure
from (
select 
a.bowler,
a.player_name,
a.wickets,
balls_table.balls_bowled as Balls_bowled,
economy_table.runs_given as runs_given,
6*(round(round(economy_table.runs_given,2)/round(balls_table.balls_bowled,2),2)) as economy_rate,
round(round(balls_table.balls_bowled,2)/round(a.wickets,2),2) as bowler_strike_rate
from (
select bowler,pl.player_name as player_name,count(out_name) as wickets from wicket_taken wkt
join out_type ot on wkt.kind_out=ot.out_id
join ball_by_ball byb on byb.match_id=wkt.match_id and byb.over_id=wkt.over_id and byb.ball_id=wkt.ball_id and byb.innings_no=wkt.innings_no
join player pl on byb.bowler=pl.player_id
group by player_name
) a join (select bowler,count(ball_id) as Balls_Bowled from ball_by_ball
group by bowler) balls_table on a.bowler=balls_table.bowler join (select * from (
select
a.bowler,
count(distinct a.match_id) as Innings_Bowled,
a.bowler_name,
a.role_desc,
sum(a.runs) as runs_given
from
(
select
byb.match_id as match_id,
byb.over_id as over_id,
byb.ball_id as ball_id,
byb.innings_no as innings_no,
byb.team_batting as team_batting,
striker,
non_striker,
bowler,
role_desc,
bs.batting_hand as batting_hand,
pl.player_name as bowler_name,
runs_scored as Runs from ball_by_ball byb
join batsman_scored bsco on byb.ball_id= bsco.ball_id and byb.match_id= bsco.match_id and byb.over_id= bsco.over_id and byb.innings_no= bsco.innings_no
join player_match pm on bsco.match_id = pm.match_id
join player pl on byb.bowler= pl.player_id
join rolee re on pm.role_id=re.role_id
join batting_Style bs on pl.batting_hand=bs.batting_id
group by
striker,
byb.match_id,
byb.over_id,
byb.ball_id,
bsco.innings_no
order by bsco.innings_no asc
)a
group by a.bowler_name
order by a.bowler
) b
order by b.runs_given desc) economy_table on a.bowler=economy_table.bowler
order by a.wickets desc) c join (select
a.match_id,
a.bowler,
max(a.wickets),
a.runs_given,
max(a.wickets) ||'-'|| a.runs_given AS Best_Bowling_figure

from (
select
wt.match_id,
wt.bowler,
wt.wickets,
rt.runs_given

from
(
select byb.match_id,bowler, count(byb.ball_id) as wickets from 
ball_by_ball byb
join wicket_taken wkt on byb.match_id=wkt.match_id and byb.over_id=wkt.over_id and byb.ball_id=wkt.ball_id and byb.innings_no=wkt.innings_no
group by byb.match_id,bowler
) wt

join 
(select byb.match_id,bowler, sum(runs_scored) as runs_given from 
ball_by_ball byb
join batsman_scored bs on byb.match_id=bs.match_id and byb.over_id=bs.over_id and byb.ball_id=bs.ball_id and byb.innings_no=bs.innings_no
group by bs.match_id,bowler
) rt on rt.match_id=wt.match_id ) a
group by a.bowler
order by a.wickets desc) best_bowling_table on c.bowler=best_bowling_table.bowler


-- Top Batsmen 
select * from (
select
a.striker,
count(distinct a.match_id) as Batting_innings,
a.striker_name,
a.role_desc,
a.batting_hand,
sum(a.runs) as runs
from
(
select
byb.match_id as match_id,
byb.over_id as over_id,
byb.ball_id as ball_id,
byb.innings_no as innings_no,
byb.team_batting as team_batting,
striker,
non_striker,
bowler,
role_desc,
bs.batting_hand as batting_hand,
pl.player_name as striker_name,
runs_scored as Runs from ball_by_ball byb
join batsman_scored bsco on byb.ball_id= bsco.ball_id and byb.match_id= bsco.match_id and byb.over_id= bsco.over_id and byb.innings_no= bsco.innings_no
join player_match pm on bsco.match_id = pm.match_id
join player pl on byb.striker= pl.player_id
join rolee re on pm.role_id=re.role_id
join batting_Style bs on pl.batting_hand=bs.batting_id
group by
striker,
byb.match_id,
byb.over_id,
byb.ball_id
order by bsco.innings_no asc
)a
group by a.striker_name
order by a.striker
) b
order by b.runs desc


-- Average Runs scored by Teams During Different Match Phases
select 
b.team_batting_name,
b.Matches_played,
max(b.power_play) as runs_power_play,
max(b.middle_overs) as runs_middle_overs,
max(b.death_overs) as runs_death_overs
from
(
select
t.Team_batting_name,
count(distinct t.match_id) as Matches_played,
case when t.Match_Phase='Power Play' then round(round(sum(t.runs_scored),2)/round(count(distinct t.match_id),2),2) else 0 end as Power_Play,
case when t.Match_Phase='Middle Overs' then round(round(sum(t.runs_scored),2)/round(count(distinct t.match_id),2),2) else 0 end as Middle_Overs,
case when t.Match_Phase='Death Overs' then round(round(sum(t.runs_scored),2)/round(count(distinct t.match_id),2),2) else 0 end as Death_Overs
from (
select
byb.match_id,
byb.over_id,
(case when byb.over_id between 0 and 6 then 'Power Play'
     when byb.over_id between 7 and 15 then 'Middle Overs'
     when byb.over_id between 16 and 20 then 'Death Overs' else 0 end) as Match_Phase,
byb.ball_id,
byb.innings_no,
t.team_name as Team_batting_name,
bs.runs_scored as runs_scored
from ball_by_ball byb join
team t on byb.team_batting=t.team_id
join batsman_scored bs on bs.match_id=byb.match_id and bs.over_id=byb.over_id and bs.ball_id=byb.ball_id and bs.innings_no=byb.innings_no
group by byb.match_id,
byb.over_id,
byb.ball_id,
byb.innings_no
order by byb.innings_no asc ) t

group by t.team_batting_name,t.match_phase ) b
group by b.team_batting_name

-- Most Successful Teams

select 
t.team_name,
w.match_won,
p.match_played,
100*(round(round(w.match_won,2)/round(p.match_played,2),4)) as Win_percent

from (
select team_1,count(match_winner) as match_won from match
group by team_1) w join (select team.team_id,count(distinct match_id) as match_played from team join
player_match on player_match.team_id=team.team_id
group by team.team_id) p on w.team_1=p.team_id join team t on p.team_id=t.team_id
order by Win_percent desc


-- Complete Statistics for all players

select 
s.striker,
s.striker_name,
s.role_desc,
s.batting_hand
,bowling_style_table.bowling_skill,
s.runs,
s.matches,
s.dismissals,
round(round(s.runs,2)/round(s.dismissals,2),2) as batt_avg,
s.Highest_score,
s.thirties, 
s.fifties,
s.hundreds,
s.balls_faced_career,
s.strike_rate,
s.wickets_taken,
s.economy_rate,
s.strike_rate,
s.best_bowling_figure
 from (
select
f.striker,
f.striker_name,
f.role_desc,
f.batting_hand,
f.runs,
f.matches,
f.dismissals,
round(round(f.runs,2)/round(f.dismissals,2),2) as batt_avg,
f.Highest_score,
f.thirties, 
f.fifties,
f.hundreds,
f.balls_faced_career,
f.strike_rate,
f.wickets_taken,
bowler_table.economy_rate as economy_rate,
bowler_table.bowler_strike_rate as strike_rate,
bowler_table.best_bowling_figure as best_bowling_figure

from (
select 
g.striker,
g.striker_name,
g.role_desc,
g.batting_hand,
g.runs,
g.matches,
g.dismissals,
round(round(g.runs,2)/round(g.dismissals,2),2) as batt_avg,
g.Highest_score,
g.thirties, 
g.fifties,
g.hundreds,
g.balls_faced_career,
g.strike_rate,
bowlers_table.wickets as wickets_taken

from (
select
f.striker,
f.striker_name,
f.role_desc,
f.batting_hand,
f.runs,
f.matches,
dissmissals_table.dismissals as dismissals,
round(round(f.runs,2)/round(dissmissals_table.dismissals,2),2) as batt_avg,
f.Highest_score,
f.thirties, 
f.fifties,
f.hundreds,
f.balls_faced_career,
f.strike_rate
from (
select 
e.striker,
e.striker_name,
e.role_desc,
e.batting_hand,
e.runs,
e.matches,
round(round(e.runs,2)/round(e.matches,2),2) as batt_avg,
e.Highest_score,
e.thirties, 
e.fifties,
e.hundreds,
sum(ball_face_by_batsman_per_match) as balls_faced_career,
100*(round(round(e.runs,4)/round(sum(ball_face_by_batsman_per_match),4),4)) as strike_rate
from (
select
d.striker,
d.striker_name,
d.role_desc,
d.batting_hand,
d.runs,
d.matches,
100*round(round(d.runs,2)/round(d.matches,2),2) as batt_avg,
max(d.max_individual_score_per_match) as Highest_score,
d.thirties, 
d.fifties,
d.hundreds

from
(select c.striker,
c.striker_name,
c.role_desc,
c.batting_hand,
c.runs,
c.matches,
c.max_individual_score_per_match,
fifties_hundreds_table.thirties, 
fifties_hundreds_table.fifties,
fifties_hundreds_table.hundreds
from (
select 
runs_table.striker,
runs_table.striker_name,
runs_table.matches,
runs_table.role_desc,
runs_table.batting_hand,
runs_table.runs,
highest_score.runs as max_individual_score_per_match from
(
select * from 
(
select
a.striker,
count(distinct a.match_id) as Matches,
a.striker_name,
a.role_desc,
a.batting_hand,
sum(a.runs) as runs
from
(
select
byb.match_id as match_id,
byb.over_id as over_id,
byb.ball_id as ball_id,
byb.innings_no as innings_no,
byb.team_batting as team_batting,
striker,
non_striker,
bowler,
role_desc,
bs.batting_hand as batting_hand,
pl.player_name as striker_name,
runs_scored as Runs from ball_by_ball byb
join batsman_scored bsco on byb.ball_id= bsco.ball_id and byb.match_id= bsco.match_id and byb.over_id= bsco.over_id and byb.innings_no= bsco.innings_no
join player_match pm on bsco.match_id = pm.match_id
join player pl on byb.striker= pl.player_id
join rolee re on pm.role_id=re.role_id
join batting_Style bs on pl.batting_hand=bs.batting_id
group by
striker,
byb.match_id,
byb.over_id,
byb.ball_id
order by bsco.innings_no asc
)a
group by a.striker_name
order by a.striker
)b
group by b.striker_name,b.striker,b.matches
order by b.runs desc ) runs_table join (select * from (
select striker,
bs.match_id,
player_name,
byb.innings_no, 
sum(runs_scored) as runs 
from ball_by_ball byb
join batsman_scored bs on byb.match_id=bs.match_id and byb.over_id=bs.over_id and byb.ball_id=bs.ball_id and byb.innings_no= bs.innings_no
join player pl on byb.striker=pl.player_id
group by bs.match_id,
player_name
order by byb.innings_no
) a
order by a.runs desc) highest_score on runs_table.striker=highest_score.striker and runs_table.striker=highest_score.striker
)c
join (select 
b.striker,
b.player_name,
sum(b.thirties) as thirties,
sum(b.fifties) as fifties,
sum(b.hundreds) as hundreds from (
select *,
(case when a.runs >= 30 then 1 else 0 end) as thirties,
(case when a.runs >= 50 then 1 else 0 end) as fifties,
(case when a.runs >= 100 then 1 else 0 end) as hundreds from (
select striker,
bs.match_id,
player_name,
byb.innings_no, 
sum(runs_scored) as runs 
from ball_by_ball byb
join batsman_scored bs on byb.match_id=bs.match_id and byb.over_id=bs.over_id and byb.ball_id=bs.ball_id and byb.innings_no= bs.innings_no
join player pl on byb.striker=pl.player_id
group by bs.match_id,
player_name
order by byb.innings_no
) a
order by a.runs desc
)b
group by b.player_name
order by b.striker) fifties_hundreds_table on c.striker=fifties_hundreds_table.striker
)d
group by d.striker_name
order by d.matches desc
)e join (select match_id,striker,count(ball_id) as ball_face_by_batsman_per_match from ball_by_ball
group by striker,match_id) ball_faced_table on e.striker=ball_faced_table.striker
group by e.striker ) f join (select * from (
select player_out,count(out_name) as dismissals from wicket_taken wkt
join out_type ot on wkt.kind_out=ot.out_id
group by player_out
) a) dissmissals_table on f.striker=dissmissals_table.player_out
group by f.striker
) g join (select * from (
select bowler,pl.player_name as player_name,count(out_name) as wickets from wicket_taken wkt
join out_type ot on wkt.kind_out=ot.out_id
join ball_by_ball byb on byb.match_id=wkt.match_id and byb.over_id=wkt.over_id and byb.ball_id=wkt.ball_id and byb.innings_no=wkt.innings_no
join player pl on byb.bowler=pl.player_id
group by player_name
) a
order by a.wickets desc) bowlers_table on g.striker=bowlers_table.bowler
order by g.striker) f 
join (select
c.bowler,
c.player_name,
c.wickets,
c.economy_rate,
c.bowler_strike_rate,
best_bowling_table.best_bowling_figure
from (
select 
a.bowler,
a.player_name,
a.wickets,
balls_table.balls_bowled as Balls_bowled,
economy_table.runs_given as runs_given,
6*(round(round(economy_table.runs_given,2)/round(balls_table.balls_bowled,2),2)) as economy_rate,
round(round(balls_table.balls_bowled,2)/round(a.wickets,2),2) as bowler_strike_rate
from (
select bowler,pl.player_name as player_name,count(out_name) as wickets from wicket_taken wkt
join out_type ot on wkt.kind_out=ot.out_id
join ball_by_ball byb on byb.match_id=wkt.match_id and byb.over_id=wkt.over_id and byb.ball_id=wkt.ball_id and byb.innings_no=wkt.innings_no
join player pl on byb.bowler=pl.player_id
group by player_name
) a join (select bowler,count(ball_id) as Balls_Bowled from ball_by_ball
group by bowler) balls_table on a.bowler=balls_table.bowler join (select * from (
select
a.bowler,
count(distinct a.match_id) as Innings_Bowled,
a.bowler_name,
a.role_desc,
sum(a.runs) as runs_given
from
(
select
byb.match_id as match_id,
byb.over_id as over_id,
byb.ball_id as ball_id,
byb.innings_no as innings_no,
byb.team_batting as team_batting,
striker,
non_striker,
bowler,
role_desc,
bs.batting_hand as batting_hand,
pl.player_name as bowler_name,
runs_scored as Runs from ball_by_ball byb
join batsman_scored bsco on byb.ball_id= bsco.ball_id and byb.match_id= bsco.match_id and byb.over_id= bsco.over_id and byb.innings_no= bsco.innings_no
join player_match pm on bsco.match_id = pm.match_id
join player pl on byb.bowler= pl.player_id
join rolee re on pm.role_id=re.role_id
join batting_Style bs on pl.batting_hand=bs.batting_id
group by
striker,
byb.match_id,
byb.over_id,
byb.ball_id,
bsco.innings_no
order by bsco.innings_no asc
)a
group by a.bowler_name
order by a.bowler
) b
order by b.runs_given desc) economy_table on a.bowler=economy_table.bowler
order by a.wickets desc) c join (select
a.match_id,
a.bowler,
max(a.wickets),
a.runs_given,
max(a.wickets) ||'-'|| a.runs_given AS Best_Bowling_figure

from (
select
wt.match_id,
wt.bowler,
wt.wickets,
rt.runs_given

from
(
select byb.match_id,bowler, count(byb.ball_id) as wickets from 
ball_by_ball byb
join wicket_taken wkt on byb.match_id=wkt.match_id and byb.over_id=wkt.over_id and byb.ball_id=wkt.ball_id and byb.innings_no=wkt.innings_no
group by byb.match_id,bowler
) wt

join 
(select byb.match_id,bowler, sum(runs_scored) as runs_given from 
ball_by_ball byb
join batsman_scored bs on byb.match_id=bs.match_id and byb.over_id=bs.over_id and byb.ball_id=bs.ball_id and byb.innings_no=bs.innings_no
group by bs.match_id,bowler
) rt on rt.match_id=wt.match_id ) a
group by a.bowler
order by a.wickets desc) best_bowling_table on c.bowler=best_bowling_table.bowler) bowler_table on f.striker_name=bowler_table.player_name
) s join (select player_name,bl.bowling_skill from player p
join bowling_style bl on p.bowling_skill=bl.bowling_id) bowling_style_table on s.striker_name=bowling_style_table.player_name

