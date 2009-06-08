#!/home/realtimemachine/local/ruby/bin/ruby 
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
  erb :search
end

get '/result' do
  return if !params[:date] || !params[:time_range] || !params[:tv_station]

  url = "http://www.tvais.jp/tvpg_search.php?tv_station=#{params[:tv_station]}&tele_day=#{params[:date]}&time_zone=#{params[:time_range]}"
  doc = Hpricot(NKF.nkf('-w', open(url).read))

  @a_line_letters = (doc/'div.pa_t10 table strong').map{|tag| tag.inner_text}
  @letters = (doc/'div.pa_t20 table td.txt14_b').map{|tag| tag.inner_text}
  @programs = doc/'div.pa_t20 table table'

  erb :result
end

get '/category/:id' do 
  doc = Hpricot(open("http://www.tvais.jp/cate_top.php?cate_id=#{params[:id]}"))
end

get '/tv/:tv_id' do
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
