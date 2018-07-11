class ScrapeDirectoryWorker
  include Sidekiq::Worker

  def perform(index)
    browser = Watir::Browser.new
    browser.goto "https://www.rlsnet.ru/pcr_alf_letter_c#{index}.htm"
    browser.div(class: 'tn_alf_list').ul.lis.each do |li|
      ScrapeItemWorker.perform_async(li.a.href) unless Drug.find_by(name: li.a.text)
    end
    browser.close
  end

end