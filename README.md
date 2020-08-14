# G2R Market Mobile

Мобильное приложение маркета

## Что уже есть в приложении:

- [x] Авторизация и регистрация
- [x] Просмотр каталога товаров
- [ ] Просмотр каталога запросов
- [x] Добавление в избранное и просмотр содержимого
- [x] Просмотр личных данных и возможность их редактирования
- [x] Список профилей
- [ ] Выбор профиля и его редактирование
- [ ] Создание профиля и его подтверждение
- [ ] Просмотр магазинов поставщиков
- [ ] Создание и редактирование товаров/запросов
- [ ] Чат
- - [x] Пуши через рэббит
- - [x] Сообщения от техподдержки
- - [ ] Внешка для чата c техподдержкой
- - [ ] Внешка для чата c профилями
- - [x] Получение уведомлений когда приложение закрыто

## Баги
- [x] После авторизации не сохранялась авторизация на некоторых страницах не ставилась
- [x] Кнопка назад работала без сохранения предыдущего состояния
- [ ] В фоне не приходят пуши
- [ ] После успешной авторизации секунда задержки
- [ ] При редактировании аккаунта если закрыть клавиатуру, то сбрасывается введённый текст


## Что нужно знать перед сборкой

 - Для IOS:
    - Сделать flutter build
    - Затем в /ios/Podfile прописать строку: <br>
    `target 'Runner' do use_frameworks!`