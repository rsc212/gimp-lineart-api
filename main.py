import os
import subprocess
import tempfile
from fastapi import FastAPI, UploadFile, HTTPException
from fastapi.responses import JSONResponse
from supabase import create_client
from dotenv import load_dotenv

# Load environment variables
load_dotenv()
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

# Initialize Supabase client
supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
app = FastAPI()

@app.post("/lineart")
async def generate_lineart(file: UploadFile):
    if not file.content_type.startswith("image/"):
        raise HTTPException(400, "Only images allowed")

    # Save upload to temp file
    with tempfile.NamedTemporaryFile(suffix=".jpg", delete=False) as in_tmp:
        in_tmp.write(await file.read())
        in_path = in_tmp.name

    # Prepare output temp file
    out_tmp = tempfile.NamedTemporaryFile(suffix=".png", delete=False)
    out_path = out_tmp.name

    # Run GIMP headless Script-Fu
    cmd = [
        "gimp", "-i",
        "-b", f"(script-fu-lineart-pipeline \"{in_path}\" \"{out_path}\")",
        "-b", "(gimp-quit 0)"
    ]
    proc = subprocess.run(cmd, capture_output=True)
    if proc.returncode != 0:
        raise HTTPException(500, proc.stderr.decode())

    # Upload result to Supabase Storage
    bucket = supabase.storage.from_('linearts')
    key = f"{file.filename.rsplit('.',1)[0]}_lineart.png"
    bucket.upload(key, out_path, {'content-type': 'image/png'})
    public_url = bucket.get_public_url(key)

    return JSONResponse({"lineart_url": public_url})
