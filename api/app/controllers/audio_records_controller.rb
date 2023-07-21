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

      render json: {status: 'success', recording_id: recording_id}, status: :ok
    rescue => e
      render json: {status: 'error', message: e.message}, status: :unprocessable_entity
    end
  end
end
