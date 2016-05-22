require 'nokogiri'
require 'json'
require 'open-uri'

PAGES = 34
URL_BASE = "http://flamingfreedom.com"
CSS = '.powerpress_link_d'
EPISODES_DIR = "#{File.dirname(File.realpath(__FILE__))}/episodes"

class Episode < Struct.new :filename, :url; end

def get_page_links page_number
  doc = Nokogiri::HTML(open "#{URL_BASE}/page/#{page_number}")
  doc.css(CSS).map {|item| item['href'] }
end

def get_all_page_links
  threads = []
  links = []

  (1..34).each do |i|
    thread = Thread.new do
      page_links = get_page_links i
      page_links.each do |link|
        links.push link
      end
    end
    threads << thread
  end

  threads.each(&:join)
  return links
end

def get_episodes 
  Array.new.tap do |episodes| 
    page_links = get_all_page_links
    page_links.each do |link|
      episodes << Episode.new(link.split("/")[-1], link)
    end
  end
end

def episode_downloaded? episode
  File.exists? "#{EPISODES_DIR}/#{episode.filename}"
end

def download_episode episode
  open "#{EPISODES_DIR}/#{episode.filename}", "wb" do |file|
    open episode.url do |uri|
       file.write(uri.read)
    end
  end 
end

get_episodes.each do |episode|
  if episode_downloaded? episode
    puts "episode #{episode.filename} already downloaded"
  else
    puts "downloading episode #{episode.filename}"
    begin
      download_episode episode
    rescue => error
      puts "error downloading episode #{episode.filename} from #{episode.url}"
      File.delete "#{EPISODES_DIR}/#{episode.filename}"
    end
  end
end

