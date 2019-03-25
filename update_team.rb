# Follow steps here: 
#
# 1. https://developers.google.com/sheets/api/quickstart/ruby#step_1_turn_on_the_api_name
# 2. bundle install
# 3. ruby update_team.rb -m csk_rcb.yml

require 'active_support'
require 'active_support/core_ext'
require 'yaml'
require 'optparse'
require 'active_record'
require 'yaml'
require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

options = {:team => nil, :match => nil}

parser = OptionParser.new do|opts|
  opts.banner = "Usage: update_team.rb [options]"

  opts.on('-m', '--match match', 'Match') do |match|
    options[:match] = match;
  end

  opts.on('-h', '--help', 'Displays Help') do
    puts opts
    exit
  end
end

parser.parse!

if options[:match] == nil
    options[:match] = 'csk_rcb'
end
 

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
APPLICATION_NAME = 'Google Sheets API Ruby Quickstart'.freeze
CREDENTIALS_PATH = 'credentials.json'.freeze

# The file token.yaml stores the user's access and refresh tokens, and is
# created automatically when the authorization flow completes for the first
# time.
TOKEN_PATH = 'token.yaml'.freeze
SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY

# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
  client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: OOB_URI)
    puts 'Open the following URL in the browser and enter the ' \
         "resulting code after authorization:\n" + url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI
    )
  end
  credentials
end

class Team

  attr_reader :our_team, :opponent_team, :key

  def initialize(response, key, players)
    @key = key
    @our_team = []
    @opponent_team = []

    response.values.each_with_index do |row, index|
      # Print columns A and E, which correspond to indices 0 and 4.
      if index == 0
        row[0].gsub!(/\(PP\)/i,"")
        row[1].gsub!(/\(PP\)/i,"")
      end 

      @our_team << players.find { |player| player.downcase.include? row[0].downcase } 
      @opponent_team << players.find { |player| player.downcase.include? row[1].downcase } 
    end if response.values.present?
  end  
end 

class ReadTeam
  attr_reader :spreadsheet_id, :range, :sai_team, :vineeth_team, :uday_team, :vinay_team, :vamsi_team

  def initialize(config)
    @spreadsheet_id = config[:google][:spreadsheet_id]
    
    players = (config[config[:first_innings_fielding_team].to_sym] + ', ' + config[config[:second_innings_fielding_team].to_sym]).to_s.split(', ')

    # @vineeth_team = Team.new(teams(config[:google][:vv_range]), 'vineeth', players)
    # @vinay_team = Team.new(teams(config[:google][:vinay_range]), 'vinay', players)
    @sai_team = Team.new(teams(config[:google][:sai_range]), 'sai', players)
    @vamsi_team = Team.new(teams(config[:google][:vamsi_range]), 'vamsi', players)
    @uday_team = Team.new(teams(config[:google][:uday_range]), 'uday', players)
  end  

  private

  # Returns the information of JIRA's that are "In Review" for the team passed in.
  def teams(range)
    # Initialize the API
    service = Google::Apis::SheetsV4::SheetsService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize
    service.get_spreadsheet_values(@spreadsheet_id, range)
  end
 end   

game_config = YAML.load(ERB.new(File.read("#{options[:match]}.yml")).result)
read_team = ReadTeam.new(game_config.deep_symbolize_keys[:game])

# game_config['vineeth']['our_team']['players'] = "#{read_team.vineeth_team.our_team.join(', ')}"
# game_config['vineeth']['opposing_team']['players'] = "#{read_team.vineeth_team.opponent_team.join(', ')}"
# File.open("#{options[:match]}.yml", 'w') { |file| file.write game_config.to_yaml }

# game_config['vinay']['our_team']['players'] = "#{read_team.vinay_team.our_team.join(', ')}"
# game_config['vinay']['opposing_team']['players'] = "#{read_team.vinay_team.opponent_team.join(', ')}"
# File.open("#{options[:match]}.yml", 'w') { |file| file.write game_config.to_yaml }

game_config['sai']['our_team']['players'] = "#{read_team.sai_team.our_team.join(', ')}"
game_config['sai']['opposing_team']['players'] = "#{read_team.sai_team.opponent_team.join(', ')}"
File.open("#{options[:match]}.yml", 'w') { |file| file.write game_config.to_yaml }

game_config['uday']['our_team']['players'] = "#{read_team.uday_team.our_team.join(', ')}"
game_config['uday']['opposing_team']['players'] = "#{read_team.uday_team.opponent_team.join(', ')}"
File.open("#{options[:match]}.yml", 'w') { |file| file.write game_config.to_yaml }

game_config['vamsi']['our_team']['players'] = "#{read_team.vamsi_team.our_team.join(', ')}"
game_config['vamsi']['opposing_team']['players'] = "#{read_team.vamsi_team.opponent_team.join(', ')}"
File.open("#{options[:match]}.yml", 'w') { |file| file.write game_config.to_yaml }
