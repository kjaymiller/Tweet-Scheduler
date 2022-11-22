from flask_wtf import FlaskForm
from wtforms import (
        TextAreaField,
        DateTimeLocalField,
)

from datetime import datetime 

class AddMessage(FlaskForm):
    msg = TextAreaField(
            "Message",
            render_kw={"style": "width:100%"},
    )
    date = DateTimeLocalField(
            "Send Automatically at",
            default=datetime.now(),
            format='%Y-%m-%dT%H:%M',
    )
