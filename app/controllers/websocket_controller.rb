class WebsocketController < WebsocketRails::BaseController

  def listen
    
    puts 'listening...'
    WebsocketRails[:updates].trigger(:update, 'test')

  end

  def goodbye
    
    puts 'goodbye!'
    WebsocketRails[:updates].trigger(:update, 'test')

  end

end
