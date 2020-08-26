# G2R Market Mobile

Мобильное приложение маркета

## Что уже есть в приложении:

- [x] Авторизация и регистрация
- [x] Просмотр каталога товаров
- [ ] Просмотр каталога запросов
- [x] Добавление в избранное и просмотр содержимого
- [x] Просмотр личных данных и возможность их редактирования
- [x] Список профилей
- [x] Выбор профиля
- [ ] Редактирование профиля
- [ ] Создание профиля и его подтверждение
- [ ] Просмотр магазинов поставщиков
- [ ] Создание и редактирование товаров/запросов
- [ ] Создание моделей товара
- [ ] Чат
- - [x] Пуши через рэббит
- - [x] Сообщения от техподдержки
- - [x] Сообщения от профиля
- - [x] Внешка для чата
- - [ ] Внешка для настроек чата
- - [ ] Добавление в контакты
- - [x] Получение уведомлений когда приложение закрыто

## Баги

- [x] После авторизации не сохранялась авторизация на некоторых страницах не ставилась
- [x] Кнопка назад работала без сохранения предыдущего состояния
- [x] В фоне не приходят пуши
- [x] В просмотре профиля ошибки из-за отсутствующих картинок, если открывать после выбора чат, то придётся перезапускать
- [x] После успешной авторизации секунда задержки
- [ ] При редактировании аккаунта если закрыть клавиатуру, то сбрасывается введённый текст


## Что нужно знать перед сборкой

 - Для IOS:
   - - Сделать flutter build
   - - Затем в /ios/Podfile прописать строку: <br>
    `target 'Runner' do use_frameworks!`
   - - Настроить Firebase
   - - - https://firebase.google.com/docs/cloud-messaging/ios/certs?hl=ru