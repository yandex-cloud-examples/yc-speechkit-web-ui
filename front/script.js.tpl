// Voices and roles dictionary
const voices = {
    alena: ["neutral", "good"],
    filipp: ["none"],
    ermil: ["neutral", "good"],
    jane: ["neutral", "good", "evil"],
    madirus: ["none"],
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
    lea: ["none"],
    john: ["none"],
    naomi: ["modern", "classic"],
    amira: ["none"],
    madi: ["none"],
    nigora: ["none"],
};

// Default values
const speeds = ["0.5x", "1.0x", "1.5x", "2.0x", "3.0x"];
const defaultVoice = 'alexander';
const defaultRole = 'good';

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

// Generating curl command
function updateCurlCommand(text) {
    var curlCmd = 'curl -X POST "${api_gw}/tts" \\\n' +
                  '-H "Content-Type: application/json" \\\n' +
                  '-d \'' + JSON.stringify({ 
                      text: text,
                      voice: currentVoice,
                      role: currentRole,
                      unsafe: currentUnsafeMode,
                      speed: currentSpeed 
                  }).replace(/'/g, "\\'") + '\'';
    document.getElementById('curlCommand').textContent = curlCmd;
}

document.addEventListener('DOMContentLoaded', function() {
    // Text area and character count
    var textArea = document.getElementById('textInput');
    var charCount = document.getElementById('charCount');
    
    // Update curl command when text changes
    textArea.addEventListener('input', function() {
        updateCurlCommand(textArea.value);
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
        updateCurlCommand(textArea.value);
        
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
        updateCurlCommand(text);
        
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
    
    // Copy curl command
    document.getElementById('copyButton').addEventListener('click', function() {
        var curlCommand = document.getElementById('curlCommand').textContent;
        navigator.clipboard.writeText(curlCommand).then(function() {
            console.log('Curl command copied to clipboard');
            // Optional: Show feedback to user
            const originalText = this.textContent;
            this.textContent = 'Скопировано!';
            setTimeout(() => {
                this.textContent = originalText;
            }, 1500);
        }.bind(this), function(err) {
            console.error('Could not copy text: ', err);
        });
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
        document.getElementById('resultSttTagOne').innerHTML = '';
        document.getElementById('resultSttTagTwo').innerHTML = '';
        
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
                    
                    // Display raw JSON
                    var resultSttDiv = document.getElementById("resultStt");
                    var newParagraphStt = document.createElement("p");
                    var responseTextStt = JSON.stringify(response, null, 2);
                    newParagraphStt.innerHTML = responseTextStt;
                    resultSttDiv.appendChild(newParagraphStt);
                    
                    // Process channel data
                    let result = response.result.chunks;
                    let textForChannel1 = "";
                    let textForChannel2 = "";
                    
                    result.forEach(chunk => {
                        chunk.alternatives.forEach(alternative => {
                            if (chunk.channelTag === "1") {
                                textForChannel1 += alternative.text + "\n";
                            } else if (chunk.channelTag === "2") {
                                textForChannel2 += alternative.text + "\n";
                            }
                        });
                    });
                    
                    let htmlTextForChannel1 = textForChannel1.replace(/\n/g, '<br>');
                    let htmlTextForChannel2 = textForChannel2.replace(/\n/g, '<br>');
                    
                    const resultSttDivChannel1 = document.getElementById('resultSttTagOne');
                    const resultSttDivChannel2 = document.getElementById('resultSttTagTwo');
                    
                    if (htmlTextForChannel1) {
                        let p1 = document.createElement('p');
                        p1.innerHTML = htmlTextForChannel1;
                        resultSttDivChannel1.appendChild(p1);
                    }
                    
                    if (htmlTextForChannel2) {
                        let p2 = document.createElement('p');
                        p2.innerHTML = htmlTextForChannel2;
                        resultSttDivChannel2.appendChild(p2);
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
