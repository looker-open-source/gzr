require 'lkr/commands/dashboard/import'

RSpec.describe Lkr::Commands::Dashboard::Import do
  it "executes `import` command successfully" do
    output = StringIO.new
    options = {}
    command = Lkr::Commands::Dashboard::Import.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
