class TranscriptionController < ApplicationController

  def initialize
    @storage_client = StorageService.new
  end

  def show
    container_name = ENV['AZURE_TEXT_CONTAINER']
    record_id = params[:record_id]

    raise 'No record_id provided' if record_id.nil?

    tr_file, transcription = @storage_client.download(container_name, "#{record_id}_transcription.txt")
    an_file, analysis = @storage_client.download(container_name, "#{record_id}_analysis.txt")

    render json: {
      status: 'success',
      transcription: transcription,
      analysis: analysis
    }, status: :ok
  rescue => e
    render json: {status: 'error', message: e.message}, status: :unprocessable_entity
  end
end
