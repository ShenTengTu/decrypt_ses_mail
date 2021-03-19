# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv/load'
require 'aws-sdk'

# Creates a directory if it doesn't exist.
# @param string [String] path of directory.
def mkdir(string)
  Dir.mkdir(string) unless Dir.exist?(string)
end

# Updates Configuration of AWS.
def update_aws_config
  Aws.config.update({
                      credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY']),
                      region: ENV['AWS_REGION']
                    })
end

def s3_encryption_client
  Aws::S3::EncryptionV2::Client.new(
    key_wrap_schema: :kms_context,
    content_encryption_schema: :aes_gcm_no_padding,
    security_profile: :v2_and_legacy,
    kms_key_id: ENV['KMS_KEY_ID']
  )
end

# List S3 objects whose keys have the specified prefix
# @param bucket_name [String] The name of the bucket.
# @param key_prefix [String] The specified prefix.
def list_object_with_prefix(bucket_name, key_prefix)
  s3_client = Aws::S3::Client.new
  params = { bucket: bucket_name }
  if s3_client.wait_until(:bucket_exists, params)
    resp = s3_client.list_objects_v2(params.update({ prefix: key_prefix }))
    resp.contents.reject { |entry| entry.key.end_with?('AMAZON_SES_SETUP_NOTIFICATION') }
  end
rescue Aws::Waiters::Errors::WaiterFailed => e
  puts "Error getting object: #{e.message}"
end

# Downloads an object  from an AWS S3 bucket.
# @param bucket_name [String] The name of the bucket.
# @param object_key [String] The name of the object to download.
# @param local_path [String] The path on your local computer to download
def object_downloaded?(bucket_name, object_key, local_path)
  puts "download '#{object_key}' ..."
  s3_encryption_client.get_object({ bucket: bucket_name, key: object_key, response_target: local_path })
rescue StandardError => e
  puts "Error getting object: #{e.message}"
end

def main
  update_aws_config
  bucket_name = ENV['S3_BUCKET']
  s3_key_prefix = ENV['S3_KEY_PREFIX']
  reports = list_object_with_prefix(bucket_name, s3_key_prefix)
  mkdir("#{Dir.pwd}/#{s3_key_prefix}")
  reports.each do |report|
    local_path = "#{Dir.pwd}/#{report.key}.eml"
    object_downloaded?(bucket_name, report.key, local_path) unless File.exist?(local_path)
  end
end

main if $PROGRAM_NAME == __FILE__
