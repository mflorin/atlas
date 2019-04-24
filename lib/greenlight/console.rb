require 'singleton'

class Colors

	COLORS_LIB = {
			:red => '31',
			:green => '32',
			:yellow => '33',
			:blue => '34',
			:grey => '37',
			:magenta => '35',
			:cyan => '36',
			:light_cyan => '96',
			:light_red => '91',
			:light_blue => '94',
			:light_magenta => '95',
			:light_green => '92',
			:light_yellow => '93',
			:white => '97'

	}
	class << self
		COLORS_LIB.each do |color_name, color_val|
			define_method(color_name.to_s) { |msg|
				$stdout.tty? ? "\e[#{color_val}m#{msg}\e[0m" : msg
			}
		end
	end

end

class Console

	include Singleton

	attr_accessor :indent_level

	INDENT_STR = '  '

	def initialize
		self.indent_level = 0
	end

	def info(msg)
		puts Colors.grey(' - ' + get_indent + msg)
	end

	def action(msg)
		puts ' * ' + get_indent + msg
	end

	def error(msg)
		puts Colors.light_red(' ' + Console.utf8("\u2718") + ' ' + get_indent + msg)
	end

	def success(msg)
		puts Colors.light_green(' ' + Console.utf8("\u2713") + ' ' + get_indent + msg)
	end

	def get_indent
		INDENT_STR * indent_level
	end

	def indent
		self.indent_level = self.indent_level + 1
	end

	def unindent
		self.indent_level = self.indent_level - 1 unless self.indent_level == 0
	end

	def self.utf8(code)
		code.encode('utf-8')
	end
end


def info(msg)
	Console.instance.info(msg)
end

def action(msg)
	Console.instance.action(msg)
end

def error(msg)
	Console.instance.error(msg)
end

def success(msg)
	Console.instance.success(msg)
end