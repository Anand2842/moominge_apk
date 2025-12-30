"""
Cattle & Buffalo Breed Classifier API
Wraps vishnuamar/cattle-breed-classifier for use with Moomingle app.
"""

import gradio as gr
from huggingface_hub import hf_hub_download
import onnxruntime as ort
import numpy as np
import json
from PIL import Image
from torchvision import transforms

# Global model state
session = None
prototypes = None

BUFFALO_BREEDS = ['Bhadawari', 'Jaffarbadi', 'Mehsana', 'Murrah', 'Surti']
CATTLE_BREEDS = ['Gir', 'Kankrej', 'Ongole', 'Sahiwal', 'Tharparkar']

def load_model():
    """Download and load the ONNX model from Hugging Face."""
    global session, prototypes
    
    print("📥 Downloading model from Hugging Face...")
    model_path = hf_hub_download("vishnuamar/cattle-breed-classifier", "model.onnx")
    prototypes_path = hf_hub_download("vishnuamar/cattle-breed-classifier", "prototypes.json")
    
    session = ort.InferenceSession(model_path)
    with open(prototypes_path, 'r') as f:
        prototypes = json.load(f)
    
    print("✅ Model ready!")

def classify_breed(image: Image.Image) -> dict:
    """
    Classify the breed of cattle/buffalo in the image.
    
    Returns:
        dict with breed, confidence, animal_type, and all_scores
    """
    global session, prototypes
    
    if session is None:
        load_model()
    
    # Preprocess image
    image = image.convert('RGB')
    transform = transforms.Compose([
        transforms.Resize(256),
        transforms.CenterCrop(224),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])
    input_data = transform(image).unsqueeze(0).numpy()
    
    # Run inference
    features = session.run(None, {'input': input_data})[0][0]
    
    # Calculate similarities with prototypes
    similarities = {}
    for breed, prototype in prototypes['prototypes'].items():
        similarity = float(np.dot(features, np.array(prototype)))
        similarities[breed] = round(similarity, 4)
    
    # Get best match
    predicted_breed = max(similarities, key=similarities.get)
    confidence = similarities[predicted_breed]
    animal_type = 'Buffalo' if predicted_breed in BUFFALO_BREEDS else 'Cattle'
    
    return {
        'breed': predicted_breed,
        'confidence': confidence,
        'animal_type': animal_type,
        'all_scores': similarities
    }

def predict(image):
    """Gradio interface function."""
    if image is None:
        return "Please upload an image"
    
    result = classify_breed(image)
    
    # Format output for display
    output = f"""
## 🐄 Classification Result

**Animal Type:** {result['animal_type']}
**Breed:** {result['breed']}
**Confidence:** {result['confidence']:.2%}

### All Scores
"""
    for breed, score in sorted(result['all_scores'].items(), key=lambda x: -x[1]):
        bar = "█" * int(score * 20) if score > 0 else ""
        output += f"- {breed}: {score:.2%} {bar}\n"
    
    return output

# Create Gradio interface
demo = gr.Interface(
    fn=predict,
    inputs=gr.Image(type="pil", label="Upload Cattle/Buffalo Image"),
    outputs=gr.Markdown(label="Classification Result"),
    title="🐄 Cattle & Buffalo Breed Classifier",
    description="Upload an image of cattle or buffalo to identify its breed. Supports 10 breeds: Bhadawari, Jaffarbadi, Mehsana, Murrah, Surti (Buffalo) and Gir, Kankrej, Ongole, Sahiwal, Tharparkar (Cattle).",
    examples=[],
    allow_flagging="never",
)

if __name__ == "__main__":
    load_model()  # Pre-load for faster first request
    demo.launch()
