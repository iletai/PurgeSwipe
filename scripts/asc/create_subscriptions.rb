#!/usr/bin/env ruby
# Create the Pro subscription group + monthly/yearly subscriptions (prices in every territory via USD equalization,
# yearly gets a free-trial intro offer). Idempotent per piece. Never submits for review.
# Usage: bundle exec ruby scripts/asc/create_subscriptions.rb <asc_app_id> <env_bundle_id>
require "base64"
require "faraday"
require "json"
require "spaceship"

app_id, bundle_id = ARGV
abort "usage: #{$PROGRAM_NAME} <asc_app_id> <env_bundle_id>" unless app_id && bundle_id
env = File.read(File.expand_path("../../.env", __dir__)).scan(/^(ASC_[A-Z0-9_]+)=(.*)$/).to_h.transform_values { |v| v.delete('"') }
token = Spaceship::ConnectAPI::Token.create(key_id: env.fetch("ASC_KEY_ID"), issuer_id: env.fetch("ASC_ISSUER_ID"), key: Base64.decode64(env.fetch("ASC_KEY_CONTENT_BASE64")))
API = "https://api.appstoreconnect.apple.com"
conn = Faraday.new(API)

def call(conn, token, verb, path, body = nil)
  res = conn.run_request(verb, path, body && JSON.generate(body), "Authorization" => "Bearer #{token.text}", "Content-Type" => "application/json")
  [res.status, res.body.to_s.empty? ? {} : JSON.parse(res.body)]
end

def pages(conn, token, path)
  rows = []
  while path
    status, json = call(conn, token, :get, path)
    abort "GET #{path} failed: #{status} #{json}" unless status == 200
    rows += json["data"]
    path = json.dig("links", "next")&.sub(API, "")
  end
  rows
end

def post(conn, token, path, type, attributes, rels)
  status, body = call(conn, token, :post, path, { data: { type: type, attributes: attributes, relationships: rels } })
  abort "POST #{path}: #{status} #{body}" unless status == 201
  body["data"]["id"]
end

def rel(type, id) = { data: { type: type, id: id } }

LOCALES = {
  "en-US" => { group: "PurgeSwipe Pro", monthly: ["Pro Monthly", "Unlimited deletions, no ads"], yearly: ["Pro Yearly", "Unlimited deletions, no ads, save more"] },
  "vi" => { group: "PurgeSwipe Pro", monthly: ["Pro theo tháng", "Xóa không giới hạn, không quảng cáo"], yearly: ["Pro theo năm", "Xóa không giới hạn, không quảng cáo"] }
}.freeze
PRODUCTS = [
  { key: :monthly, id: "pro.monthly", name: "PurgeSwipe Pro Monthly", period: "ONE_MONTH", price: 4.99, level: 2 },
  { key: :yearly, id: "pro.yearly", name: "PurgeSwipe Pro Yearly", period: "ONE_YEAR", price: 19.99, level: 1, trial: "THREE_DAYS" }
].freeze

group = pages(conn, token, "/v1/apps/#{app_id}/subscriptionGroups").find { |g| g.dig("attributes", "referenceName") == "PurgeSwipe Pro" }
group_id = group ? group["id"] : post(conn, token, "/v1/subscriptionGroups", "subscriptionGroups", { referenceName: "PurgeSwipe Pro" }, { app: rel("apps", app_id) })
have = pages(conn, token, "/v1/subscriptionGroups/#{group_id}/subscriptionGroupLocalizations").map { |l| l.dig("attributes", "locale") }
LOCALES.each do |loc, t|
  next if have.include?(loc)
  post(conn, token, "/v1/subscriptionGroupLocalizations", "subscriptionGroupLocalizations", { locale: loc, name: t[:group] }, { subscriptionGroup: rel("subscriptionGroups", group_id) })
end
puts "group #{group_id}"

territories = pages(conn, token, "/v1/territories?limit=200").map { |t| t["id"] }
existing = pages(conn, token, "/v1/subscriptionGroups/#{group_id}/subscriptions").to_h { |s| [s.dig("attributes", "productId"), s["id"]] }

PRODUCTS.each do |p|
  product_id = "#{bundle_id}.#{p[:id]}"
  sub_id = existing[product_id] || post(conn, token, "/v1/subscriptions", "subscriptions",
    { name: p[:name], productId: product_id, subscriptionPeriod: p[:period], groupLevel: p[:level], familySharable: false },
    { group: rel("subscriptionGroups", group_id) })

  have = pages(conn, token, "/v1/subscriptions/#{sub_id}/subscriptionLocalizations").map { |l| l.dig("attributes", "locale") }
  LOCALES.each do |loc, t|
    next if have.include?(loc)
    name, desc = t[p[:key]]
    abort "#{product_id} #{loc}: name > 30 or description > 45 chars" if name.length > 30 || desc.length > 45
    post(conn, token, "/v1/subscriptionLocalizations", "subscriptionLocalizations", { locale: loc, name: name, description: desc }, { subscription: rel("subscriptions", sub_id) })
  end

  _, avail = call(conn, token, :get, "/v1/subscriptions/#{sub_id}/subscriptionAvailability")
  unless avail.dig("data", "id")
    post(conn, token, "/v1/subscriptionAvailabilities", "subscriptionAvailabilities", { availableInNewTerritories: true },
      { subscription: rel("subscriptions", sub_id), availableTerritories: { data: territories.map { |t| { type: "territories", id: t } } } })
  end

  if pages(conn, token, "/v1/subscriptions/#{sub_id}/prices?limit=200").empty?
    usd = pages(conn, token, "/v1/subscriptions/#{sub_id}/pricePoints?filter%5Bterritory%5D=USA&limit=200").find { |pt| (pt.dig("attributes", "customerPrice").to_f - p[:price]).abs < 0.001 }
    abort "#{product_id}: no USD price point #{p[:price]}" unless usd
    points = [usd] + pages(conn, token, "/v1/subscriptionPricePoints/#{usd['id']}/equalizations?limit=200&include=territory")
    points.each do |pt|
      terr = pt.dig("relationships", "territory", "data", "id") || "USA"
      post(conn, token, "/v1/subscriptionPrices", "subscriptionPrices", { preserveCurrentPrice: false },
        { subscription: rel("subscriptions", sub_id), subscriptionPricePoint: rel("subscriptionPricePoints", pt["id"]), territory: rel("territories", terr) })
    end
  end

  # ASC requires one intro offer per territory (the territory relationship is mandatory).
  if p[:trial]
    done = pages(conn, token, "/v1/subscriptions/#{sub_id}/introductoryOffers?include=territory&limit=200").map { |o| o.dig("relationships", "territory", "data", "id") }
    (territories - done).each do |t|
      post(conn, token, "/v1/subscriptionIntroductoryOffers", "subscriptionIntroductoryOffers",
        { duration: p[:trial], offerMode: "FREE_TRIAL", numberOfPeriods: 1 }, { subscription: rel("subscriptions", sub_id), territory: rel("territories", t) })
    end
  end
  puts "ok   #{product_id} $#{p[:price]}#{p[:trial] ? ' + trial' : ''}"
end
