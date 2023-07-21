require 'azure/storage/blob'

class StorageService
  def initialize
    account_name = ENV['AZURE_STORAGE_ACCOUNT']
    access_key = ENV['AZURE_STORAGE_ACCESS_KEY']

    @client = Azure::Storage::Blob::BlobService.create(
      storage_account_name: account_name,
      storage_access_key: access_key
    )
  end

  def upload(target, filename, file_content)
    @client.create_block_blob(target, filename, file_content)
  end

  def download(target, filename)
    @client.get_blob(target, filename)
  end
end