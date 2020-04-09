RSpec.describe Sidekiq::ConcurrencySafety do
  it "has a version number" do
    expect(Sidekiq::ConcurrencySafety::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
