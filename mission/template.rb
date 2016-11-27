require 'erb'
require 'pathname'

##
# Render ERB templates with support for partials and variables.
#
# @example Variables
#   src = 'src.erb'
#   File.open(src, 'w') do |io|
#     io.write('Hello <%= @name %>, this is a template')
#   end
#   template = Template.new(src, {name: 'Brandon'})
#   template.result
#   => "Hello Brandon, this is a template"
#
# @example Partials
#   src = 'src.erb'
#   File.open(src, 'w') do |io|
#     io.write("Hello, I can display partials: <%= render 'partial' %>")
#   end
#   File.open('_partial.erb', 'w') do |io|
#     io.write('This is a partial!')
#   end
#   template = Template.new(src)
#   template.result
#   # => "Hello, I can display partials: This is a partial!"
class Template

  attr_reader :template_pathname
  attr_reader :prefix_pathname
  attr_accessor :variables
  attr_accessor :partial_extension

  def initialize(template_pathname, variables={})
    template_pathname = Pathname.new(template_pathname) unless template_pathname.is_a?(Pathname)
    @template_pathname = template_pathname
    @prefix_pathname = @template_pathname.expand_path.dirname
    @variables = variables
    @partial_extension = '.erb'
  end

  def context
    Context.new(self, variables)
  end
  private :context

  def partial_pathname(partial_relative_path)
    # To mimic partials in Rails, the path passed does not have a '_' prefix, so add it
    relative_directory = File.dirname(partial_relative_path)
    raw_basename = File.basename(partial_relative_path)
    partial_basename = "_#{raw_basename}"

    partial_pathname = prefix_pathname.join(relative_directory, partial_basename)

    # if the extension wasn't included, look for it
    unless partial_pathname.exist?
      new_partial_pathname = Pathname.new("#{partial_pathname}#{partial_extension}")

      if new_partial_pathname.exist?
        partial_pathname = new_partial_pathname
      else
        raise ArgumentError, "No partials matching #{partial_relative_path}"
      end
    end

    partial_pathname
  end
  private :partial_pathname

  # Used for rendering partials
  def render(partial_relative_path, vars=nil)
    pathname = partial_pathname(partial_relative_path)

    if vars.is_a?(Hash)
      context = Context.new(self, (variables || {}).merge(vars))
    else
      context = nil
    end

    template_result(pathname.read, context)
  end
  private :render

  # Calls {#template_result} with the content of the file {#template_pathname}.
  def result
    template_result(template_pathname.read)
  end

  # Renders the ERB template file specified with {#context}'s binding.
  def template_result(str, context=nil)
    context = context() unless context
    template = ERB.new(str, nil, '-')
    template.result(context.get_binding)
  end
  private :template_result

  # Process +template_file+ and write +output_file+.
  def self.to_file(template_file, output_file, vars=nil)
    template = self.new(template_file, vars)

    result = template.result

    output_file_pathname = Pathname.new(output_file)
    output_file_pathname.dirname.mkpath
    output_file_pathname.delete if output_file_pathname.exist?
    output_file_pathname.open('wb') do |f|
      f.write(result)
    end
    # I don't think we should update mode and time to match the template source,
    # but we could
    #output_file_pathname.chmod(template.template_pathname.stat.mode)
    #output_file_pathname.utime(template.template_pathname.atime, template.template_pathname.mtime)
    output_file_pathname
  end


  ##
  # Context is used to isolate the template context.
  # A +render+ method is provided for rendering partials.
  # Instance variables are set to the given +vars+ hash.
  class Context
    # Include ActiveSupport's ERB::Util patches
    include ERB::Util

    def initialize(template, vars={})
      @_template = template
      if vars.is_a?(Hash)
        vars.each do |key, val|
          instance_variable_set("@#{key}", val)
        end
      end
    end

    # Delegates {#render} to this instance's template.
    def render(*args)
      @_template.send(:render, *args)
    end

    # Exposes this {Context} instance's binding.
    def get_binding
      binding
    end
  end
end
