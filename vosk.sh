#!/usr/bin/env bash

# ✅ اختيار مجلد
DIR=$(find ~ -type d -not -path '*/\.*' -maxdepth 3 | wofi --dmenu --prompt "📁 Select folder")
[ -z "$DIR" ] && echo "❌ No folder selected. Exiting." && exit 1

# ✅ اختيار ملف داخل المجلد
FILE=$(find "$DIR" -type f \( -iname "*.mkv" -o -iname "*.mp4" -o -iname "*.wav" \) | wofi --dmenu --prompt "🎞️ Select file")
[ -z "$FILE" ] && echo "❌ No file selected. Exiting." && exit 1

# ✅ تحديد أسماء الملفات الناتجة
BASENAME=$(basename "$FILE")
FILENAME="${BASENAME%.*}"
SAFE_FILENAME=$(echo "$FILENAME" | tr ' ' '_' | tr -d '()!#&') # لتجنب مشاكل الرموز والمسافات
AUDIO="$DIR/${SAFE_FILENAME}_audio.wav"
SRT="$DIR/${SAFE_FILENAME}_subs.srt"

# ✅ استخراج الصوت من الفيديو إن لزم
if [[ "$FILE" == *.mkv || "$FILE" == *.mp4 ]]; then
  echo "🎧 Extracting audio..."
  ffmpeg -y -i "$FILE" -ar 16000 -ac 1 -c:a pcm_s16le "$AUDIO"
else
  AUDIO="$FILE"
fi

# ✅ تفعيل البيئة واستخدام Vosk
echo "📝 Generating subtitles..."
source ~/vosk-venv/bin/activate

python3 <<EOF
from vosk import Model, KaldiRecognizer
import wave, json

def to_timestamp(secs):
    h = int(secs // 3600)
    m = int((secs % 3600) // 60)
    s = int(secs % 60)
    ms = int((secs - int(secs)) * 1000)
    return f"{h:02}:{m:02}:{s:02},{ms:03}"

model = Model("/home/yousef/vosk-models/vosk-model-en-us-0.22")

wf = wave.open("$AUDIO", "rb")
rec = KaldiRecognizer(model, wf.getframerate())
rec.SetWords(True)

counter = 1
srt = ""

while True:
    data = wf.readframes(4000)
    if len(data) == 0:
        break
    if rec.AcceptWaveform(data):
        result = json.loads(rec.Result())
        if "result" in result and result["result"]:
            words = result["result"]
            start = to_timestamp(words[0]["start"])
            end = to_timestamp(words[-1]["end"])
            text = " ".join([w["word"] for w in words])
            srt += f"{counter}\n{start} --> {end}\n{text}\n\n"
            counter += 1

final = json.loads(rec.FinalResult())
if "result" in final and final["result"]:
    words = final["result"]
    start = to_timestamp(words[0]["start"])
    end = to_timestamp(words[-1]["end"])
    text = " ".join([w["word"] for w in words])
    srt += f"{counter}\n{start} --> {end}\n{text}\n\n"

with open("$SRT", "w") as f:
    f.write(srt)

print("✅ Subtitles created:", "$SRT")
EOF

# ✅ دمج الترجمة في الفيديو إن أمكن
if [[ "$FILE" == *.mkv || "$FILE" == *.mp4 ]]; then
  OUTPUT="$DIR/${SAFE_FILENAME}_subtitled.mkv"
  echo "🎬 Embedding subtitles into video..."

  # ⛔ حل مشاكل المسارات ذات الرموز: escape path for ffmpeg
  SRT_ESCAPED=$(printf "%q" "$SRT")

  ffmpeg -y -i "$FILE" -vf "subtitles=filename='${SRT}'" -c:a copy "$OUTPUT"

  echo "✅ Subtitled video saved as: $OUTPUT"
else
  echo "🎧 Audio file only – subtitles generated: $SRT"
fi
