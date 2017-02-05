require 'net/http'
require 'open-uri'
require 'nokogiri'
require 'csv'


jobtitles = []
locations = []
companies = []
urls = []
jobs = []

puts "Enter prefered locations in the following format: {city, state abbreviation}, separated with semicolons. For example: San Diego, CA; Los Angeles, CA"
prefered_locations = gets.chomp.split(";")
#prefered_locations = ['Dallas, TX', 'Plano, TX', 'Frisco, TX', 'Richardson, TX', 'Addison, TX', 'McKinney, TX']

puts "Enter prefered positions, separated with commas. For example: SEO Manager, Data Analyst"
prefered_positions = gets.chomp.split(";")

#prefered_positions = ['java', 'architect']
combos = prefered_positions.product(prefered_locations)


def find_fantastic_job(title, location)  # san%20diego%2C+ca 

  title = title.gsub(' ','%20')
  location = location.gsub(', ', '%2C+').gsub(' ', '%20')

  @page_url = "http://api.indeed.com/ads/apisearch?publisher=xxxxxxxxxxxx&q=#{title}&l=#{location}&sort=&radius=50&st=&jt=fulltime&start=&limit=100&fromage=&filter=&latlong=1&co=us&chnl=&userip=1.2.3.4&useragent=Mozilla/%2F4.0%28Firefox%29&v=2"


  url = URI.parse(@page_url)
  req = Net::HTTP::Get.new(url.to_s, {'User-Agent' => 'Japookar'})
  res = Net::HTTP.start(url.host, url.port) {|http| http.request(req)}
  #puts res.body
  return res.body

end

combos.each do |combo|

  @doc = Nokogiri::XML(find_fantastic_job(combo[0], combo[1]))

  @doc.xpath("//jobtitle").each {|x| jobtitles << x.text}
  @doc.xpath("//formattedLocation").each {|x| locations << x.text}
  @doc.xpath("//company").each {|x| companies << x.text}
  @doc.xpath("//url").each {|x| urls << x.text}


end

jobs = jobtitles.zip(locations, companies, urls).compact


CSV.open("jobs.csv", "w") do |csv|
  csv << ["Job Title", "Location", "Company", "URL"]
  jobs.each do |job|
    csv << [job[0], job[1], job[2], job[3]]
    #if job[0].include? "Director" 
     #csv << [job[0], job[1], job[2], job[3]]
    #elsif job[0].include? "Growth" 
     #csv << [job[0], job[1], job[2], job[3]]
    #elsif job[0].include? "SEO Director" 
     #csv << [job[0], job[1], job[2], job[3]]
    #elsif job[0].include? "Head of Growth" 
     #csv << [job[0], job[1], job[2], job[3]]
    #elsif job[0].include? "Director of Online" 
     #csv << [job[0], job[1], job[2], job[3]]
   

    #end
  end  
  
end

puts "Completed, check the file jobs.csv."
