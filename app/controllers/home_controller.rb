class HomeController < ApplicationController
  require 'watir'

  def index

  end

  def scrape
    browser = Watir::Browser.new
    browser.goto "https://www.rlsnet.ru/pcr_alf_letter_c0.htm"
    browser.div(class: 'tn_alf_list').ul.lis.each do |li|
      create_file_or_skip(li.a.href)
    end
  end

  private

  def create_file_or_skip(url)
    browser = Watir::Browser.new
    browser.goto url
    browser.div(id: 'packing-header').click
    sleep 0.2

    code_wrapper = browser.div(id: 'preplist_aurora').div(class: 'drug__list-filterresult').ul.text
    codes = code_wrapper.scan(/EAN\s\d*/).join(' ').gsub('EAN', '')
    if codes.length.positive?
      f = File.open("#{codes}.html", 'w')
      f.write("<!DOCTYPE html>\n<html lang='en'>\n<head>\n<meta charset='UTF-8'>\n<title>Title</title>\n</head>\n<body>\n")

      f.write("<h1>Штрихкоды: #{codes.gsub('  ', ', ')}</h1>\n")
      h1 = browser.h1.inner_html.to_s
      f.write("<h2>Название: #{h1}</h2>\n")
      content = browser.div(class: 'drug__content')
      h2s = content.h2s
      h2s.each do |h2|
        break if h2.text == 'Цены в аптеках Москвы'
        next if h2.text == 'Содержание'
        break if h2.text == 'Синонимы нозологических групп'
        p h2.text
        f.write("<h2>#{h2.text}</h2>\n")
        next_tag = ''
        i = 0
        while next_tag != 'h2'
          inner = h2.next_sibling(index: i)
          break if inner.class_name.include? 'noprint'
          f.write("<#{inner.tag_name}>#{inner.inner_html}</#{inner.tag_name}>\n")
          i += 1
          next_tag = h2.next_sibling(index: i + 1).tag_name
        end
      end
      f.write("\n</body>\n</html>")
      browser.close
    else
      puts "Нет штрихкодов"
      browser.close
    end
  end

end
