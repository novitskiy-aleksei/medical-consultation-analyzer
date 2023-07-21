require 'azure/storage/blob'

class AudioRecordsController < ApplicationController

  def initialize
    @storage_client = StorageService.new
  end

  def create
    begin
      container_name = ENV['AZURE_AUDIO_CONTAINER']

      # Get the file from the request
      file = params[:file]
      raise 'No file provided' if file.nil?

      # prepare file name
      original_filename = file.original_filename.gsub(/[^0-9A-Za-z.\-]/, '_')
      recording_id = SecureRandom.hex
      blob_name = recording_id + File.extname(original_filename)

      @storage_client.upload(container_name, blob_name, file.read)

      trigger_transcribe(recording_id)

      render json: {status: 'success', recording_id: recording_id}, status: :ok
    rescue => e
      render json: {status: 'error', message: e.message}, status: :unprocessable_entity
    end
  end

  private

  def trigger_transcribe(recording_id)
    # trigger transcribe/analyse job and don't wait for response
    Thread.new do
      uri = URI.parse("#{ENV['SPEECH_ANALYZER_SERVICE_HOST']}/transcribe")

      header = {'Content-Type': 'application/json'}
      payload = { recording_id: recording_id }

      # Create the HTTP objects
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = payload.to_json

      # Send the request
      http.request(request)
    end

  end
end
