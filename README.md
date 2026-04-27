import logging
import random
from datetime import datetime
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import Application, CommandHandler, MessageHandler, CallbackQueryHandler, filters, ContextTypes

# Настройка логирования
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)
logger = logging.getLogger(__name__)

# База знаний для ответов на вопросы
FAQ = {
    "привет": ["Привет! 👋 Как я могу вам помочь?", "Здравствуйте! Чем могу быть полезен?", "Приветствую! Задавайте вопросы."],
    "как дела": ["У меня всё отлично! А у вас?", "Хорошо! Спасибо, что спросили.", "Отлично, готов помогать!"],
    "что ты умеешь": [
        "Я умею:\n• Отвечать на вопросы\n• Помогать с информацией\n• Вести диалог\n• Выполнять простые команды"
    ],
    "помощь": [
        "Доступные команды:\n/start - начать работу\n/help - показать помощь\n/info - информация о боте\n/clear - очистить историю\n/about - о боте"
    ],
    "спасибо": ["Пожалуйста! Всегда рад помочь! 😊", "Обращайтесь!", "Рад был помочь!"],
    "пока": ["До свидания! Было приятно пообщаться! 👋", "Всего хорошего!", "До новых встреч!"],
    "имя": ["Меня зовут AnswerBot! Я виртуальный помощник.", "Я AnswerBot - ваш персональный консультант."],
    "кто тебя создал": ["Я создан с помощью Python и библиотеки python-telegram-bot.", "Мой создатель - разработчик, который любит Python!"]
}

# Шаблоны для ответов на неизвестные вопросы
FALLBACK_ANSWERS = [
    "Интересный вопрос! 🤔 Дайте мне подумать...",
    "Хороший вопрос! Я постоянно учусь и буду знать ответ в следующий раз.",
    "Извините, я еще не знаю ответ на этот вопрос.",
    "Попробуйте переформулировать вопрос.",
    "Я бы порекомендовал поискать информацию в интернете.",
    "Сейчас я специализируюсь на общих вопросах."
]

# Интеллектуальные ответы (простые шаблоны)
INTELLIGENT_RESPONSES = {
    "погода": "Я не могу смотреть погоду в реальном времени, но вы можете узнать её в приложении погоды или на сайте гидрометцентра! 🌤️",
    "время": lambda: f"Текущее время: {datetime.now().strftime('%H:%M:%S')} ⏰",
    "дата": lambda: f"Сегодня: {datetime.now().strftime('%d.%m.%Y')} 📅",
    "как тебя зовут": "Меня зовут AnswerBot! А вас?",
    "бот": "Да, я бот-помощник. Чем могу помочь?",
    "python": "Python - отличный язык программирования! Я сам написан на Python 🐍",
    "telegram": "Telegram - отличная платформа для общения и создания ботов!",
    "язык": "Я общаюсь на русском языке, но понимаю и другие языки.",
    "твой возраст": "Я родился только что вместе с этим кодом! 🎂",
    "любишь": "Я люблю помогать людям и отвечать на их вопросы! ❤️"
}

# История диалога для каждого пользователя
user_histories = {}

class AnswerBot:
    def __init__(self):
        self.name = "AnswerBot"
        self.version = "1.0"
    
    async def start(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Обработчик команды /start"""
        user = update.effective_user
        welcome_text = f"""
Привет, {user.first_name}! 👋

Я {self.name} - виртуальный помощник версии {self.version}
Я здесь, чтобы отвечать на твои вопросы и помогать!

Вот что я умею:
✅ Отвечать на вопросы
✅ Поддерживать диалог
✅ Помогать с информацией

Просто напиши мне сообщение, и я постараюсь ответить!

Используй /help для списка всех команд
        """
        await update.message.reply_text(welcome_text)
        
        # Инициализация истории для пользователя
        user_id = update.effective_user.id
        if user_id not in user_histories:
            user_histories[user_id] = []
    
    async def help_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Обработчик команды /help"""
        help_text = """
📚 *Доступные команды:*

/start - Начать общение
/help - Показать это сообщение
/info - Информация о боте
/clear - Очистить историю диалога
/about - О разработчике
/menu - Показать меню

💡 *Советы:*
• Задавайте простые и конкретные вопросы
• Я лучше понимаю общие вопросы
• Используйте ключевые слова

*Примеры вопросов:*
• Привет! Как дела?
• Что ты умеешь?
• Который час?
• Расскажи о Python
        """
        await update.message.reply_text(help_text, parse_mode='Markdown')
    
    async def info_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Обработчик команды /info"""
        info_text = f"""
🤖 *Информация о боте*

*Имя:* {self.name}
*Версия:* {self.version}
*Язык:* Python + python-telegram-bot
*Возможности:* Ответы на вопросы, диалог, простые вычисления

*Статистика:*
• Обслужено пользователей: {len(user_histories)}
• База знаний: {len(FAQ)} тем
• Время работы: С момента запуска

*Ограничения:*
- Не ищу в интернете
- Не сохраняю личные данные
- Только текстовое общение
        """
        await update.message.reply_text(info_text, parse_mode='Markdown')
    
    async def clear_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Очистка истории диалога"""
        user_id = update.effective_user.id
        if user_id in user_histories:
            user_histories[user_id] = []
            await update.message.reply_text("История диалога очищена! 🧹")
        else:
            await update.message.reply_text("История и так пуста!")
    
    async def about_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """О разработчике"""
        about_text = """
ℹ️ *О разработчике*

Этот бот создан как пример Telegram бота на Python.
Он демонстрирует возможности:
• Обработка команд
• Анализ сообщений
• Контекстные ответы

*Технологии:*
• Python 3.7+
• python-telegram-bot v20+
• JSON для хранения данных

*Исходный код:*
Доступен по запросу у разработчика.

*Контакты:*
По вопросам разработки ботов обращайтесь к создателю.
        """
        await update.message.reply_text(about_text, parse_mode='Markdown')
    
    async def menu_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Показать интерактивное меню"""
        keyboard = [
            [InlineKeyboardButton("ℹ️ Информация", callback_data='info')],
            [InlineKeyboardButton("❓ Помощь", callback_data='help')],
            [InlineKeyboardButton("🗑 Очистить историю", callback_data='clear')],
            [InlineKeyboardButton("📊 Статистика", callback_data='stats')],
        ]
        reply_markup = InlineKeyboardMarkup(keyboard)
        await update.message.reply_text("Выберите действие:", reply_markup=reply_markup)
    
    async def button_callback(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Обработчик нажатий на кнопки меню"""
        query = update.callback_query
        await query.answer()
        
        if query.data == 'info':
            await self.info_command(update, context)
        elif query.data == 'help':
            await self.help_command(update, context)
        elif query.data == 'clear':
            user_id = update.effective_user.id
            if user_id in user_histories:
                user_histories[user_id] = []
                await query.edit_message_text("История диалога очищена! 🧹")
            else:
                await query.edit_message_text("История и так пуста!")
        elif query.data == 'stats':
            stats_text = f"📊 Статистика:\n• Пользователей: {len(user_histories)}\n• Ваших сообщений: {len(user_histories.get(update.effective_user.id, []))}"
            await query.edit_message_text(stats_text)
    
    def get_response(self, user_message: str) -> str:
        """Генерация ответа на сообщение пользователя"""
        user_message_lower = user_message.lower().strip()
        
        # Проверка на ключевые слова в интеллектуальных ответах
        for keyword, response in INTELLIGENT_RESPONSES.items():
            if keyword in user_message_lower:
                if callable(response):
                    return response()
                return response
        
        # Проверка на вопросы из FAQ
        for question, answers in FAQ.items():
            if question in user_message_lower:
                return random.choice(answers)
        
        # Особые случаи
        if '?' in user_message:
            if len(user_message.split()) > 3:
                return "Это интересный вопрос! Я могу найти информацию, если вы уточните детали. 🤔"
            return "Хороший вопрос! Дайте мне немного времени подумать... 💭"
        
        if any(word in user_message_lower for word in ['что', 'как', 'почему', 'где', 'когда']):
            return "Попробуйте задать вопрос проще. Я лучше понимаю короткие и конкретные вопросы! 📝"
        
        # Если сообщение похоже на приветствие
        if user_message_lower in ['здравствуй', 'здравствуйте', 'добрый день', 'доброе утро', 'прив']:
            return random.choice(FAQ.get("привет", ["Привет! Как дела?"]))
        
        # Стандартный ответ
        return random.choice(FALLBACK_ANSWERS)
    
    async def handle_message(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Обработчик текстовых сообщений"""
        user_message = update.message.text
        user_id = update.effective_user.id
        user_name = update.effective_user.first_name
        
        # Логирование
        logger.info(f"User {user_name} ({user_id}): {user_message}")
        
        # Сохранение в историю
        if user_id not in user_histories:
            user_histories[user_id] = []
        
        user_histories[user_id].append({"role": "user", "text": user_message, "time": datetime.now()})
        
        # Уведомление о печати
        await context.bot.send_chat_action(chat_id=update.effective_chat.id, action="typing")
        
        # Получение ответа
        response = self.get_response(user_message)
        
        # Сохранение ответа в историю
        user_histories[user_id].append({"role": "bot", "text": response, "time": datetime.now()})
        
        # Ограничение истории (последние 20 сообщений)
        if len(user_histories[user_id]) > 20:
            user_histories[user_id] = user_histories[user_id][-20:]
        
        # Отправка ответа
        await update.message.reply_text(response)
    
    async def error_handler(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Обработчик ошибок"""
        logger.error(f"Update {update} caused error {context.error}")
        if update and update.effective_message:
            await update.effective_message.reply_text("Произошла ошибка. Пожалуйста, попробуйте позже.")

def main():
    """Запуск бота"""
    # Введите токен вашего бота
    TOKEN = "YOUR_BOT_TOKEN_HERE"  # Замените на свой токен!
    
    if TOKEN == "YOUR_BOT_TOKEN_HERE":
        print("⚠️ Пожалуйста, получите токен у @BotFather и вставьте его в код!")
        print("1. Найдите @BotFather в Telegram")
        print("2. Отправьте команду /newbot")
        print("3. Следуйте инструкциям")
        print("4. Скопируйте полученный токен в переменную TOKEN")
        return
    
    try:
        # Создание приложения
        app = Application.builder().token(TOKEN).build()
        
        # Создание экземпляра бота
        bot = AnswerBot()
        
        # Регистрация обработчиков команд
        app.add_handler(CommandHandler("start", bot.start))
        app.add_handler(CommandHandler("help", bot.help_command))
        app.add_handler(CommandHandler("info", bot.info_command))
        app.add_handler(CommandHandler("clear", bot.clear_command))
        app.add_handler(CommandHandler("about", bot.about_command))
        app.add_handler(CommandHandler("menu", bot.menu_command))
        
        # Обработчик кнопок меню
        app.add_handler(CallbackQueryHandler(bot.button_callback))
        
        # Обработчик текстовых сообщений
        app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, bot.handle_message))
        
        # Обработчик ошибок
        app.add_error_handler(bot.error_handler)
        
        # Запуск бота
        print("🚀 Бот запущен и готов к работе!")
        print("Нажмите Ctrl+C для остановки")
        app.run_polling(allowed_updates=Update.ALL_TYPES)
        
    except Exception as e:
        logger.error(f"Ошибка при запуске бота: {e}")

if __name__ == "__main__":
    main()


  
