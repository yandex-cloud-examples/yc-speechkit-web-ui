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
const speeds          = ["0.5x", "1.0x", "1.5x", "2.0x", "3.0x"]
const defaultVoice    = 'alexander';
const defaultRole     = 'good';

// Dropdowns and parameters
let currentVoice      = '';
let currentRole       = '';
let currentSpeed      = '';
let currentUnsafeMode = false

// TTS
document.addEventListener('DOMContentLoaded', function () {
    populateVoicesDropdown();
    selectDefaultVoice(defaultVoice);
    selectDefaultSpeed("1.0x");
});

// Checking for unsafe mode toggle
document.getElementById('unsafeModeToggle').addEventListener('change', function() {
    currentUnsafeMode = this.checked;
    const button = document.getElementById('unsafeModeButton');
    
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
    maxLength = textInput.getAttribute('maxlength');
    charCount.textContent = currentLength + '/' + maxLength;
});

// Populating voices dropdown based on the dictionary
function populateVoicesDropdown() {
    const voicesDropdownMenu = document.querySelector('#voicesDropdown').nextElementSibling;
    for (const voice in voices) {
      const item = document.createElement('a');
      item.classList.add('dropdown-item');
      item.href = '#';
      item.textContent = voice;
      item.onclick = function() {
        currentVoice = voice
        populateRolesDropdown(voice);
        document.querySelector('#voicesDropdown').textContent = voice; 
    };
      voicesDropdownMenu.appendChild(item);
    }
}

// Populating speeds dropdown based on default values
function populateSpeedsDropdown() {
    const speedsDropdownMenu = document.querySelector('#speedsDropdown').nextElementSibling;
    speeds.forEach(function(speed) {
        const item = document.createElement('a');
        item.classList.add('dropdown-item');
        item.href = '#';
        item.textContent = speed;
        item.onclick = function() {
            currentSpeed = speed
            document.querySelector('#speedsDropdown').textContent = speed; 
        };
        speedsDropdownMenu.appendChild(item);
    });
}

// Selecting default voice
function selectDefaultVoice(name) {
    currentVoice = name
    populateRolesDropdown(name);
    document.querySelector('#voicesDropdown').textContent = name;
}

// Selecting default speed
function selectDefaultSpeed(speed) {
    currentSpeed = speed;
    populateSpeedsDropdown(speed);
    document.querySelector('#speedsDropdown').textContent = speed;
}

// Populating roles dropdown
function populateRolesDropdown(name) {
    const roles = voices[name];
    const rolesDropdownMenu = document.querySelector('#rolesDropdown').nextElementSibling;
    rolesDropdownMenu.innerHTML = '';
    roles.forEach((role, index) => {
      const item = document.createElement('a');
      item.classList.add('dropdown-item');
      item.href = '#';
      item.textContent = role;
      item.onclick = function() { 
        currentRole = role
        document.querySelector('#rolesDropdown').textContent = role;
      };
      rolesDropdownMenu.appendChild(item);

      if (index === 0) {
        currentRole = role
        document.querySelector('#rolesDropdown').textContent = role;
      }
    });
  }

// Generating curl command
function updateCurlCommand(text) {
    var curlCmd = 'curl -X POST "${api_gw}/tts" \\\n' +
                  '-H "Content-Type: application/json" \\\n' +
                  '-d \'' + JSON.stringify({ text: text,
                    voice: currentVoice,
                    role: currentRole,
                    unsafe: currentUnsafeMode,
                    speed: currentSpeed }).replace(/'/g, "\\'") + '\'';
    document.getElementById('curlCommand').textContent = curlCmd;
}

// Updating curl command based on the text change
var textArea = document.getElementById('textInput');
textArea.addEventListener('input', function() {
    updateCurlCommand(textArea.value);
});

// Support TTS formatting buttons
document.getElementById('insertPauseTiny').addEventListener('click', function() {
    var startPos = textArea.selectionStart;
    var endPos = textArea.selectionEnd;
    var textToInsert = '<[tiny]>';
    textArea.value = textArea.value.substring(0, startPos) 
        + textToInsert 
        + textArea.value.substring(endPos, textArea.value.length);
    textArea.focus();
    textArea.selectionStart = startPos + textToInsert.length;
    textArea.selectionEnd = startPos + textToInsert.length;
    updateCurlCommand(textArea.value);
});

document.getElementById('insertPauseSmall').addEventListener('click', function() {
    var startPos = textArea.selectionStart;
    var endPos = textArea.selectionEnd;
    var textToInsert = '<[small]>';
    textArea.value = textArea.value.substring(0, startPos) 
        + textToInsert 
        + textArea.value.substring(endPos, textArea.value.length);
    textArea.focus();
    textArea.selectionStart = startPos + textToInsert.length;
    textArea.selectionEnd = startPos + textToInsert.length;
    updateCurlCommand(textArea.value);
});

document.getElementById('insertPauseMedium').addEventListener('click', function() {
    var startPos = textArea.selectionStart;
    var endPos = textArea.selectionEnd;
    var textToInsert = '<[medium]>';
    textArea.value = textArea.value.substring(0, startPos) 
        + textToInsert 
        + textArea.value.substring(endPos, textArea.value.length);
    textArea.focus();
    textArea.selectionStart = startPos + textToInsert.length;
    textArea.selectionEnd = startPos + textToInsert.length;
    updateCurlCommand(textArea.value);
});

document.getElementById('insertPauseLarge').addEventListener('click', function() {
    var startPos = textArea.selectionStart;
    var endPos = textArea.selectionEnd;
    var textToInsert = '<[large]>';
    textArea.value = textArea.value.substring(0, startPos) 
        + textToInsert 
        + textArea.value.substring(endPos, textArea.value.length);
    textArea.focus();
    textArea.selectionStart = startPos + textToInsert.length;
    textArea.selectionEnd = startPos + textToInsert.length;
    updateCurlCommand(textArea.value);
});

document.getElementById('insertPauseHuge').addEventListener('click', function() {
    var startPos = textArea.selectionStart;
    var endPos = textArea.selectionEnd;
    var textToInsert = '<[huge]>';
    textArea.value = textArea.value.substring(0, startPos) 
        + textToInsert 
        + textArea.value.substring(endPos, textArea.value.length);
    textArea.focus();
    textArea.selectionStart = startPos + textToInsert.length;
    textArea.selectionEnd = startPos + textToInsert.length;
    updateCurlCommand(textArea.value);
});

document.getElementById('insertPauseMs').addEventListener('click', function() {
    var startPos = textArea.selectionStart;
    var endPos = textArea.selectionEnd;
    var textToInsert = ' sil<[500]> ';
    textArea.value = textArea.value.substring(0, startPos) 
        + textToInsert 
        + textArea.value.substring(endPos, textArea.value.length);
    textArea.focus();
    textArea.selectionStart = startPos + textToInsert.length;
    textArea.selectionEnd = startPos + textToInsert.length;
    updateCurlCommand(textArea.value);
});

document.getElementById('insertStress').addEventListener('click', function() {
    var startPos = textArea.selectionStart;
    var endPos = textArea.selectionEnd;
    var textToInsert = '+';
    textArea.value = textArea.value.substring(0, startPos) 
        + textToInsert 
        + textArea.value.substring(endPos, textArea.value.length);
    textArea.focus();
    textArea.selectionStart = startPos + textToInsert.length;
    textArea.selectionEnd = startPos + textToInsert.length;
    updateCurlCommand(textArea.value);
});

// Sending the request
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
                playbackButton.className = 'btn btn-sm btn-primary mt-2';
                playbackButton.innerHTML = '<i class="fas fa-play"></i> Прослушать';
                playbackButton.onclick = function() {
                    var audio = new Audio(audioUrl);
                    audio.play();
                };
                document.getElementById('playbackButtonContainer').appendChild(playbackButton);

                // Download button
                var downloadButton = document.createElement('button');
                downloadButton.className = 'btn btn-sm btn-primary ml-1 mt-2';
                downloadButton.innerHTML = '<i class="fas fa-download"></i> Скачать';
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
            // Handle HTTP error response
            console.error('HTTP Error:', response.statusText);
        }
    })
    .catch((error) => {
        console.error('Error:', error);
        document.getElementById('processing').style.display = 'none';
        document.getElementById('sendButton').style.display = 'inline-block';
    });
});

// Copy curl command button
document.getElementById('copyButton').addEventListener('click', function() {
    var curlCommand = document.getElementById('curlCommand').textContent;
    navigator.clipboard.writeText(curlCommand).then(function() {
        console.log('Curl command copied to clipboard');
    }, function(err) {
        console.error('Could not copy text: ', err);
    });
});

// Downloading a file
$(document).ready(function() {

    $('#fileInput').on('change', function() {
        var file = this.files[0]; // Access the selected file
        if (file.type == 'audio/wav') {
            document.getElementById('rateForm').classList.add('d-block');
            document.getElementById('rateForm').classList.remove('d-none');
        } else {
            document.getElementById('rateForm').classList.remove('d-block');
            document.getElementById('rateForm').classList.add('d-none');
            document.getElementById('sampleRateInput').value = '48000';
        }
    });

    $('#audioUploadForm').on('submit', function(e) {
        e.preventDefault();
        var formData = new FormData(this);
        var file = formData.get('file');
        var lang = formData.get('lang');
        var rate = formData.get('sampleRate');
        var fileName = file.name;

        document.getElementById('processingStt').classList.add('d-inline-block');
        document.getElementById('processingStt').classList.remove('d-none');
        
        document.getElementById('sendButtonStt').classList.add('d-none');
        document.getElementById('sendButtonStt').classList.remove('d-inline-block');


        document.getElementById('resultStt').innerHTML = '';
        document.getElementById('resultSttTagOne').innerHTML = '';
        document.getElementById('resultSttTagTwo').innerHTML = '';

        // Presigning url
        encoded_filename = encodeURIComponent(fileName)
        $.ajax({
            type: 'GET',
            url: `${api_gw}/presign?fileName=` + encoded_filename,
            success: function(response) {
                // upload
                var presignedUrl = response.url;
                var uploadData = new FormData();
                uploadData.append('file', file);

                $.ajax({
                    type: 'PUT',
                    url: presignedUrl,
                    data: file,
                    contentType: 'binary/octet-stream',
                    processData: false,
                    success: function() {
                        console.log('Upload to S3 successful');

                        // processing
                        var objectKey = response.key;
                        console.log(objectKey)
                        console.log(response)
                        $.ajax({
                            type: 'POST',
                            url: `${api_gw}/stt`,
                            data: JSON.stringify({key: objectKey, lang: lang, rate: rate}),
                            contentType: 'application/json',
                            success: function(response) {
                                console.log('STT processing initiated');
                                checkOperationStatus(response.operation);
                            },
                            error: function(error) {
                                console.error('Error during STT processing');
                                document.getElementById('processingStt').classList.add('d-none');
                                document.getElementById('processingStt').classList.remove('d-inline-block');
                                
                                document.getElementById('sendButtonStt').classList.add('d-inline-block');
                                document.getElementById('sendButtonStt').classList.remove('d-none');
                            }
                        });
                    },
                    error: function(error) {
                        console.error('Error during file upload to S3');
                        document.getElementById('processingStt').classList.add('d-none');
                        document.getElementById('processingStt').classList.remove('d-inline-block');
                        
                        document.getElementById('sendButtonStt').classList.add('d-inline-block');
                        document.getElementById('sendButtonStt').classList.remove('d-none');
                    }
                });
            },
            error: function(error) {
                console.error('Error fetching pre-signed URL');
                document.getElementById('processingStt').classList.add('d-none');
                document.getElementById('processingStt').classList.remove('d-inline-block');
                
                document.getElementById('sendButtonStt').classList.add('d-inline-block');
                document.getElementById('sendButtonStt').classList.remove('d-none');
            }
        });
    });
});

// Checking operation
function checkOperationStatus(operationId) {
    var checkStatus = function() {
        var url = '${api_gw}/operation?operationId=' + operationId;
        $.ajax({
            type: 'GET',
            url: url,
            success: function(response) {
                if (response.done == "true") {
                    console.log('Operation completed successfully');
                    console.log(response)
                    
                    document.getElementById('processingStt').classList.add('d-none');
                    document.getElementById('processingStt').classList.remove('d-inline-block');
                    
                    document.getElementById('sendButtonStt').classList.add('d-inline-block');
                    document.getElementById('sendButtonStt').classList.remove('d-none');
                    
                    var resultSttDiv = document.getElementById("resultStt");
                    var newParagraphStt = document.createElement("p");
                    var responseTextStt = JSON.stringify(response, null, 2);
                    newParagraphStt.innerHTML = responseTextStt
                    resultSttDiv.appendChild(newParagraphStt);

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
            },
            error: function(error) {
                console.error('Error checking operation status');
                document.getElementById('processingStt').classList.add('d-none');
                document.getElementById('processingStt').classList.remove('d-inline-block');
                
                document.getElementById('sendButtonStt').classList.add('d-inline-block');
                document.getElementById('sendButtonStt').classList.remove('d-none');
            }
        });
    };

    checkStatus();
}

// Validating the number of symbols
document.addEventListener('DOMContentLoaded', function () {
    var textInput = document.getElementById('textInput');
    var charCount = document.getElementById('charCount');
    var maxLength = textInput.getAttribute('maxlength');

    function updateCharCount() {
        var currentLength = textInput.value.length;
        maxLength = textInput.getAttribute('maxlength');
        charCount.textContent = currentLength + '/' + maxLength;
    }

    textInput.addEventListener('input', updateCharCount);

    // Initialize the character count on page load
    updateCharCount();
});