require "bundler"

Bundler.require

# I've never played poker before so hopefully I understand the rules well enough.
class Poker
  class Game
    attr_accessor :hands

    def initialize
      @hands = []
    end

    def add_hand(name:, cards:)
      hands.push Hand.new(name: name, cards: cards)
    end

    def winners
      hands
        .sort_by(&:point_value)
        .reverse
        .group_by(&:point_value)
        .values
        .first
    end
  end

  class Hand
    attr_accessor :name, :cards

    def initialize(name:, cards:)
      @name = name
      @cards = cards.map { |card| Card.new(card[0..-2], card[-1]) }
    end

    def flush?
      # five cards, same suit
      return false unless cards.count == 5
      return false unless cards.all? { |card| card.suit == cards.first.suit }

      true
    end

    def three_kind?
      set?(3)
    end

    def two_kind?
      set?(2)
    end

    def set?(set_count)
      cards.group_by(&:rank).any? { |rank, like_cards| like_cards.count == set_count }
    end

    # Kings high
    def highest_card
      cards.sort_by(&:numeric_rank).last
    end

    # This makes it easier to find the winner. We give a point value to each type of recognized
    # hand.
    def point_value
      return 500 if flush?
      return 300 if three_kind?
      return 200 if two_kind?
      return highest_card.numeric_rank
    end
  end

  class Card
    attr_accessor :suit, :rank

    def initialize(rank, suit)
      @suit = suit.downcase
      @rank = rank.downcase

      # This makes math easier, apparently aces are considered to be the number 1 in card playing
      @rank = "1" if @rank == "a"
    end

    def clubs?
      suit == "c"
    end

    def hearts?
      suit == "h"
    end

    def spades?
      suit == "s"
    end

    def diamonds?
      suit == "d"
    end

    def number?
      !face?
    end

    def face?
      rank == "j" || rank == "q" || rank == "k"
    end

    def numeric_rank
      case rank
      when "j"
        11
      when "q"
        12
      when "k"
        13
      else
        rank.to_i
      end
    end
  end
end

# Game 1: Sample game in email. Joe wins with flush.
game = Poker::Game.new

game.add_hand(name: "Joe", cards: ["3H", "4H", "5H", "6H", "8H"])
game.add_hand(name: "Bob", cards: ["3C", "3D", "3S", "8C", "10D"])
game.add_hand(name: "Sally", cards: ["AC", "10C", "5C", "2S", "2C"])

puts "Winner(s): #{game.winners.map(&:name).join(", ")}"

# Game 2: Either Fred or Joe is cheating and have the exact same hand. Joe and Fred tie.
game = Poker::Game.new

game.add_hand(name: "Joe", cards: ["3H", "4H", "5H", "6H", "8H"])
game.add_hand(name: "Fred", cards: ["3H", "4H", "5H", "6H", "8H"])
game.add_hand(name: "Bob", cards: ["3C", "3D", "3S", "8C", "10D"])
game.add_hand(name: "Sally", cards: ["AC", "10C", "5C", "2S", "2C"])

puts "Winner(s): #{game.winners.map(&:name).join(", ")}"

# Game 3: Runt hand. Highest card is 10 so both Bob and Sally win.

game = Poker::Game.new

game.add_hand(name: "Joe", cards: ["3H", "4H", "5D", "6H", "8H"])
game.add_hand(name: "Bob", cards: ["3C", "3D", "4S", "8C", "10D"])
game.add_hand(name: "Sally", cards: ["AC", "10C", "5C", "2S", "2C"])

puts "Winner(s): #{game.winners.map(&:name).join(", ")}"

