if $0 == __FILE__ and not defined?(JRUBY_VERSION)
  raise "task jetty_launch needs to be run under jruby"
end

if defined?(JRUBY_VERSION)
  
require 'java'

JARS = [
  "jetty-6.1.12.rc2.jar",
  "jetty-util-6.1.12.rc2.jar",
  "jruby-complete-1.1.4.jar",
  "jruby-rack-0.9.2.jar",
  "servlet-api-2.5-6.1.12.rc2.jar"
]

$:.unshift File.expand_path(File.dirname(__FILE__) + "/..")
JARS.each do |jar|
  require jar
end

class JettyLauncher
  include Java

  def self.launch
    new.launch
  end

  def launch
    server = org.mortbay.jetty.Server.new
    connector = org.mortbay.jetty.nio.SelectChannelConnector.new
    connector.set_port 8080
    connector.set_host "127.0.0.1"
    server.add_connector connector

    rails_ctx = org.mortbay.jetty.webapp.WebAppContext.new
    rails_ctx.set_context_path "/" + File.basename(File.expand_path("."))
    rails_ctx.set_war "."
    rails_ctx.set_descriptor "./tmp/war/WEB-INF/web.xml"
    rails_ctx.set_override_descriptor File.dirname(__FILE__) + "/override-web.xml"
    rails_ctx.set_extra_classpath classpath

    public_ctx = org.mortbay.jetty.webapp.WebAppContext.new
    public_ctx.set_context_path "/"
    public_ctx.set_war "./public"

    server.add_handler rails_ctx
    server.add_handler public_ctx
    server.set_stop_at_shutdown true

    server.start
  end

  def classpath
    lib_dir = File.expand_path(File.dirname(__FILE__) + "/../")
    JARS.select {|jar| jar =~ /^jruby.*/ }.map {|jar| "#{lib_dir}/#{jar}" }.join(":")
  end
end

end
