require 'net/http'
require 'digest'
require 'uri'

# SHA256 checksums of the Consul releases used by the tests, from https://releases.hashicorp.com/consul/<version>/consul_<version>_SHA256SUMS
# Add the checksums when changing the Consul version, a download that does not match is rejected.
CONSUL_SHA256 = {
  '1.22.6' => {
    'linux_amd64'  => '5c2d67c6a364512b3dd0646eaf8bb58fa2fd6b9c890e2f374475deab2a6ec648',
    'darwin_amd64' => 'fc9c25898282f51e8e9b1a50f5f77bfbd0ae8556882fbf4338fa9f5f66b68a3c'
  }
}

# Downloads over verified TLS (up to a few redirects) and only keeps the file if the checksum matches
def verified_download(url, target, sha256, redirects = 3)
  uri = URI.parse(url)
  raise "Refusing to download over #{uri.scheme}" unless uri.scheme == 'https'

  Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
    http.request(Net::HTTP::Get.new(uri.request_uri)) do |response|
      case response
      when Net::HTTPRedirection
        raise "Too many redirects for #{url}" if redirects <= 0
        return verified_download(response['location'], target, sha256, redirects - 1)
      when Net::HTTPSuccess
        digest = Digest::SHA256.new
        File.open(target, 'wb') do |file|
          response.read_body do |chunk|
            digest << chunk
            file.write(chunk)
          end
        end
        unless digest.hexdigest == sha256
          File.delete(target)
          raise "Checksum mismatch for #{url}: expected #{sha256}, got #{digest.hexdigest}"
        end
      else
        raise "Download of #{url} failed: #{response.code} #{response.message}"
      end
    end
  end
end
