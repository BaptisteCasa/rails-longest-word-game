require 'net/http'
require 'json'
require 'uri'

class GamesController < ApplicationController
  def new
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
  end

  def score
    @word = params[:word].upcase
    @letters = params[:letters].split('')
    @valid_grid = word_in_grid?(@word, @letters)
    @valid_english = valid_english_word?(@word)

    if !@valid_grid
      @message = "Sorry, but #{@word} can't be built out of #{@letters.join(', ')}."
      @score = 0
    elsif !@valid_english
      @message = "Sorry, but #{@word} is not a valid English word."
      @score = 0
    else
      @message = "Well done!"
      @score = @word.length**2  # Score = carré du nombre de lettres
    end

    session[:total_score] ||= 0
    session[:total_score] += @score
    @total_score = session[:total_score]
  end

  private

  def word_in_grid?(word, letters)
    word.chars.all? { |letter| word.count(letter) <= letters.count(letter) }
  end

  def valid_english_word?(word)
    url = URI.parse("https://wagon-dictionary.herokuapp.com/#{word}")
    response = Net::HTTP.get_response(url)

    return false unless response.is_a?(Net::HTTPSuccess)

    json = JSON.parse(response.body)
    json['found']
  end
end
