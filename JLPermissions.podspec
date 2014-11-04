Pod::Spec.new do |s|
  s.name             = "JLPermissions"
  s.version          = "2.0.0"
  s.summary          = "User permission dialogs."
  s.description      = <<-DESC
                       Ask the user for permissions before iOS does increasing the chance of acceptance on future requests.
                       DESC
  s.homepage         = "https://github.com/jlaws/JLPermissions"
  s.license          = 'MIT'
  s.author           = { "Joe Laws" => "joe.laws@gmail.com" }
  s.source           = { :git => "https://github.com/jlaws/JLPermissions.git", :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'JLPermissions'
  s.default_subspecs = 'Core'

  s.subspec 'Core' do |c|
    s.source_files = 'JLPermissions/JLPermissionsCore.?', 'JLPermissions/JLPermissionsCore+Internal.h'
  end

  s.subspec 'Calendar' do |c|
    c.dependency 'JLPermissions/Core'
    c.source_files = 'JLPermissions/JLCalendarPermission.?'
    c.frameworks = 'EventKit'
  end

  s.subspec 'Contacts' do |p|
    p.dependency 'JLPermissions/Core'
    p.source_files = 'JLPermissions/JLContactsPermission.?'
    p.frameworks = 'AddressBook'
  end

  s.subspec 'Facebook' do |p|
    p.dependency 'JLPermissions/Core'
    p.source_files = 'JLPermissions/JLFacebookPermission.?'
    p.frameworks = 'Accounts'
  end

  s.subspec 'Health' do |p|
    p.dependency 'JLPermissions/Core'
    p.source_files = 'JLPermissions/JLHealthPermission.?'
    p.frameworks = 'HealthKit'
  end

  s.subspec 'Location' do |p|
    p.dependency 'JLPermissions/Core'
    p.source_files = 'JLPermissions/JLLocationPermission.?'
    p.frameworks = 'CoreLocation'
  end

  s.subspec 'Microphone' do |p|
    p.dependency 'JLPermissions/Core'
    p.source_files = 'JLPermissions/JLMicrophonePermission.?'
    p.frameworks = 'AVFoundation'
  end

  s.subspec 'Notification' do |p|
    p.dependency 'JLPermissions/Core'
    p.source_files = 'JLPermissions/JLNotificationPermission.?'
  end

  s.subspec 'Photos' do |p|
    p.dependency 'JLPermissions/Core'
    p.source_files = 'JLPermissions/JLPhotosPermission.?'
    p.frameworks = 'AssetsLibrary'
  end

  s.subspec 'Reminders' do |p|
    p.dependency 'JLPermissions/Core'
    p.source_files = 'JLPermissions/JLRemindersPermission.?'
    p.frameworks = 'EventKit'
  end

  s.subspec 'Twitter' do |p|
    p.dependency 'JLPermissions/Core'
    p.source_files = 'JLPermissions/JLTwitterPermission.?'
    p.frameworks = 'Accounts'
  end

end
