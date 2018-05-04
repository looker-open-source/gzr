require 'lkr/commands/space/top'

RSpec.describe Lkr::Commands::Space::Top do
  it "executes `top` command successfully" do
    require 'sawyer'
    mock_spaces = Array.new
    (1..6).each do |i|
      h = {
        :id=>i,
        :name=>"Space #{i}",
        :is_shared_root=>i==1,
        :is_users_root=>i==2,
        :is_root=>i==3,
        :is_user_root=>i==4,
        :is_embed_shared_root=>i==5,
        :is_embed_users_root=>i==5,
      }
      m = double(Sawyer::Resource, h)
      allow(m).to receive(:to_attrs).and_return(h)
      allow(m).to receive(:name).and_return(h[:name])
      allow(m).to receive(:is_shared_root).and_return(h[:is_shared_root])
      allow(m).to receive(:is_users_root).and_return(h[:is_uses_root])
      allow(m).to receive(:is_root).and_return(h[:is_root])
      allow(m).to receive(:is_user_root).and_return(h[:is_user_root])
      allow(m).to receive(:is_embed_shared_root).and_return(h[:is_embed_shared_root])
      allow(m).to receive(:is_embed_users_root).and_return(h[:is_embed_users_root])
      mock_spaces << m
    end
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:all_spaces) do |body|
      return mock_spaces
    end

    output = StringIO.new
    options = {}
    command = Lkr::Commands::Space::Top.new(options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq <<-OUT
+--+-------+--------------+-------------+-------+------------+--------------------+-------------------+
|id|name   |is_shared_root|is_users_root|is_root|is_user_root|is_embed_shared_root|is_embed_users_root|
+--+-------+--------------+-------------+-------+------------+--------------------+-------------------+
| 1|Space 1|true          |false        |false  |false       |false               |false              |
| 3|Space 3|false         |false        |true   |false       |false               |false              |
| 4|Space 4|false         |false        |false  |true        |false               |false              |
| 5|Space 5|false         |false        |false  |false       |true                |true               |
+--+-------+--------------+-------------+-------+------------+--------------------+-------------------+
    OUT
  end
end
