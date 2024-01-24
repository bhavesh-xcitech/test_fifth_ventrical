class CodeDir {
  String getPyCode(String fileName) {
    return """
import librosa, os
import numpy as np
from scipy.signal import find_peaks

os.environ["HDF5_USE_FILE_LOCKING"] = "FALSE"
print(os.getcwd())

def calculate_prominence(data, global_sr):
    two_seconds = 2 * global_sr
    if len(data) < two_seconds:
        return 1
    skip_sample_rate = global_sr - 1000
    data = data[skip_sample_rate:]
    reverse_skip_sample = -1 * skip_sample_rate
    data = data[:-reverse_skip_sample]
    n_mean, n_std = np.mean(data), np.std(data)
    arr = []
    for i in data:
        temp = i - n_mean
        temp = temp / n_std
        if (np.abs(temp) >= 3 and i > 0):
            arr.append(i)
    arr.sort()
    prominence = np.median(arr)
    return prominence

def return_beats(data, prominence, sr=4000):
    numerator = 36 * sr
    distance = numerator / 100
    peaks, _ = find_peaks(data, prominence=prominence, distance=distance)
    return peaks

def extract_features(audio_file):
    y, sr = librosa.load(audio_file, sr=None)
    prominence = calculate_prominence(y, sr)
    peaks = return_beats(y, prominence, sr)

    if len(peaks) < 2:
        return None

    differences = np.diff(peaks)
    avg_duration = np.mean(differences) / sr
    return avg_duration

def predict_heart_rate(model, audio_file):
    features = extract_features(audio_file)

    if features is not None:
        predicted_hr = model.predict(np.array(features).reshape(-1, 1))
        return predicted_hr[0]

import h5py
from sklearn.linear_model import LinearRegression

def load_model_from_h5(h5_file_path):
    with h5py.File(h5_file_path, 'r') as h5_file:
        coef = h5_file['coef'][()]
        intercept = h5_file['intercept'][()]

    model = LinearRegression()
    model.coef_ = coef
    model.intercept_ = intercept

    return model

heart_rate_prediction = load_model_from_h5('storage/emulated/0/Documents/Chesto/linear_regression_model_for_HR.h5')

print("HR: ",int(predict_heart_rate(heart_rate_prediction, "storage/emulated/0/Documents/Chesto/$fileName.wav")))

 """;
  }

  String getContinueHr(rawAudioData) {
    return """
import numpy as np
from scipy.signal import find_peaks
import time


# Parameters
sampling_rate = 6000
chunk_size = 1800 

try:
    while True:
        audio_chunk = $rawAudioData[:chunk_size]
        $rawAudioData = $rawAudioData[chunk_size:]
        audio_chunk_bytes = bytes(audio_chunk)

        audio_signal = np.frombuffer(audio_chunk_bytes, dtype=np.int16)

        fft_result = np.fft.fft(audio_signal)

        peaks, _ = find_peaks(np.abs(fft_result), threshold = 100000)
        
        # Calculate heart rate 
        if len(peaks) > 1:
          count = 1
          time_difference = np.diff(peaks)
          heart_rate = 1 / (np.mean(time_difference) / sampling_rate) * 60
          print("Real-time Heart Rate:", heart_rate/count)
          count = count + 1

        # Break the loop if there's no more data
        if not $rawAudioData:
            break

except KeyboardInterrupt:
    pass

 """;
  }

}
