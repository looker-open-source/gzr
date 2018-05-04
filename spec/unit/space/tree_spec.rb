require 'lkr/commands/space/tree'

RSpec.describe Lkr::Commands::Space::Tree do
  it "executes `tree` command successfully" do
    require 'sawyer'
    mock_spaces = Array.new
    (1..10).each do |i|
      h = { :id=>i, :name=>"Space #{i}" }
      m = double(Sawyer::Resource, h)
      allow(m).to receive(:to_attrs).and_return(h)
      allow(m).to receive(:name).and_return(h[:name])
      allow(m).to receive(:looks).and_return([])
      allow(m).to receive(:dashboards).and_return([])
      mock_spaces << m
    end
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:search_spaces) do |body|
      return [mock_spaces[0]]
    end
    mock_sdk.define_singleton_method(:space) do |id,body|
      return mock_spaces[id - 1]
    end
    mock_sdk.define_singleton_method(:space_children) do |id,body|
      if (id.to_i < 9) then
        [mock_spaces[id]]
      else
        []
      end
    end

    output = StringIO.new
    options = {}
    command = Lkr::Commands::Space::Tree.new("1",options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq <<-OUT
Space 1
└── Space 2
    └── Space 3
        └── Space 4
            └── Space 5
                └── Space 6
                    └── Space 7
                        └── Space 8
                            └── Space 9
    OUT
  end
end
