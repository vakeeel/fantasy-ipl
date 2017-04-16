require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'optparse' 
require 'colorize'

class FantasyInnings

	# RPS VS DD
	# OUR_TEAM = "F du Plessis, SV Samson, MA Agarwal, RR Pant, CH Morris, A Mishra, PJ Cummins, MS Dhoni, R Bhatia, DL Chahar, Imran Tahir"
	# OPPOSING_TEAM = "AM Rahane, A Tare, SW Billings, KK Nair, BA Stokes, CJ Anderson, A Zampa, Z Khan, S Nadeem, AB Dinda, RA Tripathi"
	# OUR_CAPTAIN = "Imran Tahir"
	# OPPONENT_CAPTAIN = "BA Stokes"
	# MATCH_URL = "http://www.espncricinfo.com/indian-premier-league-2017/engine/match/1082599.html"

	# KXIP VS RCB
	# OUR_TEAM = "SR Watson, GJ Maxwell, M Vohra, AB de Villiers, Mandeep Singh, TS Mills, DA Miller, MM Sharma, YS Chahal, T Natarajan, VR Aaron"
	# OPPOSING_TEAM = "Vishnu Vinod, HM Amla, KM Jadhav, P Negi, Iqbal Abdulla, B Stanlake, AR Patel, STR Binny, WP Saha, MP Stoinis, Sandeep Sharma"
	# OUR_CAPTAIN = "SR Watson"
	# OPPONENT_CAPTAIN = "AR Patel"
	# MATCH_URL = "http://www.espncricinfo.com/indian-premier-league-2017/engine/match/1082598.html"

	# MI VS KKR
	# OUR_TEAM = "JC Buttler, KA Pollard, MK Pandey, HH Pandya, YK Pathan, SA Yadav, SP Narine, Kuldeep Yadav, AS Rajpoot, TA Boult, JJ Bumrah"
	# OPPOSING_TEAM = "G Gambhir, RV Uthappa, CA Lynn, PA Patel, RG Sharma, KH Pandya, MJ McClenaghan, SL Malinga, CR Woakes, Harbhajan Singh, N Rana"
	# OUR_CAPTAIN = "Kuldeep Yadav"
	# OPPONENT_CAPTAIN = "SL Malinga"
	# MATCH_URL = "http://www.espncricinfo.com/indian-premier-league-2017/engine/match/1082597.html"

	# SRH VS GL
	# OUR_TEAM = "DA Warner, MC Henriques, JJ Roy, SK Raina, Yuvraj Singh, Rashid Khan, P Kumar, A Nehra, DJ Hooda, Basil Thampi, Tejas Baroka"
	# OPPOSING_TEAM = "B Kumar, BCJ Cutting, BB McCullum, DR Smith, AJ Finch, KD Karthik, S Dhawan, DS Kulkarni, Bipul Sharma, S Kaushik, NV Ojha"
	# OUR_CAPTAIN = "DA Warner"
	# OPPONENT_CAPTAIN = "B Kumar"
	# MATCH_URL = "http://www.espncricinfo.com/indian-premier-league-2017/engine/match/1082596.html"

	# RCB vs DD
	# OUR_TEAM = "CH Morris, CH Gayle, TS Mills, A Mishra, KM Jadhav, KK Nair, RR Pant, Iqbal Abdulla, Mandeep Singh, P Negi, Z Khan"
	# OPPOSING_TEAM = "SR Watson, CR Brathwaite, SW Billings, PJ Cummins, SV Samson, AP Tare, YS Chahal, B Stanlake, STR Binny, S Nadeem, Vishnu Vinod"
	# OUR_CAPTAIN = "CH Morris"
	# OPPONENT_CAPTAIN = "SR Watson"
	# MATCH_URL = "http://www.espncricinfo.com/indian-premier-league-2017/engine/match/1082595.html"


	# KXIB vs KKR
	# OUR_TEAM = "AR Patel, MP Stoinis, TA Boult, PP Chawla, RV Uthappa, GJ Maxwell, Sandeep Sharma, M Vohra, YK Pathan, SA Yadav, DA Miller"
	# OPPOSING_TEAM = "G Gambhir, HM Amla, WP Saha, MK Pandey, MM Sharma, I Sharma, VR Aaron, CR Woakes, C de Grandhomme, SP Narine, UT Yadav"
	# OUR_CAPTAIN = "AR Patel"
	# OPPONENT_CAPTAIN = "C de Grandhomme"
	# MATCH_URL = "http://www.espncricinfo.com/indian-premier-league-2017/engine/match/1082601.html?view=scorecard;wrappertype=none"

	# RCB vs MI
	# OUR_TEAM = "CH Gayle, PA Patel, JJ Bumrah, AB de Villiers, N Rana, Mandeep Singh, Harbhajan Singh, KA Pollard, TS Mills, TG Southee, S Badree"
	# OPPOSING_TEAM = "V Kohli, JC Buttler, RG Sharma, KH Pandya, KM Jadhav, STR Binny, P Negi, HH Pandya, YS Chahal, MJ McClenaghan, S Aravind"
	# OUR_CAPTAIN = "JJ Bumrah"
	# OPPONENT_CAPTAIN = "V Kohli"
	# MATCH_URL = "http://www.espncricinfo.com/indian-premier-league-2017/engine/match/1082602.html?view=scorecard;wrappertype=none"

	# GL vs RPS
	OUR_PLAYERS = "LH Ferguson, AJ Finch, RD Chahar, SN Thakur, KD Karthik, RA Jadeja, MK Tiwary, Ishan Kishan, P Kumar, SPD Smith, RA Tripathi"
	OPPOSING_PLAYERS = "MS Dhoni, DR Smith, BB McCullum, Ankit Sharma, SK Raina, Imran Tahir, Basil Thampi, BA Stokes, AJ Tye, AM Rahane, SB Jakati"
	OUR_CAPTAIN = "SPD Smith"
	OPPONENT_CAPTAIN = "Imran Tahir"
	MATCH_URL = "http://www.espncricinfo.com/indian-premier-league-2017/engine/match/1082603.html?view=scorecard;wrappertype=none"

	OUR_TEAM = OUR_PLAYERS.split(', ')
	OPPOSING_TEAM = OPPOSING_PLAYERS.split(', ')

	attr_accessor :our_team_batting_total, :opposing_team_batting_total, :our_team_fielding_total, :opposing_team_fielding_total, :player_batting_score, :player_fielding_score

	def initialize
		@our_team_batting_total = 0
		@opposing_team_batting_total = 0
		@our_team_fielding_total = 0
		@opposing_team_fielding_total = 0
		@player_batting_score = {}
		@player_fielding_score = {}
	end

	def get_dismissal_infos(trs)
		dismissal_infos = []

		trs.each do |tr|
			batsman_name_row = tr.css(".batsman-name").css("a")
			batsman_name = batsman_name_row.text
			runs = tr.css(".bold").text.to_i

			if (OUR_TEAM.include? batsman_name) 			
				if (OUR_CAPTAIN.include? batsman_name)
					@our_team_batting_total += 2*runs
					@player_batting_score[batsman_name] = 2*runs
				else	
					@our_team_batting_total += runs
					@player_batting_score[batsman_name] = runs
				end
			elsif (OPPOSING_TEAM.include? batsman_name)
				if (OPPONENT_CAPTAIN.include? batsman_name)
					@opposing_team_batting_total += 2*runs
					@player_batting_score[batsman_name] = 2*runs
				else	
					@opposing_team_batting_total += runs
					@player_batting_score[batsman_name] = runs
				end
			end

			dismissal_infos << tr.css(".dismissal-info").text.strip!
		end

		puts "Our team batting score: " + @our_team_batting_total.to_s
		puts "Opposing team batting score: " + @opposing_team_batting_total.to_s

		dismissal_infos
	end	

	def read_table_rows(trs)
	 	dismissal_infos = get_dismissal_infos(trs)

		dismissal_infos.each do |dismissal|
			if ((dismissal.include? 'st ') || (dismissal.include? 'c '))
				update_scores_for_catch_or_stumping(dismissal)			
				next;
			elsif (dismissal.include? 'run out')
				update_scores_for_runout(dismissal)
				next
			elsif ((dismissal.include? 'lbw ')	|| (dismissal.include? 'b '))
				update_scores_for_lbw_or_bowled(dismissal)
			end
		end

		puts "Our Team Fielding Score : " + @our_team_fielding_total.to_s
		puts "Opposing Team Fielding Score : " + @opposing_team_fielding_total.to_s

		return (@our_team_batting_total + @our_team_fielding_total), (@opposing_team_batting_total + @opposing_team_fielding_total)
	end

	def update_scores_for_catch_or_stumping(dismissal)
		fielder_name = dismissal.split(' ')[1]
		if (fielder_name == '&') 
			fielder_name = dismissal.split(' ').last
		end

		fielder_name.gsub!(/\W+/, '')  # Doing this for keepers where you have † symbol.
		opposing_team_fielder_name = OPPOSING_TEAM.find {|s| s.include? fielder_name}
		if (opposing_team_fielder_name != nil)
			@player_fielding_score[opposing_team_fielder_name] = 0 if @player_fielding_score[opposing_team_fielder_name].nil?
			if (OPPONENT_CAPTAIN.include? fielder_name)
				@opposing_team_fielding_total += 2*5
				@player_fielding_score[opposing_team_fielder_name] += 2*5
			else
				@opposing_team_fielding_total += 5
				@player_fielding_score[opposing_team_fielder_name] += 5
			end
		else
			our_team_fielder_name = OUR_TEAM.find {|s| s.include? fielder_name}
			@player_fielding_score[our_team_fielder_name] = 0 if @player_fielding_score[our_team_fielder_name].nil?
			if (OUR_TEAM.include? fielder_name)
				@our_team_fielding_total += 2*5
				@player_fielding_score[our_team_fielder_name] += 2*5
			else
				@our_team_fielding_total += 5
				@player_fielding_score[our_team_fielder_name] += 5
			end
		end

		bowler_name = dismissal.split(' b ')[1]
		if (bowler_name != nil)
			opposing_team_bowler_name = OPPOSING_TEAM.find {|s| s.include? bowler_name}
			if (opposing_team_bowler_name != nil)
				@player_fielding_score[opposing_team_bowler_name] = 0 if @player_fielding_score[opposing_team_bowler_name].nil?
				if (OPPONENT_CAPTAIN.include? bowler_name)
					@opposing_team_fielding_total += 2*20
					@player_fielding_score[opposing_team_bowler_name] += 2*20
				else
					@opposing_team_fielding_total += 20
					@player_fielding_score[opposing_team_bowler_name] += 20
				end
			else
				our_team_bowler_name = OUR_TEAM.find {|s| s.include? bowler_name}
				@player_fielding_score[our_team_bowler_name] = 0 if @player_fielding_score[our_team_bowler_name].nil?
				if (OUR_CAPTAIN.include? bowler_name)
					@our_team_fielding_total += 2*20
					@player_fielding_score[our_team_bowler_name] += 2*20
				else
					@our_team_fielding_total += 20
					@player_fielding_score[our_team_bowler_name] += 20
				end
			end
		end
	end

	def update_scores_for_lbw_or_bowled(dismissal)
		bowler_name = dismissal.split('b ')[1]
		if (OPPOSING_TEAM.any? {|s| s.include? bowler_name})
			@opposing_team_fielding_total += (OPPONENT_CAPTAIN.include? bowler_name) ? 2*25 : 25
		elsif (OUR_TEAM.any? {|s| s.include? bowler_name})
			@our_team_fielding_total += (OUR_CAPTAIN.include? bowler_name) ? 2*25 : 25
		end
	end

	def update_scores_for_runout(dismissal)
		fielder_name = dismissal.scan(/\((.*)\)/)[0][0]
		if(fielder_name.include? '/')
			fielder_names = fielder_name.split('/')
			fielder_names.each do |fn|
				if (OPPOSING_TEAM.any? {|s| s.include? fn})
					@opposing_team_fielding_total += (OPPONENT_CAPTAIN.include? fn) ? 2*5 : 5
				elsif (OUR_TEAM.any? {|s| s.include? fn})
					@our_team_fielding_total += (OUR_CAPTAIN.include? fn) ? 2*5 : 5
				end
			end
			return
		end

		if (OPPOSING_TEAM.any? {|s| s.include? fielder_name})
			@opposing_team_fielding_total += (OPPONENT_CAPTAIN.include? fielder_name) ? 2*5 : 5
		elsif (OUR_TEAM.any? {|s| s.include? fielder_name})
			@our_team_fielding_total += (OUR_CAPTAIN.include? fielder_name) ? 2*5 : 5
		end
	end

end

puts "OUR TEAM : " + FantasyInnings::OUR_PLAYERS
puts "OPPOSING TEAM : " + FantasyInnings::OPPOSING_PLAYERS
puts "*"*100

"http://www.espncricinfo.com/indian-premier-league-2017/engine/match/1082600.html?view=scorecard;wrappertype=none"
page = Nokogiri::HTML(open(FantasyInnings::MATCH_URL))
batting_tables = page.css(".full-scorecard-block").css(".batting-table")

puts "FIRST INNINGS: ".red
first_innings = FantasyInnings.new

first_innings_records = batting_tables[0].css("tr:not(.dismissal-detail)").css("tr:not(.tr-heading)").css("tr:not(.extra-wrap)").css("tr:not(.total-wrap)")
first_innings_our_score, first_innings_opponent_score = first_innings.read_table_rows(first_innings_records)

puts "First Innings Our Individual Scores : ".green
puts "Player Name" + "|Batting Score|" + "Fielding Score|"
FantasyInnings::OUR_TEAM.each do |player|
	puts player.strip + "|" + first_innings.player_batting_score[player].to_s + "|" + first_innings.player_fielding_score[player].to_s + "|"
end

puts "First Innings Opponent Individual Scores : ".green
puts "Player Name" + "|Batting Score|" + "Fielding Score|"
FantasyInnings::OPPOSING_TEAM.each do |player|
	puts player.strip + "|" + first_innings.player_batting_score[player].to_s + "|" + first_innings.player_fielding_score[player].to_s + "|"
end

total_first_innings = first_innings_our_score - first_innings_opponent_score
puts "Total first innings : #{total_first_innings}".blue

puts "*"*100

puts "SECOND INNINGS: ".red
second_innings = FantasyInnings.new

second_innings_records = batting_tables[1].css("tr:not(.dismissal-detail)").css("tr:not(.tr-heading)").css("tr:not(.extra-wrap)").css("tr:not(.total-wrap)")
second_innings_our_score, second_innings_opponent_score = second_innings.read_table_rows(second_innings_records)

puts "Second Innings Our Individual Scores : ".green
puts "Player Name" + "|Batting Score|" + "Fielding Score|"
FantasyInnings::OUR_TEAM.each do |player|
	puts player.strip + "|" + second_innings.player_batting_score[player].to_s + "|" + second_innings.player_fielding_score[player].to_s + "|"
end

puts "Second Innings Opponent Individual Scores : ".green
puts "Player Name" + "|Batting Score|" + "Fielding Score|"
FantasyInnings::OPPOSING_TEAM.each do |player|
	puts player.strip + "|" + second_innings.player_batting_score[player].to_s + "|" + second_innings.player_fielding_score[player].to_s + "|"
end

total_second_innings = (second_innings_our_score - second_innings_opponent_score)
puts "Total second innings : #{total_second_innings}".blue

puts "*"*100

puts "Our team: " + 	(first_innings_our_score + second_innings_our_score).to_s
puts "Opposing team: " + 	(first_innings_opponent_score + second_innings_opponent_score).to_s
puts "TOTAL : " + ((first_innings_our_score + second_innings_our_score) - (first_innings_opponent_score + second_innings_opponent_score)).to_s



