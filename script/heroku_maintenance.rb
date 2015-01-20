#!/usr/bin/env ruby

require 'heroku-api'

heroku = Heroku::API.new(:api_key => ENV['HEROKU_API_KEY'])
branch = ENV['TRAVIS_BRANCH']
case branch
when 'master'
  app = 'growstuff-prod'
when 'dev'
  app = 'growstuff-staging'
when 'travis_deploy'
  app = 'tranquil-basin-3130'
else
  abort "No Heroku app found for branch #{branch}"
end
print "#{app}\n"

case ARGV[0]
when "on"
  maintenance_state = 1
when "off"
  maintenance_state = 0
else
  abort "usage: #{$0} (on|off)"
end
print "#{maintenance_state}\n"

heroku.post_app_maintenance(app, maintenance_state)
