Pod::Spec.new do |s|
  s.name         = 'NodeMobile'
  s.version      = '0.1.8'
  s.summary      = 'Node.js for Mobile Apps'

  s.description  = <<-DESC.strip_heredoc
                    [Node.js for Mobile Apps](https://code.janeasystems.com/nodejs-mobile) - A toolkit for integrating Node.js into mobile applications.
  DESC

  s.homepage     = 'https://code.janeasystems.com/nodejs-mobile'
  s.license      = { type: 'Mixed', file: 'LICENSE' }

  s.documentation_url  = 'https://code.janeasystems.com/nodejs-mobile/getting-started-ios'

  s.author             = 'Janea Systems'

  s.ios.deployment_target = '9.0'

  s.source = { git: 'https://github.com/janeasystems/nodejs-mobile.git',
               tag: "nodejs-mobile-v#{s.version}" }

  s.vendored_frameworks = 'out_ios/Release-universal/NodeMobile.framework'

  s.prepare_command = <<-CMD.strip_heredoc
  tools/ios_framework_prepare.sh
  CMD
end
