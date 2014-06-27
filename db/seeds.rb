require 'CSV'
require 'iso_country_codes'
require 'money'
require 'Nokogiri'


english = Language.create(name: "English")
spanish = Language.create(name: "Spanish")
french = Language.create(name: "French")

usa = Country.create(name: "USA", language_id: english.id)
spain = Country.create(name: "Spain", language_id: spanish.id)
france = Country.create(name: "France", language_id: french.id)

Phrase.create(language_id: english.id, hello: "hello", please: "please", thanks: "thanks", bathroom: "Where is the bathroom?")
Phrase.create(language_id: spanish.id, hello: "hola", please: "por favor", thanks: "gracias", bathroom: "Ou est trouvent les toilettes?")
Phrase.create(language_id: french.id, hello: "bonjour", please: "s'il vous plait", thanks: "merci", bathroom: "Donde esta el bano?")

Image.create(country_id: english.id, url: "http://www.scti.com.au/media/1059/travel-insurance-for-usa.jpg")
Image.create(country_id: english.id, url: "http://www.itesolcourse.com/images/location/usa-travel.jpg")
Image.create(country_id: english.id, url: "http://www.foley.com/files/Office/8766eedf-e4b8-42fe-9c37-4f8383686c0d/Presentation/OfficePhoto/washingtondc.jpg")
Image.create(country_id: english.id, url: "http://upload.wikimedia.org/wikipedia/commons/thumb/d/da/SF_From_Marin_Highlands3.jpg/1280px-SF_From_Marin_Highlands3.jpg")

Image.create(country_id: spain.id, url: "https://www.tripextras.com/files/countries/spain_basilicadelpilar.jpg")
Image.create(country_id: spain.id, url: "http://www.fodors.com/world/images/destinations/668/spain.jpg")
Image.create(country_id: spain.id, url: "http://www.fantom-xp.com/wallpapers/63/Travel_Spain.jpg")
Image.create(country_id: spain.id, url: "http://www.survivalspain.com/img/spain-travel-guide-homepage.jpg")

Image.create(country_id: france.id, url: "http://www.wallcoo.net/human/france/images/%5Bwallcoo%5D_france_travel_france_EF004.jpg")
Image.create(country_id: france.id, url: "http://traveldealslady.com/wp-content/uploads/Paris-France-travel-tour-traveltours-travel-agent-deals.jpg")
Image.create(country_id: france.id, url: "http://www.francetravelguide.com/files/2011/11/3952987239_3b29d282b5_z.jpg")
Image.create(country_id: france.id, url: "http://www.fodors.com/world/images/destinations/231/ile-de-france.jpg")

poli_ratings = []
data = File.open('db/politicalstability.csv')
CSV.foreach(data) do |row|
	poli_ratings << [row[0],row[1].gsub(/\t/,'').to_f]
end

fx = OpenExchangeRates::Rates.new

###fetch currency code by country name using Iso Country Codes gem
p currency_code = IsoCountryCodes.search_by_name('australia').first.currency
###fetch name of currency for given currency code using Money gem
p currency = Money.new(1000,currency_code).currency.name
###fetch exchange rate for USD to any currency using Open Exchange Rates gem
p fx.exchange_rate(:from => "USD", :to => currency_code) # => 0.808996

require 'net/http'
require 'rexml/document'

url = 'http://travel.state.gov/_res/rss/TAs.xml'

require 'open-uri'
require 'net/http'

# Build the feed's URI
uri = URI.parse(url);

begin
  response = Net::HTTP.get_response(uri);
  if response.code != "200"
    raise
  end
rescue
  puts "Failed to request Twitter feed."
  exit 1
end

begin
	response.body
  xmlDoc = REXML::Document.new(response.body)
rescue
  puts "Received invalid XML."
  exit 1
end

p xmlDoc
# Parse the data and print it in a friendly way.
xmlDoc.elements.each("/channel/link") do |element| 
    p element.attributes["description"]
end