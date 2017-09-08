# Руководство по развертыванию приложения

## Преамбула

Подразумевается, что у вас операционная система macOS и установлены пакеты актуальных версий:
- Brew
- Git
- Virtualbox
- Vagrant

## Подготовка окружения
ШАГ 1: Переходим в домашнюю директорию и клонируем репозиторий (команда выпоняется на вашей macOS).
```markdown
cd $HOME && git clone https://github.com/olegbukatchuk/websocket_chat.git
```
ШАГ 2: Переходим в директорию websocket_chat/configs/vagrant/ и создаем 2 виртуальные машины (команда выпоняется на вашей macOS)
```markdown
cd websocket_chat/configs/vagrant/ && vagrant up
```
Ждём примерно 10 минут, пока создаются виртуальные хосты, называться они будут:
- salt (192.168.10.10)
- chat (192.168.10.20)

IP адреса виртуальных машин можно изменить (главное, чтобы оба хоста находились в одной сети) в файлах:
```markdown
$HOME/websocket_chat/configs/vagrant/Vagrantfile
$HOME/websocket_chat/install/configure.sh
```
Кстати, за это время Vagrant сделает за нас всю грязную работу и даже установит на оба хоста нужные salt-роли и конечно настроет их:

- salt (salt-master)
- chat (salt-minion)

Если интересно, как вся эта магия происходит идём и читаем [здесь](https://docs.saltstack.com/en/latest/topics/tutorials/salt_bootstrap.html).

ШАГ 3: Находясь в директории $HOME/websocket_chat/configs/vagrant/ входим внутрь salt-master, таким способом:
```markdown
vagrant ssh salt
```

## Настройка

ШАГ 4: Становимся суперпользователем:
```markdown
sudo -i  
```

ШАГ 5: Теперь следует подружить minion'а с master'ом. Для этого на хосте salt выполним поиск minion'а командой:
```markdown
salt-key -a chat -y
```

Вывод:
```markdown
The following keys are going to be accepted:
minions_pre:
    - chat
Key for minion chat accepted.
```
ШАГ 6: Настраиваем роль (иногда minion не отвечает вовремя и команда завершется неудачей, если такое произошло просто запустите команду предствленную ниже повторно!):
```markdown
salt 'chat' grains.setval roles chat
```
Вывод:
```markdown
chat:
    ----------
    roles:
        chat
```

ШАГ 7: Запускаем deploy (иногда minion не выполняет сразу все states, если такое произошло просто запустите команду предствленную ниже повторно!):
```markdown
salt 'chat' state.highstate
```

Вывод:
```markdown
chat:
----------
          ID: Python PIP
    Function: pkg.installed
        Name: python-pip
      Result: True
     Comment: Package python-pip is already installed
     Started: 21:11:56.325091
    Duration: 292.06 ms
     Changes:
----------
          ID: Update PIP
    Function: cmd.run
        Name: pip install --upgrade pip
      Result: True
     Comment: Command "pip install --upgrade pip" run
     Started: 21:11:56.618608
    Duration: 807.808 ms
     Changes:
              ----------
              pid:
                  17397
              retcode:
                  0
              stderr:
              stdout:
                  Requirement already up-to-date: pip in /usr/lib/python2.7/dist-packages
----------
          ID: Add APT Docker repo
    Function: pkgrepo.managed
        Name: deb https://apt.dockerproject.org/repo debian-stretch main
      Result: True
     Comment: Package repo 'deb https://apt.dockerproject.org/repo debian-stretch main' already configured
     Started: 21:11:57.428561
    Duration: 40.839 ms
     Changes:
----------
          ID: Install Docker
    Function: pkg.installed
        Name: docker-engine
      Result: True
     Comment: Package docker-engine is already installed
     Started: 21:11:57.469552
    Duration: 4.718 ms
     Changes:
----------
          ID: Start Docker Service
    Function: service.running
        Name: docker
      Result: True
     Comment: The service docker is already running
     Started: 21:11:57.475311
    Duration: 37.274 ms
     Changes:
----------
          ID: Docker Python API
    Function: pip.installed
        Name: docker-py
      Result: True
     Comment: All packages were successfully installed
     Started: 21:11:57.781841
    Duration: 3774.136 ms
     Changes:
----------
          ID: Download chat image
    Function: dockerng.image_present
        Name: olegbukatchuk/websocket_chat:1.0
      Result: True
     Comment: Image 'olegbukatchuk/websocket_chat:1.0' was pulled
     Started: 21:12:01.559844
    Duration: 59413.935 ms
     Changes:
              ----------
              Layers:
                  ----------
                  Pulled:
                      - 2cb6694637e7
                      - f38157a2cbde
                      - c45a3e2e6478
                      - cbc63b61d5f1
                      - ad74af05f5a2
                      - f95fb20f25b0
                      - 39e40c2077f2
              Status:
                  Downloaded newer image for olegbukatchuk/websocket_chat:1.0
              Time_Elapsed:
                  59.3498518467
----------
          ID: Spin up a container
    Function: dockerng.running
        Name: websocket_chat
      Result: True
     Comment: Container 'websocket_chat' changed state.. Container 'websocket_chat' was created.
     Started: 21:13:00.974117
    Duration: 1835.105 ms
     Changes:
              ----------
              added:
                  ----------
                  Id:
                      97d809a5fd470968a0c57dc6a12206627cc08912052f863a2da44a3d84012c32
                  Name:
                      websocket_chat
                  Time_Elapsed:
                      0.139441013336
                  Warnings:
                      None
              state:
                  ----------
                  new:
                      running
                  old:
                      None

Summary for chat
------------
Succeeded: 8 (changed=3)
Failed:    0
------------
Total states run:     8
Total run time:  66.206 s
```

ШАГ 8: Проверяем статус контейнера:
```markdown
salt 'chat' cmd.run "docker ps"
```

Вывод:
```markdown
chat:
    CONTAINER ID        IMAGE                              COMMAND                  CREATED              STATUS              PORTS                            NAMES
    b860f639b8ac        olegbukatchuk/websocket_chat:1.0   "./websocket_chat ..."   About a minute ago   Up About a minute   0.0.0.0:80->8080/tcp, 8080/tcp   websocket_chat
```

ШАГ 9: Открываем в браузере страницу приложения:
```markdown
http://192.168.10.20
```

Вот и всё!
