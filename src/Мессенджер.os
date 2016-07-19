﻿
///////////////////////////////////////////////////////////////////////////////////////////////
//
// Модуль отправки сообщений 
// Доступные варианты
//	- Канал SLACK
//	- SMS
//	- E-Mail
//
// (с) BIA Technologies, LLC	
//
///////////////////////////////////////////////////////////////////////////////////////////////

Перем АвторизацияSLACK;

///////////////////////////////////////////////////////////////////////////////////////////////

Процедура ОтправитьСообщениеSMS(Адресат, Сообщение) Экспорт

	ОтправитьСообщение("sms", Адресат, Сообщение);

КонецПроцедуры

Процедура ОтправитьСообщениеEMail(Адресат, Сообщение, ТемаСообщения = "Уведомление") Экспорт

	ОтправитьСообщение("email", Адресат, Сообщение, ТемаСообщения);

КонецПроцедуры

Процедура ОтправитьСообщениеSLACK(Адресат, Сообщение, ТипСообщения) Экспорт

	ОтправитьСообщение("slack", Адресат, Сообщение,, ТипСообщения);
	
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////////////////////

Процедура ОтправитьСообщение(Протокол, Адресат, Сообщение, ТемаСообщения = "", ТипСообщения = "") Экспорт

	Если Протокол = "slack" Тогда

		ОтправитьСообщениеВКаналSLACK(Адресат, Сообщение, ТипСообщения)

	Иначе
		ОтправитьСообщениеSMSEmail(Протокол, Адресат, Сообщение, ТемаСообщения);

	КонецЕсли;

КонецПроцедуры

Процедура ОтправитьСообщениеSMSEmail(Протокол, Адресат, Знач Сообщение, ТемаСообщения = "") Экспорт

	ВызватьИсключение "Необходимо настроить транспорт SMS/EMAIL";
	
	URL = "notifications_url";
	ИмяСервера = "myserver.mycompany.com";
	Пользователь = "bot_name";
	Пароль = "bot_pass";

	Если Протокол = "email" Тогда
		
		Сообщение = СтрЗаменить(Сообщение, Символы.ПС, "<br/>")
		
	КонецЕсли;
	
	ТелоЗапроса = "
	|{
	|""operation"": """ + Протокол + """,
	|""receivers"": [""" + Адресат + """],
	|""message"": """ + Сообщение + """,
	|""subject"": """ + ТемаСообщения + """
	|}";

	HTTPЗапрос = Новый HTTPЗапрос;
	HTTPЗапрос.Заголовки.Вставить("Content-Type", "application/json");
	HTTPЗапрос.АдресРесурса = URL;
	HTTPЗапрос.УстановитьТелоИзСтроки(ТелоЗапроса);

	HTTP = Новый HTTPСоединение(ИмяСервера,,
						Пользователь,
						Пароль);
	Ответ = HTTP.ОтправитьДляОбработки(HTTPЗапрос);

КонецПроцедуры

Процедура ОтправитьСообщениеВКаналSLACK(Канал, ТекстСообщения, ТипСообщения) Экспорт

	Если АвторизацияSLACK = Неопределено Тогда

		ВызватьИсключение "Необходимо выполнить инициализацию транспорта Slack";

	КонецЕсли;
	
	ИмяСервера = "slack.com";
	
	Прокси = Новый ИнтернетПрокси(ИСТИНА);
	
	URL = "api/chat.postMessage?channel=" 
		+ Канал 
		+ "&text=" + СформироватьТекстСообщенияSLACK(ТипСообщения, ТекстСообщения) 
		+ "&as_user=" + АвторизацияSLACK.Логин + "&token=" + АвторизацияSLACK.Ключ;
	

	HTTPЗапрос = Новый HTTPЗапрос;
	HTTPЗапрос.АдресРесурса = URL;
	
	HTTP = Новый HTTPСоединение(ИмяСервера,,,, Прокси);
	Ответ = HTTP.Получить(HTTPЗапрос);

КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////////////////////
// Инициализация
///////////////////////////////////////////////////////////////////////////////////////////////

Процедура ИнициализацияSLACK(Логин, Ключ)Экспорт

	АвторизацияSLACK = Новый Структура("Логин, Ключ", Логин, Ключ)

КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////////////////////

Функция СформироватьТекстСообщенияSLACK(ТипСообщения, ТекстСообщения)

	Сообщение = ПолучитьИконкуТипаСообщенияSLACK(ТипСообщения) + " " + КодироватьСтроку(ТекстСообщения, СпособКодированияСтроки.КодировкаURL);
	Возврат Сообщение;

КонецФункции 

Функция ПолучитьИконкуТипаСообщенияSLACK(ТипСообщения)

	Иконка = ТипСообщения;
	Если ТипСообщения = "Ошибка" Тогда
		
		Иконка = ":no_entry:";
		
	ИначеЕсли ТипСообщения = "Информация" Тогда
		
		Иконка = ":speech_balloon:";                                            
		
	ИначеЕсли ТипСообщения = "Предупреждение" Тогда
	
		Иконка = ":warning:";  
		
	КонецЕсли;
	
	Возврат Иконка;

КонецФункции

///////////////////////////////////////////////////////////////////////////////////////////////

АвторизацияSLACK = Неопределено;
