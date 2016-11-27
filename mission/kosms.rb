require 'yaml'
require 'erb'
require 'singleton'
require './template.rb'

class Kosms
  class MissionBuilder
    def initialize(name, steps)
      mission_base = 'mission_base.erb'
      @name = name
      @template = Template.new(mission_base, {steps: steps})
    end
    def create
      @file = File.open(@name+'.ks', 'w')
      @file << @template.result
      @file.close
    end
  end
  def initialize
    @missions = YAML.load_file('missions.yml').each_pair{|k,v| v.flatten!}

  end
  def generate_missions
    @missions.each_pair do |name, steps|
      MissionBuilder.new(name, steps).create
    end
  end
end
