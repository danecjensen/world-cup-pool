namespace :storage do
  # Headers Active Storage's direct-upload JS sends on the PUT, plus a wildcard
  # so we never miss one. Origins come from APP_HOST (already used elsewhere in
  # production) or an explicit CORS_ALLOWED_ORIGINS (comma-separated) override.
  def s3_credentials
    {
      access_key_id:     ENV["AWS_ACCESS_KEY_ID"]     || ENV["BUCKETEER_AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"] || ENV["BUCKETEER_AWS_SECRET_ACCESS_KEY"],
      region:            ENV["AWS_REGION"]            || ENV["BUCKETEER_AWS_REGION"] || "us-east-1",
      bucket:            ENV["AWS_BUCKET"]            || ENV["BUCKETEER_BUCKET_NAME"]
    }
  end

  def cors_origins
    explicit = ENV["CORS_ALLOWED_ORIGINS"].to_s.split(",").map(&:strip)
    return explicit unless explicit.empty?

    host = ENV["APP_HOST"].to_s.strip
    host.empty? ? [] : ["https://#{host}"]
  end

  desc "Configure bucket CORS so Active Storage direct uploads work from the browser"
  task configure_cors: :environment do
    require "aws-sdk-s3"

    creds = s3_credentials
    if creds[:access_key_id].blank? || creds[:bucket].blank?
      abort "No S3 credentials found. Provision Bucketeer or set AWS_ACCESS_KEY_ID/AWS_BUCKET."
    end

    origins = cors_origins
    if origins.empty?
      abort "No allowed origins. Set APP_HOST=your-app.herokuapp.com (or CORS_ALLOWED_ORIGINS=https://a,https://b)."
    end

    client = Aws::S3::Client.new(
      region: creds[:region],
      access_key_id: creds[:access_key_id],
      secret_access_key: creds[:secret_access_key]
    )

    rule = {
      allowed_headers: ["*"],
      allowed_methods: %w[PUT GET HEAD],
      allowed_origins: origins,
      max_age_seconds: 3600
    }

    begin
      client.put_bucket_cors(
        bucket: creds[:bucket],
        cors_configuration: { cors_rules: [rule] }
      )
      puts "✅ CORS configured on bucket '#{creds[:bucket]}' for: #{origins.join(', ')}"
    rescue Aws::S3::Errors::AccessDenied
      warn <<~MSG
        ❌ Access denied setting CORS on '#{creds[:bucket]}'.
           These credentials can't change the bucket policy (some add-ons restrict this).
           Fall back to proxied uploads instead of direct uploads:
             heroku config:set ACTIVE_STORAGE_DIRECT_UPLOADS=false
           Uploads will route through the dyno (fine for photos and short clips).
      MSG
      exit 1
    end
  end

  desc "Smoke-test the configured storage service with an upload/download/delete round-trip"
  task check: :environment do
    require "openssl"

    service = ActiveStorage::Blob.service
    target  = service.try(:bucket)&.name || service.class.name
    puts "Service: #{service.class} (#{target})"

    key  = "_healthcheck/#{SecureRandom.hex(8)}.txt"
    data = "ok-#{Time.now.to_i}"
    service.upload(key, StringIO.new(data), checksum: OpenSSL::Digest.base64digest("MD5", data))
    roundtrip = service.download(key)
    service.delete(key)

    if roundtrip == data
      puts "✅ Upload + download + delete succeeded — storage is working."
    else
      abort "❌ Round-trip mismatch — storage is misconfigured."
    end
  end
end
