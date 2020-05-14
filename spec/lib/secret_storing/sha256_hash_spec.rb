# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::Doorkeeper::SecretStoring::Sha256Hash do
  let(:instance) { double("instance") }

  let(:hash_function) do
    ->(input) { ::Digest::SHA256.hexdigest(input) }
  end

  describe "#transform_secret" do
    it "raises" do
      expect(described_class.transform_secret("foo")).to eq hash_function.call("foo")
    end
  end

  describe "#restore_secret" do
    it "raises" do
      expect { described_class.restore_secret(instance, :token) }.to raise_error(NotImplementedError)
    end
  end

  describe "#allows_restoring_secrets?" do
    it "does not allow it" do
      expect(described_class.allows_restoring_secrets?).to eq false
    end
  end

  describe "validate_for" do
    it "allows for valid model" do
      expect(described_class.validate_for(:application)).to eq true
      expect(described_class.validate_for(:token)).to eq true
    end

    it "raises for invalid model" do
      expect { described_class.validate_for(:wat) }.to raise_error(ArgumentError, /can not be used for wat/)
    end
  end

  describe "secret_matches?" do
    it "compares input with #transform_secret" do
      expect(described_class.secret_matches?("input", "input")).to eq false
      expect(described_class.secret_matches?("a", hash_function.call("a"))).to eq true
    end
  end
end
