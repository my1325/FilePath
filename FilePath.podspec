Pod::Spec.new do |s|

 s.name             = "FilePath"
 s.version           = "0.0.1"
 s.summary         = "provide tool to read or write property list file and json file"
 s.homepage        = "https://github.com/my1325/FilePath.git"
 s.license            = "MIT"
 s.platform          = :ios, "11.0"
 s.authors           = { "mayong" => "1173962595@qq.com" }
 s.source             = { :git => "https://github.com/my1325/FilePath.git", :tag => "#{s.version}" }
 s.swift_version = '5'
 s.source_files = 'Sources/FilePath/*.swift'

end