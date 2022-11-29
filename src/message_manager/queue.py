import os
from azqueuetweeter import storage, twitter, QueueTweeter


sa = storage.Auth(
        connection_string=os.environ.get("azurestorageconnectionstring"),
        queue_name=os.environ.get("azurestoragequeuename")
)

ta = twitter.Auth(
        consumer_key=os.environ.get("twitterconsumerkey"),
        consumer_secret=os.environ.get("twitterconsumersecret"),
        access_token=os.environ.get("twitteraccesstoken"),
        access_token_secret=os.environ.get("twitteraccesstokensecret"),
)

queue = QueueTweeter(storage_auth=sa, twitter_auth=ta)
