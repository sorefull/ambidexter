require "application"
require "curb"
require "colorize"

class Client < Application
  def initialize
    # Setting IP of server
    print "Input IP address of servrer: ".green
    @ip = $stdin.gets.chomp
    @ip = 'localhost' if blank? @ip

    # Setting PORT of server
    print "Input Port of servrer: ".green
    @port = $stdin.gets.chomp
    @port = '5899' if blank? @port

    # Setting iterations count
    print "Input iterations count: ".green
    @each_count = $stdin.gets.chomp.to_i
    @each_count = 1 if @each_count.zero?

    # Setting eterations count
    print "Input threads count: ".green
    @threads_count = $stdin.gets.chomp.to_i
    @threads_count = 1 if @threads_count.zero?

    # Setting timeout
    print "Input timeout: ".green
    @http_timeout = $stdin.gets.chomp.to_f
    @http_timeout = 10 if @http_timeout.zero?

    # Building link
    @uri = "http://#{@ip}:#{@port}"

    # Variables
    @req_times = []
    @threads = []
    @package_loss = 0
    @package_rec = 0
  end

  def test
    @threads_count.times do
      @threads << Thread.new do
        @each_count.times do
          # Raw root GET
          begin
            t = Time.now
            response = Curl.get(@uri) do |http|
              http.timeout = @http_timeout
            end
            @req_times << Time.now - t
            if response.status == '200 OK'
              print '.'.green
            else
              print '!'.red
            end
            @package_rec += 1
          rescue Curl::Err::TimeoutError
            print '#'.yellow
            @package_loss += 1
          end

          # Root POST with correct params
          begin
            t = Time.now
            response = Curl.post(@uri, { name: 'Oleg', github_nickname: 'sorefull' }) do |http|
              http.timeout = @http_timeout
            end
            @req_times << Time.now - t
            if response.status == '202 Accepted'
              print '.'.green
            else
              print '!'.red
            end
            @package_rec += 1
          rescue Curl::Err::TimeoutError
            print '#'.yellow
            @package_loss += 1
          end

          # Root POST with wrong params
          begin
            t = Time.now
            response = Curl.post(@uri, { name: '', github_nickname: '' }) do |http|
              http.timeout = @http_timeout
            end
            @req_times << Time.now - t
            if response.status == '401 Unauthorized'
              print '.'.green
            else
              print '!'.red
            end
            @package_rec += 1
          rescue Curl::Err::TimeoutError
            print '#'.yellow
            @package_loss += 1
          end

          # Lorem GET with body check
          begin
            t = Time.now
            response = Curl.get(@uri + '/lorem') do |http|
              http.timeout = @http_timeout
            end
            @req_times << Time.now - t
            if response.body == LoremIpsum.lorem
              print '.'.green
            else
              print '!'.red
            end
            @package_rec += 1
          rescue Curl::Err::TimeoutError
            print '#'.yellow
            @package_loss += 1
          end

          # Lorem GET with params
          begin
            t = Time.now
            response = Curl.get(@uri + '/lorem', { length: 10 }) do |http|
              http.timeout = @http_timeout
            end
            @req_times << Time.now - t
            if response.body == LoremIpsum.lorem[0..10]
              print '.'.green
            else
              print '!'.red
            end
            @package_rec += 1
          rescue Curl::Err::TimeoutError
            print '#'.yellow
            @package_loss += 1
          end

          # Cookie GET with correct cookies
          begin
          t = Time.now
            response = Curl.get(@uri + '/cookie') do |http|
              http.headers['Cookie'] = 'private=asdfg; public=gijj'
              http.timeout = @http_timeout
            end
            @req_times << Time.now - t
            if response.status == '200 OK'
              print '.'.green
            else
              print '!'.red
            end
            @package_rec += 1
          rescue Curl::Err::TimeoutError
            print '#'.yellow
            @package_loss += 1
          end

          # Cookie GET with wrong cookies
          begin
            t = Time.now
            response = Curl.get(@uri + '/cookie') do |http|
              http.headers['Cookie'] = 'private=wrong; public=wrong'
              http.timeout = @http_timeout
            end
            @req_times << Time.now - t
            if response.status == '401 Unauthorized'
              print '.'.green
            else
              print '!'.red
            end
            @package_rec += 1
          rescue Curl::Err::TimeoutError
            print '#'.yellow
            @package_loss += 1
          end

          # File GET
          begin
            file_name = '/file.txt'
            t = Time.now
            response = Curl.get(@uri + file_name) do |http|
              http.timeout = @http_timeout
            end
            @req_times << Time.now - t
            file = File.open("#{__dir__}/../files#{file_name}", 'r')
            if response.body == file.read && response.status == '200 OK'
              print '.'.green
            else
              print '!'.red
            end
            @package_rec += 1
          rescue Curl::Err::TimeoutError
            print '#'.yellow
            @package_loss += 1
          end

          # File POST
          begin
            file_name = 'image.jpeg'
            response = Curl::Easy.new(@uri + '/file') do |http|
              http.timeout = @http_timeout
            end
            response.multipart_form_post = true
            t = Time.now
            response.http_post(Curl::PostField.file('uploaded_image', "#{__dir__}/../files/#{file_name}"))
            @req_times << Time.now - t
            if response.status == '200 OK'
              print '.'.green
            else
              print '!'.red
            end
            @package_rec += 1
          rescue Curl::Err::TimeoutError
            print '#'.yellow
            @package_loss += 1
          end
        end
      end
    end

    # Joining threads
    @threads.each {|thread| thread.join}
  end

  def send_results
    Curl.post(@uri + '/exit', { results: @req_times.join(' '), package_loss: @package_loss, package_rec: @package_rec })
  end
end
