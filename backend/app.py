from flask import Flask, request, jsonify
import threading
import os
import cv2
from ultralytics import YOLO
import geocoder
import pyttsx3
import time
from twilio.rest import Client as TwilioClient
from supabase import create_client, Client
from dotenv import load_dotenv

# ================== Supabase Setup ==================
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), ".env"))

# Read from environment variables
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_ANON_KEY = os.getenv("SUPABASE_ANON_KEY")

# Create Supabase client
supabase = create_client(SUPABASE_URL, SUPABASE_ANON_KEY)


# ================== Flask Setup ==================
app = Flask(__name__)

# ================== Twilio Setup ================cd
account_sid = os.getenv("TWILIO_SID")
auth_token = os.getenv("TWILIO_AUTH_TOKEN")
twilio_client = TwilioClient(account_sid, auth_token)

TWILIO_NUMBER = "+17855039317"
TO_NUMBER = "+919380981939"

# ================== Helpers ==================
engine = pyttsx3.init()

def speak(text):
    def run_speech():
        engine.say(text)
        engine.runAndWait()
    threading.Thread(target=run_speech).start()

def get_location():
    g = geocoder.ip('me')
    if g.ok:
        lat, lon = g.latlng
        print(f"📍 Current Location: {lat}, {lon}")
        return lat, lon
    return None, None

def send_alert(msg):
    try:
        message = twilio_client.messages.create(
            body=msg,
            from_=TWILIO_NUMBER,
            to=TO_NUMBER
        )
        print("✅ SMS Sent:", message.sid)
    except Exception as e:
        print("❌ SMS Failed:", e)

def overlap_ratio(boxA, boxB):
    xA = max(boxA[0], boxB[0])
    yA = max(boxA[1], boxB[1])
    xB = min(boxA[2], boxB[2])
    yB = min(boxA[3], boxB[3])
    interArea = max(0, xB - xA) * max(0, yB - yA)
    if interArea == 0:
        return 0.0
    boxAArea = (boxA[2]-boxA[0]) * (boxA[3]-boxA[1])
    boxBArea = (boxB[2]-boxB[0]) * (boxB[3]-boxB[1])
    return interArea / float(min(boxAArea, boxBArea))

# ================== Accident Detection Thread ==================
def run_accident_detection():
    print("🚗 Accident detection started...")
    speak("Accident detection started.")
    
    model = YOLO("yolov8n.pt")
    cap = cv2.VideoCapture(0)
    last_alert_time = 0
    cooldown = 5

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        h, w, _ = frame.shape
        car_zone = (int(w*0.3), int(h*0.6), int(w*0.7), h-10)
        cv2.rectangle(frame, (car_zone[0], car_zone[1]),
                      (car_zone[2], car_zone[3]), (255, 0, 0), 2)
        cv2.putText(frame, "OUR CAR ZONE", (car_zone[0], car_zone[1]-10),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 0, 0), 2)

        results = model(frame)
        annotated_frame = results[0].plot()
        vehicles = []

        for box in results[0].boxes:
            cls = int(box.cls[0])
            conf = float(box.conf[0])
            x1, y1, x2, y2 = map(int, box.xyxy[0])
            if cls in [2, 3, 5, 7] and conf > 0.5:
                vehicles.append((x1, y1, x2, y2))
                cv2.rectangle(annotated_frame, (x1, y1),
                              (x2, y2), (0, 255, 0), 2)

                overlap = overlap_ratio((x1, y1, x2, y2), car_zone)
                if overlap > 0.3:
                    now = time.time()
                    if now - last_alert_time > cooldown:
                        speak("Accident detected with our car.")
                        lat, lon = get_location()
                        if lat and lon:
                            send_alert(
                                f"🚨 Accident detected with OUR CAR! Location: https://www.google.com/maps?q={lat},{lon}")
                        else:
                            send_alert("🚨 Accident detected with OUR CAR! Location unavailable.")
                        last_alert_time = now

        for i in range(len(vehicles)):
            for j in range(i + 1, len(vehicles)):
                overlap = overlap_ratio(vehicles[i], vehicles[j])
                if overlap > 0.3:
                    now = time.time()
                    if now - last_alert_time > cooldown:
                        speak("Accident detected between other vehicles.")
                        lat, lon = get_location()
                        if lat and lon:
                            send_alert(
                                f"🚨 Accident detected between vehicles! Location: https://www.google.com/maps?q={lat},{lon}")
                        else:
                            send_alert("🚨 Accident detected between vehicles! Location unavailable.")
                        last_alert_time = now

        cv2.imshow("Accident Detection", annotated_frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

# ================== API Routes ==================
@app.route('/')
def home():
    return jsonify({"status": "✅ Server running! Use /start_accident_detection to begin."})

@app.route('/start_accident_detection', methods=['POST'])
def start_accident_detection():
    threading.Thread(target=run_accident_detection).start()
    return jsonify({"message": "✅ Accident detection started"}), 200

# ================== Run Server ==================
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)