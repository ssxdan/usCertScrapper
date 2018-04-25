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

def bulletinToArray(bulletinURL)
  boletin = $mechanize.get("#{CERTBASE}#{bulletinURL}")
  doc = Nokogiri::HTML(boletin.body)
  res = []
  for severity in ['High Vulnerabilities', 'Medium Vulnerabilities', 'Low Vulnerabilities', 'Severity Not Yet Assigned']
    table = doc.xpath("//table[@summary='#{severity}']")
    rows = table.css('tr')
    text_all_rows = rows.map do |row|
        row_values = row.css('td').map(&:text)
    end
    text_all_rows.delete_at(0)
    text_all_rows.each { |td| res.push(td)}
  end
  return res
end
