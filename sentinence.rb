require 'sinatra'
require 'data_mapper'

configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
end

configure :production do
  require 'newrelic_rpm'
  DataMapper.setup(:default, ENV['HEROKU_POSTGRESQL_AQUA_URL'])
end

class WordPair
  include DataMapper::Resource
  property :current,    String, :key => true
  property :next,     String, :key => true
  property :frequency,  Integer,:default => 1
  property :starter,    Boolean,:default => false
  property :nextIsStarter, Boolean,:default => false
  property :ender, Boolean, :default => false
end

DataMapper.finalize
DataMapper.auto_upgrade!

class Sentinence
  def preprocess(f)
    punctuation = [".", ",", ":", ";", "!", "?", "—"]
    punctuation.each do |p|
      f = f.gsub(p, " " + p)
    end

    eliminate = ["(", ")", "<", ">", "[", "]", "~", "\""]
    eliminate.each do |e|
      f = f.gsub(e, "")
    end
    return f
  end

  # parse grabs relevant data about word pairs occuring in file.
  # for each word pair, it inserts/updates a corresponding row in db.
  def process(fileName)
    WordPair.destroy

    f = File.read(fileName)
    f = preprocess(f)

    parsed = f.split(/[\s]+/)
    currentWord = nil
    nextWord = nil

    parsed.each do |word|
      nextIsStarter = false
      ender = false
      nextWord = word[/[\w][\w’'-`]*[\w]|[\w]/]
      if nextWord == nil
        nextWord = word[/[.,:;!?]/]
        if /[.!?]/.match(nextWord)
          ender = true
        end
      elsif /^[A-Z]/.match(nextWord)
        nextIsStarter = true
      end

      if (currentWord != nil) # not the first word 
        starter = 'A' <= currentWord[0] && currentWord[0] <= 'Z'
        if (nextWord != nil)
          dbPair = WordPair.get(currentWord, nextWord)
          if (dbPair == nil) # this pair is new
            dbPair = WordPair.create(:current => currentWord, :next => nextWord, :starter => starter, :nextIsStarter => nextIsStarter, :ender => ender)
          else # we have this pair stored
            newFreq = dbPair.frequency + 1
            dbPair.update(:frequency => newFreq)
          end
        end
      end
      currentWord = nextWord
    end
  end

  def buildSentence
    pairs = WordPair.all
    
    # query for a start word
    candidates = WordPair.all(:starter => true, :ender => false, :nextIsStarter => false)
    n = 0
    min = 1
    max = 32
    doc = []
    word = nil

    # up to MIN times, choose links
    loop do
      if n > 0

      end

      rouletteTotal = 0

      candidates.each do |c|
        rouletteTotal += c.frequency
      end

      # roulette for next link
      r = rand(rouletteTotal)

      candidates.each do |c|
        if (r - c.frequency >= 0)
          r -= c.frequency
        else
          word = c
          doc.push(word.current)
          n += 1
          break
        end
      end

      candidates = WordPair.all(:current => word.next, :nextIsStarter => false)
      puts word.current + " " + word.next

      if n >= max
        tempCandidates = candidates.all(:ender => true)
        if tempCandidates.length != 0
          candidates = tempCandidates
        end
      end

      if n > min && word.ender
        doc.push(word.next)
        break
      elsif candidates.length == 0
        doc.push("...")
        puts "... " + n.to_s
        break
      end
    end

    sentence = ""
    doc.each do |w|
      if /[.,:;!?]/.match(w)
        sentence += w
      else 
        sentence += " " + w
      end
    end

    return sentence
  end
end