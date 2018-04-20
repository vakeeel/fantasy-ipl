# Follow steps here: https://developers.google.com/sheets/api/quickstart/ruby#step_1_turn_on_the_api_name
# in order to use this script.

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
  opts.banner = "Usage: quickstart.rb [options]"

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
    options[:match] = 'rr_csk'
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
        row[0].gsub!("(PP)","")
        row[1].gsub!("(PP)","")
      end 

      @our_team << players.find { |player| player.downcase.include? row[0].downcase } 
      @opponent_team << players.find { |player| player.downcase.include? row[1].downcase } 
    end if response.values.present?
  end  
end  

class ReadTeam

  attr_reader :spreadsheet_id, :range, :sai_team, :vineeth_team, :uday_team, :vinay_team

  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
  APPLICATION_NAME = 'Google Sheets API Ruby Quickstart'
  CLIENT_SECRETS_PATH = 'client_secret.json'
  CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                               "sheets.googleapis.com-ruby-quickstart.yaml")
  SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY

  def initialize(config)
    @spreadsheet_id = config[:google][:spreadsheet_id]
    
    players = (config[config[:first_innings_fielding_team].to_sym] + ', ' + config[config[:second_innings_fielding_team].to_sym]).to_s.split(', ')

    # @vineeth_team = Team.new(teams(config[:google][:vineeth_range]), 'vineeth', players)
    @vinay_team = Team.new(teams(config[:google][:vinay_range]), 'vinay', players)
    # @sai_team = Team.new(teams(config[:google][:sai_range]), 'sai', players)
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

  # Ensure valid credentials, either by restoring from the saved credentials
  # files or intitiating an OAuth2 authorization. If authorization is required,
  # the user's default browser will be launched to approve the request.
  #
  # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
  def authorize
    FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

    client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      url = authorizer.get_authorization_url(
        base_url: OOB_URI)
      puts "Open the following URL in the browser and enter the " +
           "resulting code after authorization"
      puts url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI)
    end
    credentials
  end
end 

game_config = YAML.load(ERB.new(File.read("#{options[:match]}.yml")).result)
read_team = ReadTeam.new(game_config.deep_symbolize_keys[:game])

# game_config['vineeth']['our_team']['players'] = "#{read_team.vineeth_team.our_team.join(', ')}"
# game_config['vineeth']['opposing_team']['players'] = "#{read_team.vineeth_team.opponent_team.join(', ')}"
# File.open("#{options[:match]}.yml", 'w') { |file| file.write game_config.to_yaml }

game_config['vinay']['our_team']['players'] = "#{read_team.vinay_team.our_team.join(', ')}"
game_config['vinay']['opposing_team']['players'] = "#{read_team.vinay_team.opponent_team.join(', ')}"
File.open("#{options[:match]}.yml", 'w') { |file| file.write game_config.to_yaml }

# game_config['sai']['our_team']['players'] = "#{read_team.sai_team.our_team.join(', ')}"
# game_config['sai']['opposing_team']['players'] = "#{read_team.sai_team.opponent_team.join(', ')}"
# File.open("#{options[:match]}.yml", 'w') { |file| file.write game_config.to_yaml }

game_config['uday']['our_team']['players'] = "#{read_team.uday_team.our_team.join(', ')}"
game_config['uday']['opposing_team']['players'] = "#{read_team.uday_team.opponent_team.join(', ')}"
File.open("#{options[:match]}.yml", 'w') { |file| file.write game_config.to_yaml }
