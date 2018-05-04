require 'lkr/commands/look/import'

RSpec.describe Lkr::Commands::Look::Import do
  it "executes `import` command successfully" do
    output = StringIO.new
    file = nil
    options = {}
    command = Lkr::Commands::Look::Import.new(file, options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
