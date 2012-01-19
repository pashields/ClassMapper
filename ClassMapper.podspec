Pod::Spec.new do |s|
  s.name     = 'ClassMapper'
  s.version  = '0.0.1'
  s.license  = 'MIT'
  s.summary  = 'Simple and extensible mapping between your classes and NSDictionary'
  s.author   = { 'Pat Shields' => 'yeoldefortran@gmail.com' }
  s.homepage = 'https://github.com/pashields/ClassMapper'

  s.source   = { :git => 'git://github.com/pashields/ClassMapper.git' }

  s.platform = :ios

  s.source_files = ['ClassMapper/*.{h,m}', 'ClassMapper/Categories/*.{h,m}']

  s.requires_arc = true
end
