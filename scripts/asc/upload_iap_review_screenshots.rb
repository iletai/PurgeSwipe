#!/usr/bin/env ruby
# Upload one review screenshot to every in-app purchase of an ASC app that has none yet.
# Usage: bundle exec ruby scripts/asc/upload_iap_review_screenshots.rb <asc_app_id> <image.png>
# Credentials come from ./.env (ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_CONTENT_BASE64); nothing is printed.
require "base64"
require "digest"
require "faraday"
require "json"
require "spaceship"

app_id, image_path = ARGV
abort "usage: #{$PROGRAM_NAME} <asc_app_id> <image.png>" unless app_id && image_path && File.file?(image_path)

env = File.read(File.expand_path("../../.env", __dir__)).scan(/^(ASC_[A-Z0-9_]+)=(.*)$/).to_h.transform_values { |v| v.delete('"') }
token = Spaceship::ConnectAPI::Token.create(
  key_id: env.fetch("ASC_KEY_ID"),
  issuer_id: env.fetch("ASC_ISSUER_ID"),
  key: Base64.decode64(env.fetch("ASC_KEY_CONTENT_BASE64"))
)

API = "https://api.appstoreconnect.apple.com"
conn = Faraday.new(API)

def call(conn, token, verb, path, body = nil)
  res = conn.run_request(verb, path, body && JSON.generate(body), "Authorization" => "Bearer #{token.text}", "Content-Type" => "application/json")
  [res.status, res.body.to_s.empty? ? {} : JSON.parse(res.body)]
end

data = File.binread(image_path)
file_name = File.basename(image_path)

iaps = []
path = "/v1/apps/#{app_id}/inAppPurchasesV2?limit=200&fields%5BinAppPurchases%5D=productId,name"
loop do
  status, json = call(conn, token, :get, path)
  abort "list failed: #{status}" unless status == 200
  iaps += json["data"]
  next_url = json.dig("links", "next")
  break unless next_url

  path = next_url.sub(API, "")
end
puts "#{iaps.size} in-app purchases on app #{app_id}"

# Subscriptions are a separate ASC resource: their review screenshot lives under /v1/subscription*.
subs = []
_, groups = call(conn, token, :get, "/v1/apps/#{app_id}/subscriptionGroups?limit=200")
(groups["data"] || []).each do |g|
  _, list = call(conn, token, :get, "/v1/subscriptionGroups/#{g['id']}/subscriptions?limit=200")
  subs += list["data"] || []
end
puts "#{subs.size} subscriptions on app #{app_id}"

targets = iaps.map { |i| { id: i["id"], name: i.dig("attributes", "productId"), get: "/v2/inAppPurchases/#{i['id']}/appStoreReviewScreenshot",
                           type: "inAppPurchaseAppStoreReviewScreenshots", rel: ["inAppPurchaseV2", "inAppPurchases"], path: "/v1/inAppPurchaseAppStoreReviewScreenshots" } } +
          subs.map { |s| { id: s["id"], name: s.dig("attributes", "productId"), get: "/v1/subscriptions/#{s['id']}/appStoreReviewScreenshot",
                           type: "subscriptionAppStoreReviewScreenshots", rel: ["subscription", "subscriptions"], path: "/v1/subscriptionAppStoreReviewScreenshots" } }

targets.each do |t|
  product_id = t[:name]
  status, existing = call(conn, token, :get, t[:get])
  if status == 200 && existing["data"]
    state = existing.dig("data", "attributes", "assetDeliveryState", "state")
    if state != "FAILED"
      puts "skip #{product_id} (has screenshot, #{state})"
      next
    end
    # A rejected image (e.g. IMAGE_INCORRECT_DIMENSIONS) keeps the IAP in MISSING_METADATA: replace it.
    call(conn, token, :delete, "#{t[:path]}/#{existing.dig('data', 'id')}") unless ENV["DRY_RUN"]
  end

  if ENV["DRY_RUN"]
    puts "would upload #{product_id}"
    next
  end

  status, reserved = call(conn, token, :post, t[:path], {
    data: {
      type: t[:type],
      attributes: { fileName: file_name, fileSize: data.bytesize },
      relationships: { t[:rel][0] => { data: { type: t[:rel][1], id: t[:id] } } }
    }
  })
  abort "reserve failed for #{product_id}: #{status} #{reserved}" unless status == 201

  shot_id = reserved.dig("data", "id")
  reserved.dig("data", "attributes", "uploadOperations").each do |op|
    headers = op["requestHeaders"].to_h { |h| [h["name"], h["value"]] }
    chunk = data.byteslice(op["offset"], op["length"])
    res = Faraday.new.run_request(op["method"].downcase.to_sym, op["url"], chunk, headers)
    abort "upload failed for #{product_id}: #{res.status}" unless res.status.between?(200, 299)
  end

  status, committed = call(conn, token, :patch, "#{t[:path]}/#{shot_id}", {
    data: {
      type: t[:type],
      id: shot_id,
      attributes: { uploaded: true, sourceFileChecksum: Digest::MD5.hexdigest(data) }
    }
  })
  abort "commit failed for #{product_id}: #{status} #{committed}" unless status == 200

  puts "ok   #{product_id} (#{committed.dig('data', 'attributes', 'assetDeliveryState', 'state')})"
end
