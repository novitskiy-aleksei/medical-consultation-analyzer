from flask import Flask, request, jsonify
from azure.storage.blob import BlobServiceClient
import os
import whisper, openai
import logging, json
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
# logging.basicConfig(level=logging.DEBUG)

# set API key for GPT
openai.api_key = os.getenv('OPENAI_API_KEY')

# set connection string for Azure Bucket
# az_blob_connect_str = os.getenv('AZURE_BLOB_CONNECT_STRING')
blob_service_client = BlobServiceClient.from_connection_string(os.getenv('AZURE_BLOB_CONNECT_STRING'))

# Load the whisper model
model = whisper.load_model('base.en')


@app.route('/transcribe', methods=['POST'])
def transcribe():
    # Retrieve the parameters from the request
    recording_id = request.json.get('recording_id')
    # language = request.json.get('language')

    # Download the audio file from Azure Blob Storage
    blob_client = blob_service_client.get_blob_client("audio-container", recording_id)
    with open(recording_id, 'wb') as download_file:
        download_file.write(blob_client.download_blob().readall())

    # Transcribe the audio
    transcription = model.transcribe(recording_id)

    # Check if transcription was successful
    if not 'text' in transcription:
        return jsonify({
            'success': False,
            'message': 'Failed to transcribe the audio.'
        }), 400

    transcription_text = transcription['text']
    analyzed_transcription = analyze(transcription_text)

    upload_text(recording_id, transcription_text, analyzed_transcription)

    # Return the output of the command
    return jsonify({
        'success': True,
        'analysis': analyzed_transcription,
        'transcription': transcription_text
    })

def analyze(transcription):
    return openai.ChatCompletion.create(
        model="gpt-3.5-turbo-16k",
        messages=[
            {
                "role": "system",
                "content": "You will be provided with a transcription of a meeting with the doctor, "
                           "and your tasks are:"
                           "1. To summarize the meeting and provide action points "
                           "2. Detect any aggressive talking, harassment, or causing harm. In this case - describe the situation so human can review it."
            },
            {
                "role": "user",
                "content": transcription
            }
        ],
        temperature=0,
        max_tokens=2048,
        top_p=1.0,
        frequency_penalty=0.0,
        presence_penalty=0.0
    )

def upload_text(id, transcription, analysis):
    try:
        extension = '.wav'
        transcription_file_name = f"{id}_transcription{extension}"
        analysis_file_name = f"{id}_analysis{extension}"

        # Create a blob client.
        ts_blob_client = blob_service_client.get_blob_client('text-container', transcription_file_name)
        an_blob_client = blob_service_client.get_blob_client('text-container', analysis_file_name)

        # Upload the string data to the blob.
        ts_blob_client.upload_blob(transcription)
        an_blob_client.upload_blob(analysis)

        return jsonify({'message': 'Upload successful.'}), 200
    except Exception as e:
        return jsonify({'message': 'Upload failed.', 'error': str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5005)
