require "application"
require "webrick"
include WEBrick
require 'securerandom'

class Server < Application
  class RootPath < WEBrick::HTTPServlet::AbstractServlet
    def do_GET(request, response)
      response.status = 200
    end
    def do_POST(request, response)
      if request.query == { "name"=>"Oleg", "github_nickname"=>"sorefull"}
        response.status = 202
      else
        response.status = 401
      end
    end
  end

  class LoremPath < WEBrick::HTTPServlet::AbstractServlet
    def do_GET(request, response)
      length = request.query['length'].to_i
      length = -1 if length < 1
      response.body = Server::LoremIpsum.lorem[0..length]
      response.status = 200
    end
  end

  class CookiePath < WEBrick::HTTPServlet::AbstractServlet
    def do_GET(request, response)
      if request.cookies.select{|c| c.name == 'private'}.first.value == 'asdfg' &&
          request.cookies.select{|c| c.name == 'public'}.first.value == 'gijj'
        response.status = 200
      else
        response.status = 401
      end
    end
  end

  class FilePath < WEBrick::HTTPServlet::AbstractServlet
    def do_POST(request, response)
      file_data = request.query["uploaded_image"]
      random_string = SecureRandom.hex(3)
      f = File.open("#{__dir__}/../tmp/#{random_string}_image.jpeg", "wb")
      f.syswrite file_data
      f.close
      response.status = FileUtils.compare_file("#{__dir__}/../tmp/#{random_string}_image.jpeg", "#{__dir__}/../files/image.jpeg") ? 200 : 500
      FileUtils.rm_rf("#{__dir__}/../tmp/#{random_string}_image.jpeg")
    end
  end

  def initialize
    print "Input Port of servrer: ".green
    @port = $stdin.gets.chomp
    @port = '5899' if blank? @port
    FileUtils.rm_rf("#{__dir__}/../tmp")
    Dir.mkdir("#{__dir__}/../tmp")
  end

  def mount
    @server = HTTPServer.new(:Port => @port)
    @server.mount "/",          RootPath
    @server.mount "/lorem",     LoremPath
    @server.mount "/cookie",    CookiePath
    @server.mount "/file",      FilePath
    @server.mount('/file.txt',  WEBrick::HTTPServlet::DefaultFileHandler, "#{__dir__}/../files/file.txt")
  end

  def start
    ['TERM', 'INT'].each do |signal|
      trap(signal){ @server.shutdown }
    end
    @server.start
  end
end
