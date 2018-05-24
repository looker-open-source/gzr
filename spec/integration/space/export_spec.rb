RSpec.describe "`gzr space export` command", type: :cli do
  it "executes `space export --help` command successfully" do
    output = `gzr space export --help`
    expect(output).to eq <<-OUT
Usage:
  gzr space export SPACE_ID

Options:
  -h, [--help], [--no-help]  # Display usage information
      [--dir=DIR]            # Directory to store output tree
                             # Default: .
      [--tar=TAR]            # Tar file to store output
      [--tgz=TGZ]            # TarGZ file to store output

Export a space, including all child looks, dashboards, and spaces.
    OUT
  end
end
