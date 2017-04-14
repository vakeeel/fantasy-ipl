require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'optparse' 

# OptionParser.new do |opt|
#   opt.on('--our_team OURTEAM') { |o| our_team = o }
#   opt.on('--opposing_team OPPOSINGTEAM') { |o| opposing_team = o }
#   opt.on('--our_captain OURCAPTAIN') { |o| our_captain = o }
#   opt.on('--opponent_captain OPPONENTCAPTAIN') { |o| opponent_captain = o }
#   opt.on('--match_url MATCHURL') { |o| match_url = o }
# end.parse!

# RPS VS DD
# our_team = "F du Plessis, SV Samson, MA Agarwal, RR Pant, CH Morris, A Mishra, PJ Cummins, MS Dhoni, R Bhatia, DL Chahar, Imran Tahir"
# opposing_team = "AM Rahane, A Tare, SW Billings, KK Nair, BA Stokes, CJ Anderson, A Zampa, Z Khan, S Nadeem, AB Dinda, RA Tripathi"
# our_captain = "Imran Tahir"
# opponent_captain = "BA Stokes"
# match_url = "http://www.espncricinfo.com/indian-premier-league-2017/engine/match/1082599.html"

# KXIP VS RCB
# our_team = "SR Watson, GJ Maxwell, M Vohra, AB de Villiers, Mandeep Singh, TS Mills, DA Miller, MM Sharma, YS Chahal, T Natarajan, VR Aaron"
# opposing_team = "Vishnu Vinod, HM Amla, KM Jadhav, P Negi, Iqbal Abdulla, B Stanlake, AR Patel, STR Binny, WP Saha, MP Stoinis, Sandeep Sharma"
# our_captain = "SR Watson"
# opponent_captain = "AR Patel"
# match_url = "http://www.espncricinfo.com/indian-premier-league-2017/engine/match/1082598.html"

# MI VS KKR
# our_team = "JC Buttler, KA Pollard, MK Pandey, HH Pandya, YK Pathan, SA Yadav, SP Narine, Kuldeep Yadav, AS Rajpoot, TA Boult, JJ Bumrah"
# opposing_team = "G Gambhir, RV Uthappa, CA Lynn, PA Patel, RG Sharma, KH Pandya, MJ McClenaghan, SL Malinga, CR Woakes, Harbhajan Singh, N Rana"
# our_captain = "Kuldeep Yadav"
# opponent_captain = "SL Malinga"
# match_url = "http://www.espncricinfo.com/indian-premier-league-2017/engine/match/1082597.html"

# SRH VS GL
# our_team = "DA Warner, MC Henriques, JJ Roy, SK Raina, Yuvraj Singh, Rashid Khan, P Kumar, A Nehra, DJ Hooda, Basil Thampi, Tejas Baroka"
# opposing_team = "B Kumar, BCJ Cutting, BB McCullum, DR Smith, AJ Finch, KD Karthik, S Dhawan, DS Kulkarni, Bipul Sharma, S Kaushik, NV Ojha"
# our_captain = "DA Warner"
# opponent_captain = "B Kumar"
# match_url = "http://www.espncricinfo.com/indian-premier-league-2017/engine/match/1082596.html"

# RCB vs DD
# our_team = "CH Morris, CH Gayle, TS Mills, A Mishra, KM Jadhav, KK Nair, RR Pant, Iqbal Abdulla, Mandeep Singh, P Negi, Z Khan"
# opposing_team = "SR Watson, CR Brathwaite, SW Billings, PJ Cummins, SV Samson, AP Tare, YS Chahal, B Stanlake, STR Binny, S Nadeem, Vishnu Vinod"
# our_captain = "CH Morris"
# opponent_captain = "SR Watson"
# match_url = "http://www.espncricinfo.com/indian-premier-league-2017/engine/match/1082595.html"


# KXIB vs KKR
# our_team = "AR Patel, MP Stoinis, TA Boult, PP Chawla, RV Uthappa, GJ Maxwell, Sandeep Sharma, M Vohra, YK Pathan, SA Yadav, DA Miller"
# opposing_team = "G Gambhir, HM Amla, WP Saha, MK Pandey, MM Sharma, I Sharma, VR Aaron, CR Woakes, C de Grandhomme, SP Narine, UT Yadav"
# our_captain = "AR Patel"
# opponent_captain = "C de Grandhomme"
# match_url = "http://www.espncricinfo.com/indian-premier-league-2017/engine/match/1082601.html?view=scorecard;wrappertype=none"

# RCB vs MI
# our_team = "CH Gayle, PA Patel, JJ Bumrah, AB de Villiers, N Rana, Mandeep Singh, Harbhajan Singh, KA Pollard, TS Mills, TG Southee, S Badree"
# opposing_team = "V Kohli, JC Buttler, RG Sharma, KH Pandya, KM Jadhav, STR Binny, P Negi, HH Pandya, YS Chahal, MJ McClenaghan, S Aravind"
# our_captain = "JJ Bumrah"
# opponent_captain = "V Kohli"
# match_url = "http://www.espncricinfo.com/indian-premier-league-2017/engine/match/1082602.html?view=scorecard;wrappertype=none"

# GL vs RPS
our_team = "LH Ferguson, AJ Finch, RD Chahar, SN Thakur, KD Karthik, RA Jadeja, MK Tiwary, Ishan Kishan, P Kumar, SPD Smith, RA Tripathi"
opposing_team = "MS Dhoni, DR Smith, BB McCullum, Ankit Sharma, SK Raina, Imran Tahir, Basil Thampi, BA Stokes, AJ Tye, AM Rahane, SB Jakati"
our_captain = "SPD Smith"
opponent_captain = "Imran Tahir"
match_url = "http://www.espncricinfo.com/indian-premier-league-2017/engine/match/1082603.html?view=scorecard;wrappertype=none"

our_players = our_team.split(', ')
opponent_players = opposing_team.split(', ')

def read_table_rows(trs, our_team, opposing_team, our_captain, opponent_captain)
	opposing_team_batting_total = 0
	our_team_batting_total = 0
	dismissal_info = []

	trs.each do |tr|
		batsman_name_row = tr.css(".batsman-name").css("a")
		batsman_name = batsman_name_row.text
		runs = tr.css(".bold").text.to_i

		if (our_team.include? batsman_name) 
			our_team_batting_total += (our_captain.include? batsman_name) ? 2*runs : runs
		elsif (opposing_team.include? batsman_name)
			opposing_team_batting_total += (opponent_captain.include? batsman_name) ? 2*runs : runs
		end

		dismissal_info << tr.css(".dismissal-info").text.strip!
	end
	puts "Our team batting score: " + our_team_batting_total.to_s
	puts "Opposing team batting score: " + opposing_team_batting_total.to_s

	our_team_fielding_total = 0
	opposing_team_fielding_total = 0

	dismissal_info.each do |dismissal|
		if (dismissal.include? 'c ')
			fielder_name = dismissal.split(' ')[1]
			if (fielder_name == '&') 
				fielder_name = dismissal.split(' ').last
			end

			fielder_name.gsub!(/\W+/, '')  # Doing this for keepers where you have † symbol.
			if (opposing_team.any? {|s| s.include? fielder_name})
				opposing_team_fielding_total += (opponent_captain.include? fielder_name) ? 2*5 : 5
			elsif (our_team.any? {|s| s.include? fielder_name})
				our_team_fielding_total += (our_captain.include? fielder_name) ? 2*5 : 5
			end

			bowler_name = dismissal.split(' b ')[1]
			if (bowler_name != nil)
				if (opposing_team.any? {|s| s.include? bowler_name})
					opposing_team_fielding_total += (opponent_captain.include? bowler_name) ? 2*20 : 20
				elsif (our_team.any? {|s| s.include? bowler_name})
					our_team_fielding_total += (our_captain.include? bowler_name) ? 2*20 : 20
				end
			end
			
			next;
		elsif (dismissal.include? 'lbw ')	
			bowler_name = dismissal.split('b ')[1]
			if (opposing_team.any? {|s| s.include? bowler_name})
				opposing_team_fielding_total += (opponent_captain.include? bowler_name) ? 2*25 : 25
			elsif (our_team.any? {|s| s.include? bowler_name})
				our_team_fielding_total += (our_captain.include? bowler_name) ? 2*25 : 25
			end
			next;
		elsif (dismissal.include? 'run out')
			fielder_name = dismissal.scan(/\((.*)\)/)[0][0]
			if(fielder_name.include? '/')
				fielder_names = fielder_name.split('/')
				fielder_names.each do |fn|
					if (opposing_team.any? {|s| s.include? fn})
						opposing_team_fielding_total += (opponent_captain.include? fn) ? 2*5 : 5
					elsif (our_team.any? {|s| s.include? fn})
						our_team_fielding_total += (our_captain.include? fn) ? 2*5 : 5
					end
				end
				next
			end

			if (opposing_team.any? {|s| s.include? fielder_name})
				opposing_team_fielding_total += (opponent_captain.include? fielder_name) ? 2*5 : 5
			elsif (our_team.any? {|s| s.include? fielder_name})
				our_team_fielding_total += (our_captain.include? fielder_name) ? 2*5 : 5
			end
			next
		elsif (dismissal.include? 'b ')
			bowler_name = dismissal.split('b ')[1]
			if (opposing_team.any? {|s| s.include? bowler_name})
				opposing_team_fielding_total += (opponent_captain.include? bowler_name) ? 2*25 : 25
			elsif (our_team.any? {|s| s.include? bowler_name})
				our_team_fielding_total += (our_captain.include? bowler_name) ? 2*25 : 25
			end
		end
	end

	puts "Our Team Fielding Score : " + our_team_fielding_total.to_s
	puts "Opposing Team Fielding Score : " + opposing_team_fielding_total.to_s

	return (our_team_batting_total + our_team_fielding_total), (opposing_team_batting_total + opposing_team_fielding_total)
end

puts "OUR TEAM : " + our_team
puts "OPPOSING TEAM : " + opposing_team
puts "*"*100

# "http://www.espncricinfo.com/indian-premier-league-2017/engine/match/1082600.html?view=scorecard;wrappertype=none"
page = Nokogiri::HTML(open(match_url))
batting_tables = page.css(".full-scorecard-block").css(".batting-table")

puts "FIRST INNINGS: "
first_innings = batting_tables[0].css("tr:not(.dismissal-detail)").css("tr:not(.tr-heading)").css("tr:not(.extra-wrap)").css("tr:not(.total-wrap)")
first_innings_our_score, first_innings_opponent_score = read_table_rows(first_innings, our_players, opponent_players, our_captain, opponent_captain)
puts "Total first innings : " + (first_innings_our_score - first_innings_opponent_score).to_s

puts "*"*100

puts "SECOND INNINGS: "
second_innings = batting_tables[1].css("tr:not(.dismissal-detail)").css("tr:not(.tr-heading)").css("tr:not(.extra-wrap)").css("tr:not(.total-wrap)")
second_innings_our_score, second_innings_opponent_score = read_table_rows(second_innings, our_players, opponent_players, our_captain, opponent_captain)
puts "Total second innings : " + (second_innings_our_score - second_innings_opponent_score).to_s

puts "*"*100

puts "Our team: " + 	(first_innings_our_score + second_innings_our_score).to_s
puts "Opposing team: " + 	(first_innings_opponent_score + second_innings_opponent_score).to_s
puts "TOTAL : " + ((first_innings_our_score + second_innings_our_score) - (first_innings_opponent_score + second_innings_opponent_score)).to_s





