FROM python:3.7
COPY unschedule.py /root/unschedule.py
RUN pip install requests
CMD ["python3", "/root/unschedule.py"]
