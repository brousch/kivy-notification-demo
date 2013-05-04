# Display a notification suitable for the platform being run on
# Usage:
# from components.notification import Notification
# Notification('what you want said').notify()

from kivy.utils import platform

platform = platform()


class NotificationBase():
    def __init__(self, title='', message=''):
        self.title = title
        self.message = message
        
    def notify(self):
        ''' Echoes the message to the console '''
        print('Notification: {}\n{}'.format(self.title, self.message))


class NotificationAndroid(NotificationBase):
    def notify(self):
        ''' Displays a native Android notification '''
        from jnius import autoclass
        AndroidString = autoclass('java.lang.String')
        PythonActivity = autoclass('org.renpy.android.PythonActivity')
        NotificationBuilder = autoclass('android.app.Notification$Builder')
        Drawable = autoclass('net.clusterbleep.notificationdemo.R$drawable')
        icon = Drawable.icon
        noti = NotificationBuilder(PythonActivity.mActivity)
        #noti.setDefaults(Notification.DEFAULT_ALL)
        noti.setContentTitle(AndroidString(self.title.encode('utf-8')))
        noti.setContentText(AndroidString(self.message.encode('utf-8')))
        noti.setSmallIcon(icon)
        noti.setAutoCancel(True)
        nm = PythonActivity.mActivity.getSystemService(PythonActivity.NOTIFICATION_SERVICE)
        nm.notify(0,noti.build())


class NotificationLinux(NotificationBase):
    def notify(self):
        ''' Displays a notification via libnotify '''
        import notify2
        notify2.init (self.title)
        noti = notify2.Notification (self.title,
                                      self.message,
                                      "dialog-information")
        noti.show ()


# UNTESTED !!!
# From http://stackoverflow.com/questions/12202983/working-with-mountain-lions-notification-center-using-pyobjc
class NotificationOsx(NotificationBase):
    def notify(self):
        import Foundation
        import objc
        import AppKit
        NSUserNotification = objc.lookUpClass('NSUserNotification')
        NSUserNotificationCenter = objc.lookUpClass('NSUserNotificationCenter')
        notification = NSUserNotification.alloc().init()
        notification.setTitle_(str(self.title))
        #notification.setSubtitle_(str(subtitle))
        notification.setInformativeText_(self.message)
        notification.setSoundName_("NSUserNotificationDefaultSoundName")
        #notification.setHasActionButton_(False)
        #notification.setOtherButtonTitle_("View")
        #notification.setUserInfo_({"action":"open_url", "value":url})
        NSUserNotificationCenter.defaultUserNotificationCenter().setDelegate_(self)
        NSUserNotificationCenter.defaultUserNotificationCenter().scheduleNotification_(notification)


# UNTESTED !!!
# It will at least also need detection of pre-requisites
class NotificationWindows(NotificationBase):
    def notify(self):
        ''' Displays a notification using the win32 API '''
        from win32 import balloontip
        ballontip.balloon_tip(self.title, self.message)


# Default to console
Notification = NotificationBase

# Platform-specific searches
if platform == "android":
    Notification = NotificationAndroid
    
if platform == "macosx":
    Notification = NotificationOsx
    
elif platform == "linux":
    Notification = NotificationLinux
    
elif platform == "win":
    Notification = NotificationWindows
