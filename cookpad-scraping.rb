require 'open-uri'
require 'nokogiri'
require 'uri'
require 'logger'
require 'optparse'
load './yummy-recipe.rb'

$BASE_URL = "https://cookpad.com"
$CHARSET = nil
$log = Logger.new(STDOUT)
$log.level = Logger::INFO

# パラメータの解析を行う
# @param [Hash]
def read_param(params)
  if params["d"] then
    $log.level = Logger::DEBUG
  end
  $limit = params["limit"].to_i
  $konbannoMenu = params["menu"]
  $konbannoMenuUTF8 = URI.encode_www_form_component($konbannoMenu)
  $condCount = params["cond"].to_i
  $konbannoUrl = $BASE_URL + "/search/" + $konbannoMenuUTF8
end

# 引数のurlをDocumentにして返す
# @param [String] url 
# @return [Document] document
def get_document(url) 
  html = open(url) do |f|
    charset = f.charset
    f.read
  end
  return Nokogiri::HTML.parse(html, nil, $CHARSET)
end

# どこまで検索するかのindexを返す
# @param [String] url 
# @return [Integer] どこまで検索するかのindexを返す
def search_to_index(konbannoUrl)
  maxIndex = get_max_page_index(get_document(konbannoUrl))
  if maxIndex > $limit
    return $limit
  end
  return maxIndex
end 

# 検索する対象のページ総数を取得
# @param [Document] menuDoc 
# @return [Integer] 検索結果リストの最終ページの数字
def get_max_page_index(menuDoc) 
  innerText = menuDoc.xpath("//div[@class='paginator']").css('span').inner_text
  return innerText.split('/')[1].delete!(",|\n| ").to_i
end

# つくれぽの件数をレシピのurlから取得
# @param [String] recipeUrl レシピのurl 
# @return [Integer] つくれぽ数 
def get_tsukurepo_count(recipeUrl)
  recipeDoc = get_document(recipeUrl)
  return extract_tsukurepo_kensu(recipeDoc).delete!("件|\n|(|)").to_i
end

# つくれぽの件数をレシピのdocumentから抽出
# @param [Document] doc レシピのhtmlのdocument Object 
# @return [String] つくれぽの件数 > "\n(x件)\n"形式で出力 
def extract_tsukurepo_kensu(doc)
  return doc.xpath("//li[@id='tsukurepo_tab']").css('span').inner_text
end

# Yummyなmenuのリストの作成
# @param [String] url
# @return [List[YummyRecipe]]
def get_yummy_recipes(url) 
  return get_document(url).xpath("//div[@class='recipe-text']").select { | recipe | 
    href = recipe.css('a').attribute('href').value
    recipeUrl = $BASE_URL + href
    $log.debug(get_tsukurepo_count(recipeUrl))
    get_tsukurepo_count(recipeUrl) > $condCount
  }.map { | recipe |
    return get_recipe_info(recipe)
  }
end

# NodeSetからrecipeの情報を返す
# @param [NodeSet] recipe
# @return [YummyRecipe] 
def get_recipe_info(recipeNode) 
  recipeName = recipeNode.css('a').inner_text 
  $log.debug(recipeName)
  href = recipeNode.css('a').attribute('href').value
  recipeUrl = $BASE_URL + href
  return YummyRecipe.new(recipeName, recipeUrl)
end

# 引数の読み込みと結果ファイルを作成を行う
def init() 
  read_param(ARGV.getopts("d","menu:カレー","cond:10","limit:100"))
  $yummyFile= File.open(Dir.pwd + '/' + $konbannoMenu + "-yummy.txt",'a')
end

# yummyなリストを作成しまっせ
def generate_yummy_list()
  yummys = (1..search_to_index($konbannoUrl)).map { | index |
    $log.debug("index : " + index.to_s + " scraping start .....")
    indexedUrl = $konbannoUrl + '?&page=' + index.to_s
    get_yummy_recipes(indexedUrl)
  }
  yummys.flatten.each { | yummy |
    $yummyFile.puts yummy.get_data
  }
end

init
generate_yummy_list

