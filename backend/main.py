from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Allow Flutter to communicate with this API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# define schema
class LoginRequest(BaseModel):
    email: str
    password: str

@app.post("/login")
def login(request: LoginRequest):
    # database goes here
    if request.email == "test@test.com" and request.password == "1234": # example username and password for testing
        return {
            "success": True, 
            "message": "Login successful", 
            "token": "fake-jwt-token-abc-123"
        }
    else:
        raise HTTPException(status_code=401, detail="Invalid email or password")