#!/usr/bin/env ruby
# Copyright 2023, Tommi Venemies
# Licensed under the BSD-4-Clause.
# TODO: Create flow:
# 1. Go through all files and parse.
# 2. Add fail tailing for the files to catch new data
# TODO: Create parsing
# 1. Normalize data
# 2. Store data in tsv with some hash or row number
# 3. Create indexes. Likely in-memory, or on disk and load certain timeframe
# 4. Build indexes for common things like logins, su, etc.
class Aggregate
	attr_accessor :logs
end

class Log
	attr_accessor :channel
	attr_accessor :meta
	attr_accessor :message
	attr_accessor :time
	attr_accessor :source
	attr_accessor :process
end

class App
	def initialize(ro = {})
		configure ro
	end

	def configure(ro = {})
	end

	def process(f, e = nil)
		return nil unless File.file?(f)
		log = Aggregate.new
		log.logs = Hash.new
		mode = e ? "r:#{e}" : "r"
		File.open(f, mode) { |content| parse content, log }
		log
	end

	def parse(c, t)
		return unless c && t
		c.each_line do |line|
			log = parse_line line
			# Probably a better spot to apply filters after parse
			# e.g. should only parse once but filter many times.
			if log.process.include? "ssh"
				# IPv4 regex
				ip = log.message[/(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/, 1]
				if ip
					if t.logs.include? ip
						count = t.logs[ip]
						count = count + 1
						t.logs[ip] = count
					else
						t.logs[ip] = 1
					end
				end
				# Invalid user regex
				user = log.message[/Invalid user (\S*)/, 1]
				if user
					if t.logs.include? user
						count = t.logs[user]
						count = count + 1
						t.logs[user] = count
					else
						t.logs[user] = 1
					end
				end
			end
		end
	end

	def parse_line(l)
		line = l.chomp
		parts = line.split
		entry = Log.new
		unless parts[3].include? "<"
			entry.meta = parts[0..4]
			entry.message = parts[5..].join
			entry.time = entry.meta[0..2].join
			entry.source = entry.meta[3]
			entry.process = entry.meta[4]
		else
			entry.meta = parts[0..5]
			entry.message = parts[6..].join " "
			entry.time = entry.meta[0..2].join " "
			entry.channel = entry.meta[3]
			entry.source = entry.meta[4]
			entry.process = entry.meta[5]
		end
		entry
	end

	def summarize(l)
		puts "#{l.logs.length}"
		l.logs = l.logs.sort_by {|k,v| v}.reverse
		l.logs.each {|x| print x, "\n" }
	end
end

if __FILE__ == $0
	app = App.new
	log = app.process "tower.log"
	app.summarize(log)
end
