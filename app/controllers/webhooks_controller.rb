require 'net/http'
require 'openssl'
require 'base64'

class WebhooksController < ApplicationController
  SECRET_KEY = 'your_secret_key_here'

  def create
    data = DataModel.new(data_params)

    if data.save
      notify_third_party_apis(data)
      render json: data, status: :created
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  def update
    model = DataModel.find(params[:id])

    if model.update(data_params)
      notify_third_party_apis(model)
      render json: model, status: :ok
    else
      render json: model.errors, status: :unprocessable_entity
    end
  end

  private

  def data_params
    params.require(:data_model).permit(:name, :data)
  end

  def notify_third_party_apis(data)
    third_party_endpoints = ThirdPartyService.endpoints

    third_party_endpoints.each do |endpoint|
      uri = URI(endpoint)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = data.to_json

      sign_request(request)

      http.request(request)
    end
  end

  def sign_request(request)
    string_to_sign = request.body + SECRET_KEY
    hmac = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), SECRET_KEY, string_to_sign)
    signature = Base64.encode64(hmac).strip
    request['X-Signature'] = signature
  end
end
