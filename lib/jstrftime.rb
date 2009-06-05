require 'date'
# 曜日の名称・午前午後を日本語にするためのモジュール
module JStrftime
  JAPANESE = {"Sunday"=>"日", "Monday"=>"月", "Tuesday"=>"火", "Wednesday"=>"水",
    "Thursday"=>"木", "Friday"=>"金", "Saturday"=>"土", "AM"=>"午前", "PM"=>"午後"}
# 置換すべき英語名のどれかに一致する正規表現
  JAPANESE_RE = Regexp.union(*JAPANESE.keys)
# 英語を日本語に置き換える
  def jstrftime(fmt)  strftime(fmt).gsub(JAPANESE_RE){ JAPANESE[$&] }  end
end
# Time・Date・DateTimeクラスで使えるようにMix-inする
class Time; include JStrftime end
class Date; include JStrftime end
