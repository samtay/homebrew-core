require "language/node"
require "json"

class Webpack < Formula
  desc "Bundler for JavaScript and friends"
  homepage "https://webpack.js.org/"
  url "https://registry.npmjs.org/webpack/-/webpack-5.93.0.tgz"
  sha256 "3aa06fab2965c33d9b563affe86146bda627b0e872a57ebe94450f17260a9616"
  license "MIT"
  head "https://github.com/webpack/webpack.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "b1b4d919e926f624c348c2b3316311fc44fec1f89b0700f1a54242e650b72b67"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "b1b4d919e926f624c348c2b3316311fc44fec1f89b0700f1a54242e650b72b67"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "b1b4d919e926f624c348c2b3316311fc44fec1f89b0700f1a54242e650b72b67"
    sha256 cellar: :any_skip_relocation, sonoma:         "3529e5e8e2778bcc63c902866fa6e4a86fabca02c76b7719bbafd193bb159d2c"
    sha256 cellar: :any_skip_relocation, ventura:        "3529e5e8e2778bcc63c902866fa6e4a86fabca02c76b7719bbafd193bb159d2c"
    sha256 cellar: :any_skip_relocation, monterey:       "3529e5e8e2778bcc63c902866fa6e4a86fabca02c76b7719bbafd193bb159d2c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "492cfa46076aed87fca3d129ddd2afac68b654c8937eeecbc2d9dfeede27a76c"
  end

  depends_on "node"

  resource "webpack-cli" do
    url "https://registry.npmjs.org/webpack-cli/-/webpack-cli-5.1.4.tgz"
    sha256 "0d5484af2d1547607f8cac9133431cc175c702ea9bffdf6eb446cc1f492da2ac"
  end

  def install
    (buildpath/"node_modules/webpack").install Dir["*"]
    buildpath.install resource("webpack-cli")

    cd buildpath/"node_modules/webpack" do
      system "npm", "install", *Language::Node.local_npm_install_args, "--legacy-peer-deps"
    end

    # declare webpack as a bundledDependency of webpack-cli
    pkg_json = JSON.parse(File.read("package.json"))
    pkg_json["dependencies"]["webpack"] = version
    pkg_json["bundleDependencies"] = ["webpack"]
    File.write("package.json", JSON.pretty_generate(pkg_json))

    system "npm", "install", *Language::Node.std_npm_install_args(libexec)

    bin.install_symlink libexec/"bin/webpack-cli"
    bin.install_symlink libexec/"bin/webpack-cli" => "webpack"

    # Replace universal binaries with their native slices
    deuniversalize_machos
  end

  test do
    (testpath/"index.js").write <<~EOS
      function component() {
        const element = document.createElement('div');
        element.innerHTML = 'Hello' + ' ' + 'webpack';
        return element;
      }

      document.body.appendChild(component());
    EOS

    system bin/"webpack", "bundle", "--mode", "production", "--entry", testpath/"index.js"
    assert_match "const e=document.createElement(\"div\");", File.read(testpath/"dist/main.js")
  end
end
