# coding: utf-8
require 'nokogiri'
require 'open-uri'
require "csv"

def main
  lives = getLives("http://pripara.jp/item/2015_4th.html")
  allItems = lives.map do |liveId, liveName|
    getItems(liveId, liveName)
  end
  writeAsCSV("all.csv", allItems.flatten(1))
end

def getLives(lastLiveUrl)
  html = Nokogiri::HTML(open(lastLiveUrl))
  links = html.css(".mainAreaL a").map do |link|
    liveId = link["class"]
    name = trim(link.text)
    [liveId, name]
  end
end

def getItems(liveId, liveName)
  puts liveId + "（" + liveName + "）のアイテム一覧を取得します"
  html = Nokogiri::HTML(open("http://pripara.jp/item/" + liveId + ".html"))
  itemsNode = html.css(".itemDateBlock")
  items = itemsNode.map do |item|
    itemId = ""
    if item.css(".itemName span").children.length == 1
      itemId = toHalf(trimStar(item.css(".itemName span").children[0].text))
    end
    itemName = item.css(".itemName h2").children.drop(2).map { |element| element.text }.join()
    thumbnailUrl = crateThumbnailUrl(item.css(".itemimg > img").first["src"])
    category = item.css("table").children[3].children[1].text
    type = item.css("table").children[3].children[3].text
    brand = determineBrand(item.css("table").children[3].children[5].children[0]["src"])
    rarity = item.css("table").children[7].children[1].text
    nice = item.css("table").children[7].children[3].text
    color = item.css("table").children[7].children[5].text

    trimed = [liveId, liveName, itemId, itemName, thumbnailUrl, category, type, brand, rarity, nice, color].map do |str|
      trim(str)
    end
    completeSecretCode(trimed)
  end
end

def completeSecretCode(codeData)
  case codeData[2]
  when "MR-003"
    return ["2015_2nd","まいにちプリパラ2015 2ndライブ","MR-003","ミステリーCAサイリウムワンピ","http://pripara.jp/item/image/secret.png","ワンピース","ポップ","CandyAlamode","MR",2290,"不明"]
  when "MR-004"
    return ["2015_2nd","まいにちプリパラ2015 2ndライブ","MR-004","ミステリーCAサイリウムシューズ","http://pripara.jp/item/image/secret.png","シューズ","ポップ","CandyAlamode","MR",1170,"不明"]
  when "H-MR-002"
    return ["2015_2nd","まいにちプリパラ2015 2ndライブ","H-MR-002","ミステリーCAサイリウムヘアアクセ","http://pripara.jp/item/image/secret.png","ヘアアクセ","ポップ","CandyAlamode",nil,nil,"不明"]
  when "MR-005"
    return ["2015_3rd","まいにちプリパラ2015 3rdライブ（9月）","MR-005","ミステリーHTサイリウムワンピ","http://pripara.jp/item/image/secret.png","ワンピース","クール","HolicTrick","MR",2290,"不明"]
  when "MR-006"
    return ["2015_3rd","まいにちプリパラ2015 3rdライブ（9月）","MR-006","ミステリーHTサイリウムシューズ","http://pripara.jp/item/image/secret.png","シューズ","クール","HolicTrick","MR",1170,"不明"]
  when "H-MR-003"
    return ["2015_3rd","まいにちプリパラ2015 3rdライブ（9月）","H-MR-003","ミステリーHTサイリウムヘアアクセ","http://pripara.jp/item/image/secret.png","ヘアアクセ","クール","HolicTrick",nil,nil,"不明"]
  when "MR-007"
    return ["2015_4th","まいにちプリパラ2015 4thライブ（10月）","MR-007","ミステリーBMサイリウムワンピ","http://pripara.jp/item/image/secret.png","ワンピース","クール","BabyMonster","MR",2350,"不明"]
  when "MR-008"
    return ["2015_4th","まいにちプリパラ2015 4thライブ（10月）","MR-008","ミステリーBMサイリウムシューズ","http://pripara.jp/item/image/secret.png","ワンピース","クール","BabyMonster","MR",1200,"不明"]
  when "H-MR-004"
    return ["2015_4th","まいにちプリパラ2015 4thライブ（10月）","H-MR-004","ミステリーBMサイリウムヘアアクセ","http://pripara.jp/item/image/secret.png","ワンピース","クール","BabyMonster",nil,nil,"不明"]
  when "C-086"
    return ["2015promotion","2015シリーズプロモーション","C-086","プチデビスイートトップス","http://pripara.jp/item/image/secret.png","トップス","クール","HolicTrickClassic","SR",720,"不明"]
  when "C-060"
    return ["2015promotion","2015シリーズプロモーション","C-060","ゴージャスムーンワンピ","http://pripara.jp/item/image/secret.png","ワンピ","クール","HolicTrick","R",1100,"不明"]
  else
    return codeData
  end
end

def trim(str)
  # スペースを半角スペースにする。また末尾のスペースを取り除く
  trimed = str.gsub(/[[:space:]]/, " ").strip
  if trimed == ""
    nil
  else
    trimed
  end
end

def trimStar(str)
  str.gsub("★", "")
end

def writeAsCSV(fileName, items)
  puts fileName + "に結果を書き込みます"
  CSV.open(fileName, "wb") do |csv|
    csv << ["liveId", "liveName", "itemId", "itemName", "thumbnailUrl", "category", "type", "brand", "rarity", "nice", "color"]
    items.each do |item|
      csv << item
    end
  end
end

def crateThumbnailUrl(relativePath)
  if (relativePath != " ")
    "http://pripara.jp/item/" + relativePath
  else
    relativePath
  end
end

def determineBrand(imgSrc)
  case imgSrc  
  when "../img/item/icon_baby.jpg"
    return "BabyMonster"
  when "../img/item/icon_candy.jpg"
    return "CandyAlamode"
  when "../img/item/icon_classic.jpg"
    return "HolicTrick classic"
  when "../img/item/icon_clock.jpg"
    return "Clockgarden"
  when "../img/item/icon_coco.jpg"
    return "CocoFlower"
  when "../img/item/icon_dear.jpg"
    return "DearCrown"
  when "../img/item/icon_dreaming.jpg"
    return "DreamingGirl"
  when "../img/item/icon_fantasy.jpg"
    return "FantasyTime"
  when "../img/item/icon_fortune.jpg"
    return "FortuneParty"
  when "../img/item/icon_ftdream.jpg"
    return "FantasyTime Dream"
  when "../img/item/icon_garden.jpg"
    return "Clockgarden"
  when "../img/item/icon_holic.jpg"
    return "HolicTrick"
  when "../img/item/icon_love.jpg"
    return "LOVEDEVI"
  when "../img/item/icon_marionette.jpg"
    return "MarionetteMu"
  when "../img/item/icon_melty.jpg"
    return "MeltyLily"
  when "../img/item/icon_more.jpg"
    return "CandyAlamode more"
  when "../img/item/icon_neon.jpg"
    return "NeonDrop"
  when "../img/item/icon_pretty.jpg"
    return "PrettyRythm"
  when "../img/item/icon_prince.jpg"
    return "BrilliantPrince"
  when "../img/item/icon_prismstone.jpg"
    return "PrismStone"
  when "../img/item/icon_rich.jpg"
    return "RichVenus"
  when "../img/item/icon_rosette.jpg"
    return "RosetteJewel"
  when "../img/item/icon_silky.jpg"
    return "SilkyHeart"
  when "../img/item/icon_sweet.jpg"
    return "TwinkleRibbon Sweet"
  when "../img/item/icon_time.jpg"
    return "FantasyTime"
  when "../img/item/icon_twinkle.jpg"
    return "TwinkleRibbon"
  when "../img/item/icon_zoo.jpg"
    return "SunnyZoo"
  when "../img/item/icon_RONI.jpg"
    return "RONI"
  when "../img/item/icon_ps_dream.jpg"
    return "PRISM STONE"
  else
    return "なし"
  end
end

def toHalf(str)
  str.tr('０-９ａ-ｚＡ-Ｚ', '0-9a-zA-Z')
end

main()
