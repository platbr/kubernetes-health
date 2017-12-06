require "spec_helper"

RSpec.describe Kubernetes::Health do
  it "has a version number" do
    expect(Kubernetes::Health::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
