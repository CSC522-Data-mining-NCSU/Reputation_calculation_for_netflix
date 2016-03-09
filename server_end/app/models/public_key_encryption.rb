require 'openssl'
require 'base64'

class PublicKeyEncryption < ActiveRecord::Base

	def self.rsa_public_key2(string)
		public_key_file = 'public2.pem'
		public_key = OpenSSL::PKey::RSA.new(File.read(public_key_file))
		encrypted_string = Base64.encode64(public_key.public_encrypt(string))

		return encrypted_string
	end

	def self.rsa_private_key1(cipertext)
		private_key_file = 'private1.pem'
		password = "ZXhwZXJ0aXph\n"
		encrypted_string = cipertext
		private_key = OpenSSL::PKey::RSA.new(File.read(private_key_file),Base64.decode64(password))
		string = private_key.private_decrypt(Base64.decode64(encrypted_string))

		return string
	end

	def self.aes_encrypt(data)
		cipher = OpenSSL::Cipher::AES.new(256, :CBC)
		cipher.encrypt
		key = cipher.random_key
		iv = cipher.random_iv
		cipertext = Base64.encode64(cipher.update(data) + cipher.final)
		return cipertext, key, iv
	end

	def self.aes_decrypt(cipertext, key, iv)
		decipher = OpenSSL::Cipher::AES.new(256, :CBC)
		decipher.decrypt
		decipher.key = key
		decipher.iv = iv
		plain = decipher.update(Base64.decode64(cipertext)) + decipher.final
		return plain
	end
end