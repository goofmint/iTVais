# -*- coding: utf-8 -*-

require 'rubygems'
require 'sinatra'
require 'cgi'
require 'uri'
require 'erb'
require 'hpricot'
require 'open-uri'
require 'nkf'
require 'lib/jstrftime'
require 'lib/helpers'

get '/' do
  url = "http://www.tvais.jp/"
  doc = Hpricot(open(url))
  @title = "TVais（テレビアイズ）"
  @categories = doc.search('ul#t_menu li a')
  new_tv_doc = Hpricot(doc.html.gsub(/.*<td class=\"new_list\"/m, "").gsub(/<div style="padding-top: 10px;">.*/m, ""))
  @new_tvs = new_tv_doc.search("table div")
  @new_lists = doc.search("div.co_both")
  # @wadai_recipe = doc.css('div#wadai-recipe-inner ul li span.recipe-title a')
  erb :index
end

get '/search' do
  @leftnav = '<a href="/"><img alt="home" src="/images/home.png" /></a>'
  erb :search
end

get '/result' do
  @leftnav = '<a href="/"><img alt="home" src="/images/home.png" /></a>'
  return if !params[:date] || !params[:time_range] || !params[:tv_station]
  url = "http://www.tvais.jp/tvpg_search.php?tv_station=#{params[:tv_station]}&tele_day=#{params[:date]}&time_zone=#{params[:time_range]}"
  doc = Hpricot(NKF.nkf('-w', open(url).read))
  @title = doc.at(:title).inner_html.gsub("&nbsp;-&nbsp;TVais（テレビアイズ）", "") # 検索結果
  @a_line_letters = (doc/'div.pa_t10 table strong').map{|tag| tag.inner_text}
  @letters = (doc/'div.pa_t20 table td.txt14_b').map{|tag| tag.inner_text}
  @programs = doc/'div.pa_t20 table table'

  erb :result
end

get '/category/:id' do
  url = "http://www.tvais.jp/cate_top.php?cate_id=#{params[:id]}"
  doc = Hpricot(NKF.nkf('-w', open(url).read))
  @leftnav = '<a href="/"><img alt="home" src="/images/home.png" /></a>'
  @title = doc.search("div#main_frame table td")[0].inner_html
  @newest = { :date => doc.at("td.pa_t10").at("span.txt14_b").inner_html.gsub("&nbsp;", ""),
    :tv_id => doc.at("td.pa_t10").at("a.txt14_b")[:href].match(/.*tv_id=([0-9]*?)$/)[1],
    :tv_title => doc.at("td.pa_t10").at("a.txt14_b").inner_text,
    :tv_station => doc.at("td.pa_t10").search("a.txt14_b")[1][:href].match(/.*tv_station=([0-9]*).*/)[1],
    :tele_day => doc.at("td.pa_t10").search("a.txt14_b")[1][:href].match(/.*tele_day=([0-9]*).*/)[1],
    :time_zone => doc.at("td.pa_t10").search("a.txt14_b")[1][:href].match(/.*time_zone=([0-9]*).*/)[1],
    :tv_station_name => doc.at("td.pa_t10").search("a.txt14_b")[1].inner_text,
    :corner => doc.at("td.pa_t5").inner_text,
    :img => doc.search("div.pa_t10 table")[2].at("table").at("img")[:src],
    :width => doc.search("div.pa_t10 table")[2].at("table").at("img")[:width],
    :title => doc.search("div.pa_t10 table")[2].at("table").at(".txt14_b").inner_text,
    :actors => doc.search("td.pa_t5[text()*='出演'] a"),
    :description => doc.at("div.pa_t5").inner_text
  }
  list_doc = Hpricot(doc.to_html.gsub(/.*<!--今日のトピックス 開始-->/m, "").gsub(/<!--メインコンテンツ終了-->.*/m, ""))
  @date_list = []
  old_title = ""
  list_doc.search("div.cle").each_with_index { |date, i|
    date = { :date => date.at("table table td").inner_text, :shows => []}
    list_doc.search("div.pa_t10")[i].search("table").each do |shows|
      next if shows.at("td.pa_l5 a").inner_text == old_title
      old_title = shows.at("td.pa_l5 a").inner_text
      ary = {
        :title => shows.at("td.pa_l5 a").inner_text.gsub("「", "").gsub("」", ""),
        :i_id  => shows.at("td.pa_l5 a")[:href].match(/i_id=([0-9]*)/)[1],
        :tv_id => shows.at("td.pa_l5 a")[:href].match(/tv_id=([0-9]*)/)[1],
        :tv_title => shows.search("td.pa_l5 a")[1].inner_text,
        :tv_station_name => shows.search("td.pa_l5 a")[2].inner_text,
        :tv_station => shows.search("td.pa_l5 a")[2][:href].match(/tv_station=([0-9]*)/)[1],
        :tele_day => shows.search("td.pa_l5 a")[2][:href].match(/tele_day=([0-9]*)/)[1],
        :time_zone => shows.search("td.pa_l5 a")[2][:href].match(/time_zone=([0-9]*)/)[1],
        :description => shows.search("td.pa_t5").inner_text
      }
      date[:shows] << ary
    end
    @date_list << date
    date = {}
  }
  erb :category
end

get '/tv/:tv_id' do
  @leftnav = '<a href="/"><img alt="home" src="/images/home.png" /></a>'
  return if !params[:tv_id]

  if params[:tv_id] =~ /^t-/
    # t_id対策 なんでか元サイトのリンクがtv_idではなくt_idになる場合がある
    params[:tv_id] = params[:tv_id].split('-').last
    url = "http://www.tvais.jp/tv_dte.php?t_id=#{params[:tv_id]}"
  else
    url = "http://www.tvais.jp/tv_dte.php?tv_id=#{params[:tv_id]}"
  end

  doc = Hpricot(NKF.nkf('-w', open(url).read))

  @tv_title = doc.at(:title).inner_text # 番組名

  # その他？# トピック# 出演# キャラクター# ゲスト
  @summary = [
    ["その他", doc.at("div.txt10[text()*='【その他】']")],
    ["トピック", doc.at("div.txt10[text()*='【トピック】']")],
    ["出演", doc.at("div.txt10[text()*='【出演】']")],
    ["キャラクター", doc.at("div.txt10[text()*='【キャラクター】']")],
    ["ゲスト", doc.at("div.txt10[text()*='【ゲスト】']")],
  ]

  # 番組構成
  @parts = doc/"div[@id^='contOP_']"

  #   紹介された商品へのリンク
  # 前回へのリンク又は次回へのリンク（あれば）
  @prev = doc/"td.pa_5[text()*='前回']"
  @next = doc/"td.pa_5[text()*='次回']"

  erb :tv
end

get '/item/:item_id/:tv_id' do
  @leftnav = '<a href="/"><img alt="home" src="/images/home.png" /></a>'
  return if !params[:tv_id] || !params[:item_id]

  url = "http://www.tvais.jp/item_dte.php?i_id=#{params[:item_id]}&tv_id=#{params[:tv_id]}"
  doc = Hpricot(NKF.nkf('-w', open(url).read))

  # カテゴリ
  @category = doc.at("div#main_frame").at(:table).inner_text.strip

  # 番組情報
  @tv = doc.at("div#main_frame").at("td.pa_t10")
  (@tv/:a).first[:href] = "/tv/#{(@tv/:a).first[:href].slice(/tv_id=(\d+)/, 1)}" # 番組へのリンク 
  (@tv/:a).last[:href] = "/result?tv_station=#{(@tv/:a).last[:href].slice(/tv_station=(\d+)/, 1)}&date=14&time_range=0" # 局へのリンク
  @part = doc.at("div#main_frame").at("td.pa_t5").inner_text

  # 商品情報
  section =  doc.at("div#main_frame").at("td.pa_l20")
  @item = {
    :image_url => doc.at("div#main_frame").at(:img)[:src],
    :name => section.at("div.txt14_b").inner_text,
    :info => section.at("div.pa_t5"),
    :link => section.at("td.pa_l5")
  }

  @item[:image_url] = 'http://www.tvais.jp/img/no_image.gif' if @item[:image_url] == './img/no_image.gif'

  erb :item
end

Sinatra::Application.run
