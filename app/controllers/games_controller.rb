require 'open-uri'
require 'json'

class GamesController < ApplicationController

  def new
    @letters = []
    12.times { @letters << ('A'..'Z').to_a.sample }
  end

  def score
    @attempt = params[:attempt].downcase
    @letters = params[:letters].downcase
    @time = params[:time_taken]

    attempt = params[:attempt].downcase
    grid = params[:letters].downcase.split("")
    if legit_word?(attempt) && does_not_over_use_letters?(attempt, grid) && attempt_has_letters_in_grid?(attempt, grid)
      @score = ((attempt.length.to_f / grid.length) * 100).round(2)
      @score += 5 if @time.to_i < 5
    else
      @score = 0
    end
    @message = message_for_result(attempt, grid)
  end

  private

  def legit_word?(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    word_result_serialized = URI.open(url).read
    word_result = JSON.parse(word_result_serialized)
    return word_result["found"]
  end

  def does_not_over_use_letters?(attempt, grid)
    attempt = attempt.chars
    grid_count = hash_with_letter_count(grid)
    attempt_count = hash_with_letter_count(attempt)

    # compare grid count and attempt count
    answer = true
    grid_count.each do |letter, _count|
      answer = false if !attempt_count[letter].nil? && attempt_count[letter] > grid_count[letter]
    end
    answer
  end

  def hash_with_letter_count(letters_array)
    hash = {}
    letters_array.each do |letter|
      letter&.downcase!
      hash[letter].nil? ? hash[letter] = 1 : hash[letter] += 1
    end
    return hash
  end

  def attempt_has_letters_in_grid?(attempt, grid)
    attempt = attempt.chars
    answer = true
    attempt.each do |letter|
      answer = false unless grid.include?(letter)
    end
    answer
  end

  def message_for_result(attempt, grid)
    if legit_word?(attempt) && does_not_over_use_letters?(attempt, grid) && attempt_has_letters_in_grid?(attempt, grid)
      message = 'Well Done!'
    else
      message = 'Not an english word' unless legit_word?(attempt)
      unless does_not_over_use_letters?(attempt, grid) && attempt_has_letters_in_grid?(attempt, grid)
        message = 'Not in the grid'
      end
    end
    message
  end
end
