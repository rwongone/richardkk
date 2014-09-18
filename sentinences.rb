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
  property :punctuation,  Boolean,:default => false
end

DataMapper.finalize
DataMapper.auto_upgrade!

class Sentinences
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
    punct = false

    parsed.each do |word|
      punct = false
      nextWord = word[/[\w][\w’'-`]*[\w]|[\w]/]
      if (nextWord == nil)
        nextWord = word[/[.,:;!?]/]
        punct = true
      end

      if (currentWord != nil) # not the first word 
        starter = 'A' <= currentWord[0] && currentWord[0] <= 'Z'
        if (nextWord != nil)
          dbPair = WordPair.get(currentWord, nextWord)
          if (dbPair == nil) # this pair is new
            dbPair = WordPair.create(:current => currentWord, :next => nextWord, :starter => starter, :punctuation => punct)
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
    candidates = WordPair.all(:starter => true)
    n = 0
    ohGod = 0
    min = 10
    max = 100
    doc = []
    word = nil
    # do

    loop do
      rouletteTotal = 0

      candidates.each do |c|
        rouletteTotal += c.frequency
      end

      r = rand(rouletteTotal)

      candidates.each do |c|
        if (r - c.frequency >= 0)
          r -= c.frequency
        else
          word = c
          doc.push(word.current)
          puts word.current
          n += 1
          break;
        end
      end

      if (n < min)
        candidates = WordPair.all(:current => word.next).all(:punctuation => false)
      else 
        candidates = WordPair.all(:current => word.next)
      end

      if n > min && word.punctuation && !word.next[/[,;]/] || !candidates
        doc.push(word.next)
        break;
      elsif n > max || ohGod > 10 * max
        doc.push("...")
        break;
      end
      ohGod += 1
    end

    sentence = ""
    doc.each do |w|
      if /[.,:;!?]/.match(w)
        sentence += w
      else 
        sentence += " " + w
      end
    end

    # up to MIN times, choose links

    # roulette for next link

    # after MIN times, take first word with punctuation which is not "," or ";" and end the sentence


  end
end