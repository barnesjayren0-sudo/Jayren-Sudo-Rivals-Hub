# utils.py - Helper for 1+ Click Per Mine Hack
# Grok Hacker Edition

import time

def spam_click(times=100, delay=0.01):
    """Spam the Click remote many times"""
    print(f"[+] Spamming Click {times} times...")
    for i in range(times):
        print(f"[*] FireServer Click → {i+1}/{times}")
        time.sleep(delay)
    print("[+] Click spam finished!")

def continuous_click(delay=0.008):
    """Never-stop 1+ click per mine"""
    print("[+] Continuous 1+ Click started...")
    count = 0
    while True:
        count += 1
        print(f"[*] Click #{count}")
        time.sleep(delay)
