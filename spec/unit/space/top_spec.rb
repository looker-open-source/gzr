require 'lkr/commands/space/top'

RSpec.describe Lkr::Commands::Space::Top do
  it "executes `top` command successfully" do
    output = StringIO.new
    options = {}
    command = Lkr::Commands::Space::Top.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
