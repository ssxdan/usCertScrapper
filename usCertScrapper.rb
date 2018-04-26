require 'mechanize'
require 'nokogiri'
require 'erb'

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
      #print(["#{bulletin.css('a').text}", "#{bulletin.css('a')[0]["href"]}"])
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

def arrayToCSV(array, ruta)
  # Primary_Vendor_Product;Description;Published;CVSS_Score;Source_and_Patch_Info
	line = ERB.new %q{<%= row[0] %>|<%= row[1] %>|<%= row[2] %>|<%= row[3] %>|<%= row[4].match(/CVE-[0-9]+-[0-9]+/)[0] %>}
	csv = File.open(ruta,"w:UTF-8")
  csv.puts("Primary_Vendor_Product|Description|Published|CVSS_Score|Source_and_Patch_Info")
  array.each do |row|
    begin
      #print("#{line.result(binding)}\n")
      csv.puts(line.result(binding))
    rescue
      print("")
    end
  end
	csv.close
end

def cuatroUltimosACSV()
  boletines = getBulletinList()
  (0..3).each do |n|
    boletin = bulletinToArray("#{boletines[n][1]}")
    arrayToCSV(boletin,"#{boletines[n][1].split("/").last}.csv")
    #print(boletin)
  end
end

cuatroUltimosACSV()
