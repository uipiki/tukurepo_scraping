# Yummyなレシピの名前とurlとつくれぽ件数情報を扱うクラス
class YummyRecipe
  def initialize(name, url)
    @name = name
    @url = url
  end

  def get_data
    return @name + "," + @url
  end
  
  def echo_data
    puts getData
  end
end