from django.test import TestCase

# Create your tests here.
from django.contrib.auth.models import User
from product.models import Product
from order.models import Order

class OrderModelTest(TestCase):
    def setUp(self):
        # Cria um usuário de teste
        self.user = User.objects.create_user(username='testuser', password='testpass')
        # Cria alguns produtos de teste
        self.product1 = Product.objects.create(title='Produto 1', price=10.0)
        self.product2 = Product.objects.create(title='Produto 2', price=20.0)

    def test_create_order(self):
        # Cria um pedido
        order = Order.objects.create(user=self.user)
        # Adiciona produtos ao pedido
        order.product.add(self.product1, self.product2)
        # Verifica se o pedido foi criado corretamente
        self.assertEqual(order.user.username, 'testuser')
        self.assertEqual(order.product.count(), 2)
        self.assertIn(self.product1, order.product.all())
        self.assertIn(self.product2, order.product.all())
