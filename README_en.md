# SpeechKit Web UI

<img
  src="images/web-ui.png"
  alt="SpeechKit Web UI"
  title="SpeechKit Web UI"
  style="display: inline-block; margin: 0 auto; max-width: 600px">

This repository contains a web application that allows users to interact with the [Yandex SpeechKit](https://aistudio.yandex.ru/en/ai-speech) service through a web interface.

The application demonstrates the capabilities of asynchronous and streaming speech recognition, as well as speech synthesis with various recognition and synthesis parameters available in SpeechKit:

- You can select and test different available [voices](https://aistudio.yandex.ru/docs/en/speechkit/tts/voices.html);
- You can use [TTS markup](https://aistudio.yandex.ru/docs/en/speechkit/tts/markup/tts-markup.html);
- [Speaker Labeling](https://aistudio.yandex.ru/docs/en/speechkit/stt/speaker-labeling.html) is available for mono-channel audio;
- Features for [summarization](https://aistudio.yandex.ru/docs/en/speechkit/stt/llm-results.html) and [classification](https://aistudio.yandex.ru/docs/en/speechkit/stt/analysis.html) are also included.

The application [can be deployed](deploy/README_en.md) locally using Docker Compose or in Yandex Cloud using Terraform.

> Streaming recognition mode via microphone is only available in local deployments using Docker Compose, since it requires WebSocket support, which is not available in Serverless Containers.

Speech synthesis results are stored in an Object Storage bucket.

## Related Examples

- [Automatic batch audio recognition](https://github.com/yandex-cloud-examples/yc-speechkit-async-recognizer)
- [Streaming recognition example](https://github.com/yandex-cloud-examples/yc-speechkit-streams-recognizer)