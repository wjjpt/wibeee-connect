#!/usr/bin/env ruby

require 'json'
require 'kafka'
require 'socket'

$stdout.sync = true
@name = "wibeee2k"
if ENV['KAFKA_TOPIC'].nil?
    puts "Error: It is mandatory to configure KAFKA_TOPIC and KAFKA_TOPIC_OUTPUT environment variables"
    sleep 10
    exit 1
end
config_hash = { :kafka_broker => ENV['KAFKA_BROKER'].nil? ? "127.0.0.1" : ENV['KAFKA_BROKER'],
                :kafka_port => ENV['KAFKA_PORT'].nil? ? "9092" : ENV['KAFKA_PORT'],
                :wibeee_port => ENV['WIBEEE_PORT'].nil? ? "8080" : ENV['WIBEEE_PORT'],
                :kafka_topic => ENV['KAFKA_TOPIC'],
                :kafka_client_id => @name }

def w2k(config_hash)
    begin
        server = TCPServer.new config_hash[:wibeee_port]
        kclient = Kafka.new(seed_brokers: ["#{config_hash[:kafka_broker]}:#{config_hash[:kafka_port]}"], client_id: @name)
        while session = server.accept
            request = session.gets
            method, full_path = request.split(' ')
            path, query = full_path.split('?')
        
            j = { "timestamp" => Time.now.to_i }
            query.split('&').each do |x|
                k, v = x.split('=')
                j[k] = v
            end
            puts j.to_json unless ENV['DEBUG'].nil?
            kclient.deliver_message("#{j.to_json}",topic: config_hash[:kafka_topic])
        
            session.print "HTTP/1.1 200\r\n"
            session.print "Content-Type: text/html\r\n"
            session.print "\r\n"
            session.close
        end
    rescue Exception => e
        puts "Exception: #{e.class}, message: #{e.message}"
        puts "Disconnecting from brokers"
        kclient.shutdown
        puts "[#{@name}] Stopping wibeee2k poc thread"
    end 
end

Signal.trap('INT') { throw :sigint }

catch :sigint do
    while true
        puts "[#{@name}] Starting wibeee2k thread"
        t1 = Thread.new{w2k(config_hash)}
        t1.join
    end
end

puts "Exiting from wibeee2k"

## vim:ts=4:sw=4:expandtab:ai:nowrap:formatoptions=croqln:
