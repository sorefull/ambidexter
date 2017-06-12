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

    # Setting eterations count
    print "Input eterations count: ".green
    @each_count = $stdin.gets.chomp.to_i
    @each_count = 1 if @each_count.zero?

    # Setting eterations count
    print "Input threads count: ".green
    @threads_count = $stdin.gets.chomp.to_i
    @threads_count = 1 if @threads_count.zero?

    # Building link
    @uri = "http://#{@ip}:#{@port}"

    # Thread and time arrays
    @req_times = []
    @threads = []
  end

  def test
    @threads_count.times do
      @threads << Thread.new do
        @each_count.times do
          # Raw root GET
          t = Time.now
          response = Curl.get(@uri)
          @req_times << Time.now - t
          if response.status == '200 OK'
            print '.'.green
          else
            print '!'.red
          end

          # Root POST with correct params
          t = Time.now
          response = Curl.post(@uri, { name: 'Oleg', github_nickname: 'sorefull' })
          @req_times << Time.now - t
          if response.status == '202 Accepted'
            print '.'.green
          else
            print '!'.red
          end

          # Root POST with wrong params
          t = Time.now
          response = Curl.post(@uri, { name: '', github_nickname: '' })
          @req_times << Time.now - t
          if response.status == '401 Unauthorized'
            print '.'.green
          else
            print '!'.red
          end

          # Lorem GET with body check
          t = Time.now
          response = Curl.get(@uri + '/lorem')
          @req_times << Time.now - t
          if response.body == LoremIpsum.lorem
            print '.'.green
          else
            print '!'.red
          end

          # Lorem GET with params
          t = Time.now
          response = Curl.get(@uri + '/lorem', { length: 10 })
          @req_times << Time.now - t
          if response.body == LoremIpsum.lorem[0..10]
            print '.'.green
          else
            print '!'.red
          end

          # Cookie GET with correct cookies
          t = Time.now
          response = Curl.get(@uri + '/cookie') do |http|
            http.headers['Cookie'] = 'private=asdfg; public=gijj'
          end
          @req_times << Time.now - t
          if response.status == '200 OK'
            print '.'.green
          else
            print '!'.red
          end

          # Cookie GET with wrong cookies
          t = Time.now
          response = Curl.get(@uri + '/cookie') do |http|
            http.headers['Cookie'] = 'private=wrong; public=wrong'
          end
          @req_times << Time.now - t
          if response.status == '401 Unauthorized'
            print '.'.green
          else
            print '!'.red
          end

          # File GET
          file_name = '/file.txt'
          t = Time.now
          response = Curl.get(@uri + file_name)
          @req_times << Time.now - t
          file = File.open("#{__dir__}/../files#{file_name}", 'r')
          if response.body == file.read && response.status == '200 OK'
            print '.'.green
          else
            print '!'.red
          end

          # File POST
          file_name = 'image.jpeg'
          response = Curl::Easy.new(@uri + '/file')
          response.multipart_form_post = true
          t = Time.now
          response.http_post(Curl::PostField.file('uploaded_image', "#{__dir__}/../files/#{file_name}"))
          @req_times << Time.now - t
          if response.status == '200 OK'
            print '.'.green
          else
            print '!'.red
          end
        end
      end
    end

    # Joining threads
    @threads.each {|thread| thread.join}
  end

  def result
    @req_times
  end
end
