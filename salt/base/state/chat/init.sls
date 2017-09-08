include:
  - docker

"Download chat image":
  dockerng.image_present:
    - name: 'olegbukatchuk/websocket_chat:1.0'
    - require:
      - pip: "Docker Python API"

"Spin up a container":
  dockerng.running:
    - name: websocket_chat
    - image: olegbukatchuk/websocket_chat:1.0
    - hostname: chat
    - tty: True
    - interactive: True
    - ports:
      - 8080/tcp
    - port_bindings:
      - 80:8080/tcp
    - dns:
      - 8.8.8.8
      - 8.8.4.4
    - require:
      - dockerng: "Download chat image"
