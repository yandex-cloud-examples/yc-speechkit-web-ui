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
    lola_ru: ["neutral", "strict"],
    zhanar_ru: ["neutral", "strict", "friendly"],
    yulduz_ru: ["neutral", "strict", "friendly"],
    nigora: ["none"],
    lola: ["none"],
    yulduz: ["none"]
};

// Default values
const speeds = ["0.5x", "1.0x", "1.5x", "2.0x", "3.0x"];
const defaultVoice = 'marina';
const defaultRole = 'neutral';

// Dropdowns and parameters
let currentVoice = '';
let currentRole = '';
let currentSpeed = '';
let currentUnsafeMode = false;

// Add CSS for dropdowns
document.addEventListener('DOMContentLoaded', function() {
    // Add CSS for custom dropdowns
    const style = document.createElement('style');
    style.textContent = `
        .custom-dropdown {
            position: relative;
            display: inline-block;
            margin-right: 10px;
            margin-bottom: 10px;
        }
        .dropdown-content {
            display: none;
            position: absolute;
            background-color: #f9f9f9;
            min-width: 160px;
            box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
            z-index: 1;
            max-height: 200px;
            overflow-y: auto;
        }
        .dropdown-content a {
            color: black;
            padding: 8px 12px;
            text-decoration: none;
            display: block;
            cursor: pointer;
        }
        .dropdown-content a:hover {
            background-color: #f1f1f1;
        }
        .show {
            display: block;
        }
    `;
    document.head.appendChild(style);
    
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
    selectDefaultSpeed("1.0x");
    
    // Setup dropdown toggles
    document.getElementById('voicesDropdown').addEventListener('click', function() {
        document.getElementById('voicesDropdownContent').classList.toggle('show');
    });
    
    document.getElementById('rolesDropdown').addEventListener('click', function() {
        document.getElementById('rolesDropdownContent').classList.toggle('show');
    });
    
    document.getElementById('speedsDropdown').addEventListener('click', function() {
        document.getElementById('speedsDropdownContent').classList.toggle('show');
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
        if (!event.target.matches('#speedsDropdown')) {
            const dropdown = document.getElementById('speedsDropdownContent');
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

// Populating speeds dropdown
function populateSpeedsDropdown() {
    const speedsDropdownContent = document.getElementById('speedsDropdownContent');
    speeds.forEach(function(speed) {
        const item = document.createElement('a');
        item.textContent = speed;
        item.onclick = function() {
            currentSpeed = speed;
            document.getElementById('speedsDropdown').textContent = speed;
            speedsDropdownContent.classList.remove('show');
        };
        speedsDropdownContent.appendChild(item);
    });
}

// Selecting default voice
function selectDefaultVoice(name) {
    currentVoice = name;
    populateRolesDropdown(name);
    document.getElementById('voicesDropdown').textContent = name;
}

// Selecting default speed
function selectDefaultSpeed(speed) {
    currentSpeed = speed;
    populateSpeedsDropdown();
    document.getElementById('speedsDropdown').textContent = speed;
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
                        link.download = 'audio.wav';
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
        
        navigator.clipboard.writeText(textToCopy).then(function() {
            const originalText = this.textContent;
            this.textContent = 'Copied!';
            setTimeout(() => {
                this.textContent = originalText;
            }, 1500);
        }.bind(this));
    });
    
    // Toggle Raw JSON visibility
    document.getElementById('toggleJsonBtn').addEventListener('click', function() {
        const section = document.getElementById('rawJsonSection');
        if (section.style.display === 'none') {
            section.style.display = 'block';
            this.textContent = 'Hide';
        } else {
            section.style.display = 'none';
            this.textContent = 'Show';
        }
    });
    
    // Toggle Speaker Analysis visibility
    document.getElementById('toggleSpeakerBtn').addEventListener('click', function() {
        const section = document.getElementById('speakerAnalysisSection');
        if (section.style.display === 'none') {
            section.style.display = 'block';
            this.textContent = 'Hide';
        } else {
            section.style.display = 'none';
            this.textContent = 'Show';
        }
    });
    
    // Toggle Conversation Analysis visibility
    document.getElementById('toggleConversationBtn').addEventListener('click', function() {
        const section = document.getElementById('conversationAnalysisSection');
        if (section.style.display === 'none') {
            section.style.display = 'block';
            this.textContent = 'Hide';
        } else {
            section.style.display = 'none';
            this.textContent = 'Show';
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
        document.getElementById('toggleSpeakerBtn').textContent = 'Show';
        document.getElementById('toggleConversationBtn').textContent = 'Show';
        
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
                        rate: rate
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
                    
                    result.forEach(chunk => {
                        const text = chunk.alternatives.map(a => a.text).join(' ');
                        if (!text.trim()) return;
                        
                        const isLeft = (chunk.channelTag === leftTag);
                        const side = isLeft ? 'left' : 'right';
                        
                        const bubble = document.createElement('div');
                        bubble.className = 'dialogue-bubble ' + side;
                        
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
