FROM ubuntu:24.04
EXPOSE 6969

SHELL ["/bin/bash", "-c"]

USER root
RUN apt-get update -y
RUN apt-get install -y ssdeep python3-venv python3-pip libmagic1

RUN useradd -ms /bin/bash app
USER app
WORKDIR /home/app/
COPY . .

RUN python3 -m venv .venv
RUN source .venv/bin/activate
RUN pip install --no-cache-dir --break-system-packages -r requirements.txt 

# CMD ["fastapi", "run", "--port", "6969", "--host", "0.0.0.0"]
CMD ["bash"]
