# STT Plan

 Feature                         API field                                     Currently used?
 ─────────────────────────────────────────────────────────────────────────────────────────────
 Speaker labeling / diarization  speaker_labeling                              ❌
 Speaker analysis stats          speech_analysis.enable_speaker_analysis       ❌
 Conversation analysis stats     speech_analysis.enable_conversation_analysis  ❌
 Recognition classifiers         recognition_classifier                        ❌
 Summarization (YandexGPT)       summarization                                   ❌
 Word-level timestamps           Alternative.words                               ❌
 Language estimation             Alternative.languages                           ❌
 Confidence scores               Alternative.confidence                          ❌
 Profanity filter                TextNormalizationOptions.profanity_filter       ❌
 Phone formatting control        TextNormalizationOptions.phone_formatting_mode  ❌
 Real-time streaming             Recognizer.RecognizeStreaming                   ❌
 Delete results                  AsyncRecognizer.DeleteRecognition               ❌


 Based on the proto definitions in the reference files, here's what the v3 API supports that we're not currently using:

1. Speaker Labeling

RecognizeFileRequest accepts a speaker_labeling field with SpeakerLabelingOptions. When enabled (SPEAKER_LABELING_ENABLED), the API assigns speaker_tag values to distinguish speakers — useful for diarization. We currently rely
only on channel_tag for the dialogue view.

2. Speech Analysis (per-speaker stats)

The speech_analysis field (SpeechAnalysisOptions) enables:

 • Speaker analysis — per-speaker metrics: total speech/silence duration, ratios, words/letters count, words-per-second, utterance count, utterance duration statistics.
 • Conversation analysis — two-speaker conversation metrics: simultaneous silence/speech durations and ratios, speaker interrupts (count, duration, boundaries).

These arrive as speaker_analysis and conversation_analysis events in the streaming response.

3. Recognition Classifiers

RecognizeFileRequest accepts recognition_classifier (RecognitionClassifierOptions) — a list of named classifiers with trigger types (ON_UTTERANCE, ON_FINAL, ON_PARTIAL). Results come back as classifier_update events with labels
and confidence scores, plus phrase highlights. This could be used for intent detection, topic classification, etc.

4. Summarization

The summarization field (SummarizationOptions) lets you specify a YandexGPT model URI and a list of SummarizationProperty instructions. The API returns Summarization events with text responses and token usage stats. This enables
automatic call/meeting summarization.

5. Word-level timing

The Alternative message includes a words array with per-word start_time_ms and end_time_ms. Our backend currently only extracts the top-level text from alternatives, discarding word timestamps.

6. Language estimation

Each Alternative includes a languages array with language_code and probability. We don't surface detected language info in the UI.

7. Confidence scores

Each Alternative has a confidence field. We don't display it.

8. Profanity filter

TextNormalizationOptions has a profanity_filter boolean. We don't expose it as a UI toggle.

9. Phone formatting mode

TextNormalizationOptions has phone_formatting_mode to disable phone number formatting. Not exposed.

10. Streaming (real-time) recognition

The Recognizer service offers RecognizeStreaming — bidirectional streaming for real-time mic input. We only use AsyncRecognizer (file-based).

11. Delete recognition results

AsyncRecognizer.DeleteRecognition allows cleaning up operation results. We never call it.



# TTS Plan

Not Implemented ❌


 Feature           Description
 ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 volume hint       Adjusts normalization level. For LUFS: range [-145, 0), default -19. For MAX_PEAK: range (0, 1], default 0.7
 pitch_shift hint        Adjusts speaker pitch in Hz, range [-1000, 1000], default 0
 duration hint            DurationHint with policies: EXACT_DURATION, MIN_DURATION, MAX_DURATION — constrains audio length in ms
 text_template           Template-based synthesis, e.g. "Hello, {username}" with variable substitution (TextTemplate + TextVariable)
 audio_template          Audio template synthesis — provide reference audio + text template + AudioVariable markers for variable segments
 model                   Model name field (used for Brand Voice Lite / Brand Voice Call Center)
 MAX_PEAK normalization  We hardcode LUFS; user can't choose MAX_PEAK
 OGG_OPUS / MP3 output   We hardcode WAV output; API also supports OGG_OPUS and MP3 containers
 StreamSynthesis         Bidirectional streaming RPC — send text chunks incrementally, receive audio chunks in real-time



Recommendations (by effort/value)

Easy wins for the UI:

 1 volume — add a slider
 2 pitch_shift — add a slider
 3 Output format selector — WAV / OGG_OPUS / MP3 (smaller files for OGG/MP3)
 4 Normalization type selector — LUFS vs MAX_PEAK

Medium effort: 5. duration hint — add optional fields for policy + duration_ms 6. model field — text input for Brand Voice users

Higher effort: 7. text_template — needs UI for defining variables and their values 8. audio_template — needs audio upload + variable marker UI 9. StreamSynthesis — needs WebSocket/streaming architecture, similar to the streaming
STT item on our roadmap

Would you like me to start implementing the easy wins (volume, pitch_shift, output format, normalization type)?