// Check if STREAM feature is enabled (only in local deployment)
const STREAM_ENABLED = ${stream_enabled};

// Voices and roles dictionary
const voices = {
    lea: ["none"],
    john: ["none"],
    naomi: ["modern", "classic"],
    amira: ["none"],
    madi: ["none"],
    saule: ["neutral", "strict"],
    zhanar: ["neutral", "friendly"],
    alena: ["neutral", "good"],
    filipp: ["none"],
    ermil: ["neutral", "good"],
    jane: ["neutral", "good", "evil"],
    omazh: ["neutral", "evil"],
    zahar: ["neutral", "good"],
    dasha: ["neutral", "good", "friendly"],
    julia: ["neutral", "strict"],
    lera: ["neutral", "friendly"],
    masha: ["good", "strict", "friendly"],
    marina: ["neutral", "whisper", "friendly"],
    alexander: ["neutral", "good"],
    kirill: ["neutral", "strict", "good"],
    anton: ["neutral", "good"],
    madi_ru: ["none"],
    saule_ru: ["neutral", "strict", "whisper"],
    zamira_ru: ["neutral", "strict", "friendly"],
    zhanar_ru: ["neutral", "strict", "friendly"],
    yulduz_ru: ["neutral", "strict", "friendly", "whisper"],
    nigora: ["none"],
    zamira: ["neutral", "strict", "friendly"],
    yulduz: ["neutral", "strict", "friendly", "whisper"],
};

// Default values
const defaultVoice = 'marina';
const defaultRole = 'neutral';

// Dropdowns and parameters
let currentVoice = '';
let currentRole = '';
let currentSpeed = 1.0;
let currentPitchShift = 0;
let currentVolume = -19;
let currentFormat = 'WAV';
let currentNormType = 'LUFS';
let currentUnsafeMode = false;

// Add CSS for dropdowns
document.addEventListener('DOMContentLoaded', function() {
    // Enable STREAM tab if feature is enabled
    if (STREAM_ENABLED) {
        document.body.classList.add('stream-enabled');
        setupStreamRecognition();
    }
    
    // Setup tabs
    const tabs = document.querySelectorAll('.tab');
    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            // Remove active class from all tabs and contents
            document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
            document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
            
            // Add active class to clicked tab and corresponding content
            tab.classList.add('active');
            const tabId = tab.getAttribute('data-tab');
            document.getElementById(tabId).classList.add('active');
        });
    });
    
    // Initialize TTS components
    populateVoicesDropdown();
    selectDefaultVoice(defaultVoice);
    
    // Setup dropdown toggles
    document.getElementById('voicesDropdown').addEventListener('click', function() {
        document.getElementById('voicesDropdownContent').classList.toggle('show');
    });
    
    document.getElementById('rolesDropdown').addEventListener('click', function() {
        document.getElementById('rolesDropdownContent').classList.toggle('show');
    });
    
    document.getElementById('formatDropdown').addEventListener('click', function() {
        document.getElementById('formatDropdownContent').classList.toggle('show');
    });
    
    document.getElementById('normDropdown').addEventListener('click', function() {
        document.getElementById('normDropdownContent').classList.toggle('show');
    });
    
    // Populate format dropdown
    const formatOptions = ['WAV', 'OGG_OPUS', 'MP3'];
    const formatDropdownContent = document.getElementById('formatDropdownContent');
    formatOptions.forEach(function(fmt) {
        const item = document.createElement('a');
        item.textContent = fmt;
        item.onclick = function() {
            currentFormat = fmt;
            document.getElementById('formatDropdown').textContent = fmt;
            formatDropdownContent.classList.remove('show');
        };
        formatDropdownContent.appendChild(item);
    });
    
    // Populate normalization type dropdown
    const normOptions = [
        { label: 'LUFS', value: 'LUFS' },
        { label: 'MAX_PEAK', value: 'MAX_PEAK' }
    ];
    const normDropdownContent = document.getElementById('normDropdownContent');
    normOptions.forEach(function(opt) {
        const item = document.createElement('a');
        item.textContent = opt.label;
        item.onclick = function() {
            currentNormType = opt.value;
            document.getElementById('normDropdown').textContent = opt.label;
            normDropdownContent.classList.remove('show');
            updateVolumeSliderRange();
        };
        normDropdownContent.appendChild(item);
    });
    
    // Slider event listeners
    document.getElementById('speedSlider').addEventListener('input', function() {
        currentSpeed = parseFloat(this.value);
        document.getElementById('speedValue').textContent = currentSpeed.toFixed(1);
    });
    
    document.getElementById('pitchSlider').addEventListener('input', function() {
        currentPitchShift = parseInt(this.value);
        document.getElementById('pitchValue').textContent = currentPitchShift;
    });
    
    document.getElementById('volumeSlider').addEventListener('input', function() {
        currentVolume = parseFloat(this.value);
        document.getElementById('volumeValue').textContent = currentVolume;
    });
    
    function updateVolumeSliderRange() {
        const slider = document.getElementById('volumeSlider');
        const valueLabel = document.getElementById('volumeValue');
        if (currentNormType === 'LUFS') {
            slider.min = '-145';
            slider.max = '-0.1';
            slider.step = '0.1';
            slider.value = '-19';
            currentVolume = -19;
            valueLabel.textContent = '-19';
        } else {
            slider.min = '0.1';
            slider.max = '1';
            slider.step = '0.01';
            slider.value = '0.7';
            currentVolume = 0.7;
            valueLabel.textContent = '0.7';
        }
    }
    
    // Reset sliders button
    document.getElementById('resetSlidersBtn').addEventListener('click', function() {
        // Speed
        currentSpeed = 1.0;
        document.getElementById('speedSlider').value = '1.0';
        document.getElementById('speedValue').textContent = '1.0';
        
        // Pitch
        currentPitchShift = 0;
        document.getElementById('pitchSlider').value = '0';
        document.getElementById('pitchValue').textContent = '0';
        
        // Normalization type
        currentNormType = 'LUFS';
        document.getElementById('normDropdown').textContent = 'LUFS';
        
        // Volume (reset range then value)
        var slider = document.getElementById('volumeSlider');
        slider.min = '-145';
        slider.max = '-0.1';
        slider.step = '0.1';
        slider.value = '-19';
        currentVolume = -19;
        document.getElementById('volumeValue').textContent = '-19';
    });
    
    // Close dropdowns when clicking outside
    window.addEventListener('click', function(event) {
        if (!event.target.matches('#voicesDropdown')) {
            const dropdown = document.getElementById('voicesDropdownContent');
            if (dropdown.classList.contains('show')) {
                dropdown.classList.remove('show');
            }
        }
        if (!event.target.matches('#rolesDropdown')) {
            const dropdown = document.getElementById('rolesDropdownContent');
            if (dropdown.classList.contains('show')) {
                dropdown.classList.remove('show');
            }
        }
        if (!event.target.matches('#formatDropdown')) {
            const dropdown = document.getElementById('formatDropdownContent');
            if (dropdown.classList.contains('show')) {
                dropdown.classList.remove('show');
            }
        }
        if (!event.target.matches('#normDropdown')) {
            const dropdown = document.getElementById('normDropdownContent');
            if (dropdown.classList.contains('show')) {
                dropdown.classList.remove('show');
            }
        }
    });
    
    // Unsafe mode toggle
    document.getElementById('unsafeModeButton').addEventListener('click', function() {
        currentUnsafeMode = !currentUnsafeMode;
        const button = this;
        
        if (currentUnsafeMode) {
            button.classList.remove('btn-outline-danger');
            button.classList.add('btn-danger');
        } else {
            button.classList.remove('btn-danger');
            button.classList.add('btn-outline-danger');
        }
        
        const textInput = document.getElementById('textInput');
        document.getElementById('unsafeMode').value = currentUnsafeMode ? 'true' : 'false';
        
        if (currentUnsafeMode) {
            textInput.setAttribute('maxlength', '5000');
        } else {
            textInput.setAttribute('maxlength', '250');
        }
        
        var currentLength = textInput.value.length;
        var maxLength = textInput.getAttribute('maxlength');
        document.getElementById('charCount').textContent = currentLength + '/' + maxLength;
    });
});

// Populating voices dropdown
function populateVoicesDropdown() {
    const voicesDropdownContent = document.getElementById('voicesDropdownContent');
    for (const voice in voices) {
        const item = document.createElement('a');
        item.textContent = voice;
        item.onclick = function() {
            currentVoice = voice;
            populateRolesDropdown(voice);
            document.getElementById('voicesDropdown').textContent = voice;
            voicesDropdownContent.classList.remove('show');
        };
        voicesDropdownContent.appendChild(item);
    }
}

// Selecting default voice
function selectDefaultVoice(name) {
    currentVoice = name;
    populateRolesDropdown(name);
    document.getElementById('voicesDropdown').textContent = name;
}

// Populating roles dropdown
function populateRolesDropdown(name) {
    const roles = voices[name];
    const rolesDropdownContent = document.getElementById('rolesDropdownContent');
    rolesDropdownContent.innerHTML = '';
    
    roles.forEach((role, index) => {
        const item = document.createElement('a');
        item.textContent = role;
        item.onclick = function() {
            currentRole = role;
            document.getElementById('rolesDropdown').textContent = role;
            rolesDropdownContent.classList.remove('show');
        };
        rolesDropdownContent.appendChild(item);
        
        if (index === 0) {
            currentRole = role;
            document.getElementById('rolesDropdown').textContent = role;
        }
    });
}


document.addEventListener('DOMContentLoaded', function() {
    // Text area and character count
    var textArea = document.getElementById('textInput');
    var charCount = document.getElementById('charCount');
    
    // Update character count when text changes
    textArea.addEventListener('input', function() {
        var currentLength = textArea.value.length;
        var maxLength = textArea.getAttribute('maxlength');
        charCount.textContent = currentLength + '/' + maxLength;
    });
    
    // Initialize character count
    var currentLength = textArea.value.length;
    var maxLength = textArea.getAttribute('maxlength');
    charCount.textContent = currentLength + '/' + maxLength;
    
    // TTS formatting buttons
    function insertText(textToInsert) {
        var startPos = textArea.selectionStart;
        var endPos = textArea.selectionEnd;
        textArea.value = textArea.value.substring(0, startPos) + 
            textToInsert + 
            textArea.value.substring(endPos);
        textArea.focus();
        textArea.selectionStart = startPos + textToInsert.length;
        textArea.selectionEnd = startPos + textToInsert.length;
        
        // Update character count
        var currentLength = textArea.value.length;
        var maxLength = textArea.getAttribute('maxlength');
        charCount.textContent = currentLength + '/' + maxLength;
    }
    
    document.getElementById('insertPauseTiny').addEventListener('click', function() {
        insertText('<[tiny]>');
    });
    
    document.getElementById('insertPauseSmall').addEventListener('click', function() {
        insertText('<[small]>');
    });
    
    document.getElementById('insertPauseMedium').addEventListener('click', function() {
        insertText('<[medium]>');
    });
    
    document.getElementById('insertPauseLarge').addEventListener('click', function() {
        insertText('<[large]>');
    });
    
    document.getElementById('insertPauseHuge').addEventListener('click', function() {
        insertText('<[huge]>');
    });
    
    document.getElementById('insertPauseMs').addEventListener('click', function() {
        insertText(' sil<[500]> ');
    });
    
    document.getElementById('insertStress').addEventListener('click', function() {
        insertText('+');
    });
    
    // Send TTS request
    document.getElementById('sendButton').addEventListener('click', function() {
        var text = textArea.value;
        
        document.getElementById('processing').style.display = 'inline-block';
        document.getElementById('sendButton').style.display = 'none';
        document.getElementById('playbackButtonContainer').innerHTML = '';
        
        fetch('${api_gw}/tts', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                text: text,
                voice: currentVoice,
                role: currentRole,
                speed: currentSpeed,
                pitchShift: currentPitchShift,
                volume: currentVolume,
                format: currentFormat,
                normType: currentNormType,
                unsafe: currentUnsafeMode
            }),
        })
        .then(response => {
            document.getElementById('processing').style.display = 'none';
            document.getElementById('sendButton').style.display = 'inline-block';
            
            if (response.ok) {
                response.text().then(data => {
                    var audioUrl = data;
                    
                    // Playback button
                    var playbackButton = document.createElement('button');
                    playbackButton.textContent = 'Прослушать';
                    playbackButton.onclick = function() {
                        var audio = new Audio(audioUrl);
                        audio.play();
                    };
                    document.getElementById('playbackButtonContainer').appendChild(playbackButton);
                    
                    // Download button
                    var downloadButton = document.createElement('button');
                    downloadButton.textContent = 'Скачать';
                    downloadButton.style.marginLeft = '5px';
                    downloadButton.onclick = function() {
                        var link = document.createElement('a');
                        link.href = audioUrl;
                        var ext = currentFormat === 'OGG_OPUS' ? 'ogg' : currentFormat.toLowerCase();
                        link.download = 'audio.' + ext;
                        document.body.appendChild(link);
                        link.click();
                        document.body.removeChild(link);
                    };
                    document.getElementById('playbackButtonContainer').appendChild(downloadButton);
                });
            } else {
                console.error('HTTP Error:', response.statusText);
            }
        })
        .catch((error) => {
            console.error('Error:', error);
            document.getElementById('processing').style.display = 'none';
            document.getElementById('sendButton').style.display = 'inline-block';
        });
    });
    
    // Copy button functionality
    document.getElementById('copyJsonBtn').addEventListener('click', function() {
        const resultSttDiv = document.getElementById('resultStt');
        const textToCopy = resultSttDiv.textContent;
        var btn = this;
        
        navigator.clipboard.writeText(textToCopy).then(function() {
            var originalHTML = btn.innerHTML;
            btn.innerHTML = '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M5 13l4 4L19 7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>';
            btn.classList.add('copied');
            setTimeout(function() {
                btn.innerHTML = originalHTML;
                btn.classList.remove('copied');
            }, 1500);
        });
    });
    
    // Prevent help links inside collapsible headers from toggling collapse
    document.querySelectorAll('.collapsible .help-link').forEach(function(link) {
        link.addEventListener('click', function(e) {
            e.stopPropagation();
        });
    });
    
    // Toggle Raw JSON visibility
    document.getElementById('toggleJsonBtn').addEventListener('click', function() {
        const section = document.getElementById('rawJsonSection');
        const arrow = this.querySelector('.collapse-arrow');
        if (section.style.display === 'none') {
            section.style.display = 'block';
            arrow.classList.add('open');
        } else {
            section.style.display = 'none';
            arrow.classList.remove('open');
        }
    });
    
    // Toggle Speaker Analysis visibility
    document.getElementById('toggleSpeakerBtn').addEventListener('click', function() {
        const section = document.getElementById('speakerAnalysisSection');
        const arrow = this.querySelector('.collapse-arrow');
        if (section.style.display === 'none') {
            section.style.display = 'block';
            arrow.classList.add('open');
        } else {
            section.style.display = 'none';
            arrow.classList.remove('open');
        }
    });
    
    // Toggle Conversation Analysis visibility
    document.getElementById('toggleConversationBtn').addEventListener('click', function() {
        const section = document.getElementById('conversationAnalysisSection');
        const arrow = this.querySelector('.collapse-arrow');
        if (section.style.display === 'none') {
            section.style.display = 'block';
            arrow.classList.add('open');
        } else {
            section.style.display = 'none';
            arrow.classList.remove('open');
        }
    });
    
    // STT file input handling
    document.getElementById('fileInput').addEventListener('change', function() {
        var file = this.files[0];
        if (file && file.type === 'audio/wav') {
            document.getElementById('rateForm').classList.remove('hidden');
        } else {
            document.getElementById('rateForm').classList.add('hidden');
            document.getElementById('sampleRateInput').value = '48000';
        }
    });
    
    // STT form submission
    document.getElementById('audioUploadForm').addEventListener('submit', function(e) {
        e.preventDefault();
        var formData = new FormData(this);
        var file = formData.get('file');
        var lang = formData.get('lang');
        var rate = formData.get('sampleRate');
        var fileName = file.name;
        
        document.getElementById('processingStt').style.display = 'inline-block';
        document.getElementById('sendButtonStt').style.display = 'none';
        
        document.getElementById('resultStt').innerHTML = '';
        document.getElementById('dialogueSection').innerHTML = '';
        document.getElementById('speakerAnalysisSection').innerHTML = '';
        document.getElementById('conversationAnalysisSection').innerHTML = '';
        document.getElementById('speakerAnalysisSection').style.display = 'none';
        document.getElementById('conversationAnalysisSection').style.display = 'none';
        document.getElementById('toggleSpeakerBtn').querySelector('.collapse-arrow').classList.remove('open');
        document.getElementById('toggleConversationBtn').querySelector('.collapse-arrow').classList.remove('open');
        document.getElementById('summarySection').innerHTML = '';
        
        // Presigning URL
        var encodedFilename = encodeURIComponent(fileName);
        
        fetch(`${api_gw}/presign?fileName=` + encodedFilename)
            .then(response => response.json())
            .then(response => {
                // Upload to S3
                var presignedUrl = response.url;
                
                return fetch(presignedUrl, {
                    method: 'PUT',
                    body: file,
                    headers: {
                        'Content-Type': 'binary/octet-stream'
                    }
                }).then(() => {
                    console.log('Upload to S3 successful');
                    return response.key;
                });
            })
            .then(objectKey => {
                // Process with STT
                return fetch(`${api_gw}/stt`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        key: objectKey,
                        lang: lang,
                        rate: rate,
                        summaryInstruction: document.getElementById('summaryInstructionInput').value
                    })
                }).then(response => response.json());
            })
            .then(response => {
                console.log('STT processing initiated');
                checkOperationStatus(response.operation);
            })
            .catch(error => {
                console.error('Error in STT process:', error);
                document.getElementById('processingStt').style.display = 'none';
                document.getElementById('sendButtonStt').style.display = 'inline-block';
            });
    });
});

// Check STT operation status
function checkOperationStatus(operationId) {
    function checkStatus() {
        fetch(`${api_gw}/operation?operationId=` + operationId)
            .then(response => response.json())
            .then(response => {
                if (response.done === "true") {
                    console.log('Operation completed successfully');
                    
                    document.getElementById('processingStt').style.display = 'none';
                    document.getElementById('sendButtonStt').style.display = 'inline-block';
                    
                    // Display beautified JSON
                    var resultSttDiv = document.getElementById("resultStt");
                    var newParagraphStt = document.createElement("pre");
                    var responseTextStt = JSON.stringify(response, null, 2);
                    
                    // Beautify JSON with syntax highlighting
                    const highlighted = responseTextStt.replace(
                        /("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g,
                        function (match) {
                            let cls = 'json-number';
                            if (/^"/.test(match)) {
                                if (/:$/.test(match)) {
                                    cls = 'json-key';
                                } else {
                                    cls = 'json-string';
                                }
                            } else if (/true|false/.test(match)) {
                                cls = 'json-boolean';
                            } else if (/null/.test(match)) {
                                cls = 'json-null';
                            }
                            return '<span class="' + cls + '">' + match + '</span>';
                        }
                    );
                    
                    newParagraphStt.innerHTML = highlighted;
                    resultSttDiv.appendChild(newParagraphStt);
                    
                    // Process channel data as dialogue
                    let result = response.result.chunks;
                    const dialogueSection = document.getElementById('dialogueSection');
                    dialogueSection.innerHTML = '';
                    
                    // Determine the first channel tag to assign it as "left"
                    let leftTag = null;
                    if (result.length > 0) {
                        leftTag = result[0].channelTag;
                    }
                    
                    // Sort chunks chronologically by start time
                    result.sort(function(a, b) {
                        var aTime = (a.alternatives && a.alternatives[0]) ? (a.alternatives[0].startTimeMs || 0) : 0;
                        var bTime = (b.alternatives && b.alternatives[0]) ? (b.alternatives[0].startTimeMs || 0) : 0;
                        return aTime - bTime;
                    });

                    function formatTimestamp(ms) {
                        if (ms === undefined || ms === null || ms === 0) return '0:00.0';
                        var totalSeconds = parseInt(ms) / 1000;
                        var minutes = Math.floor(totalSeconds / 60);
                        var seconds = (totalSeconds % 60).toFixed(1);
                        if (seconds < 10) seconds = '0' + seconds;
                        return minutes + ':' + seconds;
                    }
                    
                    result.forEach(chunk => {
                        const text = chunk.alternatives.map(a => a.text).join(' ');
                        if (!text.trim()) return;
                        
                        const isLeft = (chunk.channelTag === leftTag);
                        const side = isLeft ? 'left' : 'right';
                        
                        const bubble = document.createElement('div');
                        bubble.className = 'dialogue-bubble ' + side;
                        
                        // Build tooltip from first alternative
                        const alt = chunk.alternatives[0];
                        const tooltip = document.createElement('div');
                        tooltip.className = 'bubble-tooltip';
                        
                        // Time row
                        var timeRow = document.createElement('div');
                        timeRow.className = 'tooltip-row';
                        timeRow.innerHTML = '<span class="tooltip-label">Time:</span>' +
                            formatTimestamp(alt.startTimeMs) + ' – ' + formatTimestamp(alt.endTimeMs);
                        tooltip.appendChild(timeRow);
                        
                        // Words count row
                        var wordsRow = document.createElement('div');
                        wordsRow.className = 'tooltip-row';
                        var wordCount = (alt.words && alt.words.length) ? alt.words.length : 0;
                        wordsRow.innerHTML = '<span class="tooltip-label">Words:</span>' + wordCount;
                        tooltip.appendChild(wordsRow);
                        
                        // Confidence row
                        if (alt.confidence) {
                            var confRow = document.createElement('div');
                            confRow.className = 'tooltip-row';
                            confRow.innerHTML = '<span class="tooltip-label">Confidence:</span>' +
                                (parseFloat(alt.confidence) * 100).toFixed(1) + '%';
                            tooltip.appendChild(confRow);
                        }
                        
                        // Language row
                        if (alt.languages && alt.languages.length > 0) {
                            var langRow = document.createElement('div');
                            langRow.className = 'tooltip-row';
                            var langParts = alt.languages.map(function(l) {
                                return l.language_code + ' (' + (parseFloat(l.probability) * 100).toFixed(1) + '%)';
                            });
                            langRow.innerHTML = '<span class="tooltip-label">Language:</span>' + langParts.join(', ');
                            tooltip.appendChild(langRow);
                        }
                        
                        bubble.appendChild(tooltip);
                        
                        const content = document.createElement('div');
                        content.textContent = text;
                        bubble.appendChild(content);
                        
                        dialogueSection.appendChild(bubble);
                        
                        // Clearfix after each bubble
                        const clearfix = document.createElement('div');
                        clearfix.className = 'dialogue-clearfix';
                        dialogueSection.appendChild(clearfix);
                    });

                    // Render Speaker Analysis
                    const speakerAnalysis = response.result.speakerAnalysis;
                    const speakerSection = document.getElementById('speakerAnalysisSection');
                    speakerSection.innerHTML = '';
                    
                    if (speakerAnalysis && speakerAnalysis.length > 0) {
                        speakerAnalysis.forEach(function(sa) {
                            const card = document.createElement('div');
                            card.className = 'analysis-card';
                            
                            const title = document.createElement('h6');
                            title.textContent = 'Speaker: ' + (sa.speaker_tag || 'Unknown');
                            card.appendChild(title);
                            
                            const table = document.createElement('table');
                            table.className = 'analysis-table';
                            
                            function addRow(label, value) {
                                const tr = document.createElement('tr');
                                const th = document.createElement('th');
                                th.textContent = label;
                                const td = document.createElement('td');
                                td.textContent = value;
                                tr.appendChild(th);
                                tr.appendChild(td);
                                table.appendChild(tr);
                            }
                            
                            function formatMs(ms) {
                                if (ms === undefined || ms === null) return '—';
                                var seconds = (parseInt(ms) / 1000).toFixed(1);
                                return seconds + 's';
                            }
                            
                            function formatRatio(ratio) {
                                if (ratio === undefined || ratio === null) return '—';
                                return (parseFloat(ratio) * 100).toFixed(1) + '%';
                            }
                            
                            function formatStat(stat) {
                                if (!stat) return '—';
                                return 'mean: ' + (parseFloat(stat.mean || 0)).toFixed(2) +
                                       ', min: ' + (parseFloat(stat.min || 0)).toFixed(2) +
                                       ', max: ' + (parseFloat(stat.max || 0)).toFixed(2);
                            }
                            
                            addRow('Total Speech', formatMs(sa.total_speech_ms));
                            addRow('Speech Ratio', formatRatio(sa.speech_ratio));
                            addRow('Total Silence', formatMs(sa.total_silence_ms));
                            addRow('Silence Ratio', formatRatio(sa.silence_ratio));
                            addRow('Words Count', sa.words_count || '0');
                            addRow('Letters Count', sa.letters_count || '0');
                            addRow('Utterance Count', sa.utterance_count || '0');
                            addRow('Words/sec', formatStat(sa.words_per_second));
                            addRow('Letters/sec', formatStat(sa.letters_per_second));
                            addRow('Words/utterance', formatStat(sa.words_per_utterance));
                            addRow('Letters/utterance', formatStat(sa.letters_per_utterance));
                            addRow('Utterance Duration', formatStat(sa.utterance_duration_estimation));
                            
                            if (sa.speech_boundaries) {
                                addRow('Speech Start', formatMs(sa.speech_boundaries.start_time_ms));
                                addRow('Speech End', formatMs(sa.speech_boundaries.end_time_ms));
                            }
                            
                            card.appendChild(table);
                            speakerSection.appendChild(card);
                        });
                    } else {
                        speakerSection.innerHTML = '<div class="analysis-card">No speaker analysis data available.</div>';
                    }
                    
                    // Render Conversation Analysis
                    const convAnalysis = response.result.conversationAnalysis;
                    const convSection = document.getElementById('conversationAnalysisSection');
                    convSection.innerHTML = '';
                    
                    if (convAnalysis) {
                        const card = document.createElement('div');
                        card.className = 'analysis-card';
                        
                        const table = document.createElement('table');
                        table.className = 'analysis-table';
                        
                        function addConvRow(label, value) {
                            const tr = document.createElement('tr');
                            const th = document.createElement('th');
                            th.textContent = label;
                            const td = document.createElement('td');
                            td.textContent = value;
                            tr.appendChild(th);
                            tr.appendChild(td);
                            table.appendChild(tr);
                        }
                        
                        function fmtMs(ms) {
                            if (ms === undefined || ms === null) return '—';
                            return (parseInt(ms) / 1000).toFixed(1) + 's';
                        }
                        
                        function fmtRatio(ratio) {
                            if (ratio === undefined || ratio === null) return '—';
                            return (parseFloat(ratio) * 100).toFixed(1) + '%';
                        }
                        
                        function fmtStat(stat) {
                            if (!stat) return '—';
                            return 'mean: ' + (parseFloat(stat.mean || 0)).toFixed(2) +
                                   ', min: ' + (parseFloat(stat.min || 0)).toFixed(2) +
                                   ', max: ' + (parseFloat(stat.max || 0)).toFixed(2);
                        }
                        
                        if (convAnalysis.conversation_boundaries) {
                            addConvRow('Conversation Start', fmtMs(convAnalysis.conversation_boundaries.start_time_ms));
                            addConvRow('Conversation End', fmtMs(convAnalysis.conversation_boundaries.end_time_ms));
                        }
                        
                        addConvRow('Total Speech Duration', fmtMs(convAnalysis.total_speech_duration_ms));
                        addConvRow('Total Speech Ratio', fmtRatio(convAnalysis.total_speech_ratio));
                        addConvRow('Simultaneous Silence', fmtMs(convAnalysis.total_simultaneous_silence_duration_ms));
                        addConvRow('Simultaneous Silence Ratio', fmtRatio(convAnalysis.total_simultaneous_silence_ratio));
                        addConvRow('Silence Duration Stats', fmtStat(convAnalysis.simultaneous_silence_duration_estimation));
                        addConvRow('Simultaneous Speech', fmtMs(convAnalysis.total_simultaneous_speech_duration_ms));
                        addConvRow('Simultaneous Speech Ratio', fmtRatio(convAnalysis.total_simultaneous_speech_ratio));
                        addConvRow('Speech Duration Stats', fmtStat(convAnalysis.simultaneous_speech_duration_estimation));
                        
                        card.appendChild(table);
                        
                        // Render interrupts per speaker
                        if (convAnalysis.speaker_interrupts && convAnalysis.speaker_interrupts.length > 0) {
                            convAnalysis.speaker_interrupts.forEach(function(si) {
                                const intCard = document.createElement('div');
                                intCard.style.marginTop = '10px';
                                
                                const intTitle = document.createElement('h6');
                                intTitle.textContent = 'Interrupts by ' + (si.speaker_tag || 'Unknown');
                                intTitle.style.fontSize = '0.85rem';
                                intTitle.style.marginBottom = '4px';
                                intCard.appendChild(intTitle);
                                
                                const intInfo = document.createElement('div');
                                intInfo.className = 'interrupts-list';
                                intInfo.innerHTML = 'Count: <strong>' + (si.interrupts_count || 0) +
                                    '</strong> &nbsp;|&nbsp; Total duration: <strong>' + fmtMs(si.interrupts_duration_ms) + '</strong>';
                                intCard.appendChild(intInfo);
                                
                                if (si.interrupts && si.interrupts.length > 0) {
                                    const intList = document.createElement('div');
                                    intList.className = 'interrupts-list';
                                    si.interrupts.forEach(function(seg) {
                                        const span = document.createElement('span');
                                        span.className = 'interrupt-item';
                                        span.textContent = fmtMs(seg.start_time_ms) + ' → ' + fmtMs(seg.end_time_ms);
                                        intList.appendChild(span);
                                    });
                                    intCard.appendChild(intList);
                                }
                                
                                card.appendChild(intCard);
                            });
                        }
                        
                        convSection.appendChild(card);
                    } else {
                        convSection.innerHTML = '<div class="analysis-card">No conversation analysis data available.</div>';
                    }

                    // Render Summarization
                    const summaryData = response.result.summarization;
                    const summarySection = document.getElementById('summarySection');
                    summarySection.innerHTML = '';
                    
                    if (summaryData && summaryData.results && summaryData.results.length > 0) {
                        const card = document.createElement('div');
                        card.className = 'analysis-card';
                        
                        summaryData.results.forEach(function(item) {
                            var responseText = item.response || '';
                            
                            // Strip markdown code fences if present (e.g. ```json ... ```)
                            var fenceStart = new RegExp('^' + '`'.repeat(3) + '(?:json)?\\s*\\n?');
                            var fenceEnd = new RegExp('\\n?' + '`'.repeat(3) + '\\s*$');
                            responseText = responseText.replace(fenceStart, '').replace(fenceEnd, '').trim();
                            
                            // Try to parse as JSON and pretty-print it
                            try {
                                var parsed = JSON.parse(responseText);
                                if (typeof parsed === 'object' && parsed !== null) {
                                    // Render each field as a labeled paragraph
                                    Object.keys(parsed).forEach(function(key) {
                                        var val = parsed[key];
                                        var wrapper = document.createElement('div');
                                        wrapper.style.margin = '0 0 10px 0';
                                        
                                        var label = document.createElement('div');
                                        label.style.fontSize = '0.75rem';
                                        label.style.fontWeight = '600';
                                        label.style.color = '#7f8c8d';
                                        label.style.textTransform = 'uppercase';
                                        label.style.letterSpacing = '0.5px';
                                        label.style.marginBottom = '2px';
                                        label.textContent = key;
                                        wrapper.appendChild(label);
                                        
                                        var content = document.createElement('p');
                                        content.style.margin = '0';
                                        content.style.fontSize = '0.85rem';
                                        content.style.lineHeight = '1.5';
                                        if (typeof val === 'string') {
                                            content.textContent = val;
                                        } else {
                                            content.style.fontFamily = 'monospace';
                                            content.style.whiteSpace = 'pre-wrap';
                                            content.textContent = JSON.stringify(val, null, 2);
                                        }
                                        wrapper.appendChild(content);
                                        
                                        card.appendChild(wrapper);
                                    });
                                } else {
                                    throw new Error('not an object');
                                }
                            } catch (e) {
                                // Not valid JSON — display as plain text
                                const p = document.createElement('p');
                                p.style.margin = '0 0 8px 0';
                                p.style.fontSize = '0.85rem';
                                p.style.lineHeight = '1.5';
                                p.textContent = responseText;
                                card.appendChild(p);
                            }
                        });
                        
                        if (summaryData.content_usage) {
                            const usage = document.createElement('div');
                            usage.style.fontSize = '0.75rem';
                            usage.style.color = '#7f8c8d';
                            usage.style.marginTop = '8px';
                            usage.style.borderTop = '1px solid #eee';
                            usage.style.paddingTop = '6px';
                            usage.textContent = 'Tokens: ' +
                                (summaryData.content_usage.input_text_tokens || 0) + ' input, ' +
                                (summaryData.content_usage.completion_tokens || 0) + ' completion, ' +
                                (summaryData.content_usage.total_tokens || 0) + ' total';
                            card.appendChild(usage);
                        }
                        
                        summarySection.appendChild(card);
                    } else {
                        summarySection.innerHTML = '<div class="analysis-card">No summarization data available.</div>';
                    }
                } else {
                    setTimeout(checkStatus, 5000);
                }
            })
            .catch(error => {
                console.error('Error checking operation status:', error);
                document.getElementById('processingStt').style.display = 'none';
                document.getElementById('sendButtonStt').style.display = 'inline-block';
            });
    }
    
    checkStatus();
}

// Streaming recognition variables
let mediaRecorder;
let websocket;
let audioContext;
let audioWorkletNode;
let isRecording = false;
let mediaStream;

function setupStreamRecognition() {
    document.getElementById('startStreamBtn').addEventListener('click', startStreaming);
    document.getElementById('stopStreamBtn').addEventListener('click', stopStreaming);
    document.getElementById('clearStreamBtn').addEventListener('click', function() {
        document.getElementById('partialText').textContent = '';
        document.getElementById('finalText').innerHTML = '';
    });
}

async function startStreaming() {
    try {
        // Request microphone access
        mediaStream = await navigator.mediaDevices.getUserMedia({ 
            audio: {
                channelCount: 1,
                sampleRate: 16000,
                echoCancellation: true,
                noiseSuppression: true
            } 
        });
        
        const lang = document.getElementById('streamLanguageSelect').value;
        
        // Create WebSocket connection
        const wsProtocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
        const wsUrl = `${wsProtocol}//${window.location.host}/stream?lang=${lang}`;
        websocket = new WebSocket(wsUrl);
        
        websocket.onopen = function() {
            console.log('WebSocket connected');
            
            // Setup audio recording
            audioContext = new (window.AudioContext || window.webkitAudioContext)({ sampleRate: 16000 });
            const source = audioContext.createMediaStreamSource(mediaStream);
            
            // Use ScriptProcessorNode for compatibility
            const processor = audioContext.createScriptProcessor(4096, 1, 1);
            
            processor.onaudioprocess = function(e) {
                if (!isRecording) return;
                
                const inputData = e.inputBuffer.getChannelData(0);
                // Convert Float32Array to Int16Array (LINEAR16_PCM)
                const int16Data = new Int16Array(inputData.length);
                for (let i = 0; i < inputData.length; i++) {
                    const s = Math.max(-1, Math.min(1, inputData[i]));
                    int16Data[i] = s < 0 ? s * 0x8000 : s * 0x7FFF;
                }
                
                // Send audio chunk to backend
                if (websocket && websocket.readyState === WebSocket.OPEN) {
                    websocket.send(int16Data.buffer);
                }
            };
            
            source.connect(processor);
            processor.connect(audioContext.destination);
            
            isRecording = true;
            document.getElementById('startStreamBtn').disabled = true;
            document.getElementById('stopStreamBtn').disabled = false;
            document.getElementById('partialText').textContent = 'Слушаю...';
        };
        
        websocket.onmessage = function(event) {
            try {
                const result = JSON.parse(event.data);
                
                if (result.type === 'error') {
                    console.error('Recognition error:', result.message);
                    document.getElementById('partialText').textContent = 'Ошибка: ' + result.message;
                    document.getElementById('partialText').style.color = '#e74c3c';
                    return;
                }
                
                if (result.type === 'partial' && result.alternatives && result.alternatives.length > 0) {
                    document.getElementById('partialText').textContent = result.alternatives[0];
                    document.getElementById('partialText').style.color = '';
                } else if (result.type === 'final' && result.alternatives && result.alternatives.length > 0) {
                    const finalDiv = document.getElementById('finalText');
                    const p = document.createElement('p');
                    p.className = 'stream-final';
                    p.textContent = result.alternatives[0];
                    finalDiv.appendChild(p);
                    document.getElementById('partialText').textContent = '';
                    
                    // Auto-scroll to bottom
                    const streamResults = document.getElementById('streamResults');
                    streamResults.scrollTop = streamResults.scrollHeight;
                } else if (result.type === 'final_refinement' && result.alternatives && result.alternatives.length > 0) {
                    // Update last final text with refined version
                    const finalDiv = document.getElementById('finalText');
                    if (finalDiv.lastChild) {
                        finalDiv.lastChild.textContent = result.alternatives[0] + ' ';
                    }
                }
            } catch (e) {
                console.error('Error parsing WebSocket message:', e);
            }
        };
        
        websocket.onerror = function(error) {
            console.error('WebSocket error:', error);
            document.getElementById('partialText').textContent = 'Ошибка соединения';
            document.getElementById('partialText').style.color = '#e74c3c';
            stopStreaming();
        };
        
        websocket.onclose = function() {
            console.log('WebSocket closed');
            if (isRecording) {
                stopStreaming();
            }
        };
        
    } catch (error) {
        console.error('Error accessing microphone:', error);
        alert('Не удалось получить доступ к микрофону. Проверьте разрешения браузера.');
    }
}

function stopStreaming() {
    isRecording = false;
    
    if (websocket && websocket.readyState === WebSocket.OPEN) {
        websocket.send('END');
        websocket.close();
    }
    websocket = null;
    
    if (audioContext) {
        audioContext.close();
        audioContext = null;
    }
    
    if (mediaStream) {
        mediaStream.getTracks().forEach(track => track.stop());
        mediaStream = null;
    }
    
    document.getElementById('startStreamBtn').disabled = false;
    document.getElementById('stopStreamBtn').disabled = true;
    
    const partialText = document.getElementById('partialText');
    if (partialText.textContent === 'Слушаю...') {
        partialText.textContent = '';
    }
}
