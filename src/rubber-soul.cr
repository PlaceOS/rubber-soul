require "option_parser"

require "./config"
require "./server"

# Server defaults
server_host = ENV["RUBBER_SOUL_HOST"]? || "127.0.0.1"
server_port = ENV["RUBBER_SOUL_PORT"]?.try(&.to_i) || 3000

cluster = false
process_count = 1

# Application defaults
backfill = false
reindex = true

# Command line options
OptionParser.parse(ARGV.dup) do |parser|
  parser.banner = "Usage: #{APP_NAME} [arguments]"

  # RubberSoul Options
  parser.on("--backfill", "Perform backfill") { backfill = true }
  parser.on("--reindex", "Perform reindex") { reindex = true }

  # Rethinkdb Options,
  # Access through models themselves.
  #
  # parser.on("--rethink-host HOST", "RethinkDB host") do |host|
  #   RubberSoul::Rethink.settings.host = host
  # end
  # parser.on("--rethink-port PORT", "RethinkDB port") do |port|
  #   RubberSoul::Rethink.settings.port = port.to_i
  # end

  # Elasticsearch Options
  parser.on("--elastic-host HOST", "Elasticsearch host") do |host|
    RubberSoul::Elastic.settings.host = host
  end
  parser.on("--elastic-port PORT", "Elasticsearch port") do |port|
    RubberSoul::Elastic.settings.port = port.to_i
  end

  # Spider-gazelle configuration
  parser.on("-b HOST", "--bind=HOST", "Specifies the server host") { |h| server_host = h }
  parser.on("-p PORT", "--port=PORT", "Specifies the server port") { |p| server_port = p.to_i }

  parser.on("-w COUNT", "--workers=COUNT", "Specifies the number of processes to handle requests") do |w|
    cluster = true
    process_count = w.to_i
  end

  parser.on("-r", "--routes", "List the application routes") do
    ActionController::Server.print_routes
    exit 0
  end

  parser.on("-v", "--version", "Display the application version") do
    puts "#{APP_NAME} v#{VERSION}"
    exit 0
  end

  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit 0
  end
end

# Ensure elastic is available
RubberSoul::Elastic.ensure_elastic!

# DB and table presence ensured by rethinkdb orm

if backfill || reindex
  # Perform backfill/reindex and then exit

  raise RubberSoul::Error.new("Cannot reindex and backfill tables") if reindex && backfill

  # TODO: Model names currently hardcoded
  # TODO: Change once models export the model names
  tm = RubberSoul::TableManager.new([ControlSystem, Module, Dependency, Zone])

  # Push all documents in RethinkDB to ES
  tm.backfill_tables if backfill
  # Recreate ES indexes from existing RethinkDB documents
  tm.reindex_all if reindex
else
  # Otherwise, run server

  puts "Launching #{APP_NAME} v#{VERSION}"
  RubberSoul::Server.start(server_host, server_port, cluster, process_count)
end

# Shutdown message
puts "#{APP_NAME} signing off :}\n"
