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

helpers do
  def toutf8(str)
    NKF.nkf('-w', str) 
  end
end

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
  if params[:date] && params[:time_range] && params[:tv_station]
    '引数あったら検索結果だよ'
    "#{params[:date]} #{params[:time_range]} #{params[:tv_station]}"

    url = "http://www.tvais.jp/tvpg_search.php?tv_station=#{params[:tv_station]}&tele_day=#{params[:date]}&time_zone=#{params[:time_range]}"
    doc = Hpricot(open(url))
    toutf8(doc.at('title').inner_text)
  else
    # :dateと:time_rangeは必須だよ
    '引数なかったら検索フォームだよ'
    erb :search
  end
end

Sinatra::Application.run
