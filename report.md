## 4 балла
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
### Результаты проверки

Приложение запущено на http://127.0.0.1:8080/.
В ответе возвращается приветствие «Привет из Docker!».
Два запроса POST /increment завершились с HTTP 200.
После них GET / возвращает count: 2.


Логи проверки: [docker.log](docker.log).

## 6 балла

проверочка: пересоздаём контейнер, volume не удаляем
```bash
curl http://127.0.0.1:8080/
curl -X POST http://127.0.0.1:8080/increment
curl -X POST http://127.0.0.1:8080/increment
curl http://127.0.0.1:8080/
sudo docker compose down
sudo docker compose up -d
```
### Результаты проверки

Приложение доступно на порту 8080, приветствие — «Привет из Docker Compose!».
При первом запуске с новым volume счётчик прошёл 0 → 1 → 2.

Пересоздание перепроверено без новых инкрементов. GET / вернул:

| | count | hostname |
| --- | --- | --- |
| до удаления | 2 | fa429f3810bb |
| после запуска | 2 | 78dd06d8117c |

Контейнер новый, а счётчик сохранился в том же volume `hw_3_template_counter-data`.

Логи и ответы GET до и после пересоздания: [compose.log](compose.log).

## 8 баллов

проверочка: два сервиса `app` и `redis`, оба `healthy`. у Redis включён AOF,
volume `redis-data` подключён к `/data`. на компьютере доступен только порт `app`.

сначала увеличили счётчик и пересоздали контейнеры:
```bash
curl -X POST http://127.0.0.1:8080/increment
curl -X POST http://127.0.0.1:8080/increment
curl http://127.0.0.1:8080/
docker compose down
docker compose up -d
curl http://127.0.0.1:8080/
```
до `down` было `count: 2`, после `up` тоже `count: 2`. volume не удаляли.

проверочка: остановили Redis:
```bash
docker compose stop redis
curl -i http://127.0.0.1:8080/healthz
curl -i http://127.0.0.1:8080/readyz
curl -i -X POST http://127.0.0.1:8080/increment
```
получилось: `/healthz` — 200, `/readyz` — 503, `POST /increment` — 503.
`app` продолжал работать, счётчик не изменился.

запустили Redis обратно без перезапуска `app`:
```bash
docker compose start redis
docker compose ps
curl http://127.0.0.1:8080/
curl -X POST http://127.0.0.1:8080/increment
```
после готовности Redis GET вернул `count: 2`, следующий POST — `count: 3`.
логи текущих контейнеров: [redis.log](redis.log).
