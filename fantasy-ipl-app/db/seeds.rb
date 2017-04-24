# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#

rps_players = 'AM Rahane, BA Stokes, AB Dinda, RA Tripathi, A Zampa, MA Agarwal, MS Dhoni, R Bhatia, DL Chahar, Imran Tahir, F du Plessis, LH Ferguson, RD Chahar, SN Thakur, MK Tiwary, Ankit Sharma'
dd_players = 'A Tare, SW Billings, KK Nair, CJ Anderson, Z Khan, S Nadeem, SV Samson, RR Pant, CH Morris, A Mishra, PJ Cummins, SS Iyer, J Yadav, AD Mathews'
punjab_players = 'GJ Maxwell, M Vohra, DA Miller, MM Sharma, VR Aaron, Vishnu Vinod, HM Amla, AR Patel, WP Saha, MP Stoinis, Sandeep Sharma'
rcb_players = 'SR Watson, AB de Villiers, Mandeep Singh, TS Mills, YS Chahal, KM Jadhav, B Stanlake, P Negi, STR Binny, Iqbal Abdulla, T Natarajan'
mi_players = 'JC Buttler, KA Pollard, HH Pandya, JJ Bumrah, PA Patel, RG Sharma, KH Pandya, MJ McClenaghan, SL Malinga, Harbhajan Singh, N Rana'
kkr_players = 'MK Pandey, YK Pathan, SA Yadav, SP Narine, Kuldeep Yadav, TA Boult, G Gambhir, RV Uthappa, CA Lynn, CR Woakes, AS Rajpoot'
gl_players = 'AJ Finch, KD Karthik, RA Jadeja, Ishan Kishan, P Kumar, DR Smith, BB McCullum, SK Raina, Basil Thampi, AJ Tye, SB Jakati'
srh_players = 'Rashid Khan, S Kaul, DA Warner, KS Williamson, Yuvraj Singh, NV Ojha, B Kumar, Mohammed Siraj, DJ Hooda, MC Henriques, S Dhawan'

all_teams = [kkr_players, punjab_players, srh_players, mi_players, rps_players, gl_players, dd_players, rcb_players]

(1..8).each do |team_id|
  players = all_teams[team_id-1]

  players.split(', ').each do |player|
    Player.create!(name: player, role: 0, team_id: team_id)
  end
end
