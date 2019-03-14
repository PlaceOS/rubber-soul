# Application dependencies
require "action-controller"
require "engine-models"
require "habitat"

# stdlib
require "http/client"
require "logger"
require "uri"

# Application code
require "./controllers/base"
require "./controllers/*"

require "./rubber-soul/*"

# Server required after application controllers
require "action-controller/server"

# Add handlers that should run before your application
ActionController::Server.before(
  HTTP::LogHandler.new(STDOUT),
  HTTP::ErrorHandler.new(ENV["SG_ENV"]? != "production"),
  HTTP::CompressHandler.new
)

LOG = Logger.new

# ACA engine configuration... necessary if using models?
ACA_ENGINE_DB = "engine"

APP_NAME = "rubber-soul"
VERSION  = "1.0.0"
