# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'RingToneMaker' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Google Mobile Ads SDK for AdMob integration
  pod 'Google-Mobile-Ads-SDK', '~> 11.0'

  # Optional: Add Firebase Analytics for better ad targeting
  # pod 'Firebase/Analytics'
  
  # Optional: Add AdMob Mediation adapters for higher eCPM
  # pod 'GoogleMobileAdsMediationFacebook'
  # pod 'GoogleMobileAdsMediationUnity'
  # pod 'GoogleMobileAdsMediationAppLovin'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
