from azure.storage.queue import QueueClient
import json


def message_loader(message):
    """Loads a message from the queue"""
    return json.loads(message.content)


def get_messages(queue: QueueClient, count:int=10):
    """Creates a List of the last <COUNT> messages in the queue"""

    msgs = [{'id':msg['id'], "content":message_loader(msg)} for msg in queue.peek_messages(max_messages=count)]
    return msgs

def get_message(id, queue: QueueClient, max_tries=20):

    message = queue.peek_messages()[0]
    attempt = 0

    while message['id'] != id or attempt < max_tries:
        message = queue.peek_messages()[0]

        if message['id'] == id:
            return message

        attempt += 1
        message = queue.receive_message(visibility_timeout=1)


def delete_message(message_id, queue: QueueClient):
    """Deletes a message from the queue"""
    get_message(message_id, queue)
    message = queue.receive_message(visibility_timeout=1)
    return queue.delete_message(message=message, pop_receipt=message['pop_receipt'])
