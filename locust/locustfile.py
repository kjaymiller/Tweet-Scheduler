from locust import HttpUser, task


class HelloWorldUser(HttpUser):
    @task
    def test_load(self):
        self.client.get("/")
        self.client.get("/jay")