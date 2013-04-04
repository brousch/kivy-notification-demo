import kivy
kivy.require('1.6.0')

from kivy.app import App
from kivy.properties import ObjectProperty
from kivy.uix.boxlayout import BoxLayout

from components.notification import Notification


class NotificationDemo(BoxLayout):
    notifications_received = ObjectProperty(None)
    notification_title = ObjectProperty(None)
    notification_text = ObjectProperty(None)

    def notify(self, title, msg):
        self.notifications_received.text += '\n' + title + ': ' + msg
        Notification(title, msg).notify()

class NotificationDemoApp(App):
    def build(self):
        return NotificationDemo()
    

if __name__ == '__main__':
    NotificationDemoApp().run()
