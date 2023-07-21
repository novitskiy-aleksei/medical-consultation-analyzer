# Medical Consultation Analyzer

Plug-in service, which receives audio file through Ruby on Rails API, transcribe it using Whisper AI. Then it produces a summary and detects 'red flags' during a conversation using GPT-3.5

## Repo structure

- [/infrastructure](/infrastructure) - Terraform scripts for getting the environment up and basic deployment
- [/api](/api) - Ruby on Rails REST API, as entrypoint which will handle communication with clients
- [/transcription-service](/transcription-service) - Service which contains the Whisper model to transcribe audio into the text and call GPT external API for summarization. Covered with basic Flask API.

# Development

Use docker-compose.yml to spin up services locally and Terraform scripts to deploy them into the cloud

