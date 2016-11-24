require 'yaml'
require 'erb'
require 'singleton'

class Kosmos
  class MissionBuilder
    def initialize(steps)

    end
  end
  def initialize
    @config = YAML.load_file('config.yml').each_pair{|k,v| v.flatten!}
    @missions = {}
    @config.each_pair do |name, steps|
      @missions[name] = MissionBuilder.new(steps)
    end
  end
end
