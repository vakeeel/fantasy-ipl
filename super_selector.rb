require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'colorize'
# require 'spreadsheet'

class FantasyInnings

#RPS: "AM Rahane, BA Stokes, AB Dinda, RA Tripathi, A Zampa, MA Agarwal, MS Dhoni, R Bhatia, DL Chahar, Imran Tahir, F du Plessis, LH Ferguson, RD Chahar, SN Thakur, MK Tiwary, Ankit Sharma"
#DD: "A Tare, SW Billings, KK Nair, CJ Anderson, Z Khan, S Nadeem, SV Samson, RR Pant, CH Morris, A Mishra, PJ Cummins, SS Iyer, J Yadav, AD Mathews"
#KXIP: "GJ Maxwell, M Vohra, DA Miller, MM Sharma, VR Aaron, Vishnu Vinod, HM Amla, AR Patel, WP Saha, MP Stoinis, Sandeep Sharma"
#RCB: "SR Watson, AB de Villiers, Mandeep Singh, TS Mills, YS Chahal, KM Jadhav, B Stanlake, P Negi, STR Binny, Iqbal Abdulla, T Natarajan"
#MI: "JC Buttler, KA Pollard, HH Pandya, JJ Bumrah, PA Patel, RG Sharma, KH Pandya, MJ McClenaghan, SL Malinga, Harbhajan Singh, N Rana"
#KKR: "MK Pandey, YK Pathan, SA Yadav, SP Narine, Kuldeep Yadav, TA Boult, G Gambhir, RV Uthappa, CA Lynn, CR Woakes, AS Rajpoot"
#GL: "AJ Finch, KD Karthik, RA Jadeja, Ishan Kishan, P Kumar, DR Smith, BB McCullum, SK Raina, Basil Thampi, AJ Tye, SB Jakati"
#SRH: "Rashid Khan, S Kaul, DA Warner, KS Williamson, Yuvraj Singh, NV Ojha, B Kumar, Mohammed Siraj, DJ Hooda, MC Henriques, S Dhawan"


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
	# OUR_PLAYERS = "LH Ferguson, AJ Finch, RD Chahar, SN Thakur, KD Karthik, RA Jadeja, MK Tiwary, Ishan Kishan, P Kumar, SPD Smith, RA Tripathi"
	# OPPOSING_PLAYERS = "MS Dhoni, DR Smith, BB McCullum, Ankit Sharma, SK Raina, Imran Tahir, Basil Thampi, BA Stokes, AJ Tye, AM Rahane, SB Jakati"
	# OUR_CAPTAIN = "SPD Smith"
	# OPPONENT_CAPTAIN = "Imran Tahir"
	# MATCH_URL = "http://www.espncricinfo.com/indian-premier-league-2017/engine/match/1082603.html?view=scorecard;wrappertype=none"

	# RCB vs RPS
	# OUR_PLAYERS = "SR Watson, DR Smith, KM Jadhav, TM Head, P Negi, AF Milne, YS Chahal, RA Jadeja, KD Karthik, Basil Thampi, Ishan Kishan"
	# OPPOSING_PLAYERS = "CH Gayle, V Kohli, BB McCullum,  Mandeep Singh, STR Binny, S Aravind, SK Raina, AJ Finch, DS Kulkarni, AJ Tye, S Kaushik"
	# OUR_CAPTAIN = "SR Watson"
	# OPPONENT_CAPTAIN = "V Kohli"
	# MATCH_URL = "http://www.espncricinfo.com/indian-premier-league-2017/engine/match/1082610.html?view=scorecard;wrappertype=none"

	# SRH vs DD
	# OUR_PLAYERS = "SW Billings, Rashid Khan, SS Iyer, S Kaul, KK Nair, DA Warner, KS Williamson, CH Morris, J Yadav, Yuvraj Singh, PJ Cummins"
	# OPPOSING_PLAYERS = "NV Ojha, B Kumar, SV Samson, Mohammed Siraj, RR Pant, DJ Hooda, AD Mathews, MC Henriques, S Dhawan, A Mishra, Z Khan"
	# OUR_CAPTAIN = "CH Morris"
	# OPPONENT_CAPTAIN = "MC Henriques"
	# MATCH_URL = "http://www.espncricinfo.com/indian-premier-league-2017/engine/match/1082611.html?view=scorecard;wrappertype=none"

	# MI vs KXI
	# OUR_PLAYERS = "SE Marsh, AR Patel, PA Patel, N Rana, Swapnil Singh, MM Sharma, KA Pollard, HH Pandya, Harbhajan Singh, SL Malinga, JJ Bumrah"
	# OPPOSING_PLAYERS = "HM Amla, WP Saha, Gurkeerat Singh, GJ Maxwell, Sandeep Sharma, MP Stoinis, JC Buttler, RG Sharma, KH Pandya, I Sharma, MJ McClenaghan"
	# OUR_CAPTAIN = "JJ Bumrah"
	# OPPONENT_CAPTAIN = "KH Pandya"
	# MATCH_URL = "http://www.espncricinfo.com/ci/engine/match/1082612.html?view=scorecard;wrappertype=none"

	# KKR vs GL
	# OUR_PLAYERS = "G Gambhir, BB McCullum, YK Pathan, Shakib Al Hasan, AJ Finch, CR Woakes, NM Coulter-Nile, Kuldeep Yadav, P Kumar, Ishan Kishan, DS Kulkarni"
	# OPPOSING_PLAYERS = "DR Smith, RV Uthappa, SP Narine, MK Pandey, SK Raina, SA Yadav, KD Karthik, RA Jadeja, JP Faulkner, Basil Thampi, UT Yadav"
	# OUR_CAPTAIN = "NM Coulter-Nile"
	# OPPONENT_CAPTAIN = "JP Faulkner"
	# MATCH_URL = "http://www.espncricinfo.com/indian-premier-league-2017/engine/match/1082613.html?view=scorecard;wrappertype=none"

	# RCB vs KKR
	OUR_PLAYERS = "G Gambhir, KM Jadhav, STR Binny, S Aravind, YK Pathan, SA Yadav, NM Coulter-Nile, Kuldeep Yadav, S Badree, TS Mills, AB de Villiers"
	OPPOSING_PLAYERS = "CH Gayle, V Kohli, Mandeep Singh, MK Pandey, YS Chahal, P Negi, RV Uthappa, CR Woakes, C de Grandhomme, SP Narine, UT Yadav"
	OUR_CAPTAIN = "TS Mills"
	OPPONENT_CAPTAIN = "V Kohli"
	MATCH_URL = "http://www.espncricinfo.com/indian-premier-league-2017/engine/match/1082617.html?view=scorecard;wrappertype=none"

	OUR_TEAM = OUR_PLAYERS.split(', ')
	OPPOSING_TEAM = OPPOSING_PLAYERS.split(', ')

	attr_accessor :our_team_batting_total, :opposing_team_batting_total, :our_team_fielding_total, 
	:opposing_team_fielding_total, :player_batting_score, :player_fielding_score

	def initialize
		@our_team_batting_total = 0
		@opposing_team_batting_total = 0
		@our_team_fielding_total = 0
		@opposing_team_fielding_total = 0
		@player_batting_score = Hash.new(0)
		@player_fielding_score = Hash.new(0)
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

	def update_scores_for_catch_or_stumping(dismissal)
		involved_players = dismissal.split(' b ')

		fielder_name = involved_players[0]
		fielder_name.gsub!(/†/, '')  # Doing this for keepers where you have † symbol.

		if (fielder_name.include? '&') 
			fielder_name = dismissal.split(' & ').last
		elsif (fielder_name.include? 'c ')
			fielder_name = fielder_name.split('c ').last
		elsif (fielder_name.include? 'st ')	
			fielder_name = fielder_name.split('st ').last
		end

		update_score_for_fielder(fielder_name)

		bowler_name = involved_players[1]
		if (bowler_name != nil)
			opposing_team_bowler_name = OPPOSING_TEAM.find {|s| s.include? bowler_name}
			if (opposing_team_bowler_name != nil)
				if (OPPONENT_CAPTAIN.include? bowler_name)
					@opposing_team_fielding_total += 2*20
					@player_fielding_score[opposing_team_bowler_name] += 2*20
				else
					@opposing_team_fielding_total += 20
					@player_fielding_score[opposing_team_bowler_name] += 20
				end
			else
				our_team_bowler_name = OUR_TEAM.find {|s| s.include? bowler_name}
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
		if (bowler_name != nil)
			opposing_team_bowler_name = OPPOSING_TEAM.find {|s| s.include? bowler_name}
			if (opposing_team_bowler_name != nil)
				if (OPPONENT_CAPTAIN.include? bowler_name)
					@opposing_team_fielding_total += 2*25
					@player_fielding_score[opposing_team_bowler_name] += 2*25
				else
					@opposing_team_fielding_total += 25
					@player_fielding_score[opposing_team_bowler_name] += 25
				end
			else
				our_team_bowler_name = OUR_TEAM.find {|s| s.include? bowler_name}
				if (OUR_CAPTAIN.include? bowler_name)
					@our_team_fielding_total += 2*25
					@player_fielding_score[our_team_bowler_name] += 2*25
				else
					@our_team_fielding_total += 25
					@player_fielding_score[our_team_bowler_name] += 25
				end
			end
		end
	end

	def update_scores_for_runout(dismissal)
		fielder_name = dismissal.scan(/\((.*)\)/)[0][0]
		if(fielder_name.include? '/')
			fielder_names = fielder_name.split('/')
			fielder_names.each do |fn|
				fn.gsub!(/†/, '')  # Doing this for keepers where you have † symbol.
				update_score_for_fielder(fn, true)
			end
			return
		end

		update_score_for_fielder(fielder_name)
	end

	def update_score_for_fielder(fielder_name, split=false)
		opposing_team_fielder_name = OPPOSING_TEAM.find {|s| s.include? fielder_name}
		fielding_points = split ? 2.5 : 5
		if (opposing_team_fielder_name != nil)
			if (OPPONENT_CAPTAIN.include? opposing_team_fielder_name)
				@opposing_team_fielding_total += 2*fielding_points
				@player_fielding_score[opposing_team_fielder_name] += 2*fielding_points
			else
				@opposing_team_fielding_total += fielding_points
				@player_fielding_score[opposing_team_fielder_name] += fielding_points
			end
		else
			our_team_fielder_name = OUR_TEAM.find {|s| s.include? fielder_name}
			if (our_team_fielder_name != nil)			
				if (OUR_CAPTAIN.include? our_team_fielder_name)
					@our_team_fielding_total += 2*fielding_points
					@player_fielding_score[our_team_fielder_name] += 2*fielding_points
				else
					@our_team_fielding_total += fielding_points
					@player_fielding_score[our_team_fielder_name] += fielding_points
				end
			end
		end
	end
end

puts "OUR TEAM : ".bold + FantasyInnings::OUR_PLAYERS
puts "OPPOSING TEAM : ".bold + FantasyInnings::OPPOSING_PLAYERS

puts "*"*100

"http://www.espncricinfo.com/indian-premier-league-2017/engine/match/1082600.html?view=scorecard;wrappertype=none"
page = Nokogiri::HTML(open(FantasyInnings::MATCH_URL))
batting_tables = page.css(".full-scorecard-block").css(".batting-table")

puts "FIRST INNINGS: ".cyan.bold
first_innings = FantasyInnings.new

first_innings_records = batting_tables[0].css("tr:not(.dismissal-detail)").css("tr:not(.tr-heading)").css("tr:not(.extra-wrap)").css("tr:not(.total-wrap)")
first_innings_our_score, first_innings_opponent_score = first_innings.read_table_rows(first_innings_records)

# puts "*"*100

puts "SECOND INNINGS: ".cyan.bold
second_innings = FantasyInnings.new

second_innings_records = batting_tables[1].css("tr:not(.dismissal-detail)").css("tr:not(.tr-heading)").css("tr:not(.extra-wrap)").css("tr:not(.total-wrap)")
second_innings_our_score, second_innings_opponent_score = second_innings.read_table_rows(second_innings_records)

puts "*"*100

puts "Our Team".colorize(:color => :white, :background => :black).bold
printf "%-20s %-20s %-20s %-20s\n", "Player", "Batting Score", "Fielding Score", "Total Score"
player_final_batting_score = Hash.new(0)
player_final_fielding_score = Hash.new(0)
player_final_score = Hash.new(0)

FantasyInnings::OUR_TEAM.each do |player|
	player_final_batting_score[player] = first_innings.player_batting_score[player] + second_innings.player_batting_score[player]
	player_final_fielding_score[player] = first_innings.player_fielding_score[player] + second_innings.player_fielding_score[player]
	player_final_score[player] = player_final_batting_score[player] + player_final_fielding_score[player]
	
	player_name = (FantasyInnings::OUR_CAPTAIN.include? player) ? player.strip + "*" : player.strip
	printf "%-20s %-20s %-20s %-20s\n", player_name, player_final_batting_score[player].to_s, player_final_fielding_score[player].to_s, player_final_score[player].to_s
end

our_team_total = first_innings_our_score + second_innings_our_score
puts "Our Team Total : #{our_team_total}".blue.bold

puts "*"*100

puts "Opposing Team".colorize(:color => :white, :background => :black).bold
printf "%-20s %-20s %-20s %-20s\n", "Player", "Batting Score", "Fielding Score", "Total Score"

opposing_player_final_batting_score = Hash.new(0)
opposing_player_final_fielding_score = Hash.new(0)
opposing_player_final_score = Hash.new(0)

FantasyInnings::OPPOSING_TEAM.each do |player|
	opposing_player_final_batting_score[player] = first_innings.player_batting_score[player] + second_innings.player_batting_score[player]
	opposing_player_final_fielding_score[player] = first_innings.player_fielding_score[player] + second_innings.player_fielding_score[player]
	opposing_player_final_score[player] = opposing_player_final_batting_score[player] + opposing_player_final_fielding_score[player]
	
	player_name = (FantasyInnings::OPPONENT_CAPTAIN.include? player) ? player.strip + "*" : player.strip
	printf "%-20s %-20s %-20s %-20s\n", player_name, opposing_player_final_batting_score[player].to_s, opposing_player_final_fielding_score[player].to_s, opposing_player_final_score[player].to_s
end	

opposing_team_total = first_innings_opponent_score + second_innings_opponent_score
puts "Opposing Team Total : #{opposing_team_total}".blue.bold

puts "*"*100

final_total = (first_innings_our_score + second_innings_our_score) - (first_innings_opponent_score + second_innings_opponent_score)
puts "MATCH AGGREGATE : ".bold + ((final_total < 0) ? final_total.to_s.red : final_total.to_s.green)

# man_of_the_match_details = page.css(".match-details-block").css(".match-information").css(".normal")[2].text
# man_of_the_match = man_of_the_match_details.split(" (")[0]
# puts "Man of the Match : ".bold + man_of_the_match

# if (FantasyInnings::OUR_TEAM.include? man_of_the_match)
# 	match_aggregate = final_total + 50
# else
# 	match_aggregate = final_total - 50
# end
# puts "MATCH AGGREGATE : ".bold + ((match_aggregate < 0) ? match_aggregate.to_s.red : match_aggregate.to_s.green)

# Writing to a spreadsheet
# book = Spreadsheet::Workbook.new 
# sheet1 = book.create_worksheet :name => "game_points"

# sheet1[0,0] = "Player"
# sheet1[0,1] = "Batting Score"
# sheet1[0,2] = "Bowling Score"
# sheet1[0,3] = "Total Score"

# book.write 'fantasy_points.xls'
