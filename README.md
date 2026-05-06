# SpeechKit Web UI

<img
  src="images/web-ui.png"
  alt="SpeechKit Web UI"
  title="SpeechKit Web UI"
  style="display: inline-block; margin: 0 auto; max-width: 600px">

Данный репозиторий содержит веб-приложение, которое позволяет обращаться к сервису [Yandex SpeechKit](https://aistudio.yandex.ru/ru/ai-speech) и работать с ним через веб-интерфейс.

Приложение позволяет ознакомиться с возможностями асихронного и потокового распознавания, а также – синтеза речи – с различными параметрами, доступными при распознавании и синтезе:
- Можно выбрать и проверить различные доступные [голоса](https://aistudio.yandex.ru/docs/ru/speechkit/tts/voices.html);
- Можно использовать [TTS-разметку](https://aistudio.yandex.ru/docs/ru/speechkit/tts/markup/tts-markup.html);
- Доступны возможности [Speaker Labeling](https://aistudio.yandex.ru/docs/ru/speechkit/stt/speaker-labeling.html) для моноканального аудио;
- Добавлены возможности для [суммаризации](https://aistudio.yandex.ru/docs/ru/speechkit/stt/llm-results.html) и [классификации](https://aistudio.yandex.ru/docs/ru/speechkit/stt/analysis.html).

Приложение [можно развернуть](deploy/README.md) локально при помощи Docker Compose, либо в Yandex Cloud, при помощи Terraform.

> Потоковый режим распознавания через микрофон доступен только при локальном развертывании через docker compose, так как необходима поддержка WebSockets, недоступная в Serverless Containers.

Результат синтеза речи сохраняется в бакет.

## Связанные примеры

- [Автоматическое батч-распознавание аудио](https://github.com/yandex-cloud-examples/yc-speechkit-async-recognizer)
- [Пример стриминг распознавания](https://github.com/yandex-cloud-examples/yc-speechkit-streams-recognizer)
