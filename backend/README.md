# Cattle Breed Classifier API

A Gradio-powered API for the Moomingle app.

## Setup

```bash
pip install -r requirements.txt
python app.py
```

## Deployment to Hugging Face Spaces

1. Create a new Space at https://huggingface.co/spaces
2. Choose "Gradio" as the SDK
3. Upload these files: `app.py`, `requirements.txt`
4. The Space will auto-deploy

## API Endpoint

Once deployed, use:
```
POST https://YOUR-USERNAME-moomingle-classifier.hf.space/api/predict
```
