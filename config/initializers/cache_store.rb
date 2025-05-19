if Rails.env.production?
  Rails.application.configure do
    config.action_controller.perform_caching = true

    config.active_record.cache_versioning = true

    config.active_record.collection_cache_versioning = true
  end
end
