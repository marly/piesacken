require 'rbot/plugins'
require 'open-uri'

# Piesack your friends
#
# The word piesack is derived from the German verb 'piesacken'. Read more here:
#     http://en.wiktionary.org/wiki/piesacken
#

class Piesack < Plugin
  
  def initialize(*a)
    super

    # Where to find insults       
    @insult_url = "http://www.randominsults.net"

  end
  
  def help(plugin, topic="")
    case plugin
    when "piesack"
      "piesack <nick>: taunt a user and ignore his commands. Related: piesacklist, reconcile"
    when "piesacklist"
      "piesacklist: list piesacked nicks"
    when "reconcile"
      "reconcile <nick>: stop piesacking a user"
    end
  end
    
  # Listen for messages from piesacked nicks
  def listen(m)
    nicks = @registry[:piesacken] || Array.new
    return unless m.address? and nicks.include?(m.sourcenick)    
    
    @bot.say m.replyto, "#{m.sourcenick}, #{insult}"
    m.ignored = true
  end
    
  # Put a nick on the bad list
  def piesack(m, params)
    
    ignored = @registry[:piesacken] || Array.new
    nick = params[:nick]
    
    ignored << nick unless ignored.include? nick
    @registry[:piesacken] = ignored
    
    m.okay
  end
  
  # Make up
  def reconcile(m, params)
    ignored = @registry[:piesacken] || Array.new
    @registry[:piesacken] = ignored.reject { |n| n == params[:nick] }
    m.okay
  end
  
  # Scrape a random insult
  def insult
    begin
      open(@insult_url) do |f| 
        f.read.match(/<strong><i>(.*)<\/i><\/strong>/)[1]
      end
    rescue Exception => e
      # It will get boring if something goes wrong.
      "You think you're pretty smart, don't you?"
    end
  end
  
  # List piesacked nicks
  def list(m, params)
    piesacked = @registry[:piesacken]
    
    if piesacked and not piesacked.empty?
      m.reply "Piesacked nicks: " + piesacked.join(', ')
    else
      m.reply "No one to piesack. To add someone: piesack <nick>"
    end
  
  end
  
end

plugin = Piesack.new
plugin.map! 'piesack :nick'
plugin.map! 'piesacklist', :action => :list
plugin.map! 'reconcile :nick'
