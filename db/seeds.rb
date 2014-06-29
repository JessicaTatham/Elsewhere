# require 'CSV'
require 'iso_country_codes'
require 'money'
require 'nokogiri'


def two_code(country_name)
	code = IsoCountryCodes.search_by_name(country_name).first.alpha2
end

def three_code(country_name)
	code = IsoCountryCodes.search_by_name(country_name).first.alpha3
end

def currency(country_name)
	currency_code = IsoCountryCodes.search_by_name(country_name).first.currency
	currency = Money.new(1000,currency_code).currency.name
end


["Aruba",
"Andorra",
"Afghanistan",
"Angola",
"Albania",
"United Arab Emirates",
"Argentina",
"Armenia",
"American Samoa",
"Antigua and Barbuda",
"Australia",
"Austria",
"Azerbaijan",
"Burundi",
"Belgium",
"Benin",
"Burkina Faso",
"Bangladesh",
"Bulgaria",
"Bahrain",
"Bahamas",
"Bosnia and Herzegovina",
"Belarus",
"Belize",
"Bermuda",
"Bolivia",
"Brazil",
"Barbados",
"Brunei Darussalam",
"Bhutan",
"Botswana",
"Central African Republic",
"Canada",
"Switzerland",
"Chile",
"China",
"Côte d'Ivoire",
"Cameroon",
"Congo",
"Colombia",
"Comoros",
"Cabo Verde",
"Costa Rica",
"Cuba",
"Curaçao",
"Cayman Islands",
"Cyprus",
"Czech Republic",
"Germany",
"Djibouti",
"Dominica",
"Denmark",
"Dominican Republic",
"Algeria",
"Ecuador",
"Egypt",
"Eritrea",
"Spain",
"Estonia",
"Ethiopia",
"Finland",
"Fiji",
"France",
"Faroe Islands",
"Micronesia, Federated States of",
"Gabon",
"United Kingdom",
"Georgia",
"Ghana",
"Guinea",
"Gambia",
"Guinea-Bissau",
"Equatorial Guinea",
"Greece",
"Grenada",
"Greenland",
"Guatemala",
"Guam",
"Guyana",
"Hong Kong",
"Honduras",
"Croatia",
"Haiti",
"Hungary",
"Indonesia",
"India",
"Ireland",
"Iran",
"Iraq",
"Iceland",
"Israel",
"Italy",
"Jamaica",
"Jordan",
"Japan",
"Kazakhstan",
"Kenya",
"Kyrgyzstan",
"Cambodia",
"Kiribati",
"Saint Kitts and Nevis",
"Korea, Rep.",
"Kuwait",
"Lao",
"Lebanon",
"Liberia",
"Libya",
"Saint Lucia",
"Liechtenstein",
"Sri Lanka",
"Lesotho",
"Lithuania",
"Luxembourg",
"Latvia",
"Saint Martin",
"Morocco",
"Monaco",
"Moldova",
"Madagascar",
"Maldives",
"Mexico",
"Marshall Islands",
"Macedonia",
"Mali",
"Malta",
"Myanmar",
"Montenegro",
"Mongolia",
"Northern Mariana Islands",
"Mozambique",
"Mauritania",
"Mauritius",
"Malawi",
"Malaysia",
"Namibia",
"New Caledonia",
"Niger",
"Nigeria",
"Nicaragua",
"Netherlands",
"Norway",
"Nepal",
"New Zealand",
"Oman",
"Pakistan",
"Panama",
"Peru",
"Philippines",
"Palau",
"Papua New Guinea",
"Poland",
"Puerto Rico",
"Korea",
"Portugal",
"Paraguay",
"French Polynesia",
"Qatar",
"Romania",
"Russian Federation",
"Rwanda",
"Saudi Arabia",
"Sudan",
"Senegal",
"Singapore",
"Solomon Islands",
"Sierra Leone",
"El Salvador",
"San Marino",
"Somalia",
"Serbia",
"South Sudan",
"Sao Tome and Principe",
"Suriname",
"Slovakia",
"Slovenia",
"Sweden",
"Swaziland",
"Sint Maarten",
"Seychelles",
"Syrian Arab Republic",
"Turks and Caicos Islands",
"Chad",
"Togo",
"Thailand",
"Tajikistan",
"Turkmenistan",
"Timor-Leste",
"Tonga",
"Trinidad and Tobago",
"Tunisia",
"Turkey",
"Tanzania",
"Uganda",
"Ukraine",
"Uruguay",
"United States",
"Uzbekistan",
"Saint Vincent and the Grenadines",
"Venezuela",
"Virgin Islands",
"Vietnam",
"Vanuatu",
"Samoa",
"Yemen",
"South Africa",
"Zambia",
"Zimbabwe"].each do |country|
  Country.create(name:country, two_character_code: two_code(country), three_character_code: three_code(country), currency: currency(country))
end


Country.all.each do |country|
	if country.name == "Korea, Rep."
		name = "South_Korea"
	elsif country.name == "Micronesia, Federated States of"
		name = "Federated_States_of_Micronesia"
	elsif country.name == "Brunei Darussalam"
		name = "Brunei"
	elsif country.name == "Côte d'Ivoire"
		name = "Ivory_Coast"
	elsif country.name == "Curaçao"
		name = "Curacao"
	elsif country.name == "Syrian Arab Republic"
		name = "Syria"
	else
		multiple = country.name.split(" ")
		if multiple.count > 1
			name = multiple.join("_")
		else
			name = multiple[0]
		end
	end
	p name
	p country.name
			doc = Nokogiri::XML(open('http://wikitravel.org/en/'+ name))
			intro =  doc.css('#mw-content-text table p:eq(2)')
			intro2 =  doc.css('#mw-content-text table p:eq(3)')
			intro.each do |i|
				i1 = i.content
			end
			intro2.each do |i|
				i2 = i.content
			end
		country.update(intro: '#{i1} #{i2}')
end


usa = Country.find_by(name: 'United States')
usa.update(common_name: 'United States of America')
russia = Country.find_by(name: 'Russian Federation')
russia.update(common_name:'Russia')


################ THIS SEEDS THE IMAGES ################ 
require 'flickr'
flickr = Flickr.new(ENV["FLICKR_KEY"])

Country.all.each do |country|	
	photos = flickr.photos_search(
		content_type: 1, 
		safe_search: 1, 
		tags: "#{country.name}, travel, beautiful",
		tag_mode: "all", 
		privacy_filter: 1, 
		sort: "interestingness-desc",
		media: "photos",
		)
	
	photos[0..3].each do |photo|
		country.images << Image.create(url: photo.source)
	end
end
