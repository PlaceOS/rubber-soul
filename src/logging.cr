require "placeos-log-backend"

require "./constants"

module RubberSoul::Logging
  ::Log.progname = APP_NAME

  # Logging configuration
  log_level = RubberSoul.production? ? ::Log::Severity::Info : ::Log::Severity::Debug
  log_backend = PlaceOS::LogBackend.log_backend
  namespaces = ["action-controller.*", "place_os.*", "rubber_soul.*"]

  ::Log.setup do |config|
    config.bind "*", :warn, log_backend
    namespaces.each do |namespace|
      config.bind namespace, log_level, log_backend
    end
  end

  PlaceOS::LogBackend.register_severity_switch_signals(
    production: RubberSoul.production?,
    namespaces: namespaces,
    backend: log_backend,
  )
end
