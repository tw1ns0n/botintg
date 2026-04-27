Файл зависимостей (requirements.txt)
txt
python-telegram-bot==20.7
python-dotenv==1.0.0
Инструкция по установке и запуску
1. Установка зависимостей
bash
# Установка библиотек
pip install python-telegram-bot python-dotenv
2. Получение токена бота
Откройте Telegram и найдите @BotFather

Отправьте команду /newbot

Придумайте имя для бота

Придумайте username (должен заканчиваться на bot)

Скопируйте полученный токен

![Пример получения токена]

3. Настройка и запуск
python
# Вставьте токен в код
TOKEN = "ваш_токен_здесь"

# Или создайте файл .env:
BOT_TOKEN=ваш_токен_здесь
4. Запуск бота
bash
python bot.py
Расширенная версия с AI (используя OpenAI)
python
import openai
from telegram.ext import Application, MessageHandler, filters

class AIBot:
    def __init__(self, api_key):
        openai.api_key = api_key
    
    async def get_ai_response(self, user_message):
        try:
            response = openai.ChatCompletion.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": "Ты полезный помощник на русском языке."},
                    {"role": "user", "content": user_message}
                ],
                max_tokens=150,
                temperature=0.7
            )
            return response.choices[0].message.content
        except Exception as e:
            return f"Ошибка: {str(e)}"

# Использование
# bot = AIBot("your_openai_api_key")
Возможности бота:
✅ Основные функции:

Ответы на вопросы

Понимание команд

Сохранение истории диалога

Приветствие пользователей

✅ Дополнительные возможности:

Интерактивное меню с кнопками

Статистика использования

Контекстные ответы

Обработка ошибок

✅ Команды бота:

/start - начало работы

/help - помощь

/info - информация о боте

/clear - очистка истории

/menu - интерактивное меню
