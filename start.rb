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

Sinatra::Application.run
