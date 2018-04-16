#!/usr/bin/env ruby

require './lib/syllabes.rb'

syllabes = Syllabes.new("catacroker")
p syllabes.process.size
