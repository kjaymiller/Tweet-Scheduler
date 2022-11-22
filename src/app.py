from flask import (
        Flask,
        render_template,
        flash,
        redirect,
        url_for,
)
import json

from uuid import uuid4

from message_manager import messages
from message_manager.queue import queue as q
from message_manager.form  import AddMessage
import time


try:
    q.queue.create_queue()
except:
    pass


app = Flask(__name__)
app.secret_key = str(uuid4())

def rebuild(template_name:str):
    msgs = messages.get_messages(queue = q.queue)
    form = AddMessage()
    return render_template(template_name, msgs=msgs, form=form)



@app.route('/')
def index():
    return rebuild('index.html')


@app.route('/send/<message_id>', methods=['POST'])
def tweet(message_id):
    messages.get_message(id=message_id, queue=q.queue)
    q.send_next_message(
        message_transformer=lambda msg: {"text": json.loads(msg)['msg']},
        delete_after=True,
        )
    return rebuild('message.html')


@app.route('/message', methods=["GET", "POST"])
def add_message():
    #Because we are parsing the form data we do not use rebuild
    form = AddMessage()

    if form.validate_on_submit():
        q.queue_message(json.dumps({
                "msg": form.msg.data,
                "date": form.date.data.isoformat()
                })
        )
        flash("Message Queued", "success")
        return redirect(url_for('add_message'))

    for error in form.errors:
        flash(error, "error")

    msgs = messages.get_messages(queue=q.queue)
    return render_template('message.html', msgs=msgs, form=form)

@app.route('/clear_all', methods=["POST"])
def clear_all():
    q.queue.clear_messages()
    flash("Queue Cleared", "success")
    return rebuild('message.html')

@app.route('/delete/<message_id>', methods=["POST"])
def delete_one(message_id):
    messages.delete_message(message_id=message_id, queue=q.queue)
    flash("Message Deleted", "success")
    time.sleep(1.1) # Gives the queue time to update before we rebuild the page
    return rebuild('message.html')


if __name__ == '__main__':
    app.run() 