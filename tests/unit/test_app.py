import pytest
from app import create_app  # Import the application factory function

@pytest.fixture
def client():
    app = create_app()  # Initialize the app
    app.config['TESTING'] = True  # Enable testing mode for the app
    
    with app.test_client() as client:  # Use the test client to simulate requests
        yield client
#Verifies the creation and configuration of the test client
def test_config(client):
   
    assert client









