from django.core.urlresolvers import reverse
from django.test import Client
from django.test import TestCase

# Create your tests here.

class ViewsTest(TestCase):
    def setUp(self):
        self.client = Client()
        
    def test_hello_should_work(self):
        response = self.client.get(reverse('core_hello'))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content, 'Hello World')

    def test_echo_should_work(self):
        # status 200
        response = self.client.get(reverse('core_echo'))
        self.assertEqual(response.status_code, 200)

        # status 500
        response = self.client.get(reverse('core_echo') + '?code=500')
        self.assertEqual(response.status_code, 500)
        
        # headers
        response = self.client.get(reverse('core_echo') + '?header=Content-Type%3Aapplication%2Fx-www-form-urlencoded%3B%20charset%3Dutf-8')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response['Content-Type'], 'application/x-www-form-urlencoded; charset=utf-8')
        
        response = self.client.get(reverse('core_echo') + '?header=Content-Type%3Aapplication%2Fx-www-form-urlencoded%3B%20charset%3Dutf-8&header=MyKey%3AMyValue')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response['Content-Type'], 'application/x-www-form-urlencoded; charset=utf-8')
        self.assertEqual(response['MyKey'], 'MyValue')
        
        # content and encoding        
        response = self.client.get(reverse('core_echo') + '?content=hello')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content, 'hello')
        
        response = self.client.get(reverse('core_echo') + '?content=%E4%BD%A0%E5%A5%BD&encoding=utf8')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content, '\xe4\xbd\xa0\xe5\xa5\xbd')

        response = self.client.get(reverse('core_echo') + '?content=%E4%BD%A0%E5%A5%BD&encoding=gb2312')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content, '\xc4\xe3\xba\xc3')
        