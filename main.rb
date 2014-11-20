require 'rubygems'
require 'sinatra'

set :sessions, true
BLACKJACK_AMT = 21
DEALER_MIN_HIT = 17
POT = 500

helpers do
  def calculate_total(cards) 
    arr = cards.map { |element| element[1] }
    total = 0
    arr.each do |a|
      if a == 'A'
        total += 11
      else
        total += a.to_i == 0 ? 10 : a.to_i
      end
    end

    arr.select { |element| element == 'A' }.count.times do 
      break if total <= BLACKJACK_AMT
      total -= 10
    end
    total
  end

  def card_image(card) 
    suit = case card[0]
      when 'H' then 'hearts'
      when 'D' then 'diamonds'
      when 'C' then 'clubs'
      when 'S' then 'spades'
    end

    value = card[1]
    if ['J', 'Q', 'K', 'A'].include?(value)
      value = case card[1]
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        when 'A' then 'ace'
      end
    end
    
    "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
  end

  def winner!(msg)
    @play_again = true
    @success_or_error = false
    session[:player_pot] += session[:player_bet]
    @success = "<strong>Congratulations. You win.</strong> #{msg}"
  end

  def loser!(msg)
    @play_again = true
    @success_or_error = false
    session[:player_pot] -= session[:player_bet]
    @error = "<strong>Sorry, you lose.</strong> #{msg}"
  end

  def tie!(msg)
    @play_again = true
    @success_or_error = false
    @success = "<strong>It's a tie!</strong> #{msg}"
  end
end

before do
  @success_or_error = true
  @show_dealer_score = true
end

get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  session[:player_pot] = POT
  erb :new_player
end

post '/new_player' do
  if params[:player_name].empty?
    @error = "Name is required."
    halt erb :new_player
  end
  session[:player_name] = params[:player_name]
  redirect '/bet'
end

get '/bet' do
  session[:player_bet] = nil
  erb :bet 
end

post '/bet' do
  if params[:bet_amount].nil? || params[:bet_amount].to_i == 0
    @error = "You must make a bet in order to play!"
    halt erb(:bet)
  elsif params[:bet_amount].to_i > session[:player_pot]
    @error = "You cannot bet more than you have. You currently have $#{session[:player_pot]} in your pot."
    halt erb(:bet)
  else
    session[:player_bet] = params[:bet_amount].to_i
    redirect '/game'
  end
end

get '/game' do
  session[:turn] = session[:player_name]

  suits = ['H', 'D', 'C', 'S']
  values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  session[:deck] = suits.product(values).shuffle!
  
  session[:player_cards] = []
  session[:dealer_cards] = []

  2.times do
    session[:player_cards] << session[:deck].pop
    session[:dealer_cards] << session[:deck].pop
  end

  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  player_total = calculate_total(session[:player_cards])
  if player_total == BLACKJACK_AMT
    winner!("You hit BlackJack!!")
  elsif player_total > BLACKJACK_AMT 
    loser!("You busted!")
  end
  erb :game, layout: false
end

post '/game/player/stay' do
  @success = "You have decided to stay."
  @success_or_error = false
  redirect '/game/dealer'
end

get '/game/dealer' do
  session[:turn] = "dealer"

  @success_or_error = false

  dealer_total = calculate_total(session[:dealer_cards])
  if dealer_total == BLACKJACK_AMT
    loser!("Dealer hit BlackJack!")
  elsif dealer_total > BLACKJACK_AMT
    winner!("Dealer busted")
  elsif dealer_total >= DEALER_MIN_HIT 
    redirect '/game/compare'
  else 
    @show_dealer_btn = true
  end

  erb :game, layout: false
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  @success_or_error = false

  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])

  if player_total > dealer_total
    winner!("Your final score is #{player_total}. The dealer's final score is #{dealer_total}.")
  elsif dealer_total > player_total
    loser!("The dealer's final score is #{dealer_total}. Your final score is #{player_total}.")
  else
    tie!("Both of your final scores are #{player_total}.")
  end

  erb :game, layout: false
end 

get '/game_over' do
  erb :game_over
end




