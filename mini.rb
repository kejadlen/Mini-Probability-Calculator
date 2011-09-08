#!/usr/bin/env ruby

require 'camping'

Camping.goes :Mini

class Mini::Game
  attr_reader :score

  def initialize(*p)
    @p = p
    @score = [0, 0]
  end

  def play
    @team = 0 # start with team 0
    self.play_point
  end

  def play_point
    if rand < @p[@team] # scored!
      @score[@team] += 1
    else # turnover!
      @score[@team] -= 1
      @team = (@team + 1) % 2
    end

    self.play_point unless self.over?
  end

  def over?
    score.include?(3) or score.include?(-2)
  end

  def reset
    @score = [0, 0]
  end
end

module Mini::Controllers
  class Index
    def get
      @n = 10_000
      @p_1 = @p_2 = 0.5
      render :index
    end
    
    def post
      @n = @input['n'].to_i
      @p_1 = @input['p_1'].to_f
      @p_2 = @input['p_2'].to_f

      m = Mini::Game.new(@p_1, @p_2)
      scores = Hash.new { 0 }
      @n.times do
        m.reset
        m.play
        scores[m.score] += 1
      end

      @wins,@losses = scores.sort.reverse.partition {|k,_| k[0] == 3 or k[1] == -2 }

      render :index
    end
  end
end

module Mini::Views
  def index
    h1 'Mini Probability Calculator'

    form :action => R(Index), :method => :post do
      label "N "; input :value => @n, :name => :n, :size => 5; br
      label "P_1 "; input :value => @p_1, :name => :p_1, :size => 5; br
      label "P_2 "; input :value => @p_2, :name => :p_2, :size => 5; br
      input :type => :submit, :value => 'Calculate'
    end

    if @wins and @losses
      h2 'Wins'
      _data(@wins)

      h2 'Losses'
      _data(@losses)
    end
  end

  def _data(data)
    sum = 0
    table :border => 1 do
      data.each do |score,num|
        prob = 100 * num / @n.to_f 
        sum += prob
        tr do
          td score[0]
          td score[1]
          td num
          td "#{prob}%"
        end
      end
    end
    p "%0.2f%" % sum
  end
end

__END__
