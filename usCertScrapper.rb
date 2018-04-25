require 'mechanize'
require 'nokogiri'

CERTBASE = "https://www.us-cert.gov".freeze

$mechanize = Mechanize.new

def getBulletinList()
  res = []
  botelines = $mechanize.get("#{CERTBASE}/ncas/bulletins")
  doc = Nokogiri::HTML(botelines.body)
  table = doc.xpath("//div[@class='item-list']")
  items = table.css('li')
  items.each do |bulletin|
    begin
      print(["#{bulletin.css('a').text}", "#{bulletin.css('a')[0]["href"]}"])
      res.push(["#{bulletin.css('a').text}", "#{bulletin.css('a')[0]["href"]}"])
    rescue
      print("")
    end
  end
  return res
end
  
  
