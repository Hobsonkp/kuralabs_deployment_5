FROM python:latest

WORKDIR /url_dock

COPY ./Application .

RUN pip install -r requirements.txt pip install gunicorn

EXPOSE 5000

CMD gunicorn --bind 0.0.0.0:5000 application:app