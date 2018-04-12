require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'colorize'
require 'active_support'
require 'active_support/core_ext'
require 'yaml'
require 'optparse'
require 'active_record'
require 'highline/import'
require 'pp'

options = {:team => nil, :match => nil}

parser = OptionParser.new do|opts|
	opts.banner = "Usage: super_selector.rb [options]"
	opts.on('-t', '--team team', 'Team') do |team|
		options[:team] = team.to_sym;
	end

	opts.on('-m', '--match match', 'Match') do |match|
		options[:match] = match;
	end

	opts.on('-h', '--help', 'Displays Help') do
		puts opts
		exit
	end
end

parser.parse!

if options[:team] == nil
    options[:team] = 'vv'.to_sym
end

if options[:match] == nil
    options[:match] = 'srh_mi'
end

class FantasyInnings
	attr_accessor :batting_records, :bowling_records, :our_team_batting_total, :our_team_bowling_total, 
	:our_team_fielding_total, :opposing_team_batting_total, :opposing_team_bowling_total, :opposing_team_fielding_total, 
	:player_batting_score, :player_bowling_score, :player_fielding_score, :our_team_total, :opposing_team_total,
	:our_team, :opposing_team, :fielding_team

	def initialize(batting_card, bowling_card, our_team, opposing_team, fielding_team)
		if (batting_card != nil && batting_card.css(".flex-row") != nil)
			@batting_records = batting_card.css(".flex-row").css(".wrap.batsmen")
			@bowling_records = bowling_card.css("tbody").css("tr")
		else
			@batting_records = []
			@bowling_records = []		
		end	

		@our_team = get_team(our_team)
		@opposing_team = get_team(opposing_team)
		@fielding_team = fielding_team.split(", ")

		@our_team_batting_total = 0
		@opposing_team_batting_total = 0
		@our_team_bowling_total = 0
		@our_team_total = 0

		@opposing_team_bowling_total = 0
		@our_team_fielding_total = 0
		@opposing_team_fielding_total = 0
		@opposing_team_total = 0

		@player_batting_score = Hash.new(0)
		@player_bowling_score = Hash.new(0)
		@player_fielding_score = Hash.new(0)
	end

	def aggregate
		dismissal_infos = get_dismissal_infos

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

		add_bonus_points(@our_team)
		add_bonus_points(@opposing_team, false)

		@our_team_total = @our_team_batting_total + @our_team_bowling_total + @our_team_fielding_total
		@opposing_team_total = @opposing_team_batting_total + @opposing_team_bowling_total + @opposing_team_fielding_total
		return @our_team_total - @opposing_team_total
	end

	private 

	def get_team(config)
		team = {}
		team[:players] = config[:players].split(', ')
		team[:power_player] = config[:power_player]

		team
	end	

	def add_bonus_points(team, is_our_team = true)
		team[:players].each do |player_name|
			add_bonus_points_for_wickets(player_name, is_our_team)	
			add_bonus_points_for_batsmen(player_name, is_our_team)	
		end	
	end	

	def add_bonus_points_for_wickets(player_name, is_our_team)
		captain = is_our_team ? @our_team[:power_player] : @opposing_team[:power_player]
		is_player_captain = captain.include?(player_name)
		player_score = is_player_captain ? @player_bowling_score[player_name]/2 : @player_bowling_score[player_name]
		wickets = player_score/20

		points = 0
		if wickets.between?(2,3)
			points = is_player_captain ? 2*10 : 10
		elsif wickets == 4
			points = is_player_captain ? 2*25 : 25
		elsif wickets >= 5
			points = is_player_captain ? 2*50 : 50
		end		

		if is_our_team
			@our_team_bowling_total += points
		else
			@opposing_team_bowling_total += points	
		end
		@player_bowling_score[player_name] += points
	end	

	def add_bonus_points_for_batsmen(player_name, is_our_team)
		captain = is_our_team ? @our_team[:power_player] : @opposing_team[:power_player]
		is_player_captain = captain.include?(player_name)
		player_score = is_player_captain ? @player_batting_score[player_name]/2 : @player_batting_score[player_name]
		milestone = player_score/50

		points = 0
		if milestone == 1
			points = is_player_captain ? 2*10 : 10
		elsif milestone == 2
			points = is_player_captain ? 2*25 : 25
		elsif milestone >= 3
			points = is_player_captain ? 2*50 : 50
		end

		if is_our_team
			@our_team_batting_total += points
		else
			@opposing_team_batting_total += points	
		end	
		@player_batting_score[player_name] += points		
	end	

	def get_dismissal_infos
		dismissal_infos = []
		
		@batting_records.each do |batting_record|
			batsman_name = batting_record.css(".cell.batsmen").css("a").text
			runs = batting_record.css(".cell.runs")[0].text.to_i

			if (@our_team[:players].include? batsman_name) 			
				if (@our_team[:power_player].include? batsman_name)
					@our_team_batting_total += 2*runs
					@player_batting_score[batsman_name] = 2*runs
				else	
					@our_team_batting_total += runs
					@player_batting_score[batsman_name] = runs
				end
			elsif (@opposing_team[:players].include? batsman_name)
				if (@opposing_team[:power_player].include? batsman_name)
					@opposing_team_batting_total += 2*runs
					@player_batting_score[batsman_name] = 2*runs
				else	
					@opposing_team_batting_total += runs
					@player_batting_score[batsman_name] = runs
				end
			end

			dismissal = batting_record.css(".cell.commentary").css("a").text
			dismissal.strip!
			dismissal_infos << dismissal
		end

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
		update_score_for_bowler(bowler_name, 20)
	end

	def update_scores_for_lbw_or_bowled(dismissal)
		bowler_name = dismissal.split('b ')[1]
		update_score_for_bowler(bowler_name, 25)
	end

	def update_score_for_bowler(bowler_name, points)
		if (bowler_name != nil)
			bowler_tr = @bowling_records.find { |tr| tr.css("td").css("a").text.to_s.include?(bowler_name) }
			bowler_name = bowler_tr.css("td").css("a").text.to_s

			opposing_team_bowler_name = @opposing_team[:players].find {|s| s.include? bowler_name}
			if (opposing_team_bowler_name != nil)
				if (@opposing_team[:power_player].include? bowler_name)
					@opposing_team_bowling_total += 2*points
					@player_bowling_score[opposing_team_bowler_name] += 2*points
				else
					@opposing_team_bowling_total += points
					@player_bowling_score[opposing_team_bowler_name] += points
				end
			else
				our_team_bowler_name = @our_team[:players].find {|s| s.include? bowler_name}
				if (@our_team[:power_player].include? bowler_name)
					@our_team_bowling_total += 2*points
					@player_bowling_score[our_team_bowler_name] += 2*points
				else
					@our_team_bowling_total += points
					@player_bowling_score[our_team_bowler_name] += points
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

	def update_score_for_fielder(fielder_name, split = false)
		fielder_name = @fielding_team.find { |fielder| fielder.include? fielder_name.to_s }

		if (fielder_name != nil)
			opposing_team_fielder_name = @opposing_team[:players].find {|s| s.include? fielder_name } 
			fielding_points = split ? 2.5 : 5
			if (opposing_team_fielder_name != nil)
				if (@opposing_team[:power_player].include? opposing_team_fielder_name)
					@opposing_team_fielding_total += 2*fielding_points
					@player_fielding_score[opposing_team_fielder_name] += 2*fielding_points
				else
					@opposing_team_fielding_total += fielding_points
					@player_fielding_score[opposing_team_fielder_name] += fielding_points
				end
			else
				our_team_fielder_name = @our_team[:players].find {|s| s.include? fielder_name}
				if (our_team_fielder_name != nil)			
					if (@our_team[:power_player].include? our_team_fielder_name)
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
end

game_config = YAML.load(ERB.new(File.read("#{options[:match]}.yml")).result).deep_symbolize_keys
our_team = game_config[options[:team]][:our_team]
opposing_team = game_config[options[:team]][:opposing_team]

puts "OUR TEAM : ".bold + our_team[:players]
puts "OPPOSING TEAM : ".bold + opposing_team[:players]

puts "*"*100

page = Nokogiri::HTML(open(game_config[:game][:match_url]).read)

puts "FIRST INNINGS: ".cyan.bold
first_innings_fielding_team = game_config[:game][game_config[:game][:first_innings_fielding_team].to_sym]
first_innings = FantasyInnings.new(page.css(".scorecard-section.batsmen")[0], page.css(".scorecard-section.bowling")[0], our_team, opposing_team, first_innings_fielding_team)
fi_aggregate = first_innings.aggregate.to_s

printf "%-20s %-20s %-20s %-20s %-20s\n", "Team", "Batting Score", "Bowling Score", "Fielding Score", "Total Score"
printf "%-20s %-20s %-20s %-20s %-20s\n", "Our Team", first_innings.our_team_batting_total.to_s, first_innings.our_team_bowling_total.to_s, first_innings.our_team_fielding_total.to_s, first_innings.our_team_total.to_s
printf "%-20s %-20s %-20s %-20s %-20s\n", "Opposing Team", first_innings.opposing_team_batting_total.to_s, first_innings.opposing_team_bowling_total.to_s, first_innings.opposing_team_fielding_total.to_s, first_innings.opposing_team_total.to_s
puts "First Innings Aggregate : #{fi_aggregate}".blue.bold

puts "*"*100

puts "SECOND INNINGS: ".cyan.bold
second_innings_fielding_team = game_config[:game][game_config[:game][:second_innings_fielding_team].to_sym]
second_innings = FantasyInnings.new(page.css(".scorecard-section.batsmen")[1], page.css(".scorecard-section.bowling")[1], our_team, opposing_team, second_innings_fielding_team)
si_aggregate = second_innings.aggregate.to_s

printf "%-20s %-20s %-20s %-20s %-20s\n", "Team", "Batting Score", "Bowling Score", "Fielding Score", "Total Score"
printf "%-20s %-20s %-20s %-20s %-20s\n", "Our Team", second_innings.our_team_batting_total.to_s, second_innings.our_team_bowling_total.to_s, second_innings.our_team_fielding_total.to_s, second_innings.our_team_total.to_s
printf "%-20s %-20s %-20s %-20s %-20s\n", "Opposing Team", second_innings.opposing_team_batting_total.to_s, second_innings.opposing_team_bowling_total.to_s, second_innings.opposing_team_fielding_total.to_s, second_innings.opposing_team_total.to_s
puts "Second Innings Aggregate : #{si_aggregate}".blue.bold

puts "*"*100

puts "Our Team".colorize(:color => :white, :background => :black).bold
printf "%-20s %-20s %-20s %-20s %-20s\n", "Player", "Batting Score", "Bowling Score", "Fielding Score", "Total Score"
player_final_batting_score = Hash.new(0)
player_final_bowling_score = Hash.new(0)
player_final_fielding_score = Hash.new(0)
player_final_score = Hash.new(0)

our_team[:players].split(', ').each do |player|
	player_final_batting_score[player] = first_innings.player_batting_score[player] + second_innings.player_batting_score[player]
	player_final_bowling_score[player] = first_innings.player_bowling_score[player] + second_innings.player_bowling_score[player]
	player_final_fielding_score[player] = first_innings.player_fielding_score[player] + second_innings.player_fielding_score[player]
	player_final_score[player] = player_final_batting_score[player] + player_final_bowling_score[player] + player_final_fielding_score[player]
	
	player_name = (our_team[:power_player].include? player) ? player.strip + "*" : player.strip
	printf "%-20s %-20s %-20s %-20s %-20s\n", player_name, player_final_batting_score[player].to_s, player_final_bowling_score[player].to_s, player_final_fielding_score[player].to_s, player_final_score[player].to_s
end

our_team_game_total = first_innings.our_team_total + second_innings.our_team_total
puts "Our Team Total : #{our_team_game_total}".blue.bold

puts "*"*100

puts "Opposing Team".colorize(:color => :white, :background => :black).bold
printf "%-20s %-20s %-20s %-20s %-20s\n", "Player", "Batting Score", "Bowling Score", "Fielding Score", "Total Score"

opposing_player_final_batting_score = Hash.new(0)
opposing_player_final_bowling_score = Hash.new(0)
opposing_player_final_fielding_score = Hash.new(0)
opposing_player_final_score = Hash.new(0)

opposing_team[:players].split(', ').each do |player|
	opposing_player_final_batting_score[player] = first_innings.player_batting_score[player] + second_innings.player_batting_score[player]
	opposing_player_final_bowling_score[player] = first_innings.player_bowling_score[player] + second_innings.player_bowling_score[player]
	opposing_player_final_fielding_score[player] = first_innings.player_fielding_score[player] + second_innings.player_fielding_score[player]
	opposing_player_final_score[player] = opposing_player_final_batting_score[player] + opposing_player_final_bowling_score[player] + opposing_player_final_fielding_score[player]
	
	player_name = (opposing_team[:power_player].include? player) ? player.strip + "*" : player.strip
	printf "%-20s %-20s %-20s %-20s %-20s\n", player_name, opposing_player_final_batting_score[player].to_s, opposing_player_final_bowling_score[player].to_s, opposing_player_final_fielding_score[player].to_s, opposing_player_final_score[player].to_s
end	

opposing_team_game_total = first_innings.opposing_team_total + second_innings.opposing_team_total
puts "Opposing Team Total : #{opposing_team_game_total}".blue.bold

man_of_the_match = game_config[:game][:mom]
if (man_of_the_match != nil)
	if (our_team[:players].split(", ").include? man_of_the_match) 			
		if (our_team[:power_player].include? man_of_the_match)
			our_team_game_total += 2*30
		else	
			our_team_game_total += 30
		end
	elsif (opposing_team[:players].split(", ").include? man_of_the_match)
		if (opposing_team[:power_player].include? man_of_the_match)
			opposing_team_game_total += 2*30
		else	
			opposing_team_game_total += 30
		end
	end
	puts "Man Of The Match: ".bold + man_of_the_match 
end

puts "*"*100	

final_game_total = our_team_game_total - opposing_team_game_total
puts "MATCH AGGREGATE: ".bold + ((final_game_total < 0) ? final_game_total.to_s.red : final_game_total.to_s.green)

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
