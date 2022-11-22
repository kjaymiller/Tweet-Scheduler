import os
import dotenv
from azqueuetweeter import storage, twitter, QueueTweeter

dotenv.load_dotenv('../.azure/31daysofND/.env')

sa = storage.Auth(
        connection_string=os.environ.get("AZURE_STORAGE_CONNECTION_STRING"),
        queue_name=os.environ.get("AZURE_STORAGE_QUEUE_NAME")
)

ta = twitter.Auth(
        consumer_key=os.environ.get("TWITTER_CONSUMER_KEY"),
        consumer_secret=os.environ.get("TWITTER_CONSUMER_SECRET"),
        access_token=os.environ.get("TWITTER_ACCESS_TOKEN"),
        access_token_secret=os.environ.get("TWITTER_ACCESS_TOKEN_SECRET"),
)

queue = QueueTweeter(storage_auth=sa, twitter_auth=ta)
