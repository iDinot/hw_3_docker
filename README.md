## ДЗ по Docker

# 4 балла

сборка контейнера
```bash
sudo docker build -f app.dockerfile -t hw3-app .
```

запуск контейнера
```bash
sudo docker run -d \
  --name hw3-counter \
  -p 127.0.0.1:8080:8000 \
  -e GREETING='Привет из Docker!' \
  hw3-app
```
проверочка: запрос, два инкремента, запрос
```bash
curl http://127.0.0.1:8080/
curl -X POST http://127.0.0.1:8080/increment
curl -X POST http://127.0.0.1:8080/increment
curl http://127.0.0.1:8080/
```
логи сохраняем в файлик:
```bash
sudo docker logs hw3-counter > docker.log 2>&1
```

## 6 баллов

настройки из примера:
```bash
cp .env.example .env
```
в `.env` меняем `APP_PORT` — порт на компьютере, `GREETING` — приветствие.
если `.env` уже есть, копировать заново не надо.

запуск через композ, старый контейнер останавливаем чтобы освободить порт:
```bash
sudo docker stop hw3-counter
sudo docker compose up -d --build
```

проверочка: два инкремента, запоминаем значение и пересоздаём контейнер
```bash
curl -X POST http://127.0.0.1:8080/increment
curl -X POST http://127.0.0.1:8080/increment
echo 'до пересоздания' > compose.log
curl http://127.0.0.1:8080/ | tee -a compose.log
echo >> compose.log
sudo docker compose logs --no-color app >> compose.log 2>&1
sudo docker compose down
sudo docker compose up -d
```
после запуска приложения ещё раз смотрим счётчик:
```bash
echo 'после пересоздания' >> compose.log
curl http://127.0.0.1:8080/ | tee -a compose.log
echo >> compose.log
```
если меняли порт в `.env`, в запросах тоже меняем 8080 на свой.

база хранится в volume `counter-data`, подключённом к `/data`.
значение должно сохраниться. `down -v` не используем — он удалит данные.

логи нового контейнера дописываем в тот же файлик:
```bash
sudo docker compose logs --no-color app >> compose.log 2>&1
```
результаты в [report.md](report.md).

## 8 баллов

теперь в `compose.yaml` два сервиса: `app` и `redis`. приложение хранит счётчик
в Redis, а тот записывает данные в volume `redis-data`. наружу открыт только
порт приложения. проверка на 6 баллов выше была со старым вариантом на SQLite.
`app` подключается к `redis://redis:6379/0`, готовность обоих сервисов проверяется healthcheck.

запуск:
```bash
sudo docker compose up -d --build
sudo docker compose ps
```
ждём, пока оба сервиса станут `healthy`.

проверочка: записываем значение, удаляем контейнеры и запускаем заново:
```bash
curl -X POST http://127.0.0.1:8080/increment
curl -X POST http://127.0.0.1:8080/increment
curl http://127.0.0.1:8080/
sudo docker compose down
sudo docker compose up -d
curl http://127.0.0.1:8080/
```
`down -v` не используем, иначе удалится volume.
после повторного `up` ждём, пока оба сервиса снова станут `healthy`.

проверочка без Redis:
```bash
sudo docker compose stop redis
curl -i http://127.0.0.1:8080/healthz
curl -i http://127.0.0.1:8080/readyz
curl -i -X POST http://127.0.0.1:8080/increment
```
потом возвращаем Redis, `app` не перезапускаем:
```bash
sudo docker compose start redis
sudo docker compose ps
curl http://127.0.0.1:8080/
curl -X POST http://127.0.0.1:8080/increment
```
после `start` ждём готовности Redis. логи текущих контейнеров:
```bash
sudo docker compose logs --no-color app redis > redis.log 2>&1
```
результаты в [report.md](report.md), логи в [redis.log](redis.log).
