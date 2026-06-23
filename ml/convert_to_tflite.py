"""
Convert the backend's MobileNetV2 embedding model to TensorFlow Lite format.

Run from the project root or ml/ folder:
    python ml/convert_to_tflite.py
"""

import os

import tensorflow as tf


base_model = tf.keras.applications.MobileNetV2(
    input_shape=(224, 224, 3),
    include_top=False,
    weights="imagenet",
)
model = tf.keras.Sequential(
    [
        base_model,
        tf.keras.layers.GlobalAveragePooling2D(),
    ]
)


converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()


output_path = os.path.join(os.path.dirname(__file__), "lizard_embedding.tflite")
with open(output_path, "wb") as f:
    f.write(tflite_model)

file_size_kb = os.path.getsize(output_path) / 1024
print(f"Success! Saved TFLite model to {output_path}")
print(f"File size: {file_size_kb:.1f} KB")
