from django.test import TestCase

# Create your tests here.
from product.models import Category, Product

class CategoryModelTest(TestCase):
    def setUp(self):
        self.category = Category.objects.create(
            title="Ficção",
            slug="ficcao",
            description="Livros de ficção",
            active=True
        )

    def test_category_creation(self):
        self.assertEqual(self.category.title, "Ficção")
        self.assertEqual(self.category.slug, "ficcao")
        self.assertEqual(self.category.description, "Livros de ficção")
        self.assertTrue(self.category.active)

    def test_category_str(self):
        self.assertEqual(str(self.category), "Ficção")

class ProductModelTest(TestCase):
    def setUp(self):
        self.category1 = Category.objects.create(
            title="Aventura", slug="aventura", description="Livros de aventura"
        )
        self.category2 = Category.objects.create(
            title="Terror", slug="terror", description="Livros de terror"
        )
        self.product = Product.objects.create(
            title="O Hobbit",
            description="Uma aventura fantástica",
            price=50,
            active=True
        )
        self.product.category.add(self.category1, self.category2)

    def test_product_creation(self):
        self.assertEqual(self.product.title, "O Hobbit")
        self.assertEqual(self.product.description, "Uma aventura fantástica")
        self.assertEqual(self.product.price, 50)
        self.assertTrue(self.product.active)

    def test_product_categories(self):
        categories = self.product.category.all()
        self.assertEqual(categories.count(), 2)
        self.assertIn(self.category1, categories)
        self.assertIn(self.category2, categories)

    def test_product_str(self):
        self.assertEqual(str(self.product), "O Hobbit")