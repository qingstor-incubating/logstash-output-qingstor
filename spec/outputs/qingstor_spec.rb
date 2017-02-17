# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/qingstor"
require "logstash/event"
require "openssl"
require_relative "./qs_access_helper"
require_relative "./spec_helper"

describe LogStash::Outputs::Qingstor do
  let(:prefix) { "ss/%{server}"}
  let(:event) { LogStash::Event.new({ "server" => "overwatch" }) }
  let(:event_encoded) { "May the code be with you!" }
  let(:events_and_encoded) {{ event => event_encoded}}
  let(:options) {{
      "access_key_id" => ENV['access_key_id'],
      "secret_access_key" => ENV['secret_access_key'],
      "bucket" => ENV['bucket'],
      "region" => ENV['region'],
      "prefix" => prefix
  }}

  after do 
    clean_remote_files
  end 

  it "done work with minimal options" do 
    fetch_event(options, events_and_encoded)
    expect(list_remote_file.size).to eq(1)
  end 

  it "use aes256 to encrpytion in the server side" do 
    cipher = OpenSSL::Cipher::AES256.new(:CBC)
    cipher.encrypt
    key = cipher.random_key
    fetch_event(options.merge({"server_side_encryption_algorithm" => "AES256","customer_key" => key}), events_and_encoded)
    expect(list_remote_file.size).to eq(1)
  end 

  

end 