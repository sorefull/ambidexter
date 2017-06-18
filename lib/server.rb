require "application"
require "webrick"
include WEBrick
require 'securerandom'
require 'usagewatch'

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

  class ExitPath < WEBrick::HTTPServlet::AbstractServlet
    def do_POST(request, response)
      @@req_results = request.query['results'].split(' ').map{|r| r.to_f}
      @@package_loss = request.query['package_loss'].to_i
      @@package_rec = request.query['package_rec'].to_i
      response.status = 200
    end

    def self.results
      @@req_results ||= []
    end

    def self.loss
      @@package_loss ||= 0
    end

    def self.rec
      @@package_rec ||= 0
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
    @server.mount '/exit',      ExitPath
  end

  def start
    @usw = Usagewatch
    @new0 = @usw.bandrx
    @time0 = Time.now

    ['TERM', 'INT'].each do |signal|
      trap(signal){
        @server.shutdown
        statistics
      }
    end
    @server.start
  end

  def statistics
    new1 = @usw.bandrx
    time1 = Time.now

    bytesreceived = new1[0].to_i - @new0[0].to_i
    bitsreceived = bytesreceived * 8
    bandwidth = (bitsreceived.to_f / 1024 / 1024).round(3)
    time = (time1 - @time0).round(3)
    sum_req_times = ExitPath.results.sum.round(3)
    package_loss = ExitPath.loss
    package_rec = ExitPath.rec
    average_req_times = begin
      if ExitPath.results.empty?
        0
      else
        (ExitPath.results.inject{ |sum, el| sum + el } / ExitPath.results.size).round(3)
      end
    end
    bandwidth_per_time = (bandwidth / time).round(3)

    puts
    puts '------------------------------------------------------------------'.green
    puts "~>  AMBIDEXTER's SUMMARY".yellow
    puts
    puts "#{time} seconds Server sesion time".yellow
    puts "#{bandwidth} Mbit Current Bandwidth Received".yellow
    puts "#{bandwidth_per_time} Mbit/s Average Bandwidth Received".yellow
    puts "#{sum_req_times} seconds Summary request time".yellow
    puts "#{average_req_times} seconds Average request time".yellow
    if package_loss > 0
      puts "#{package_loss} Packages lost".red
    end
    puts "#{package_rec} Packages received".yellow
    puts
                     puts "Made by Oleg Cherednichenko 2017, KNURE".rjust 66
    puts '------------------------------------------------------------------'.green
  end
end
