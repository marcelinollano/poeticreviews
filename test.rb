#!/usr/bin/env ruby

require './processor.rb'

# puts "processing: #{ARGV.first}"
# syllable = Syllabe.new(ARGV.first)
# syllable.process
# puts "syllable positions: #{syllable.positions}"

syllable = Processor.new("camión")
syllable.process
puts "syllable positions: #{syllable.positions}"


