cask "bignotify" do
  version "1.0.0"
  sha256 :no_check # You'll need to generate this with: shasum -a 256 BigNotify-1.0.0.zip

  url "https://github.com/aurbano/bignotify/releases/download/v#{version}/BigNotify-#{version}.zip"

  name "BigNotify"
  desc "Calendar alert manager that shows prominent meeting notifications"
  homepage "https://github.com/aurbano/bignotify"

  depends_on macos: ">= :ventura"

  app "BigNotify.app"

  uninstall quit: "com.bignotify.app"

  zap trash: [
    "~/Library/Preferences/com.bignotify.app.plist",
    "~/Library/Application Support/BigNotify",
  ]
end
