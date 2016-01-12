Pod::Spec.new do |s|
  s.name             = "JLPermissions"
  s.version          = "2.2.8"
  s.summary          = "User permission dialogs."
  s.description      = <<-DESC
                       Ask the user for permissions before iOS does increasing the chance of acceptance on future requests.
                       DESC
  s.homepage         = "https://github.com/jlaws/JLPermissions"
  s.license          = 'MIT'
  s.author           = { "Joe Laws" => "joe.laws@gmail.com" }
  s.source           = { :git => "https://github.com/jlaws/JLPermissions.git", :tag => s.version.to_s }
  s.dependency       'DBPrivacyHelper', '0.6.3'
  s.platform         = :ios, '7.0'
  s.requires_arc     = true

  s.subspec 'Core' do |ss|
    ss.source_files = 'JLPermissions/JLPermissionsCore*'
  end

  s.subspec 'Calendar' do |ss|
    ss.dependency 'JLPermissions/Core'
    ss.source_files = 'JLPermissions/JLCalendarPermission.?'
    ss.frameworks = 'EventKit'
  end

  s.subspec 'Camera' do |ss|
    ss.dependency 'JLPermissions/Core'
    ss.source_files = 'JLPermissions/JLCameraPermission.?'
    ss.frameworks = 'AVFoundation'
  end

  s.subspec 'Contacts' do |ss|
    ss.dependency 'JLPermissions/Core'
    ss.source_files = 'JLPermissions/JLContactsPermission.?'
    ss.frameworks = 'AddressBook'
  end

  s.subspec 'Facebook' do |ss|
    ss.dependency 'JLPermissions/Core'
    ss.source_files = 'JLPermissions/JLFacebookPermission.?'
    ss.frameworks = 'Accounts'
  end

  s.subspec 'Health' do |ss|
    ss.dependency 'JLPermissions/Core'
    ss.source_files = 'JLPermissions/JLHealthPermission.?'
    ss.frameworks = 'HealthKit'
  end

  s.subspec 'Location' do |ss|
    ss.dependency 'JLPermissions/Core'
    ss.source_files = 'JLPermissions/JLLocationPermission.?'
    ss.frameworks = 'CoreLocation'
  end

  s.subspec 'Microphone' do |ss|
    ss.dependency 'JLPermissions/Core'
    ss.source_files = 'JLPermissions/JLMicrophonePermission.?'
    ss.frameworks = 'AVFoundation'
  end

  s.subspec 'Notification' do |ss|
    ss.dependency 'JLPermissions/Core'
    ss.source_files = 'JLPermissions/JLNotificationPermission.?'
  end

  s.subspec 'Photos' do |ss|
    ss.dependency 'JLPermissions/Core'
    ss.source_files = 'JLPermissions/JLPhotosPermission.?'
    ss.frameworks = 'AssetsLibrary'
  end

  s.subspec 'Reminders' do |ss|
    ss.dependency 'JLPermissions/Core'
    ss.source_files = 'JLPermissions/JLRemindersPermission.?'
    ss.frameworks = 'EventKit'
  end

  s.subspec 'Twitter' do |ss|
    ss.dependency 'JLPermissions/Core'
    ss.source_files = 'JLPermissions/JLTwitterPermission.?'
    ss.frameworks = 'Accounts'
  end

end
