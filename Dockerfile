FROM ubuntu:24.04

WORKDIR /usr/local/app

USER root

SHELL ["/bin/bash", "-c"]

# Install the application dependencies
COPY . .
RUN apt-get update -y
RUN apt-get install -y ssdeep python3-venv python3-pip libmagic1
# RUN python3 -m venv .venv
# RUN source .venv/bin/activate
RUN pip install --no-cache-dir --break-system-packages -r requirements.txt 

# CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
EXPOSE 6969
# CMD ["fastapi", "run", "--port", "6969", "--host", "0.0.0.0"]
CMD ["bash"]
