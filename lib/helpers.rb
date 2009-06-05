helpers do
  def tv_station_options
    @options = ""
    tv_stations.each do |opt|
      @options += "<option value=\"#{opt[0]}\">#{opt[1]}</option>"
    end

    @options
  end

  def date_options
    @options = ""
    8.times do |i|
      day = (Time.now - i * 86400)
      @options += "<option value=\"#{day.strftime('%Y%m%d')}\">#{day.year}年#{day.month}月#{day.day}日（#{day.jstrftime('%A')}）</option>"
    end
    @options += "<option value=\"14\">過去14日間の放映</option>"

    @options
  end

  def time_range_options
    @options = ""
    time_ranges.each do |opt|
      @options += "<option value=\"#{opt[0]}\">#{opt[1]}</option>"
    end

    @options
  end

  def link_to_a_line(a_line_letter)
    "<a href=\"#l#{a_lines.invert[a_line_letter]}\">#{a_line_letter}</a>"
  end

  def id_for_a_line(letter)
    "id=\"l#{a_lines.invert[letter]}\"" if a_lines.invert[letter]
  end

  def a_lines
    {
      1 => 'ア',
      2 => 'カ',
      3 => 'サ',
      4 => 'タ',
      5 => 'ナ',
      6 => 'ハ',
      7 => 'マ',
      8 => 'ヤ',
      9 => 'ラ',
      10 => 'ワ'
    }
  end
end

# マスタ
def tv_stations
  # 順番を維持するためにハッシュではなく配列
  [ 
    ["", "局をえらぶ"],
    ["200", "NHK総合"],
    ["94", "日本テレビ"],
    ["77", "TBS"],
    ["105", "フジテレビ"],
    ["51", "テレビ朝日"],
    ["65", "テレビ東京"],
  ]
end

def time_ranges
  [
    ["0", "全ての時間帯"],
    ["1", "5:00〜12:00"],
    ["2", "12:00〜19:00"],
    ["3", "19:00〜23:00"],
    ["4", "23:00〜5:00]"],
  ]
end
