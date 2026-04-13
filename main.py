import os
from fastapi import FastAPI
from fastapi.responses import JSONResponse
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(
    title="Fast API Pipeline",
    description="Simple FastAPI application with health check",
    version="1.0.0"
)


@app.get("/", tags=["Root"])
async def read_root():
    final_message = os.getenv("WELCOME_MESSAGE", "Welcome to the Fast API Pipeline!")
    print(f"Environment variable WELCOME_MESSAGE: {final_message}")
    return JSONResponse(
        status_code=200,
        content={"message": final_message}
    )


@app.get("/health", tags=["Health"])
async def health_check():
    return JSONResponse(
        status_code=200,
        content={"status": "healthy"}
    )
    
@app.get("/heavy")
async def heavy():
    # Simulate CPU work
    total = sum(i * i for i in range(100000))
    return {"result": total}