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
  redirect "/icookpad/search/#{URI.escape(params[:word])}" if params[:word]
  recirect '/icookpad/'
end

Sinatra::Application.run
