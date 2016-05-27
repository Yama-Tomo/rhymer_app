class ApplicationController < ActionController::Base
  protect_from_forgery

  require 'net/http'
  require 'json'

  def index
    @text = nil

    if params[:id]
      share = Share.find(:first, :conditions => {:hash_id => params[:id]})
      if share != nil
        @text = share.content
      end
    end
  end

  def rhyme
    rhymer = Rhymer::Parser.new(params[:text])
    render :json => rhymer.rhymes
  end

  def random_text
    limit = 10
    if params[:limit].to_i > 0
      limit = params[:limit].to_i
    end

    url = 'https://ja.wikipedia.org/w/api.php?action=query&prop=info&format=json&list=random&rnnamespace=0&rnlimit=1'
    json = Net::HTTP.get_response(URI.parse(url)).body
    random_data_id = JSON.parse(json)['query']['random'][0]['id']

    url = 'https://ja.wikipedia.org/w/api.php?action=query&prop=revisions&rvprop=content&format=json&rvparse&pageids=' + random_data_id.to_s
    json = Net::HTTP.get_response(URI.parse(url)).body
    random_data_text = JSON.parse(json)['query']['pages'][random_data_id.to_s]['revisions'][0]['*']
    random_data_text = ActionController::Base.helpers.strip_tags(random_data_text).gsub!(/{{|}}|\[\[|\]\]|\n|&#.*?;|\[.*?\]/, ' ')

    result = []
    i = 0
    ignore_pattern  = '目次|この項目を加筆・訂正などしてくださる協力者を求めています|基本情報|'
    ignore_pattern += 'テンプレート|\^|この記事は|書きかけの項目です|信頼性向上にご協力ください|&gt;|&lt;'
    random_data_text.split('。').each do |sentence|
      next if (sentence =~ /#{ignore_pattern}/) != nil
#      next if sentence.index('この項目を加筆・訂正などしてくださる協力者を求めています') != nil
#      next if sentence.index('基本情報') != nil
#      next if sentence.index('テンプレート') != nil
#      next if sentence.index('^') != nil
#      next if sentence.index('この記事は') != nil
#      next if sentence.index('書きかけの項目です') != nil
#      next if sentence.index('信頼性向上にご協力ください') != nil

      result.push sentence

      i += 1
      if i >= limit
        break
      end
    end

    render :json => {:result => result.join('。')}
  end

  def share
    data = {}
    data[:hash_id] = Digest::MD5.hexdigest(rand().to_s + Time.now.to_i.to_s)
    data[:content] = params[:text]
    share = Share.new(data)
    share.save

    Thread.new do
      sleep 3
      # purge old records.
      Share.where(["created_at < ?", 3.days.ago]).delete_all
    end

    render :json => {:id => share.hash_id}
  end

end
