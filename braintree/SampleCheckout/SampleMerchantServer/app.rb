require "sinatra"
require "yaml"
require "braintree"
require "json"

config = YAML.load_file("config.yml")[settings.environment.to_s]
Braintree::Configuration.environment = config["braintree_environment"].to_sym
Braintree::Configuration.merchant_id = config["merchant_id"]
Braintree::Configuration.public_key = config["public_key"]
Braintree::Configuration.private_key = config["private_key"]
CSE_KEY = config['cse_key']

get "/" do
  erb :form
end

post "/card/add" do
  result = Braintree::Customer.create({
    "credit_card" => {
      "number" => params[:card_number],
      "cvv" => params[:cvv],
      "expiration_month" => params[:expiration_month],
      "expiration_year" => params[:expiration_year],
      "billing_address" => {
        "postal_code" => params[:zipcode],
      },
      "options" => {
        "venmo_sdk_session" => params[:venmo_sdk_session],
      },
    },
  })

  out = {"success" => result.success?, "error" => nil}

  if !result.success?
    out["error"] = result.message
    halt(422, JSON.generate(out))
  elsif !result.customer.credit_cards[0].venmo_sdk?
    out["error"] = "Card saved to Braintree vault, but could not be saved to Venmo Touch"
    halt(422, JSON.generate(out))
  else
    out["payment_method_token"] = result.customer.credit_cards[0].token
    return JSON.generate(out)
  end
end

post "/card/payment_method_code" do
  result = Braintree::Customer.create({
    "credit_card" => {
      "venmo_sdk_payment_method_code" => params[:payment_method_code],
    },
  })
  out = {"success" => result.success?, "error" => nil}

  if !result.success?
    out["error"] = result.message
    halt(422, JSON.generate(out))
  elsif !result.customer.credit_cards[0].venmo_sdk?
    out["error"] = "Card used successfully, but was not marked as Venmo Touch related"
    halt(422, JSON.generate(out))
  else
    out["payment_method_token"] = result.customer.credit_cards[0].token
    return JSON.generate(out)
  end
end
